// window_block_v2.hpp -- section 96: FUSED window_block as ONE ESIMD workgroup, LW=64
// (4 SIMD16 subgroups per window workgroup -- bench_v2crash proved LW>=128 ESIMD+barrier
// HANGS at scale on this toolchain: the §39 GRF rule, ~128 live ESIMD threads total per
// launch; LW=64 x 2040 windows verified at full scale, modes 0/2/3 all OK).
//
// Engine = the shipped f16v1 dpas tiles (VERBATIM tile8/store16, 39 gates); handoff =
// per-window GLOBAL scratch + group_barrier (bench_esnd3 D/F cross-subgroup visibility);
// arithmetic = per-phase bodies copied from already-certified sources:
//   P2 normalize: wbmega eh_*/cosine_recip_esimd (gate_mega LEG1 bit-exact)
//   P4 softmax:   bench_smesimd recipe (0/262144 bit-exact A/B vs shipped softmax_kernel)
//   P7 publish:   wbmega pub_esimd + ESIMD one-FMA residual (gate-proven)
//   packs:        pack_a16/pack_b16/pack_b16_t index maps inlined (pack_device.hpp, gates)
// Judges: NR_V2_STOP stage-dumps (same files/compares as the joint kernel's 100% audit)
// then the fused 4-run check, then timing. Opt-in NR_WB_V2; split path untouched.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "window_block_mega.hpp"   // eh_round/eh_mul/eh_add, esqrt, cosine_recip_esimd, pub_esimd

