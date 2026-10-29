// gemm_f16_v1_kernel.hpp -- the f16 dpas GEMM as a reusable header (section 81/81.5:
// layout probe-confirmed, tile standalone GREEN 32x32x32 0 bad). One work-item = one
// 16x16 output tile: 2 A row-strips x 2 B col-strips = 4 dpas per 16-K step, f32
// accumulators, per-row store. Shapes: M padded to 16 by the caller, N %16==0, K %16==0.
//
// Layout (section 81, esimd_f16_dp_probe.cpp LAYOUT TRUE 0/64):
//   A_simd[i*16 + k]                       row-major (i 0..7, k 0..15)
//   B_simd[(k/2)*16 + j_local*2 + (k%2)]   OpsPerChannel=2 packing
//   C[i*8 + j]                             row-major 8x8 per dpas
// pack_a/pack_b below produce exactly these from row-major M x K / K x N halfs.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>

namespace f16v1 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int TS = 16;   // tile side (8x8 per dpas, 2x2 dpas = 16x16)

// A: Mp x K row-major halfs -> Ap blocks indexed (tr, kc, strip).
static inline void pack_a(const half* A, half* Ap, int Mp, int K) {
    int tr_n = Mp / TS, kb_n = K / TS;
    for (int tr = 0; tr < tr_n; ++tr)
        for (int kc = 0; kc < kb_n; ++kc)
            for (int strip = 0; strip < 2; ++strip)
                for (int il = 0; il < 8; ++il)
                    for (int k = 0; k < 16; ++k)
                        Ap[(((size_t)(tr * kb_n + kc) * 2 + strip) * 128) + il * 16 + k] =
                            A[(size_t)(tr * TS + strip * 8 + il) * K + kc * TS + k];
}
// B: K x N row-major halfs -> Bp blocks indexed (kc, tc, jstrip).
static inline void pack_b(const half* B, half* Bp, int K, int N) {
    int kb_n = K / TS, tc_n = N / TS;
    for (int kc = 0; kc < kb_n; ++kc)
        for (int tc = 0; tc < tc_n; ++tc)
            for (int js = 0; js < 2; ++js)
                for (int k = 0; k < 16; ++k)
                    for (int jl = 0; jl < 8; ++jl)
                        Bp[(((size_t)(kc * tc_n + tc) * 2 + js) * 128) + (k / 2) * 16 + jl * 2 + (k % 2)] =
                            B[(size_t)(kc * TS + k) * N + tc * TS + js * 8 + jl];
}

// B TRANSPOSED: the scores leg's K is stored (N, K) row-major (tokens x head_dim), and
// gemm_staged.comp:16 `transposed = flags bit 0` makes ldb default to K -- logical
// B[k][j] = Bmem[j*K + k]. Same dpas operand layout, only the source index flips.
static inline void pack_b_t(const half* B, half* Bp, int K, int N) {
    int kb_n = K / TS, tc_n = N / TS;
    for (int kc = 0; kc < kb_n; ++kc)
        for (int tc = 0; tc < tc_n; ++tc)
            for (int js = 0; js < 2; ++js)
                for (int k = 0; k < 16; ++k)
                    for (int jl = 0; jl < 8; ++jl)
                        Bp[(((size_t)(kc * tc_n + tc) * 2 + js) * 128) + (k / 2) * 16 + jl * 2 + (k % 2)] =
                            B[(size_t)(tc * TS + js * 8 + jl) * K + kc * TS + k];
}

// C = A @ B, f32 accumulate, Mp x N. Ap/Bp packed. Returns the event.
static inline sycl::event gemm(sycl::queue& q, const half* Ap, const half* Bp,
                               float* C, int Mp, int N, int K) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int t = (int)it.get_id(0); int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            float* out = C + (size_t)(tr * TS) * N + tc * TS;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                r00.copy_to(out + (size_t)r * N);       r01.copy_to(out + (size_t)r * N + 8);
                r10.copy_to(out + (size_t)(8 + r) * N); r11.copy_to(out + (size_t)(8 + r) * N + 8);
            }
        });
    });
}

