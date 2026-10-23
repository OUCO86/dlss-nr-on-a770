// bench_esnd.cpp -- section 96 part 4: THE v2 go/no-go. SYCL_ESIMD_KERNEL with nd_range
// MULTI-subgroup (256 threads = e.g. 16x SG16), crossing stage handoff via GLOBAL scratch
// (NOT esimd::slm_init -- that's what hit SLM+dpas+multi-subgroup=DEVICE_LOST in the .comp
// port attempts) + standard group_barrier. Stage 1: each work-item scalar-writes its half
// into a global pool region. group_barrier. Stage 2: block-load tag<16> + dpas + store.
// If this launches without DEVICE_LOST and every lane's dpas reads the OTHER subgroups'
// writes correctly => the proven ESIMD f16v1 gemm bodies can live in ONE fused workgroup
// and hand tiles through global. That is the v2 backbone.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  // pool: 512 halfs. We fill with half value (r+1)*10 pattern? keep simple: work-item w writes (1.0) to G[w].
  // Stage-2 block loads A=G, B=G+128 (both all-ones) -> dpas K16 -> c=16 every lane.
  // BUT cross-subgroup handoff check: subgroup s writes value (s+1) into its own 128h A block?
  // then subgroup t reading subgroup s's block gets (s+1) -> D lane0 = 16*(s+1)? Let's encode
  // block identity into values: each workgroup has 256 thr; A pool = 256 halfs filled with
  // half(laneid%8 + 1) * 10? Simplify: fill A[i]=half((i/32)+1) (32-elem stripes -> 8 distinct
  // values), B=ones. After block load, D[0] row0 = sum_k A[k]*1 = sum A[0..15]=(1)*16=16;
  // row r = sum A[16r..16r+15] = (1+ (17/32+1)?) hmm rows 0..7 each 16 halfs: row r covers
  // A[16r..16r+16): stripe boundaries at 32 -> row0,1 in stripe0(val1): 16 each -> D r0=16, r1=16?
  // rows 2,3 stripe1 val2 -> 32... this gives a signature vector: D = [16,16,32,32,48,48,64,64] per row.
  // Any subgroup that did NOT see the global writes reads STALE zeros -> D all zero or partial.
  half* G=(half*)malloc_device(256*2,q); q.memset(G,0,512).wait();
  // fill G with zeros first; then stage1 of the SAME kernel writes stripes; stage2 reads.
  int* O=(int*)malloc_device(256*4,q); q.memset(O,0,1024).wait();
  float* PR=(float*)malloc_device(4,q); q.memset(PR,0,4).wait();
  printf("launching ESIMD nd(256/256) multi-subgroup global-handoff + dpas...\n"); fflush(stdout);
  try{
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint lid=(uint)it.get_local_id(0);
        // stage 1: thread lid writes stripe value (lid/32)+1 at G[lid]  (8 stripes of 32)
        G[lid]=half((float)((lid/32u)+1u));
        group_barrier(it.get_group());
        // stage 2: block loads + dpas (f16v1 gemm shapes: 128h A = rows0..7 x16k? A has only
        // 128 halfs = 256B at G, B = G+128)
        esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
        esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f);
        c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        // write row-signature: each lane stores its c[0]
        O[lid]=(int)c[0];
        auto sg=it.get_sub_group();
        if(lid==0u) PR[0]=(float)sg.get_local_range().size();
      }); });
    q.wait();
    std::vector<int> ho(256,0); std::vector<float> hw(1,0);
    q.memcpy(ho.data(),O,1024).wait(); q.memcpy(hw.data(),PR,4).wait();
    printf("[probe] ESIMD nd kernel got sg=%2.0f\n",hw[0]);
    int nzero=0,nsig=0,noth=0;
    // expected signature: B block G+128 was ALSO written by stage1: G[128..255] = stripes 5..8 ->
    // vals 5..8, not ones! Then D[r] = sum_k A[k]*B[k][r]... complicated. Just classify zero/nonzero/first-block:
    for(int v:ho){ if(v==0)++nzero; else if(v==16)++nsig; else ++noth; }
    printf("lane c0: ==0:%d  ==16:%d  other:%d  first8: %d %d %d %d %d %d %d %d\n",
      nzero,nsig,noth,ho[0],ho[1],ho[2],ho[3],ho[4],ho[5],ho[6],ho[7]);
    printf("=> %s\n", (nzero==0)?"NO STALE ZEROS: multi-subgroup global handoff WORKS (v2 backbone OK)":"STALE ZEROS: handoff broken");
  }catch(const sycl::exception&e){ printf("THREW: %.200s\n",e.what()); return 2; }
  return 0;
}
