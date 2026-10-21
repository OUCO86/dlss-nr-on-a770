// bench_jmf.cpp -- section 93: THE keystone for the resident megakernel in STANDARD SYCL
// (not ESIMD). The shipped window_block.comp structure is: coopmat at gl_ScopeSubgroup +
// workgroup shared memory + real workgroup barriers. The SYCL equivalent = joint_matrix
// (sub_group scope, proven to RUN CORRECTLY on this Arc by bench_jm) + local_accessor
// (SLM) + group_barrier, in a normal nd_range kernel with 8 subgroups (256 threads).
// Test: 8 subgroups each compute an 8x64 tile of a 64x64x32 f16 gemm via joint_matrix,
// store to SLM, group_barrier, then ALL threads read back the FULL 64x64 (cross-subgroup
// visibility). Host verifies every element. If this passes, the fusion that gives the
// coopmat chain its 45ms is expressible in SYCL/L0 -- the "third wall" was ESIMD-specific.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <vector>
#include <cmath>
#include <random>
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int M=64,N=64,K=32;
  std::vector<half> hA((size_t)M*K),hB((size_t)K*N); std::vector<float> hRef((size_t)M*N);
  std::mt19937 rng(11); std::uniform_real_distribution<float> d(-1.f,1.f);
  for(auto&x:hA)x=half(d(rng)); for(auto&x:hB)x=half(d(rng));
  for(int r=0;r<M;++r)for(int c=0;c<N;++c){float a=0;for(int k=0;k<K;++k)a+=(float)hA[(size_t)r*K+k]*(float)hB[(size_t)k*N+c];hRef[(size_t)r*N+c]=a;}
  half* A=(half*)malloc_device(hA.size()*2,q); half* B=(half*)malloc_device(hB.size()*2,q);
  half* Out=(half*)malloc_device((size_t)M*N*2,q);
  q.memcpy(A,hA.data(),hA.size()*2).wait(); q.memcpy(B,hB.data(),hB.size()*2).wait();
  printf("launching joint_matrix+SLM+group_barrier keystone...\n"); fflush(stdout);
  try{
    q.submit([&](handler& h){
      local_accessor<float,1> SLM(range((size_t)M*N), h);
      h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it){
        auto sg=it.get_sub_group();
        uint sub=sg.get_group_id();               // 0..7, each owns rows 8*sub..8*sub+7
        for(int cb=0;cb<N;cb+=8){
          jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> mc;
          jm::joint_matrix_fill(sg,mc,0.f);
          for(int kb=0;kb<K;kb+=16){
            jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> ma;
            jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::global_space>(A+(size_t)(sub*8)*K+kb),K);
            jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> mb;
            jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::global_space>(B+(size_t)kb*N+cb),N);
            jm::joint_matrix_mad(sg,mc,ma,mb,mc);
          }
          jm::joint_matrix_store(sg,mc,multi_ptr<float,access::address_space::local_space>(SLM.get_pointer()+(size_t)(sub*8)*N+cb),N,jm::layout::row_major);
        }
        group_barrier(it.get_group());
        for(uint i=it.get_local_id(0);i<(uint)(M*N);i+=256u) Out[i]=half(SLM[i]);
      });
    }).wait();
    std::vector<half> ho((size_t)M*N); q.memcpy(ho.data(),Out,ho.size()*2).wait();
    int bad=0; for(size_t i=0;i<ho.size();++i) if(std::abs((float)ho[i]-hRef[i])>0.05f) bad++;
    printf("keystone: %d/%d wrong -> %s\n",bad,(int)ho.size(),bad?"FAIL":"joint_matrix+SLM+group_barrier WORKS");
  }catch(const sycl::exception&e){printf("THREW: %s\n",e.what());return 2;}
  return 0;
}
