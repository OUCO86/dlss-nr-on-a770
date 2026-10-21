// bench_res.cpp -- section 93: ISOLATE gemm_res vs the split gemm+publish on the REAL
// ffn_stem pass-C shape (M=130560 N=32 K=128). The dpas loop is byte-identical to the
// proven f16v1::gemm, so the acc must match; the only difference is the store's
// skip/cos/publish. This localizes the 7 mismatches to a specific (row,col) so I can
// read the actual operands and see WHICH term is wrong.
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include <cmath>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
#include "publish_kernel.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int M=130560, N=32, K=128, Mp=M;
  std::vector<half> hA((size_t)M*K), hB((size_t)K*N);
  std::vector<float> hSk((size_t)M*N), hCp(N);
  std::mt19937 rng(3);
  std::uniform_real_distribution<float> da(-2.f,2.f), db(-0.5f,0.5f), dsk(-3.f,3.f), dcp(-2.f,2.f);
  for(auto&x:hA)x=half(da(rng)); for(auto&x:hB)x=half(db(rng));
  for(auto&x:hSk)x=dsk(rng); for(auto&x:hCp)x=dcp(rng);
  half* dA=(half*)malloc_device(hA.size()*2,q); half* dB=(half*)malloc_device(hB.size()*2,q);
  float* dSk=(float*)malloc_device(hSk.size()*4,q); float* dCp=(float*)malloc_device(N*4,q);
  q.memcpy(dA,hA.data(),hA.size()*2).wait(); q.memcpy(dB,hB.data(),hB.size()*2).wait();
  q.memcpy(dSk,hSk.data(),hSk.size()*4).wait(); q.memcpy(dCp,hCp.data(),N*4).wait();
  half* dAp=(half*)malloc_device((size_t)Mp*K*2,q); half* dBp=(half*)malloc_device((size_t)K*N*2,q);
  packdev::pack_a16(q,dA,dAp,M,Mp,K); packdev::pack_b16(q,dB,dBp,K,N);
  const unsigned epi=1u;
  // split reference
  float* dC2=(float*)malloc_device((size_t)Mp*N*4,q);
  f16v1::gemm(q,dAp,dBp,dC2,Mp,N,K);
  half* outS=(half*)malloc_device((size_t)M*N*2,q);
  q.parallel_for(range((size_t)M*N),[=](item<1> it){
    size_t i=it.get_id(0); unsigned col=(unsigned)(i%N);
    float total=sycl::fma(dSk[i],dCp[col],dC2[i]);
    outS[i]=half(qr_publish(epi,total));
  }).wait();
  // fused
  half* outF=(half*)malloc_device((size_t)M*N*2,q);
  f16v1::gemm_res(q,dAp,dBp,outF,dSk,dCp,M,Mp,N,K,true,epi).wait();
  std::vector<half> a((size_t)M*N), b((size_t)M*N);
  std::vector<float> acc((size_t)Mp*N);
  q.memcpy(a.data(),outS,a.size()*2).wait(); q.memcpy(b.data(),outF,b.size()*2).wait();
  q.memcpy(acc.data(),dC2,acc.size()*4).wait();
  size_t bad=0; std::vector<size_t> first;
  for(size_t i=0;i<a.size();++i) if(a[i]!=b[i]){ if(bad<12) first.push_back(i); bad++; }
  printf("gemm_res vs split: %zu/%zu mismatch\n", a.size()-bad, a.size());
  // sanity: does the SPLIT path itself match a host gemm? (isolates pack correctness)
  {
    size_t hbad=0;
    for(size_t i=0;i<a.size();++i){
      unsigned r=(unsigned)(i/N), col=(unsigned)(i%N);
      double acc=0; for(int k=0;k<K;++k) acc+=(double)(float)hA[(size_t)r*K+k]*(double)(float)hB[(size_t)k*N+col];
      float want=qr_publish(epi, std::fma((double)hSk[i],(double)hCp[col],acc));
      if(std::abs((float)a[i]-want)>1e-3f) hbad++;
    }
    printf("split vs host-gemm: %zu/%zu mismatch (pack sanity)\n", a.size()-hbad, a.size());
  }
  for(size_t i: first){
    unsigned r=(unsigned)(i/N), col=(unsigned)(i%N);
    float want=qr_publish(epi, std::fma(hSk[i],hCp[col],acc[i]));
    printf("  row %u col %u: split %.6f fused %.6f | skip %.4f cos %.4f acc %.4f hostfma_pub %.6f\n",
      r,col,(float)a[i],(float)b[i],hSk[i],hCp[col],acc[i],want);
  }
  return 0;
}
