// gemm32_tile.cpp -- the gemm32 / gemm32_b family (BM128/BN32/BK32/NT16, s8d2 triple
// buffer, gemm_s8_v8_kernel.hpp:209) swept over its tile axes on the two N=32 frame
// shapes 刀 A (bench_s8v8_tile.cpp) left uncovered -- notes/DS-takeover-2026-11-01.md:105:
//   (M,N,K,b) = (32640,32,128,2) and (8160,32,128,4).
//   NOTE (TRAP 9, at the bottom of this header): the notes/DS line and bench_n32.cpp:2 say
//   these run "x16" and "x24" per frame. Re-counted from the plan: the REPLAYED region is
//   the captured graph (plan_960x544.c lines 5308..6643) and it holds x8 and x12 -- 20
//   calls, not 40. The 16/24 figures sum the aborted recording with the captured one.
// These are the batched-family N=32 sites: the recorder takes the N%64!=0 branch
// (libxmx_sycl.cpp:2680) = gemm32_b (raw int32) + a SEPARATE scalar publish pass
// (libxmx_sycl.cpp:2682-2693). So the pub leg measured here is a CANDIDATE fused form,
// not a shipped one. epi = 1 (the frame's N=32 plan carries epi1, bench_n32.cpp:6).
//
// AXES SCANNED (刀 A's set was the BN64/BN128 BM128 family; this one is the BN32 family):
//   NT16 -> NT32 (two ways to split 128x32 over 32 threads: MODE1 8rowsx16cols,
//                  MODE2 16rowsx8cols -- MODE1 keeps A traffic flat and doubles B SLM
//                  reads, MODE2 halves the store width to 8 int32; both halve the live
//                  accumulator set from 4 fragments to 2),
//   BK32 -> BK64 (KC=2; needs a different A pack map AND the kc-sliced B copy, below),
//   BN32 -> BN64/BN128 (ILLEGAL as a drop-in for N=32: wg=(Mp/128)*(N/BN) = 0 -> the
//                  shipped kernel launches NOTHING and the B tile reads past the packed
//                  buffer. Measured here in the PADDED form (B packed with Np=BNV rows,
//                  rows >= N zero; stores culled at gc>=N) so the redundancy is priced,
//                  not hidden: B global traffic x(BNV/N), dpas x(BNV/N) of waste. The
//                  table prints the pad factor and run_variant prints N/A if you ask for
//                  an unpadded BN>N -- see LEGALITY below),
//   depth: NBUF=2 (double buffer, prefetch depth 1) vs NBUF=3 (the shipped s8d2) vs 4,
//   legs: raw (int32 C32 store, verbatim gemm32_b tail) and pub (f16 fused publish,
//                  verbatim gemm_b_pub tail: convert<float>(acc)*rs*cs then pub_vec_v8).
//
// REPRODUCTION TRAPS (each one cost a build or a wrong table -- do not re-discover):
// 1. BUILD RECIPE: cd into src/bench/sycl and pass RELATIVE names, then
//      bash E:/DSH/bench.sh gemm32_tile.cpp gemm32_tile.exe
//    With an ABSOLUTE path MSYS does not fold "//Fe:" and icx dies on "no such file".
//    icx is a clang-cl driver: flags in //form, NO MSYS_NO_PATHCONV, and the exe must
//    run from E:/DSH/oneapi (the sycl9.dll chain lives there) -- bench.sh stages it.
//    SYCL_DEVICE_FILTER=level_zero:gpu (ESIMD does not run on the native/sycl: filter).
// 2. BK=64 B COPY -- THE TRAP, PINNED DOWN BY MEASUREMENT IN THIS FILE. pack_b emits one
//    kk32 block per 32 K and puts consecutive kk32 blocks Np*32 bytes apart in GLOBAL,
//    where Np is the PACKED column count. A BK=64 SLM buffer spans two of them, so the
//    per-kc copy (bp + kb*Np*BKV + kc*(Np*32) -> SLM slot kc*(SLM_B/KC)) is only
//    interchangeable with one linear copy when the tile spans the whole packed width,
//    i.e. BNV == Np -- NOT "when N==32" as 刀 A's note reads. At N=32 with a BN32 tile
//    BNV==Np holds, so the naive copy is ACCIDENTALLY correct in this family; 刀 A's
//    BN64 tile at N=128 has BNV < Np and that is where it silently fed wrong bytes
//    (bench_s8v8_tile.cpp:104-119, notes/DS-takeover-2026-11-01.md:91). Both halves are
//    proven here by the TRAPDEMO row: the BN32/BK64 kernel pointed at an Np=64 pack
//    (BNV < Np) is diff=0 with the per-kc copy and diff=2088940/2088960 (shape A) and
//    1044468/1048576 (shape B) when built with //DG32_BCOPY_NAIVE -- and every BNV==Np
//    row stays diff=0 in BOTH builds. Keep the per-kc form anyway: KC=1 reduces to the
//    linear copy, so it costs nothing and it is the only correct spelling for BNV<Np.
// 3. BK=64 A PACK: gather_pack_a_b hardcodes BK=32, so BK=64 needs its own map: per
//    (w,kb) block = 8 wi x [kc0: 16 rows x 32k][kc1: ditto] (1024B per wi). The kernel
//    reads it with offA = packwi*(KC*512) + kc*512. pack_a64_host below is HOST-side and
//    runs OUTSIDE the timed region (only gemm events are timed), so the pack cost never
//    enters a row -- but it must be byte-consistent with the kernel's map or diff != 0.
// 4. BN > N IS NOT A KERNEL BUG, IT IS A GRID BUG: (N/BN) == 0 in the shipped launch.
//    The padded variants need the B pack at Np=BNV (a different buffer, kk-block stride
//    Np*32) AND the store cull; pass the wrong B buffer and you read OOB garbage.
// 5. THE PUB LEG HAS NO SHIPPED TWIN at N=32 (gemm_b_pub needs N%64==0 -> wg=0). The pub
//    reference is therefore THIS FILE'S OWN fork at the shipped geometry
//    (BN32/BK32/NT16/NBUF3/MODE0/PUB). The chain closes because the same fork with
//    PUB=false is diffed byte-exact against the shipped gemm32_b (the ANCHOR line); if
//    the anchor raw diff != 0 everything below it is void, which is why the anchor rows
//    are the FIRST two rows of the sweep -- read them before believing any other row.
// 6. CROSS-PROCESS ABSOLUTE TIMES ARE NOT COMPARABLE (刀 A proved it on the BN64 family:
//    the shipped pub leg on a small grid drew 0.036 / 0.073 / 0.131 ms). THIS FILE proves
//    the same on the N=32 family AND finds a second, worse source: four processes of this
//    one exe put the SAME form's min-of-15 anywhere from 0.068 to 0.134 ms (M32640 shipped
//    raw). The per-rep distribution is 1.4-4x wide, and its shape depends on how much
//    GPU work the process has already asked for -- a short burst off an idle GPU reaches a
//    boost/L2-hot mode, one long group mixes that with a throttled mode (a 300-rep
//    warm-up made the shipped kernel's TYPICAL rep 0.13 against a 0.094 min). Do NOT
//    "fix" this by warming up harder; see the TIMING PROTOCOL block above run_variant.
//
// 7. SPILL/SCRATCH LEDGER: do NOT AOT-link this file -- ocloc dies on "more than one
//    module with an entry point" once the TU carries 30+ kernel instantiations. Use the
//    JIT persistent cache instead (SYCL_CACHE_PERSISTENT=1 + SYCL_CACHE_DIR, both set by
//    bench.sh): gemm32_spillcheck.py reads the zebin ELFs (e_machine 0xCD) that ACTUALLY
//    RAN. Dump to a SHORT path (MAX_PATH trap, the .text.<mangled>.asm names are ~170B).
// 8. The output buffers are memset before the reference pass; padded C rows (rr>=M) are
//    never written by the pub tail, so the pub diff covers the full b*Mp*N region and is
//    only meaningful because every variant writes the same zeros there.
//
// WHAT THE SWEEP FOUND (full numbers, 8-process pooled table, per-kernel ledger:
// gemm32_tile_run.txt next to this file; 40 group-mins per form per leg):
//  - 34 forms x {raw,pub} x 2 shapes: byte-exact everywhere, every diff column 0.
//  - THE FORK TAX IS ~4%: the anchor (this file's copy of the shipped geometry) measures
//    0.0977 / 0.0725 ms vs the shipped 0.0936 / 0.0688 (msM, shapes A / B). A form has to
//    clear that tax before its win means anything.
//  - SHAPE B (8160,32,128,b4): the NT16 grid under-fills the machine (64 wg_rows x 4
//    groups = 256 workgroups). NT32 in either split, and BN32/BK64/NT32-halfrow with
//    DOUBLE buffers, sits at 0.0295-0.0348 ms vs shipped 0.0688 = -49.5% to -57.1%, i.e.
//    272-321 GB/s = 49-57% of the 560 roof where the shipped form only reaches 24.5%.
//    Reliable: 34-36 of 40 groups land in the fast state. (bn32_buf2 reaches 0.0291 in
//    only 19/40, so its ranking number is 0.0470 = -31.8% -- depth-2 alone is real but
//    unsteady at BK32; the NT32 forms are the steady ones.) Frame: 12 calls => -0.47 ms.
//  - SHAPE A (32640,32,128,b2): big-M and DRAM-bound -- on the ranking number no legal
//    form gets past ~39% of the roof. bk64_hr_buf2 shows 373 GB/s (66.5%) but reaches that
//    state in only 4 of 40 groups, so treat 0.0862 ms (-7.9%) as its real value; the
//    steady shape-A tile win is -4% (bn32_buf2) to -8% (bk64_hr_buf2).
//  - THE WALL AT THESE SITES IS NOT THE TILE: the recorder's SEPARATE scalar publish
//    pass (libxmx_sycl.cpp:2682-2693, measured verbatim here) costs 0.3927 / 0.2049 ms per
//    call = 12.5 MB (int32 read + f16 write) => 31.9 / 30.6 GB/s = 5.7% / 5.5% of the roof,
//    i.e. 4.2x / 3.0x the gemm32_b it follows; the split chain is 0.4863 / 0.2737 per call.
//    Fusing the publish into the GEMM (the pub leg, byte-exact by construction) at
//    BN32/BK32/NT32-halfrow/BUF2 gives 0.0717 / 0.0416 ms per call TOTAL.
//  - TRAP 9, THE CALL COUNT (this is the one that would have doubled the headline): the
//    frame replays only the CAPTURED graph of plan_960x544.c (plan lines 5308..6643). In
//    it, xmx_rec_gemm_int8_batched runs M=32640 N=32 K=128 b=2 EIGHT times (plan lines
//    5345/5369/5391/5413/6541/6563/6585/6607) and M=8160 N=32 K=128 b=4 TWELVE times
//    (5438/5460/5482/5504/5526/5548/6407/6429/6451/6473/6495/6517) = 20 calls, NOT the 40
//    (x16/x24) figure that bench_n32.cpp:2 and the notes inherited -- those counts sum the
//    aborted recording (3922..5294) with the captured one. At 8/12: today the 20 sites cost
//    1.57 (gemm) + 5.60 (publish) = 7.18 ms/frame, ALL OF IT ALREADY INSIDE the "batched
//    18.5" row of the section 6.30 RUN_TIMING table (that instrument times whole recorder
//    closures with a GQ->wait, libxmx_sycl.cpp:885-893, and the publish pass is launched
//    inside the same closure). Fold + retile = 1.07 ms/frame => -6.1 ms SERIAL inside that
//    row (18.5 -> ~12.4); at the notes' 43% overlap survival that is ~-2.6 ms on the frame,
//    up to -6.1 if the closures are critical-path. Report the RANGE, not one number.
//  - WHY THERE IS NO GUARD TO JUST RELAX (the change is a new kernel, not a flag): this
//    op's int8 fold branch is libxmx_sycl.cpp:2660 `N % 64u == 0u` -> gemm_b_pub /
//    gemm_b_pub_slm, and gemm_b_pub's grid (Mp/128)*(N/64) is ZERO at N=32 (bench_n32.cpp:4
//    already records those as empty launches). The header has no pub twin of the BN32
//    family (gemm32:280 / gemm32_b:209 are raw only). Blade-5's ldc_e guard fix (:2297)
//    lives in the f16-input op (:2304), a different recorder function. The two folds that
//    would also eat the downstream quant are dead/opt-in: v9 at :2563 is `if (false &&`,
//    v9b is NR_V9B=1 and shelved. So: add s8v8::gemm32_b_pub (gemm32_b's loop + gemm_b_pub's
//    tail -- THIS FILE'S gemm32_var<32,32,NTV,2,MODE,true> IS that kernel, byte-exact on
//    both shapes) and widen :2660 to N%32==0 selecting it, behind an NR_G32_PUB=0 escape.
//  - BN64 / BN128 at N=32 are ILLEGAL as a drop-in (wg = (Mp/128)*(N/BN) = 0 -> the launch
//    computes nothing and the B tile reads past the pack). Priced padded (Np=BNV, culled
//    stores) they pay 2x / 4x the B traffic and lose to the BN32 winners on both legs.
//  - LEDGER: grf=128, spill=private=scratch=0 and 0 scratch instructions in all 35
//    kernels; slm_size exactly the requested bytes (10-30 KB). 刀 A's finding #2 holds for
//    this family too -- nothing here is a register-pressure story.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include <thread>
#include <chrono>
#include "gemm_s8_v8_kernel.hpp"   // shipped: s8v8::gemm32_b / gemm_b / pub_vec_v8 -- READ ONLY
#include "pack_device.hpp"
#include "publish_kernel.hpp"      // cr_mul / qr_publish -- the recorder's SEPARATE publish pass
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ---- the variant kernels: bench-local fork of gemm32_b, geometry as template params ----
namespace g32v {
static const int BM = 128;

// MODE 0 = shipped BN32 map: thread tile 16 rows x 16 cols, 4 accumulator fragments,
//          NTV = BNV/2 (BN32 -> NT16 = the shipped gemm32_b; BN64 -> NT32; BN128 -> NT64)
// MODE 1 = thread tile  8 rows x 16 cols, 2 fragments, NTV = BNV (16 row bands)
// MODE 2 = thread tile 16 rows x  8 cols, 2 fragments, NTV = BNV (8 col bands of 8)
// MODE 3/4 are the shipped BN64/BN128 (MODE0) geometry applied to N=32 with the B pad.
template <int BNV, int BKV, int NTV, int NBUF, int MODE, bool PUB>
static inline sycl::event gemm32_var(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     int32_t* C32, void* Cout, const float* as, const float* bs,
                                     int M, int Mp, int N, int Np, int K, int batch,
                                     size_t sc, unsigned ldc, unsigned scale_stride,
                                     unsigned col_stride, bool narrow, unsigned epi) {
    constexpr int SLM_A  = BM * BKV;              // A bytes per operand buffer
    constexpr int SLM_B  = BKV * BNV;             // B bytes per operand buffer
    constexpr int KC     = BKV / 32;              // 32-K dpas chunks per kb block
    constexpr int RPT    = (MODE == 1) ? 8 : 16;  // rows per thread
    constexpr int CPT    = (MODE == 2) ? 8 : 16;  // cols per thread
    constexpr int WIC    = BNV / CPT;             // col bands
    constexpr int WIR    = BM / RPT;              // row bands
    constexpr int PBAND  = 512;                   // A bytes per 16-row PACK band per kc
    constexpr int BBAND  = CPT * 32;              // B bytes per thread per kc
    static_assert(WIR * WIC == NTV, "MODE/BNV/NTV geometry mismatch");
    static_assert(BKV % 32 == 0 && BNV % 16 == 0, "BK must be a multiple of 32, BN of 16");
    int coltiles = (N + BNV - 1) / BNV;
    int wg = (Mp / BM) * coltiles;
    int kb_n = K / BKV;
    size_t apb_sz = (size_t)Mp * K, bpb_sz = (size_t)Np * K, cb_sz = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NTV), range(NTV)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            constexpr uint32_t SLMB_BASE = NBUF * SLM_A;   // B buffers follow the A buffers
            esimd::slm_init<NBUF * SLM_A + NBUF * SLM_B>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int wg_row = loc / coltiles, wg_col = loc % coltiles;
            int wi_row = lid / WIC, wi_col = lid % WIC;
            // MODE1 threads own HALF a 16-row pack band: which band, and which half.
            int packwi = (MODE == 1) ? (wi_row / 2) : wi_row;
            int subrow = (MODE == 1) ? ((wi_row % 2) * 8) : 0;
            const int8_t* apb = Ap + (size_t)g * apb_sz + (size_t)(wg_row * kb_n) * SLM_A;
            const int8_t* bp  = Bp + (size_t)g * bpb_sz + (size_t)wg_col * (BNV / 8) * 256;
            int32_t* c_g = C32 + (size_t)g * cb_sz;
            // global -> SLM for one kb. A is one contiguous block (the packer laid it out
            // per (w,kb)); B is KC kk32 blocks Np*32 bytes apart in global -> per-kc copy
            // into per-kc SLM slots (TRAP 2; KC==1 reduces to the shipped linear copy).
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, SLM_A / NTV> av = esimd::block_load<int8_t, SLM_A / NTV>(
                    apb + (size_t)kb * SLM_A + lid * (SLM_A / NTV), esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * (SLM_A / NTV), av, esimd::overaligned_tag<16>{});
#ifdef G32_BCOPY_NAIVE
                // THE BUG 刀 A paid for (bench_s8v8_tile.cpp:104-119): one linear copy of
                // the whole BK*BN SLM buffer from global. It is only correct when the tile
                // spans the whole packed width (BNV == Np), because pack_b puts consecutive
                // kk32 blocks Np*32 bytes apart. Build with -DG32_BCOPY_NAIVE and the
                // TRAPDEMO row (BNV=32 pointed at an Np=64 pack, i.e. BNV < Np) comes back
                // diff != 0 while every BNV==Np row stays diff=0 -- which is exactly why
                // the N=32 family never tripped on this and the BN64-at-N=128 family did.
                esimd::simd<int8_t, SLM_B / NTV> bv = esimd::block_load<int8_t, SLM_B / NTV>(
                    bp + (size_t)kb * ((size_t)Np * BKV) + lid * (SLM_B / NTV),
                    esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLMB_BASE + buf * SLM_B + lid * (SLM_B / NTV),
                    bv, esimd::overaligned_tag<16>{});
#else
                #pragma unroll
                for (int kc = 0; kc < KC; ++kc) {
                    esimd::simd<int8_t, SLM_B / KC / NTV> bv = esimd::block_load<int8_t, SLM_B / KC / NTV>(
                        bp + (size_t)kb * (size_t)Np * BKV + (size_t)kc * ((size_t)Np * 32)
                           + lid * (SLM_B / KC / NTV), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLMB_BASE + buf * SLM_B + kc * (SLM_B / KC)
                        + lid * (SLM_B / KC / NTV), bv, esimd::overaligned_tag<16>{});
                }
#endif
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            int nb = (NBUF - 1 < kb_n) ? NBUF - 1 : kb_n;
            for (int p = 0; p < nb; ++p) load_block(p, p);   // prologue: depth NBUF-1
            esimd::barrier();
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % NBUF;
                int nx = b + NBUF - 1;
                if (nx < kb_n) load_block(nx % NBUF, nx);
                #pragma unroll
                for (int kc = 0; kc < KC; ++kc) {
                    uint32_t offA = (uint32_t)(cur * SLM_A) + (uint32_t)(packwi * (KC * PBAND))
                                  + (uint32_t)(kc * PBAND) + (uint32_t)(subrow * 32);
                    uint32_t offB = SLMB_BASE + (uint32_t)(cur * SLM_B)
                                  + (uint32_t)(kc * (BNV * 32)) + (uint32_t)(wi_col * BBAND);
                    a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                    if (RPT == 16)
                        a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                    b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                    if (CPT == 16)
                        b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                    if (CPT == 16) c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                    if (RPT == 16) c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                    if (RPT == 16 && CPT == 16) c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                }
                esimd::barrier();
            }
            // ---- store: the shipped tails VERBATIM (raw = gemm32_b's block_store pair,
            // pub = gemm_b_pub's cs/rs/acc-assembly/pub_vec_v8 chain), plus the BN>N cull.
            int gr = wg_row * BM + wi_row * RPT;
            int gc = wg_col * BNV + wi_col * CPT;
            bool live = (gc < N);            // padded-BN variants throw away whole bands
            if (!PUB) {
                if (live) {
                    // one dpas fragment row group = 8 rows; RPT==16 threads carry a
                    // SECOND group (c10/c11) at gr+8. (MODE1 threads have only 8 rows.)
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        if (CPT == 16) {
                            esimd::simd<int32_t, 16> row0;
                            row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                            row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                            esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                        } else {
                            esimd::simd<int32_t, 8> row0 = c00.select<8, 1>(r * 8);
                            esimd::block_store<int32_t, 8>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                        }
                        if (RPT == 16) {
                            if (CPT == 16) {
                                esimd::simd<int32_t, 16> row1;
                                row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                                row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
                            } else {
                                esimd::simd<int32_t, 8> row1 = c10.select<8, 1>(r * 8);
                                esimd::block_store<int32_t, 8>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
                            }
                        }
                    }
                }
            } else {
                if (live) {
                    const float* gas = as + (size_t)g * scale_stride;
                    const float* gbs = bs + (size_t)g * col_stride;
                    esimd::simd<float, CPT> cs = esimd::block_load<float, CPT>(
                        gbs + gc, esimd::overaligned_tag<16>{});
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        int rr0 = gr + r, rr1 = gr + 8 + r;
                        if (rr0 < M) {
                            float rs = gas[rr0];
                            esimd::simd<int32_t, CPT> acc(0);
                            acc.template select<8, 1>(0) = c00.template select<8, 1>(r * 8);
                            if (CPT == 16) acc.template select<8, 1>(8) = c01.template select<8, 1>(r * 8);
                            esimd::simd<float, CPT> pub = s8v8::pub_vec_v8<CPT>(
                                epi, esimd::convert<float>(acc) * rs * cs);
                            size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                            if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                            else        pub.copy_to((float*)Cout + out);
                        }
                        if (RPT == 16 && rr1 < M) {
                            float rs = gas[rr1];
                            esimd::simd<int32_t, CPT> acc(0);
                            acc.template select<8, 1>(0) = c10.template select<8, 1>(r * 8);
                            if (CPT == 16) acc.template select<8, 1>(8) = c11.template select<8, 1>(r * 8);
                            esimd::simd<float, CPT> pub = s8v8::pub_vec_v8<CPT>(
                                epi, esimd::convert<float>(acc) * rs * cs);
                            size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                            if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                            else        pub.copy_to((float*)Cout + out);
                        }
                    }
                }
            }
        });
    });
}
} // namespace g32v

