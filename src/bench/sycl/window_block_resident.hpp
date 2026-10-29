// window_block_resident.hpp -- section 94: RESIDENT window_block megakernel with the
// SIMD8-CORRECT workgroup shape: 64 threads = 8 physical subgroups of 8 lanes, each physical
// subgroup owning ONE WINDOW ROW (8 tokens) and holding its own 8x8 joint_matrix fragments.
//
// WHY THIS SHAPE (section 93/94 measurements):
//  - bench_simd: joint_matrix is FORCED to SIMD8 on this toolchain (even a 1-fragment kernel),
//    and reqd_sub_group_size(32)+joint_matrix = IGC divide-by-zero (bench_jmf32). So SIMD32 is
//    unreachable for joint_matrix, period.
//  - bench_esl: in an ESIMD kernel the standard local_accessor is ALSO per-subgroup (0/8 cross-
//    subgroup visibility), so "ESIMD dpas + workgroup-shared SLM" is not available either.
//  - The .comp's shape is 8 subgroups x 32 lanes, one window row each. Under SIMD8 an 8x8 coopmat
//    fragment is held by exactly 8 lanes = ONE physical subgroup. So the faithful mapping is
//    8 subgroups x 8 lanes = 64 threads: each physical subgroup owns one window row and computes
//    every tile EXACTLY ONCE (the 256-thread version computed each logical group's tiles 4x
//    redundantly -- 32 physical subgroups for 8 logical groups), and per-workgroup fragment
//    register pressure drops 4x (the suspected cause of the outproj fragment corruption that the
//    isolated bench_oproj says should never happen: 0/256 correct alone, 6.3% inside the kernel).
//
// Cross-subgroup sharing still uses the PROVEN keystone combo (bench_jmf/bench_lloc): standard
// local_accessor SLM + group_barrier; K/V/Q/attended live in dedicated non-overlapping regions
// (the old in-place K/V write clobbered the weights the next part needed -- section 93's root
// cause for scores NaN, now fixed: scores verified 100%, context verified 100%).
//
// SLM map (floats; 10304 floats = ~40KB; bench_slm proved 64KB fine):
//   halves [0,3072)        WQKV  QKV weights 32x96 (floats [0,1536))
//   halves [3072,4096)     PROJ  proj weights 32x32 (floats [1536,2048))
//   floats  [2048+256g]    SCRATCH per-group 8x32 float tiles (gemm in/out, probs staging)
//   u32     [4096+256g]    PROBS  per-group 8 rows x 32 words (8x64 half probs)
//   halves  [12288+256g]   QSTASH per-group Q 8x32
//   halves  [14336]        KSTASH full K 64 tokens x 32 ch (token-indexed)
//   halves  [16384]        VSTASH full V 64x32 (token-indexed)
//   halves  [18432+256g]   ATTSTASH per-group attended 8x32
//   floats  [10240+8g]     RECIP per-group 8 row reciprocals
// Opt-in behind NR_RESIDENT_WB; the 462ms split path stays the default. Judges: WINDOW_BLOCK-
// style stage dumps (stop=5 scores, stop=9 projected) and the fused 4-run bit-exact check.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"

