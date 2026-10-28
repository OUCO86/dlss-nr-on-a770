// bench_packa16_v.cpp -- P8-d: pack_a16 (f16 family's A leg) scalar vs vec32B.
// Frame shapes from the f16 census (M,K): (32640,32)x2 (8160,64)x2 (2040,128)x2
// (640,256)x2 (192,512)x2 (192,1024) + the ffn chain's K=128/32 legs.
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
  struct Cfg{int M,K;};
  std::vector<Cfg> cfgs={{32640,32},{8160,64},{2040,128},{640,256},{192,512},{32640,128},{130560,32}};
  for(auto cf:cfgs){
    int M=cf.M,K=cf.K; int Mp=((M+127)/128)*128;
    std::vector<sycl::half> A((size_t)M*K);
    std::mt19937 rng(5);
    for(auto&x:A)x=sycl::half((float)((int)(rng()%2000)-1000)/64.f);
    sycl::half*dA=(sycl::half*)malloc_device(A.size()*2,q);
    sycl::half*dP=(sycl::half*)malloc_device((size_t)Mp*K*2,q),*dQ=(sycl::half*)malloc_device((size_t)Mp*K*2,q);
    q.memcpy(dA,A.data(),A.size()*2).wait();
    q.memset(dP,0x3F,(size_t)Mp*K*2); q.memset(dQ,0x3F,(size_t)Mp*K*2); q.wait();
    packdev::pack_a16(q,dA,dP,M,Mp,K);          // scalar form: below the 500K threshold for these? NO -- force by direct calls:
    packdev::pack_a16_v(q,dA,dQ,M,Mp,K);
    q.wait();
    std::vector<sycl::half> h1((size_t)Mp*K),h2((size_t)Mp*K);
    q.memcpy(h1.data(),dP,h1.size()*2).wait(); q.memcpy(h2.data(),dQ,h2.size()*2).wait();
    size_t diff=0; for(size_t i=0;i<h1.size();++i) if(memcmp(&h1[i],&h2[i],2)) diff++;
    double bs=tm([&]{ packdev::pack_a16(q,dA,dP,M,Mp,K); },21);
    double bv=tm([&]{ packdev::pack_a16_v(q,dA,dQ,M,Mp,K); },21);
    printf("M=%-7d K=%-5d  scalar=%8.4f vec32B=%8.4f ms  diff=%zu / %zu\n",
           M,K,bs,bv,diff,h1.size());
    free(dA,q);free(dP,q);free(dQ,q);
  }
  // the f16 gemm family's HOT leg: gather_pack_a16_b (the frame's 84 calls:
  // lda=K, sa=0, oa=0, batch=nb). vec-vs-scalar on the same map.
  printf("--- gather_pack_a16_b (lda=K,sa=0,oa=0) ---\n");
  struct GCfg{int M,N,K,nb;};
  std::vector<GCfg> gcfgs={{32640,32,64,1},{8160,128,64,1},{2040,256,128,1},{640,512,256,1},{192,1024,512,1},{640,64,256,8}};
  for(auto cf:gcfgs){
    int M=cf.M,K=cf.K,nb=cf.nb; int Mp=((M+127)/128)*128;
    std::vector<sycl::half> A((size_t)nb*M*K);
    std::mt19937 rng(7);
    for(auto&x:A)x=sycl::half((float)((int)(rng()%2000)-1000)/64.f);
    sycl::half*dA=(sycl::half*)malloc_device(A.size()*2,q);
    size_t np=(size_t)nb*Mp*K*2;
    sycl::half*dP=(sycl::half*)malloc_device(np,q),*dQ=(sycl::half*)malloc_device(np,q);
    q.memcpy(dA,A.data(),A.size()*2).wait();
    q.memset(dP,0x3F,np); q.memset(dQ,0x3F,np); q.wait();
    // the vec path fires when lda%16==0 (lda_e here = K): call the fn once (env ON
    // default) -> vec; the scalar comparison uses the pack_a16-style direct maps:
    // temporarily flip the static via setenv BEFORE first call is impossible inside
    // one process -- so compare vec-vs-vec-of-pack_a16 scalar form (same map when
    // sa=0 lda=K oa=0 batch=nb -- the shapes match the scalar batch pack): use the
    // EXISTING gather scalar through NR_GPACK_VEC=0 by re-exec? Simpler: the vec
    // form must equal pack_a16's batched map; verify against a HOST-computed tile.
    packdev::gather_pack_a16_b(q,dA,dQ,M,Mp,K,K,0,0,nb);   // vec path (env default ON)
    q.wait();
    std::vector<sycl::half> h2((size_t)nb*Mp*K);
    q.memcpy(h2.data(),dQ,h2.size()*2).wait();
    // host reference: dest = ((tr*kb_n+kc)*2+strip)*128 + il*16 + k per group
    size_t diff=0; size_t per=(size_t)(Mp/16)*(K/16)*2*128;
    for(int gg=0;gg<nb;++gg)
      for(int tr=0;tr<Mp/16;++tr) for(int kc=0;kc<K/16;++kc)
        for(int strip=0;strip<2;++strip) for(int il=0;il<8;++il) for(int k=0;k<16;++k){
          int srow=tr*16+strip*8+il;
          size_t dst=((size_t)gg*per + ((size_t)tr*(K/16)+kc)*2*128 + strip*128 + il*16)*1 + k;
          sycl::half want = srow<M ? A[(size_t)gg*M*K + (size_t)srow*K + kc*16 + k] : sycl::half(0.f);
          if (memcmp(&h2[dst],&want,2)) diff++;
        }
    double bv2=tm([&]{ packdev::gather_pack_a16_b(q,dA,dQ,M,Mp,K,K,0,0,nb); },21);
    // the old scalar form is unreachable now (env ON); time the pack_a16 scalar
    // single-group as the reference cost proxy (same element count, no batch dim):
    double bs2=tm([&]{ for(int gg=0;gg<nb;++gg) packdev::pack_a16(q,dA+(size_t)gg*M*K,dP+(size_t)gg*Mp*K,M,Mp,K); },21);
    printf("M=%-7d K=%-5d nb=%d  scalar(batch loop)=%8.4f gather_vec=%8.4f ms  diff=%zu / %zu\n",
           M,K,nb,bs2,bv2,diff,h2.size());
    free(dA,q);free(dP,q);free(dQ,q);
  }
  return 0;
}