namespace wbv2 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ESIMD-exact fp32 single-round helpers (bench_smesimd recipe: simd<float,1> ops are
// never contracted into FMAs; div = hardware correctly-rounded per §20 ESIMD context).
static inline float ef_mul(float a, float b){ return (esimd::simd<float,1>(a)*esimd::simd<float,1>(b))[0]; }
static inline float ef_add(float a, float b){ return (esimd::simd<float,1>(a)+esimd::simd<float,1>(b))[0]; }
static inline float ef_div(float a, float b){ return (esimd::simd<float,1>(a)/esimd::simd<float,1>(b))[0]; }
// no free esimd::fma; in an ESIMD kernel a*b+c lowers to ONE hardware FMA (single
// rounding) == plain-kernel sycl::fma (mega residual comment, gate-proven).
static inline float ef_fma(float a, float b, float c){ return a * b + c; }

// ---- pack index maps (VERBATIM from pack_device.hpp, inlined so phases scatter) ----
static inline uint pa16_dest(uint srow, uint k, uint kb_n){
    uint tr=srow>>4, strip=(srow>>3)&1u, il=srow&7u, kc=k>>4;
    return ((tr*kb_n+kc)*2u+strip)*128u + il*16u + (k&15u);
}
static inline uint pb16t_dest(uint nrow, uint k, uint kb_n, uint tc_n){   // transposed B
    uint tc=nrow>>4, js=(nrow>>3)&1u, jl=nrow&7u;
    uint kc=k>>4, kq=(k>>1)&7u, kpar=k&1u;
    return ((kc*tc_n+tc)*2u+js)*128u + kq*16u + jl*2u + kpar;
}
// pack_b16 row-major-B dest for logical B[k][n] (pack_device.hpp:73): dest =
// ((kc*tc_n+tc)*2+js)*128 + kq*16 + jl*2 + (k&1), kq=(k&15)>>1.
static inline uint pb16_dest_kn(uint k, uint n, uint kb_n, uint tc_n){
    uint kc=k>>4, kk=k&15u;
    uint tc=n>>4, js=(n>>3)&1u, jl=n&7u;
    return ((kc*tc_n+tc)*2u+js)*128u + (kk>>1)*16u + jl*2u + (k&1u);
}

// ---- the 16x16 dpas tile: f16v1::gemm inner VERBATIM (Ab = per-tr A pack base; Bb =
// per-tc B pack base; kc stride tc_n*2*128 = gemm_b pattern) ----
static inline void tile8(esimd::simd<float,64>& c00, esimd::simd<float,64>& c01,
                         esimd::simd<float,64>& c10, esimd::simd<float,64>& c11,
                         const half* Ab, const half* Bb, int kb_n, int tc_n){
    for (int kc = 0; kc < kb_n; ++kc) {
        const half* ab = Ab + (size_t)kc * 2u * 128u;
        const half* bb = Bb + (size_t)kc * (size_t)tc_n * 2u * 128u;
        esimd::simd<half,128> a0(ab, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> a1(ab + 128, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(bb, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b1(bb + 128, esimd::overaligned_tag<16>{});
        c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
        c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
        c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
        c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
    }
}
// store one 16x16 tile f32 (gemm_b pattern VERBATIM; N = row stride of the dest region)
static inline void store16(float* out, int N, esimd::simd<float,64>& c00,
                           esimd::simd<float,64>& c01, esimd::simd<float,64>& c10,
                           esimd::simd<float,64>& c11){
    for (int r = 0; r < 8; ++r) {
        esimd::simd<float,8> r00=c00.template select<8,1>(r*8), r01=c01.template select<8,1>(r*8);
        esimd::simd<float,8> r10=c10.template select<8,1>(r*8), r11=c11.template select<8,1>(r*8);
        r00.copy_to(out + (size_t)r*N);      r01.copy_to(out + (size_t)r*N + 8);
        r10.copy_to(out + (size_t)(8+r)*N);  r11.copy_to(out + (size_t)(8+r)*N + 8);
    }
}

// per-window global slice (HALF offsets; every region multiple of 256B, so all tag<16>
// block loads are 16B-aligned; WS base from the pool is 64B-aligned):
constexpr uint AQO  = 0;         // Aqkv pack (M=64 K=32)              2048
constexpr uint DCQ  = 2048;      // dCq f32 64x96 (as halfs)          12288
constexpr uint QPO  = 14336;     // Q pack (M=64 K=32)                 2048
constexpr uint KTO  = 16384;     // K^T pack (scores B: K=32 N=64)     2048
constexpr uint VPO  = 18432;     // V pack  (attnV B: K=64 N=32)       2048
constexpr uint DSC  = 20480;     // scores f32 64x64                   8192
constexpr uint PPO  = 28672;     // probs pack (M=64 K=64)             4096
constexpr uint DCT  = 32768;     // ctx f32 64x32                      4096
constexpr uint ATO  = 36864;     // attended pack (M=64 K=32)          2048
constexpr uint DPJ  = 38912;     // projected f32 64x32                4096
constexpr uint WSL  = 43008;     // slice total halfs (~84KB)

constexpr uint LW = 64u;         // threads per workgroup = one window (4x SIMD16)

inline sycl::event launch_v2(
    sycl::queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, const half* WprojPacked,   // cached_pack_b_f16 products
    half* Tgt, float* TgtF, const float* Bias, const float* Cos, const float* QkvScale,
    half* WS,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr)
{
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)windows*LW), range(LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            uint window = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);          // 0..63
            uint sgid = lid >> 4, lane = lid & 15u;       // 4 subgroups x 16 lanes
            half* w = WS + (size_t)window * WSL;
            float* f32w = (float*)w;
            uint top = pad_top, left = pad_left;
            if (stop_stage == 0xFFFFu || stop_stage == 0xFFFEu) return;  // probes: launch-only / fill+launch

            // ===== P0: gather 64 tokens x 32ch -> AQO pack. Thread = one token row. =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    for (uint c = 0; c < 32; ++c) {
                        float f = image_half ? (float)((const half*)Img)[at+c]
                                             : ((const float*)Img)[at+c];
                        w[AQO + pa16_dest(t, c, 2u)] = half(qr_e4m3_scalar(f));
                    }
                } else {
                    for (uint c = 0; c < 32; ++c) w[AQO + pa16_dest(t, c, 2u)] = half(0.f);
                }
            }
            group_barrier(it.get_group());
            if (stop_stage == 1u) {                       // AQO pack vs split dAp slice
                if (DumpKV) for (uint c = 0; c < 2048u; c += 64u)
                    DumpKV[(size_t)window*4096u + c + lid] = w[AQO + c + lid];
                return;
            }

            // ===== P1: QKV gemm M=64 x N=96, K=32: 24 tiles / 4 SGs = 6 each =====
            for (uint tile = sgid; tile < 24u; tile += 4u) {
                uint tr = tile / 6u, tc = tile % 6u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8(c00,c01,c10,c11, w + AQO + (size_t)tr*512u, WqkvPacked + (size_t)tc*256u, 2, 6);
                store16(f32w + DCQ/2 + (size_t)(tr*16u)*96u + tc*16u, 96, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 2u) {                       // dCq K-col block vs split_raw
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = half(f32w[DCQ/2 + lid*96u + 32u + c]);
                return;
            }

            // ===== P2: normalize + scatter packs. 64 threads; pass = Q,K,V over the rows.
            // Chain verbatim from the joint kernel + gate_mega (eh_round/cosine_recip_esimd).
            // QPO: Q pack; KTO: K^T pack (scores B); VPO: V pack; (KPO dropped: K only ever
            // feeds the scores-B operand now; the joint kernel's KPO was a QKV-gemm remnant.)
            for (uint pass = 0; pass < 3u; ++pass) {
                uint r = lid;
                const float* src = f32w + DCQ/2 + r*96u + pass*32u;
                if (pass == 2u) {                         // V: raw e4m3 -> pack (no normalize)
                    for (uint c = 0; c < 32; ++c)
                        w[VPO + pb16_dest_kn(r, c, 4u, 2u)] = half(qr_e4m3_scalar(src[c]));
                } else {
                    float hv[32];
                    for (uint c = 0; c < 32; ++c) hv[c] = wbmega::eh_round(src[c]);
                    float recip = wbmega::cosine_recip_esimd(hv);
                    if (pass == 0u) {                     // Q: * scale, -> QPO (gemm A pack)
                        float sc = wbmega::eh_round(QkvScale[0]);
                        for (uint c = 0; c < 32; ++c)
                            w[QPO + pa16_dest(r, c, 2u)] =
                                half(qr_e4m3_scalar(wbmega::eh_mul(wbmega::eh_mul(hv[c], recip), sc)));
                    } else {                              // K: -> KTO (scores-B pack, no QPO needed)
                        for (uint c = 0; c < 32; ++c)
                            w[KTO + pb16t_dest(r, c, 2u, 4u)] =
                                half(qr_e4m3_scalar(wbmega::eh_mul(hv[c], recip)));
                    }
                }
                group_barrier(it.get_group());
            }
            if (stop_stage == 3u) {   // K unpacked via the KTO map (row-major token view)
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = w[KTO + pb16t_dest(lid, c, 2u, 4u)];
                return;
            }

            // ===== P3: scores = Q.K^T, M=64 N=64 K=32: 16 tiles / 4 SGs = 4 each =====
            for (uint tile = sgid; tile < 16u; tile += 4u) {
                uint tr = tile >> 2, tc = tile & 3u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8(c00,c01,c10,c11, w + QPO + (size_t)tr*512u, w + KTO + (size_t)tc*256u, 2, 4);
                store16(f32w + DSC/2 + (size_t)(tr*16u)*64u + tc*16u, 64, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 5u) {                       // raw scores vs split_scores
                if (DumpKV) for (uint c = 0; c < 64; ++c)
                    DumpKV[(size_t)window*4096u + lid*64u + c] = half(f32w[DSC/2 + lid*64u + c]);
                return;
            }

            // ===== P4: softmax (bench_smesimd BIT-EXACT recipe), thread = row =====
            {
                uint r = lid;
                const float* row = f32w + DSC/2 + (size_t)r*64u;
                size_t boff = (size_t)r * 64u;            // heads==1: (r%64)*64
                float wf[64]; float total = 0.0f;
                for (uint c = 0; c < 64u; c += 2u) {
                    float hl0 = wbmega::eh_round(row[c]    + Bias[boff+c]);
                    float hl1 = wbmega::eh_round(row[c+1u] + Bias[boff+c+1u]);
                    float a0 = wbmega::eh_add(wbmega::eh_mul(hl0,0.044921875f),1.30078125f);
                    float a1 = wbmega::eh_add(wbmega::eh_mul(hl1,0.044921875f),1.30078125f);
                    a0 = a0<1.03125f?1.03125f:(a0>1.5693359375f?1.5693359375f:a0);
                    a1 = a1<1.03125f?1.03125f:(a1>1.5693359375f?1.5693359375f:a1);
                    uint32_t packed = (uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a0))
                                    | ((uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a1)) << 16);
                    uint32_t tr_ = (packed << 5) + 0x7FF88000u;
                    sycl::half h0 = sycl::bit_cast<sycl::half>((uint16_t)(tr_ & 0xFFFFu));
                    sycl::half h1 = sycl::bit_cast<sycl::half>((uint16_t)((tr_ >> 16) & 0xFFFFu));
                    total += (float)h0; total += (float)h1;
                    wf[c] = (float)h0; wf[c+1u] = (float)h1;
                }
                float trh = wbmega::eh_round(total);
                float recip = wbmega::eh_round(ef_div(1.0f, trh));   // ESIMD hw div
                for (uint c = 0; c < 64u; ++c)
                    w[PPO + pa16_dest(r, c, 4u)] =
                        half(qr_e4m3_scalar(wbmega::eh_round(ef_mul(wf[c], recip))));
            }
            group_barrier(it.get_group());
            if (stop_stage == 6u) {                       // probs unpacked vs split_probs
                if (DumpKV) for (uint c = 0; c < 64; ++c)
                    DumpKV[(size_t)window*4096u + lid*64u + c] = w[PPO + pa16_dest(lid, c, 4u)];
                return;
            }

            // ===== P5: attnV = probs.V, M=64 N=32 K=64: 8 tiles / 4 SGs = 2 each =====
            for (uint tile = sgid; tile < 8u; tile += 4u) {
                uint tr = tile >> 1, tc = tile & 1u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8(c00,c01,c10,c11, w + PPO + (size_t)tr*1024u, w + VPO + (size_t)tc*256u, 4, 2);
                store16(f32w + DCT/2 + (size_t)(tr*16u)*32u + tc*16u, 32, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 8u) {                       // ctx vs split_ctx
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = half(f32w[DCT/2 + lid*32u + c]);
                return;
            }

            // ===== P6: attended e4m3 -> ATO pack (thread=row), outproj 8 tiles =====
            {
                uint r = lid;
                for (uint c = 0; c < 32; ++c)
                    w[ATO + pa16_dest(r, c, 2u)] = half(qr_e4m3_scalar(f32w[DCT/2 + r*32u + c]));
            }
            group_barrier(it.get_group());
            for (uint tile = sgid; tile < 8u; tile += 4u) {
                uint tr = tile >> 1, tc = tile & 1u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8(c00,c01,c10,c11, w + ATO + (size_t)tr*512u, WprojPacked + (size_t)tc*256u, 2, 2);
                store16(f32w + DPJ/2 + (size_t)(tr*16u)*32u + tc*16u, 32, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 9u) {                       // projected vs split_c3
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = half(f32w[DPJ/2 + lid*32u + c]);
                return;
            }

            // ===== P7: residual fma + publish -> image (thread = token row; in-kernel
            // guard like launch_full's `if(...) continue` -- divergence-safe under ESIMD) =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    for (uint c = 0; c < 32; ++c) {
                        float sk = image_half ? (float)((const half*)Img)[at+c] : ((const float*)Img)[at+c];
                        float total = ef_fma(sk, Cos[c], f32w[DPJ/2 + t*32u + c]);
                        float pub = wbmega::pub_esimd(epilogue, total);
                        if (narrow) Tgt[at + c] = half(pub); else TgtF[at + c] = pub;
                    }
                }
            }
        });
    });
}
} // namespace wbv2
