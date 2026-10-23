// bench_wgs.cpp -- section 94: THE unlock test. 2026.1.1 matrix-intel.hpp has
// spv_scope_traits<sycl::group<D>> -> __spv::Scope::Workgroup, i.e. joint_matrix supports
// WORK-GROUP scope via Khronos CooperativeMatrixKHR -- the SAME primitive Vulkan coopmat
// (.comp) uses. If this compiles AND runs correct on the A770, the .comp's exact structure
// (workgroup-wide matrix, not SIMD8 sub_group) is reproducible in SYCL -> the 45ms path opens.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix-intel.hpp>
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
  const int M=16,N=16,K=16;
  std::vector<half> hA((size_t)M*K),hB((size_t)K*N);
  std::mt19937 rng(7); std::uniform_real_distribution<float> dd(-2.f,2.f);
  for(auto&x:hA)x=half(dd(rng)); for(auto&x:hB)x=half(dd(rng));
  half* A=(half*)malloc_device(hA.size()*2,q); half* B=(half*)malloc_device(hB.size()*2,q);
  float* Out=(float*)malloc_device((size_t)M*N*4,q); float* PR=(float*)malloc_device(4,q);
  q.memcpy(A,hA.data(),hA.size()*2).wait(); q.memcpy(B,hB.data(),hB.size()*2).wait();
  std::vector<float> hRef((size_t)M*N,0.f);
  for(int m=0;m<M;++m)for(int n=0;n<N;++n){float a=0;for(int k=0;k<K;++k)a+=(float)hA[(size_t)m*K+k]*(float)hB[(size_t)k*N+n];hRef[(size_t)m*N+n]=a;}
  printf("launching WORK-GROUP-scope joint_matrix (CooperativeMatrixKHR)...\n"); fflush(stdout);
  try {
    q.submit([&](handler& h){
      // one workgroup of 256 threads computes one 16x16x16 gemm with a workgroup-scope matrix
      h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it){
        auto wg = it.get_group();   // <-- work_group scope, NOT sub_group
        jm::joint_matrix<decltype(wg),half,jm::use::a,M,K,jm::layout::row_major> ma;
        jm::joint_matrix_load(wg,ma,multi_ptr<half,access::address_space::global_space>(A),(size_t)K);
        jm::joint_matrix<decltype(wg),half,jm::use::b,K,N,jm::layout::row_major> mb;
        jm::joint_matrix_load(wg,mb,multi_ptr<half,access::address_space::global_space>(B),(size_t)N);
        jm::joint_matrix<decltype(wg),float,jm::use::accumulator,M,N,jm::layout::dynamic> mc;
        jm::joint_matrix_fill(wg,mc,0.f);
        jm::joint_matrix_mad(wg,mc,ma,mb,mc);
        jm::joint_matrix_store(wg,mc,multi_ptr<float,access::address_space::global_space>(Out),(size_t)N,jm::layout::row_major);
        if(it.get_local_id(0)==0u) PR[0]=(float)it.get_sub_group().get_local_range().size();
      }); });
    q.wait();
    std::vector<float> hc((size_t)M*N); q.memcpy(hc.data(),Out,hc.size()*4).wait();
    float hp; q.memcpy(&hp,PR,4).wait();
    int bad=0; for(size_t i=0;i<hc.size();++i) if(std::abs(hc[i]-hRef[i])>0.3f) bad++;
    printf("[probe] sub_group width=%.0f\n",hp);
    printf("WORK-GROUP joint_matrix: %d/%d wrong -> %s\n",bad,(int)hc.size(),bad?"BROKEN":"WORKS (45ms path OPEN)");
    for(int i=0;i<4;++i) printf("  [%d] got %.4f want %.4f\n",i,hc[i],hRef[i]);
  } catch(const sycl::exception&e){ printf("THREW: %s\n",e.what()); return 2; }
  return 0;
}