// ---- host A pack for BK=64 (TRAP 3). Same as bench_s8v8_tile.cpp:249 -- BM=128, 8 wi
// bands x [kc0 16x32][kc1 16x32] per (w,kb). Rows >= M zero, mirroring gather_pack_a_b. ----
static void pack_a64_host(const int8_t* A, int8_t* Ap, int M, int Mp, int K, int batch,
                          int lda = 0, size_t sa = 0) {
    lda = lda ? lda : K;                                 // frame: lda = K*batch (wide row)
    int wgr = Mp / 128, kb_n = K / 64;
    size_t per = (size_t)Mp * K;
    for (int gg = 0; gg < batch; ++gg) {
        int8_t* dst = Ap + (size_t)gg * per;
        for (int w = 0; w < wgr; ++w)
            for (int kb = 0; kb < kb_n; ++kb)
                for (int wi = 0; wi < 8; ++wi)
                    for (int kc = 0; kc < 2; ++kc)
                        for (int row = 0; row < 16; ++row)
                            for (int k = 0; k < 32; ++k) {
                                int srow = w * 128 + wi * 16 + row;
                                dst[((size_t)(w * kb_n + kb) * 8 + wi) * 1024 + kc * 512 + row * 32 + k] =
                                    srow < M ? A[(size_t)gg * sa + (size_t)srow * lda + kb * 64 + kc * 32 + k] : (int8_t)0;
                            }
    }
}

