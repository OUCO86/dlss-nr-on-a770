// gemm_s8_v9_kernel.hpp -- section 99: the SENIOR v2 wide producer (esimd_gemm_s8_v2.cpp,
// BM=64 BN=128 BK=32 NT=32, "wide producer: BN=N so one work-group owns whole rows; rmax
// is a per-row atomic-fmax in SLM") + batch z-dimension + Mp padding + the FUSED QUANT
// EPILOGUE. This is §29 rule 1: "producer GEMM owns the whole row -> quantize folds into
// the store loop -> independent quantize passes = 0". The 448 xmx_rec_quant passes after
// the batched family's N=128 shapes disappear: the GEMM writes int8 + new_scale DIRECTLY.
//
// Bit-exactness contract: the epilogue reproduces, in order, EXACTLY what the current
// split chain computes:
//   gemm_b_pub (v8): f = convert<float>(acc) * rs * csl ; pub = pub_esimd(epi, f)
//   quant (quantize_row_kernel.hpp): peak = max|pub| over the row;
//       scale = (peak==0)?1:fdiv_rn(peak,127); out = clip(rint(fdiv_rn(pub,scale)),±127);
//       scales[row] = scale.
// Divisions use the simd<float,1> '/' spelling (ef_div, proven bit-exact vs fdiv_rn in
// the §97 softmax fold); rint == esimd::rnde (both round-half-to-even). The dpas main
// loop and accumulator geometry are BYTE-IDENTICAL to senior v2 (c00..c11, 4x dpas,
// double-buffered SLM), so the int32 accumulators are bit-exact by construction.
//
// Geometry (senior v2 verbatim): BM=64 BN=128 BK=32 NT=32; WI_ROWS=4 WI_COLS=8; each WI
// a 16x16 quad of 8x8 tiles = 4 accumulators simd<int32,64>. N MUST equal BN=128 (the
// whole row lives in one workgroup -- the §23 fact that makes fused requantize possible).
// M padded up to 64k (pack_a9 zero-pads rows >= M; stores guard rr < M; padded rows'
// rmax/scale are garbage but never consumed).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "publish_kernel.hpp"     // qr_e4m3_scalar (ESIMD-safe)
#include "gemm_s8_v8_kernel.hpp"  // s8v8::pub_esimd = the gate+e4m3 chain (v8 spelling)

namespace s8v9 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
using namespace esimd;

static const int BM = 64, BN = 128, BK = 32, NT = 32;
static const int WI_ROWS = BM / 16, WI_COLS = BN / 16;   // 4 x 8 = 32
static const int SLM_A = BM * BK;            // 2048 B per buffer
static const int SLM_B = BK * BN;            // 4096 B per buffer
static const int SLM_B_BASE = 2 * SLM_A;
static const int RMAX_BASE = 2 * SLM_A + 2 * SLM_B;      // 12288
static const int SLM_TOTAL = RMAX_BASE + BM * 4;         // 12544 < 32 KB (P2)

// v9_div: esimd::div_ieee = the __esimd_ieee_div intrinsic (math.hpp:553) = correctly
// rounded division, the ESIMD twin of ext::intel::math::fdiv_rn. The plain '/' on
// simd<float,1> is NOT safe here: the bench_v9 gate caught it 1 ULP low on peak/127
// (0x4051a346 vs ...47), which flips the exact .5 ties the quant grid produces
// (pub=208, scale=peak/127 -> 63.5 -> rint ties-to-even). Same lesson family as the
// §77 fdiv_rn note in quantize_row_kernel.hpp: BOTH divisions must be correctly rounded.
static inline float v9_div(float a, float b) {
    return div_ieee<float,1>(simd<float,1>(a), simd<float,1>(b))[0];
}

