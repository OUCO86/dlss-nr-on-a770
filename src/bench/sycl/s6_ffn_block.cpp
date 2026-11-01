// s6_ffn_block.cpp -- S6-1a stage 1: the C=64 FFN closure chain, 6 recorder ops
// (shipped: 8 real launches) vs ONE block-resident ESIMD kernel, byte-exact.
// Chain = plan_960x544.c:5337-5349 (M=32640 C=64):
//   QUANT(1270,K=64) -> BATCHED(expand 128,K=64,b2,epi3) -> QUANT(1274,K=256)
//   -> BATCHED(proj 32,128,b2 -> WIDE-merge Nw=64,Kw=256,epi1) -> QUANT(1275,K=64)
//   -> GEMM_INT8_RESIDUAL(->1267, skip=1270 half, cos=73, epi1)
// The RESIDUAL's quant fold is DEFAULT ON (qfuse_take, libxmx_sycl.cpp:304/3092): op5
// dissolves into pack_a_fused. The BATCHED folds are DEFAULT OFF (NR_Q_FUSE_B opt-in,
// :384): ops 1/3 run for real. So the control leg issues the recorder's REAL sequence:
//   quant1, pack_a_v, gemm_b_pub_slm<false>, quant3, pack_a_v(wide), gemm_b_pub(wide),
//   pack_a_fused(=op5 dissolved), gemm_b_res.            (8 launches)
// Weight packs are cache-owned (g_wcache in the recorder): done once at setup, NOT timed.
//
// FUSED LEG (experiment): one WG owns T=32 tokens x C=64 (parent's 07:33 SLM math,
// NOT the 48KB estimate in notes SS16): peak live SLM =
//   pkH 8K + pk(A/O) 2K + hid 16K + out 4K + sc 0.4K = 30.4KB (32KB bucket).
//   B tiles are read global->GRF (L2-hot weights) -- no SLM staging in stage 1;
//   if that is the loser, the next shape is SLM double-buffered B (8-12KB, fits).
// LW=64 (SS96 safe zone), grid = M/32 = 1020 WG => WIDE M lives in the GRID dim
// (military rule 1: no small-M dispatch). pk/sc NEVER touch global in the timed form
// (DUMP=true instantiation exists only for the diff pass; the timed launch is DUMP=false).
// Numerics VERBATIM: row peak AFTER f16 rounding (intermediate planes stored f16 in SLM
// and read back as f16); quant chain = qr_kernel_rowthread (div_ieee peak/127,
// div_ieee v/scale, rnde, clip +-127); pub = convert<float>(acc)*rs*cs -> pub_vec_v8
// (epi3 gate+e4m3 / epi1 e4m3) -> f16; residual tail = ELEMENTWISE scalar
// sk*cos + stage (auto-FMA, one rounding -- simd muladd is frame-0%, :936 lesson).
//
// TIMING (gemm32_tile.cpp TRAP 1-9 protocol, :366-408): 1 untimed rep (module upload),
// then 5 groups x 15 timed reps with a 60 ms IDLE GAP between groups. Chain and fused
// totals are timed HOST-WALL (launch overhead is part of what fusion kills; same
// process, same protocol; TRAP 6: short bursts boost, long warm-ups throttle). msm /
// msM (median of group-mins, headline) / msX (worst group-min) / med (median of 75).
// Build+run: cd src/bench/sycl && bash E:/DSH/bench.sh s6_ffn_block.cpp s6_ffn_block.exe
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
#include "gemm_s8_v8_kernel.hpp"   // shipped: gemm_b_pub / gemm_b_pub_slm / gemm_b_res / pub_vec_v8
#include "pack_device.hpp"         // gather_pack_a_b_v / gather_pack_b_b / gather_pack_b_diag_b / pack_b / pack_a_fused
#include "quantize_row_kernel.hpp" // qr_launch_esimd (the frame's quant path)
using namespace sycl;

