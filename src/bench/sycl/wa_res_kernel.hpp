// wa_res_kernel.hpp -- section 100 P10b/P10c: the window_attention RESIDENT BLOCK
// with RAW operands. One WG = one batch: the Q/K/V dpas tiles are GATHERED from the
// RAW f16 operands once per WG (the pack maps VERBATIM: Q = pack_a16_b contiguous;
// K = pack_b16_t_b interleaved; V = pack_b16_b interleaved via the 2x8-half
// interleave form). SLM regions sized by BLOCKS (each tile = 8 blocks x 256 halfs =
// 4KB -- the 2KB-by-elements sizing bug overlapped QT into KT and the WB gates caught
// it). Then scores gemm -> accumulator staged into SLM Z -> softmax reads Z, writes
// probs into SLM Y (the smax_esimd math VERBATIM) -> attnV consumes A from Y directly
// (tile8s pattern; B copies from the dead X operand slots) with the P9 merge-fold
// store. dScores/dProbs/dAp AND the Q/K (and with raw_v, V) pack launches vanish.
// SLM = 8(X) + 16(Z) + 8(Y) + 4(QT) + 4(KT) + 4(VT) = 44KB at LW=16 (the v4ph 45KB
// line, power-of-two regions; the P3c barrier discipline: stage-3 bands run on all 16
// threads). bench_wa_res: SIX shapes all EXACT (1020x2 packed/RAW/RAWV, 16x1, 6x1,
// 12x1, 18x2). Guards: merged==1, bias present, tokens==64. Gates: NR_WA_RES=0 ->
// split chain; NR_WA_RAWV=1 -> the V tile gathered too (the cross-A/B decides).
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"

