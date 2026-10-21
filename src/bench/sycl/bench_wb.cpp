// bench_wb.cpp -- section 92: the CLEAN measurement I kept failing to get inside the
// engine. window_block is 361ms/20 calls = 18ms/call, but per-stage wait timing in the
// in-order queue is self-contradictory (a stage summed larger than the whole run). Here:
// GPU-event timing of the three window_block kernels at the real shape, no host pollution.
// Real shape (960x544 field): windows=510, tokens=64, rows=32640, C=32, NH=96, Mp=32768.
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "softmax_kernel.hpp"
using namespace sycl;
static const int C=32, NH=96, windows=2100, tokens=64, height=272, width=480, across=60, rows=windows*tokens;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property_list{property::queue::in_order{}, property::queue::enable_profiling{}});
  const int Mp=((rows+15)/16)*16;
  half* Img=(half*)malloc_device((size_t)height*width*C*2,q);
  half* dA=(half*)malloc_device((size_t)rows*C*2,q);
  half* dAp=(half*)malloc_device((size_t)Mp*C*2,q);
  half* dBp=(half*)malloc_device((size_t)C*NH*2,q);
  float* dCq=(float*)malloc_device((size_t)Mp*NH*4,q);
  half* dQ=(half*)malloc_device((size_t)rows*C*2,q);
  half* dK=(half*)malloc_device((size_t)rows*C*2,q);
  half* dV=(half*)malloc_device((size_t)rows*C*2,q);
  float* qs=(float*)malloc_device(4,q);
  float* bias=(float*)malloc_device((size_t)64*64*4,q);
  half* Praw=(half*)malloc_device((size_t)C*C*2,q);
  float* cp=(float*)malloc_device((size_t)C*4,q);
  float* dScores=(float*)malloc_device((size_t)windows*64*64*4,q);
  half* dProbs=(half*)malloc_device((size_t)windows*64*64*2,q);
  half* dAq=(half*)malloc_device((size_t)windows*64*32*2,q);
  half* dBk=(half*)malloc_device((size_t)windows*32*64*2,q);
  half* dAp2=(half*)malloc_device((size_t)windows*64*64*2,q);
  half* dBv=(half*)malloc_device((size_t)windows*64*32*2,q);
  float* dCtx=(float*)malloc_device((size_t)windows*64*32*4,q);
  half* dAtt=(half*)malloc_device((size_t)rows*C*2,q);
  half* dAp3=(half*)malloc_device((size_t)Mp*C*2,q);
  half* dBp3=(half*)malloc_device((size_t)C*C*2,q);
  float* dC3=(float*)malloc_device((size_t)Mp*C*4,q);
  float* Tgt=(float*)malloc_device((size_t)height*width*C*4,q);
  std::vector<half> hi((size_t)height*width*C, half(0.5f)); q.memcpy(Img,hi.data(),hi.size()*2).wait();
  std::vector<half> hw((size_t)C*NH, half(0.1f)); q.memcpy(dBp,hw.data(),hw.size()*2).wait();
  float one=1.f; q.memcpy(qs,&one,4).wait();
  auto now=[](){ return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now().time_since_epoch()).count(); };
  auto ev=[&](const char* nm, std::function<event()> f){
    f().wait(); double t0=now(); event e=f(); e.wait(); double t1=now();
    printf("%-22s GPU %8.3f ms   (wall %8.3f)\n", nm,
           (double)(e.get_profiling_info<info::event_profiling::command_end>()-
                    e.get_profiling_info<info::event_profiling::command_start>())/1e6, t1-t0);
  };
  // warm
  for(int i=0;i<3;i++){
    q.parallel_for(range((size_t)rows*C),[=](item<1> it){ size_t i=it.get_id(0); unsigned r=i/C,c=i%C;
      unsigned w=r/tokens,t=r%tokens; int y=(int)((w/across)*8u+t/8u); int x=(int)((w%across)*8u+t%8u);
      if(y<0||x<0||y>=height||x>=width){dA[i]=half(0.f);return;} size_t at=((size_t)y*width+x)*C;
      dA[i]=half(qr_e4m3((float)Img[at+c])); });
    packdev::pack_a16(q,dA,dAp,rows,Mp,C);
    f16v1::gemm(q,dAp,dBp,dCq,Mp,NH,C);
    q.parallel_for(range((size_t)rows),[=](item<1> it){ unsigned r=it.get_id(0); float row32[32];
      for(int c2=0;c2<32;++c2) row32[c2]=qr_half_round(dCq[(size_t)r*NH+c2]);
      float recip=ctree::cosine_reciprocal(row32); float sc=qr_half_round(qs[0]);
      for(int c2=0;c2<32;++c2){ float v=qr_half_round(cr_mul(row32[c2],recip)); v=qr_half_round(cr_mul(v,sc));
        dQ[(size_t)r*32u+c2]=half(qr_e4m3(v)); }
      for(int c2=0;c2<32;++c2) row32[c2]=qr_half_round(dCq[(size_t)r*NH+C+c2]);
      float krec=ctree::cosine_reciprocal(row32);
      for(int c2=0;c2<32;++c2) dK[(size_t)r*32u+c2]=half(qr_e4m3(qr_half_round(cr_mul(row32[c2],krec))));
      for(int c2=0;c2<32;++c2) dV[(size_t)r*32u+c2]=half(qr_e4m3(dCq[(size_t)r*NH+2u*C+c2])); });
    q.wait();
  }
  ev("gather(flattened)",[&]{ return q.parallel_for(range((size_t)rows*C),[=](item<1> it){ size_t i=it.get_id(0);
      unsigned r=i/C,c=i%C; unsigned w=r/tokens,t=r%tokens; int y=(int)((w/across)*8u+t/8u); int x=(int)((w%across)*8u+t%8u);
      if(y<0||x<0||y>=height||x>=width){dA[i]=half(0.f);return;} size_t at=((size_t)y*width+x)*C;
      dA[i]=half(qr_e4m3((float)Img[at+c])); }); });
  ev("pack_a16",[&]{ return q.submit([&](handler& h){ h.parallel_for(range((size_t)(Mp/16)*(C/16)*2*128),[=](item<1> it){ size_t d=it.get_id(0); int k=(int)(d%16); size_t rest=d/16; int il=(int)(rest%8); rest/=8; int strip=(int)(rest%2); size_t blk=rest/2; int kc=(int)(blk%(size_t)(C/16)); int tr=(int)(blk/(size_t)(C/16)); int srow=tr*16+strip*8+il; dAp[d]= srow<rows? dA[(size_t)srow*C+kc*16+k] : half(0.f); }); }); });
  ev("gemm f16 32640x96x32",[&]{ return f16v1::gemm(q,dAp,dBp,dCq,Mp,NH,C); });
  ev("epilogue(scalar row)",[&]{ return q.parallel_for(range((size_t)rows),[=](item<1> it){ unsigned r=it.get_id(0); float row32[32];
      for(int c2=0;c2<32;++c2) row32[c2]=qr_half_round(dCq[(size_t)r*NH+c2]);
      float recip=ctree::cosine_reciprocal(row32); float sc=qr_half_round(qs[0]);
      for(int c2=0;c2<32;++c2){ float v=qr_half_round(cr_mul(row32[c2],recip)); v=qr_half_round(cr_mul(v,sc));
        dQ[(size_t)r*32u+c2]=half(qr_e4m3(v)); }
      for(int c2=0;c2<32;++c2) row32[c2]=qr_half_round(dCq[(size_t)r*NH+C+c2]);
      float krec=ctree::cosine_reciprocal(row32);
      for(int c2=0;c2<32;++c2) dK[(size_t)r*32u+c2]=half(qr_e4m3(qr_half_round(cr_mul(row32[c2],krec))));
      for(int c2=0;c2<32;++c2) dV[(size_t)r*32u+c2]=half(qr_e4m3(dCq[(size_t)r*NH+2u*C+c2])); }); });
  ev("pack_a16_b Q(510)",[&]{ return q.submit([&](handler& h){ h.parallel_for(range((size_t)windows*(64/16)*(32/16)*2*128),[=](item<1> it){ size_t g=it.get_id(0)/((size_t)(64/16)*(32/16)*2*128), d=it.get_id(0)%((size_t)(64/16)*(32/16)*2*128); int k=(int)(d%16); size_t rest=d/16; int il=(int)(rest%8); rest/=8; int strip=(int)(rest%2); size_t blk=rest/2; int kc=(int)(blk%(size_t)(32/16)); int tr=(int)(blk/(size_t)(32/16)); int srow=tr*16+strip*8+il; dAq[g*((size_t)(64/16)*(32/16)*2*128)+d]= srow<64? dQ[g*64*32+srow*32+kc*16+k] : half(0.f); }); }); });
  ev("gemm_b scores 510x64x64x32",[&]{ return f16v1::gemm_b(q,dAq,dBk,dScores,64,64,32,windows); });
  ev("softmax 32640x64",[&]{ return q.parallel_for(range((size_t)windows*64), smax::softmax_kernel()(dScores,dProbs,windows*64,64,bias,1)); });
  ev("gemm_b attnV 510x64x32x64",[&]{ return f16v1::gemm_b(q,dAp2,dBv,dCtx,64,32,64,windows); });
  ev("pack_a16 attended",[&]{ return q.submit([&](handler& h){ h.parallel_for(range((size_t)(Mp/16)*(C/16)*2*128),[=](item<1> it){ size_t d=it.get_id(0); int k=(int)(d%16); size_t rest=d/16; int il=(int)(rest%8); rest/=8; int strip=(int)(rest%2); size_t blk=rest/2; int kc=(int)(blk%(size_t)(C/16)); int tr=(int)(blk/(size_t)(C/16)); int srow=tr*16+strip*8+il; dAp3[d]= srow<rows? dAtt[(size_t)srow*C+kc*16+k] : half(0.f); }); }); });
  ev("gemm f16 32640x32x32 (LEG3)",[&]{ return f16v1::gemm(q,dAp3,dBp3,dC3,Mp,C,C); });
  ev("residual store (LEG3)",[&]{ return q.parallel_for(range((size_t)rows*C),[=](item<1> it){ size_t i=it.get_id(0); unsigned r=i/C,col=i%C; unsigned w=r/64,t=r%64; unsigned y=(w/across)*8u+t/8u; unsigned x=(w%across)*8u+t%8u; if(y>=height||x>=width) return; size_t out=((size_t)y*width+x)*C+col; Tgt[out]=sycl::fma((float)Img[out],cp[col],dC3[i]); }); });
  return 0;
}
