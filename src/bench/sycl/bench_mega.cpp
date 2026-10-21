// bench_mega.cpp -- section 92 STAGED BISECT of the mega256 DEVICE_LOST crash. The full
// resident megakernel (the only path to 45ms) crashes; I wrote it, so I bisect it by
// stage, each stage in its OWN PROCESS (DEVICE_LOST poisons the L0 context). argv[1]=stage:
//   1 gather only (store gathered row to dQ)
//   2 + afrg build (store afrg to dQ)
//   3 + dpas projection (store acc to dQ)
//   4 + normalize (full leg1 logic at 256 threads)
// leg1 (32 threads, 1 subgroup) is proven bit-exact; mega256 differs only in 8 subgroups
// cooperating in one workgroup. This localizes whether the crash is gather, afrg, dpas,
// or the multi-subgroup barrier/SLM interaction.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static inline float eh_round(float x){ return (float)(half)x; }
static inline float eh_mul(float a,float b){ return (float)(half)(a*b); }
static inline float eh_add(float a,float b){ return (float)(half)(a+b); }
static inline float eh_hfma(float l,float r,float acc){ return (float)(half)(l*r+acc); }
static inline float esqrt(float x){ esimd::simd<float,1> v(x); return esimd::sqrt(v)[0]; }

int main(int argc,char**argv){
  int stage = argc>1 ? atoi(argv[1]) : 4;
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property_list{property::queue::in_order{}, property::queue::enable_profiling{}});
  const unsigned C=32,NH=96,windows=2100,tokens=64,image_h=272,image_w=480,across=60;
  const unsigned rows=windows*tokens;
  half* Img=(half*)malloc_device((size_t)image_h*image_w*C*2,q);
  half* Wq=(half*)malloc_device((size_t)C*NH*2,q);
  half* dQ=(half*)malloc_device((size_t)rows*C*2,q);
  half* dK=(half*)malloc_device((size_t)rows*C*2,q);
  half* dV=(half*)malloc_device((size_t)rows*C*2,q);
  float* qs=(float*)malloc_device(4,q);
  std::vector<half> hi((size_t)image_h*image_w*C, half(0.5f)); q.memcpy(Img,hi.data(),hi.size()*2).wait();
  std::vector<half> hw((size_t)C*NH, half(0.1f)); q.memcpy(Wq,hw.data(),hw.size()*2).wait();
  float one=1.f; q.memcpy(qs,&one,4).wait();
  printf("stage=%d launching...\n",stage); fflush(stdout);
  try {
  if(stage==5){ // N-thread (argv[2]) ESIMD, no SLM/barrier: pin the workgroup-size limit
    unsigned NT = argc>2 ? (unsigned)atoi(argv[2]) : 64u;
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(windows*NT),range(NT)),
        [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint wg=(uint)it.get_group(0), lid=(uint)it.get_local_id(0);
        int y=(int)((wg/across)*8u); int x0=(int)((wg%across)*8u);
        uint row0=wg*64u;
        if(lid<8u){ int x=x0+(int)lid;
          if(y>=0&&y<(int)image_h&&x>=0&&x<(int)image_w){ size_t at=((size_t)y*image_w+(size_t)x)*32u;
            esimd::simd<half,32> v; for(int e=0;e<32;++e) v[e]=half(qr_e4m3_scalar((float)((const half*)Img)[at+e]));
            v.copy_to(dQ+(size_t)(row0+lid)*32u); } }
      }); });
    q.wait(); printf("stage=5 (%uthr) OK\n",NT); fflush(stdout); return 0; }
  if(stage==0){ // 256-thread ESIMD, NO slm_init, NO barrier, NO SLM: pure gather->global
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(windows*256u),range(256u)),
        [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint wg=(uint)it.get_group(0), lid=(uint)it.get_local_id(0);
        uint sub=lid/32u, local=lid%32u;
        int y=(int)((wg/across)*8u+sub); int x0=(int)((wg%across)*8u);
        uint row0=wg*64u+sub*8u;
        if(local<8u){ int x=x0+(int)local;
          if(y>=0&&y<(int)image_h&&x>=0&&x<(int)image_w){ size_t at=((size_t)y*image_w+(size_t)x)*32u;
            esimd::simd<half,32> v; for(int e=0;e<32;++e) v[e]=half(qr_e4m3_scalar((float)((const half*)Img)[at+e]));
            v.copy_to(dQ+(size_t)(row0+local)*32u); } }
      }); });
    q.wait(); printf("stage=0 OK\n"); fflush(stdout); return 0; }
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(windows*256u),range(256u)),
      [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      esimd::slm_init<2560u>();
      uint wg=(uint)it.get_group(0), lid=(uint)it.get_local_id(0);
      uint sub=lid/32u, local=lid%32u;
      uint ROW=0u, AFRG=512u, VAL=1024u;
      int y=(int)((wg/across)*8u+sub); int x0=(int)((wg%across)*8u);
      bool row_in=y>=0&&y<(int)image_h;
      uint row0=wg*64u+sub*8u;
      // stage 1: gather
      if(local<8u){
        esimd::simd<half,32> v; int x=x0+(int)local;
        if(row_in&&x>=0&&x<(int)image_w){ size_t at=((size_t)y*image_w+(size_t)x)*32u;
          for(int e=0;e<32;++e) v[e]=half(qr_e4m3_scalar((float)((const half*)Img)[at+e])); }
        else { for(int e=0;e<32;++e) v[e]=half(0.f); }
        esimd::slm_block_store(ROW+local*64u,v,esimd::overaligned_tag<16>{});
      }
      esimd::barrier();
      if(stage==1){ if(local<8u){ esimd::simd<half,32> v=esimd::slm_block_load<half,32>(ROW+local*64u,esimd::overaligned_tag<16>{}); v.copy_to(dQ+(size_t)(row0+local)*32u);} return; }
      // stage 2: afrg
      if(local<4u){ uint kc=local/2u,rg=local%2u; esimd::simd<half,64> a;
        for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(ROW+(rg*4u+j)*64u,esimd::overaligned_tag<16>{});
          esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
        esimd::slm_block_store(AFRG+kc*256u+rg*128u,a,esimd::overaligned_tag<16>{}); }
      esimd::barrier();
      if(stage==2){ if(local<8u){ esimd::simd<half,32> v=esimd::slm_block_load<half,32>(AFRG+local*64u,esimd::overaligned_tag<16>{}); v.copy_to(dQ+(size_t)(row0+local)*32u);} return; }
      // stage 3+: dpas (part 0 only for stage 3)
      int nparts = (stage==3)?1:3;
      for(int part=0;part<nparts;++part){
        esimd::simd<float,64> acc0(0.f),acc1(0.f),acc2(0.f),acc3(0.f);
        for(int kc=0;kc<2;++kc){
          esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
          for(int tl=0;tl<2;++tl){ int tc=part*2+tl;
            esimd::simd<half,128> b0(Wq+(((size_t)kc*6u+tc)*2u+0u)*128u,esimd::overaligned_tag<16>{});
            esimd::simd<half,128> b1(Wq+(((size_t)kc*6u+tc)*2u+1u)*128u,esimd::overaligned_tag<16>{});
            if(tl==0){acc0=esimd::xmx::dpas<8,8,float>(acc0,b0,a0);acc1=esimd::xmx::dpas<8,8,float>(acc1,b1,a0);}
            else{acc2=esimd::xmx::dpas<8,8,float>(acc2,b0,a0);acc3=esimd::xmx::dpas<8,8,float>(acc3,b1,a0);} } }
        for(int r=0;r<8;++r){ esimd::simd<float,16> q0,q1;
          q0.template select<8,1>(0)=acc0.template select<8,1>(r*8); q0.template select<8,1>(8)=acc1.template select<8,1>(r*8);
          q1.template select<8,1>(0)=acc2.template select<8,1>(r*8); q1.template select<8,1>(8)=acc3.template select<8,1>(r*8);
          esimd::slm_block_store(VAL+r*128u,q0,esimd::overaligned_tag<16>{});
          esimd::slm_block_store(VAL+r*128u+64u,q1,esimd::overaligned_tag<16>{}); }
        esimd::barrier();
        if(stage==3){ // store raw acc to dQ, done
          uint r=local/4u,l=local%4u;
          esimd::simd<float,32> rv=esimd::slm_block_load<float,32>(VAL+r*128u,esimd::overaligned_tag<16>{});
          esimd::simd<half,32> o; for(int i=0;i<32;++i) o[i]=half(rv[i]);
          o.copy_to(dQ+(size_t)(row0+r)*32u); esimd::barrier(); continue; }
        // stage 4: normalize
        uint r=local/4u,l=local%4u;
        esimd::simd<float,32> rv=esimd::slm_block_load<float,32>(VAL+r*128u,esimd::overaligned_tag<16>{});
        float h[32]; for(int i=0;i<32;++i) h[i]=rv[i];
        if(part<2){
          for(int i=0;i<32;++i) h[i]=eh_round(h[i]);
          float partial[4][2];
          for(int lane=0;lane<4;++lane) for(int p=0;p<2;++p){ int ch=lane*2+p;
            float first=eh_hfma(h[ch+8],h[ch+8],eh_mul(h[ch],h[ch]));
            float second=eh_hfma(h[ch+24],h[ch+24],eh_mul(h[ch+16],h[ch+16]));
            partial[lane][p]=eh_add(first,second); }
          float two[4][2],one[4][2];
          for(int lane=0;lane<4;++lane) for(int p=0;p<2;p++) two[lane][p]=eh_add(partial[lane][p],partial[lane^2][p]);
          for(int lane=0;lane<4;++lane) for(int p=0;p<2;p++) one[lane][p]=eh_add(two[lane][p],two[lane^1][p]);
          float norm=eh_add(one[0][0],one[0][1]); float floorv=eh_round(ctree::COSINE_NORM_FLOOR);
          norm=norm>floorv?norm:floorv; float recip=eh_round(1.0f/esqrt(norm));
          float sc=part==0?eh_round(qs[0]):1.0f;
          half* dst=part==0?dQ:dK;
          for(int i=0;i<32;++i){ float v=eh_mul(h[i],recip); if(part==0) v=eh_mul(v,sc);
            uint ch=(uint)(i/2)*8u+2u*l+(uint)(i%2); dst[(size_t)(row0+r)*32u+ch]=half(qr_e4m3_scalar(v)); }
        } else {
          for(int i=0;i<32;++i){ uint ch=(uint)(i/2)*8u+2u*l+(uint)(i%2);
            dV[(size_t)(row0+r)*32u+ch]=half(qr_e4m3_scalar(h[i])); }
        }
        esimd::barrier();
      }
    });
  }).wait();
  printf("stage=%d OK\n",stage); fflush(stdout);
  return 0;
  } catch(const sycl::exception&e){ printf("stage=%d THREW: %s\n",stage,e.what()); return 2; }
}