namespace wares {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

#define WA_X 0u
#define WA_Z 8192u
#define WA_Y 24576u
#define WA_QT 32768u
#define WA_KT 36864u
#define WA_VT 40960u
#define WA_SLM 45056u

static inline event launch_wa_res(queue& q, const half* dQ, const half* dK, const half* dV,
                                  const half* dBv, const float* dBias, half* Out,
                                  unsigned batches, unsigned heads, bool raw_v) {
    return q.submit([&](handler& h) {
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
            const half* Ab = dQ + (size_t)b * 64 * 32;
            const half* Bb = dK + (size_t)b * 32 * 64;
            
            // P10b RAW mode: stage the Q/K dpas tiles from the RAW f16 operands ONCE
            // per WG. Both packs read row-major (rows,32): the tile elem map
            // d = ((blk*2+strip)*8+il)*16 + k (blk=(tr,kc)) reduces to row =
            // tr*16+strip*8+il, col = kc*16+k -- pack_a16_b/pack_b16_t_b VERBATIM.
            // 16 threads: thread lid = (il=lid/2, kq=lid%2): an 8-half piece each.
            if (true) {   // P10b: Q/K always RAW in the recorder form
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
                // kc*16 + kq*2+kpar].
                // BLADE-7 (supply audit 20:1x, the supply list the user's memo pushed
                // us to run): the OLD form wrote the tile with 1024 TWO-HALF SLM stores
                // per WG (4-byte messages -- the worst supply pattern in the whole
                // chain, counted 75 narrow send.slm in the AOT asm). New form: ONE
                // thread owns one 128-half tile BLOCK bidx=(kc*4+tc)*2+js: it loads the
                // block's 8 raw rows (8 x 32B overaligned global loads, rows shared
                // across the kc pair = L1) and assembles the 128-half block IN
                // REGISTERS (select-to-select copies = register shuffles, the free
                // strided-mov encoding), then ONE 256B slm_block_store. Values and
                // addresses are IDENTICAL to the old form by construction (same elem
                // map, just different message shape). WINDOW_ATTENTION gate + 1301 judge.
                {
                    uint bidx = lid;                       // 16 threads = 16 blocks
                    uint kc2 = bidx / 8u, tc2 = (bidx / 2u) % 4u, js = bidx % 2u;
                    esimd::simd<half,16> rows[8];
                    #pragma unroll
                    for (int jl = 0; jl < 8; ++jl)
                        rows[jl] = esimd::block_load<half,16>(
                            Kb + (size_t)(tc2 * 16 + js * 8 + jl) * 32u + kc2 * 16u,
                            esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> blk;
                    #pragma unroll
                    for (int kq = 0; kq < 8; ++kq)
                        #pragma unroll
                        for (int jl = 0; jl < 8; ++jl)
                            blk.template select<2,1>(kq * 16 + jl * 2) =
                                rows[jl].template select<2,1>(kq * 2);
                    esimd::slm_block_store(WA_KT + bidx * 128u * 2u, blk, esimd::overaligned_tag<16>{});
                }
                esimd::barrier();
                
                if (raw_v) {   // P10c V gather (clean): tile blocks bidx =
                    // (kc*2+tc)*2+js (0..15) -- thread lid = bidx; for kq 0..7 the
                    // tile's CONTIGUOUS 16-half run at bidx*128 + kq*16 holds elems
                    // j = jl*2+kpar (0..15): raw row kc*16 + kq*2 + (j%2), col
                    // tc*16 + js*8 + j/2 -- the pack_b16_b map VERBATIM.
                    const half* Vb = dV + (size_t)b * 64u * 32u;
                    uint bidx = lid;
                    uint kc2 = bidx / 4u, tc2 = (bidx / 2u) % 2u, js = bidx % 2u;
                    #pragma unroll
                    for (int kq = 0; kq < 8; ++kq) {
                        // run[j] = (j even) row kq*2, col j/2 ; (j odd) row kq*2+1,
                        // col j/2 -- INTERLEAVE of two contiguous 8-half raw rows:
                        // the scalar 16-load form cost +0.15ms/frame (measured).
                        esimd::simd<half,16> run;
                        esimd::simd<half,8> a = esimd::block_load<half,8>(Vb + (size_t)(kc2 * 16u + kq * 2u) * 32u + tc2 * 16u + js * 8u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,8> b = esimd::block_load<half,8>(Vb + (size_t)(kc2 * 16u + kq * 2u + 1u) * 32u + tc2 * 16u + js * 8u, esimd::overaligned_tag<16>{});
                        run.select<8,2>(0) = a;   // even lanes: row kq*2
                        run.select<8,2>(1) = b;   // odd lanes:  row kq*2+1
                        esimd::slm_block_store(WA_VT + (bidx * 128u + (uint)kq * 16u) * 2u,
                                               run, esimd::overaligned_tag<16>{});
                    }
                }
            }

            auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                if (true) {   // P10b: Q/K always RAW in the recorder form   // P10b: SLM->SLM copies of the kc-slice's 4 blocks
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
                        if (raw_v) {   // P10c: SLM->SLM copy from the V tile (the
                            // gather's linear map == the gemm's block addressing)
                            esimd::simd<half,64> v2 = esimd::slm_block_load<half,64>(WA_VT + (uint)(kc * 512 + lb) * 2u, esimd::overaligned_tag<16>{});   // the kc-slice offset was MISSING (the block map is kc*512 + tcl*256 + within == kc*512 + lb)
                            esimd::slm_block_store(WA_X + 4096u + buf * SLM_B2 + lb * 2, v2, esimd::overaligned_tag<16>{});
                        } else {
                        esimd::simd<half,64> v = esimd::block_load<half,64>(
                            Bb2 + ((size_t)(kc * 2 + tcl) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(WA_X + 4096u + buf * SLM_B2 + lb * 2, v, esimd::overaligned_tag<16>{});
                        }
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
                    h00.copy_to(Out + o0); h01.copy_to(Out + o0 + 8u);
                    h10.copy_to(Out + o2); h11.copy_to(Out + o2 + 8u);
                }
            }   // stage 3 all-16 (8 duplicate bands -- identical work, identical stores)
        });
    });
}
}