// batched: `batches` independent Mp x N = (Mp x K) @ (K x N) matrices, contiguous per
// batch (Ap at b*Mp*K, Bp at b*K*N, C at b*Mp*N). One launch -- the per-batch host loop
// (4 sync memcpys + 4 malloc/free + 2 launches each, batches up to 2040) was the
// window_attention 34s pathology (section 92). The dpas sequence per tile is IDENTICAL
// to gemm() above -- only the base pointers shift by the batch stride -- so it is
// bit-exact by construction against the loop it replaces.
static inline sycl::event gemm_b(sycl::queue& q, const half* Ap, const half* Bp,
                                 float* C, int Mp, int N, int K, int batches) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * N, cb = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)batches * tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            size_t g = it.get_id(0);
            int b = (int)(g / ((size_t)tr_n * tc_n)); size_t t0 = g % ((size_t)tr_n * tc_n);
            const half* Ab = Ap + (size_t)b * apb; const half* Bb = Bp + (size_t)b * bpb;
            float* Cb = C + (size_t)b * cb;
            int t = (int)t0; int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ab + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bb + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            float* out = Cb + (size_t)(tr * TS) * N + tc * TS;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                r00.copy_to(out + (size_t)r * N);       r01.copy_to(out + (size_t)r * N + 8);
                r10.copy_to(out + (size_t)(8 + r) * N); r11.copy_to(out + (size_t)(8 + r) * N + 8);
            }
        });
    });
}

// gemm_b_merge_scale (section 100 P9-twin): the global_attention attnV leg WITH the
// merge_heads_scale tail folded into the store. The merge pass computes, per output
// index (token, c): half(qr_e4m3(half_round(cr_mul(half_round(dCtx[at*32 + c32]),
// dRecip[at])))) with at = (c/32)*rows + token -- the value dCtx[at*32+c32] IS the
// accumulator fragment we hold (row = token of the head's block, col = c32). So the
// store: v -> eh_round -> *recip[row] -> eh_round -> e4m3_vec (proven identical) ->
// half -> Out[token*CH + head*32 + c32]. dCtx (rows x 32 x heads f32) AND the merge
// launch both vanish. Guards: N==32 (one tc), Mp==rows (the recorder's Mp=ceil16(rows),
// rows%16==0 in-frame), narrow-out half. batch b = head (the heads-contiguous layout).
static inline sycl::event gemm_b_merge_scale(sycl::queue& q, const half* Ap, const half* Bp,
                                             half* Out, const float* dRecip,
                                             int Mp, int N, int K, int batches) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * N;
    const unsigned CH = (unsigned)batches * 32u;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)batches * tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            size_t g = it.get_id(0);
            int b = (int)(g / ((size_t)tr_n * tc_n)); size_t t0 = g % ((size_t)tr_n * tc_n);
            const half* Ab = Ap + (size_t)b * apb; const half* Bb = Bp + (size_t)b * bpb;
            int t = (int)t0; int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ab + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bb + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            // (row, col) of the batch's ctx fragment -> the merge's index map
            for (int r = 0; r < 8; ++r) {
                int tok0 = tr * TS + r, tok1 = tok0 + 8;
                float rc0 = dRecip[(size_t)b * Mp + tok0];    // at = head*rows + token (b=head)
                float rc1 = dRecip[(size_t)b * Mp + tok1];
                esimd::simd<float,8> r00 = c00.template select<8,1>(r*8), r01 = c01.template select<8,1>(r*8);
                esimd::simd<float,8> r10 = c10.template select<8,1>(r*8), r11 = c11.template select<8,1>(r*8);
                auto ms8 = [&](esimd::simd<float,8> v, float rc) SYCL_ESIMD_FUNCTION {
                    esimd::simd<float,8> hr = esimd::convert<float>(esimd::convert<half>(v));
                    esimd::simd<float,8> m  = hr * esimd::simd<float,8>(rc);
                    esimd::simd<float,8> hm = esimd::convert<float>(esimd::convert<half>(m));
                    return esimd::convert<half>(s8v8::e4m3_vec_v8<8>(hm));
                };
                esimd::simd<half,8> o00 = ms8(r00, rc0), o01 = ms8(r01, rc0);
                esimd::simd<half,8> o10 = ms8(r10, rc1), o11 = ms8(r11, rc1);
                size_t base0 = (size_t)tok0 * CH + (size_t)b * 32u + tc * TS;
                size_t base1 = (size_t)tok1 * CH + (size_t)b * 32u + tc * TS;
                o00.copy_to(Out + base0); o01.copy_to(Out + base0 + 8u);
                o10.copy_to(Out + base1); o11.copy_to(Out + base1 + 8u);
            }
        });
    });
}

