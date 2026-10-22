// window_block_resident.hpp -- section 93: the RESIDENT window_block megakernel in STANDARD
// SYCL. The design path (window_block.comp: "one 8x8 window a workgroup ... they never leave
// the workgroup"): gather -> QKV -> normalize -> scores -> softmax -> attnV -> outproj ->
// residual -> publish in ONE dispatch, Q/K/V/probs/context never leave shared memory. The
// coopmat chain's ~45ms rests on THIS fusion (its gemm ceiling is only 24.8 TOPS).
//
// ARCHITECTURE PROVEN: bench_jmf keystone (joint_matrix+local_accessor+group_barrier, cross-
// subgroup 0/4096 wrong); bench_jmt throughput gate; the full kernel runs all 5254 steps
// without crashing.
//
// SIMD8 REALITY (section 93, decisive): reqd_sub_group_size(32)+joint_matrix is a HARD toolchain
// conflict -- even the tiny bench_jmf32 keystone hits IGC "divide by zero". So the compiler
// picks SIMD8 (probe: sg size=8, 32 physical subgroups). The .comp persists the Q coopmat
// fragment in registers across stages (correct for SIMD32) but a long-lived fragment gets
// spilled+corrupted under SIMD8 (scores came out NaN). Fixes applied: (a) logical row-group
// mapping via workgroup-linear id (sub=lid/32), NOT sg.get_group_id(); (b) query fragment
// declared+loaded+used ONLY inside stage 5 (never lives across the kernel); (c) Q/K/V written
// DIRECTLY to dedicated non-overlapping SLM stash regions in the part loop (no kreg/vreg
// register arrays -- the register pressure that spilled the scores fragments).
//
// SLM map (in HALVES, h16 index; SLM = 8192 floats = 16384 halves):
//   [0,3072)      WQKV   QKV weights (32x96), read during the part loop
//   [3072,4096)   PROJ   projection weights (32x32=1024), read in stage 9 (never overlaps K/V)
//   [4096,8192)   SCRATCH per-group gemm tiles + probs (floats [2048,4096), 8 groups x 512 halves)
//   [8192,10240)  QSTASH Q per group (8 x 256)
//   [10240,12288) KSTASH K full (64 tokens x 32 ch = 2048)
//   [12288,14336) VSTASH V full (2048)
// No region overlaps another's live-read window, so the part loop can write K/V directly.
//
// Opt-in behind NR_RESIDENT_WB; the 462ms split path stays the default. WINDOW_BLOCK gate +
// fused 4-run check are the judges.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"

namespace wbres {
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;

// the .comp's weights() (window_block.comp:54-62) on one logit pair -> packed u32 of two
// half weights (the bit-pair transform (packed<<5)+0x7FF88000).
static inline uint32_t weights_pair_u32(float l0, float l1) {
    float a0 = cr_add(cr_mul(qr_half_round(l0), 0.044921875f), 1.30078125f);
    float a1 = cr_add(cr_mul(qr_half_round(l1), 0.044921875f), 1.30078125f);
    a0 = sycl::min(sycl::max(a0, 1.03125f), 1.5693359375f);
    a1 = sycl::min(sycl::max(a1, 1.03125f), 1.5693359375f);
    uint32_t packed = (uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a0))
                    | ((uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a1)) << 16);
    uint32_t tr = (packed << 5) + 0x7FF88000u;
    return tr;
}

