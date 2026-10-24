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
constexpr uint NRM  = 43008;     // P2 per-thread hv[32] FLOATS (64 rows)  4096 halfs (kills hv[32] stack)
constexpr uint WGT  = 47104;     // P4 per-thread wf[64] FLOATS (64 rows)  8192 halfs (kills wf[64] stack)
constexpr uint WSL  = 55296;     // slice total halfs (~108KB)

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

            // ===== P0: gather 64 tokens x 32ch -> AQO pack. Thread = one token row.
            // VECTORIZED (section 97): one 32-wide e4m3_vec + two 16-half block stores
            // (the pack_a16 map makes each token's 32 channels TWO contiguous 16-half
            // blocks: kc=0 -> base1, kc=1 -> base2). Was 32x scalar qr_e4m3_scalar =
            // masked-SIMD divergence; e4m3_vec is bit-exact (bench_e4m3vec 0/4096). =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                uint tr=t>>4, strip=(t>>3)&1u, il=t&7u;
                uint base1 = ((tr*2u+0u)*2u+strip)*128u + il*16u;   // channels 0..15
                uint base2 = ((tr*2u+1u)*2u+strip)*128u + il*16u;   // channels 16..31
                esimd::simd<float,32> v;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    if (image_half) {
                        esimd::simd<half,32> hv((const half*)Img + at, esimd::overaligned_tag<16>{});
                        v = esimd::convert<float>(hv);
                    } else {
                        v = esimd::simd<float,32>((const float*)Img + at, esimd::overaligned_tag<16>{});
                    }
                } else {
                    v = esimd::simd<float,32>(0.0f);
                }
                esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(v));
                esimd::simd<half,16> o1 = oh.template select<16,1>(0).read();
                esimd::simd<half,16> o2 = oh.template select<16,1>(16).read();
                o1.copy_to(w + AQO + base1);
                o2.copy_to(w + AQO + base2);
            }
            group_barrier(it.get_group());
            if (stop_stage == 1u) {                       // AQO pack vs split dAp slice
                if (DumpKV) for (uint c = 0; c < 2048u; c += 64u)
                    DumpKV[(size_t)window*4096u + c + lid] = w[AQO + c + lid];
                return;
            }

#if V2_TRIM
            if (stop_stage >= 1u) {}   // keep the compiler honest about w/f32w liveness
            return;                    // TRIM probe: body ends after P0
