// bench_lloc.cpp -- section 93: isolate the resident bug. joint_matrix_load from LOCAL
// (SLM) space was never verified (bench_jmf proved global-load + local-STORE). Test an
// 8x16 * 16x8 = 8x8 f16 gemm with operands staged in SLM, load from local vs from global.
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
  const int MA=8,MK=16,MB=8;
  std::vector<half> hA((size_t)MA*MK),hB((size_t)MK*MB);
  std::mt19937 rng(5); std::uniform_real_distribution<float> dd(-2.f,2.f);
  for(auto&x:hA)x=half(dd(rng)); for(auto&x:hB)x=half(dd(rng));
  std::vector<float> hRef((size_t)MA*MB,0.f);
  for(int r=0;r<MA;++r)for(int c=0;c<MB;++c){float a=0;for(int k=0;k<MK;++k)a+=(float)hA[(size_t)r*MK+k]*(float)hB[(size_t)k*MB+c];hRef[(size_t)r*MB+c]=a;}
  half* GA=(half*)malloc_device(hA.size()*2,q); half* GB=(half*)malloc_device(hB.size()*2,q);
  float* Out=(float*)malloc_device((size_t)MA*MB*4,q);
  q.memcpy(GA,hA.data(),hA.size()*2).wait(); q.memcpy(GB,hB.data(),hB.size()*2).wait();
  auto run=[&](int variant){ // 0=fill SLM + local-load; 1=global-load (control)
    q.submit([&](handler& h){
      local_accessor<float,1> SLM(range(512u), h);
      h.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
        auto sg=it.get_sub_group(); uint lid=(uint)it.get_local_id(0);
        float* f32p=SLM.get_pointer(); half* h16=(half*)f32p;
        for(int i=lid;i<MA*MK+MK*MB;i+=32) h16[i]=(i<MA*MK)?GA[i]:GB[i-MA*MK];
        group_barrier(it.get_group());
        jm::joint_matrix<decltype(sg),half,jm::use::a,MA,MK,jm::layout::row_major> ma;
        jm::joint_matrix<decltype(sg),half,jm::use::b,MK,MB,jm::layout::row_major> mb;
        if(variant==0){
          jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::local_space>(h16),(size_t)MK);
          jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::local_space>(h16+MA*MK),(size_t)MB);
        } else {
          jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::global_space>(GA),(size_t)MK);
          jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::global_space>(GB),(size_t)MB);
        }
        jm::joint_matrix<decltype(sg),float,jm::use::accumulator,MA,MB,jm::layout::dynamic> mc;
        jm::joint_matrix_fill(sg,mc,0.f);
        jm::joint_matrix_mad(sg,mc,ma,mb,mc);
        jm::joint_matrix_store(sg,mc,multi_ptr<float,access::address_space::global_space>(Out),(size_t)MB,jm::layout::row_major);
      }); });
    q.wait();
    std::vector<float> hc((size_t)MA*MB); q.memcpy(hc.data(),Out,hc.size()*4).wait();
    int bad=0; for(size_t i=0;i<hc.size();++i) if(std::abs(hc[i]-hRef[i])>0.3f) bad++;
    printf("variant %d (%s-load): %d/%d wrong\n",variant,variant==0?"local":"global",bad,(int)hc.size());
  };
  run(0); run(1);
  return 0;
}
