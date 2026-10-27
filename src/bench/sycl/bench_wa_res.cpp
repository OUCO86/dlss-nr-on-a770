// bench_wa_res.cpp -- section 100 P10: the window_attention RESIDENT block.
// One WG = one batch (window x head): scores gemm (the promoted f16v2 gemm_b2
// loop VERBATIM) -> the accumulator staged into SLM (the gemm_b_pub_slm
// untouched-store pattern) -> softmax reads the 64 rows FROM SLM and writes the
// e4m3 probs back in the pack_a16 block layout (the smax_esimd_tiled math
// VERBATIM) -> attnV consumes A FROM SLM (the tile8s pattern) with the P9 merge
// fold on its store. dScores (16KB/batch f32 write+read) and dProbs (8KB/batch
// half write+read) NEVER touch global; 2 launches fold away. SLM: X 16KB (the
// gemm operand double-buffers, then the scores stage -- the C-stage aliases the
// dead operand region exactly like gemm_b_pub_slm) + Y 8KB (probs, live across
// stage 3) = 24KB, LW=16 (gemm_b2<64>'s NT). Stage 3 (BN=32, NT=8) runs on
// threads 0..7 with 8..15 waiting at the barriers -- the idle cost is the
// measured question (the senior's coopmat avoids it by resharing; ours pays it
// back in deleted wire + launches). Reference = the promoted split chain
// (pack_a16_b Q + pack_b16_t_b K + gemm_b2 scores + smax_esimd_tiled +
// pack_b16_b V + gemm_b2_merge). Shapes: the frame's batches=1020, heads=2.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <random>
#include <algorithm>
#include <functional>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "softmax_kernel.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"
#include "pack_device.hpp"

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// SLM layout (bytes): X = 16384 (gemm_b2<64> operand buffers: SLM_A 2*2048=4096?
//   recompute: BM=64,BK=16: SLM_A=BM*BK*2=2048 per buffer, x2 = 4096;
//   SLM_B = BK*BN*2 = 16*64*2 = 2048 per buffer, x2 = 4096; SLM_B_BASE=4096;
//   SLM_TOTAL=8192 -- NOT 16KB. the scores C-stage (64x64 f32=16KB) does NOT fit
//   in the operand region (8KB): the pub_slm alias worked at BM=128/BN=64 = 32KB.
//   HERE: SC gets its OWN 16KB region Z. Total = 8 (ops1) + 16 (SC) + 8 (PB)
//   + 6 (ops2: SLM_A 2x2048 + SLM_B 2x1024 = 6144; reuse ops1? ops1 is dead by
//   stage 3 EXCEPT SC lives in Z, PB in Y: yes, stage-3 ops alias ops1 at X.)
//   PEAK = 8 + 16 + 8 = 32KB.
#define WA_X 0u           // operand double-buffers (stage 1, then stage 3)
#define WA_Z 8192u        // scores f32 64x64 = 16KB (stage 1 C -> stage 2 reads)
#define WA_Y 24576u       // probs pack_a16 64x64 half = 8KB (stage 2 -> stage 3)
#define WA_QT 32768u          // P10b: the raw-Q staged tile (4KB: 8 blocks x 256 halfs)
#define WA_KT 36864u          // P10b: the raw-K staged tile (4KB) -- the 2KB sizing OVERLAPPED QT (the K gather trashed A blocks (2,*),(3,*) = half the rows wrong, gate-caught)
#define WA_SLM 40960u         // 8+16+8+4+4 = 40KB (the v4ph 45KB precedent)

