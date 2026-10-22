// bench_sctest.cpp -- section 93: reproduce the scores gemm IN ISOLATION + probe the SIMD
// width. Q(8x32), K(64x32) scalar-written to SLM, joint_matrix Q(row_major A) . K^T
// (col_major B), 8 accumulators, vs host. Also report sg.get_local_range() so we can compare
// the SIMD width this small kernel gets vs the big resident kernel (probe said resident=8).
// Hypothesis: joint_matrix scores works at SIMD32 (this small kernel) but breaks at SIMD8
// (the resident kernel), and SIMD32 cannot be forced (reqd_sub_group_size(32)+joint_matrix
// = IGC divide-by-zero). If confirmed, the resident fusion needs a SIMD8-safe gemm strategy.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include <cmath>
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int M=8,K=32,N=64;
  std::vector<half> hQ((size_t)M*K),hK((size_t)N*K);
  std::mt19937 rng(7); std::uniform_real_distribution<float> dd(-2.f,2.f);
  for(auto&x:hQ)x=half(dd(rng)); for(auto&x:hK)x=half(dd(rng));
  half* GQ=(half*)malloc_device(hQ.size()*2,q); half* GK=(half*)malloc_device(hK.size()*2,q);
  float* Out=(float*)malloc_device((size_t)M*N*4,q); float* PR=(float*)malloc_device(4,q);
  q.memcpy(GQ,hQ.data(),hQ.size()*2).wait(); q.memcpy(GK,hK.data(),hK.size()*2).wait();
  std::vector<float> hRef((size_t)M*N,0.f);
  for(int m=0;m<M;++m)for(int n=0;n<N;++n){float a=0;for(int k=0;k<K;++k)a+=(float)hQ[(size_t)m*K+k]*(float)hK[(size_t)n*K+k];hRef[(size_t)m*N+n]=a;}
  q.submit([&](handler& h){
    local_accessor<float,1> SLM(range(2048u), h);
    h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group(); uint lid=(uint)it.get_local_id(0);
      float* f32p=SLM.get_pointer(); half* h16=(half*)f32p;
      for(uint i=lid;i<256u;i+=256u) h16[i]=GQ[i];
      for(uint i=lid;i<(uint)(N*K);i+=256u) h16[256u+i]=GK[i];
      group_barrier(it.get_group());
      jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> qa[2];
      jm::joint_matrix_load(sg,qa[0],multi_ptr<half,access::address_space::local_space>(h16),(size_t)K);
      jm::joint_matrix_load(sg,qa[1],multi_ptr<half,access::address_space::local_space>(h16+16),(size_t)K);
      jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> acc[8];
      for(uint j=0;j<8;++j) jm::joint_matrix_fill(sg,acc[j],0.f);
      for(uint c=0;c<K;c+=16)
        for(uint j=0;j<8;++j){
          jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::col_major> key;
          jm::joint_matrix_load(sg,key,multi_ptr<half,access::address_space::local_space>(h16+256u+j*8u*K+c),(size_t)K);
          jm::joint_matrix_mad(sg,acc[j],qa[c/16],key,acc[j]);
        }
      for(uint j=0;j<8;++j)
        jm::joint_matrix_store(sg,acc[j],multi_ptr<float,access::address_space::global_space>(Out+j*8),(size_t)N,jm::layout::row_major);
      if(lid==0u){PR[0]=(float)sg.get_local_range().size(); PR[1]=(float)it.get_sub_group().get_group_range().size();}
    }); });
  q.wait();
  std::vector<float> hc((size_t)M*N); q.memcpy(hc.data(),Out,hc.size()*4).wait();
  std::vector<float> hp(4); q.memcpy(hp.data(),PR,16).wait();
  int bad=0,nan=0; for(size_t i=0;i<hc.size();++i){ if(std::isnan(hc[i]))nan++; if(std::abs(hc[i]-hRef[i])>0.3f) bad++; }
  printf("[probe] sg_size=%.0f nsub=%.0f\n",hp[0],hp[1]);
  printf("scores-isolated: %d/%d wrong, %d NaN -> %s\n",bad,(int)hc.size(),nan,bad?"BROKEN":"OK");
  return 0;
}