// gemm_b_pub_f16 (section 100 P12b): the gemm-FAMILY op (xmx_rec_gemm) with the
// publish pass folded into the gemm store -- the ladder (NR_G_STOP) attributed
// 9.4ms to the standalone publish over dC (f32 M x N write + read); this kills
// the dC wire AND the launch. The store map is the publish loop's VERBATIM
// arithmetic: out = oc + g*sc + r*ldc + col, r<M guard, epi0/1/3/4 through the
// bench_pubvec-proven vector pub (pub_vec_v8<8>), epi2 through the SCALAR
// pub_esimd (the -0.0 sign lesson), narrow -> half else f32. CONTIGUOUS fast
// path when ldc==N (the frame's every call): one 8-wide vector publish per
// fragment half-row. Compact (N=16,ldc=4) and ldc!=N stay on the split path
// (recorder guard). v1 geometry (one 16x16 tile per global load) = the shipped
// form of this family (the v2 swap measured NEUTRAL here: NR_G_V2 stays OFF).
static inline sycl::event gemm_b_pub_f16(sycl::queue& q, const half* Ap, const half* Bp,
                                         void* Cout, int M, int Mp, int N, int K, int batches,
                                         unsigned epi, bool narrow, size_t oc, size_t sc,
                                         unsigned ldc, unsigned lda_unused) {
    (void)lda_unused;
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * N;
    sycl::half* Oh = (sycl::half*)Cout;
    float* Of = (float*)Cout;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)batches * tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            size_t g = it.get_id(0);
            int b = (int)(g / ((size_t)tr_n * tc_n)); size_t t0 = g % ((size_t)tr_n * tc_n);
            const half* Ab = Ap + (size_t)b * apb; const half* Bb = Bp + (size_t)b * bpb;
            int t = (int)t0; int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ab + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bb + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            const size_t ob = oc + (size_t)b * sc;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float,8> r00 = c00.template select<8,1>(r*8), r01 = c01.template select<8,1>(r*8);
                esimd::simd<float,8> r10 = c10.template select<8,1>(r*8), r11 = c11.template select<8,1>(r*8);
                int row0 = tr * TS + r, row1 = row0 + 8;
                if (row0 < M) {
                    if (epi == 2u) {   // gate: the SCALAR proven form (the -0.0 lesson)
                        size_t base = ob + (size_t)row0 * ldc + (unsigned)tc * TS;
                        for (int e = 0; e < 8; ++e) {
                            float v0 = s8v8::pub_esimd(epi, r00.read()[e]), v1 = s8v8::pub_esimd(epi, r01.read()[e]);
                            if (narrow) { Oh[base + e] = sycl::half(v0); Oh[base + 8 + e] = sycl::half(v1); }
                            else        { Of[base + e] = v0; Of[base + 8 + e] = v1; }
                        }
                    } else {
                        esimd::simd<float,8> p0 = s8v8::pub_vec_v8<8>(epi, r00), p1 = s8v8::pub_vec_v8<8>(epi, r01);
                        size_t base = ob + (size_t)row0 * ldc + (unsigned)tc * TS;
                        if (narrow) { esimd::simd<half,8> h0 = esimd::convert<half>(p0), h1 = esimd::convert<half>(p1);
                            h0.copy_to(Oh + base); h1.copy_to(Oh + base + 8u); }
                        else { p0.copy_to(Of + base); p1.copy_to(Of + base + 8u); }
                    }
                }
                if (row1 < M) {
                    if (epi == 2u) {
                        size_t base = ob + (size_t)row1 * ldc + (unsigned)tc * TS;
                        for (int e = 0; e < 8; ++e) {
                            float v0 = s8v8::pub_esimd(epi, r10.read()[e]), v1 = s8v8::pub_esimd(epi, r11.read()[e]);
                            if (narrow) { Oh[base + e] = sycl::half(v0); Oh[base + 8 + e] = sycl::half(v1); }
                            else        { Of[base + e] = v0; Of[base + 8 + e] = v1; }
                        }
                    } else {
                        esimd::simd<float,8> p0 = s8v8::pub_vec_v8<8>(epi, r10), p1 = s8v8::pub_vec_v8<8>(epi, r11);
                        size_t base = ob + (size_t)row1 * ldc + (unsigned)tc * TS;
                        if (narrow) { esimd::simd<half,8> h0 = esimd::convert<half>(p0), h1 = esimd::convert<half>(p1);
                            h0.copy_to(Oh + base); h1.copy_to(Oh + base + 8u); }
                        else { p0.copy_to(Of + base); p1.copy_to(Of + base + 8u); }
                    }
                }
            }
        });
    });
}

