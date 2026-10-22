// bench_cmajor.cpp -- section 93: is col_major joint_matrix_load the scores-gemm culprit?
// QKV gemm (row_major B) is 100% correct; scores gemm (col_major B = K^T) breaks. Test an
// 8x16 A * 16x8 B(col_major) = 8x8 C, B stored row-major as K[8][16] (token-major), loaded
// col_major to get K^T. Compare vs host. If this breaks, col_major is the bug; if it works,
// the bug is query-fragment reuse across stages.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <vector>
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
  const int M=8,K=16,N=8;
  std::vector<half> hA((size_t)M*K),hK((size_t)N*K);   // K stored [token][channel] = [N][K]
  std::mt19937 rng(7); std::uniform_real_distribution<float> dd(-2.f,2.f);
  for(auto&x:hA)x=half(dd(rng)); for(auto&x:hK)x=half(dd(rng));
  half* A=(half*)malloc_device(hA.size()*2,q); half* Kb=(half*)malloc_device(hK.size()*2,q);
  float* Out=(float*)malloc_device((size_t)M*N*4,q);
  q.memcpy(A,hA.data(),hA.size()*2).wait(); q.memcpy(Kb,hK.data(),hK.size()*2).wait();
  // host: C[m][n] = sum_k A[m][k]*K^T[k][n] = sum_k A[m][k]*K[n][k]
  std::vector<float> hRef((size_t)M*N,0.f);
  for(int m=0;m<M;++m)for(int n=0;n<N;++n){float a=0;for(int k=0;k<K;++k)a+=(float)hA[(size_t)m*K+k]*(float)hK[(size_t)n*K+k];hRef[(size_t)m*N+n]=a;}
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group();
      jm::joint_matrix<decltype(sg),half,jm::use::a,M,K,jm::layout::row_major> ma;
      jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::global_space>(A),(size_t)K);
      jm::joint_matrix<decltype(sg),half,jm::use::b,K,N,jm::layout::col_major> mb;
      jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::global_space>(Kb),(size_t)K);  // K[N][K] row-major, ld=K, col_major -> K^T
      jm::joint_matrix<decltype(sg),float,jm::use::accumulator,M,N,jm::layout::dynamic> mc;
      jm::joint_matrix_fill(sg,mc,0.f);
      jm::joint_matrix_mad(sg,mc,ma,mb,mc);
      jm::joint_matrix_store(sg,mc,multi_ptr<float,access::address_space::global_space>(Out),(size_t)N,jm::layout::row_major);
    }); });
  q.wait();
  std::vector<float> hc((size_t)M*N); q.memcpy(hc.data(),Out,hc.size()*4).wait();
  int bad=0; for(size_t i=0;i<hc.size();++i) if(std::abs(hc[i]-hRef[i])>0.3f) bad++;
  printf("col_major B-load (K^T): %d/%d wrong -> %s\n",bad,(int)hc.size(),bad?"COL_MAJOR BROKEN":"col_major OK");
  for(int i=0;i<4;++i) printf("  [%d] got %.4f want %.4f\n",i,hc[i],hRef[i]);
  return 0;
}
