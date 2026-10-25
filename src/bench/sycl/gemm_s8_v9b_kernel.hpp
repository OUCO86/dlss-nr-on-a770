// gemm_s8_v9b_kernel.hpp -- section 99: the FUSED-QUANT wide-N producer for the 40
// sa=0 batched->quant pairs (the v9 fold, unblocked). Plan facts (from the shape dump):
// those pairs are (M=8160 N=128 K=128 b=4 ldc=512 sc=128 sa=0) x24 and
// (M=32640 N=128 K=64 b=2 ldc=256 sc=128 sa=0) x16, both epi3 (gate+e4m3) narrow T=1.
// sa=0 => ALL groups share the same A rows => the batched op IS one wide GEMM:
//   C[r][n] for n in [0,ldc), n = g*N + j, B = group-concatenated transposed weights,
//   bs = the concatenated float[ldc] (col_stride=N => bs + g*N + j = bs + n exactly).
// ldc = N*b => the quant row spans every group's columns CONTIGUOUSLY (c layout
// r*ldc + n) => one workgroup owning BM rows x ldc cols sees the whole row => the
// requantize folds (v9's blocker gone). SLM: A 2x(32x32)=2KB + B 2x(32*ldc)=16/32KB
// + rmax 128B + as-stage 128B <= 34.3KB < 64KB (bench_slm128 cap).
//
// RACE FIX (v9's latent bug, closed here): the producer writes new_scale INTO the
// a_scale buffer, which is ALSO this GEMM's row-scale input (scale_stride=0). Other
// WIs may still read as[r] when one WI writes ns[r]. => stage the BM row scales to
// SLM at kernel start (one barrier), dequant from SLM, write ns to a_scale freely.
//
// BIT-EXACT contract (same as bench_v9's proven chain):
//   pub = convert<float>(acc) * as_slab[r] * bs[n] -> s8v8::pub_vec_v8(epi) (epi3 =
//   gate_vec + e4m3_vec, bench_pubvec IDENTICAL over 1M values); pub values are e4m3
//   grid => EXACTLY representable in half, so the split chain's fp16 c-store loses
//   nothing and requantizing the f32 pub == requantizing the half-rounded pub.
//   scale = (peak==0)?1:div_ieee(peak,127); q = clip(rnde(div_ieee(pub,scale)),±127).
//   div_ieee = hw correctly-rounded (== fdiv_rn, bench_v9 0/8.3M).
// dpas loop VERBATIM v8/v9 (int8 8x8x32, c00..c11, double-buffered SLM).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "gemm_s8_v8_kernel.hpp"   // s8v8::pub_vec_v8 (bench_pubvec proven)

