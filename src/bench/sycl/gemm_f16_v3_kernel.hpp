// gemm_f16_v3_kernel.hpp -- section 99: the LEG-3 FUSION (health form + speed).
// The split window_block's outproj leg is TWO passes today:
//   f16v1::gemm(dAp3, dBp3 -> dC3 f32 [Mp x 32])   then
//   the residual leg (read dC3 + image + cos -> publish -> write target).
// The dC3 f32 scratch is 16.7MB written AND re-read per call (33MB of pure
// intermediate traffic), and the NR_WB_STOP delta says the residual leg costs
// ~3.2ms/call for 33MB = ~10GB/s -- 40x under the card's bandwidth.
// v3 = ONE kernel: the gemm work-item owns a 16-row x 32-col block (the FULL
// channel width, tc_n=2 tiles side by side), and its store loop does
//   total = image[y,x,c] * cos[c] + acc ;  target[y,x,c] = publish(epi, total)
// straight from the accumulator registers. dC3 disappears; the separate launch
// disappears. Every store is 64B contiguous (one token's 32 halfs at a
// 64B-aligned image slot) -- the P4 rule.
//
// BIT-EXACTNESS BY CONSTRUCTION:
//  - the per-16x16-tile dpas sequence/operands are VERBATIM f16v1::gemm (same
//    pack_a16/pack_b blocks, same c00..c11 order); the second tile (tc=1) uses
//    the same a0/a1 with the (kc,1) B block -- identical to two gemm() calls.
//  - the row assembly (which select() slice feeds which channel) is the exact
//    inverse of f16v1::gemm's store16 mapping (verified against :84-89).
//  - the residual math is the standalone leg3's proven ESIMD spelling:
//    sk*cv + acc lowers to ONE HW FMA == sycl::fma (§92 mega-residual, gate
//    proven), publish = wbv2::e4m3_vec<32> (bench_e4m3vec 0/4096 bit-exact).
//  - the crop guard is per-token (same as the scalar leg), NOT per-row-block.
// Scope: the PLAIN form (epi 0/1/4) plus, section 100, the POOL and HEAD forms
// through two extra outlets:
//   Stage (pool): when non-null, the RAW total is stored at the BLOCK layout
//     index r*N+c -- exactly what the split scalar leg wrote to dStage before the
//     independent pool pass (:3228-3229's contract); the pool pass reads it back
//     unchanged. The published outlet is epi=1+narrow (half(e4m3(total)) ==
//     qr_e4m3 scalar, bench_e4m3vec bit-exact).
//   head: no outlet change -- dOut16 IS the narrow target with epi=0
//     (half(total) == the scalar leg's dOut16 store, :3224), image layout `at`.
// SECTION 100 A2 (pool fold, the senior's structure window_block.comp:507-530):
// when Pool != nullptr the 2x2 pool happens INSIDE this kernel -- no Stage buffer,
// no independent pool pass. Structure: work-item tr owns rows tr*16..tr*16+15 of
// the flat block layout = ONE band py=tr%4 of window w=tr/4 (64=4x16), and the
// senior's taps for pooled pixel (py,px) -- tokens py*16+px*2, +8, +1, +9
// (gemm_staged.comp:371-390 order) -- ALL live in this band: rows px*2, px*2+1
// (upper y) and px*2+8, px*2+9 (lower y). So the eight upper-row totals are
// stashed in registers as the rr loop passes, and at rr=px*2+9 the sum
// ((u[px*2]+r[px*2+8])+u[px*2+1])+r[px*2+9] closes: each cr_add == one HW vadd
// (IEEE correctly rounded == fadd_rn, the scalar chain's op), then *0.25 (exact)
// and e4m3_vec (== qr_e4m3, bench_e4m3vec) -> half at the half-resolution image
// index. All-or-none crop (even extents/pads, the recorder's guard): the lower
// row being in-bounds implies its whole 2x2 was stashed.
// The recorder keeps the old two-pass path for everything else.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "window_block_v2.hpp"   // wbv2::e4m3_vec (bit-exact vectorized e4m3)

namespace f16v3 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int TS = 16;

