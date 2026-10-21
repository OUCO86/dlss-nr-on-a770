// bench_jm.cpp -- section 92: verify joint_matrix (SYCL matrix ext, NOT ESIMD) runs DPAS
// on this Arc/L0 device, at BOTH sub_group and work_group scope. The bisect proved ESIMD
// multi-subgroup SLM+dpas crashes; joint_matrix is the standard-SYCL coopmat path (uses
// __spirv_CooperativeMatrixMulAddKHR, the same instruction the shipped GLSL .comp emits),
// so work_group scope should allow the multi-subgroup cooperation ESIMD cannot. If this
// runs, the resident megakernel becomes expressible and the third wall is NOT hard.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  // ---- sub_group scope: 16x16x16 f16*f16->f32 ----
  {
    half* A=(half*)malloc_device(16*16*2,q); half* B=(half*)malloc_device(16*16*2,q);
    float* C=(float*)malloc_device(16*16*4,q);
    std::vector<half> ha(16*16, half(1.f)), hb(16*16, half(1.f));
    q.memcpy(A,ha.data(),ha.size()*2).wait(); q.memcpy(B,hb.data(),hb.size()*2).wait();
    try {
      q.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
        auto sg=it.get_sub_group();
        jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> ma;
        jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> mb;
        jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> mc;
        jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::global_space>(A),16); jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::global_space>(B),16);
        jm::joint_matrix_fill(sg,mc,0.f);
        jm::joint_matrix_mad(sg,mc,ma,mb,mc);
        jm::joint_matrix_store(sg,mc,multi_ptr<float,access::address_space::global_space>(C),16,jm::layout::row_major);
      }).wait();
      std::vector<float> hc(16*16); q.memcpy(hc.data(),C,hc.size()*4).wait();
      printf("sub_group joint_matrix: C[0]=%.1f (expect 16) -> %s\n",hc[0], hc[0]>15.5f&&hc[0]<16.5f?"OK":"WRONG");
    } catch(const std::exception&e){ printf("sub_group joint_matrix THREW: %s\n",e.what()); }
  }
  // work_group scope block removed: toolchain type bug (matrix-unified.hpp:181)
  return 0;
}
