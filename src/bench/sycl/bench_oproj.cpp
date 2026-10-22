// bench_oproj.cpp -- section 93: isolate stage 9 outproj EXACTLY. attended(8x32 row-major
// A, from SLM) . Wproj(32x32 row-major B, from SLM) = projected(8x32), K=32 in two 16-steps,
// N=32 in four 8-steps, acc[4]. This is byte-for-byte the resident stage-9 gemm. If it works
// in isolation, the resident break is register pressure (stage 9 is late); if it fails, my
// indexing is wrong.
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
  const int M=8,K=32,N=32;
  std::vector<half> hA((size_t)M*K),hW((size_t)K*N);
  std::mt19937 rng(7); std::uniform_real_distribution<float> dd(-2.f,2.f);
  for(auto&x:hA)x=half(dd(rng)); for(auto&x:hW)x=half(dd(rng)*0.3f);
  half* GA=(half*)malloc_device(hA.size()*2,q); half* GW=(half*)malloc_device(hW.size()*2,q);
  float* Out=(float*)malloc_device((size_t)M*N*4,q); float* PR=(float*)malloc_device(4,q);
  q.memcpy(GA,hA.data(),hA.size()*2).wait(); q.memcpy(GW,hW.data(),hW.size()*2).wait();
  std::vector<float> hRef((size_t)M*N,0.f);
  for(int m=0;m<M;++m)for(int n=0;n<N;++n){float a=0;for(int k=0;k<K;++k)a+=(float)hA[(size_t)m*K+k]*(float)hW[(size_t)k*N+n];hRef[(size_t)m*N+n]=a;}
  q.submit([&](handler& h){
    local_accessor<float,1> SLM(range(8192u), h);
    h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group(); uint lid=(uint)it.get_local_id(0);
      float* f32p=SLM.get_pointer(); half* h16=(half*)f32p;
      const uint ATT=14336u, PROJ=3072u;
      for(uint i=lid;i<M*K;i+=256u) h16[ATT+i]=GA[i];
      for(uint i=lid;i<K*N;i+=256u) h16[PROJ+i]=GW[i];
      group_barrier(it.get_group());
      jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> attended[2];
      for(uint kk=0;kk<2;++kk)
        jm::joint_matrix_load(sg,attended[kk],multi_ptr<half,access::address_space::local_space>(h16+ATT+kk*16u),(size_t)K);
      jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> projected[4];
      for(uint j=0;j<4;++j) jm::joint_matrix_fill(sg,projected[j],0.f);
      for(uint kk=0;kk<2;++kk)
        for(uint j=0;j<4;++j){
          jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> w;
          jm::joint_matrix_load(sg,w,multi_ptr<half,access::address_space::local_space>(h16+PROJ+kk*16u*32u+j*8u),(size_t)N);
          jm::joint_matrix_mad(sg,projected[j],attended[kk],w,projected[j]);
        }
      for(uint j=0;j<4;++j)
        jm::joint_matrix_store(sg,projected[j],multi_ptr<float,access::address_space::global_space>(Out+j*8),(size_t)N,jm::layout::row_major);
      if(lid==0u){PR[0]=(float)sg.get_local_range().size();}
    }); });
  q.wait();
  std::vector<float> hc((size_t)M*N); q.memcpy(hc.data(),Out,hc.size()*4).wait();
  std::vector<float> hp(4); q.memcpy(hp.data(),PR,16).wait();
  int bad=0; for(size_t i=0;i<hc.size();++i) if(std::abs(hc[i]-hRef[i])>0.3f) bad++;
  printf("[probe] sg_size=%.0f\n",hp[0]);
  printf("outproj-isolated: %d/%d wrong -> %s\n",bad,(int)hc.size(),bad?"BROKEN (indexing)":"OK (=> register pressure in resident)");
  for(int i=0;i<4;++i) printf("  [%d] got %.4f want %.4f\n",i,hc[i],hRef[i]);
  return 0;
}