static queue* GQ;

struct Ctx {
    int M, N, K, b, Mp;
    int8_t *dAp, *dAp64;              // A packs: BK32 (device) / BK64 (host)
    int8_t *dBp32, *dBp64, *dBp128;   // B packs at Np = 32 / 64 (pad) / 128 (pad)
    float  *das, *dbs;                // dbs padded to 128 cols (all 1.0)
    int32_t *dC32ref, *dC32v;
    half   *dCref, *dCv;
    std::vector<int32_t> h32ref, h32v;
    std::vector<half> h16ref, h16v;
};

// TIMING PROTOCOL (this file's answer to TRAP 6, validated by three processes per form):
// a single min-of-N is not stable here -- the per-rep distribution is ~1.4x wide and its
// SHAPE depends on how much GPU work the process has already asked for:
//   * short burst  -> the boost regime (the fast mode);
//   * 300-rep warm -> the sustained regime, THROTTLED (the same shipped kernel: min
//     0.0938 but a typical rep 0.13). So "warm up then take the min" does not remove the
//     lottery, it just moves where the reps land.
// Therefore: 1 untimed rep (module upload out of the way), then 5 groups x 15 timed reps
// with a 60 ms IDLE GAP between groups (TRAP 6b: without the gap the groups run in one
// sustained burst and the whole table drifts into the throttled regime; with it every
// group starts from the same clock/L2 state and the group-mins are comparable).
//   msm = best group-min, msM = MEDIAN of the five group-mins (the headline ranking),
//   msX = worst group-min (drift inside one process), med = median of all 75 reps
//   (the sustained regime -- shown because it can and does change the verdict).
// A variant whose msM beats the shipped row is a win only if its med does not lose badly;
// one that wins only on msm is a lucky burst.
struct Stat { double msm, msM, msX, med; size_t ng; std::vector<double> gms; };
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f().wait();                                       // untimed: first-launch module upload
    std::vector<double> gmin; gmin.reserve(groups);
    std::vector<double> all; all.reserve(groups * reps);
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event e = f(); e.wait();
            auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
            auto t0 = e.get_profiling_info<info::event_profiling::command_end>();
            double ms = (double)(t0 - s0) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    Stat st; st.ng = groups;
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size() / 2];
    st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size() / 2];
    st.gms = gmin;                                    // the five group-mins, sorted
    return st;
}