// ---- device packs (v9 geometry; batch + strides like the batched family) ----
// A: (M x K) row-major, row stride lda, group stride sa -> Ap blocks of BM*BK=2048B:
//    dest = ((w*kb_n + kb)*WI_ROWS + wi)*512 + row*32 + k ; w over Mp/BM.
inline void pack_a9(queue& q, const int8_t* Araw, int8_t* Ap,
                    int M, int Mp, int K, int lda, size_t sa, int batch) {
    const int kb_n = K / BK;
    size_t n = (size_t)batch * (Mp / BM) * kb_n * WI_ROWS * 512;
    q.parallel_for(range(n), [=](item<1> it) {
        size_t d = it.get_id(0);
        int off = (int)(d % 512); size_t rest = d / 512;
        int wi = (int)(rest % (size_t)WI_ROWS); rest /= WI_ROWS;
        int kb = (int)(rest % (size_t)kb_n); rest /= kb_n;
        int w = (int)(rest % (size_t)(Mp / BM)); rest /= (Mp / BM);
        int g = (int)rest;
        int row = off / 32, k = off % 32;
        int srow = w * BM + wi * 16 + row;
        Ap[d] = srow < M ? Araw[(size_t)g * sa + (size_t)srow * lda + kb * BK + k] : (int8_t)0;
    });
}
// B: (K x N) row-major (senior v2 layout), row stride ldb, group stride sb ->
//    Bp[ ((kk32*(N/8) + ntile)*64 + kq*8 + nl)*4 + j ] = B[g*sb + (kk32*32+kq*4+j)*ldb + ntile*8+nl]
inline void pack_b9(queue& q, const int8_t* Braw, int8_t* Bp,
                    int K, int N, int ldb, size_t sb, int batch) {
    size_t n = (size_t)batch * (K / 32) * (N / 8) * 256;
    q.parallel_for(range(n), [=](item<1> it) {
        size_t d = it.get_id(0);
        int j = (int)(d % 4); size_t rest = d / 4;
        int nl = (int)(rest % 8); rest /= 8;
        int kq = (int)(rest % 8); rest /= 8;
        int ntile = (int)(rest % (size_t)(N / 8)); rest /= (N / 8);
        int kk32 = (int)(rest % (size_t)(K / 32)); rest /= (K / 32);
        int g = (int)rest;
        Bp[d] = Braw[(size_t)g * sb + (size_t)(kk32 * 32 + kq * 4 + j) * ldb + ntile * 8 + nl];
    });
}

