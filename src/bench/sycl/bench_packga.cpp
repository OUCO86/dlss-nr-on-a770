// bench_packga.cpp -- the f16-pack scalar-residual audit's PRICE probe (15:2x card
// queued two windows, done 17:5x): the global_attention family's THREE remaining
// scalar packs at the frame's real shapes (rows=2040, heads=2; the attnV pack_a16_b
// is already dissolved by NR_GA_TILE's softmax-tiled store):
//   pack_a16_b   (Q: (heads,rows,32) -> tile map)      261K elems/call
//   pack_b16_t_b (Kk: (heads,rows,32) N-major -> B map) 261K elems/call
//   pack_b16_b   (V: (heads,rows,32) -> B map)          261K elems/call
// All three run ONE element per thread (2B load + 2B store = the frame's last
// scalar staging group). Vec variants priced here BEFORE touching the dll
// (military rule 8). Judges: byte diff vs the scalar form = EXACT, then time.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include <functional>
#include "pack_device.hpp"
using namespace sycl;

// ---- vec variants (the audit's candidates; maps VERBATIM from the scalar forms) ----
// pack_a16_b vec: dest run (fixed il, k=0..15) = 16 CONTIGUOUS halves (32B);
// src = A[srow*K + kc*16 .. +15] = 32B contiguous (K=32 %16==0). Same form as
// pack_a16_v with the gg dimension.
static inline void pack_a16_b_v(sycl::queue& q, const sycl::half* A, sycl::half* Ap,
                                int M, int Mp, int K, int batches) {
    const int TS = 16;
    int tr_n = Mp / TS, kb_n = K / TS;
    size_t per = (size_t)tr_n * kb_n * 2 * 128;          // = Mp*K
    q.parallel_for(sycl::range((size_t)batches * per / 16), [=](sycl::item<1> it) {
        size_t d16 = it.get_id(0);
        size_t gg = d16 / (per / 16); size_t d = (d16 % (per / 16)) * 16;
        size_t rest = d / 16;
        int il = (int)(rest % 8); rest /= 8;
        int strip = (int)(rest % 2); size_t blk = rest / 2;
        int kc = (int)(blk % (size_t)kb_n); int tr = (int)(blk / (size_t)kb_n);
        int srow = tr * TS + strip * 8 + il;
        const sycl::half* Ab = A + gg * (size_t)M * K;
        sycl::half* Apb = Ap + gg * per;
        sycl::vec<unsigned, 8> v(0u);
        if (srow < M)
            v = *reinterpret_cast<const sycl::vec<unsigned, 8>*>(Ab + (size_t)srow * K + (size_t)kc * TS);
        *reinterpret_cast<sycl::vec<unsigned, 8>*>(Apb + d) = v;
    });
}
// pack_b16_b vec: dest block ((kc*tc_n+tc)*2+js)*128 = 128 CONTIGUOUS halves (256B),
// filled from src rows (kc*TS+k) k=0..15 at columns tc*TS+js*8+jl jl=0..7:
// = 16 loads of 8 strided 16B? NO -- one thread per (blk16) = 16 halves of ONE src row:
// src row run B[(kc*TS+k)*N + tc*TS + js*8 .. +7] = 8 halves (16B, contiguous!);
// its dest slots = base + kq*16 + jl*2 + kpar (scattered within the 128 block).
// Form: thread handles one (kc,tc,k) src row-strip (js fixed? no). Simplest exact map:
// thread per (blk, k): loads 8 halves (16B) at src, writes 8 x 2B strided (stride 2)
// -- load-side vectorized, store-side 8 scalars. Better: thread per (blk2, kq):
// loads TWO rows (k=2*kq, 2*kq+1) = 2 x 16B at js=0 and js=1 strips = 4 loads,
// builds the 32B dest word (kq*16 + jl*2 + kpar) for both js and stores 2 x vec<8>.
// Even better: thread per (blk2, k) -> 2 loads (js=0,1 rows) -> 2 vec<8> stores.
// dest for (blk2, k): half0 = B[(kc*TS+k)*N + tc*TS + 0..7] at base0+(k/2)*16+{0,2,..14}
//   -> that is 8 halves with stride 2 = NOT contiguous. Hmm.
// Re-read the map: dest = ((kc*tc_n+tc)*2+js)*128 + (k/2)*16 + jl*2 + (k%2).
// For fixed (kc,tc,js,k): the 8 jl values = slots {(k/2)*16 + jl*2 + (k%2)} = 8 halves
// stride-2 within a 16-half band. A PAIR of k (2k,2k+1) fills the FULL 16-half band
// (jl*2+0 and jl*2+1) = 32B contiguous. So: thread per (kc,tc,js,kq):
//   loads: B[(kc*TS+2kq)*N + tc*TS+js*8 .. +7] (16B) and row 2kq+1 (16B)
//   interleaves them half-by-half into one 32B vec, ONE vec<16>/vec<unsigned,8> store.
static inline void pack_b16_b_v(sycl::queue& q, const sycl::half* B, sycl::half* Bp,
                                int K, int N, int batches) {
    const int TS = 16;
    int kb_n = K / TS, tc_n = N / TS;
    size_t per = (size_t)kb_n * tc_n * 2 * 128;          // = K*N
    q.parallel_for(sycl::range((size_t)batches * per / 16), [=](sycl::item<1> it) {
        size_t d16 = it.get_id(0);
        size_t gg = d16 / (per / 16); size_t d = (d16 % (per / 16)) * 16;
        size_t blk = d / 128; int band = (int)(d % 128);   // band = kq*16
        int js = (int)(blk % 2); size_t blk2 = blk / 2;
        int tc = (int)(blk2 % (size_t)tc_n); int kc = (int)(blk2 / (size_t)tc_n);
        int kq = band / 16;
        const sycl::half* Bb = B + gg * (size_t)K * N;
        sycl::half* Bpb = Bp + gg * per;
        const sycl::half* r0 = Bb + (size_t)(kc * TS + 2 * kq) * N + tc * TS + js * 8;
        const sycl::half* r1 = r0 + N;
        // 8 halves = 16B = vec<unsigned,4> per row (the row run is 16B-aligned:
        // N=32 -> row offset (kc*16+2kq)*32 halves = 64B mult; + tc*16+js*8 halves
        // = 16B mult -> the two loads are 16B-aligned).
        sycl::vec<unsigned, 4> lo = *reinterpret_cast<const sycl::vec<unsigned, 4>*>(r0);
        sycl::vec<unsigned, 4> hi = *reinterpret_cast<const sycl::vec<unsigned, 4>*>(r1);
        // dest band (16 halves = 32B): word w (halves 2w,2w+1) at slot kq*16+2w+? :
        // slot(k,jl) = (k/2)*16 + jl*2 + (k%2). half 2w of the band = jl=w,kpar=0 ->
        // lo's half w; half 2w+1 = jl=w,kpar=1 -> hi's half w.
        sycl::vec<unsigned, 8> o;
        {
            const sycl::half* l8 = reinterpret_cast<const sycl::half*>(&lo);
            const sycl::half* h8 = reinterpret_cast<const sycl::half*>(&hi);
            unsigned* ou = reinterpret_cast<unsigned*>(&o);
            for (int w = 0; w < 8; ++w)
                ou[w] = (unsigned)l8[w].bits() | ((unsigned)h8[w].bits() << 16);
        }
        *reinterpret_cast<sycl::vec<unsigned, 8>*>(Bpb + d) = o;
    });
}
// pack_b16_t_b vec: src = B[(tc*TS + js*8 + jl)*K + kc*TS + k]. For fixed (tc,js,k),
// the 8 jl are STRIDED (stride K); but for fixed (tc,js,jl), k=0..15 = 32B contiguous.
// dest = ((kc*tc_n+tc)*2+js)*128 + (k/2)*16 + jl*2 + (k%2).
// Pair over kc? No -- pair over k again: thread per (kc,tc,js,kq):
//   loads row (tc*TS+js*8)*K + kc*TS + 2kq (16B: k=2kq..2kq+15?? NO, 8 halves =
//   k=2kq..2kq+7 only if 8 halves = 16B) -- hmm, kq spans 16 k per band.
// Simplest exact: thread per (kc,tc,js,jl): ONE 16-half run k=0..15 = 32B load;
//   dest slots = (k/2)*16 + jl*2 + (k%2) = 16 scattered 2B stores = WORSE.
// Two-row interleave like b16_b: thread per (kc,tc,kq): for js=0,1 and each jl:
//   slot (kq*16 + jl*2 + kpar) gets B[(tc*TS+js*8+jl)*K + kc*TS + 2kq+kpar].
//   = gathers from 16 src rows (js*8+jl) x 2 halves = 16 x 4B loads -> 2 x 32B stores.
//   Load side strided, store side wide. Mirror of the scalar form's other diagonal.
// Try the (kc,tc,js,kq) thread = 2 rows (k=2kq,2kq+1) x 8 jl = 16 x 2B loads,
//   16B store (band). Or (kc,tc,kq,kpar?) ... price BOTH store-wide and load-wide.
static inline void pack_b16_t_b_v(sycl::queue& q, const sycl::half* B, sycl::half* Bp,
                                  int K, int N, int batches) {
    const int TS = 16;
    int kb_n = K / TS, tc_n = N / TS;
    size_t per = (size_t)kb_n * tc_n * 2 * 128;
    // thread = (gg, kc, tc, js, kq): 16 x 2B strided loads (jl=0..7, k=2kq,2kq+1),
    // 32B contiguous store.
    q.parallel_for(sycl::range((size_t)batches * kb_n * tc_n * 2 * 8), [=](sycl::item<1> it) {
        size_t g = it.get_id(0);
        size_t gg = g / (per / 16); size_t l = g % (per / 16);
        int kq = (int)(l % 8); l /= 8;
        int js = (int)(l % 2); l /= 2;
        int tc = (int)(l % (size_t)tc_n); int kc = (int)(l / (size_t)tc_n);
        const sycl::half* Bb = B + gg * (size_t)N * K;
        sycl::half* Bpb = Bp + gg * per;
        unsigned ou[8];
        for (int w = 0; w < 8; ++w) {           // w = jl
            unsigned lo = (unsigned)*reinterpret_cast<const unsigned short*>(
                Bb + (size_t)(tc * TS + js * 8 + w) * K + (size_t)kc * TS + 2 * kq);
            unsigned hi = (unsigned)*reinterpret_cast<const unsigned short*>(
                Bb + (size_t)(tc * TS + js * 8 + w) * K + (size_t)kc * TS + 2 * kq + 1);
            ou[w] = lo | (hi << 16);            // slot = kq*16 + jl*2 + kpar
        }
        sycl::vec<unsigned, 8> o;
        for (int w = 0; w < 8; ++w) o[w] = ou[w];
        size_t d = (((size_t)kc * tc_n + tc) * 2 + js) * 128 + kq * 16;
        *reinterpret_cast<sycl::vec<unsigned, 8>*>(Bpb + d) = o;
    });
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  auto tm=[&](std::function<void()> f,int n)->double{
    f(); q.wait();
    auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<n;++i) f();
    q.wait();
    return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
  // GA frame shapes: rows=2040 K=32 (Q leg A-pack), Kk = (rows,32) N-major B_t-pack,
  // V = (rows,32) K-major? V is (K=rows,N=32): pack_b16_b(K=rows,N=32). heads=2.
  // rows%16==0 is the recorder's guard (2040 %16=8 would FAILMSG) -> the frame's
  // real GA rows is 2048 (the census note's "rows=2040" is the WINDOW family's).
  struct G{int rows,heads;}; G gs[]={{2048,2},{1024,2}};
  for(auto g:gs){
    int rows=g.rows, hd=g.heads, Mp=((rows+15)/16)*16;
    size_t nA=(size_t)hd*rows*32, nP=(size_t)hd*Mp*32;
    std::vector<sycl::half> A(nA), Bk(nA), V(nA);
    std::mt19937 rng(11);
    for(auto&x:A)x=sycl::half((float)((int)(rng()%2000)-1000)/64.f);
    for(auto&x:Bk)x=sycl::half((float)((int)(rng()%2000)-1000)/64.f);
    for(auto&x:V)x=sycl::half((float)((int)(rng()%2000)-1000)/64.f);
    sycl::half *dA=(sycl::half*)malloc_device(nA*2,q),*dB=(sycl::half*)malloc_device(nA*2,q),*dV=(sycl::half*)malloc_device(nA*2,q);
    size_t nP2=(size_t)hd*rows*rows;   // the scores A-pack is rows-wide? NO: Q pack K=32. dBk/dV maps K*N=rows*32 or 32*rows = nA.
    sycl::half *dP1=(sycl::half*)malloc_device(nP*2,q),*dP2=(sycl::half*)malloc_device(nP*2,q);
    sycl::half *dQ1=(sycl::half*)malloc_device(nA*2,q),*dQ2=(sycl::half*)malloc_device(nA*2,q);
    q.memcpy(dA,A.data(),nA*2).wait(); q.memcpy(dB,Bk.data(),nA*2).wait(); q.memcpy(dV,V.data(),nA*2).wait();
    (void)nP2;
    // 1. pack_a16_b (Q): M=rows,K=32
    packdev::pack_a16_b(q,dA,dP1,rows,Mp,32,hd);
    pack_a16_b_v(q,dA,dP2,rows,Mp,32,hd);
    q.wait();
    { std::vector<sycl::half> h1(nP),h2(nP);
      q.memcpy(h1.data(),dP1,nP*2).wait(); q.memcpy(h2.data(),dP2,nP*2).wait();
      size_t d=0; for(size_t i=0;i<nP;++i) if(memcmp(&h1[i],&h2[i],2)) d++;
      double bs=tm([&]{ packdev::pack_a16_b(q,dA,dP1,rows,Mp,32,hd); },21);
      double bv=tm([&]{ pack_a16_b_v(q,dA,dP2,rows,Mp,32,hd); },21);
      printf("pack_a16_b    rows=%-5d hd=%d  scalar=%8.4f vec=%8.4f (%.2fx) diff %zu/%zu\n", rows,hd,bs,bv,bs/bv,d,nP); }
    // 2. pack_b16_t_b (Kk): K=32,N=rows
    packdev::pack_b16_t_b(q,dB,dQ1,32,rows,hd);
    pack_b16_t_b_v(q,dB,dQ2,32,rows,hd);
    q.wait();
    { std::vector<sycl::half> h1(nA),h2(nA);
      q.memcpy(h1.data(),dQ1,nA*2).wait(); q.memcpy(h2.data(),dQ2,nA*2).wait();
      size_t d=0; for(size_t i=0;i<nA;++i) if(memcmp(&h1[i],&h2[i],2)) d++;
      double bs=tm([&]{ packdev::pack_b16_t_b(q,dB,dQ1,32,rows,hd); },21);
      double bv=tm([&]{ pack_b16_t_b_v(q,dB,dQ2,32,rows,hd); },21);
      printf("pack_b16_t_b  rows=%-5d hd=%d  scalar=%8.4f vec=%8.4f (%.2fx) diff %zu/%zu\n", rows,hd,bs,bv,bs/bv,d,nA); }
    // 3. pack_b16_b (V): K=rows,N=32
    packdev::pack_b16_b(q,dV,dQ1,rows,32,hd);
    pack_b16_b_v(q,dV,dQ2,rows,32,hd);
    q.wait();
    { std::vector<sycl::half> h1(nA),h2(nA);
      q.memcpy(h1.data(),dQ1,nA*2).wait(); q.memcpy(h2.data(),dQ2,nA*2).wait();
      size_t d=0; for(size_t i=0;i<nA;++i) if(memcmp(&h1[i],&h2[i],2)) d++;
      if (d) { size_t shown=0;
        for(size_t i=0;i<nA && shown<6;++i) if(memcmp(&h1[i],&h2[i],2)) {
          printf("   dbg i=%zu (gg=%zu blk=%zu band=%zu x=%zu) want %.3f got %.3f\n", i,
                 i/(size_t)rows*32, (i%((size_t)rows*32))/128, (i%128)/16*16, i%16,
                 (float)h1[i], (float)h2[i]); ++shown; } }
      double bs=tm([&]{ packdev::pack_b16_b(q,dV,dQ1,rows,32,hd); },21);
      double bv=tm([&]{ pack_b16_b_v(q,dV,dQ2,rows,32,hd); },21);
      printf("pack_b16_b    rows=%-5d hd=%d  scalar=%8.4f vec=%8.4f (%.2fx) diff %zu/%zu\n", rows,hd,bs,bv,bs/bv,d,nA); }
    free(dA,q);free(dB,q);free(dV,q);free(dP1,q);free(dP2,q);free(dQ1,q);free(dQ2,q);
  }
  return 0;
}