static void one_wa_res(queue& q, unsigned batches, unsigned heads, int stop_stage = 0, bool raw_qk = false) {
    sycl::half* kt_dump = getenv("WA_KTDUMP") ? malloc_device<sycl::half>(2048, q) : nullptr;
    if (kt_dump) q.memset(kt_dump, 0xEE, 4096);
    const unsigned tokens = 64u, C = 32u;
    const unsigned windows = batches / heads;
    std::mt19937 rng(9); std::uniform_real_distribution<float> df(-4.f, 4.f);
    size_t nqkv = (size_t)batches * 64u * C;
    std::vector<sycl::half> hQ(nqkv), hK(nqkv), hV(nqkv);
    std::vector<float> hBias((size_t)heads * 4096u);
    for (auto& x : hQ) x = sycl::half(df(rng));
    for (auto& x : hK) x = sycl::half(df(rng));
    for (auto& x : hV) x = sycl::half(df(rng));
    for (auto& x : hBias) x = df(rng) * 0.5f;
    sycl::half *dQ = malloc_device<sycl::half>(nqkv, q), *dK = malloc_device<sycl::half>(nqkv, q),
               *dV = malloc_device<sycl::half>(nqkv, q);
    float* dBias = malloc_device<float>(hBias.size(), q);
    q.memcpy(dQ, hQ.data(), nqkv*2); q.memcpy(dK, hK.data(), nqkv*2);
    q.memcpy(dV, hV.data(), nqkv*2); q.memcpy(dBias, hBias.data(), hBias.size()*4); q.wait();
    sycl::half *dAq = malloc_device<sycl::half>(nqkv, q), *dBk = malloc_device<sycl::half>(nqkv, q),
               *dAp = malloc_device<sycl::half>((size_t)batches * 4096u, q),   // the probs A tile is 64x64, NOT 64x32 (the bench-undersize = the OOB fault, rc=127)
               *dBv = malloc_device<sycl::half>(nqkv, q);
    float* dScores = malloc_device<float>((size_t)batches*4096u, q);
    sycl::half* outRef = malloc_device<sycl::half>((size_t)windows*64u*heads*32u, q);
    sycl::half* outRes = malloc_device<sycl::half>((size_t)windows*64u*heads*32u, q);
    q.memset(outRef, 0, (size_t)windows*64u*heads*32u*2);
    q.memset(outRes, 0, (size_t)windows*64u*heads*32u*2);
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9; for(int it=0;it<15;++it){ auto es=fn(); for(auto&e:es)e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    packdev::pack_a16_b(q, dQ, dAq, 64, 64, 32, (int)batches);
    packdev::pack_b16_t_b(q, dK, dBk, 32, 64, (int)batches);
    packdev::pack_b16_b(q, dV, dBv, 64, 32, (int)batches);
    // ---- reference: the promoted chain (scores gemm_b2 + smax_tiled + attnV merge-fold) ----
    sycl::half* dProbs = malloc_device<sycl::half>((size_t)batches*4096u, q);
    float* dScores2 = (stop_stage == 1) ? dScores : nullptr;   // reuse AFTER the split chain
    sycl::half* dAp2 = (stop_stage == 2) ? dAp : nullptr;
    double t_split = timeit([&]{
        event e1 = f16v2::gemm_b2<64>(q, dAq, dBk, dScores, 64, 64, 32, (int)batches);
        event e2 = q.parallel_for(range((size_t)batches*64u),
                         smax::softmax_kernel()(dScores, dProbs, batches*64u, 64u, dBias, heads));
        packdev::pack_a16_b(q, dProbs, dAp, 64, 64, 64, (int)batches);   // void; the in-order queue orders it before e3
        event e3 = f16v2::gemm_b2_merge(q, dAp, dBv, outRef, 64, 32, 64, (int)batches, (int)heads);
        return std::vector<event>{e1,e2,e3}; });
    float* dCtx = malloc_device<float>((size_t)batches * 2048u, q);
    if (stop_stage == 3)   // rebuild the split attnV RAW (the merge fold can't hide a dpas error)
        f16v2::gemm_b2<32>(q, dAp, dBv, dCtx, 64, 32, 64, (int)batches).wait();
    // capture the split chain's intermediates BEFORE the resident re-run overwrites them
    std::vector<float> refScores, *pRS = nullptr; std::vector<sycl::half> refAp, *pRA = nullptr;
    if (stop_stage == 1) { refScores.resize((size_t)batches*4096u); q.memcpy(refScores.data(), dScores, refScores.size()*4).wait(); pRS=&refScores; }
    if (stop_stage == 2) { refAp.resize((size_t)batches*4096u); q.memcpy(refAp.data(), dAp, refAp.size()*2).wait(); pRA=&refAp; }
    std::vector<float> refCtx, *pRC = nullptr;
    if (stop_stage == 3) { refCtx.resize((size_t)batches*2048u); q.memcpy(refCtx.data(), dCtx, refCtx.size()*4).wait(); pRC=&refCtx; }
    // ---- the resident kernel ----
    double t_res = timeit([&]{
        event ev = q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)batches * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<WA_SLM>();
            uint b  = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            // ===== stage 1: scores gemm (the gemm_b2<64> loop VERBATIM; BM=64,BN=64,
            // BK=16; NT=16: WIR=4, WIC=4; ACH=(64*16)/16=64, BCH=(16*64)/16=64) =====
            const int TS = 16, BM = 64, BN = 64, BK = 16;
            const int SLM_A = BM*BK*2, SLM_B = BK*BN*2, SLM_B_BASE = 2*SLM_A;
            const int ACH = (BM*BK)/16, BCH = (BK*BN)/16;
            const int kb_n = 32/BK;             // 2
            const half* Ab = dAq + (size_t)b * 64 * 32;
            const half* Bb = dBk + (size_t)b * 32 * 64;
            
            // P10b RAW mode: stage the Q/K dpas tiles from the RAW f16 operands ONCE
            // per WG. Both packs read row-major (rows,32): the tile elem map
            // d = ((blk*2+strip)*8+il)*16 + k (blk=(tr,kc)) reduces to row =
            // tr*16+strip*8+il, col = kc*16+k -- pack_a16_b/pack_b16_t_b VERBATIM.
            // 16 threads: thread lid = (il=lid/2, kq=lid%2): an 8-half piece each.
            if (raw_qk) {
                const half* Qb = dQ + (size_t)b * 64u * 32u;
                const half* Kb = dK + (size_t)b * 64u * 32u;
                #pragma unroll
                for (int blk = 0; blk < 8; ++blk) {          // Q-side blk = tr*2+kc
                    int trr = blk / 2, kc2 = blk % 2;
                    #pragma unroll
                    for (int strip = 0; strip < 2; ++strip) {
                        // Q: pack_a16_b map (k CONTIGUOUS): tile elem =
                        // ((tr*2+kc)*2+strip)*128 + il*16 + k : 16 raw halves -> 16 tile halves
                        uint row  = (uint)(trr * 16 + strip * 8 + (int)(lid / 2u));
                        uint elem = (uint)(blk * 2 + strip) * 128u + (lid / 2u) * 16u + (lid % 2u) * 8u;
                        esimd::simd<half,8> vq = esimd::block_load<half,8>(Qb + (size_t)row * 32u + (uint)kc2 * 16u + (lid % 2u) * 8u, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(WA_QT + elem * 2u, vq, esimd::overaligned_tag<16>{});
                        // K: pack_b16_t_b map (k INTERLEAVED kq*2+kpar): tile elem =
                        // ((kc*tc_n+tc)*2+js)*128 + kq*16 + jl*2 + kpar. blk here = tr*2+kc =
                        // tc*2+kc SWAPPED vs the pack's kc*8+tc*2 -- the gemm reads block
                        // (kc,tc) at (kc*tc_n+tc)*2*128: our loop's blk=(tr,kc) with tr=tc
                        // (square 64x64: tr_n == tc_n == 2? NO: kb_n=2, tc_n=4 for B).
                        // DO IT PER THE PACK: for (kc,tc,js): thread lid -> jl = lid/2? 16
                        // threads: jl = lid, js = 0? one strip per pass:
                        //   load 16 raw halves at row (tc*16+js*8+jl), cols kc*16..+16;
                        //   for kq 0..7: tile 2-halves at ((kc*4+tc)*2+js)*128 + kq*16 + jl*2 + {0,1}
                        (void)row; (void)elem;
                    }
                }
                // K gather with the pack_b16_t_b INTERLEAVED map: tile elem =
                // ((kc*4+tc)*2+js)*128 + kq*16 + jl*2 + kpar <- raw[(tc*16+js*8+jl)*32 +
                // kc*16 + kq*2+kpar]. thread lid -> (js = lid/8, jl = lid%8).
                #pragma unroll
                for (int kc2 = 0; kc2 < 2; ++kc2)
                #pragma unroll
                for (int tc2 = 0; tc2 < 4; ++tc2) {
                    uint js = lid / 8u, jl = lid % 8u;
                    esimd::simd<half,16> vr = esimd::block_load<half,16>(Kb + (size_t)(tc2 * 16 + js * 8 + jl) * 32u + (uint)kc2 * 16u, esimd::overaligned_tag<16>{});
                    // scatter: for kq 0..7: two halves -> tile ((kc2*4+tc2)*2+js)*128 + kq*16 + jl*2 + kpar
                    uint tb = ((uint)(kc2 * 4 + tc2) * 2u + js) * 128u + jl * 2u;
                    #pragma unroll
                    for (int kq = 0; kq < 8; ++kq) {
                        esimd::simd<half,2> piece;
                        piece[0] = vr[kq * 2]; piece[1] = vr[kq * 2 + 1];
                        esimd::slm_block_store(WA_KT + (tb + (uint)kq * 16u) * 2u, piece, esimd::overaligned_tag<4>{});
                    }
                }
                esimd::barrier();
                if (kt_dump && b == 0u) {   // DUMP the whole 2KB K tile to global
                    #pragma unroll
                    for (int p2 = 0; p2 < 4; ++p2) {
                        esimd::simd<half,32> tv = esimd::slm_block_load<half,32>(WA_KT + (uint)(p2 * 512u + lid * 32u) * 2u, esimd::overaligned_tag<16>{});
                        tv.copy_to(kt_dump + (size_t)(p2 * 16u + lid) * 32u);
                    }
                }
            }

            auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                if (raw_qk) {   // P10b: SLM->SLM copies of the kc-slice's 4 blocks
                    // the slice = blocks (tr*2+kc) tr 0..3: each block 256 halfs at
                    // tile offset ((tr*2+kc)*2)*128? NO: block index = (tr,kc) -> tile
                    // half-offset ((tr*2+kc)*2+strip)*128: the 4 blocks (strip 0/1 each)
                    // = 2048 halfs per slice? the slice = 4 tr x 256 halfs = 1024 halfs? BM*BK=64*16=1024 halfs = 2KB: blocks (tr,kc): 4 blocks x 256 halfs. thread lid moves 64 halfs: src = WA_QT + ((tr*2+kc)*2)*128 + (lid%8)*... SIMPLEST: per-thread 64-half pieces: idx t: tr = t/4? Let me: for p in 0..3: each thread copies 64 halfs at tile position of block (p,kc) + (lid*64 within the block's 256? block=256 halfs: 4 threads per block. thread lid: p=lid/4, w=lid%4: src=((p*2+kc)*2)*128 + w*64; dst = buf*SLM_A + (p* (TS*BK*... the gemm's SLM_A layout: block(tr,kc) at (tr*kb_n+kc)*2*128 halfs? from the loop's offA = cur*SLM_A + wi_row*(TS*BK*2): SLM_A stride per tr band = TS*BK=256 halfs: dst elems (tr,kc) at tr*256 + kc*0? The double-buffer holds the WHOLE (BM x BK) for one kc: elems (tr band wi_row) at wi_row*256. dst = buf*SLM_A + tr*256 + w*64.
                    #pragma unroll
                    for (int p = 0; p < 4; ++p) {
                        int tt = (int)(lid / 4u), w = (int)(lid % 4u);
                        if (tt != p) continue;
                        esimd::simd<half,64> av = esimd::slm_block_load<half,64>(WA_QT + (uint)(((tt*2+kc)*2)*128 + w*64) * 2u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,64> bv = esimd::slm_block_load<half,64>(WA_KT + (uint)(((kc*4+tt)*2)*128 + w*64) * 2u, esimd::overaligned_tag<16>{});   // FIXED: gather wrote block(kc,tc) at (kc*4+tc)*256; the copy read the A-pattern (tc*2+kc)*256
                        esimd::slm_block_store(WA_X + buf * SLM_A + (uint)(tt * 256 + w * 64) * 2u, av, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(WA_X + SLM_B_BASE + buf * SLM_B + (uint)(tt * 256 + w * 64) * 2u, bv, esimd::overaligned_tag<16>{});
                    }
                } else {
                #pragma unroll
                for (int i = 0; i < ACH / 64; ++i) {
                    int la = lid * ACH + i * 64;
                    int trl = la / 256, within = la % 256;
                    esimd::simd<half,64> v = esimd::block_load<half,64>(
                        Ab + ((size_t)((trl) * kb_n + kc) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(WA_X + buf * SLM_A + la * 2, v, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int i = 0; i < BCH / 64; ++i) {
                    int lb = lid * BCH + i * 64;
                    int tcl = lb / 256, within = lb % 256;
                    esimd::simd<half,64> v = esimd::block_load<half,64>(
                        Bb + ((size_t)(kc * 4 + (tcl)) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(WA_X + SLM_B_BASE + buf * SLM_B + lb * 2, v, esimd::overaligned_tag<16>{});
                }
                }
            };
            int wi_row = lid / 4, wi_col = lid % 4;
            esimd::simd<float,64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            load_block(0, 0);
            esimd::barrier();
            for (int kb = 0; kb < kb_n; ++kb) {
                int cur = kb & 1, nxt = cur ^ 1;
                if (kb + 1 < kb_n) load_block(nxt, kb + 1);
                uint32_t offA = WA_X + cur * SLM_A + wi_row * (TS * BK * 2);
                uint32_t offB = WA_X + SLM_B_BASE + cur * SLM_B + wi_col * (TS * BK * 2);
                esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(offA, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(offA + 256, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(offB, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(offB + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8,8,float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8,8,float>(c11, b1, a1);
                esimd::barrier();
            }
            // stage the scores into Z (the pub_slm C-stage: fragments -> SLM f32,
            // the tile's own row-major map (wi_row band r, wi_col band 16 cols))
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + r) * 64 + wi_col*16)) * 4u,
                    c00.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + r) * 64 + wi_col*16 + 8)) * 4u,
                    c01.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + 8 + r) * 64 + wi_col*16)) * 4u,
                    c10.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + 8 + r) * 64 + wi_col*16 + 8)) * 4u,
                    c11.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            if (stop_stage == 1) {   // BISECT: dump the Z scores to global dScores
                for (int rr = 0; rr < 4; ++rr) {
                    uint row = lid * 4u + rr;
                    esimd::simd<float,32> z0 = esimd::slm_block_load<float,32>(WA_Z + row * 256u, esimd::overaligned_tag<16>{});
                    esimd::simd<float,32> z1 = esimd::slm_block_load<float,32>(WA_Z + row * 256u + 128u, esimd::overaligned_tag<16>{});
                    z0.copy_to(dScores + (size_t)b * 4096u + (size_t)row * 64u);
                    z1.copy_to(dScores + (size_t)b * 4096u + (size_t)row * 64u + 32u);
                }
                return;
            }
            // ===== stage 2: softmax, 4 rows per thread (the smax_esimd math VERBATIM;
            // the row source = Z (SLM), the probs dest = Y in the pack_a16 map) =====
            for (int rr = 0; rr < 4; ++rr) {
                uint row = lid * 4u + rr;                    // local row in the batch
                uint rgl = b * 64u + row;                    // the global row (bias map)
                esimd::simd<float,32> s0 = esimd::slm_block_load<float,32>(WA_Z + row * 256u, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> s1 = esimd::slm_block_load<float,32>(WA_Z + row * 256u + 128u, esimd::overaligned_tag<16>{});
                size_t boff = ((size_t)(rgl / 64u) % (size_t)heads) * 4096u + (size_t)(rgl % 64u) * 64u;
                esimd::simd<float,32> b0v = esimd::block_load<float,32>(dBias + boff, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> b1v = esimd::block_load<float,32>(dBias + boff + 32, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<sycl::half>(s0 + b0v));
                esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<sycl::half>(s1 + b1v));
                esimd::simd<float,32> a0v = esimd::convert<float>(esimd::convert<sycl::half>(
                    hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                esimd::simd<float,32> a1v = esimd::convert<float>(esimd::convert<sycl::half>(
                    hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                a0v = (esimd::min)((esimd::max)(a0v, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                a1v = (esimd::min)((esimd::max)(a1v, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                esimd::simd<sycl::half,16> he0=esimd::convert<sycl::half>(a0v.template select<16,2>(0).read());
                esimd::simd<sycl::half,16> ho0=esimd::convert<sycl::half>(a0v.template select<16,2>(1).read());
                esimd::simd<sycl::half,16> he1=esimd::convert<sycl::half>(a1v.template select<16,2>(0).read());
                esimd::simd<sycl::half,16> ho1=esimd::convert<sycl::half>(a1v.template select<16,2>(1).read());
                esimd::simd<uint16_t,16> e0=he0.bit_cast_view<uint16_t>(), o0=ho0.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> e1=he1.bit_cast_view<uint16_t>(), o1=ho1.bit_cast_view<uint16_t>();
                esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
                esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
                esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<sycl::half,32> w0; w0=t0.bit_cast_view<sycl::half>();
                esimd::simd<sycl::half,32> w1; w1=t1.bit_cast_view<sycl::half>();
                esimd::simd<float,32> f0 = esimd::convert<float>(w0);
                esimd::simd<float,32> f1 = esimd::convert<float>(w1);
                float total = 0.0f;
                for (unsigned cc = 0; cc < 32u; ++cc) total += f0[cc];
                for (unsigned cc = 0; cc < 32u; ++cc) total += f1[cc];
                float trh = wbmega::eh_round(total);
                float recip = wbmega::eh_round(wbv2::ef_div(1.0f, trh));
                esimd::simd<sycl::half,32> oh0 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w0), recip)));
                esimd::simd<sycl::half,32> oh1 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w1), recip)));
                // pack_a16 store into Y: tr=row/16, strip=(row%16)/8, il=row%8;
                // dest((tr*4+kc)*2+strip)*128 + il*16 + k16 (halfs)
                uint trr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                uint base = WA_Y + ((trr * 4u + 0u) * 2u + strip) * 256u + il * 32u;   // BYTES: block(tr,0)=(tr*4)*512; strip +256; il*16 half = il*32 B
                esimd::simd<half,16> q0 = oh0.template select<16,1>(0), q1 = oh0.template select<16,1>(16);
                esimd::simd<half,16> q2 = oh1.template select<16,1>(0), q3 = oh1.template select<16,1>(16);
                esimd::slm_block_store(base, q0, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(base + 512u, q1, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(base + 1024u, q2, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(base + 1536u, q3, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            if (stop_stage == 2) {   // BISECT: dump the whole Y region (4096 halfs)
                #pragma unroll
                for (int blk = 0; blk < 8; ++blk) {   // thread slice: 256 halfs (512 B)
                    esimd::simd<half,32> v = esimd::slm_block_load<half,32>(WA_Y + (lid * 256u + blk * 32u) * 2u, esimd::overaligned_tag<16>{});   // FIXED: the read stride must match the write (the 512/64 pair read 8KB PAST the 8KB Y region = the GPU fault, rc=127 no-output = the black-screen class again, caught by the harness not the game)
                    v.copy_to(dAp + (size_t)b * 4096u + (size_t)lid * 256u + blk * 32u);
                }
                return;
            }
            // ===== stage 3: attnV (BN=32: gemm_b2<32> geometry, NT=8 -> threads 0..7;
            // A from Y (SLM, the tile8s pattern), B from global dBv, merge-fold store) =====
            {
                const int SLM_B2 = BK*32*2;                 // 1024
                const int BCH2 = (BK*32)/8;                 // 64
                int t8 = (int)lid % 8;
                const half* Bb2 = dBv + (size_t)b * 64 * 32;
                int tr2 = t8 / 2, tc2 = t8 % 2;
                auto load_block2 = [&](int buf, int kc) SYCL_ESIMD_FUNCTION {
                    // A: this WG's probs live in Y ALREADY in the pack_a16 block map --
                    // gemm_b2's load_block stages A blocks (tr,kc) into SLM_A; here the
                    // A block (tr2,kc) IS at Y ((tr2*4+kc)*2+strip)*128: the tile8s form
                    // reads A fragments DIRECTLY from Y (no restage). B: global pack.
                    #pragma unroll
                    for (int i = 0; i < BCH2 / 64; ++i) {
                        int lb = t8 * BCH2 + i * 64;
                        int tcl = lb / 256, within = lb % 256;
                        esimd::simd<half,64> v = esimd::block_load<half,64>(
                            Bb2 + ((size_t)(kc * 2 + tcl) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(WA_X + 4096u + buf * SLM_B2 + lb * 2, v, esimd::overaligned_tag<16>{});
                    }
                };
                esimd::simd<float,64> d00(0.f), d01(0.f), d10(0.f), d11(0.f);
                load_block2(0, 0);
                esimd::barrier();
                for (int kb = 0; kb < 4; ++kb) {     // K=64: kb_n=4
                    int cur = kb & 1, nxt = cur ^ 1;
                    if (kb + 1 < 4) load_block2(nxt, kb + 1);
                    uint32_t offA = WA_Y + (uint32_t)(((size_t)tr2 * 4u + (size_t)kb) * 2u) * 256u;
                    uint32_t offB = WA_X + 4096u + cur * SLM_B2 + tc2 * (TS * BK * 2);
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(offA, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(offA + 256, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(offB, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(offB + 256, esimd::overaligned_tag<16>{});
                    d00 = esimd::xmx::dpas<8,8,float>(d00, b0, a0);
                    d01 = esimd::xmx::dpas<8,8,float>(d01, b1, a0);
                    d10 = esimd::xmx::dpas<8,8,float>(d10, b0, a1);
                    d11 = esimd::xmx::dpas<8,8,float>(d11, b1, a1);
                    esimd::barrier();
                }
                // merge-fold store (the gemm_b2_merge tail VERBATIM): batch b =
                // window*heads + head; the fragment rows tr2*16 + {r, 8+r}, cols tc2*16+c
                unsigned window = b / heads, head = b % heads;
                const unsigned CH = heads * 32u;
                if (stop_stage == 3 && t8 == (int)lid) {   // BISECT: RAW f32 dump -> dCtx (dup threads skip)
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<float,8> r00 = d00.template select<8,1>(r*8), r01 = d01.template select<8,1>(r*8);
                        esimd::simd<float,8> r10 = d10.template select<8,1>(r*8), r11 = d11.template select<8,1>(r*8);
                        size_t o0 = ((size_t)b * 2048u + (size_t)(tr2 * 16 + r) * 32u + (unsigned)tc2 * 16u);
                        size_t o2 = o0 + 8u * 32u;
                        r00.copy_to(dCtx + o0); r01.copy_to(dCtx + o0 + 8u);
                        r10.copy_to(dCtx + o2); r11.copy_to(dCtx + o2 + 8u);
                    }
                    return;
                }
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<float,8> r00 = d00.template select<8,1>(r*8), r01 = d01.template select<8,1>(r*8);
                    esimd::simd<float,8> r10 = d10.template select<8,1>(r*8), r11 = d11.template select<8,1>(r*8);
                    esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                    esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                    esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                    esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                    size_t o0 = (((size_t)window * 64u + (size_t)(tr2 * 16 + r)) * CH
                                 + head * 32u + (unsigned)tc2 * 16u);
                    size_t o2 = (((size_t)window * 64u + (size_t)(tr2 * 16 + 8 + r)) * CH
                                 + head * 32u + (unsigned)tc2 * 16u);
                    h00.copy_to(outRes + o0); h01.copy_to(outRes + o0 + 8u);
                    h10.copy_to(outRes + o2); h11.copy_to(outRes + o2 + 8u);
                }
            }   // stage 3 all-16 (8 duplicate bands -- identical work, identical stores)
        });
        });
        return std::vector<event>{ev}; });
    if (stop_stage == 1 && pRS) {   // resident Z-dump (now in dScores) vs the split's
        std::vector<float> rb((size_t)batches*4096u);
        q.memcpy(rb.data(), dScores, rb.size()*4).wait();
        size_t d1 = 0; for (size_t i = 0; i < rb.size(); ++i) if (refScores[i] != rb[i]) d1++;
        printf("wa-res BISECT stage1 (scores in Z): diff %zu / %zu %s\n", d1, rb.size(), d1?"NOT-EXACT":"EXACT");
    }
    if (stop_stage == 3) {
        std::vector<float> ra((size_t)batches*2048u), rb((size_t)batches*2048u);
        // ra = the split's dCtx BEFORE the resident dump overwrote it: capture first
        (void)ra; (void)rb;
    }
    if (stop_stage == 2 && pRA) {   // resident Y-dump (now in dAp) vs the split's dAp
        std::vector<sycl::half> rb((size_t)batches*4096u);
        q.memcpy(rb.data(), dAp, rb.size()*2).wait();
        size_t d2 = 0; for (size_t i = 0; i < rb.size(); ++i) if (refAp[i] != rb[i]) d2++;
        printf("wa-res BISECT stage2 (probs in Y): diff %zu / %zu %s\n", d2, rb.size(), d2?"NOT-EXACT":"EXACT");
    }
    if (stop_stage == 3 && pRC) {
        std::vector<float> rb((size_t)batches*2048u);
        q.memcpy(rb.data(), dCtx, rb.size()*4).wait();
        size_t d3 = 0; for (size_t i = 0; i < rb.size(); ++i) if (refCtx[i] != rb[i]) d3++;
        printf("wa-res BISECT stage3 (attnV raw): diff %zu / %zu %s\n", d3, rb.size(), d3?"NOT-EXACT":"EXACT");
    }
    if (stop_stage == 0) {
    if (kt_dump) {
        std::vector<sycl::half> got(2048), want(2048);
        q.memcpy(got.data(), kt_dump, 4096).wait();
        q.memcpy(want.data(), dBk, 4096).wait();   // packed batch-0 tile (proven)
        int d3=0; for (int i2=0;i2<2048;++i2) if (got[i2]!=want[i2]) d3++;
        printf("WA_KT vs packed dBk[0] (b=0): diff %d / 2048\n", d3);
        int shown=0;
        for (int i2=0;i2<2048 && shown<4;++i2) if (got[i2]!=want[i2]) {
            printf("  elem %d (blk %d within %d): got %.6g want %.6g\n", i2, i2/256, i2%256, (float)got[i2], (float)want[i2]); shown++; }
        free(kt_dump,q);
    }
    std::vector<sycl::half> a((size_t)windows*64u*heads*32u), bb((size_t)windows*64u*heads*32u);
    q.memcpy(a.data(), outRef, a.size()*2).wait();
    q.memcpy(bb.data(), outRes, bb.size()*2).wait();
    size_t diff = 0; for (size_t i = 0; i < a.size(); ++i) if (a[i] != bb[i]) diff++;
    printf("wa-res batches=%u heads=%u | split %7.3f  resident %7.3f (%.2fx) | diff %zu / %zu %s\n",
        batches, heads, t_split, t_res, t_split/t_res, diff, a.size(), diff ? "NOT-EXACT" : "EXACT");
    }
    free(dQ,q);free(dK,q);free(dV,q);free(dBias,q);free(dAq,q);free(dBk,q);free(dAp,q);free(dBv,q);
    free(dScores,q);free(outRef,q);free(outRes,q);free(dProbs,q);free(dCtx,q);
}

int main() {
    queue q(device{}, property::queue::enable_profiling{});
    int st = getenv("WA_BISECT") ? atoi(getenv("WA_BISECT")) : 0;
    one_wa_res(q, 1020u, 2u, st);
    if (getenv("WA_KTDUMP")) one_wa_res(q, 16u, 1u, 0, true);
    if (getenv("WA_RAW")) {
        one_wa_res(q, 1020u, 2u, 0, true);
        one_wa_res(q, 16u, 1u, 0, true);
        one_wa_res(q, 16u, 1u, 1, true);   // STAGE-1 BISECT: RAW scores vs packed dScores
        one_wa_res(q, 6u, 1u, 0, true);    // THE WB-GATE shapes: 16x24 -> windows 6?
        one_wa_res(q, 12u, 1u, 0, true);   // 20x36-crop windows; heads=1 (the gate run())
    }
    one_wa_res(q, 16u, 1u, 0);    // the gate's WB-16x24 shape
    one_wa_res(q, 18u, 2u, 0);    // the gate's WB-20x36-crop shape
    return 0;
}
