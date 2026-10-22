// bench_acc.cpp -- section 93: DECISIVE root-cause test. Are joint_matrix's f32 accumulator
// bits identical to f16v1::gemm (ESIMD dpas<8,8>)'s for the SAME f16 operands? If they
// differ by ULPs, the resident kernel cannot be bit-exact with the split golden (which uses
// ESIMD dpas) no matter how the normalize is written -- V hides it (e4m3 coarse), K exposes
// it (half_round + butterfly). 16x16x16 f16 -> f32, both paths, bit-compare.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int M=8,N=8,K=16;
  std::vector<half> hA((size_t)M*K),hB((size_t)K*N);
  std::mt19937 rng(4); std::uniform_real_distribution<float> dd(-2.f,2.f);
  for(auto&x:hA)x=half(dd(rng)); for(auto&x:hB)x=half(dd(rng));
  half* A=(half*)malloc_device(hA.size()*2,q); half* B=(half*)malloc_device(hB.size()*2,q);
  q.memcpy(A,hA.data(),hA.size()*2).wait(); q.memcpy(B,hB.data(),hB.size()*2).wait();
  float* CJ=(float*)malloc_device((size_t)M*N*4,q);   // joint_matrix
  float* CE=(float*)malloc_device((size_t)M*N*4,q);   // ESIMD f16v1
  // joint_matrix: one workgroup, sub_group scope, 16x16x16 in one mad (K=16)
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group();
      jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> ma;
      jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::global_space>(A),(size_t)K);
      jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> mb;
      jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::global_space>(B),(size_t)N);
      jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> mc;
      jm::joint_matrix_fill(sg,mc,0.f);
      jm::joint_matrix_mad(sg,mc,ma,mb,mc);
      jm::joint_matrix_store(sg,mc,multi_ptr<float,access::address_space::global_space>(CJ),(size_t)N,jm::layout::row_major);
    }); });
  // ESIMD f16v1::gemm (packed)
  half* dAp=(half*)malloc_device((size_t)M*K*2,q); half* dBp=(half*)malloc_device((size_t)K*N*2,q);
  packdev::pack_a16(q,A,dAp,M,M,K); packdev::pack_b16(q,B,dBp,K,N);
  f16v1::gemm(q,dAp,dBp,CE,M,N,K);
  q.wait();
  std::vector<float> hj((size_t)M*N),he((size_t)M*N);
  q.memcpy(hj.data(),CJ,hj.size()*4).wait(); q.memcpy(he.data(),CE,he.size()*4).wait();
  int bad=0; double maxd=0;
  for(size_t i=0;i<hj.size();++i){ if(bit_cast<uint32_t>(hj[i])!=bit_cast<uint32_t>(he[i])) bad++;
    maxd=std::max(maxd,(double)std::abs(hj[i]-he[i])); }
  fflush(stdout); printf("joint_matrix vs ESIMD dpas acc: %d/%d bit-differ, max abs diff %.6f\n",bad,(int)hj.size(),maxd);
  for(int i=0;i<6;++i) printf("  [%d] jm %.7f  esimd %.7f\n",i,hj[i],he[i]);
  return 0;
}
