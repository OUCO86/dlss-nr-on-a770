// ffn_fused_kernel.hpp -- section 100 P3c: the blueprint's real ffn_fused.
// One work-item = one 16-row tile owned by ONE 16-lane subgroup. Expand GEMM (the
// f16v1 gemm_pub dpas order VERBATIM) -> publish(3) on the accumulator -> the gated
// e4m3 halves land in SLM IN THE PROJECTION'S pack_a16 A-block layout (dest =
// ((tr*kb_n2 + kc2)*2 + strip)*128 + il*16 + k; our frag = one 8-col slice, so the
// store is slm_block_store<half,8> at +k) -> esimd::barrier() -> the projection GEMM
// reads A from SLM via wbv3::tile8s (the proven v4ph-head form: SLM A + global
// packed B). The hidden layer NEVER leaves the chip: the Mp*hidden-half tile write
// + read pair (66KB per 16 rows at hidden=128; 33MB+33MB per big call) disappears.
// Residual + final publish stay the SPLIT pass C tail (the gemm_res 1-ULP lesson).
//
// Frame geometry (the gate's shapes): cin=32 -> expand kb_n=2; hidden=128 -> the
// expand's tc_n=8 (8 col-tiles of 16) and the projection's kb_n2=8. The expand's
// 16-col output tile (tr, tc) IS the projection's A block (tr, kc2=tc).
//
// SLM: per subgroup 8 kc2 x 2 strip x 128 halfs x 2B = 4KB; LW=64 -> 4 subgroups =
// 16KB. v4ph runs 45KB at LW=64 -- 16KB is comfortably inside the occupancy rules.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "gemm_s8_v8_kernel.hpp"    // s8v8::pub_esimd (the proven gate+e4m3 chain)
#include "window_block_v3.hpp"      // wbv3::tile8s (SLM-A dpas tile)

