// bench_simd.cpp -- section 93: THE crux experiment. joint_matrix's speed/fragility under
// SIMD8 is the whole blocker. What determines whether the compiler picks SIMD32 vs SIMD8?
// bench_jmf (tiny, 4096 SLM, 1 gemm) got SIMD32. bench_oproj (8192 SLM, 6 fragments) got
// SIMD8. Test a matrix of (SLM size, live-fragment count, live-array count) and report the
// SIMD width each gets. If a small change flips it to SIMD32, the resident kernel can be
// restructured to get SIMD32 -> joint_matrix becomes 8x faster + non-fragile -> 45ms path opens.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <cstdlib>
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;
template<int SLMF, int NFRAG, int NARR> void probe(queue& q, float* PR){
  q.submit([&](handler& h){
    local_accessor<float,1> SLM(range((size_t)SLMF), h);
    h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group(); uint lid=(uint)it.get_local_id(0);
      float* f32p=SLM.get_pointer(); half* h16=(half*)f32p;
      float arr[NARR>0?NARR:1]; for(int i=0;i<NARR;++i) arr[i]=f32p[lid+i]; if(NARR==0) arr[0]=f32p[lid];
      jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> a[NFRAG];
      jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> c[NFRAG];
      for(int i=0;i<NFRAG;++i){
        jm::joint_matrix_load(sg,a[i],multi_ptr<half,access::address_space::local_space>(h16+i*16u),(size_t)32u);
        jm::joint_matrix_fill(sg,c[i],arr[i]);
      }
      for(int i=0;i<NFRAG;++i){
        jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> b;
        jm::joint_matrix_load(sg,b,multi_ptr<half,access::address_space::local_space>(h16+i*16u),(size_t)8u);
        jm::joint_matrix_mad(sg,c[i],a[i],b,c[i]);
      }
      for(int i=0;i<NFRAG;++i)
        jm::joint_matrix_store(sg,c[i],multi_ptr<float,access::address_space::local_space>(f32p+i*8u),(size_t)8u,jm::layout::row_major);
      group_barrier(it.get_group());
      if(lid==0u) PR[0]=(float)sg.get_local_range().size();
    }); });
  q.wait();
}
int main(int argc,char**argv){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* PR=(float*)malloc_device(4,q);
  auto run=[&](int slmf,int nfrag,int narr,const char* nm){
    if(slmf==4096&&nfrag==1&&narr==0) probe<4096,1,0>(q,PR);
    else if(slmf==4096&&nfrag==4&&narr==0) probe<4096,4,0>(q,PR);
    else if(slmf==4096&&nfrag==8&&narr==0) probe<4096,8,0>(q,PR);
    else if(slmf==8192&&nfrag==4&&narr==0) probe<8192,4,0>(q,PR);
    else if(slmf==4096&&nfrag==4&&narr==32) probe<4096,4,32>(q,PR);
    else if(slmf==4096&&nfrag==4&&narr==64) probe<4096,4,64>(q,PR);
    else if(slmf==4096&&nfrag==2&&narr==0) probe<4096,2,0>(q,PR);
    else { printf("no case %s\n",nm); return; }
    float hp; q.memcpy(&hp,PR,4).wait();
    printf("  %-28s -> SIMD%.0f\n",nm,hp);
  };
  printf("SIMD width vs (SLM floats, live fragments, live array):\n");
  run(4096,1,0,"slm4096 frag1 arr0");
  run(4096,2,0,"slm4096 frag2 arr0");
  run(4096,4,0,"slm4096 frag4 arr0");
  run(4096,8,0,"slm4096 frag8 arr0");
  run(8192,4,0,"slm8192 frag4 arr0");
  run(4096,4,32,"slm4096 frag4 arr32");
  run(4096,4,64,"slm4096 frag4 arr64");
  return 0;
}