// ============================ the fused block kernel ============================
namespace ffnblk {
static const int T = 32;        // tokens per WG (parent 07:33: T=64 busts the 64KB cap)
static const int C = 64;        // block channels (in/out)
static const int HID = 256;     // FFN hidden (2 groups x 128, interleaved wide rows)
static const int NT = 64;       // threads per WG (LW=64, SS96 safe zone)
// SLM byte map (total 31104 -> 32KB bucket):
static const uint32_t SLM_PKH  = 0;       // pk(hidden) 8192: (kb*2+wi)*512 + r16*32 + k
static const uint32_t SLM_PK   = 8192;    // pk(in) then pk(out) 2048: same map, kb<2
static const uint32_t SLM_HID  = 10240;   // hidden f16 32x256 = 16384 (row-major, half)
static const uint32_t SLM_OUT  = 26624;   // 1275-value f16 32x64 = 4096 (row-major, half)
static const uint32_t SLM_SC   = 30720;   // scA @+0 | scH @+128 | scO @+256  (32 floats each)
static const uint32_t SLM_TOT  = 31104;

struct Args {
    const half* dIn;        // 1270 f16 M x 64
    half* dOut;             // 1267 f16 M x 64 (final write)
    const int8_t* Bexp;     // pack_b of the WIDE (256 x 64) = two W83 groups concatenated along N
    const int8_t* Bproj;    // gather_pack_b_diag_b output (64 x 256 packed, block-diagonal)
    const int8_t* Bres;     // pack_b of W77 (64 x 64 packed)
    const float* bsExp;     // 256 floats (W84, the two groups concatenated)
    const float* bsProj;    // 64 floats (W86)
    const float* bsRes;     // 64 floats (W78)
    const float* cos;       // 64 floats (W73)
    int M;                  // M % T == 0 required (32640: exact)
    // DUMP-only scratch (the diff pass; unused when DUMP=false):
    int8_t* dpk1; float* dsc1;   // quant of 1270 (M x 64, M)
    half*  dHid;                 // the 1274 plane (M x 256)
    int8_t* dpk2; float* dsc2;   // quant of 1274 (M x 256, M)
    half*  dOut1275;             // the 1275 plane (M x 64)
    int8_t* dpk3; float* dsc3;   // quant of 1275 (M x 64, M)
};

// NPHASE = cumulative-phase bisection for the pricing pass (military rule 7: WHICH
// stage is the cost): the kernel returns after phase NPHASE's barrier. Legal because
// every phase boundary ends on an esimd::barrier reached by ALL 64 threads; a return
// after it just drops the later phases (outputs partial/garbage -- timing only).
template <bool DUMP, int NPHASE = 6>
static sycl::event fused(sycl::queue& q, const Args& a) {
    namespace esimd = sycl::ext::intel::esimd;
    const int nblk = a.M / T;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)nblk * NT), range(NT)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOT>();
            const int blk = (int)it.get_group(0);       // 32-token block index
            const int t   = (int)it.get_local_id(0);    // 0..63
            const int r0  = blk * T;                    // first row of the block

            // ---- phase 1: 1270 -> row peak (values already f16) -> pk(in)+scA in SLM ----
            // (qr_kernel_rowthread<64> VERBATIM: one 64-half row load, hmax, div_ieee chain)
            if (t < T) {
                esimd::simd<half,64> h = esimd::block_load<half,64>(a.dIn + (size_t)(r0+t)*64,
                                                                    esimd::overaligned_tag<16>{});
                esimd::simd<float,64> f = esimd::convert<float>(h);
                float peak = esimd::hmax<float,float,64>(esimd::abs(f));
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::slm_block_store(SLM_SC + (uint32_t)t*4u, esimd::simd<float,1>(scale),
                                       esimd::overaligned_tag<16>{});
                esimd::simd<float,64> qq = esimd::div_ieee<float,64>(f, esimd::simd<float,64>(scale));
                qq = esimd::min(esimd::max(esimd::rnde<float,64>(qq), esimd::simd<float,64>(-127.f)),
                                esimd::simd<float,64>(127.f));
                esimd::simd<int8_t,64> o = esimd::convert<int8_t>(esimd::convert<int>(qq));
                for (int kb = 0; kb < 2; ++kb) {
                    esimd::simd<int8_t,32> seg = o.template select<32,1>(kb*32);
                    esimd::slm_block_store<int8_t,32>(SLM_PK + (uint32_t)(kb*2 + (t>>4))*512u + (uint32_t)(t&15)*32u,
                                                      seg, esimd::overaligned_tag<16>{});
                    if (DUMP)
                        esimd::block_store<int8_t,32>(a.dpk1 + (size_t)(r0+t)*64 + kb*32, seg,
                                                      esimd::overaligned_tag<16>{});
                }
                if (DUMP) a.dsc1[r0+t] = scale;
            }
            esimd::barrier();
            if (!DUMP && NPHASE <= 1) return;

            // ---- phase 2: expand gemm (32 x 256, K=64, epi3 gate+e4m3) -> hidden f16 SLM ----
            {
                const int rb = t / 16, cb = t % 16;     // 4 row bands x 16 col bands = 64 threads
                esimd::simd<int8_t,256> a0, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0);
                for (int kb = 0; kb < 2; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(SLM_PK + (uint32_t)(kb*2 + (rb>>1))*512u + (uint32_t)(rb&1)*256u,
                                                           esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bexp + (size_t)kb*(256*32) + (size_t)cb*512,
                                                       esimd::overaligned_tag<16>{});
                    b1 = esimd::block_load<int8_t,256>(a.Bexp + (size_t)kb*(256*32) + (size_t)cb*512 + 256,
                                                       esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                }
                esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsExp + cb*16, esimd::overaligned_tag<16>{});
                esimd::simd<float,8>  rss = esimd::slm_block_load<float,8>(SLM_SC + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<int32_t,16> acc(0);
                    acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                    acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                    float rs = rss[r];
                    esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(3u, esimd::convert<float>(acc) * rs * cs);
                    esimd::slm_block_store<half,16>(SLM_HID + (uint32_t)(rb*8 + r)*512u + (uint32_t)cb*32u,
                                                    esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();
            if (DUMP) {   // hidden plane -> 1274 twin (rows owned by t<T)
                if (t < T)
                    for (int c = 0; c < 16; ++c)
                        esimd::block_store<half,16>(a.dHid + (size_t)(r0+t)*256 + c*16,
                            esimd::slm_block_load<half,16>(SLM_HID + (uint32_t)t*512u + (uint32_t)c*32u,
                                                           esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
                esimd::barrier();
            }
            if (!DUMP && NPHASE <= 2) return;

            // ---- phase 3: hidden row peak OVER f16 SLM (= after f16 rounding, the rule) ----
            if (t < T) {
                esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                for (int c = 0; c < 16; ++c) {
                    esimd::simd<half,16> h = esimd::slm_block_load<half,16>(SLM_HID + (uint32_t)t*512u + (uint32_t)c*32u,
                                                                            esimd::overaligned_tag<16>{});
                    mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                }
                float peak = esimd::hmax<float,float,16>(mx);
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::slm_block_store(SLM_SC + 128u + (uint32_t)t*4u, esimd::simd<float,1>(scale),
                                       esimd::overaligned_tag<16>{});
                for (int kb = 0; kb < 8; ++kb) {
                    esimd::simd<half,32> h = esimd::slm_block_load<half,32>(SLM_HID + (uint32_t)t*512u + (uint32_t)kb*64u,
                                                                            esimd::overaligned_tag<16>{});
                    esimd::simd<float,32> qq = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                    qq = esimd::min(esimd::max(esimd::rnde<float,32>(qq), esimd::simd<float,32>(-127.f)),
                                    esimd::simd<float,32>(127.f));
                    esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(qq));
                    esimd::slm_block_store<int8_t,32>(SLM_PKH + (uint32_t)(kb*2 + (t>>4))*512u + (uint32_t)(t&15)*32u,
                                                      o, esimd::overaligned_tag<16>{});
                    if (DUMP)
                        esimd::block_store<int8_t,32>(a.dpk2 + (size_t)(r0+t)*256 + kb*32, o, esimd::overaligned_tag<16>{});
                }
                if (DUMP) a.dsc2[r0+t] = scale;
            }
            esimd::barrier();
            if (!DUMP && NPHASE <= 3) return;

            // ---- phase 4: projection gemm (32 x 64, K=256, block-diag wide, epi1) -> out f16 SLM ----
            if (t < 16) {   // 4 row bands x 4 col bands; idle threads still reach every barrier
                const int rb = t / 4, cb = t % 4;
                esimd::simd<int8_t,256> a0, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0);
                for (int kb = 0; kb < 8; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(SLM_PKH + (uint32_t)(kb*2 + (rb>>1))*512u + (uint32_t)(rb&1)*256u,
                                                           esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bproj + (size_t)kb*(64*32) + (size_t)cb*512,
                                                       esimd::overaligned_tag<16>{});
                    b1 = esimd::block_load<int8_t,256>(a.Bproj + (size_t)kb*(64*32) + (size_t)cb*512 + 256,
                                                       esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                }
                esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsProj + cb*16, esimd::overaligned_tag<16>{});
                // row scale = scH (the op3 quant's scale, SLM_SC+128) -- NOT scA.
                esimd::simd<float,8>  rss = esimd::slm_block_load<float,8>(SLM_SC + 128u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<int32_t,16> acc(0);
                    acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                    acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                    float rs = rss[r];
                    esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(1u, esimd::convert<float>(acc) * rs * cs);
                    esimd::slm_block_store<half,16>(SLM_OUT + (uint32_t)(rb*8 + r)*128u + (uint32_t)cb*32u,
                                                    esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();
            if (DUMP) {
                if (t < T)
                    for (int c = 0; c < 4; ++c)
                        esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*64 + c*16,
                            esimd::slm_block_load<half,16>(SLM_OUT + (uint32_t)t*128u + (uint32_t)c*32u,
                                                           esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
                esimd::barrier();
            }
            if (!DUMP && NPHASE <= 4) return;

            // ---- phase 5: out row peak -> pk(out)+scO in SLM (reuses SLM_PK) ----
            if (t < T) {
                esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                for (int c = 0; c < 4; ++c) {
                    esimd::simd<half,16> h = esimd::slm_block_load<half,16>(SLM_OUT + (uint32_t)t*128u + (uint32_t)c*32u,
                                                                            esimd::overaligned_tag<16>{});
                    mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                }
                float peak = esimd::hmax<float,float,16>(mx);
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::slm_block_store(SLM_SC + 256u + (uint32_t)t*4u, esimd::simd<float,1>(scale),
                                       esimd::overaligned_tag<16>{});
                for (int kb = 0; kb < 2; ++kb) {
                    esimd::simd<half,32> h = esimd::slm_block_load<half,32>(SLM_OUT + (uint32_t)t*128u + (uint32_t)kb*64u,
                                                                            esimd::overaligned_tag<16>{});
                    esimd::simd<float,32> qq = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                    qq = esimd::min(esimd::max(esimd::rnde<float,32>(qq), esimd::simd<float,32>(-127.f)),
                                    esimd::simd<float,32>(127.f));
                    esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(qq));
                    esimd::slm_block_store<int8_t,32>(SLM_PK + (uint32_t)(kb*2 + (t>>4))*512u + (uint32_t)(t&15)*32u,
                                                      o, esimd::overaligned_tag<16>{});
                    if (DUMP)
                        esimd::block_store<int8_t,32>(a.dpk3 + (size_t)(r0+t)*64 + kb*32, o, esimd::overaligned_tag<16>{});
                }
                if (DUMP) a.dsc3[r0+t] = scale;
            }
            esimd::barrier();
            if (!DUMP && NPHASE <= 5) return;

            // ---- phase 6: out-proj gemm (32 x 64, K=64) + skip*cos + epi1 -> 1267 ----
            // tail VERBATIM from gemm_b_res (:918-953): stage = convert(acc)*rs*cs,
            // ELEMENTWISE scalar t[e] = sk[e]*cos[e] + stage[e] (auto-FMA, one rounding),
            // pub_vec_v8<16>(1, ...), convert<half> copy_to.
            if (t < 16) {
                const int rb = t / 4, cb = t % 4;
                esimd::simd<int8_t,256> a0, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0);
                for (int kb = 0; kb < 2; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(SLM_PK + (uint32_t)(kb*2 + (rb>>1))*512u + (uint32_t)(rb&1)*256u,
                                                           esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bres + (size_t)kb*(64*32) + (size_t)cb*512,
                                                       esimd::overaligned_tag<16>{});
                    b1 = esimd::block_load<int8_t,256>(a.Bres + (size_t)kb*(64*32) + (size_t)cb*512 + 256,
                                                       esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                }
                esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsRes + cb*16, esimd::overaligned_tag<16>{});
                esimd::simd<float,16> cc = esimd::block_load<float,16>(a.cos  + cb*16, esimd::overaligned_tag<16>{});
                esimd::simd<float,8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
                esimd::simd<float,8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
                esimd::simd<float,8> ros = esimd::slm_block_load<float,8>(SLM_SC + 256u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                for (int r = 0; r < 8; ++r) {
                    const int row = r0 + rb*8 + r;
                    float rs = ros[r];
                    esimd::simd<float,8> f0 = esimd::convert<float>(c00.template select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float,8> f1 = esimd::convert<float>(c01.template select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<half,16> sh = esimd::block_load<half,16>(a.dIn + (size_t)row*64 + cb*16, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> sk0 = esimd::convert<float>(sh.template select<8,1>(0).read());
                    esimd::simd<float,8> sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    esimd::simd<float,8> t0, t1;
                    for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                    esimd::simd<float,16> pub;
                    { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                      pub = s8v8::pub_vec_v8<16>(1u, tt); }
                    esimd::convert<half>(pub).copy_to(a.dOut + (size_t)row*64 + cb*16);
                }
            }
        });
    });
}
} // namespace ffnblk

// ============================ host: timing + diff ============================
struct Stat { double msm, msM, msX, med; size_t ng; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size()/2];
    st.gms = gmin;
    return st;
}
// GPU-time timing (event profile) for SINGLE-kernel launches -- gemm32_tile.cpp:383 verbatim.
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f().wait();
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
    return pack_stat(gmin, all);
}
// host-wall timing for sequences (enqueue + wait): launch overhead is part of the prize.
static Stat timeit_wall(std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f();
    std::vector<double> gmin; gmin.reserve(groups);
    std::vector<double> all; all.reserve(groups * reps);
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            auto c0 = std::chrono::steady_clock::now();
            f();
            auto c1 = std::chrono::steady_clock::now();
            double ms = std::chrono::duration<double, std::milli>(c1 - c0).count();
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[160]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 140; ++i)
        o += snprintf(buf+o, sizeof(buf)-o, "%.4f ", st.gms[i]);
    return buf;
}
static bool diffbytes(const uint8_t* x, const uint8_t* y, size_t n, size_t K, const char* what) {
    for (size_t i = 0; i < n; ++i) if (x[i] != y[i]) {
        printf("  DIFF %-9s first mismatch elem %zu (row=%zu col=%zu): ctrl=0x%02X fused=0x%02X\n",
               what, i, i/K, i%K, x[i], y[i]);
        return false;
    }
    printf("  diff %-9s = 0  (%zu bytes)\n", what, n);
    return true;
}