namespace s8v9b {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ---- self-contained vectorized publish (bench_pubvec A/B: epi 0/1/3/4 scalar-vs-
// vector IDENTICAL over 1M values; epi2 differs ONLY on -0.0 sign, and epi3's
// e4m3-after-gate masks that). e4m3_vec = wbv2's proven block (bench_e4m3vec 0/4096);
// gate chain = the SAME statement structure as s8v8::gate_esimd (simd ops are
// separate instructions, no FMA contraction -- §92). ----
template <int N>
static inline esimd::simd<float,N> e4m3_vec_v9b(esimd::simd<float,N> x){
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
template <int N>
static inline esimd::simd<float,N> gate_vec_v9b(esimd::simd<float,N> x) {
    esimd::simd<float,N> wide = esimd::convert<float>(esimd::convert<sycl::half>(x));
    esimd::simd<float,N> clamped = (esimd::min)((esimd::max)(wide, esimd::simd<float,N>(-4.0f)), esimd::simd<float,N>(4.0f));
    esimd::simd<float,N> ac = esimd::abs(clamped);
    esimd::simd<float,N> L = ac * esimd::simd<float,N>(-0.055908203125f);
    L = L + esimd::simd<float,N>(0.447265625f);
    esimd::simd<float,N> l0 = esimd::convert<float>(esimd::convert<sycl::half>(L));
    esimd::simd<float,N> M = l0 * clamped;
    M = M + esimd::simd<float,N>(0.89453125f);
    esimd::simd<float,N> l1 = esimd::convert<float>(esimd::convert<sycl::half>(M));
    esimd::simd<float,N> R = wide * l1;
    return esimd::convert<float>(esimd::convert<sycl::half>(R));
}
template <int N>
static inline esimd::simd<float,N> pub_vec_v9b(unsigned epi, esimd::simd<float,N> v) {
    if (epi == 2u || epi == 3u) v = gate_vec_v9b<N>(v);
    if (epi == 1u || epi == 3u) v = e4m3_vec_v9b<N>(v);
    if (epi == 4u) v = esimd::convert<float>(esimd::convert<sycl::half>(v));
    return v;
}

static const int BM = 32, BK = 32, NT = 32;

// A: (M x K) row-major int8, lda -> Ap BM=32 blocks:
//   dest = ((w*kb_n + kb)*2 + wi)*512 + row*32 + k  (w over Mp/32, wi<2, row<16)
inline void pack_a9b(queue& q, const int8_t* Araw, int8_t* Ap,
                     int M, int Mp, int K, int lda) {
    const int kb_n = K / BK;
    size_t n = (size_t)(Mp / BM) * kb_n * 2 * 512;
    q.parallel_for(range(n), [=](item<1> it) {
        size_t d = it.get_id(0);
        int off = (int)(d % 512); size_t rest = d / 512;
        int wi = (int)(rest % 2u); rest /= 2;
        int kb = (int)(rest % (size_t)kb_n); rest /= kb_n;
        int w = (int)rest;
        int row = off / 32, k = off % 32;
        int srow = w * BM + wi * 16 + row;
        Ap[d] = srow < M ? Araw[(size_t)srow * lda + kb * BK + k] : (int8_t)0;
    });
}
// B: b groups of transposed (N x K) weights at Braw + g*sb + j*ldb + k -> ONE packed
//   (K x ldc) VNNI: dest = ((kk32*(ldc/8) + ntile)*64 + kq*8 + nl)*4 + j,
//   ntile = g*(N/8) + (j/8), nl = j%8.
inline void pack_b9b(queue& q, const int8_t* Braw, int8_t* Bp,
                     int K, int N, int ldc, int ldb, size_t sb, int batch) {
    size_t n = (size_t)(K / 32) * (ldc / 8) * 256;
    q.parallel_for(range(n), [=](item<1> it) {
        size_t d = it.get_id(0);
        int j = (int)(d % 4); size_t rest = d / 4;
        int nl = (int)(rest % 8); rest /= 8;
        int kq = (int)(rest % 8); rest /= 8;
        int ntile = (int)(rest % (size_t)(ldc / 8)); rest /= (ldc / 8);
        int kk32 = (int)rest;
        int g = ntile / (N / 8);
        int nn = (ntile % (N / 8)) * 8 + nl;
        Bp[d] = Braw[(size_t)g * sb + (size_t)nn * ldb + kk32 * 32 + kq * 4 + j];
    });
}

// the fused kernel: C8 = int8 (Mp x ldc, the c buffer reinterpreted), ns = float[Mp]
// (the a_scale buffer). bs = concatenated float[ldc]. as = float[M] (staged to SLM).
template <int BN, bool FOLD>
inline event gemm_b_rq9b(queue& q, const int8_t* Ap, const int8_t* Bp,
                         sycl::half* C8, float* ns,
                         const float* as, const float* bs,
                         int M, int Mp, int K, unsigned epi) {
    // FOLD=1: C8 is reinterpreted int8* (the quant pass's PACKED buffer, M x ldc flat),
    // ns = the quant pass's SCALE buffer (float[M]). The producer writes int8+scale
    // DIRECTLY; the xmx_rec_quant closure becomes a no-op. pub is e4m3-grid exact ->
    // requantizing the f32 pub == requantizing the half-rounded pub the split chain
    // would have re-read (the bench_v9 argument). rmax = SLM atomic-fmax over the
    // workgroup's WIs (the workgroup owns the WHOLE ldc row -- v9b geometry).
    static_assert(BN == 256 || BN == 512, "v9b: ldc is 256 or 512 in the frame");
    const int WI_COLS = BN / 16;                 // 16 or 32 col-tiles
    const int SLM_A = BM * BK;                   // 1024 B per buffer
    const int SLM_B = BK * BN;                   // 8KB / 16KB per buffer
    const int SLM_B_BASE = 2 * SLM_A;            // 2048
    const int ASS = 2 * SLM_A + 2 * SLM_B;       // row-scale stage, 128 B
    const int RMAXB = ASS + BM * 4;              // fold: row absmax, 128 B
    const int SLMTOT = RMAXB + (FOLD ? BM * 4 : 0);  // <= 34.4KB
    const int TILES = 2 * WI_COLS;               // 32 / 64
    const int TPT = TILES / NT;                  // 1 / 2 tiles per thread
    int wg = Mp / BM;
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * BN;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMTOT>();
            int lid = (int)it.get_local_id(0);
            int w = (int)it.get_group(0);   // BUGFIX: nd_range local=NT => group count IS wg;
                                            // the old /NT made every workgroup compute the
                                            // wrong row block (frame 0%).
            // stage row scales cooperatively
            esimd::slm_block_store(ASS + lid * 4, esimd::simd<float,1>(as[w * BM + lid]), esimd::overaligned_tag<16>{});
            if (FOLD) esimd::slm_block_store(RMAXB + lid * 4, esimd::simd<float,1>(0.f), esimd::overaligned_tag<16>{});
            const int8_t* apb_g = Ap + (size_t)w * (size_t)(K / BK) * 2 * 512;
            const int8_t* bp_g  = Bp;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 32> av = esimd::block_load<int8_t, 32>(
                    apb_g + (size_t)kb * SLM_A + lid * 32, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 32, av, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int i = 0; i < SLM_B / (NT * 128); ++i) {
                    esimd::simd<int8_t, 128> bv = esimd::block_load<int8_t, 128>(
                        bp_g + (size_t)kb * SLM_B + lid * 128 + i * NT * 128, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLM_B_BASE + buf * SLM_B + lid * 128 + i * NT * 128, bv, esimd::overaligned_tag<16>{});
                }
            };
            auto load_grf = [=](int buf, int tr, int tc,
                                esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A + tr * 512;
                uint32_t offB = SLM_B_BASE + buf * SLM_B + tc * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> acc[TPT][4];
            #pragma unroll
            for (int t = 0; t < TPT; ++t) { acc[t][0]=0; acc[t][1]=0; acc[t][2]=0; acc[t][3]=0; }
            int kb_n = K / BK;
            load_block(0, 0);
            esimd::barrier();
            for (int b = 0; b < kb_n; ++b) {
                int cur = b & 1, nxt = cur ^ 1;
                if (b + 1 < kb_n) load_block(nxt, b + 1);
                #pragma unroll
                for (int t = 0; t < TPT; ++t) {
                    int tile = t * NT + lid;
                    int tr = tile / WI_COLS, tc = tile % WI_COLS;
                    load_grf(cur, tr, tc, a0, a1, b0, b1);
                    acc[t][0] = esimd::xmx::dpas<8, 8, int32_t>(acc[t][0], b0, a0);
                    acc[t][1] = esimd::xmx::dpas<8, 8, int32_t>(acc[t][1], b1, a0);
                    acc[t][2] = esimd::xmx::dpas<8, 8, int32_t>(acc[t][2], b0, a1);
                    acc[t][3] = esimd::xmx::dpas<8, 8, int32_t>(acc[t][3], b1, a1);
                }
                esimd::barrier();
            }
            // ---- store phase. FOLD=0: half[r*ldc+n] like gemm_b_pub (the c buffer).
            // FOLD=1: phase A = pub + row absmax atomic-fmax; barrier; phase B = scale +
            // requantize + int8[r*ldc+n] + ns[r]. pub recomputed in phase B from the
            // SAME acc registers (deterministic, bit-identical -- no SLM pub staging). ----
            #pragma unroll
            for (int t = 0; t < TPT; ++t) {
                int tile = t * NT + lid;
                int tr = tile / WI_COLS, tc = tile % WI_COLS;
                int gr = w * BM + tr * 16, gc = tc * 16;
                esimd::simd<float, 16> bsv = esimd::block_load<float,16>(bs + gc, esimd::overaligned_tag<16>{});
                esimd::simd<float,8> lo = bsv.template select<8,1>(0).read();
                esimd::simd<float,8> hi = bsv.template select<8,1>(8).read();
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    int rr0 = gr + r, rr1 = gr + 8 + r;
                    float rs0 = esimd::slm_block_load<float,1>(ASS + (tr*16u + r)*4u)[0];
                    float rs1 = esimd::slm_block_load<float,1>(ASS + (tr*16u + 8 + r)*4u)[0];
                    esimd::simd<float,8> f0 = esimd::convert<float>(acc[t][0].template select<8,1>(r*8).read()) * rs0 * lo;
                    esimd::simd<float,8> f1 = esimd::convert<float>(acc[t][1].template select<8,1>(r*8).read()) * rs0 * hi;
                    esimd::simd<float,8> g0 = esimd::convert<float>(acc[t][2].template select<8,1>(r*8).read()) * rs1 * lo;
                    esimd::simd<float,8> g1 = esimd::convert<float>(acc[t][3].template select<8,1>(r*8).read()) * rs1 * hi;
                    if (!FOLD) {
                        if (rr0 < M) {
                            esimd::simd<float,16> pub(0.f);
                            for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, f0.read()[e]);
                            for (int e = 0; e < 8; ++e) pub[8 + e] = s8v8::pub_esimd(epi, f1.read()[e]);
                            esimd::convert<sycl::half>(pub).copy_to((sycl::half*)C8 + (size_t)rr0 * BN + gc);
                        }
                        if (rr1 < M) {
                            esimd::simd<float,16> pub(0.f);
                            for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, g0.read()[e]);
                            for (int e = 0; e < 8; ++e) pub[8 + e] = s8v8::pub_esimd(epi, g1.read()[e]);
                            esimd::convert<sycl::half>(pub).copy_to((sycl::half*)C8 + (size_t)rr1 * BN + gc);
                        }
                    } else {
                        // phase A: pub + absmax
                        esimd::simd<float,8> p0 = pub_vec_v9b<8>(epi, f0);
                        esimd::simd<float,8> p1 = pub_vec_v9b<8>(epi, f1);
                        esimd::simd<float,8> q0 = pub_vec_v9b<8>(epi, g0);
                        esimd::simd<float,8> q1 = pub_vec_v9b<8>(epi, g1);
                        float m0 = (esimd::max)(esimd::hmax<float,float,8>(esimd::abs(p0)),
                                                esimd::hmax<float,float,8>(esimd::abs(p1)));
                        float m1 = (esimd::max)(esimd::hmax<float,float,8>(esimd::abs(q0)),
                                                esimd::hmax<float,float,8>(esimd::abs(q1)));
                        esimd::slm_atomic_update<esimd::atomic_op::fmax, float, 1>(
                            esimd::simd<uint32_t,1>((uint32_t)(RMAXB + (tr*16u + r) * 4u)), esimd::simd<float,1>(m0));
                        esimd::slm_atomic_update<esimd::atomic_op::fmax, float, 1>(
                            esimd::simd<uint32_t,1>((uint32_t)(RMAXB + (tr*16u + 8 + r) * 4u)), esimd::simd<float,1>(m1));
                    }
                }
            }
            if (FOLD) {
                esimd::barrier();
                #pragma unroll
                for (int t = 0; t < TPT; ++t) {
                    int tile = t * NT + lid;
                    int tr = tile / WI_COLS, tc = tile % WI_COLS;
                    int gr = w * BM + tr * 16, gc = tc * 16;
                    esimd::simd<float, 16> bsv = esimd::block_load<float,16>(bs + gc, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> lo = bsv.template select<8,1>(0).read();
                    esimd::simd<float,8> hi = bsv.template select<8,1>(8).read();
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        int rr0 = gr + r, rr1 = gr + 8 + r;
                        float rm0 = esimd::slm_block_load<float,1>(RMAXB + (tr*16u + r)*4u)[0];
                        float rm1 = esimd::slm_block_load<float,1>(RMAXB + (tr*16u + 8 + r)*4u)[0];
                        float sc0 = (rm0 == 0.f) ? 1.f : esimd::div_ieee<float,1>(esimd::simd<float,1>(rm0), esimd::simd<float,1>(127.0f))[0];
                        float sc1 = (rm1 == 0.f) ? 1.f : esimd::div_ieee<float,1>(esimd::simd<float,1>(rm1), esimd::simd<float,1>(127.0f))[0];
                        if (tc == 0) {
                            if (rr0 < M) ns[rr0] = sc0;
                            if (rr1 < M) ns[rr1] = sc1;
                        }
                        float rs0 = esimd::slm_block_load<float,1>(ASS + (tr*16u + r)*4u)[0];
                        float rs1 = esimd::slm_block_load<float,1>(ASS + (tr*16u + 8 + r)*4u)[0];
                        esimd::simd<float,8> f0 = esimd::convert<float>(acc[t][0].template select<8,1>(r*8).read()) * rs0 * lo;
                        esimd::simd<float,8> f1 = esimd::convert<float>(acc[t][1].template select<8,1>(r*8).read()) * rs0 * hi;
                        esimd::simd<float,8> g0 = esimd::convert<float>(acc[t][2].template select<8,1>(r*8).read()) * rs1 * lo;
                        esimd::simd<float,8> g1 = esimd::convert<float>(acc[t][3].template select<8,1>(r*8).read()) * rs1 * hi;
                        auto rq8 = [](esimd::simd<float,8> p, float sc) {
                            esimd::simd<float,8> q = esimd::div_ieee<float,8>(p, esimd::simd<float,8>(sc));
                            q = esimd::rnde<float,8>(q);
                            q = (esimd::min)((esimd::max)(q, esimd::simd<float,8>(-127.f)), esimd::simd<float,8>(127.f));
                            return esimd::convert<int8_t>(esimd::convert<int>(q));
                        };
                        int8_t* C8i = (int8_t*)C8;
                        if (rr0 < M) {
                            esimd::block_store<int8_t,8>(C8i + (size_t)rr0 * BN + gc, rq8(pub_vec_v9b<8>(epi, f0), sc0));
                            esimd::block_store<int8_t,8>(C8i + (size_t)rr0 * BN + gc + 8, rq8(pub_vec_v9b<8>(epi, f1), sc0));
                        }
                        if (rr1 < M) {
                            esimd::block_store<int8_t,8>(C8i + (size_t)rr1 * BN + gc, rq8(pub_vec_v9b<8>(epi, g0), sc1));
                            esimd::block_store<int8_t,8>(C8i + (size_t)rr1 * BN + gc + 8, rq8(pub_vec_v9b<8>(epi, g1), sc1));
                        }
                    }
                }
            }
        });
    });
}
} // namespace s8v9b