// the five group-mins, printed so the two regimes are visible per row (not hidden by the
// median): a row like [0.0700 0.0702 0.0709 0.1081 0.1086] is a genuine mode flip.
static const char* gmfmt(const Stat& st) {
    static char buf[128]; int o = 0;
    buf[o++] = '[';
    for (double v : st.gms) o += snprintf(buf + o, (size_t)(sizeof(buf) - o), " %.4f", v);
    buf[o++] = ']'; buf[o] = 0;
    return buf;
}

// BNBIG: BNV > N is only runnable padded; Np carries the pad.
template <int BNV, int BKV, int NTV, int NBUF, int MODE, bool PUB>
static void run_variant(Ctx& cx, const char* name, int forceNp = 0) {
    queue& q = *GQ;
    size_t n32 = (size_t)cx.b * cx.Mp * cx.N;
    if (cx.K % BKV) { printf("  %-22s %-4s  -- N/A (K%%%d) --\n", name, PUB ? "pub" : "raw", BKV); return; }
    // LEGALITY (TRAP 4): BNV>N is NOT a drop-in for the shipped launch (wg=(Mp/128)*(N/BN)
    // = 0 -> nothing is computed and the B tile would read past the pack). It is measured
    // here in the PADDED form -- B packed at Np=BNV with zero rows beyond N plus a store
    // cull -- so the redundancy it would cost is on the table, flagged ILLEGAL.
    if (BNV <= cx.N && cx.N % BNV) { printf("  %-22s %-4s  -- N/A (N%%%d) --\n", name, PUB ? "pub" : "raw", BNV); return; }
    int Np = (BNV > cx.N) ? BNV : cx.N;
    if (forceNp) Np = forceNp;              // TRAPDEMO: point a BNV tile at a wider pack
    const int8_t* Ap = (BKV == 32) ? cx.dAp : cx.dAp64;
    const int8_t* Bp = (Np == 32) ? cx.dBp32 : (Np == 64) ? cx.dBp64 : cx.dBp128;
    Stat st = timeit([&]() -> event {
        return PUB
            ? g32v::gemm32_var<BNV, BKV, NTV, NBUF, MODE, true>(q, Ap, Bp, nullptr, (void*)cx.dCv,
                  cx.das, cx.dbs, cx.M, cx.Mp, cx.N, Np, cx.K, cx.b, (size_t)cx.Mp * cx.N,
                  (unsigned)cx.N, 0u, 0u, true, 1u)
            : g32v::gemm32_var<BNV, BKV, NTV, NBUF, MODE, false>(q, Ap, Bp, cx.dC32v, nullptr,
                  cx.das, cx.dbs, cx.M, cx.Mp, cx.N, Np, cx.K, cx.b, (size_t)cx.Mp * cx.N,
                  (unsigned)cx.N, 0u, 0u, true, 1u);
    });
    size_t diff = 0;
    if (PUB) {
        q.memcpy(cx.h16v.data(), cx.dCv, n32 * 2).wait();
        for (size_t i = 0; i < n32; ++i)
            if (memcmp(&cx.h16ref[i], &cx.h16v[i], 2)) ++diff;
    } else {
        q.memcpy(cx.h32v.data(), cx.dC32v, n32 * 4).wait();
        for (size_t i = 0; i < n32; ++i)
            if (cx.h32ref[i] != cx.h32v[i]) ++diff;
    }
    // the kernel's OWN global load/store volume (what the 560 GB/s roof is measured on):
    //   A: Mp*K per group per col-tile;  B: (Mp/128) * BNV * K per group per col-tile
    //   (BNV>N padded => the pad is really read);  C: Mp*N * (2 pub / 4 raw), culled.
    int coltiles = (cx.N + BNV - 1) / BNV;
    double bytes = (double)cx.b * ((double)cx.Mp * cx.K * coltiles
                                 + (double)(cx.Mp / 128) * coltiles * BNV * cx.K
                                 + (double)cx.Mp * cx.N * (PUB ? 2 : 4));
    double gbsM = bytes / (st.msM / 1e3) / 1e9;
    double gbsm = bytes / (st.msm / 1e3) / 1e9;
    double gf   = 2.0 * cx.M * cx.N * cx.K * cx.b / (st.msM / 1e3) / 1e9;
    int slm = NBUF * (128 * BKV + BKV * BNV);
    double pad = (BNV > cx.N) ? (double)BNV / cx.N : 1.0;
    printf("  %-22s %-4s %-13s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  "
           "GB/s@M=%6.1f %5.1f%%  GB/s@min=%6.1f %5.1f%%  GF/s=%7.0f  diff=%zu SLM=%5.1fKB pad=%.2f  gm=%s\n",
           name, PUB ? "pub" : "raw", (BNV > cx.N) ? "ILLEGAL(pad)" : "legal",
           st.msM, st.msm, st.msX, st.med,
           gbsM, 100.0 * gbsM / 560.0, gbsm, 100.0 * gbsm / 560.0,
           gf, diff, slm / 1024.0, pad, gmfmt(st));
}

