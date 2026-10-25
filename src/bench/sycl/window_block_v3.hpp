// window_block_v3.hpp -- section 99: v2 with the per-window scratch in SLM (64KB IGC cap
// proven by bench_slm128: slm_init<65536> RUNS, 81920+ REJECTED by IGC). The 108KB
// GLOBAL slice (the §2 rule-2 violation: intermediates round-trip through global) becomes
// a 45KB lifetime-ALIASED SLM map (all regions below fit 64KB WITHOUT aliasing -- see the
// region table). Same phases, same tiles, same math: addressing goes through the slm_*
// helpers (byte offsets). Opt-in NR_WB_V3; v2 (NR_WB_V2) and split stay untouched.
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

namespace wbv3 {
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

// branch-free vectorized e4m3 (bench_e4m3vec.cpp: 0/4096 bit-exact vs qr_e4m3_scalar over
// random +-500 + clamp/tie/-0.0 edges). esimd::rnde == the scalar floor+tie-to-even chain
// for t in [0,16); sign via the (x<0) PREDICATE (mask converts to 0/1, so <<31), NOT the
// sign bit -- -0.0 must map to +0 exactly like the golden's `x < 0.0f ? -r : r`.
template<int N>
static esimd::simd<float,N> e4m3_vec(esimd::simd<float,N> x){
    esimd::simd<float,N> mag = esimd::abs(x);
    mag = (esimd::min)(mag, esimd::simd<float,N>(448.0f));
    esimd::simd<int32_t,N> mb; mb = mag.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> exp = (mb >> 23) & esimd::simd<int32_t,N>(0xFF);
    exp = (esimd::max)(exp, esimd::simd<int32_t,N>(121)) - 3;
    esimd::simd<int32_t,N> sb = exp << 23; esimd::simd<float,N> step; step = sb.template bit_cast_view<float>();
    esimd::simd<int32_t,N> rb = (esimd::simd<int32_t,N>(254) - exp) << 23; esimd::simd<float,N> recip; recip = rb.template bit_cast_view<float>();
    esimd::simd<float,N> t = mag * recip;
    esimd::simd<float,N> r = esimd::rnde<float>(t) * step;
    esimd::simd<int32_t,N> ri; ri = r.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> negm = x < esimd::simd<float,N>(0.0f);
    esimd::simd<int32_t,N> out = (ri & esimd::simd<int32_t,N>(0x7FFFFFFF)) | (negm << 31);
    esimd::simd<float,N> res; res = out.template bit_cast_view<float>();
    return res;
}

// vectorized half-round multiply: eh_mul(a,b) = (float)(half)(a*b) done on a whole simd.
// The f32 product is a single correctly-rounded mul (no add to contract), convert<half>
// rounds once, convert<float> back -- identical to the scalar eh_mul per lane.
static inline esimd::simd<float,32> mulh(esimd::simd<float,32> v, float s){
    return esimd::convert<float>(esimd::convert<half>(v * esimd::simd<float,32>(s)));
}
// cosine_recip on a whole-row simd (the ctree reduce order VERBATIM from
// wbmega::cosine_recip_esimd; h[i] with constant i is a register extract, so the 8-slot
// reduce is bit-identical by construction -- only the 32-channel round/e4m3 got vectorized).
static inline float cosine_recip_vec(esimd::simd<float,32> h){
    float partial[4][2];
    for (int lane=0;lane<4;++lane) for (int p=0;p<2;++p){
        int ch=lane*2+p;
        float first  = wbmega::eh_hfma(h[ch+8],  h[ch+8],  wbmega::eh_mul(h[ch],      h[ch]));
        float second = wbmega::eh_hfma(h[ch+24], h[ch+24], wbmega::eh_mul(h[ch+16],   h[ch+16]));
        partial[lane][p]=wbmega::eh_add(first,second);
    }
    float two[4][2], one[4][2];
    for (int lane=0;lane<4;++lane) for (int p=0;p<2;++p) two[lane][p]=wbmega::eh_add(partial[lane][p],partial[lane^2][p]);
    for (int lane=0;lane<4;++lane) for (int p=0;p<2;++p) one[lane][p]=wbmega::eh_add(two[lane][p],two[lane^1][p]);
    float norm=wbmega::eh_add(one[0][0],one[0][1]);
    float floorv=wbmega::eh_round(ctree::COSINE_NORM_FLOOR);
    norm = norm>floorv?norm:floorv;
    return wbmega::eh_round(1.0f / wbmega::esqrt(norm));
}

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

// ---- SLM map (BYTE offsets; every region 16B-aligned; total 46080 B < 65536) ----
// lifetime aliasing NOT needed at 45KB -- but we still pack tightly for headroom:
//   AQO  Aqkv pack  (M=64 K=32 halfs)      4096 B   [0,4096)
//   DCQ  dCq f32 64x96                    24576 B   [4096,28672)
//   QPO  Q pack                            4096 B   [28672,32768)
//   KTO  K^T pack                          4096 B   [32768,36864)
//   VPO  V pack                            4096 B   [36864,40960)
//   DSC  scores f32 64x64                 16384 B   [40960,57344)
//   PPO  probs pack (M=64 K=64 halfs)      8192 B   [57344,65536)  -- OVERLAP with
//        (PPO is born after DSC dies at P4's end; DSC+PPO = 24KB but they never
//         coexist: P4 reads DSC rows then writes PPO for ITS OWN row only, and P5
//         reads PPO+VPO. To be safe against cross-row races we DO NOT overlap:
//         see the packed map below that fits everything in 64KB without aliasing.)
// Packed no-alias map (bytes):
//   AQO 0..4096 | DCQ 4096..28672 | QPO 28672..32768 | KTO 32768..36864 |
//   VPO 36864..40960 | DSC 40960..57344 | PPO 57344..65536 = 64KB EXACT.
//   DCT (8KB) + ATO (4KB) + DPJ (8KB) + WGT (16KB) do NOT fit unaliased -> alias by
//   lifetime: DCT reuses DCQ's head (DCQ dead after P2's last pass barrier),
//   ATO reuses QPO+KTO (both dead after P3), DPJ reuses DSC (dead after P4),
//   WGT reuses DCQ+DCT (dead after P5; P4's wf staging is BEFORE P5 -- careful:
//   WGT is written IN P4 while DCQ is read IN P4 (row r of DSC only). WGT aliases
//   DCQ's region [4096..20480) which P4 no longer reads (P4 reads DSC, not DCQ).
//   DSC is read by P4 rows r=lid (each thread one row) and PPO written per row --
//   no cross-thread DSC reads after P4's barrier. SAFE.
constexpr uint AQO  = 0;         // 4096 B
constexpr uint DCQ  = 4096;      // 24576 B
constexpr uint QPO  = 28672;     // 4096 B
constexpr uint KTO  = 32768;     // 4096 B
constexpr uint VPO  = 36864;     // 4096 B
constexpr uint DSC  = 40960;     // 16384 B
constexpr uint PPO  = 57344;     // 8192 B  (ends exactly at 65536)
constexpr uint DCT  = DCQ;       // 8192 B  (DCQ dead after P2 barrier)
constexpr uint ATO  = QPO;       // 4096 B  (QPO/KTO dead after P3 barrier)
constexpr uint DPJ  = DSC;       // 8192 B  (DSC dead after P4 barrier)
constexpr uint WGT  = DCQ;       // 16384 B (DCQ/DCT dead after P5; P4 writes WGT,
                                 // reads DSC only -- no clash with DCQ)
constexpr uint SLM_BYTES = 65536;

// ---- SLM addressing helpers (byte offsets) ----
static inline void sh16(uint off, esimd::simd<half,16> v){
    esimd::slm_block_store(off, v, esimd::overaligned_tag<16>{}); }
static inline void sh32(uint off, esimd::simd<half,32> v){
    esimd::slm_block_store(off, v, esimd::overaligned_tag<16>{}); }
static inline esimd::simd<half,32> lh32(uint off){
    return esimd::slm_block_load<half,32>(off, esimd::overaligned_tag<16>{}); }
static inline void sf32(uint off, esimd::simd<float,32> v){
    esimd::slm_block_store(off, v, esimd::overaligned_tag<16>{}); }
static inline esimd::simd<float,32> lf32(uint off){
    return esimd::slm_block_load<float,32>(off, esimd::overaligned_tag<16>{}); }
static inline esimd::simd<float,8> lf8(uint off){
    return esimd::slm_block_load<float,8>(off); }
static inline void sf8(uint off, esimd::simd<float,8> v){ esimd::slm_block_store(off, v); }
static inline esimd::simd<half,16> lh16(uint off){
    return esimd::slm_block_load<half,16>(off, esimd::overaligned_tag<16>{}); }
// the 16x16 dpas tile with SLM A (Ab = byte offset of the A pack block)
static inline void tile8s(esimd::simd<float,64>& c00, esimd::simd<float,64>& c01,
                          esimd::simd<float,64>& c10, esimd::simd<float,64>& c11,
                          uint Ab, const half* Bb, int kb_n, int tc_n){
    for (int kc = 0; kc < kb_n; ++kc) {
        uint ab = Ab + (uint)kc * 2u * 256u;
        const half* bb = Bb + (size_t)kc * (size_t)tc_n * 2u * 128u;
        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(bb, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b1(bb + 128, esimd::overaligned_tag<16>{});
        c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
        c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
        c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
        c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
    }
}
// the 16x16 dpas tile with BOTH operands in SLM
static inline void tile8ss(esimd::simd<float,64>& c00, esimd::simd<float,64>& c01,
                           esimd::simd<float,64>& c10, esimd::simd<float,64>& c11,
                           uint Ab, uint Bb, int kb_n, int tc_n){
    for (int kc = 0; kc < kb_n; ++kc) {
        uint ab = Ab + (uint)kc * 2u * 256u;
        uint bb = Bb + (uint)kc * (uint)tc_n * 2u * 256u;
        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(bb, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(bb + 256, esimd::overaligned_tag<16>{});
        c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
        c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
        c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
        c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
    }
}
// store one 16x16 f32 tile to SLM (off = byte offset of the tile origin; N = row stride FLOATS)
static inline void store16s(uint off, int N, esimd::simd<float,64>& c00,
                            esimd::simd<float,64>& c01, esimd::simd<float,64>& c10,
                            esimd::simd<float,64>& c11){
    for (int r = 0; r < 8; ++r) {
        esimd::simd<float,8> r00=c00.template select<8,1>(r*8), r01=c01.template select<8,1>(r*8);
        esimd::simd<float,8> r10=c10.template select<8,1>(r*8), r11=c11.template select<8,1>(r*8);
        sf8(off + (uint)r*N*4u, r00);        sf8(off + (uint)r*N*4u + 32u, r01);
        sf8(off + (uint)(8+r)*N*4u, r10);    sf8(off + (uint)(8+r)*N*4u + 32u, r11);
    }
}
// scatter one half row (32 values) to SLM via a dest-fn (r,c)->byte offset
template <typename F>
static inline void scatter32(esimd::simd<half,32> oh, F dest){
    auto v = oh.read();
    for (uint c = 0; c < 32u; ++c)
        esimd::slm_block_store(dest(c), esimd::simd<half,1>(v[c]));
}
constexpr uint LW = 64u;         // threads per workgroup = one window (4x SIMD16)

inline sycl::event launch_v3(
    sycl::queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, const half* WprojPacked,
    half* Tgt, float* TgtF, const float* Bias, const float* Cos, const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr)
{
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)windows*LW), range(LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_BYTES>();
            uint window = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);          // 0..63
            uint sgid = lid >> 4, lane = lid & 15u;
            uint top = pad_top, left = pad_left;
            if (stop_stage == 0xFFFFu || stop_stage == 0xFFFEu) return;

            // ===== P0: gather 64 tokens x 32ch -> AQO pack (thread = one token row) =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                uint tr=t>>4, strip=(t>>3)&1u, il=t&7u;
                uint base1 = ((tr*2u+0u)*2u+strip)*128u + il*16u;   // halfs
                uint base2 = ((tr*2u+1u)*2u+strip)*128u + il*16u;
                esimd::simd<float,32> v;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    if (image_half) {
                        esimd::simd<half,32> hv((const half*)Img + at, esimd::overaligned_tag<16>{});
                        v = esimd::convert<float>(hv);
                    } else {
                        v = esimd::simd<float,32>((const float*)Img + at, esimd::overaligned_tag<16>{});
                    }
                } else v = esimd::simd<float,32>(0.0f);
                esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(v));
                sh16(AQO + base1*2u, oh.template select<16,1>(0).read());
                sh16(AQO + base2*2u, oh.template select<16,1>(16).read());
            }
            group_barrier(it.get_group());
            if (stop_stage == 1u) {
                if (DumpKV) for (uint c = 0; c < 2048u; c += 64u)
                    DumpKV[(size_t)window*4096u + c + lid] = lh16(AQO + (c+lid)*2u)[0];
                return;
            }

            // ===== P1: QKV gemm M=64 x N=96, K=32: 24 tiles / 4 SGs =====
            for (uint tile = sgid; tile < 24u; tile += 4u) {
                uint tr = tile / 6u, tc = tile % 6u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8s(c00,c01,c10,c11, AQO + tr*1024u, WqkvPacked + (size_t)tc*256u, 2, 6);
                store16s(DCQ + (tr*16u)*96u*4u + tc*16u*4u, 96, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 2u) {
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = half(lf32(DCQ + lid*96u*4u + 32u*4u)[c]);
                return;
            }

            // ===== P2: normalize + scatter packs (pass = Q,K,V over the rows) =====
            for (uint pass = 0; pass < 3u; ++pass) {
                uint r = lid;
                esimd::simd<float,32> hv = lf32(DCQ + (r*96u + pass*32u)*4u);
                if (pass == 2u) {                         // V: raw e4m3 -> pack
                    esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(hv));
                    auto ov = oh.read();
                    for (uint c = 0; c < 32; ++c)
                        esimd::slm_block_store(VPO + pb16_dest_kn(r,c,4u,2u)*2u, esimd::simd<half,1>(ov[c]));
                } else {
                    esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(hv));
                    float recip = cosine_recip_vec(hr);
                    if (pass == 0u) {                     // Q: * scale -> QPO
                        float sc = wbmega::eh_round(QkvScale[0]);
                        esimd::simd<float,32> qv = mulh(mulh(hr, recip), sc);
                        esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(qv));
                        uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                        sh16(QPO + (((tr*2u+0u)*2u+strip)*128u + il*16u)*2u, oh.template select<16,1>(0).read());
                        sh16(QPO + (((tr*2u+1u)*2u+strip)*128u + il*16u)*2u, oh.template select<16,1>(16).read());
                    } else {                              // K: -> KTO (transposed map)
                        esimd::simd<float,32> kv = mulh(hr, recip);
                        esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(kv));
                        auto ov = oh.read();
                        for (uint c = 0; c < 32; ++c)
                            esimd::slm_block_store(KTO + pb16t_dest(r,c,2u,4u)*2u, esimd::simd<half,1>(ov[c]));
                    }
                }
                group_barrier(it.get_group());
            }
            if (stop_stage == 3u) {
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = lh16(KTO + pb16t_dest(lid,c,2u,4u)*2u)[0];
                return;
            }

            // ===== P3: scores = Q.K^T, M=64 N=64 K=32: 16 tiles =====
            for (uint tile = sgid; tile < 16u; tile += 4u) {
                uint tr = tile >> 2, tc = tile & 3u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8ss(c00,c01,c10,c11, QPO + tr*1024u, KTO + tc*512u, 2, 4);
                store16s(DSC + (tr*16u)*64u*4u + tc*16u*4u, 64, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 5u) {
                if (DumpKV) for (uint c = 0; c < 64; ++c)
                    DumpKV[(size_t)window*4096u + lid*64u + c] = half(lf32(DSC + (lid*64u+c)*4u)[0]);
                return;
            }

            // ===== P4: softmax VECTORIZED (m0 spelling; total = sequential f32 sum) =====
            {
                uint r = lid;
                esimd::simd<float,32> s0 = lf32(DSC + r*64u*4u);
                esimd::simd<float,32> s1 = lf32(DSC + (r*64u+32u)*4u);
                size_t boff = (size_t)r * 64u;
                esimd::simd<float,32> b0(Bias+boff), b1(Bias+boff+32);
                esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<half>(s0 + b0));
                esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<half>(s1 + b1));
                esimd::simd<float,32> a0 = esimd::convert<float>(esimd::convert<half>(hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                esimd::simd<float,32> a1 = esimd::convert<float>(esimd::convert<half>(hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                a0 = (esimd::min)((esimd::max)(a0, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                a1 = (esimd::min)((esimd::max)(a1, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                esimd::simd<half,16> he0=esimd::convert<half>(a0.template select<16,2>(0).read());
                esimd::simd<half,16> ho0=esimd::convert<half>(a0.template select<16,2>(1).read());
                esimd::simd<half,16> he1=esimd::convert<half>(a1.template select<16,2>(0).read());
                esimd::simd<half,16> ho1=esimd::convert<half>(a1.template select<16,2>(1).read());
                esimd::simd<uint16_t,16> e0; e0=he0.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> o0; o0=ho0.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> e1; e1=he1.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> o1; o1=ho1.bit_cast_view<uint16_t>();
                esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
                esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
                esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<half,32> w0; w0=t0.bit_cast_view<half>();
                esimd::simd<half,32> w1; w1=t1.bit_cast_view<half>();
                // total: the golden's SEQUENTIAL f32 sum over the 64 half weights, staged
                // to the WGT SLM row (v2 semantics: wf[c] scalar reads; WGT aliases the
                // dead DCQ region, P4 reads DSC only -- no clash).
                sf32(WGT + r*64u*4u, esimd::convert<float>(w0));
                sf32(WGT + (r*64u+32u)*4u, esimd::convert<float>(w1));
                group_barrier(it.get_group());
                float total = 0.0f;
                for (uint c = 0; c < 64u; ++c)
                    total += esimd::slm_block_load<float,1>(WGT + (r*64u+c)*4u)[0];
                group_barrier(it.get_group());
                float trh = wbmega::eh_round(total);
                float recip = wbmega::eh_round(ef_div(1.0f, trh));
                esimd::simd<half,32> oh0 = esimd::convert<half>(e4m3_vec<32>(mulh(esimd::convert<float>(w0), recip)));
                esimd::simd<half,32> oh1 = esimd::convert<half>(e4m3_vec<32>(mulh(esimd::convert<float>(w1), recip)));
                uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                sh16(PPO + (((tr*4u+0u)*2u+strip)*128u + il*16u)*2u, oh0.template select<16,1>(0).read());
                sh16(PPO + (((tr*4u+1u)*2u+strip)*128u + il*16u)*2u, oh0.template select<16,1>(16).read());
                sh16(PPO + (((tr*4u+2u)*2u+strip)*128u + il*16u)*2u, oh1.template select<16,1>(0).read());
                sh16(PPO + (((tr*4u+3u)*2u+strip)*128u + il*16u)*2u, oh1.template select<16,1>(16).read());
            }
            group_barrier(it.get_group());
            if (stop_stage == 6u) {
                if (DumpKV) for (uint c = 0; c < 64; ++c)
                    DumpKV[(size_t)window*4096u + lid*64u + c] = lh16(PPO + pa16_dest(lid,c,4u)*2u)[0];
                return;
            }

            // ===== P5: attnV = probs.V, M=64 N=32 K=64: 8 tiles =====
            for (uint tile = sgid; tile < 8u; tile += 4u) {
                uint tr = tile >> 1, tc = tile & 1u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8ss(c00,c01,c10,c11, PPO + tr*2048u, VPO + tc*512u, 4, 2);
                store16s(DCT + (tr*16u)*32u*4u + tc*16u*4u, 32, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 8u) {
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = half(lf32(DCT + (lid*32u+c)*4u)[0]);
                return;
            }

            // ===== P6: attended e4m3 -> ATO pack, then outproj 8 tiles =====
            {
                uint r = lid;
                esimd::simd<float,32> cv = lf32(DCT + r*32u*4u);
                esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(cv));
                uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                sh16(ATO + (((tr*2u+0u)*2u+strip)*128u + il*16u)*2u, oh.template select<16,1>(0).read());
                sh16(ATO + (((tr*2u+1u)*2u+strip)*128u + il*16u)*2u, oh.template select<16,1>(16).read());
            }
            group_barrier(it.get_group());
            for (uint tile = sgid; tile < 8u; tile += 4u) {
                uint tr = tile >> 1, tc = tile & 1u;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                tile8s(c00,c01,c10,c11, ATO + tr*1024u, WprojPacked + (size_t)tc*256u, 2, 2);
                store16s(DPJ + (tr*16u)*32u*4u + tc*16u*4u, 32, c00,c01,c10,c11);
            }
            group_barrier(it.get_group());
            if (stop_stage == 9u) {
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] = half(lf32(DPJ + (lid*32u+c)*4u)[0]);
                return;
            }

            // ===== P7: residual fma + publish -> image (thread = token row) =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    esimd::simd<float,32> sk, cosv, proj;
                    if (image_half) {
                        esimd::simd<half,32> hh((const half*)Img + at, esimd::overaligned_tag<16>{});
                        sk = esimd::convert<float>(hh);
                    } else sk.copy_from((const float*)Img + at);
                    cosv.copy_from(Cos);
                    proj = lf32(DPJ + t*32u*4u);
                    esimd::simd<float,32> total = sk * cosv + proj;
                    esimd::simd<float,32> pub;
                    if (epilogue == 1u)      pub = e4m3_vec<32>(total);
                    else if (epilogue == 0u) pub = total;
                    else if (epilogue == 4u) pub = esimd::convert<float>(esimd::convert<half>(total));
                    else {   // gate (epi 2/3): scalar fallback via the WGT SLM row
                        sf32(WGT + t*64u*4u, total);
                        esimd::simd<float,32> pv;
                        auto tv0 = lf32(WGT + t*64u*4u), tv1 = lf32(WGT + (t*64u+32u)*4u);
                        auto a0v=tv0.read(), a1v=tv1.read();
                        for (uint c = 0; c < 32; ++c) pv[c] = wbmega::pub_esimd(epilogue, c<16?a0v[c]:a1v[c-16]);
                        pub = pv;
                    }
                    if (narrow) esimd::convert<half>(pub).copy_to(Tgt + at);
                    else pub.copy_to(TgtF + at);
                }
            }
        });
    });
}
} // namespace wbv2