namespace wbres {
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;

// the .comp's weights() (window_block.comp:54-62) on one logit pair -> packed u32.
static inline uint32_t weights_pair_u32(float l0, float l1) {
    float a0 = cr_add(cr_mul(qr_half_round(l0), 0.044921875f), 1.30078125f);
    float a1 = cr_add(cr_mul(qr_half_round(l1), 0.044921875f), 1.30078125f);
    a0 = sycl::min(sycl::max(a0, 1.03125f), 1.5693359375f);
    a1 = sycl::min(sycl::max(a1, 1.03125f), 1.5693359375f);
    uint32_t packed = (uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a0))
                    | ((uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a1)) << 16);
    return (packed << 5) + 0x7FF88000u;
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
        local_accessor<float,1> SLM(range(10304u), h);
        h.parallel_for(nd_range<1>(range((size_t)windows*64u), range(64u)),
            [=](nd_item<1> it) {
            float* f32 = SLM.get_pointer();
            half* h16 = (half*)f32;
            uint* u32 = (uint*)f32;
            const uint PROJ = 3072u;                          // proj weights halves
            const uint QSTASH = 12288u, KSTASH = 14336u, VSTASH = 16384u, ATTSTASH = 18432u;
            const uint RECIPF = 10240u;                       // reciprocals in FLOATS
            uint window = (uint)it.get_group(0);
            auto sg = it.get_sub_group();
            // ONE physical subgroup (8 SIMD8 lanes) == one logical window row, exactly the
            // .comp's "eight subgroups, each one row of the window" mapped to SIMD8.
            uint sub = sg.get_group_id(), local = sg.get_local_linear_id();   // 0..7 / 0..7
            uint lid = (uint)it.get_local_id(0);                              // 0..63
            uint row = sub * 8u;                                              // first token of the row
            uint scratch = 2048u + 256u * sub;                                // floats
            uint probs = 4096u + 256u * sub;                                  // u32 words
            uint top = pad_top, left = pad_left;
            int y = (int)((window / window_cols) * 8u + sub) - (int)top;      // this subgroup's image row
            int x0 = (int)((window % window_cols) * 8u) - (int)left;
            bool row_in = y >= 0 && y < (int)image_h;

            // ---- stage 1: QKV weights into [0,3072) ----
            for (uint i = lid; i < 32u * 96u; i += 64u) h16[i] = Wqkv[i];
            // ---- stage 2: gather this window row (lane local = token local), e4m3 ----
            {
                int x = x0 + (int)local;
                if (row_in && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    for (uint c = 0; c < 32; ++c) {
                        float f = image_half ? (float)((const half*)Img)[at+c] : ((const float*)Img)[at+c];
                        h16[scratch*2u + local*32u + c] = half(qr_e4m3(f));
                    }
                } else {
                    for (uint c = 0; c < 32; ++c) h16[scratch*2u + local*32u + c] = half(0.f);
                }
            }
            group_barrier(it.get_group());                   // weights + this row in place
            // ---- stage 3: QKV gemm + normalize -> QSTASH / KSTASH / VSTASH directly ----
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
                    if (stop_stage == 2u && DumpKV && part == 1u) {   // raw K gemm acc vs split dCq
                        for (int c = 0; c < 32; ++c)
                            DumpKV[(size_t)window * 4096u + (row + local) * 32u + c] = half(f32[scratch + local*32u + c]);
                        return;
                    }
                    // normalize: lane local owns row local (all 8 lanes active). Write DIRECTLY
                    // to the dedicated stash (never overlaps the still-live weights or scratch).
                    // SPILL FIX (ISA ledger 2, 2026-10-29): this hv[32] array escaped its
                    // element indexing -> private_size=1792B (=32*4*8) + scratch 8192B/thread +
                    // 311 scratch msgs in the GEN asm. 32 named scalars (rv0..rv31; NOT hvN --
                    // the outer half* h16 SLM pointer would be shadowed) + the GENERATED
                    // named-arg twin of the golden's tree (cosine_reciprocal_32, kdis/gen_cr32.py;
                    // identical operation ORDER). K's scale==1.0f multiply is bit-neutral:
                    // cr_hmul(half-representable x, 1.0f) == x exactly.
                    float rv0 = f32[scratch + local*32u + 0u], rv1 = f32[scratch + local*32u + 1u], rv2 = f32[scratch + local*32u + 2u], rv3 = f32[scratch + local*32u + 3u], rv4 = f32[scratch + local*32u + 4u], rv5 = f32[scratch + local*32u + 5u], rv6 = f32[scratch + local*32u + 6u], rv7 = f32[scratch + local*32u + 7u], rv8 = f32[scratch + local*32u + 8u], rv9 = f32[scratch + local*32u + 9u], rv10 = f32[scratch + local*32u + 10u], rv11 = f32[scratch + local*32u + 11u], rv12 = f32[scratch + local*32u + 12u], rv13 = f32[scratch + local*32u + 13u], rv14 = f32[scratch + local*32u + 14u], rv15 = f32[scratch + local*32u + 15u], rv16 = f32[scratch + local*32u + 16u], rv17 = f32[scratch + local*32u + 17u], rv18 = f32[scratch + local*32u + 18u], rv19 = f32[scratch + local*32u + 19u], rv20 = f32[scratch + local*32u + 20u], rv21 = f32[scratch + local*32u + 21u], rv22 = f32[scratch + local*32u + 22u], rv23 = f32[scratch + local*32u + 23u], rv24 = f32[scratch + local*32u + 24u], rv25 = f32[scratch + local*32u + 25u], rv26 = f32[scratch + local*32u + 26u], rv27 = f32[scratch + local*32u + 27u], rv28 = f32[scratch + local*32u + 28u], rv29 = f32[scratch + local*32u + 29u], rv30 = f32[scratch + local*32u + 30u], rv31 = f32[scratch + local*32u + 31u];
                    half* dst = (part == 0u) ? (h16 + QSTASH + 256u*sub + local*32u)
                            : (part == 1u) ? (h16 + KSTASH + (row + local) * 32u)
                            : (h16 + VSTASH + (row + local) * 32u);
                    if (part < 2u) {
                        rv0 = qr_half_round(rv0);
                        rv1 = qr_half_round(rv1);
                        rv2 = qr_half_round(rv2);
                        rv3 = qr_half_round(rv3);
                        rv4 = qr_half_round(rv4);
                        rv5 = qr_half_round(rv5);
                        rv6 = qr_half_round(rv6);
                        rv7 = qr_half_round(rv7);
                        rv8 = qr_half_round(rv8);
                        rv9 = qr_half_round(rv9);
                        rv10 = qr_half_round(rv10);
                        rv11 = qr_half_round(rv11);
                        rv12 = qr_half_round(rv12);
                        rv13 = qr_half_round(rv13);
                        rv14 = qr_half_round(rv14);
                        rv15 = qr_half_round(rv15);
                        rv16 = qr_half_round(rv16);
                        rv17 = qr_half_round(rv17);
                        rv18 = qr_half_round(rv18);
                        rv19 = qr_half_round(rv19);
                        rv20 = qr_half_round(rv20);
                        rv21 = qr_half_round(rv21);
                        rv22 = qr_half_round(rv22);
                        rv23 = qr_half_round(rv23);
                        rv24 = qr_half_round(rv24);
                        rv25 = qr_half_round(rv25);
                        rv26 = qr_half_round(rv26);
                        rv27 = qr_half_round(rv27);
                        rv28 = qr_half_round(rv28);
                        rv29 = qr_half_round(rv29);
                        rv30 = qr_half_round(rv30);
                        rv31 = qr_half_round(rv31);
                        float recip = ctree::cosine_reciprocal_32(rv0, rv1, rv2, rv3, rv4, rv5, rv6, rv7, rv8, rv9, rv10, rv11, rv12, rv13, rv14, rv15, rv16, rv17, rv18, rv19, rv20, rv21, rv22, rv23, rv24, rv25, rv26, rv27, rv28, rv29, rv30, rv31);
                        float scale = part == 0u ? qr_half_round(QkvScale[0]) : 1.0f;
                        float v0 = ctree::cr_hmul(rv0, recip);
                        if (part == 0u) v0 = ctree::cr_hmul(v0, scale);
                        dst[0] = half(qr_e4m3(v0));
                        float v1 = ctree::cr_hmul(rv1, recip);
                        if (part == 0u) v1 = ctree::cr_hmul(v1, scale);
                        dst[1] = half(qr_e4m3(v1));
                        float v2 = ctree::cr_hmul(rv2, recip);
                        if (part == 0u) v2 = ctree::cr_hmul(v2, scale);
                        dst[2] = half(qr_e4m3(v2));
                        float v3 = ctree::cr_hmul(rv3, recip);
                        if (part == 0u) v3 = ctree::cr_hmul(v3, scale);
                        dst[3] = half(qr_e4m3(v3));
                        float v4 = ctree::cr_hmul(rv4, recip);
                        if (part == 0u) v4 = ctree::cr_hmul(v4, scale);
                        dst[4] = half(qr_e4m3(v4));
                        float v5 = ctree::cr_hmul(rv5, recip);
                        if (part == 0u) v5 = ctree::cr_hmul(v5, scale);
                        dst[5] = half(qr_e4m3(v5));
                        float v6 = ctree::cr_hmul(rv6, recip);
                        if (part == 0u) v6 = ctree::cr_hmul(v6, scale);
                        dst[6] = half(qr_e4m3(v6));
                        float v7 = ctree::cr_hmul(rv7, recip);
                        if (part == 0u) v7 = ctree::cr_hmul(v7, scale);
                        dst[7] = half(qr_e4m3(v7));
                        float v8 = ctree::cr_hmul(rv8, recip);
                        if (part == 0u) v8 = ctree::cr_hmul(v8, scale);
                        dst[8] = half(qr_e4m3(v8));
                        float v9 = ctree::cr_hmul(rv9, recip);
                        if (part == 0u) v9 = ctree::cr_hmul(v9, scale);
                        dst[9] = half(qr_e4m3(v9));
                        float v10 = ctree::cr_hmul(rv10, recip);
                        if (part == 0u) v10 = ctree::cr_hmul(v10, scale);
                        dst[10] = half(qr_e4m3(v10));
                        float v11 = ctree::cr_hmul(rv11, recip);
                        if (part == 0u) v11 = ctree::cr_hmul(v11, scale);
                        dst[11] = half(qr_e4m3(v11));
                        float v12 = ctree::cr_hmul(rv12, recip);
                        if (part == 0u) v12 = ctree::cr_hmul(v12, scale);
                        dst[12] = half(qr_e4m3(v12));
                        float v13 = ctree::cr_hmul(rv13, recip);
                        if (part == 0u) v13 = ctree::cr_hmul(v13, scale);
                        dst[13] = half(qr_e4m3(v13));
                        float v14 = ctree::cr_hmul(rv14, recip);
                        if (part == 0u) v14 = ctree::cr_hmul(v14, scale);
                        dst[14] = half(qr_e4m3(v14));
                        float v15 = ctree::cr_hmul(rv15, recip);
                        if (part == 0u) v15 = ctree::cr_hmul(v15, scale);
                        dst[15] = half(qr_e4m3(v15));
                        float v16 = ctree::cr_hmul(rv16, recip);
                        if (part == 0u) v16 = ctree::cr_hmul(v16, scale);
                        dst[16] = half(qr_e4m3(v16));
                        float v17 = ctree::cr_hmul(rv17, recip);
                        if (part == 0u) v17 = ctree::cr_hmul(v17, scale);
                        dst[17] = half(qr_e4m3(v17));
                        float v18 = ctree::cr_hmul(rv18, recip);
                        if (part == 0u) v18 = ctree::cr_hmul(v18, scale);
                        dst[18] = half(qr_e4m3(v18));
                        float v19 = ctree::cr_hmul(rv19, recip);
                        if (part == 0u) v19 = ctree::cr_hmul(v19, scale);
                        dst[19] = half(qr_e4m3(v19));
                        float v20 = ctree::cr_hmul(rv20, recip);
                        if (part == 0u) v20 = ctree::cr_hmul(v20, scale);
                        dst[20] = half(qr_e4m3(v20));
                        float v21 = ctree::cr_hmul(rv21, recip);
                        if (part == 0u) v21 = ctree::cr_hmul(v21, scale);
                        dst[21] = half(qr_e4m3(v21));
                        float v22 = ctree::cr_hmul(rv22, recip);
                        if (part == 0u) v22 = ctree::cr_hmul(v22, scale);
                        dst[22] = half(qr_e4m3(v22));
                        float v23 = ctree::cr_hmul(rv23, recip);
                        if (part == 0u) v23 = ctree::cr_hmul(v23, scale);
                        dst[23] = half(qr_e4m3(v23));
                        float v24 = ctree::cr_hmul(rv24, recip);
                        if (part == 0u) v24 = ctree::cr_hmul(v24, scale);
                        dst[24] = half(qr_e4m3(v24));
                        float v25 = ctree::cr_hmul(rv25, recip);
                        if (part == 0u) v25 = ctree::cr_hmul(v25, scale);
                        dst[25] = half(qr_e4m3(v25));
                        float v26 = ctree::cr_hmul(rv26, recip);
                        if (part == 0u) v26 = ctree::cr_hmul(v26, scale);
                        dst[26] = half(qr_e4m3(v26));
                        float v27 = ctree::cr_hmul(rv27, recip);
                        if (part == 0u) v27 = ctree::cr_hmul(v27, scale);
                        dst[27] = half(qr_e4m3(v27));
                        float v28 = ctree::cr_hmul(rv28, recip);
                        if (part == 0u) v28 = ctree::cr_hmul(v28, scale);
                        dst[28] = half(qr_e4m3(v28));
                        float v29 = ctree::cr_hmul(rv29, recip);
                        if (part == 0u) v29 = ctree::cr_hmul(v29, scale);
                        dst[29] = half(qr_e4m3(v29));
                        float v30 = ctree::cr_hmul(rv30, recip);
                        if (part == 0u) v30 = ctree::cr_hmul(v30, scale);
                        dst[30] = half(qr_e4m3(v30));
                        float v31 = ctree::cr_hmul(rv31, recip);
                        if (part == 0u) v31 = ctree::cr_hmul(v31, scale);
                        dst[31] = half(qr_e4m3(v31));
                    } else {
                        dst[0] = half(qr_e4m3(rv0));
                        dst[1] = half(qr_e4m3(rv1));
                        dst[2] = half(qr_e4m3(rv2));
                        dst[3] = half(qr_e4m3(rv3));
                        dst[4] = half(qr_e4m3(rv4));
                        dst[5] = half(qr_e4m3(rv5));
                        dst[6] = half(qr_e4m3(rv6));
                        dst[7] = half(qr_e4m3(rv7));
                        dst[8] = half(qr_e4m3(rv8));
                        dst[9] = half(qr_e4m3(rv9));
                        dst[10] = half(qr_e4m3(rv10));
                        dst[11] = half(qr_e4m3(rv11));
                        dst[12] = half(qr_e4m3(rv12));
                        dst[13] = half(qr_e4m3(rv13));
                        dst[14] = half(qr_e4m3(rv14));
                        dst[15] = half(qr_e4m3(rv15));
                        dst[16] = half(qr_e4m3(rv16));
                        dst[17] = half(qr_e4m3(rv17));
                        dst[18] = half(qr_e4m3(rv18));
                        dst[19] = half(qr_e4m3(rv19));
                        dst[20] = half(qr_e4m3(rv20));
                        dst[21] = half(qr_e4m3(rv21));
                        dst[22] = half(qr_e4m3(rv22));
                        dst[23] = half(qr_e4m3(rv23));
                        dst[24] = half(qr_e4m3(rv24));
                        dst[25] = half(qr_e4m3(rv25));
                        dst[26] = half(qr_e4m3(rv26));
                        dst[27] = half(qr_e4m3(rv27));
                        dst[28] = half(qr_e4m3(rv28));
                        dst[29] = half(qr_e4m3(rv29));
                        dst[30] = half(qr_e4m3(rv30));
                        dst[31] = half(qr_e4m3(rv31));
                    }
                    group_barrier(it.get_group());           // stash halves visible
                }
            }
            if (stop_stage == 3u && DumpKV) {                // KSTASH as stage 5 will read it
                for (uint cc = 0; cc < 32u; ++cc)
                    DumpKV[(size_t)window * 4096u + (row + local) * 32u + cc] = h16[KSTASH + (row + local)*32u + cc];
                return;
            }
            // ---- stage 5: scores Q.K^T + bias -> weights() -> PROBS ----
            {
                jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> query[2];
                for (uint kk = 0; kk < 2; ++kk)
                    jm::joint_matrix_load(sg, query[kk],
                        multi_ptr<half,access::address_space::local_space>(h16 + QSTASH + 256u*sub + kk*16u), 32u);
                uint head_bias = row * 64u;
                for (uint half_keys = 0; half_keys < 2; ++half_keys) {
                    jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> acc[4];
                    for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, acc[j], 0.f);
                    for (uint c = 0; c < 32u; c += 16u)
                        for (uint j = 0; j < 4; ++j) {
                            // bench_sctest pattern (0/512 correct at SIMD8): K token-major rows,
                            // col_major load -> K^T tiles. VERIFIED producing 100% exact scores.
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
                    if (stop_stage == 5u && DumpKV) {
                        for (uint cc = 0; cc < 32u; ++cc)
                            DumpKV[(size_t)window * 4096u + (row + local) * 64u + half_keys*32u + cc] = half(f32[scratch + local*32u + cc]);
                    }
                    // weights: lane local owns row local, 16 pairs straight into PROBS (the
                    // separate region removes the kept[] registers AND the logits overlap).
                    for (uint cc = 0; cc < 32u; cc += 2u) {
                        uint bcol = half_keys*32u + cc;
                        float v0 = f32[scratch + local*32u + cc] + Bias[head_bias + local*64u + bcol];
                        float v1 = f32[scratch + local*32u + cc + 1u] + Bias[head_bias + local*64u + bcol + 1u];
                        u32[probs + (local*64u + bcol) / 2u] = weights_pair_u32(v0, v1);
                    }
                    group_barrier(it.get_group());
                }
            }
            // ---- stage 6: row sums of the probs -> reciprocals (the .comp's exact chain) ----
            // ALSO load the projection weights into PROJ here (the .comp does it at this point;
            // the 64-thread rewrite initially FORGOT this, which is why projected was 3.1% --
            // outproj was multiplying attended by garbage SLM, not a fragment bug).
            for (uint i = lid; i < 32u * 32u; i += 64u) h16[PROJ + i] = Wproj[i];
            {
                float total = 0.0f;
                for (uint w = 0; w < 32; ++w) {
                    uint32_t two = u32[probs + local*32u + w];
                    total += (float)sycl::bit_cast<sycl::half>((uint16_t)(two & 0xFFFFu));
                    total += (float)sycl::bit_cast<sycl::half>((uint16_t)(two >> 16));
                }
                f32[RECIPF + 8u*sub + local] = qr_half_round(1.0f / qr_half_round(total));
            }
            group_barrier(it.get_group());                   // reciprocals published
            // ---- stage 7: scale the probs by their row's reciprocal (e4m3, packed in place) ----
            {
                float scale = f32[RECIPF + 8u*sub + local];
                for (uint w = 0; w < 32; ++w) {
                    uint32_t pair = u32[probs + local*32u + w];
                    float p0 = (float)sycl::bit_cast<sycl::half>((uint16_t)(pair & 0xFFFFu));
                    float p1 = (float)sycl::bit_cast<sycl::half>((uint16_t)(pair >> 16));
                    float first = cr_mul(p0, scale);
                    float second = cr_mul(p1, scale);
                    u32[probs + local*32u + w] =
                          (uint32_t)sycl::bit_cast<uint16_t>(sycl::half(qr_e4m3(qr_half_round(first))))
                        | ((uint32_t)sycl::bit_cast<uint16_t>(sycl::half(qr_e4m3(qr_half_round(second)))) << 16);
                }
            }
            group_barrier(it.get_group());                   // scaled probs visible for attnV
            // ---- stage 8: attnV = probs . V -> context (VERIFIED 100% in the 256-thread run) ----
            {
                jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> context[4];
                for (uint j = 0; j < 4; ++j) jm::joint_matrix_fill(sg, context[j], 0.f);
                for (uint c = 0; c < 64u; c += 16u) {
                    jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> p;
                    jm::joint_matrix_load(sg, p,
                        multi_ptr<half,access::address_space::local_space>(h16 + 2u*probs + c), 64u);
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
            if (stop_stage == 8u && DumpKV) {                // attnV context vs split dCtx
                for (uint cc = 0; cc < 32u; ++cc)
                    DumpKV[(size_t)window * 4096u + (row + local) * 32u + cc] = half(f32[scratch + local*32u + cc]);
                return;
            }
            // ---- stage 9: attended e4m3 -> ATTSTASH (lane writes its own row -- the old code's
            // half-view write into the still-read float region was a self-aliasing bug), then
            // outproj = attended . PROJ -> projected (bench_oproj says this gemm is correct) ----
            {
                for (uint cc = 0; cc < 32; ++cc)
                    h16[ATTSTASH + 256u*sub + local*32u + cc] = half(qr_e4m3(f32[scratch + local*32u + cc]));
                group_barrier(it.get_group());
                if (stop_stage == 7u && DumpKV) {            // attended as stage 9 will load it
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
            if (stop_stage == 9u && DumpKV) {                // projected vs split dC3
                for (uint cc = 0; cc < 32u; ++cc)
                    DumpKV[(size_t)window * 4096u + (row + local) * 32u + cc] = half(f32[scratch + local*32u + cc]);
                return;
            }
            // ---- stage 10: residual fma(skip, cos, projected) + publish -> image ----
            {
                int x = x0 + (int)local;
                if (row_in && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    for (uint c = 0; c < 32; ++c) {
                        float sk = image_half ? (float)((const half*)Img)[at+c] : ((const float*)Img)[at+c];
                        float total = sycl::fma(sk, Cos[c], f32[scratch + local*32u + c]);
                        float pub = qr_publish(epilogue, total);
                        if (narrow) ((half*)Cout)[at + c] = half(pub);
                        else        ((float*)Cout)[at + c] = pub;
                    }
                }
            }
        });
    });
}
} // namespace wbres