// ================= STEP 0 (刀 C gate): the pub leg on the FRAME'S REAL strides =================
// The contiguous sweep above writes C with ldc=N (each group its own block). The frame does NOT:
// plan_960x544.c lines 5345/5369/5391/5413/6541/6563/6585/6607 (M=32640 N=32 K=128 b=2) and
// 5438/5460/5482/5504/5526/5548/6407/6429/6451/6473/6495/6517 (M=8160 N=32 K=128 b=4) all carry
//   sa=128(=K)  sb=4096(=N*K)  sc=32(=N)  lda=K*batch  ldb=128(=K)  ldc=N*batch  ss=0  flags=0x1100 (epi1, narrow)
// i.e. the A face is ONE row-interleaved wide row (lda=256/512, group stride sa=128), every group
// has its OWN weight block (sb=N*K, not the shared sb=0 of the sweep above), and the published f16
// face is the WIDE row: out = g*sc + r*ldc + col -> each group writes a 32-half (64 B) run into a
// 128/256-byte row, i.e. 64B PARTIAL-LINE stores. col_stride = N because sb != 0 (recorder :2674).
// This phase re-prices (a) shipped gemm32_b, (b) the recorder's separate publish with that map,
// and (c) the fused pub forms with that map, in ONE process, and diffs (c) against (a)+(b)
// byte-for-byte over the written region. 刀 C is only allowed if (c) < (a)+(b) here.
struct FrameCtx {
    int M, N, K, b, Mp, lda, sa, sb, sc, ldc;
    size_t out_ext;
    int8_t *dAp, *dAp64, *dBp;
    float  *das, *dbs;
    int32_t* dC32;
    half   *dOutRef, *dOutV;
    std::vector<half> hRef, hV;
};

static size_t fbytes_written(const FrameCtx& fc) { return (size_t)fc.b * fc.M * fc.N; }
static double fr_result = 0.0;      // out-param: the last frame_pub's msM (for the GATE line)

template <int BNV, int BKV, int NTV, int NBUF, int MODE>
static void frame_pub(FrameCtx& fc, const char* name) {
    queue& q = *GQ;
    const int8_t* Ap = (BKV == 32) ? fc.dAp : fc.dAp64;
    Stat st = timeit([&]() {
        return g32v::gemm32_var<BNV, BKV, NTV, NBUF, MODE, true>(q, Ap, fc.dBp, nullptr, (void*)fc.dOutV,
            fc.das, fc.dbs, fc.M, fc.Mp, fc.N, fc.N, fc.K, fc.b, (size_t)fc.sc, (unsigned)fc.ldc,
            0u, (unsigned)fc.N, true, 1u);
    });
    q.memcpy(fc.hV.data(), fc.dOutV, fc.out_ext * 2).wait();
    size_t diff = 0, cmp = 0;
    for (int g = 0; g < fc.b; ++g)
        for (int r = 0; r < fc.M; ++r)
            for (int c2 = 0; c2 < fc.N; ++c2) {
                size_t i = (size_t)g * fc.sc + (size_t)r * fc.ldc + c2;
                ++cmp; if (memcmp(&fc.hRef[i], &fc.hV[i], 2)) ++diff;
            }
    double bytes = (double)fc.b * ((double)fc.Mp * fc.K + (double)(fc.Mp / 128) * BNV * fc.K)
                 + (double)fbytes_written(fc) * 2.0;
    double gbs = bytes / (st.msM / 1e3) / 1e9;
    printf("  %-22s pub  msM=%7.4f msm=%7.4f msX=%7.4f  GB/s=%6.1f %5.1f%%  cmp=%zu diff=%zu SLM=%5.1fKB  gm=%s\n",
           name, st.msM, st.msm, st.msX, gbs, 100.0 * gbs / 560.0, cmp, diff,
           NBUF * (128 * BKV + BKV * BNV) / 1024.0, gmfmt(st));
    fr_result = st.msM;
}

