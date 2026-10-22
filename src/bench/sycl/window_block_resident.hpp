// window_block_resident.hpp -- section 93: the RESIDENT window_block megakernel in STANDARD
// SYCL (not ESIMD). This is the structure the design always called for (window_block.comp's
// own header: "one 8x8 window a workgroup ... Here they never leave the workgroup"): gather
// -> QKV -> normalize -> scores -> softmax -> attnV -> outproj -> residual -> publish in ONE
// dispatch, Q/K/V/probs/context never leaving shared memory. The coopmat chain's ~45ms comes
// from THIS fusion (its gemm ceiling is only 24.8 TOPS), and my split path pays ~10 global
// round-trips per window block instead -- that is the 10x gap the user pointed at.
//
// bench_jmf proved the keystone: joint_matrix (sub_group scope) + local_accessor (SLM) +
// group_barrier, 8 subgroups / 256 threads, cross-subgroup producer/consumer 0/4096 wrong.
// bench_jmt proved the throughput gate: joint_matrix 2.39 vs ESIMD 3.32 TOPS on the real
// QKV shape -- the round-trip elimination dominates, gemm throughput is secondary.
//
// Bit-exactness strategy: this is a STANDARD SYCL kernel, so it uses the EXACT cr_*/qr_*
// primitives the split passes use (fmul_rn/fadd_rn/half_round/e4m3, ctree::cosine_reciprocal)
// -- the same functions the WINDOW_BLOCK gate already proves 100% bit-exact against the
// coopmat golden. The .comp's 4-lane shuffle butterfly is replaced by the scalar per-row
// reciprocal (identical arithmetic, proven equal by the split path's bit-exactness).
//
// SLM layout identical to the .comp: 4096 floats (16KB) = K (halves [0,2048)) | V (halves
// [2048,4096), VALUES=2048) | per-subgroup scratch (floats [2048+256*sub, +256), aliased as
// halves at [scratch*2, +512)).
//
// Opt-in behind NR_RESIDENT_WB in the recorder; the 462ms split path stays the default.
// WINDOW_BLOCK gate + fused 4-run check are the judges.
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
    unsigned epilogue, bool narrow)
{
    return q.submit([&](handler& h) {
        local_accessor<float,1> SLM(range(4096u), h);
        h.parallel_for(nd_range<1>(range((size_t)windows*256u), range(256u)),
            [=](nd_item<1> it) {
            // NOTE: reqd_sub_group_size(32) is NOT used -- it triggers an IGC "divide by
            // zero" compiler crash with joint_matrix. The default subgroup size on this
            // Arc is 32 (proven by bench_jmf, which runs unqualified with sg.get_group_id()
            // covering exactly 8 subgroups correctly). A comment records the dependency.
            float* f32 = SLM.get_pointer();
            half* h16 = (half*)f32;
            uint* u32 = (uint*)f32;
            const uint VALUES = 2048u;                       // V start, in halves
            uint window = (uint)it.get_group(0);
            auto sg = it.get_sub_group();
            uint sub = sg.get_group_id(), local = sg.get_local_linear_id();
            uint row = sub * 8u;
            uint scratch = 2048u + 256u * sub;               // this subgroup's kilobyte, floats
            uint top = pad_top, left = pad_left;
            int y = (int)((window / window_cols) * 8u + sub) - (int)top;
            int x0 = (int)((window % window_cols) * 8u) - (int)left;
            bool row_in = y >= 0 && y < (int)image_h;
            uint lid = (uint)it.get_local_id(0);

            // ---- stage 1: QKV weights (32x96 half = 6KB) into the K/V bytes ----
            // element-wise copy: local_accessor<float> is only 4-byte aligned, so a uint4*
            // reinterpret (16-byte) would be UB. The .comp uses an explicitly-aligned shared
            // block; here we copy half-by-half (bench_lloc proved this path correct).
            for (uint i = lid; i < 32u * 96u; i += 256u) h16[i] = Wqkv[i];
            // ---- stage 2: gather this subgroup's row (8 tokens x 32 ch), e4m3 publish ----
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
            // ---- stage 3: QKV projection + normalize (the .comp's part loop) ----
            jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> query[2];
            half kreg[32], vreg[32];                          // this subgroup's K and V rows
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
                    // normalize: one lane per row (8 lanes). The .comp uses a 4-lane shuffle
                    // butterfly; this SYCL sub_group has no shuffle, so we take the whole row
                    // scalar (ctree::cosine_reciprocal) -- the EXACT chain the split epilogue
                    // uses (proven bit-exact by the WINDOW_BLOCK gate). CRITICAL: read every
                    // lane's row into registers BEFORE any half write overwrites the float
                    // tile -- the half view aliases the first half of it, so an early write
                    // from one lane races another's read. Hence a barrier between read and write.
                    float hv[32];
                    if (local < 8u) for (int c = 0; c < 32; ++c) hv[c] = f32[scratch + local*32u + c];
                    group_barrier(it.get_group());           // all reads complete before overwrite
                    if (local < 8u) {
                        if (part < 2u) {
                            for (int c = 0; c < 32; ++c) hv[c] = qr_half_round(hv[c]);
                            float recip = ctree::cosine_reciprocal(hv);
                            float scale = part == 0u ? qr_half_round(QkvScale[0]) : 1.0f;
                            for (int c = 0; c < 32; ++c) {
                                float value = ctree::cr_hmul(hv[c], recip);
                                if (part == 0u) value = ctree::cr_hmul(value, scale);
                                h16[scratch*2u + local*32u + c] = half(qr_e4m3(value));
                            }
                        } else {
                            for (int c = 0; c < 32; ++c)
                                h16[scratch*2u + local*32u + c] = half(qr_e4m3(hv[c]));
                        }
                    }
                    group_barrier(it.get_group());           // halves visible for read-back
                    // 8-lane read-back (matches the 8-lane normalize): each of the 8 row
                    // lanes takes its full 32-channel half row into registers.
                    if (local < 8u) {
                        for (int c = 0; c < 32; ++c) {
                            if (part == 1u) kreg[c] = h16[scratch*2u + local*32u + c];
                            else if (part == 2u) vreg[c] = h16[scratch*2u + local*32u + c];
                        }
                    }
                    if (part == 0u) {
                        for (uint kk = 0; kk < 2; ++kk)
                            jm::joint_matrix_load(sg, query[kk],
                                multi_ptr<half,access::address_space::local_space>(h16 + scratch*2u + kk*16u), 32u);
                    }
                }
            }
            group_barrier(it.get_group());                   // every subgroup past the weights
            {
                // 8-lane write: each row lane drops its K and V half-rows into the shared
                // K/V regions at the window's token index (row+local), 32 channels each.
                if (local < 8u) {
                    for (int c = 0; c < 32; ++c) {
                        h16[(row + local) * 32u + c] = kreg[c];
                        h16[VALUES + (row + local) * 32u + c] = vreg[c];
                    }
                }
            }
            group_barrier(it.get_group());                   // K and V in place
            // ---- stage 5: scores = Q.K^T + bias, weights() -> kept[8] (two half_keys rounds)
            uint kept[8];
            {
                jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> acc[8];
                for (uint j = 0; j < 8; ++j) jm::joint_matrix_fill(sg, acc[j], 0.f);
                for (uint c = 0; c < 32u; c += 16u)
                    for (uint j = 0; j < 8; ++j) {
                        jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::col_major> key;
                        jm::joint_matrix_load(sg, key,
                            multi_ptr<half,access::address_space::local_space>(h16 + j*8u*32u + c), 32u);
                        jm::joint_matrix_mad(sg, acc[j], query[c/16u], key, acc[j]);
                    }
                uint head_bias = row * 64u;
                for (uint half_keys = 0; half_keys < 2; ++half_keys) {
                    for (uint j = 0; j < 4; ++j)
                        jm::joint_matrix_store(sg, acc[half_keys*4u + j],
                            multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                            jm::layout::row_major);
                    group_barrier(it.get_group());           // logits tile in place
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
            // ---- stage 6: projection weights into K's bytes past the reciprocals ----
            if (lid < 128u) ((uint4*)f32)[64u + lid] = ((const uint4*)Wproj)[lid];
            if (sub < 2u) {
                uint r = sub * 32u + local;
                uint weights_at = (2048u + 256u*(r/8u)) / 4u + (r%8u) * 8u;   // u4 index
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
                            multi_ptr<half,access::address_space::local_space>(h16 + VALUES + c*32u + j*8u), 32u);
                        jm::joint_matrix_mad(sg, context[j], p, v, context[j]);
                    }
                }
                for (uint j = 0; j < 4; ++j)
                    jm::joint_matrix_store(sg, context[j],
                        multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                        jm::layout::row_major);
            }
            group_barrier(it.get_group());
            // ---- stage 9: publish attended e4m3 -> halves, outproj -> projected ----
            {
                for (uint i = 0; i < 8; ++i) h16[scratch*2u + local*8u + i] = half(qr_e4m3(f32[scratch + local*8u + i]));
                group_barrier(it.get_group());
                jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> attended[2];
                for (uint kk = 0; kk < 2; ++kk)
                    jm::joint_matrix_load(sg, attended[kk],
                        multi_ptr<half,access::address_space::local_space>(h16 + scratch*2u + kk*16u), 32u);
                jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> projected[4];
                for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, projected[j], 0.f);
                for (uint kk = 0; kk < 2; ++kk)
                    for (uint j = 0; j < 4; ++j) {
                        jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> w;
                        jm::joint_matrix_load(sg, w,
                            multi_ptr<half,access::address_space::local_space>(h16 + 512u + kk*16u*32u + j*8u), 32u);
                        jm::joint_matrix_mad(sg, projected[j], attended[kk], w, projected[j]);
                    }
                for (uint j = 0; j < 4; ++j)
                    jm::joint_matrix_store(sg, projected[j],
                        multi_ptr<float,access::address_space::local_space>(f32 + scratch + j*8u), 32u,
                        jm::layout::row_major);
            }
            group_barrier(it.get_group());
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
