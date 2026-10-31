// bench_s8v8_tile.cpp -- s8v8 tile-variant sweep (b1-blueprint §6.28/6.30 刀�?1, the
// window owed two windows ago): the three brothers (window_block 19.9 | gemm_int8_batched
// 18.5 | gemm_int8_residual 18.0, CS2 second-pass serial ledger) all ride the SAME s8v8
// gemm, today BM128/BN64/BK32/NT32 with the s8d2 depth-2 three-buffer loop. The blueprint's
// judgement (notes/b1-blueprint.md:1144-1146): NT32 + 8 accumulator fragments is 4KB/thread
// of live int32 -- far wider than the chip kernel's 12x64B -- so the RIGHT tile-variant form
// is "BN doubled but accumulators halved: 16 col x 2 tile serial". This file prices that
// form against the alternatives on the frame's REAL shapes, before anything touches the dll.
//
// WHAT IS AND IS NOT A TEMPLATE (task 1, from reading gemm_s8_v8_kernel.hpp +
// pack_device.hpp): BM/BN/BK/NT are namespace static const ints and the kernel bodies
// hardcode the geometry (lid/4, wi_row*512, simd sizes, slm_init, dpas<8,8>, store r<8);
// the packers hardcode BM=128/BK=32 for A (pack_b is kk32-block based => BK-INDEPENDENT).
// So every variant needs its own kernel -- written here as ONE template:
//
//   template<BNV, BKV, NTV, NBUF, MODE, PUB>
//     BNV  = 64/128, BKV = 32/64, NTV = 32/64 (ESIMD threads per WG),
//     NBUF = SLM buffers per operand (2 = double buffer/depth-1; 3 = the shipped s8d2;
//            4 = depth-3 quad buffer),
//     MODE 0 = BN64/NT32 (shipped geometry, depth + BK sweep)
//          1 = BN128/NT64 -- BN doubled by DOUBLING THREADS: 4 accumulator fragments
//              per thread exactly as today, 64 threads/WG, 128x128 tile.
//          2 = BN128/NT32 SERIAL 16col x 2tile -- the blueprint form: thread owns a
//              16x32 output stripe, sweeps its two 16-col tiles one after the other,
//              accumulator live-set stays 4 fragments. Cost: unless NBUF >= kb_n the
//              kb blocks are re-loaded from global for the second sweep (A/B traffic
//              x2 -- L2-hot for the small-B frames, visible for the big-M ones).
//          3 = BN128/NT32 NAIVE 8 accumulators -- the form the blueprint rejects;
//              priced anyway to FALSIFY it with numbers (spill watch via ocloc).
//     PUB false = raw int32 C32 store (gemm_b leg); true = the fused publish tail
//              VERBATIM from gemm_b_pub (epi/narrow/scales), so it is diff-able vs it.
//
// BIT-EXACT DISCIPLINE (task 3): int32 dpas accumulation is exact + associative, so ANY
// BK/BN/NT/depth order gives byte-identical C32 vs the shipped gemm_b, and the pub tail
// is the same expression text as gemm_b_pub ((float)acc * rs * cs, pub_vec_v8). Every
// variant is diffed AGAINST the shipped outputs, element-byte, and the diff count is
// printed -- diff != 0 kills the variant regardless of its time. Padded output rows are
// memset to 0 first so the pub tail's rr<M cull never compares garbage.
//
// BK=64 needs a different A pack map (B pack needs nothing -- kk32 blocks are adjacent in
// global, so one SLM buffer just spans two of them). pack_a64 below is HOST-side (packed
// once, memcpy'd); only the gemm events are timed, so the pack cost never enters a row.
//
// RUN (the recipe that cost someone a whole failed build -- follow it, from the repo root):
//   bash E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/src/bench/esimd/build_esimd.sh \
//        E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/src/bench/sycl/bench_s8v8_tile.cpp \
//        E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/src/bench/sycl/bench_s8v8_tile.exe
// (flags in //form, NO MSYS_NO_PATHCONV, SYCL_DEVICE_FILTER=level_zero:gpu; the script
//  stages the exe into E:/WorkBuddy/2026-10-09-04-20-55/oneapi/ and runs it THERE --
//  the runtime dlls only live beside that dir. Do not run nr_replay_now.exe at the same
//  time: it owns the A770.)
// For the spill/scratch ledger, AOT-build the SAME file and run kdis/spillcheck.py on it:
//   bash .../build_esimd.sh .../bench_s8v8_tile.cpp .../bench_s8v8_tile_aot.exe \
//        -fsycl-targets=spir64_gen -Xs "-device dg2"
//   python .../src/bench/sycl/kdis/spillcheck.py .../bench_s8v8_tile_aot.exe E:/tmp/s8v8tk
// (MAX_PATH trap: dump to a SHORT path, the .text.<mangled>.asm names are ~170 chars.)
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <algorithm>
#include "gemm_s8_v8_kernel.hpp"   // shipped v8: s8v8::gemm_b / gemm_b_pub / pub_vec_v8 -- READ ONLY
#include "pack_device.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ---- the variant kernels (bench-local fork of v8, geometry as template parameters) ----
namespace t8v {
static const int BM = 128;

template <int BNV, int BKV, int NTV, int NBUF, int MODE, bool PUB>
static inline sycl::event gemm_var(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                   int32_t* C32, void* Cout, const float* as, const float* bs,
                                   int M, int Mp, int N, int K, int batch,
                                   size_t sc, unsigned ldc, unsigned scale_stride,
                                   unsigned col_stride, bool narrow, unsigned epi) {
    constexpr int SLM_A  = BM * BKV;              // A bytes per operand buffer (128 rows x BK)
    constexpr int SLM_B  = BKV * BNV;             // B bytes per operand buffer
    constexpr int A_WI   = 16 * BKV;              // A stripe bytes per thread (16 rows x BK)
    constexpr int KC     = BKV / 32;              // 32-K dpas chunks per kb block
    constexpr int STRIPE = (MODE >= 2) ? 1024 : 512;  // B stripe bytes per thread per kc
    int wg = (Mp / BM) * (N / BNV);
    size_t apb_sz = (size_t)Mp * K, bpb_sz = (size_t)N * K, cb_sz = (size_t)Mp * N;
    int kb_n = K / BKV;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NTV), range(NTV)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            constexpr uint32_t SLMB_BASE = NBUF * SLM_A;   // B buffers follow the A buffers
            esimd::slm_init<NBUF * SLM_A + NBUF * SLM_B>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BNV;
            int wg_row = loc / NB, wg_col = loc % NB;
            constexpr int WIC = (MODE == 1) ? 8 : 4;       // col bands: NT64 -> 8, NT32 -> 4
            int wi_row = lid / WIC, wi_col = lid % WIC;
            const int8_t* apb = Ap + (size_t)g * apb_sz + (size_t)(wg_row * kb_n) * SLM_A;
            const int8_t* bp  = Bp + (size_t)g * bpb_sz + (size_t)wg_col * (BNV / 8) * 256;
            int32_t* c_g = C32 + (size_t)g * cb_sz;
            // global -> SLM block copy of one kb. The A block is contiguous (pack_a64
            // lays it out per (w,kb)). The B block is KC kk32 blocks -- pack_b puts
            // consecutive kk32 blocks N*32 bytes apart in global, so they are only
            // adjacent when N==BNV; copy them piecewise at their SLM slots (KC=1
            // reduces to the shipped single linear copy).
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, SLM_A / NTV> av = esimd::block_load<int8_t, SLM_A / NTV>(
                    apb + (size_t)kb * SLM_A + lid * (SLM_A / NTV), esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * (SLM_A / NTV), av, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int kc = 0; kc < KC; ++kc) {
                    esimd::simd<int8_t, SLM_B / KC / NTV> bv = esimd::block_load<int8_t, SLM_B / KC / NTV>(
                        bp + (size_t)kb * N * BKV + (size_t)kc * (N * 32) + lid * (SLM_B / KC / NTV),
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLMB_BASE + buf * SLM_B + kc * (SLM_B / KC)
                        + lid * (SLM_B / KC / NTV), bv, esimd::overaligned_tag<16>{});
                }
            };
            // one full K-sweep over column-tile s (s=0/1 only for MODE2; else s=0).
            auto sweep = [&](int s) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 256> a0, a1, b0, b1, b2, b3;
                esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
                esimd::simd<int32_t, 64> c02(0), c03(0), c12(0), c13(0);
                // MODE2 second-sweep fast path: when the whole kb pipeline fits in the
                // buffers (kb_n <= NBUF), sweep(1) reads the still-resident SLM and
                // touches global ZERO. Otherwise it re-loads every block (the honest
                // double-load form). NBUF=3 with K=64/128 and NBUF=4 with K<=128 hit it.
                int load_this = (s == 0 || kb_n > NBUF) ? 1 : 0;
                int nb = (NBUF - 1 < kb_n) ? NBUF - 1 : kb_n;
                if (load_this) for (int p = 0; p < nb; ++p) load_block(p, p);
                esimd::barrier();
                for (int b = 0; b < kb_n; ++b) {
                    int cur = b % NBUF;
                    int nx = b + NBUF - 1;
                    if (load_this && nx < kb_n) load_block(nx % NBUF, nx);
                    #pragma unroll
                    for (int kc = 0; kc < KC; ++kc) {
                        uint32_t offA = (uint32_t)(cur * SLM_A) + (uint32_t)(wi_row * A_WI) + (uint32_t)(kc * 512);
                        uint32_t offB = SLMB_BASE + (uint32_t)(cur * SLM_B)
                                      + (uint32_t)(kc * (BNV * 32)) + (uint32_t)(wi_col * STRIPE)
                                      + (MODE == 2 ? (uint32_t)(s * 512) : 0u);
                        a0 = esimd::slm_block_load<int8_t, 256>(offA + 0,   esimd::overaligned_tag<16>{});
                        a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                        b0 = esimd::slm_block_load<int8_t, 256>(offB + 0,   esimd::overaligned_tag<16>{});
                        b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                        if (MODE == 3) {
                            b2 = esimd::slm_block_load<int8_t, 256>(offB + 512, esimd::overaligned_tag<16>{});
                            b3 = esimd::slm_block_load<int8_t, 256>(offB + 768, esimd::overaligned_tag<16>{});
                        }
                        c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                        c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                        c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                        if (MODE == 3) {
                            c02 = esimd::xmx::dpas<8, 8, int32_t>(c02, b2, a0);
                            c03 = esimd::xmx::dpas<8, 8, int32_t>(c03, b3, a0);
                            c12 = esimd::xmx::dpas<8, 8, int32_t>(c12, b2, a1);
                            c13 = esimd::xmx::dpas<8, 8, int32_t>(c13, b3, a1);
                        }
                    }
                    esimd::barrier();
                }
                // ---- store: the shipped v8 tails VERBATIM (raw = gemm_b's block_store
                // pair; pub = gemm_b_pub's cs/rs/acc-assembly/pub_vec_v8 chain) ----
                int gr = wg_row * BM + wi_row * 16;
                int gc = wg_col * BNV + (MODE >= 2 ? wi_col * 32 : wi_col * 16)
                       + (MODE == 2 ? s * 16 : 0);
                if (!PUB) {
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t, 16> row0;
                        row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                        row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                        esimd::simd<int32_t, 16> row1;
                        row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                        row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                        esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                        esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
                        if (MODE == 3) {
                            esimd::simd<int32_t, 16> row0h;
                            row0h.select<8, 1>(0) = c02.select<8, 1>(r * 8);
                            row0h.select<8, 1>(8) = c03.select<8, 1>(r * 8);
                            esimd::simd<int32_t, 16> row1h;
                            row1h.select<8, 1>(0) = c12.select<8, 1>(r * 8);
                            row1h.select<8, 1>(8) = c13.select<8, 1>(r * 8);
                            esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc + 16, row0h, esimd::overaligned_tag<16>{});
                            esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc + 16, row1h, esimd::overaligned_tag<16>{});
                        }
                    }
                } else {
                    const float* gas = as + (size_t)g * scale_stride;
                    const float* gbs = bs + (size_t)g * col_stride;
                    esimd::simd<float, 16> cs = esimd::block_load<float, 16>(
                        gbs + gc, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> cs2;
                    if (MODE == 3) cs2 = esimd::block_load<float, 16>(gbs + gc + 16, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) {
                        int rr0 = gr + r, rr1 = gr + 8 + r;
                        if (rr0 < M) {
                            float rs = gas[rr0];
                            esimd::simd<int32_t, 16> acc(0);
                            acc.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                            acc.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                            esimd::simd<float, 16> pub = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                            size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                            if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                            else        pub.copy_to((float*)Cout + out);
                            if (MODE == 3) {
                                esimd::simd<int32_t, 16> acc2(0);
                                acc2.select<8, 1>(0) = c02.select<8, 1>(r * 8);
                                acc2.select<8, 1>(8) = c03.select<8, 1>(r * 8);
                                esimd::simd<float, 16> pub2 = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc2) * rs * cs2);
                                if (narrow) esimd::convert<half>(pub2).copy_to((half*)Cout + out + 16);
                                else        pub2.copy_to((float*)Cout + out + 16);
                            }
                        }
                        if (rr1 < M) {
                            float rs = gas[rr1];
                            esimd::simd<int32_t, 16> acc(0);
                            acc.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                            acc.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                            esimd::simd<float, 16> pub = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                            size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                            if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                            else        pub.copy_to((float*)Cout + out);
                            if (MODE == 3) {
                                esimd::simd<int32_t, 16> acc2(0);
                                acc2.select<8, 1>(0) = c12.select<8, 1>(r * 8);
                                acc2.select<8, 1>(8) = c13.select<8, 1>(r * 8);
                                esimd::simd<float, 16> pub2 = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc2) * rs * cs2);
                                if (narrow) esimd::convert<half>(pub2).copy_to((half*)Cout + out + 16);
                                else        pub2.copy_to((float*)Cout + out + 16);
                            }
                        }
                    }
                }
            };
            sweep(0);
            if (MODE == 2) sweep(1);   // the blueprint form's second 16-col tile
        });
    });
}
} // namespace t8v