static void frame_phase(int M, int N, int K, int b, int perframe, const std::vector<int8_t>& A,
                        const std::vector<int8_t>& B, const std::vector<float>& as1) {
    queue& q = *GQ;
    FrameCtx fc; fc.M = M; fc.N = N; fc.K = K; fc.b = b;
    fc.Mp = ((M + 127) / 128) * 128;
    fc.lda = K * b; fc.sa = K; fc.sb = N * K; fc.sc = N; fc.ldc = N * b;
    fc.out_ext = (size_t)(M - 1) * fc.ldc + (size_t)(b - 1) * fc.sc + N + 1;
    printf("\n== FRAME-STRIDE phase (M=%d N=%d K=%d b=%d) lda=%d sa=%d sb=%d sc=%d ldc=%d col_stride=%d epi1 "
           "[x%d calls/frame] ==\n", M, N, K, b, fc.lda, fc.sa, fc.sb, fc.sc, fc.ldc, fc.N, perframe);
    // raw A = M rows x (K*b) INTERLEAVED (frame lda/sa); raw B = b blocks of N x K (frame sb).
    std::vector<int8_t> Ar((size_t)(M - 1) * fc.lda + (size_t)(b - 1) * fc.sa + K, 0);
    for (int g = 0; g < b; ++g)
        for (int r = 0; r < M; ++r)
            memcpy(&Ar[(size_t)r * fc.lda + (size_t)g * fc.sa], &A[(size_t)r * K], K);
    std::vector<int8_t> Br((size_t)b * N * K);
    for (int g = 0; g < b; ++g) memcpy(&Br[(size_t)g * N * K], B.data(), (size_t)N * K);
    std::vector<float> bs((size_t)b * N, 1.f);
    fc.dAp   = (int8_t*)malloc_device((size_t)b * fc.Mp * K, q);
    fc.dAp64 = (int8_t*)malloc_device((size_t)b * fc.Mp * K, q);
    fc.dBp   = (int8_t*)malloc_device((size_t)b * N * K, q);
    fc.das   = (float*)malloc_device((size_t)fc.Mp * 4, q);
    fc.dbs   = (float*)malloc_device(bs.size() * 4, q);
    fc.dC32  = (int32_t*)malloc_device((size_t)b * fc.Mp * N * 4, q);
    fc.dOutRef = (half*)malloc_device(fc.out_ext * 2, q);
    fc.dOutV   = (half*)malloc_device(fc.out_ext * 2, q);
    q.memset(fc.dC32, 0, (size_t)b * fc.Mp * N * 4);
    q.memset(fc.dOutRef, 0, fc.out_ext * 2); q.memset(fc.dOutV, 0, fc.out_ext * 2);
    int8_t* dA = (int8_t*)malloc_device(Ar.size(), q);
    int8_t* dB = (int8_t*)malloc_device(Br.size(), q);
    q.memcpy(dA, Ar.data(), Ar.size()).wait();
    q.memcpy(dB, Br.data(), Br.size()).wait();
    q.memcpy(fc.das, as1.data(), (size_t)fc.Mp * 4).wait();
    q.memcpy(fc.dbs, bs.data(), bs.size() * 4).wait();
    packdev::gather_pack_a_b(q, dA, fc.dAp, M, fc.Mp, K, fc.lda, fc.sa, b);
    packdev::gather_pack_b_b(q, dB, fc.dBp, N, K, K, (size_t)N * K, b);
    {
        std::vector<int8_t> Ap64((size_t)b * fc.Mp * K);
        pack_a64_host(Ar.data(), Ap64.data(), M, fc.Mp, K, b, fc.lda, fc.sa);
        q.memcpy(fc.dAp64, Ap64.data(), Ap64.size()).wait();
    }
    q.wait();
    // (a) shipped gemm32_b on the frame-packed operands
    s8v8::gemm32_b(q, fc.dAp, fc.dBp, fc.dC32, fc.Mp, N, K, b).wait();
    Stat stg = timeit([&]() { return s8v8::gemm32_b(q, fc.dAp, fc.dBp, fc.dC32, fc.Mp, N, K, b); });
    // (b) the recorder's separate publish, map VERBATIM from libxmx_sycl.cpp:2682-2693
    int32_t* C32 = fc.dC32; float* as = fc.das; float* bs2 = fc.dbs; half* OC = fc.dOutRef;
    int Mp = fc.Mp, ldc = fc.ldc, sc = fc.sc;
    Stat stp = timeit([&]() -> event {
        return q.parallel_for(range((size_t)b * M * N), [=](item<1> it) {
            size_t i = it.get_id(0); unsigned mn = (unsigned)M * N;
            unsigned g = (unsigned)(i / mn); size_t rem = i % mn;
            unsigned r = (unsigned)(rem / N), col = (unsigned)(rem % N);
            float* gas = as + (size_t)g * 0u;                       // scale_stride = 0 (plan ss=0)
            float* gbs = bs2 + (size_t)g * N;                       // sb != 0 -> col_stride = N
            float v = cr_mul(cr_mul((float)C32[(size_t)g * Mp * N + (size_t)r * N + col], gas[r]), gbs[col]);
            size_t out = (size_t)g * sc + (size_t)r * ldc + col;
            ((half*)OC)[out] = sycl::half(qr_publish(1u, v));
        });
    });
    fc.hRef.resize(fc.out_ext); fc.hV.resize(fc.out_ext);
    q.memcpy(fc.hRef.data(), fc.dOutRef, fc.out_ext * 2).wait();     // the reference the fused forms must hit
    double gbsG = (double)b * ((double)fc.Mp * K + (double)(fc.Mp / 128) * N * K
                             + (double)fc.Mp * N * 4) / (stg.msM / 1e3) / 1e9;
    double bytesX = (double)b * M * N * 6.0;
    printf("  %-22s raw  msM=%7.4f msm=%7.4f msX=%7.4f  GB/s=%6.1f %5.1f%%  (shipped gemm32_b, frame packs)\n",
           "shipped gemm32_b", stg.msM, stg.msm, stg.msX, gbsG, 100.0 * gbsG / 560.0);
    printf("  %-22s pub  msM=%7.4f msm=%7.4f msX=%7.4f  GB/s=%6.1f %5.1f%%  (recorder separate publish)\n",
           "split publish", stp.msM, stp.msm, stp.msX, bytesX / (stp.msM / 1e3) / 1e9,
           100.0 * (bytesX / (stp.msM / 1e3) / 1e9) / 560.0);
    printf("  %-22s SPLIT TOTAL msM=%7.4f msm=%7.4f  <-- 刀 C must beat this\n", "gemm+publish",
           stg.msM + stp.msM, stg.msm + stp.msm);
    // (c) the fused forms on the frame map
    double wide_msM = 0.0;
    // THE PATH THE FRAME ACTUALLY RUNS (found while probing the recorder, 2026-11-01):
    // libxmx_sycl.cpp:2478-2503 P8-b wide-merge (DEFAULT ON, escape NR_B_WIDE=0) folds the
    // b groups into ONE wide gemm -- Nw=N*b, Kw=K*b, block-diagonal B, and the FUSED
    // gemm_b_pub publish. All 20 frame N=32 sites hit it (verified by substituting the plan
    // tuples into wide_ok: 20/20). So the split chain priced above is dead code on the frame
    // (reachable only under NR_B_WIDE=0), and the real comparison for 刀 C' is THIS row vs
    // the BN32 fused rows below. Cost structure of the wide form: the block-diagonal B holds
    // only 1/b non-zero, and every row band re-reads Nw*Kw => B traffic = (Mp/128)*Nw*Kw =
    // 4.08 MB (A) / 4.19 MB (B) vs 1.04 / 1.05 MB for the BN32 family -- 4x the B traffic.
    {
        const int Nw = fc.N * fc.b, Kw = fc.K * fc.b;
        int8_t* dApW = (int8_t*)malloc_device((size_t)fc.Mp * Kw, q);
        int8_t* dBpW = (int8_t*)malloc_device((size_t)Nw * Kw, q);
        packdev::gather_pack_a_b_v(q, dA, dApW, fc.M, fc.Mp, Kw, Kw, 0, 1);
        packdev::gather_pack_b_diag_b(q, dB, dBpW, fc.N, fc.K, fc.K, (size_t)fc.N * fc.K, fc.b);
        q.wait();
        Stat sw = timeit([&]() {
            return s8v8::gemm_b_pub(q, dApW, dBpW, (void*)fc.dOutV, fc.das, fc.dbs, fc.M, fc.Mp,
                Nw, Kw, 1, (size_t)0, (unsigned)Nw, 0u, 0u, true, 1u);
        });
        q.memcpy(fc.hV.data(), fc.dOutV, fc.out_ext * 2).wait();
        size_t diff = 0, cmp = 0;
        for (int g = 0; g < fc.b; ++g)
            for (int r = 0; r < fc.M; ++r)
                for (int c2 = 0; c2 < fc.N; ++c2) {
                    size_t i = (size_t)g * fc.sc + (size_t)r * fc.ldc + c2;
                    ++cmp; if (memcmp(&fc.hRef[i], &fc.hV[i], 2)) ++diff;
                }
        double bytesW = (double)fc.Mp * Kw + (double)(fc.Mp / 128) * Nw * Kw + (double)fc.b * fc.M * fc.N * 2.0;
        double gbsW = bytesW / (sw.msM / 1e3) / 1e9;
        printf("  %-22s pub  msM=%7.4f msm=%7.4f msX=%7.4f  GB/s=%6.1f %5.1f%%  cmp=%zu diff=%zu SLM= 18.0KB  gm=%s\n",
               "WIDE gemm_b_pub", sw.msM, sw.msm, sw.msX, gbsW, 100.0 * gbsW / 560.0, cmp, diff, gmfmt(sw));
        wide_msM = sw.msM;
        free(dApW, q); free(dBpW, q);
    }
    // FIRST: STEP 1 verification -- the kernel that now lives in gemm_s8_v8_kernel.hpp
    // (s8v8::gemm32_b_pub, moved verbatim from g32v::gemm32_var<32,32,32,2,1,true> below)
    // must be byte-identical to the bench template AND price the same. If this row is red
    // the shipped header drifted from the verified form -- stop, do not touch the recorder.
    {
        Stat sh = timeit([&]() {
            return s8v8::gemm32_b_pub(q, fc.dAp, fc.dBp, (void*)fc.dOutV, fc.das, fc.dbs,
                fc.M, fc.Mp, fc.N, fc.K, fc.b, (size_t)fc.sc, (unsigned)fc.ldc, 0u,
                (unsigned)fc.N, true, 1u);
        });
        q.memcpy(fc.hV.data(), fc.dOutV, fc.out_ext * 2).wait();
        size_t diff = 0, cmp = 0;
        for (int g = 0; g < fc.b; ++g)
            for (int r = 0; r < fc.M; ++r)
                for (int c2 = 0; c2 < fc.N; ++c2) {
                    size_t i = (size_t)g * fc.sc + (size_t)r * fc.ldc + c2;
                    ++cmp; if (memcmp(&fc.hRef[i], &fc.hV[i], 2)) ++diff;
                }
        double bytes = (double)fc.b * ((double)fc.Mp * fc.K + (double)(fc.Mp / 128) * fc.N * fc.K)
                     + (double)fbytes_written(fc) * 2.0;
        double gbs = bytes / (sh.msM / 1e3) / 1e9;
        printf("  %-22s pub  msM=%7.4f msm=%7.4f msX=%7.4f  GB/s=%6.1f %5.1f%%  cmp=%zu diff=%zu SLM= 10.0KB  gm=%s\n",
               "HEADER gemm32_b_pub", sh.msM, sh.msm, sh.msX, gbs, 100.0 * gbs / 560.0, cmp, diff, gmfmt(sh));
        fr_result = sh.msM;
    }
    double a0 = fr_result;
    frame_pub<32, 32, 16, 3, 0>(fc, "anchor32 pub");       double a1 = fr_result;
    frame_pub<32, 32, 32, 2, 1>(fc, "nt32_hr_buf2 pub");   double a2 = fr_result;
    frame_pub<32, 32, 32, 2, 2>(fc, "nt32_hc_buf2 pub");   double a3 = fr_result;
    frame_pub<32, 32, 16, 2, 0>(fc, "bn32_buf2 pub");      double a4 = fr_result;
    frame_pub<32, 64, 32, 2, 1>(fc, "bk64_hr_buf2 pub");   double a5 = fr_result;
    frame_pub<32, 64, 16, 3, 0>(fc, "bk64_nt16 pub");      double a6 = fr_result;
    double best = std::min(std::min(a0, a1), std::min(std::min(a2, a3), std::min(a4, std::min(a5, a6))));
    if (wide_msM > 0.0)
        printf("  刀 C' COMPARISON (bench-layer, DESCRIPTIVE ONLY -- the frame judge is the 16-pair A/B):"
               " wide %7.4f vs BN32-fused %7.4f -> %+.4f/call; x%d = %+6.2f ms/frame SERIAL\n",
               wide_msM, a0, a0 - wide_msM, perframe, (a0 - wide_msM) * perframe);
    printf("  GATE: best fused %7.4f vs split total %7.4f -> %s (per-call delta %+7.4f; x%d = %+6.2f ms/frame serial)\n",
           best, stg.msM + stp.msM, (best < 0.9 * (stg.msM + stp.msM)) ? "PASS -- proceed to step 1"
           : (best < stg.msM + stp.msM ? "MARGINAL -- report before writing shipped code" : "FAIL -- STOP"),
           best - (stg.msM + stp.msM), perframe, (best - (stg.msM + stp.msM)) * perframe);
    free(dA, q); free(dB, q);
    free(fc.dAp, q); free(fc.dAp64, q); free(fc.dBp, q); free(fc.das, q); free(fc.dbs, q);
    free(fc.dC32, q); free(fc.dOutRef, q); free(fc.dOutV, q);
}