int main() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 1; }
    queue q(dev, property::queue::enable_profiling{});
    printf("device: %s\n", dev.get_info<info::device::name>().c_str());

    const int M = 32640, Mp = ((M + 127) / 128) * 128;   // l0_ceil_bm (libxmx:2345)
    const int C = 64, HID = 256, NP = 128;               // op2: N=128 K=64 b2; op4 wide: Nw=64 Kw=256 b1
    if (M % ffnblk::T) { printf("M must be a multiple of T\n"); return 1; }

    // ---------------- host data ----------------
    std::mt19937 rng(5);
    std::uniform_real_distribution<float> du(-1.5f, 1.5f);
    std::uniform_int_distribution<int> dw(-127, 127);
    auto uscale = [&](std::mt19937& r) { std::uniform_real_distribution<float> d2(0.002f, 0.02f); return d2(r); };
    std::vector<half> hIn((size_t)M*C);            for (auto& x : hIn) x = half(du(rng));
    std::vector<int8_t> hW83((size_t)2*NP*C);      for (auto& x : hW83) x = (int8_t)dw(rng);
    std::vector<float>  hS84((size_t)2*NP);        for (auto& x : hS84) x = uscale(rng);
    std::vector<int8_t> hW85((size_t)2*32*128);    for (auto& x : hW85) x = (int8_t)dw(rng);
    std::vector<float>  hS86(64);                  for (auto& x : hS86) x = uscale(rng);
    std::vector<int8_t> hW77((size_t)64*64);       for (auto& x : hW77) x = (int8_t)dw(rng);
    std::vector<float>  hS78(64);                  for (auto& x : hS78) x = uscale(rng);
    std::vector<float>  hCos(64);                  for (auto& x : hCos) x = du(rng);
    // wide W83 for the fused leg: two groups concatenated along N (raw 256 x 64 row-major)
    std::vector<int8_t> hW83W((size_t)256*64);
    for (int g = 0; g < 2; ++g) for (int n = 0; n < NP; ++n) for (int k = 0; k < C; ++k)
        hW83W[(size_t)(g*NP + n)*64 + k] = hW83[(size_t)g*NP*C + (size_t)n*C + k];

    // ---------------- device buffers ----------------
    auto mk = [&](size_t bytes) { void* p = malloc_device(bytes, q); q.memset(p, 0, bytes).wait(); return p; };
    half*   d1270  = (half*)mk((size_t)M*C*2);
    half*   d1267c = (half*)mk((size_t)M*C*2);
    half*   d1267f = (half*)mk((size_t)M*C*2);
    int8_t* dPK    = (int8_t*)mk((size_t)M*256);          // pk1272 (row stride = K of the quant)
    float*  dSC    = (float*)mk((size_t)M*4);             // sc1273
    half*   d1274  = (half*)mk((size_t)M*HID*2);
    half*   d1275  = (half*)mk((size_t)M*C*2);
    int8_t* dAp2   = (int8_t*)mk((size_t)2*Mp*C);         // op2 A pack (batched Mp x 64 x 2)
    int8_t* dAp4   = (int8_t*)mk((size_t)Mp*256);         // op4 A pack (wide Mp x 256)
    int8_t* dApr   = (int8_t*)mk((size_t)Mp*C);           // op6 pack_a_fused output (Mp x 64)
    int8_t* dBp83  = (int8_t*)mk((size_t)2*NP*C);         // gather_pack_b_b (cache-owned)
    int8_t* dBp83W = (int8_t*)mk((size_t)256*64);         // pack_b of the wide 256x64 (fused leg)
    int8_t* dBp85  = (int8_t*)mk((size_t)64*256);         // gather_pack_b_diag_b (cache-owned)
    int8_t* dBp77  = (int8_t*)mk((size_t)64*64);          // pack_b (cached_pack_b_i8 semantics)
    float*  dS84 = (float*)mk(256*4); float* dS86 = (float*)mk(64*4);
    float*  dS78 = (float*)mk(64*4);  float* dCos = (float*)mk(64*4);
    int8_t* dW83raw = (int8_t*)mk(hW83.size());
    int8_t* dW85raw = (int8_t*)mk(hW85.size());
    int8_t* dW77raw = (int8_t*)mk(hW77.size());
    int8_t* dW83Wraw= (int8_t*)mk(hW83W.size());
    q.memcpy(d1270, hIn.data(), (size_t)M*C*2);
    q.memcpy(dW83raw, hW83.data(), hW83.size());
    q.memcpy(dW85raw, hW85.data(), hW85.size());
    q.memcpy(dW77raw, hW77.data(), hW77.size());
    q.memcpy(dW83Wraw, hW83W.data(), hW83W.size());
    q.memcpy(dS84, hS84.data(), 256*4); q.memcpy(dS86, hS86.data(), 64*4);
    q.memcpy(dS78, hS78.data(), 64*4);  q.memcpy(dCos, hCos.data(), 64*4);
    // weight packs = setup once, NOT timed (the recorder's g_wcache: :2535/:2497/:498)
    packdev::gather_pack_b_b(q, dW83raw, dBp83, NP, C, C, (size_t)NP*C, 2);
    packdev::pack_b(q, dW83Wraw, dBp83W, 256, C);
    packdev::gather_pack_b_diag_b(q, dW85raw, dBp85, 32, 128, 128, (size_t)32*128, 2);
    packdev::pack_b(q, dW77raw, dBp77, 64, 64);
    // fused-leg dump scratch
    int8_t* fPK1 = (int8_t*)mk((size_t)M*C);   float* fSC1 = (float*)mk((size_t)M*4);
    half*   fHID = (half*)mk((size_t)M*HID*2); int8_t* fPK2 = (int8_t*)mk((size_t)M*HID);
    float*  fSC2 = (float*)mk((size_t)M*4);    half*   fOUT = (half*)mk((size_t)M*C*2);
    int8_t* fPK3 = (int8_t*)mk((size_t)M*C);   float*  fSC3 = (float*)mk((size_t)M*4);
    q.wait();

    // ---------------- control leg: the recorder's REAL per-frame 8 launches ----------------
    auto C1 = [&]{ qr_launch_esimd(q, dev, d1270, (sycl::uint2*)dPK, dSC, (unsigned)M, 64u); };
    auto C2 = [&]{ packdev::gather_pack_a_b_v(q, dPK, dAp2, M, Mp, C, C, 0, 2); };
    auto C3 = [&]{ s8v8::gemm_b_pub_slm<false>(q, dAp2, dBp83, (void*)d1274, dSC, dS84, M, Mp, NP, C, 2,
                                               (size_t)NP, 256u, 0u, (unsigned)NP, true, 3u); };
    auto C4 = [&]{ qr_launch_esimd(q, dev, d1274, (sycl::uint2*)dPK, dSC, (unsigned)M, 256u); };
    auto C5 = [&]{ packdev::gather_pack_a_b_v(q, dPK, dAp4, M, Mp, 256, 256, 0, 1); };
    auto C6 = [&]{ s8v8::gemm_b_pub(q, dAp4, dBp85, (void*)d1275, dSC, dS86, M, Mp, 64, 256, 1,
                                    (size_t)0, 64u, 0u, 0u, true, 1u); };
    auto C7 = [&]{ packdev::pack_a_fused(q, d1275, dApr, dSC, M, Mp, C); };   // op5 dissolved (qfuse_take ON)
    auto C8 = [&]{ s8v8::gemm_b_res(q, dApr, dBp77, (void*)d1267c, dSC, dS78, (const void*)d1270, dCos,
                                    M, Mp, 64, 64, true, true, 1u); };
    auto CHAIN = [&]{ C1(); C2(); C3(); C4(); C5(); C6(); C7(); C8(); q.wait(); };

    // diff pass: run the chain op-by-op with snapshots at the checkpoints
    std::vector<uint8_t> cpk1((size_t)M*C), csc1((size_t)M*4), chid((size_t)M*HID*2);
    std::vector<uint8_t> cpk2((size_t)M*HID), csc2((size_t)M*4), cout((size_t)M*C*2);
    std::vector<uint8_t> cpk3((size_t)M*C), csc3((size_t)M*4), cres((size_t)M*C*2);
    CHAIN();   // full chain once (warms every control kernel too)
    C1(); q.wait(); q.memcpy(cpk1.data(), dPK, (size_t)M*C); q.memcpy(csc1.data(), dSC, (size_t)M*4); q.wait();
    C2(); C3(); q.wait(); q.memcpy(chid.data(), d1274, (size_t)M*HID*2); q.wait();
    C4(); q.wait(); q.memcpy(cpk2.data(), dPK, (size_t)M*HID); q.memcpy(csc2.data(), dSC, (size_t)M*4); q.wait();
    C5(); C6(); q.wait(); q.memcpy(cout.data(), d1275, (size_t)M*C*2); q.wait();
    qr_launch_esimd(q, dev, d1275, (sycl::uint2*)dPK, dSC, (unsigned)M, 64u); q.wait();   // op5 standalone (checkpoint only)
    q.memcpy(cpk3.data(), dPK, (size_t)M*C); q.memcpy(csc3.data(), dSC, (size_t)M*4); q.wait();
    C7(); C8(); q.wait(); q.memcpy(cres.data(), d1267c, (size_t)M*C*2); q.wait();

    // fused dump pass
    ffnblk::Args fa;
    fa.dIn = d1270; fa.dOut = d1267f; fa.Bexp = dBp83W; fa.Bproj = dBp85; fa.Bres = dBp77;
    fa.bsExp = dS84; fa.bsProj = dS86; fa.bsRes = dS78; fa.cos = dCos; fa.M = M;
    fa.dpk1 = fPK1; fa.dsc1 = fSC1; fa.dHid = fHID; fa.dpk2 = fPK2; fa.dsc2 = fSC2;
    fa.dOut1275 = fOUT; fa.dpk3 = fPK3; fa.dsc3 = fSC3;
    ffnblk::fused<true>(q, fa).wait();
    std::vector<uint8_t> fpk1((size_t)M*C), fsc1((size_t)M*4), fhid((size_t)M*HID*2);
    std::vector<uint8_t> fpk2((size_t)M*HID), fsc2((size_t)M*4), fout((size_t)M*C*2);
    std::vector<uint8_t> fpk3((size_t)M*C), fsc3((size_t)M*4), fres((size_t)M*C*2);
    q.memcpy(fpk1.data(), fPK1, (size_t)M*C); q.memcpy(fsc1.data(), fSC1, (size_t)M*4);
    q.memcpy(fhid.data(), fHID, (size_t)M*HID*2); q.memcpy(fpk2.data(), fPK2, (size_t)M*HID);
    q.memcpy(fsc2.data(), fSC2, (size_t)M*4); q.memcpy(fout.data(), fOUT, (size_t)M*C*2);
    q.memcpy(fpk3.data(), fPK3, (size_t)M*C); q.memcpy(fsc3.data(), fSC3, (size_t)M*4);
    q.memcpy(fres.data(), d1267f, (size_t)M*C*2); q.wait();

    bool ok = true;
    printf("== byte-exact diff (control vs fused dump) ==\n");
    ok &= diffbytes(cpk1.data(), fpk1.data(), cpk1.size(), C,   "pk1");
    ok &= diffbytes(csc1.data(), fsc1.data(), csc1.size(), 1,   "sc1");
    ok &= diffbytes(chid.data(), fhid.data(), chid.size(), HID, "hid1274");
    ok &= diffbytes(cpk2.data(), fpk2.data(), cpk2.size(), HID, "pk2");
    ok &= diffbytes(csc2.data(), fsc2.data(), csc2.size(), 1,   "sc2");
    ok &= diffbytes(cout.data(), fout.data(), cout.size(), C,   "out1275");
    ok &= diffbytes(cpk3.data(), fpk3.data(), cpk3.size(), C,   "pk3");
    ok &= diffbytes(csc3.data(), fsc3.data(), fsc3.size(), 1,   "sc3");
    ok &= diffbytes(cres.data(), fres.data(), cres.size(), C,   "1267-FINAL");
    if (!ok) { printf("GATE FAIL: diff != 0 -- pricing skipped (entry ticket missing)\n"); return 2; }
    printf("GATE PASS: all nine checkpoints diff=0\n\n");

    // ---------------- pricing (TRAP 1-9 protocol) ----------------
    printf("== per-op time (host wall incl. launch, chain state) ==\n");
    struct Row { const char* name; Stat st; };
    std::vector<Row> rows;
    rows.push_back({"op1 quant K64",    timeit_wall([&]{ C1(); q.wait(); })});
    rows.push_back({"op2 packA",        timeit_wall([&]{ C2(); q.wait(); })});
    rows.push_back({"op2 gemm pubslm",  timeit_wall([&]{ C3(); q.wait(); })});
    rows.push_back({"op3 quant K256",   timeit_wall([&]{ C4(); q.wait(); })});
    rows.push_back({"op4 packA wide",   timeit_wall([&]{ C5(); q.wait(); })});
    rows.push_back({"op4 gemm wide",    timeit_wall([&]{ C6(); q.wait(); })});
    rows.push_back({"op5+6 pack_fused", timeit_wall([&]{ C7(); q.wait(); })});
    rows.push_back({"op6 gemm_res",     timeit_wall([&]{ C8(); q.wait(); })});
    double sum_wall = 0;
    for (auto& r : rows) {
        printf("  %-18s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  gm=[%s]\n",
               r.name, r.st.msM, r.st.msm, r.st.msX, r.st.med, gmfmt(r.st));
        sum_wall += r.st.msM;
    }
    printf("  SUM of per-op msM = %.4f ms\n\n", sum_wall);

    printf("== leg totals (host wall, same process) ==\n");
    Stat wallC = timeit_wall(CHAIN);
    Stat wallF = timeit_wall([&]{ ffnblk::fused<false>(q, fa).wait(); });
    Stat gpuF  = timeit([&]{ return ffnblk::fused<false>(q, fa); });
    printf("  control chain (8 launches)  msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  gm=[%s]\n",
           wallC.msM, wallC.msm, wallC.msX, wallC.med, gmfmt(wallC));
    printf("  fused single  (1 launch)    msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f  gm=[%s]\n",
           wallF.msM, wallF.msm, wallF.msX, wallF.med, gmfmt(wallF));
    printf("  fused kernel GPU-only       msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f\n",
           gpuF.msM, gpuF.msm, gpuF.msX, gpuF.med);
    // fused-internal phase bisection (cumulative GPU event time; the NPHASE=6 row above
    // is the full chain). Deltas = the phase's marginal cost INSIDE the resident kernel.
    printf("== fused phase bisection (cumulative GPU msM) ==\n");
    Stat p1 = timeit([&]{ return ffnblk::fused<false,1>(q, fa); });
    Stat p2 = timeit([&]{ return ffnblk::fused<false,2>(q, fa); });
    Stat p3 = timeit([&]{ return ffnblk::fused<false,3>(q, fa); });
    Stat p4 = timeit([&]{ return ffnblk::fused<false,4>(q, fa); });
    Stat p5 = timeit([&]{ return ffnblk::fused<false,5>(q, fa); });
    printf("  P1 quant-in            cum=%7.4f  msm=%7.4f\n", p1.msM, p1.msm);
    printf("  +P2 expand gemm        cum=%7.4f  delta=%7.4f\n", p2.msM, p2.msM - p1.msM);
    printf("  +P3 pkH quant          cum=%7.4f  delta=%7.4f\n", p3.msM, p3.msM - p2.msM);
    printf("  +P4 proj gemm          cum=%7.4f  delta=%7.4f\n", p4.msM, p4.msM - p3.msM);
    printf("  +P5 pkO quant          cum=%7.4f  delta=%7.4f\n", p5.msM, p5.msM - p4.msM);
    printf("  +P6 res gemm + write   cum=%7.4f  delta=%7.4f\n", gpuF.msM, gpuF.msM - p5.msM);
    double d = wallF.msM - wallC.msM;
    printf("\nVERDICT: fused %s control by %.4f ms/chain (fused wall=%.4f vs chain wall=%.4f; per-op sum=%.4f)\n",
           d <= 0 ? "BEATS" : "LOSES TO", d < 0 ? -d : d, wallF.msM, wallC.msM, sum_wall);
    printf("frame: 8 C=64 chains/frame => %+.2f ms/frame (wall basis, msM)\n", d * 8);
    return 0;
}