// gemm_pub -- the f16 gemm with the publish fused into the store (section 92, same lever
// as the int8 gemm_b_pub/gemm_b_res). ffn's pass 1 is gemm(expand) -> dC1 float, then a
// separate publish(3) pass (gate_activation + e4m3) -> dH half. This writes dH (half)
// straight from the accumulator registers, killing the dC1 float scratch + the publish
// pass. pub_esimd(3u, acc) is the gate+e4m3 chain already proven bit-exact by the batched
// epi3 win (s8v8::pub_esimd, defined in gemm_s8_v8_kernel.hpp which libxmx_sycl.cpp
// includes BEFORE this header). M/N/K are TS=16 multiples in the captured ffn, so no
// row cull is needed, but the r<M guard is kept for safety. FFN gate is the judge.
// P8-m (section 100): the ffn_stem pass-A DUAL STORE -- the same dpas sequence as
// gemm() above (bit-identical by construction), but the store writes BOTH the raw
// f32 C (the residual skip the fused-tail reads) AND H[r][c] = half(e4m3(C[r][c]))
// in ONE pass, so the separate publish parallel_for (a 67MB f32 re-read + 33MB
// half write at the stem's M=522240) VANISHES. e4m3 vector = s8v8::pub_vec_v8<8>(1u,·)
// = the bench_pubvec-proven vector==scalar-identical e4m3 (section 99, epi 1/3
// over 1M values) -- the publish loop's qr_e4m3 spelling replaced with its proven
// vector form. The H store guard matches the C store's row bound (rows >= M are
// written to the padded C but NOT to H -- the publish loop was bounded by M*32).
static inline sycl::event gemm_dual_pub(sycl::queue& q, const half* Ap, const half* Bp,
                                        float* C, half* H, int M, int Mp, int N, int K) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int t = (int)it.get_id(0); int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            float* out = C + (size_t)(tr * TS) * N + tc * TS;
            half* hout = H + (size_t)(tr * TS) * N + tc * TS;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                r00.copy_to(out + (size_t)r * N);       r01.copy_to(out + (size_t)r * N + 8);
                r10.copy_to(out + (size_t)(8 + r) * N); r11.copy_to(out + (size_t)(8 + r) * N + 8);
                if ((size_t)(tr * TS + r) < (size_t)M) {
                    esimd::convert<half>(s8v8::pub_vec_v8<8>(1u, r00)).copy_to(hout + (size_t)r * N);
                    esimd::convert<half>(s8v8::pub_vec_v8<8>(1u, r01)).copy_to(hout + (size_t)r * N + 8);
                }
                if ((size_t)(tr * TS + 8 + r) < (size_t)M) {
                    esimd::convert<half>(s8v8::pub_vec_v8<8>(1u, r10)).copy_to(hout + (size_t)(8 + r) * N);
                    esimd::convert<half>(s8v8::pub_vec_v8<8>(1u, r11)).copy_to(hout + (size_t)(8 + r) * N + 8);
                }
            }
        });
    });
}