namespace ffnt {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// dAp = expand's A tile (pack_a16 of the ffn input); dEp = expand weights pack_b16
// (32 x 128); dPp = projection weights pack_b16 (128 x 32); dC2 = f32 out (Mp x 32)
// exactly as today's pass C gemm writes it -> the split residual tail is unchanged.
static inline event launch_ffn_fused(queue& q, const half* dAp, const half* dEp,
                                     const half* dPp, float* dC2, int M, int Mp) {
    int tr_n = Mp / 16;
    return q.submit([&](handler& h) {
        constexpr uint LW = 64u;   // 4 subgroups of 16 lanes
        h.parallel_for(nd_range<1>(range((size_t)tr_n * LW), range(LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<16384>();
            uint t   = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint sgid = lid >> 4, lane = lid & 15u;
            uint tr = t * 4u + sgid;                 // this subgroup's 16-row tile
            uint slm_sg = sgid * 4096u;              // 4KB per subgroup
            (void)lane;

            // ===== expand: 2 kc steps x 8 tc tiles, f16v1 gemm_pub's dpas order =====
            // frag naming (VERBATIM gemm_pub): c00/c01 = rows tr*16+(0..7) cols
            // tc*16+(0..7)/(8..15); c10/c11 = rows +8. Store each 8-col frag to the
            // projection A block (kc2=tc, strip, il): dest half offset (in THIS
            // subgroup's 4KB region) = (tc*2 + strip)*128 + il*16 + col0in, where
            // col0in = 0 for c00/c10 (cols 0..7 of the block) and 8 for c01/c11.
            for (int tc = 0; tc < 8; ++tc) {
                esimd::simd<float,64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
                for (int kc = 0; kc < 2; ++kc) {
                    const half* ab = dAp + ((size_t)(tr * 2u + kc) * 2u) * 128u;
                    const half* bb = dEp + ((size_t)(kc * 8u + tc) * 2u) * 128u;
                    esimd::simd<half,128> a0(ab, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1(ab + 128, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b0(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1(bb + 128, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                    c10 = esimd::xmx::dpas<8,8,float>(c10, b0, a1);
                    c11 = esimd::xmx::dpas<8,8,float>(c11, b1, a1);
                }
                const esimd::simd<half,8> z8((half)0.f);
                for (int r = 0; r < 8; ++r) {
                    bool in0 = (size_t)(tr*16 + r) < (size_t)M;
                    bool in1 = (size_t)(tr*16 + 8 + r) < (size_t)M;
                    esimd::simd<float,8> r00 = c00.template select<8,1>(r*8);
                    esimd::simd<float,8> r01 = c01.template select<8,1>(r*8);
                    esimd::simd<float,8> r10 = c10.template select<8,1>(r*8);
                    esimd::simd<float,8> r11 = c11.template select<8,1>(r*8);
                    esimd::simd<half,8> h00, h01, h10, h11;
                    if (in0) { for (int e=0;e<8;++e) h00[e]=half(s8v8::pub_esimd(3u, r00.read()[e]));
                               for (int e=0;e<8;++e) h01[e]=half(s8v8::pub_esimd(3u, r01.read()[e])); }
                    else { h00 = z8; h01 = z8; }
                    if (in1) { for (int e=0;e<8;++e) h10[e]=half(s8v8::pub_esimd(3u, r10.read()[e]));
                               for (int e=0;e<8;++e) h11[e]=half(s8v8::pub_esimd(3u, r11.read()[e])); }
                    else { h10 = z8; h11 = z8; }
                    uint off = slm_sg + (uint)(tc*2 + 0)*128u*2u + (uint)r*16u*2u;      // strip0 il=r
                    esimd::slm_block_store<half,8>(off,      h00, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<half,8>(off + 16u, h01, esimd::overaligned_tag<16>{});
                    uint off1 = slm_sg + (uint)(tc*2 + 1)*128u*2u + (uint)r*16u*2u;     // strip1 il=r
                    esimd::slm_block_store<half,8>(off1,      h10, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<half,8>(off1 + 16u, h11, esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();   // subgroup-wide: all 16 lanes' stores visible (the
                                // v4ph head's proven pattern; lane-local SLM + one
                                // barrier -- the senior's ffn_fused keeps the SAME
                                // 16-row ownership so no cross-subgroup sharing here)
            // ===== projection: 8 kc2 steps x 2 tc tiles (32 cols), A from SLM =====
            // dPp blocks: ((kc2*tc_n2 + tc)*2 + js)*128, tc_n2 = 32/16 = 2.
            // dest dC2: f32 Mp x 32 row-major (the pass C gemm's exact output form).
            for (int tc = 0; tc < 2; ++tc) {
                esimd::simd<float,64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
                for (int kc2 = 0; kc2 < 8; ++kc2) {
                    uint ab = slm_sg + (uint)(kc2*2 + 0)*256u;      // tile8s: Ab + kc*2*256
                    const half* bb = dPp + ((size_t)(kc2 * 2u + tc) * 2u) * 128u;
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b0(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1(bb + 128, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                    c10 = esimd::xmx::dpas<8,8,float>(c10, b0, a1);
                    c11 = esimd::xmx::dpas<8,8,float>(c11, b1, a1);
                }
                // raw f32 store (pass C's gemm form, NOT published -- the split tail
                // does fma(skip,cos,acc)+publish on these exact values):
                float* out = dC2 + (size_t)(tr * 16) * 32u + tc * 16u;
                for (int r = 0; r < 8; ++r) {
                    if ((size_t)(tr*16 + r) < (size_t)M) {
                        esimd::simd<float,8> r00 = c00.template select<8,1>(r*8);
                        esimd::simd<float,8> r01 = c01.template select<8,1>(r*8);
                        r00.copy_to(out + (size_t)r * 32u);
                        r01.copy_to(out + (size_t)r * 32u + 8);
                    }
                    if ((size_t)(tr*16 + 8 + r) < (size_t)M) {
                        esimd::simd<float,8> r10 = c10.template select<8,1>(r*8);
                        esimd::simd<float,8> r11 = c11.template select<8,1>(r*8);
                        r10.copy_to(out + (size_t)(8+r) * 32u);
                        r11.copy_to(out + (size_t)(8+r) * 32u + 8);
                    }
                }
            }
        });
    });
}
}
