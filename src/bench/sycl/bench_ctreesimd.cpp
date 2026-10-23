// bench_ctreesimd.cpp -- section 96 C0: can ctree::cosine_reciprocal / cr_hmul / cr_hadd /
// cr_hfma (built on ext::intel::math fmul_rn/fadd_rn + qr_half_round + qr_e4m3) be called
// from INSIDE a SYCL_ESIMD_KERNEL at all? bench_esimops said ext::intel::math is illegal in
// ESIMD context -- if that is true, v2 P2 must carry the joint kernel's ctree chain through
// a DIFFERENT context strategy. This isolates just that question: (a) compile with ctree
// call in ESIMD kernel? (b) if not, the fix options are: split v2 so normalize lives in a
// plain sub-kernel (multi-launch fused via barriers is impossible ACROSS launches...) or
// reimplement the reduce with ef_* + explicit half-rounds (the bench_smesimd recipe).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
using namespace sycl;
int main(){
  queue q;
  try{
    q.submit([&](handler& h){
      h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
        float hv[32]; for(int i=0;i<32;++i) hv[i]=1.0f+i*0.05f;
        float rec=ctree::cosine_reciprocal(hv);
        if(rec<0) printf("%g",rec);
      }); });
    q.wait(); printf("C0: ctree:: IN ESIMD COMPILES+RUNS\n");
  }catch(const sycl::exception&e){ printf("C0 THREW: %.120s\n",e.what()); }
  return 0;
}