// ---- host A pack for BK=64: per (w,kb) block = 8 wi x [kc0: 16 rows x 32k][kc1: ditto];
// rows >= M zero-padded exactly like gather_pack_a_b. Source addressing mirrors
// gather_pack_a_b(lda=K, sa=0): EVERY group reads the SAME first M*K rows. ----
static void pack_a64_host(const int8_t* A, int8_t* Ap, int M, int Mp, int K, int batch) {
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
                                    srow < M ? A[(size_t)srow * K + kb * 64 + kc * 32 + k] : (int8_t)0;
                            }
    }
}

static queue* GQ;   // for the runners below

struct Ctx {
    int M, N, K, b, Mp;
    int8_t *dAp, *dAp64, *dBp;
    float *das, *dbs;
    int32_t *dC32ref, *dC32v;
    half *dCref, *dCv;
    std::vector<int32_t> h32ref, h32v;
    std::vector<half> h16ref, h16v;
};

template <int BNV, int BKV, int NTV, int NBUF, int MODE, bool PUB>
static void run_variant(Ctx& cx, const char* name) {
    queue& q = *GQ;
    size_t n32 = (size_t)cx.b * cx.Mp * cx.N;
    if (cx.N % BNV || cx.K % BKV) {
        printf("  %-24s %-4s  -- N/A (N%%BN or K%%BK) --\n", name, PUB ? "pub" : "raw");
        return;
    }
    const int8_t* Ap = (BKV == 32) ? cx.dAp : cx.dAp64;
    double best = 1e9;
    for (int it = 0; it < 15; ++it) {
        event e = PUB
            ? t8v::gemm_var<BNV, BKV, NTV, NBUF, MODE, true>(q, Ap, cx.dBp, nullptr, (void*)cx.dCv,
                  cx.das, cx.dbs, cx.M, cx.Mp, cx.N, cx.K, cx.b, (size_t)cx.Mp * cx.N,
                  (unsigned)cx.N, 0u, 0u, true, 3u)
            : t8v::gemm_var<BNV, BKV, NTV, NBUF, MODE, false>(q, Ap, cx.dBp, cx.dC32v, nullptr,
                  cx.das, cx.dbs, cx.M, cx.Mp, cx.N, cx.K, cx.b, (size_t)cx.Mp * cx.N,
                  (unsigned)cx.N, 0u, 0u, true, 3u);
        e.wait();
        auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
        auto t0 = e.get_profiling_info<info::event_profiling::command_end>();
        best = std::min(best, (double)(t0 - s0) / 1e6);
    }
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
    // the kernel's own load traffic: A once/WG + B once per (wg_row, kb) i.e. (Mp/128)
    // reads of N*K per group + C store; MODE2 sweeps A and B twice UNLESS the whole kb
    // pipeline stays resident in the buffers for the second sweep (kb_n <= NBUF).
    double ab = (MODE == 2 && cx.K / BKV > NBUF) ? 2.0 : 1.0;
    double bytes = (double)cx.b * (ab * ((double)cx.Mp * cx.K + (double)(cx.Mp / 128) * cx.N * cx.K)
                                 + (double)cx.Mp * cx.N * (PUB ? 2 : 4));
    double gbs = bytes / (best / 1e3) / 1e9;
    double gf  = 2.0 * cx.M * cx.N * cx.K * cx.b / (best / 1e3) / 1e9;
    int slm = NBUF * (128 * BKV + BKV * BNV);
    printf("  %-24s %-4s ms=%8.4f  GB/s=%7.1f  vs560=%5.1f%% vs734=%5.1f%%  GF/s=%8.0f  diff=%zu  SLM=%dKB\n",
           name, PUB ? "pub" : "raw", best, gbs, 100.0 * gbs / 560.0, 100.0 * gbs / 734.0, gf, diff, slm / 1024);
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

    struct Cfg { int M, N, K, b; };
    std::vector<Cfg> cfgs = {
        {2040, 128, 256, 8}, {32640, 128, 64, 2}, {640, 64, 256, 8},
        {8160, 128, 128, 4}, {8160, 384, 128, 1}, {130560, 384, 128, 1},
    };
    for (auto cf : cfgs) {
        Ctx cx; cx.M = cf.M; cx.N = cf.N; cx.K = cf.K; cx.b = cf.b;
        cx.Mp = ((cx.M + 127) / 128) * 128;
        size_t nA = (size_t)cx.b * cx.M * cx.K, nB = (size_t)cx.b * cx.K * cx.N;
        size_t nAp = (size_t)cx.b * cx.Mp * cx.K, n32 = (size_t)cx.b * cx.Mp * cx.N;
        std::vector<int8_t> A(nA), B(nB), Ap64(nAp);
        std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127, 127);
        for (auto& x : A) x = (int8_t)da(rng);
        for (auto& x : B) x = (int8_t)da(rng);
        std::vector<float> as((size_t)cx.b * cx.Mp, 1.f), bs((size_t)cx.b * cx.N, 1.f);
        cx.dAp   = (int8_t*)malloc_device(nAp, q);
        cx.dAp64 = (int8_t*)malloc_device(nAp, q);
        cx.dBp   = (int8_t*)malloc_device(nB, q);
        cx.das   = (float*)malloc_device(as.size() * 4, q);
        cx.dbs   = (float*)malloc_device(bs.size() * 4, q);
        cx.dC32ref = (int32_t*)malloc_device(n32 * 4, q);
        cx.dC32v   = (int32_t*)malloc_device(n32 * 4, q);
        cx.dCref = (half*)malloc_device(n32 * 2, q);
        cx.dCv   = (half*)malloc_device(n32 * 2, q);
        q.memset(cx.dC32ref, 0, n32 * 4); q.memset(cx.dC32v, 0, n32 * 4);
        q.memset(cx.dCref, 0, n32 * 2);   q.memset(cx.dCv, 0, n32 * 2);
        // raw A/B live only at their first M*K / N*K bytes (the bench feeds sa=sb=0,
        // like the frame's same-activation batched calls); pack once, all groups read it.
        std::vector<int8_t> A1((size_t)cx.M * cx.K), B1((size_t)cx.N * cx.K);
        memcpy(A1.data(), A.data(), A1.size()); memcpy(B1.data(), B.data(), B1.size());
        int8_t* dA = (int8_t*)malloc_device(A1.size(), q);
        int8_t* dB = (int8_t*)malloc_device(B1.size(), q);
        q.memcpy(dA, A1.data(), A1.size()).wait();
        q.memcpy(dB, B1.data(), B1.size()).wait();
        q.memcpy(cx.das, as.data(), as.size() * 4).wait();
        q.memcpy(cx.dbs, bs.data(), bs.size() * 4).wait();
        packdev::gather_pack_a_b(q, dA, cx.dAp, cx.M, cx.Mp, cx.K, cx.K, 0, cx.b);
        packdev::gather_pack_b_b(q, dB, cx.dBp, cx.N, cx.K, cx.K, 0, cx.b);
        pack_a64_host(A1.data(), Ap64.data(), cx.M, cx.Mp, cx.K, cx.b);
        q.memcpy(cx.dAp64, Ap64.data(), nAp).wait();
        q.wait();

        // ---- shipped baseline: time + capture the reference outputs ----
        double bestb = 1e9, bestp = 1e9;
        for (int it = 0; it < 15; ++it) {
            event e = s8v8::gemm_b(q, cx.dAp, cx.dBp, cx.dC32ref, cx.Mp, cx.N, cx.K, cx.b); e.wait();
            auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
            auto t0 = e.get_profiling_info<info::event_profiling::command_end>();
            bestb = std::min(bestb, (double)(t0 - s0) / 1e6);
        }
        for (int it = 0; it < 15; ++it) {
            event e = s8v8::gemm_b_pub(q, cx.dAp, cx.dBp, (void*)cx.dCref, cx.das, cx.dbs,
                cx.M, cx.Mp, cx.N, cx.K, cx.b, (size_t)cx.Mp * cx.N, (unsigned)cx.N, 0u, 0u, true, 3u); e.wait();
            auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
            auto t0 = e.get_profiling_info<info::event_profiling::command_end>();
            bestp = std::min(bestp, (double)(t0 - s0) / 1e6);
        }
        cx.h32ref.resize(n32); cx.h32v.resize(n32);
        cx.h16ref.resize(n32); cx.h16v.resize(n32);
        q.memcpy(cx.h32ref.data(), cx.dC32ref, n32 * 4).wait();
        q.memcpy(cx.h16ref.data(), cx.dCref, n32 * 2).wait();
        {
            double ab = 1.0;
            double bytesR = (double)cx.b * (ab * ((double)cx.Mp * cx.K + (double)(cx.Mp / 128) * cx.N * cx.K)
                                          + (double)cx.Mp * cx.N * 4);
            double bytesP = (double)cx.b * (ab * ((double)cx.Mp * cx.K + (double)(cx.Mp / 128) * cx.N * cx.K)
                                          + (double)cx.Mp * cx.N * 2);
            printf("\n== shape (M=%d N=%d K=%d b=%d) Mp=%d wg=%d ==\n",
                   cx.M, cx.N, cx.K, cx.b, cx.Mp, (cx.Mp / 128) * (cx.N / 64));
            printf("  %-24s %-4s ms=%8.4f  GB/s=%7.1f  vs560=%5.1f%% vs734=%5.1f%%  GF/s=%8.0f  diff=0(ref) SLM=18KB\n",
                   "shipped gemm_b", "raw", bestb, bytesR / (bestb / 1e3) / 1e9,
                   100.0 * (bytesR / (bestb / 1e3) / 1e9) / 560.0,
                   100.0 * (bytesR / (bestb / 1e3) / 1e9) / 734.0,
                   2.0 * cx.M * cx.N * cx.K * cx.b / (bestb / 1e3) / 1e9);
            printf("  %-24s %-4s ms=%8.4f  GB/s=%7.1f  vs560=%5.1f%% vs734=%5.1f%%  GF/s=%8.0f  diff=0(ref) SLM=18KB\n",
                   "shipped gemm_b_pub", "pub", bestp, bytesP / (bestp / 1e3) / 1e9,
                   100.0 * (bytesP / (bestp / 1e3) / 1e9) / 560.0,
                   100.0 * (bytesP / (bestp / 1e3) / 1e9) / 734.0,
                   2.0 * cx.M * cx.N * cx.K * cx.b / (bestp / 1e3) / 1e9);
        }

        // ---- the sweep (raw vs shipped C32ref; pub vs shipped half pubref) ----
#define VLIST(X) \
        X(64, 32, 32, 2, 0, d1)          X(64, 32, 32, 4, 0, d3)           \
        X(64, 64, 32, 2, 0, bk64_d1)     X(64, 64, 32, 3, 0, bk64_d2)      \
        X(128, 32, 64, 3, 1, bn128_nt64)                                    \
        X(128, 64, 64, 2, 1, bn128_nt64_bk64_d1)                            \
        X(128, 64, 64, 3, 1, bn128_nt64_bk64_d2)                            \
        X(128, 32, 32, 3, 2, bn128_ser_d2)                                 \
        X(128, 32, 32, 4, 2, bn128_ser_d3)                                 \
        X(128, 64, 32, 2, 2, bn128_ser_bk64_d1)                             \
        X(128, 32, 32, 3, 3, bn128_naive)
#define VPUB(BNV, BKV, NTV, NBUF, MODE, NM) do { \
        run_variant<BNV, BKV, NTV, NBUF, MODE, false>(cx, #NM); \
        run_variant<BNV, BKV, NTV, NBUF, MODE, true>(cx, #NM); } while (0);
        VLIST(VPUB);
#undef VPUB
#undef VLIST

        free(dA, q); free(dB, q);
        free(cx.dAp, q); free(cx.dAp64, q); free(cx.dBp, q);
        free(cx.das, q); free(cx.dbs, q);
        free(cx.dC32ref, q); free(cx.dC32v, q); free(cx.dCref, q); free(cx.dCv, q);
    }
    return 0;
}
