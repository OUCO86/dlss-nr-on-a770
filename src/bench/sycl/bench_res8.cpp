// bench_res8 v2 -- the byte-plane blade's NET ceiling with VECTORIZED
// encode/decode (the scalar v2 legs were ALU-bound garbage: 2.5ms/touch).
// encode = e4m3_vec_v8 (the shipped 32-wide chain, copy) + row-scale divide;
// decode = bit-trick e4m3->f32 vector (lmxx's composite trick: 2^e mantissa
// in f32 exponent field, scaled). Plane = the 1267 shape (33.4M elems,
// rows=522240 W=64). This prices the REAL kernel forms, not scalar toys.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <chrono>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// shipped e4m3_vec_v8 VERBATIM (gemm_s8_v8_kernel.hpp:393) -- grid snap, no scale
template <int N> static inline esimd::simd<float,N> e4m3_vec(esimd::simd<float,N> x){
    esimd::simd<float,N> mag = esimd::abs(x);
    mag = (esimd::min)(mag, esimd::simd<float,N>(448.0f));
    esimd::simd<int32_t,N> mb; mb = mag.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> exp = (mb >> 23) & esimd::simd<int32_t,N>(0xFF);
    exp = (esimd::max)(exp, esimd::simd<int32_t,N>(121)) - 3;
    esimd::simd<int32_t,N> sb = exp << 23; esimd::simd<float,N> step; step = sb.template bit_cast_view<float>();
    esimd::simd<int32_t,N> rb = (esimd::simd<int32_t,N>(254) - exp) << 23; esimd::simd<float,N> recip; recip = rb.template bit_cast_view<float>();
    esimd::simd<float,N> t = mag * recip;
    esimd::simd<float,N> r = esimd::rnde<float>(t) * step;
    esimd::simd<int32_t,N> ri; ri = r.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> negm = x < esimd::simd<float,N>(0.0f);
    esimd::simd<int32_t,N> out = (ri & esimd::simd<int32_t,N>(0x7FFFFFFF)) | (negm << 31);
    esimd::simd<float,N> res; res = out.template bit_cast_view<float>();
    return res; }

constexpr size_t n = 33423360; constexpr unsigned W = 64;

int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  float* src=(float*)malloc_device(n*4,q);
  half* p16=(half*)malloc_device(n*2,q);
  int8_t* p8=(int8_t*)malloc_device(n,q);
  float* sc8=(float*)malloc_device((n/W)*4,q);
  float* out=(float*)malloc_device(n*4,q);
  q.parallel_for(range(n),[=](item<1>it){ size_t i=it.get_id(0); src[i]=0.001f*(float)(i%1000)-0.5f; }).wait();

  // f16 write leg (the shipped narrow store shape): simd16 loads, convert, store
  auto wr16=[&]{ q.parallel_for(range(n/16),[=](item<1>it){ size_t i=it.get_id(0)*16;
      esimd::simd<float,16> v = esimd::block_load<float,16>(src+i);
      esimd::block_store<half,16>(p16+i, esimd::convert<half>(v)); }); };
  // e4m3 write leg: row per work-item group of 4 lanes? simplest: 16-elem slab;
  // row-scale = row peak needs the whole row (W=64) -> thread = 1 ROW (64 elems,
  // 4x simd16 GRF = the rowthread proven form): peak -> scale -> div -> e4m3 grid
  // -> code pack 4B words -> store 64 bytes.
  auto wr8=[&]{ q.parallel_for(range(n/W),[=](item<1>it){ size_t r=it.get_id(0); size_t i=r*W;
      esimd::simd<float,64> v = esimd::block_load<float,64>(src+i);
      float peak = esimd::hmax<float,float,64>(esimd::abs(v));
      float s = peak>0.f ? peak/448.f : 1.f; sc8[r]=s;
      esimd::simd<float,64> qv = e4m3_vec<64>(v/s);          // grid-snapped, [-448,448]
      // snap to byte codes: qv/s is on the e4m3 grid; encode = exponent/mantissa bits
      esimd::simd<int32_t,64> b = qv.template bit_cast_view<int32_t>();
      esimd::simd<int32_t,64> e = (b >> 23) & 255; esimd::simd<int32_t,64> m = (b >> 20) & 7;
      esimd::simd<int32_t,64> code = (((e-127+7) << 3) | m) & 255;
      code |= ((b >> 25) << 7);                               // sign bit
      esimd::block_store<int8_t,64>(p8+i, esimd::convert<int8_t>(code)); }); };
  // f16 read leg: 16-wide load, convert, fma-add into skip pattern (sum 16)
  auto rd16=[&]{ q.parallel_for(range(n/16),[=](item<1>it){ size_t i=it.get_id(0)*16;
      esimd::simd<half,16> p = esimd::block_load<half,16>(p16+i);
      esimd::block_store<float,16>(out+i, esimd::convert<float>(p)); }); };
  // e4m3 read leg: 64B load -> decode bits -> *scale -> store f32
  auto rd8=[&]{ q.parallel_for(range(n/64),[=](item<1>it){ size_t r=it.get_id(0), i=r*W;
      esimd::simd<int8_t,64> b8 = esimd::block_load<int8_t,64>(p8+i);
      esimd::simd<uint32_t,64> b = esimd::convert<uint32_t>(b8) & 255;
      esimd::simd<uint32_t,64> sgn = (b >> 7) << 31;
      esimd::simd<uint32_t,64> e = (b >> 3) & 15, m = b & 7;
      // normal: ((e-7)+127)<<23 | m<<20 ; subnormal e==0: value = m*2^-9 (rare, fold)
      // PRICING form: the subnormal band (e==0) is folded into the normal path
      // (timing-relevant only; the shipped kernel's decode is the correctness judge).
      esimd::simd<uint32_t,64> f32b = ((e + 120u) << 23) | (m << 20);
      esimd::simd<uint32_t,64> sv = f32b | sgn;
      esimd::simd<float,64> v = sv.template bit_cast_view<float>();
      float s = sc8[r];
      esimd::block_store<float,64>(out+i, v * esimd::simd<float,64>(s)); }); };

  auto wall=[&](std::function<void()>f){ double b=1e9;
    for(int r=0;r<3;++r){ auto t0=std::chrono::steady_clock::now();
      for(int i=0;i<4;++i) f(); q.wait();
      b=std::min(b,std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/4);} return b; };
  double w16=wall(wr16), w8=wall(wr8), r16=wall(rd16), r8=wall(rd8);
  printf("per-touch ms: write f16=%.3f e4m3=%.3f | read f16=%.3f e4m3=%.3f\n",w16,w8,r16,r8);
  printf("frame W122+R278: f16=%.1f ms  e4m3=%.1f ms  NET SAVED=%.1f ms\n",
         (122*w16+278*r16), (122*w8+278*r8), (122*w16+278*r16)-(122*w8+278*r8));
  return 0;
}
