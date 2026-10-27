// gemm_f16_v2_kernel.hpp -- section 99: workgroup-tiled f16 dpas GEMM.
// The v1 gemm/gemm_b give EACH work-item one 16x16 tile and load its A/B blocks
// straight from GLOBAL with ZERO reuse: 2KB loaded per 16K FLOP = 8 FLOP/byte ->
// pure memory-bound (winattn TOPS 0.32 vs the senior's measured f16 4-6 TF/s,
// int8-width-sweep fp16 column). v2 = the v8-int8 lever for f16: a workgroup of
// NT work-items cooperatively stages the BM x BK A block and BK x BN B block into
// SLM (double-buffered over the K loop), each WI reads ITS tile operands from SLM.
// BM=64 (the window M and a divisor of every frame M once Mp is rounded to 64),
// BK=16 (P7: f16 native 8x8x16), BN=32 or 64 (template; every frame N is a
// multiple of 32). Reuse: BN=64 -> 4KB per 131K FLOP = 32 FLOP/byte (4x v1);
// BN=32 -> 24. SLM: BN=64: 2*(2048+2048)=8KB, BN=32: 6KB -- far under P2's 32KB.
//
// BIT-EXACTNESS BY CONSTRUCTION: the per-tile dpas sequence, operand VALUES and
// store pattern are IDENTICAL to v1 gemm_b (same pack_a16*/pack_b16* block layout
// -- v2 only moves the same 256-half blocks global->SLM->GRF). Accumulators are
// the same 4x simd<float,64> in the same order. The WINDOW_ATTENTION / WINDOW_BLOCK
// / GEMM_F16 gates + end-to-end frame are the judges.
//
// Mp MUST be a multiple of BM=64 (call sites round it; pack_a16* zero-pads rows
// >= M, padded rows write garbage into the padded C scratch exactly like v1 --
// consumers only read r < M).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "gemm_s8_v8_kernel.hpp"   // s8v8::e4m3_vec_v8 (the P9 merge-pub epilogue)


namespace f16v2 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int TS = 16, BM = 64, BK = 16;