inline sycl::event launch_resident(
    sycl::queue& q, const void* Img, bool image_half,
    const half* Wqkv, const half* Wproj,
    void* Cout, const float* Bias, const float* Cos, const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr)
{
    return q.submit([&](handler& h) {
        local_accessor<float,1> SLM(range(8192u), h);
        h.parallel_for(nd_range<1>(range((size_t)windows*256u), range(256u)),
            [=](nd_item<1> it) {
            float* f32 = SLM.get_pointer();
            half* h16 = (half*)f32;
            uint* u32 = (uint*)f32;
            const uint PROJ = 3072u;                          // projection weights [3072,4096)
            const uint QSTASH = 8192u;                        // Q per group [8192,10240)
            const uint KSTASH = 10240u;                       // K full [10240,12288)
            const uint VSTASH = 12288u;                       // V full [12288,14336)
            const uint ATTSTASH = 14336u;                     // attended per group [14336,16384)
            uint window = (uint)it.get_group(0);
            auto sg = it.get_sub_group();
            // SIMD8-safe logical mapping: 8 logical groups of 32 lanes via workgroup-linear id.
            uint lid = (uint)it.get_local_id(0);
            uint sub = lid / 32u, local = lid % 32u;
            uint row = sub * 8u;                              // this group's first token
            uint scratch = 2048u + 256u * sub;                // this group's tile, in FLOATS
            uint top = pad_top, left = pad_left;
            int y = (int)((window / window_cols) * 8u + sub) - (int)top;
            int x0 = (int)((window % window_cols) * 8u) - (int)left;
            bool row_in = y >= 0 && y < (int)image_h;

            // ---- stage 1: QKV weights (32x96 half) into [0,3072) ----
            for (uint i = lid; i < 32u * 96u; i += 256u) h16[i] = Wqkv[i];
            // ---- stage 2: gather this group's row (8 tokens x 32 ch), e4m3 publish ----
            {
                uint t = local / 4u, c0 = (local % 4u) * 8u;
                int x = x0 + (int)t;
                if (row_in && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u + c0;
                    for (uint e = 0; e < 8; ++e) {
                        float f = image_half ? (float)((const half*)Img)[at+e] : ((const float*)Img)[at+e];
                        h16[scratch*2u + t*32u + c0 + e] = half(qr_e4m3(f));
                    }
                } else {
                    for (uint e = 0; e < 8; ++e) h16[scratch*2u + t*32u + c0 + e] = half(0.f);
                }
            }
            group_barrier(it.get_group());                   // weights + this row in place
            // ---- stage 3: QKV projection + normalize, write DIRECTLY to QSTASH/KSTASH/VSTASH ----
            {
                jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> rows[2];
                for (uint kk = 0; kk < 2; ++kk)
                    jm::joint_matrix_load(sg, rows[kk],
                        multi_ptr<half,access::address_space::local_space>(h16 + scratch*2u + kk*16u), 32u);
                for (uint part = 0; part < 3; ++part) {
                    jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> acc[4];
                    for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, acc[j], 0.f);
                    for (uint kk = 0; kk < 2; ++kk)
                        for (uint j = 0; j < 4; ++j) {
                            jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> w;
                            jm::joint_matrix_load(sg, w,
                                multi_ptr<half,access::address_space::local_space>(h16 + kk*16u*96u + part*32u + j*8u), 96u);
                            jm::joint_matrix_mad(sg, acc[j], rows[kk], w, acc[j]);
                        }
                    for (uint j = 0; j < 4; ++j)
                        jm::joint_matrix_store(sg, acc[j],
                            multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                            jm::layout::row_major);
                    group_barrier(it.get_group());           // the 8x32 float tile is in place
                    if (local < 8u) {
                        float hv[32];
                        for (int c = 0; c < 32; ++c) hv[c] = f32[scratch + local*32u + c];
                        // destination: part 0 -> QSTASH (this group's 256), part 1 -> KSTASH,
                        // part 2 -> VSTASH (both indexed by the window token row+local).
                        half* dst = (part == 0u) ? (h16 + QSTASH + 256u*sub + local*32u)
                                : (part == 1u) ? (h16 + KSTASH + (row + local) * 32u)
                                : (h16 + VSTASH + (row + local) * 32u);
                        if (part < 2u) {
                            for (int c = 0; c < 32; ++c) hv[c] = qr_half_round(hv[c]);
                            float recip = ctree::cosine_reciprocal(hv);
                            float scale = part == 0u ? qr_half_round(QkvScale[0]) : 1.0f;
                            for (int c = 0; c < 32; ++c) {
                                float value = ctree::cr_hmul(hv[c], recip);
                                if (part == 0u) value = ctree::cr_hmul(value, scale);
                                dst[c] = half(qr_e4m3(value));
                            }
                        } else {
                            for (int c = 0; c < 32; ++c) dst[c] = half(qr_e4m3(hv[c]));
                        }
                    }
                    group_barrier(it.get_group());           // stash halves visible
                }
            }
            if (stop_stage == 3u && DumpKV) {                // dump KSTASH (the K stage 5 will read) for verification in the NEW layout
                for (uint i = 0; i < 2048u; ++i) DumpKV[(size_t)window * 4096u + i] = h16[KSTASH + i];
                return;
            }
            // ---- stage 5: scores = Q.K^T + bias, weights() -> kept[8] (two half_keys rounds) ----
            uint kept[8];
            {
                // query fragment declared + loaded + used ONLY inside this block: a joint_matrix
                // fragment that stays live across to stage 9 (outproj) adds register pressure that
                // spills+corrupts the outproj fragments under SIMD8 (outproj was 6.3% while QKV,
                // which has no such long-lived fragment, is 100%). QSTASH holds the Q halves.
                jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> query[2];
                for (uint kk = 0; kk < 2; ++kk)
                    jm::joint_matrix_load(sg, query[kk],
                        multi_ptr<half,access::address_space::local_space>(h16 + QSTASH + 256u*sub + kk*16u), 32u);
                // scores = Q(8x32) . K^T(32x64) = 8x64, split into two half_keys rounds each
                // using acc[4] (matching the proven QKV acc[4] structure). K read from KSTASH
                // (token-major [64][32], ld=32), loaded col_major to get K^T -- the exact
                // bench_sctest pattern that is 0/512 correct at SIMD8.
                uint head_bias = row * 64u;
                for (uint half_keys = 0; half_keys < 2; ++half_keys) {
                    jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> acc[4];
                    for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, acc[j], 0.f);
                    for (uint c = 0; c < 32u; c += 16u)
                        for (uint j = 0; j < 4; ++j) {
                            jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::col_major> key;
                            jm::joint_matrix_load(sg, key,
                                multi_ptr<half,access::address_space::local_space>(h16 + KSTASH + (half_keys*4u+j)*8u*32u + c), 32u);
                            jm::joint_matrix_mad(sg, acc[j], query[c/16u], key, acc[j]);
                        }
                    for (uint j = 0; j < 4; ++j)
                        jm::joint_matrix_store(sg, acc[j],
                            multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                            jm::layout::row_major);
                    group_barrier(it.get_group());           // logits tile in place
                    if (stop_stage == 5u && DumpKV) {        // dump this round's 8x32 scores tile (no bias) into the window's [64][64] slot
                        for (uint rr = 0; rr < 8u; ++rr)
                            for (uint cc = 0; cc < 32u; ++cc)
                                DumpKV[(size_t)window * 4096u + (row + rr) * 64u + half_keys*32u + cc] = half(f32[scratch + rr*32u + cc]);
                    }
                    for (uint t = 0; t < 4; ++t) {
                        uint at = local * 2u + t * 64u;      // float index into the 8x32 tile
                        uint lrow = at / 32u, lcol = at % 32u;
                        uint bcol = half_keys*32u + lcol;
                        float v0 = f32[scratch + lrow*32u + lcol] + Bias[head_bias + lrow*64u + bcol];
                        float v1 = f32[scratch + lrow*32u + lcol + 1u] + Bias[head_bias + lrow*64u + bcol + 1u];
                        kept[half_keys*4u + t] = weights_pair_u32(v0, v1);
                    }
                }
            }
            for (uint half_keys = 0; half_keys < 2; ++half_keys)
                for (uint t = 0; t < 4; ++t) {
                    uint at = local * 2u + t * 64u;
                    u32[scratch + ((at/32u)*64u + half_keys*32u + at%32u) / 2u] = kept[half_keys*4u + t];
                }
            group_barrier(it.get_group());                   // probs in place for the reciprocals
            // ---- stage 6: projection weights into PROJ; row reciprocals into f32[0..64) ----
            for (uint i = lid; i < 32u * 32u; i += 256u) h16[PROJ + i] = Wproj[i];
            if (sub < 2u) {
                uint r = sub * 32u + local;
                uint weights_at = (2048u + 256u*(r/8u)) / 4u + (r%8u) * 8u;   // u4 index into scratch probs
                float total = 0.0f;
                for (uint i = 0; i < 8; ++i) {
                    uint4 eight = ((const uint4*)f32)[weights_at + i];
                    for (uint w = 0; w < 4; ++w) {
                        uint32_t two = eight[w];
                        total += (float)sycl::bit_cast<sycl::half>((uint16_t)(two & 0xFFFFu));
                        total += (float)sycl::bit_cast<sycl::half>((uint16_t)(two >> 16));
                    }
                }
                f32[r] = qr_half_round(1.0f / qr_half_round(total));
            }
            group_barrier(it.get_group());                   // reciprocals published
            // ---- stage 7: scale the probs by their row's reciprocal ----
            for (uint at = local * 2u; at < 8u*64u; at += 64u) {
                float scale = f32[row + at / 64u];
                uint32_t pair = u32[scratch + at / 2u];
                float p0 = (float)sycl::bit_cast<sycl::half>((uint16_t)(pair & 0xFFFFu));
                float p1 = (float)sycl::bit_cast<sycl::half>((uint16_t)(pair >> 16));
                float first = cr_mul(p0, scale);
                float second = cr_mul(p1, scale);
                u32[scratch + at / 2u] = (uint32_t)sycl::bit_cast<uint16_t>(sycl::half(qr_e4m3(qr_half_round(first))))
                                       | ((uint32_t)sycl::bit_cast<uint16_t>(sycl::half(qr_e4m3(qr_half_round(second)))) << 16);
            }
            group_barrier(it.get_group());                   // scaled probs visible for attnV
            // ---- stage 8: attnV = probs . V -> context ----
            {
                jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> context[4];
                for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, context[j], 0.f);
                for (uint c = 0; c < 64u; c += 16u) {
                    jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> p;
                    jm::joint_matrix_load(sg, p,
                        multi_ptr<half,access::address_space::local_space>(h16 + scratch*2u + c), 64u);
                    for (uint j = 0; j < 4; ++j) {
                        jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> v;
                        jm::joint_matrix_load(sg, v,
                            multi_ptr<half,access::address_space::local_space>(h16 + VSTASH + c*32u + j*8u), 32u);
                        jm::joint_matrix_mad(sg, context[j], p, v, context[j]);
                    }
                }
                for (uint j = 0; j < 4; ++j)
                    jm::joint_matrix_store(sg, context[j],
                        multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                        jm::layout::row_major);
            }
            group_barrier(it.get_group());
            if (stop_stage == 8u && DumpKV) {                // dump attnV context (8x32 floats -> half) for localization vs split dCtx
                for (uint rr = 0; rr < 8u; ++rr)
                    for (uint cc = 0; cc < 32u; ++cc)
                        DumpKV[(size_t)window * 4096u + (row + rr) * 32u + cc] = half(f32[scratch + rr*32u + cc]);
                return;
            }
            // ---- stage 9: publish attended e4m3 -> halves (ATTSTASH), outproj -> projected ----
            {
                // The context tile is 8x32 floats at f32[scratch..scratch+255]. Convert each to
                // an e4m3 half written to the NON-OVERLAPPING ATTSTASH region (the old code wrote
                // h16[scratch*2u+idx] = float slot scratch+idx/2, which aliased the still-read
                // context floats -- self-overwrite + cross-lane race). idx = local*8+i maps to
                // (rr,cc)=(idx/32,idx%32), matching the row-major 8x32 ld=32 attended load.
                for (uint i = 0; i < 8; ++i) {
                    uint idx = local * 8u + i;
                    h16[ATTSTASH + 256u*sub + idx] = half(qr_e4m3(f32[scratch + idx]));
                }
                group_barrier(it.get_group());
                if (stop_stage == 7u && DumpKV) {            // dump attended (e4m3 of context) for this group, vs split dAttended
                    for (uint i = 0; i < 256u; ++i)
                        DumpKV[(size_t)window * 4096u + (row + i/32u) * 32u + (i%32u)] = h16[ATTSTASH + 256u*sub + i];
                    return;
                }
                jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> attended[2];
                for (uint kk = 0; kk < 2; ++kk)
                    jm::joint_matrix_load(sg, attended[kk],
                        multi_ptr<half,access::address_space::local_space>(h16 + ATTSTASH + 256u*sub + kk*16u), 32u);
                jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> projected[4];
                for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, projected[j], 0.f);
                for (uint kk = 0; kk < 2; ++kk)
                    for (uint j = 0; j < 4; ++j) {
                        jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> w;
                        jm::joint_matrix_load(sg, w,
                            multi_ptr<half,access::address_space::local_space>(h16 + PROJ + kk*16u*32u + j*8u), 32u);
                        jm::joint_matrix_mad(sg, projected[j], attended[kk], w, projected[j]);
                    }
                for (uint j = 0; j < 4; ++j)
                    jm::joint_matrix_store(sg, projected[j],
                        multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                        jm::layout::row_major);
            }
            group_barrier(it.get_group());
            if (stop_stage == 9u && DumpKV) {                // dump outproj projected (8x32) for localization vs split dC3
                for (uint rr = 0; rr < 8u; ++rr)
                    for (uint cc = 0; cc < 32u; ++cc)
                        DumpKV[(size_t)window * 4096u + (row + rr) * 32u + cc] = half(f32[scratch + rr*32u + cc]);
                return;
            }
            // ---- stage 10: residual fma(skip, cos, projected) + publish -> image ----
            for (uint e = local * 4u; e < 256u; e += 128u) {
                uint t = e / 32u, c = e % 32u;
                int x = x0 + (int)t;
                if (!row_in || x < 0 || x >= (int)image_w) continue;
                size_t at = ((size_t)y * image_w + (size_t)x) * 32u + c;
                for (uint i = 0; i < 4; ++i) {
                    float sk = image_half ? (float)((const half*)Img)[at+i] : ((const float*)Img)[at+i];
                    float total = sycl::fma(sk, Cos[c + i], f32[scratch + e + i]);
                    float pub = qr_publish(epilogue, total);
                    if (narrow) ((half*)Cout)[at + i] = half(pub);
                    else        ((float*)Cout)[at + i] = pub;
                }
            }
        });
    });
}
} // namespace wbres