static inline sycl::event gemm_resid_pub(sycl::queue& q, const half* Ap, const half* Bp,
                                         const half* ImgH, const float* ImgF, bool image_half,
                                         const float* cosv, half* TgtH, float* TgtF, bool narrow,
                                         int M, int Mp, int K, unsigned height, unsigned width,
                                         unsigned across, unsigned top, unsigned left,
                                         unsigned epi, float* Stage = nullptr,
                                         bool pool_outlet = false, half* Pool = nullptr) {
    const int N = 32;
    int tr_n = Mp / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int tr = (int)it.get_id(0);
            esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);   // tc=0: cols 0..15
            esimd::simd<float,64> d00(0.f),d01(0.f),d10(0.f),d11(0.f);   // tc=1: cols 16..31
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * 2 + 0) * 2) * 128;
                const half* cb = Bp + ((size_t)(kc * 2 + 1) * 2) * 128;
                esimd::simd<half,128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1(bb + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> e0(cb, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> e1(cb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8,8,float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8,8,float>(c11, b1, a1);
                d00 = esimd::xmx::dpas<8,8,float>(d00, e0, a0);
                d01 = esimd::xmx::dpas<8,8,float>(d01, e1, a0);
                d10 = esimd::xmx::dpas<8,8,float>(d10, e0, a1);
                d11 = esimd::xmx::dpas<8,8,float>(d11, e1, a1);
            }
            esimd::simd<float,32> cv = esimd::block_load<float,32>(
                cosv, esimd::overaligned_tag<16>{});
            // section 100 A2: with a Pool outlet the rows run in the pool's TAP order
            // per pixel -- (UL, LL, UR, LR) for px = 0..3 -- so ((UL+LL)+UR)+LR closes
            // in registers: window_block.comp:523-525's exact chain, each link a plain
            // vadd (== fadd_rn/cr_add; pure adds cannot contract, the §92 hazard is
            // mul+add only). Band structure: rows tr*16..+15 = ONE y-band py=tr%4 of
            // window tr/4 -- every tap lives here, no SLM, no barrier. rr from (px,tap)
            // by pure scalar arithmetic (no arrays: the compiler rejected constant-index
            // register reads once already, the v3 WGT lesson).
            esimd::simd<float,32> pUL, pLL, pUR;
            for (int j = 0; j < TS; ++j) {
                int rr;
                if (Pool) {
                    int px = j >> 2, tap = j & 3;
                    rr = 2*px + ((tap == 0) ? 0 : (tap == 1) ? 8 : (tap == 2) ? 1 : 9);
                } else rr = j;
                int r = tr * TS + rr;
                if (r >= M) continue;
                unsigned window = (unsigned)r / 64u, token = (unsigned)r % 64u;
                unsigned y = (window / across) * 8u + token / 8u;
                unsigned x = (window % across) * 8u + token % 8u;
                if (y < top || x < left || y - top >= height || x - left >= width) continue;
                size_t at = ((size_t)(y - top) * width + (x - left)) * N;
                int qh = rr / 8, rl = rr % 8;          // tile half (rows 0-7 / 8-15), row in tile
                esimd::simd<float,32> acc;
                if (qh == 0) {
                    acc.template select<8,1>(0)  = c00.template select<8,1>(rl*8);
                    acc.template select<8,1>(8)  = c01.template select<8,1>(rl*8);
                    acc.template select<8,1>(16) = d00.template select<8,1>(rl*8);
                    acc.template select<8,1>(24) = d01.template select<8,1>(rl*8);
                } else {
                    acc.template select<8,1>(0)  = c10.template select<8,1>(rl*8);
                    acc.template select<8,1>(8)  = c11.template select<8,1>(rl*8);
                    acc.template select<8,1>(16) = d10.template select<8,1>(rl*8);
                    acc.template select<8,1>(24) = d11.template select<8,1>(rl*8);
                }
                esimd::simd<float,32> sk;
                if (image_half) sk = esimd::convert<float>(esimd::block_load<half,32>(
                    ImgH + at, esimd::overaligned_tag<16>{}));
                else            sk = esimd::block_load<float,32>(
                    ImgF + at, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> total = sk * cv + acc;      // ONE HW FMA per lane (§92)
                if (Pool) {
                    // tap group order: UL, LL, UR, LR -- close the senior chain at LR
                    int tap = j & 3;
                    if (tap == 0)      pUL = total;
                    else if (tap == 1) pLL = total;
                    else if (tap == 2) pUR = total;
                    else {
                        esimd::simd<float,32> s = (pUL + pLL) + pUR;
                        s = s + total;                          // ((UL+LL)+UR)+LR, three vadds
                        s = s * 0.25f;                          // exact (power of two)
                        size_t po = ((size_t)((y - top) / 2u) * (width / 2u)
                                     + ((x - left) / 2u)) * N;
                        esimd::block_store<half,32>(Pool + po,
                            esimd::convert<half>(wbv2::e4m3_vec<32>(s)),
                            esimd::overaligned_tag<16>{});
                    }
                }
                if (Stage) esimd::block_store<float,32>(
                    Stage + (size_t)r * N, total, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> pub;
                if (pool_outlet)  pub = wbv2::e4m3_vec<32>(total);   // == scalar qr_e4m3 (bench_e4m3vec)
                else if (epi == 1u)      pub = wbv2::e4m3_vec<32>(total);
                else if (epi == 0u) pub = total;
                else                pub = esimd::convert<float>(esimd::convert<half>(total)); // epi 4
                if (narrow) esimd::block_store<half,32>(TgtH + at,
                    esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                else        esimd::block_store<float,32>(TgtF + at, pub,
                    esimd::overaligned_tag<16>{});
            }
        });
    });
}
} // namespace f16v3