static inline sycl::event gemm_pub(sycl::queue& q, const half* Ap, const half* Bp,
                                   half* H, int M, int Mp, int N, int K, unsigned epi) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int t = (int)it.get_id(0); int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            half* out = H + (size_t)(tr * TS) * N + tc * TS;
            for (int r = 0; r < 8; ++r) {
                if ((size_t)(tr * TS + r) < (size_t)M) {
                    esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                    esimd::simd<half, 8> h00, h01;
                    for (int e = 0; e < 8; ++e) h00[e] = half(s8v8::pub_esimd(epi, r00.read()[e]));
                    for (int e = 0; e < 8; ++e) h01[e] = half(s8v8::pub_esimd(epi, r01.read()[e]));
                    h00.copy_to(out + (size_t)r * N); h01.copy_to(out + (size_t)r * N + 8);
                }
                if ((size_t)(tr * TS + 8 + r) < (size_t)M) {
                    esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                    esimd::simd<half, 8> h10, h11;
                    for (int e = 0; e < 8; ++e) h10[e] = half(s8v8::pub_esimd(epi, r10.read()[e]));
                    for (int e = 0; e < 8; ++e) h11[e] = half(s8v8::pub_esimd(epi, r11.read()[e]));
                    h10.copy_to(out + (size_t)(8 + r) * N); h11.copy_to(out + (size_t)(8 + r) * N + 8);
                }
            }
        });
    });
}
// gemm_pub_pa16 -- P3 first cut (section 100): gemm_pub whose STORE lands in the
// f16v1 pack_a16 TILE layout of the published halves, i.e. directly as the NEXT
// gemm's A operand. The expand's output tile (tr,tc) IS the projection's A block
// (tr, kc=tc): same 16x16 geometry, and the published half values are exactly
// what pack_a16 would copy from dH (it is a pure gather of those halves). So the
// dH buffer (M x hidden halfs) and the separate pack_a16 pass both disappear --
// per ffn call that is 33MB written + 33MB read + 33MB written + 33MB read + one
// launch removed (16 calls/frame at M=130560). Bit-exactness: the fragment->tile
// map below is pack_a16's OWN index math (dest ((tr*kb_n+kc)*2+strip)*128 +
// il*16 + k, row = tr*16+strip*8+il) applied to the same pub_esimd(3,acc) halves
// gemm_pub stores row-major; rows >= M get explicit zeros (pack_a16 zero-fills
// the pad rows -- the pool tile must not carry garbage into the dpas reads).
static inline sycl::event gemm_pub_pa16(sycl::queue& q, const half* Ap, const half* Bp,
                                        half* Hp_tile, int M, int Mp, int N, int K,
                                        unsigned epi) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int t = (int)it.get_id(0); int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            // THIS tile is the projection's A block (tr, kc=tc) in ITS layout:
            // dest ((tr*kb_n' + kc)*2+strip)*128 with kb_n' = hidden/16 = tc_n
            // (the output's COLUMN-block count -- NOT the expand's kb_n).
            half* tile = Hp_tile + (size_t)((tr * tc_n + tc) * 2) * 128;
            const esimd::simd<half, 8> z8((half)0.f);
            // BLADE-4 (ISA density ledger, 2026-10-29): the scalar pub_esimd loops here
            // (256 calls x ~20 instr = ~5000 instr/WG vs 8 dpas) were the dpas-density
            // killers the census counted (gemm_pub_pa16/gemm_pub = 2035/1359 static
            // instrs at 0.1-0.3% density). Vector twin = pub_vec_v8 (bench_pubvec
            // 1M-value scalar-vs-vec IDENTICAL for epi 0/1/3/4; epi2 keeps the SCALAR
            // -0.0-sign path, the gemm_b_pub_f16 guard VERBATIM).
            if (epi != 2u) {
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<half, 8> h00, h01, h10, h11;
                    if ((size_t)(tr * TS + r) < (size_t)M) {
                        esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                        esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                        h00 = esimd::convert<half>(s8v8::pub_vec_v8<8>(epi, r00));
                        h01 = esimd::convert<half>(s8v8::pub_vec_v8<8>(epi, r01));
                    } else { h00 = z8; h01 = z8; }
                    if ((size_t)(tr * TS + 8 + r) < (size_t)M) {
                        esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                        esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                        h10 = esimd::convert<half>(s8v8::pub_vec_v8<8>(epi, r10));
                        h11 = esimd::convert<half>(s8v8::pub_vec_v8<8>(epi, r11));
                    } else { h10 = z8; h11 = z8; }
                    h00.copy_to(tile + r * 16);        h01.copy_to(tile + r * 16 + 8);
                    h10.copy_to(tile + 128 + r * 16);  h11.copy_to(tile + 128 + r * 16 + 8);
                }
            } else
            for (int r = 0; r < 8; ++r) {
                esimd::simd<half, 8> h00, h01, h10, h11;
                if ((size_t)(tr * TS + r) < (size_t)M) {
                    esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                    for (int e = 0; e < 8; ++e) h00[e] = half(s8v8::pub_esimd(epi, r00.read()[e]));
                    for (int e = 0; e < 8; ++e) h01[e] = half(s8v8::pub_esimd(epi, r01.read()[e]));
                } else { h00 = z8; h01 = z8; }
                if ((size_t)(tr * TS + 8 + r) < (size_t)M) {
                    esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                    for (int e = 0; e < 8; ++e) h10[e] = half(s8v8::pub_esimd(epi, r10.read()[e]));
                    for (int e = 0; e < 8; ++e) h11[e] = half(s8v8::pub_esimd(epi, r11.read()[e]));
                } else { h10 = z8; h11 = z8; }
                h00.copy_to(tile + r * 16);        h01.copy_to(tile + r * 16 + 8);
                h10.copy_to(tile + 128 + r * 16);  h11.copy_to(tile + 128 + r * 16 + 8);
            }
        });
    });
}
// gemm_res -- the f16 gemm with a residual fma + publish fused into the store (section 92).
// ffn_stem pass C: total = fma(skip[i], cos[col], acc); publish(epi). The engine uses
// sycl::fma (one fused rounding); ESIMD's sk*cc+acc auto-contracts to the same FMA (the
// gate_esimd lesson applied correctly). skip is f32 (the raw stem dS), cos is f32[N].
// FFN_STEM gate is the judge.
static inline sycl::event gemm_res(sycl::queue& q, const half* Ap, const half* Bp,
                                   void* Cout, const float* skip, const float* cos,
                                   int M, int Mp, int N, int K, bool narrow, unsigned epi) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int t = (int)it.get_id(0); int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + tc * TS, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                if ((size_t)(tr * TS + r) < (size_t)M) {
                    esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> sk0 = esimd::block_load<float, 8>(skip + (size_t)(tr*TS+r)*N + tc*TS, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> sk1 = esimd::block_load<float, 8>(skip + (size_t)(tr*TS+r)*N + tc*TS + 8, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> pub;
                    for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, sk0[e]*ccl[e] + r00.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8+e] = s8v8::pub_esimd(epi, sk1[e]*cch[e] + r01.read()[e]);
                    size_t out = (size_t)(tr*TS+r)*N + tc*TS;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if ((size_t)(tr * TS + 8 + r) < (size_t)M) {
                    esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                    esimd::simd<float, 8> sk0 = esimd::block_load<float, 8>(skip + (size_t)(tr*TS+8+r)*N + tc*TS, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> sk1 = esimd::block_load<float, 8>(skip + (size_t)(tr*TS+8+r)*N + tc*TS + 8, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> pub;
                    for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, sk0[e]*ccl[e] + r10.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8+e] = s8v8::pub_esimd(epi, sk1[e]*cch[e] + r11.read()[e]);
                    size_t out = (size_t)(tr*TS+8+r)*N + tc*TS;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}
} // namespace f16v1