// ---- the fused kernel: dpas (senior v2 verbatim) + gate/e4m3 publish + row-absmax +
// requantize to int8 + new_scale, all in the store loop. C8 = int8 (Mp x N per group),
// ns = new_scale float[Mp] per group (group stride scale_stride on write? the quant pass
// writes scales[row] flat per group buffer: sc buffer is M floats per group; we mirror
// exactly: ns + g*ns_stride). ----
inline event gemm_b_rq(queue& q, const int8_t* Ap, const int8_t* Bp,
                       int8_t* C8, float* ns,
                       const float* as, const float* bs,
                       int M, int Mp, int N, int K, int batch,
                       size_t sc, unsigned ldc, unsigned scale_stride,
                       unsigned col_stride, unsigned epi) {
    // store addressing EXACTLY like v8 gemm_b_pub: out = g*sc + r*ldc + col (the plan's
    // N=128 shapes have ldc=256 != N and interleaved group stride sc -- verified from
    // the plan call [M=32640 N=128 K=64 b=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256
    // scale_stride=0 flags=4864]). scales: gas = as + g*scale_stride, row-indexed; the
    // new_scale writes go to the SAME scale buffer with the SAME stride (the quant pass
    // wrote scales[row] flat; scale_stride=0 = groups share A and its scales).
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            // zero rmax cooperatively (BM=64 floats; 32 WI x 2 slots)
            slm_block_store(RMAX_BASE + lid * 4, simd<float,1>(0.f), overaligned_tag<16>{});
            slm_block_store(RMAX_BASE + (lid + 32) * 4, simd<float,1>(0.f), overaligned_tag<16>{});
            const int8_t* apb_g = Ap + (size_t)g * apb;
            const int8_t* bp_g  = Bp + (size_t)g * bpb;
            const int8_t* apb = apb_g + (size_t)(wg_row * (K / BK)) * WI_ROWS * 512;
            const int8_t* bp  = bp_g + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                simd<int8_t, 64> av = block_load<int8_t, 64>(
                    apb + (size_t)kb * SLM_A + lid * 64, overaligned_tag<16>{});
                slm_block_store(buf * SLM_A + lid * 64, av, overaligned_tag<16>{});
                simd<int8_t, 128> bv = block_load<int8_t, 128>(
                    bp + (size_t)kb * N * 32 + lid * 128, overaligned_tag<16>{});
                slm_block_store(SLM_B_BASE + buf * SLM_B + lid * 128, bv, overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, simd<int8_t,256>& a0, simd<int8_t,256>& a1,
                                simd<int8_t,256>& b0, simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A + wi_row * 512;
                uint32_t offB = SLM_B_BASE + buf * SLM_B + wi_col * 512;
                a0 = slm_block_load<int8_t, 256>(offA + 0, overaligned_tag<16>{});
                a1 = slm_block_load<int8_t, 256>(offA + 256, overaligned_tag<16>{});
                b0 = slm_block_load<int8_t, 256>(offB + 0, overaligned_tag<16>{});
                b1 = slm_block_load<int8_t, 256>(offB + 256, overaligned_tag<16>{});
            };
            simd<int8_t, 256> a0, a1, b0, b1;
            simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b & 1, nxt = cur ^ 1;
                if (b + 1 < kb_n) load_block(nxt, b + 1);
                load_grf(cur, a0, a1, b0, b1);
                c00 = xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            const float* gas = as + (size_t)g * scale_stride;
            const float* gbs = bs + (size_t)g * col_stride;
            simd<float, 8> cs_lo = block_load<float, 8>(gbs + gc, overaligned_tag<16>{});
            simd<float, 8> cs_hi = block_load<float, 8>(gbs + gc + 8, overaligned_tag<16>{});
            // ---- phase 1: pub = dequant+gate+e4m3 (v8 order), row-absmax atomic-fmax SLM ----
            float pm[16];   // per local row of this WI: rows wi_row*16 + r, +8+r
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                float rs0 = rr0 < M ? gas[rr0] : 0.f, rs1 = rr1 < M ? gas[rr1] : 0.f;
                simd<float,8> f0 = convert<float>(c00.template select<8,1>(r*8).read()) * rs0 * cs_lo;
                simd<float,8> f1 = convert<float>(c01.template select<8,1>(r*8).read()) * rs0 * cs_hi;
                simd<float,8> g0 = convert<float>(c10.template select<8,1>(r*8).read()) * rs1 * cs_lo;
                simd<float,8> g1 = convert<float>(c11.template select<8,1>(r*8).read()) * rs1 * cs_hi;
                float p0 = 0.f, p1 = 0.f;
                for (int e = 0; e < 8; ++e) {
                    float v0 = s8v8::pub_esimd(epi, f0[e]);   // gate+e4m3 chain (v8 spelling)
                    float v1 = s8v8::pub_esimd(epi, f1[e]);
                    float w0 = s8v8::pub_esimd(epi, g0[e]);
                    float w1 = s8v8::pub_esimd(epi, g1[e]);
                    // sycl::fabs/fmax are BANNED in ESIMD kernels (v8 gate_esimd note):
                    // ternary spelling, same as gate_esimd's fabs.
                    float a0 = v0 < 0.f ? -v0 : v0, a1 = v1 < 0.f ? -v1 : v1;
                    float b0 = w0 < 0.f ? -w0 : w0, b1 = w1 < 0.f ? -w1 : w1;
                    p0 = p0 > a0 ? p0 : a0; p0 = p0 > a1 ? p0 : a1;
                    p1 = p1 > b0 ? p1 : b0; p1 = p1 > b1 ? p1 : b1;
                }
                pm[r] = p0; pm[8 + r] = p1;
            }
            for (int r = 0; r < 8; ++r) {
                int lr0 = wi_row * 16 + r, lr1 = wi_row * 16 + 8 + r;
                slm_atomic_update<atomic_op::fmax, float, 1>(
                    simd<uint32_t,1>((uint32_t)(RMAX_BASE + lr0 * 4)), simd<float,1>(pm[r]));
                slm_atomic_update<atomic_op::fmax, float, 1>(
                    simd<uint32_t,1>((uint32_t)(RMAX_BASE + lr1 * 4)), simd<float,1>(pm[8 + r]));
            }
            esimd::barrier();
            // ---- phase 2: scale per row (quant semantics), requantize pub -> int8 ----
            simd<float, 16> rmaxv = slm_block_load<float, 16>(
                RMAX_BASE + wi_row * 16 * 4, overaligned_tag<16>{});
            float* ns_g = ns + (size_t)g * scale_stride;
            int8_t* C8_g = C8 + (size_t)g * sc;
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 >= M && rr1 >= M) continue;
                float rm0 = rmaxv[r], rm1 = rmaxv[8 + r];
                float sc0 = (rm0 == 0.f) ? 1.f : v9_div(rm0, 127.0f);
                float sc1 = (rm1 == 0.f) ? 1.f : v9_div(rm1, 127.0f);
                if (wi_col == 0) {
                    if (rr0 < M) ns_g[rr0] = sc0;
                    if (rr1 < M) ns_g[rr1] = sc1;
                }
                float rs0 = gas[rr0 < M ? rr0 : M - 1], rs1 = gas[rr1 < M ? rr1 : M - 1];
                simd<float,8> f0 = convert<float>(c00.template select<8,1>(r*8).read()) * rs0 * cs_lo;
                simd<float,8> f1 = convert<float>(c01.template select<8,1>(r*8).read()) * rs0 * cs_hi;
                simd<float,8> g0 = convert<float>(c10.template select<8,1>(r*8).read()) * rs1 * cs_lo;
                simd<float,8> g1 = convert<float>(c11.template select<8,1>(r*8).read()) * rs1 * cs_hi;
                simd<int8_t, 16> ob0, ob1;
                for (int e = 0; e < 8; ++e) {
                    float v0 = s8v8::pub_esimd(epi, f0[e]), v1 = s8v8::pub_esimd(epi, f1[e]);
                    int q0 = (int)rnde<float,1>(simd<float,1>(v9_div(v0, sc0))[0]);
                    int q1 = (int)rnde<float,1>(simd<float,1>(v9_div(v1, sc0))[0]);
                    q0 = q0 < -127 ? -127 : (q0 > 127 ? 127 : q0);
                    q1 = q1 < -127 ? -127 : (q1 > 127 ? 127 : q1);
                    ob0[e] = (int8_t)q0; ob0[8 + e] = (int8_t)q1;
                    float w0 = s8v8::pub_esimd(epi, g0[e]), w1 = s8v8::pub_esimd(epi, g1[e]);
                    int p0 = (int)rnde<float,1>(simd<float,1>(v9_div(w0, sc1))[0]);
                    int p1 = (int)rnde<float,1>(simd<float,1>(v9_div(w1, sc1))[0]);
                    p0 = p0 < -127 ? -127 : (p0 > 127 ? 127 : p0);
                    p1 = p1 < -127 ? -127 : (p1 > 127 ? 127 : p1);
                    ob1[e] = (int8_t)p0; ob1[8 + e] = (int8_t)p1;
                }
                if (rr0 < M) block_store<int8_t, 16>(C8_g + (size_t)rr0 * ldc + gc, ob0, overaligned_tag<16>{});
                if (rr1 < M) block_store<int8_t, 16>(C8_g + (size_t)rr1 * ldc + gc, ob1, overaligned_tag<16>{});
            }
        });
    });
}
} // namespace s8v9