#endif
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
            // VECTORIZED (section 97): the 32-channel round/e4m3/scale go through simd<float,32>
            // (mulh + e4m3_vec, both bit-exact vs the scalar spellings -- convert<half> == (half)
            // is proven by P0's AQO 100%). The ctree reduce (cosine_recip_vec) keeps the VERBATIM
            // scalar op order: h[i] with constant i is a register extract, so it is bit-identical
            // to wbmega::cosine_recip_esimd. Q's pack_a16 map makes each row's 32 channels TWO
            // contiguous 16-half blocks -> block stores. K/V use the transposed pb16t/pb16 maps
            // (interleaved) -> scalar scatter, but FROM the vectorized e4m3 result.
            for (uint pass = 0; pass < 3u; ++pass) {
                uint r = lid;
                const float* src = f32w + DCQ/2 + r*96u + pass*32u;
                esimd::simd<float,32> hv;
                hv.copy_from(src);
                if (pass == 2u) {                         // V: raw e4m3 -> pack (no normalize)
                    esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(hv));
                    for (uint c = 0; c < 32; ++c) w[VPO + pb16_dest_kn(r, c, 4u, 2u)] = oh[c];
                } else {
                    esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(hv));  // 32x eh_round
                    float recip = cosine_recip_vec(hr);
                    if (pass == 0u) {                     // Q: * scale, -> QPO (two 16-half blocks)
                        float sc = wbmega::eh_round(QkvScale[0]);
                        esimd::simd<float,32> qv = mulh(mulh(hr, recip), sc);
                        esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(qv));
                        uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                        uint b1=((tr*2u+0u)*2u+strip)*128u + il*16u;
                        uint b2=((tr*2u+1u)*2u+strip)*128u + il*16u;
                        esimd::simd<half,16> o1=oh.template select<16,1>(0).read();
                        esimd::simd<half,16> o2=oh.template select<16,1>(16).read();
                        o1.copy_to(w + QPO + b1);
                        o2.copy_to(w + QPO + b2);
                    } else {                              // K: -> KTO (transposed map, scalar scatter)
                        esimd::simd<float,32> kv = mulh(hr, recip);
                        esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(kv));
                        for (uint c = 0; c < 32; ++c) w[KTO + pb16t_dest(r, c, 2u, 4u)] = oh[c];
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

            // ===== P4: softmax VECTORIZED (section 97, bench_p4vec2.cpp proved the chain
            // bit-exact 0/16384 at every stage). The earlier attempt double-rounded the
            // affine (mulh half-rounds the product, then convert<half> rounded AGAIN); the
            // fix is the m0 spelling: hl*scale is EXACT in f32 (half x 4-bit mantissa), so
            // keep it f32 and round ONCE after +bias -- matching the scalar chain's FMA
            // contraction (the §92 trap). total stays a SCALAR sequential sum (the golden's
            // sum order); probs use mulh+e4m3_vec (both bit-exact by construction). =====
            {
                uint r = lid;
                const float* row = f32w + DSC/2 + (size_t)r*64u;
                size_t boff = (size_t)r * 64u;            // heads==1: (r%64)*64
                float* wf = f32w + WGT/2 + (size_t)r*64u; // channel-order weights (f32) for the scalar total
                esimd::simd<float,32> s0(row), s1(row+32);
                esimd::simd<float,32> b0(Bias+boff), b1(Bias+boff+32);
                esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<half>(s0 + b0));
                esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<half>(s1 + b1));
                esimd::simd<float,32> a0 = esimd::convert<float>(esimd::convert<half>(hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                esimd::simd<float,32> a1 = esimd::convert<float>(esimd::convert<half>(hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                a0 = (esimd::min)((esimd::max)(a0, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                a1 = (esimd::min)((esimd::max)(a1, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                // bit-pack (even,odd) pairs -> uint32 -> expand to channel-order halfs.
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
                esimd::convert<float>(w0).copy_to(wf);
                esimd::convert<float>(w1).copy_to(wf+32);
                float total = 0.0f;
                for (uint c = 0; c < 64u; ++c) total += wf[c];   // golden's sequential f32 sum
                float trh = wbmega::eh_round(total);
                float recip = wbmega::eh_round(ef_div(1.0f, trh));   // ESIMD hw div
                esimd::simd<half,32> oh0 = esimd::convert<half>(e4m3_vec<32>(mulh(esimd::convert<float>(w0), recip)));
                esimd::simd<half,32> oh1 = esimd::convert<half>(e4m3_vec<32>(mulh(esimd::convert<float>(w1), recip)));
                uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                oh0.template select<16,1>(0).read().copy_to(w + PPO + ((tr*4u+0u)*2u+strip)*128u + il*16u);
                oh0.template select<16,1>(16).read().copy_to(w + PPO + ((tr*4u+1u)*2u+strip)*128u + il*16u);
                oh1.template select<16,1>(0).read().copy_to(w + PPO + ((tr*4u+2u)*2u+strip)*128u + il*16u);
                oh1.template select<16,1>(16).read().copy_to(w + PPO + ((tr*4u+3u)*2u+strip)*128u + il*16u);
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
                // vectorized (section 97): same shape as P2's Q pack (proven 100%) --
                // e4m3_vec on a 32-wide row load, two contiguous 16-half pa16 block stores.
                esimd::simd<float,32> cv; cv.copy_from(f32w + DCT/2 + r*32u);
                esimd::simd<half,32> oh = esimd::convert<half>(e4m3_vec<32>(cv));
                uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                oh.template select<16,1>(0).read().copy_to(w + ATO + ((tr*2u+0u)*2u+strip)*128u + il*16u);
                oh.template select<16,1>(16).read().copy_to(w + ATO + ((tr*2u+1u)*2u+strip)*128u + il*16u);
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

            // ===== P7: residual fma + publish -> image (thread = token row). VECTORIZED
            // (section 97): the probe confirmed the captured window_block uses epi=1
            // (publish = e4m3 ONLY, NO gate) and narrow=1, so the whole row is a 32-wide
            // load + single-FMA residual + e4m3_vec + one 32-half block store (image slots
            // are 32-contiguous, at is a multiple of 32 -> 64B aligned). The gate path
            // (epi 2/3) keeps a scalar fallback for generality (never taken in this walk). =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    esimd::simd<float,32> sk, cosv, proj;
                    if (image_half) {
                        esimd::simd<half,32> h((const half*)Img + at, esimd::overaligned_tag<16>{});
                        sk = esimd::convert<float>(h);
                    } else sk.copy_from((const float*)Img + at);
                    cosv.copy_from(Cos);
                    proj.copy_from(f32w + DPJ/2 + t*32u);
                    esimd::simd<float,32> total = sk * cosv + proj;   // ESIMD single FMA (== sycl::fma, §92)
                    esimd::simd<float,32> pub;
                    if (epilogue == 1u)      pub = e4m3_vec<32>(total);
                    else if (epilogue == 0u) pub = total;
                    else if (epilogue == 4u) pub = esimd::convert<float>(esimd::convert<half>(total));
                    else {   // gate (epi 2/3): scalar fallback via the WGT scratch row (no stack
                        float* tv = f32w + WGT/2 + (size_t)t*64u;   // array; never taken in this walk, epi==1)
                        total.copy_to(tv);
                        esimd::simd<float,32> pv;
                        for (uint c = 0; c < 32; ++c) pv[c] = wbmega::pub_esimd(epilogue, tv[c]);
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