int main() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 1; }
    queue q(dev, property::queue::enable_profiling{});
    GQ = &q;
    printf("device: %s\n", dev.get_info<info::device::name>().c_str());
    printf("pub leg: epi=1 narrow=f16 (the frame's N=32 plan); scales all 1.0\n");

    struct Cfg { int M, N, K, b, perframe; };
    // perframe = calls/frame in the CAPTURED graph only (plan lines 5308..6643) -- the
    // x16/x24 figure inherited from bench_n32.cpp:2 double-counts the aborted recording
    // (TRAP 9 in this file's header). Re-counted: 8 and 12.
    std::vector<Cfg> cfgs = { {32640, 32, 128, 2, 8}, {8160, 32, 128, 4, 12} };
    for (auto cf : cfgs) {
        Ctx cx; cx.M = cf.M; cx.N = cf.N; cx.K = cf.K; cx.b = cf.b;
        cx.Mp = ((cx.M + 127) / 128) * 128;
        size_t nA = (size_t)cx.M * cx.K, nB = (size_t)cx.N * cx.K;
        size_t nAp = (size_t)cx.b * cx.Mp * cx.K, n32 = (size_t)cx.b * cx.Mp * cx.N;
        std::vector<int8_t> A(nA), B(nB), Ap64(nAp);
        std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127, 127);
        for (auto& x : A) x = (int8_t)da(rng);
        for (auto& x : B) x = (int8_t)da(rng);
        std::vector<float> as((size_t)cx.Mp, 1.f), bs(128, 1.f);
        cx.dAp   = (int8_t*)malloc_device(nAp, q);
        cx.dAp64 = (int8_t*)malloc_device(nAp, q);
        cx.dBp32 = (int8_t*)malloc_device((size_t)cx.b * 32 * cx.K, q);
        cx.dBp64 = (int8_t*)malloc_device((size_t)cx.b * 64 * cx.K, q);
        cx.dBp128= (int8_t*)malloc_device((size_t)cx.b * 128 * cx.K, q);
        cx.das   = (float*)malloc_device(as.size() * 4, q);
        cx.dbs   = (float*)malloc_device(bs.size() * 4, q);
        cx.dC32ref = (int32_t*)malloc_device(n32 * 4, q);
        cx.dC32v   = (int32_t*)malloc_device(n32 * 4, q);
        cx.dCref = (half*)malloc_device(n32 * 2, q);
        cx.dCv   = (half*)malloc_device(n32 * 2, q);
        q.memset(cx.dC32ref, 0, n32 * 4); q.memset(cx.dC32v, 0, n32 * 4);
        q.memset(cx.dCref, 0, n32 * 2);   q.memset(cx.dCv, 0, n32 * 2);
        int8_t* dA = (int8_t*)malloc_device(nA, q);
        int8_t* dB = (int8_t*)malloc_device(nB, q);
        q.memcpy(dA, A.data(), nA).wait();
        q.memcpy(dB, B.data(), nB).wait();
        q.memcpy(cx.das, as.data(), as.size() * 4).wait();
        q.memcpy(cx.dbs, bs.data(), bs.size() * 4).wait();
        packdev::gather_pack_a_b(q, dA, cx.dAp, cx.M, cx.Mp, cx.K, cx.K, 0, cx.b);
        // B packs: real N, plus the padded twins (rows N..Np-1 zero => the pad bands
        // compute zeros and the kernel throws them away; nothing else changes).
        // sb=0 == the frame's batched form: the weight is ONE cache-owned block that
        // every group's pack copies read (same discipline as bench_s8v8_tile.cpp).
        packdev::gather_pack_b_b(q, dB, cx.dBp32, cx.N, cx.K, cx.K, 0, cx.b);
        for (int Np : { 64, 128 }) {
            std::vector<int8_t> Bp_raw((size_t)Np * cx.K, 0);
            memcpy(Bp_raw.data(), B.data(), nB);
            int8_t* dBr = (int8_t*)malloc_device(Bp_raw.size(), q);
            q.memcpy(dBr, Bp_raw.data(), Bp_raw.size()).wait();
            int8_t* dst = (Np == 64) ? cx.dBp64 : cx.dBp128;
            packdev::gather_pack_b_b(q, dBr, dst, Np, cx.K, cx.K, 0, cx.b);
            q.wait(); free(dBr, q);
        }
        pack_a64_host(A.data(), Ap64.data(), cx.M, cx.Mp, cx.K, cx.b);
        q.memcpy(cx.dAp64, Ap64.data(), nAp).wait();
        q.wait();

        // ---- shipped baseline: capture the RAW reference, then time it ----
        s8v8::gemm32_b(q, cx.dAp, cx.dBp32, cx.dC32ref, cx.Mp, cx.N, cx.K, cx.b).wait();
        Stat stb = timeit([&]() { return s8v8::gemm32_b(q, cx.dAp, cx.dBp32, cx.dC32ref, cx.Mp, cx.N, cx.K, cx.b); });
        // ---- the PUB reference = this file's fork at the shipped geometry (TRAP 5) ----
        g32v::gemm32_var<32, 32, 16, 3, 0, true>(q, cx.dAp, cx.dBp32, nullptr, (void*)cx.dCref,
              cx.das, cx.dbs, cx.M, cx.Mp, cx.N, cx.N, cx.K, cx.b, (size_t)cx.Mp * cx.N,
              (unsigned)cx.N, 0u, 0u, true, 1u).wait();
        cx.h32ref.resize(n32); cx.h32v.resize(n32);
        cx.h16ref.resize(n32); cx.h16v.resize(n32);
        q.memcpy(cx.h32ref.data(), cx.dC32ref, n32 * 4).wait();
        q.memcpy(cx.h16ref.data(), cx.dCref, n32 * 2).wait();
        {
            double bytesR = (double)cx.b * ((double)cx.Mp * cx.K + (double)(cx.Mp / 128) * cx.N * cx.K
                                          + (double)cx.Mp * cx.N * 4);
            double gbsM = bytesR / (stb.msM / 1e3) / 1e9;
            double gbsm = bytesR / (stb.msm / 1e3) / 1e9;
            printf("\n== shape (M=%d N=%d K=%d b=%d) Mp=%d wg(BN32)=%d  [x%d calls/frame] ==\n",
                   cx.M, cx.N, cx.K, cx.b, cx.Mp, (cx.Mp / 128) * (cx.N / 32), cf.perframe);
            printf("  %-22s %-4s %-13s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  "
                   "GB/s@M=%6.1f %5.1f%%  GB/s@min=%6.1f %5.1f%%  GF/s=%7.0f  diff=0(ref) SLM= 15.0KB pad=1.00  gm=%s\n",
                   "shipped gemm32_b", "raw", "legal",
                   stb.msM, stb.msm, stb.msX, stb.med,
                   gbsM, 100.0 * gbsM / 560.0, gbsm, 100.0 * gbsm / 560.0,
                   2.0 * cx.M * cx.N * cx.K * cx.b / (stb.msM / 1e3) / 1e9, gmfmt(stb));
        }

        // ---- the sweep ----