template <int BN>
static inline sycl::event gemm_b2(sycl::queue& q, const half* Ap, const half* Bp,
                                  float* C, int Mp, int N, int K, int batches) {
    const int WIR = BM / TS, WIC = BN / TS, NT = WIR * WIC;   // 4 x (BN/16)
    const int SLM_A = BM * BK * 2;         // BYTES: 2048
    const int SLM_B = BK * BN * 2;         // BN=64: 2048, BN=32: 1024
    const int SLM_B_BASE = 2 * SLM_A;      // double-buffered A, then B
    const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;
    const int ACH = (BM * BK) / NT;        // half per WI from A: BN64:64, BN32:128
    const int BCH = (BK * BN) / NT;        // half per WI from B: 64 both
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * N, cb = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)batches * wg * NT), range((size_t)NT)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int b = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int tr0 = wg_row * WIR, tc0 = wg_col * WIC;
            const half* Ab = Ap + (size_t)b * apb;
            const half* Bb = Bp + (size_t)b * bpb;
            float* Cb = C + (size_t)b * cb;
            auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                #pragma unroll
                for (int i = 0; i < ACH / 64; ++i) {
                    int la = lid * ACH + i * 64;
                    int trl = la / 256, within = la % 256;
                    esimd::simd<half, 64> v = esimd::block_load<half, 64>(
                        Ab + ((size_t)((tr0 + trl) * kb_n + kc) * 2) * 128 + within,
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_A + la * 2, v, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int i = 0; i < BCH / 64; ++i) {
                    int lb = lid * BCH + i * 64;
                    int tcl = lb / 256, within = lb % 256;
                    esimd::simd<half, 64> v = esimd::block_load<half, 64>(
                        Bb + ((size_t)(kc * tc_n + (tc0 + tcl)) * 2) * 128 + within,
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLM_B_BASE + buf * SLM_B + lb * 2, v, esimd::overaligned_tag<16>{});
                }
            };
            int wi_row = lid / WIC, wi_col = lid % WIC;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            load_block(0, 0);
            esimd::barrier();
            for (int kb = 0; kb < kb_n; ++kb) {
                int cur = kb & 1, nxt = cur ^ 1;
                if (kb + 1 < kb_n) load_block(nxt, kb + 1);
                uint32_t offA = cur * SLM_A + wi_row * (TS * BK * 2);
                uint32_t offB = SLM_B_BASE + cur * SLM_B + wi_col * (TS * BK * 2);
                esimd::simd<half, 128> a0 = esimd::slm_block_load<half, 128>(offA, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1 = esimd::slm_block_load<half, 128>(offA + 256, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0 = esimd::slm_block_load<half, 128>(offB, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1 = esimd::slm_block_load<half, 128>(offB + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
                esimd::barrier();
            }
            float* out = Cb + (size_t)((tr0 + wi_row) * TS) * N + (tc0 + wi_col) * TS;
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

// gemm_b2_merge (section 100 P9): the attnV leg WITH the merge_heads tail folded
// into the store (the promoted gemm_pub_pa16 pattern, merge-map scatter). N=32,
// BN=32 (one tc per WI-row-band pair): the fragment value v -> half(qr_e4m3(v))
// at Out[((window*64 + token)*CH + head*32 + tc*16 + c)] -- EXACTLY what the
// merge pass computes from dCtx (its sp[at*32 + c%32] read is the value we hold
// in registers). dCtx (batches x 64 x 32 f32 = 16.7MB/call-frame write+read) AND
// the merge launch both vanish. The e4m3 goes through s8v8::e4m3_vec_v8<8> (the
// bench_pubvec-proven vector==scalar-identical form). Geometry guards at the
// call site: Mp=64 (one tr band x4), N=32, K=rows.
static inline sycl::event gemm_b2_merge(sycl::queue& q, const half* Ap, const half* Bp,
                                        half* Out, int Mp, int N, int K, int batches,
                                        int heads) {
    const int MERGE_BN = 32;   // the attnV leg is BN=32 (N=32)
    const int WIR = BM / TS, WIC = MERGE_BN / TS, NT = WIR * WIC;   // MERGE_BN=32 -> WIC=2, NT=8
    const int SLM_A = BM * BK * 2;
    const int SLM_B = BK * MERGE_BN * 2;
    const int SLM_B_BASE = 2 * SLM_A;
    const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;
    const int ACH = (BM * BK) / NT;
    const int BCH = (BK * MERGE_BN) / NT;
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    int wg = (Mp / BM) * (N / MERGE_BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)K * N;
    const unsigned CH = (unsigned)heads * 32u;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)batches * wg * NT), range((size_t)NT)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int b = gid / wg; int loc = gid % wg;
            int NB = N / MERGE_BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int tr0 = wg_row * WIR, tc0 = wg_col * WIC;
            const half* Ab = Ap + (size_t)b * apb;
            const half* Bb = Bp + (size_t)b * bpb;
            auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                #pragma unroll
                for (int i = 0; i < ACH / 64; ++i) {
                    int la = lid * ACH + i * 64;
                    int trl = la / 256, within = la % 256;
                    esimd::simd<half, 64> v = esimd::block_load<half, 64>(
                        Ab + ((size_t)((tr0 + trl) * kb_n + kc) * 2) * 128 + within,
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_A + la * 2, v, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int i = 0; i < BCH / 64; ++i) {
                    int lb = lid * BCH + i * 64;
                    int tcl = lb / 256, within = lb % 256;
                    esimd::simd<half, 64> v = esimd::block_load<half, 64>(
                        Bb + ((size_t)(kc * tc_n + (tc0 + tcl)) * 2) * 128 + within,
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLM_B_BASE + buf * SLM_B + lb * 2, v, esimd::overaligned_tag<16>{});
                }
            };
            int wi_row = lid / WIC, wi_col = lid % WIC;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            load_block(0, 0);
            esimd::barrier();
            for (int kb = 0; kb < kb_n; ++kb) {
                int cur = kb & 1, nxt = cur ^ 1;
                if (kb + 1 < kb_n) load_block(nxt, kb + 1);
                uint32_t offA = cur * SLM_A + wi_row * (TS * BK * 2);
                uint32_t offB = SLM_B_BASE + cur * SLM_B + wi_col * (TS * BK * 2);
                esimd::simd<half, 128> a0 = esimd::slm_block_load<half, 128>(offA, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1 = esimd::slm_block_load<half, 128>(offA + 256, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0 = esimd::slm_block_load<half, 128>(offB, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1 = esimd::slm_block_load<half, 128>(offB + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
                esimd::barrier();
            }
            // merge scatter: batch b = window*heads + head (the QKV epilogue order)
            unsigned window = (unsigned)b / (unsigned)heads, head = (unsigned)b % (unsigned)heads;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                esimd::simd<half, 8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                esimd::simd<half, 8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                esimd::simd<half, 8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                esimd::simd<half, 8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                size_t o0 = (((size_t)window * 64u + (size_t)(tr0 + wi_row) * TS + (size_t)r) * CH
                             + head * 32u + (unsigned)(tc0 + wi_col) * TS);
                size_t o1 = o0 + 8u * (size_t)CH;   // the +8 ROW is (8+r): row stride CH
                h00.copy_to(Out + o0); h01.copy_to(Out + o0 + 8u);
                // strip1 rows (8+r):
                size_t o2 = (((size_t)window * 64u + (size_t)(tr0 + wi_row) * TS + 8u + (size_t)r) * CH
                             + head * 32u + (unsigned)(tc0 + wi_col) * TS);
                h10.copy_to(Out + o2); h11.copy_to(Out + o2 + 8u);
                (void)o1;
            }
        });
    });
}
} // namespace f16v2