#define VLIST(X) \
        X(32,  32, 16, 3, 0, anchor32)        \
        X(32,  32, 16, 2, 0, bn32_buf2)       \
        X(32,  32, 16, 4, 0, bn32_buf4)       \
        X(32,  32, 32, 3, 1, nt32_halfrow)    \
        X(32,  32, 32, 2, 1, nt32_hr_buf2)    \
        X(32,  32, 32, 3, 2, nt32_halfcol)    \
        X(32,  32, 32, 2, 2, nt32_hc_buf2)    \
        X(32,  64, 16, 3, 0, bk64_nt16)       \
        X(32,  64, 16, 2, 0, bk64_nt16_buf2)  \
        X(32,  64, 32, 3, 1, bk64_nt32hr)     \
        X(32,  64, 32, 2, 1, bk64_hr_buf2)    \
        X(32,  64, 32, 3, 2, bk64_nt32hc)     \
        X(64,  32, 32, 3, 0, bn64pad)        \
        X(64,  32, 32, 2, 0, bn64pad_buf2)   \
        X(64,  64, 32, 2, 0, bn64pad_bk64)   \
        X(128, 32, 64, 3, 0, bn128pad)       \
        X(128, 32, 64, 2, 0, bn128pad_buf2)
#define VPUB(BNV, BKV, NTV, NBUF, MODE, NM) do { \
        run_variant<BNV, BKV, NTV, NBUF, MODE, false>(cx, #NM); \
        run_variant<BNV, BKV, NTV, NBUF, MODE, true>(cx, #NM); } while (0);
        VLIST(VPUB);
#undef VPUB
#undef VLIST

        // TRAPDEMO (TRAP 2): the BN32/BK64 kernel pointed at the Np=64 B pack, so the two
        // kk32 blocks it needs are 64*32 bytes apart in global -- BNV < Np, the case where
        // the per-kc copy is MANDATORY. Compiled per-kc: diff=0. Built with
        // -DG32_BCOPY_NAIVE: diff != 0 (and every BNV==Np row above still reads diff=0,
        // which is why the N=32 family never tripped on this on its own).
        run_variant<32, 64, 16, 3, 0, false>(cx, "TRAPDEMO BN32_np64", 64);

        // ---- REPRISE: the shipped raw row AND the shipped-geometry pub row re-timed
        // AFTER the sweep, so both anchors sit in the same ambient state as the variants. ----
        {
            Stat st2 = timeit([&]() { return s8v8::gemm32_b(q, cx.dAp, cx.dBp32, cx.dC32ref, cx.Mp, cx.N, cx.K, cx.b); });
            Stat st3 = timeit([&]() {
                return g32v::gemm32_var<32, 32, 16, 3, 0, true>(q, cx.dAp, cx.dBp32, nullptr, (void*)cx.dCv,
                    cx.das, cx.dbs, cx.M, cx.Mp, cx.N, cx.N, cx.K, cx.b, (size_t)cx.Mp * cx.N,
                    (unsigned)cx.N, 0u, 0u, true, 1u); });
            double bytesR = (double)cx.b * ((double)cx.Mp * cx.K + (double)(cx.Mp / 128) * cx.N * cx.K
                                          + (double)cx.Mp * cx.N * 4);
            double bytesP = bytesR - (double)cx.b * cx.Mp * cx.N * 2;
            printf("  %-22s %-4s %-13s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  "
                   "GB/s@M=%6.1f %5.1f%%  GB/s@min=%6.1f %5.1f%%  GF/s=%7.0f  diff=0(ref) SLM= 15.0KB pad=1.00  gm=%s\n",
                   "shipped REPRISE", "raw", "legal", st2.msM, st2.msm, st2.msX, st2.med,
                   bytesR / (st2.msM / 1e3) / 1e9, 100.0 * (bytesR / (st2.msM / 1e3) / 1e9) / 560.0,
                   bytesR / (st2.msm / 1e3) / 1e9, 100.0 * (bytesR / (st2.msm / 1e3) / 1e9) / 560.0,
                   2.0 * cx.M * cx.N * cx.K * cx.b / (st2.msM / 1e3) / 1e9, gmfmt(st2));
            printf("  %-22s %-4s %-13s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  "
                   "GB/s@M=%6.1f %5.1f%%  GB/s@min=%6.1f %5.1f%%  GF/s=%7.0f  diff=%zu SLM= 15.0KB pad=1.00  gm=%s\n",
                   "anchor32 REPRISE", "pub", "legal", st3.msM, st3.msm, st3.msX, st3.med,
                   bytesP / (st3.msM / 1e3) / 1e9, 100.0 * (bytesP / (st3.msM / 1e3) / 1e9) / 560.0,
                   bytesP / (st3.msm / 1e3) / 1e9, 100.0 * (bytesP / (st3.msm / 1e3) / 1e9) / 560.0,
                   2.0 * cx.M * cx.N * cx.K * cx.b / (st3.msM / 1e3) / 1e9, [&]() -> size_t {
                       q.memcpy(cx.h16v.data(), cx.dCv, n32 * 2).wait();
                       size_t dd = 0;
                       for (size_t i = 0; i < n32; ++i) if (memcmp(&cx.h16ref[i], &cx.h16v[i], 2)) ++dd;
                       return dd; }(), gmfmt(st3));

            // ---- the OTHER half of the shipped N=32 path, VERBATIM from the recorder
            // (libxmx_sycl.cpp:2682-2693): a separate elementwise publish over b*M*N,
            // epi1 + narrow (the frame's setting). Without this row the fused-pub forms
            // cannot be compared against what the frame actually pays today. ----
            int M = cx.M, N = cx.N, Mp = cx.Mp, bb = cx.b;
            int32_t* C32p = cx.dC32ref; float* asp = cx.das; float* bsp = cx.dbs; half* ocp = cx.dCv;
            Stat stx = timeit([&]() -> event {
                return q.parallel_for(range((size_t)bb * M * N), [=](item<1> it) {
                    size_t i = it.get_id(0); unsigned mn = (unsigned)M * N;
                    unsigned g = (unsigned)(i / mn); size_t rem = i % mn;
                    unsigned r = (unsigned)(rem / N), col = (unsigned)(rem % N);
                    float v = cr_mul(cr_mul((float)C32p[(size_t)g * Mp * N + (size_t)r * N + col], asp[r]), bsp[col]);
                    ((half*)ocp)[(size_t)g * Mp * N + (size_t)r * N + col] = sycl::half(qr_publish(1u, v));
                });
            });
            double bytesX = (double)cx.b * cx.M * cx.N * 6.0;      // int32 read + f16 write
            printf("  %-22s %-4s %-13s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  "
                   "GB/s@M=%6.1f %5.1f%%  GB/s@min=%6.1f %5.1f%%  GF/s=%7.0f  diff=0(ref) SLM=  0.0KB pad=1.00  gm=%s\n",
                   "split publish", "pub", "recorder", stx.msM, stx.msm, stx.msX, stx.med,
                   bytesX / (stx.msM / 1e3) / 1e9, 100.0 * (bytesX / (stx.msM / 1e3) / 1e9) / 560.0,
                   bytesX / (stx.msm / 1e3) / 1e9, 100.0 * (bytesX / (stx.msm / 1e3) / 1e9) / 560.0,
                   0.0, gmfmt(stx));
            printf("  %-22s raw+pub SPLIT total msM=%7.4f  msm=%7.4f  (what the frame pays today)\n",
                   "SPLIT TOTAL", stb.msM + stx.msM, stb.msm + stx.msm);
        }

        // ---- STEP 0 (the 刀 C gate): the same forms on the FRAME'S real strides ----
        frame_phase(cf.M, cf.N, cf.K, cf.b, cf.perframe, A, B, as);

        free(dA, q); free(dB, q);
        free(cx.dAp, q); free(cx.dAp64, q);
        free(cx.dBp32, q); free(cx.dBp64, q); free(cx.dBp128, q);
        free(cx.das, q); free(cx.dbs, q);
        free(cx.dC32ref, q); free(cx.dC32v, q); free(cx.dCref, q); free(cx.dCv, q);
    }
    return 0;
}
