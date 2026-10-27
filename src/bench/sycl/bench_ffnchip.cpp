// bench_ffnchip.cpp v3 -- section 100 P3c: the ffn_fused CHIP form, addressing FIXED.
// v2's 16x bug (bisect-proven): tr = wg*4 + (lid>>4) made SIXTEEN work-items compute
// the SAME 16-row tile -- the senior's coopmat tile spreads over 32 SUBGROUP LANES,
// but an ESIMD tile lives in ONE thread's registers, so the v4ph sgid/lane split does
// NOT transfer to dpas-accumulator code. skip-pub restored the split's speed exactly
// (1.26 vs 1.69) -> the dpas/stage structure was right, the tile COUNT was 16x.
// v3: ONE work-item = ONE 16-row tile through BOTH gemms (the senior's "one subgroup
// takes 16 rows through both" -- in ESIMD the thread IS the subgroup owner). dpas
// count now EQUALS the split chain's. LW=32; SLM = EB 8KB + PB 8KB (weights, staged
// once per WG -- the senior's 0x800000 lesson) + HS 32x1KB per-thread hidden stage
// (the projection's pack_a16 A-block layout; per-thread private, the barriers keep
// the compiler from hoisting HS reads over HS writes) = 48KB total. A operand: 4 x
// simd<half,128> in GRF. pub_esimd(3) scalar chain VERBATIM (= the promoted
// gemm_pub_pa16 arithmetic exactly; the z8 pad bypass kept). Residual tail: the
// auto-contracted sk*cv+f form (gemm_b_res golden semantics).
// Open risk (measured, not guessed): 8 projection + 4 expand live accumulators + 4 A
// operands = GRF pressure -> possible spill (the v9b ">8 accs" zone). If v3 loses,
// the next form is the two-pass-in-one-kernel variant (expand all 8 tl, stage ALL
// 2KB of hidden, then one projection walk with only 8 live).
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
#include "pack_device.hpp"

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

#define SLM_EA_OFF 0u
#define SLM_HS_OFF 32768u
#define SLM_BYTES  (64u * 1024u)   // v3c: EA 32KB + HS 32KB

static void one_ffn_chip(queue& q, unsigned M, bool with_residual) {
    const unsigned cin = 32, hidden = 128;
    size_t na = (size_t)M * cin;
    std::vector<sycl::half> hA(na), hE((size_t)hidden * cin), hP((size_t)cin * hidden), hSkip(na);
    std::vector<float> hCos(cin);
    std::mt19937 rng(7); std::uniform_real_distribution<float> df(-6.f, 6.f);
    for (auto& x : hA) x = sycl::half(df(rng));
    for (auto& x : hE) x = sycl::half(df(rng) * 0.3f);
    for (auto& x : hP) x = sycl::half(df(rng) * 0.3f);
    for (auto& x : hSkip) x = sycl::half(df(rng));
    for (auto& x : hCos) x = df(rng) * 0.1f;
    sycl::half* dA = malloc_device<sycl::half>(na, q);
    sycl::half* dE = malloc_device<sycl::half>(hE.size(), q);
    sycl::half* dP = malloc_device<sycl::half>(hP.size(), q);
    sycl::half* dSkip = malloc_device<sycl::half>(na, q);
    float* dCos = malloc_device<float>(cin, q);
    q.memcpy(dA, hA.data(), na*2); q.memcpy(dE, hE.data(), hE.size()*2);
    q.memcpy(dP, hP.data(), hP.size()*2); q.memcpy(dSkip, hSkip.data(), na*2);
    q.memcpy(dCos, hCos.data(), cin*4); q.wait();
    sycl::half* dEp = malloc_device<sycl::half>(hE.size(), q);
    sycl::half* dPp = malloc_device<sycl::half>(hP.size(), q);
    packdev::pack_b16(q, dE, dEp, (int)cin, (int)hidden);
    packdev::pack_b16(q, dP, dPp, (int)hidden, (int)cin);
    int Mp = (int)(((M + 15u) / 16u) * 16u);
    sycl::half* dAp = malloc_device<sycl::half>((size_t)Mp * cin, q);
    sycl::half* dHp = malloc_device<sycl::half>((size_t)Mp * hidden, q);
    float* dC2 = malloc_device<float>((size_t)Mp * cin, q);
    float* outRef = malloc_device<float>((size_t)M * cin, q);
    float* outChip = malloc_device<float>((size_t)M * cin, q);
    q.memset(outChip, 0, (size_t)M * cin * 4);
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9; for(int it=0;it<15;++it){ auto es=fn(); for(auto&e:es)e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    packdev::pack_a16(q, dA, dAp, (int)M, Mp, (int)cin);
    double t_split = timeit([&]{
        event e1 = f16v1::gemm_pub_pa16(q, dAp, dEp, dHp, (int)M, Mp, (int)hidden, (int)cin, 3u);
        event e2 = f16v1::gemm(q, dHp, dPp, dC2, Mp, (int)cin, (int)hidden);
        event e3 = q.parallel_for(range((size_t)M * cin), [=](item<1> it) {
            size_t i = it.get_id(0);
            unsigned col = (unsigned)(i % cin);
            float total = dC2[i];
            if (with_residual) total = sycl::fma((float)dSkip[i], dCos[col], total);
            outRef[i] = total;
        });
        return std::vector<event>{e1,e2,e3}; });
    int tiles = Mp / 16;
    int wgs = (tiles + 31) / 32;
    double t_chip = timeit([&]{
        event ev = q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wgs * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_BYTES>();
            uint wg = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int tr = (int)(wg * 32u + lid);
            if (tr >= tiles) return;   // v3b: no weight staging, no barrier -- the
                                       // weights are read from GLOBAL per dpas
                                       // (exactly the split gemm's B access; L2
                                       // catches the reuse across the 8160 tiles)
            // ---- v3c: A operand -> SLM (pack_a16 map), NOT GRF: frees 4 x 256B
            // registers -- the 16-live-GRF spill suspect (v9b ">8 accs" family) ----
            uint ea = SLM_EA_OFF + lid * 1024u;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::simd<half,32> v((half)0.f);
                if (tr * 16 + r < (int)M)
                    v = esimd::block_load<half,32>(dA + (size_t)(tr * 16 + r) * cin, esimd::overaligned_tag<16>{});
                esimd::simd<half,16> lo0 = v.template select<16,1>(0), hi0 = v.template select<16,1>(16);
                esimd::slm_block_store(ea + (uint)r*32u, lo0, esimd::overaligned_tag<16>{});          // block(kc0,strip0)
                esimd::slm_block_store(ea + 512u + (uint)r*32u, hi0, esimd::overaligned_tag<16>{});    // block(kc1,strip0)
            }
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::simd<half,32> v((half)0.f);
                if (tr * 16 + 8 + r < (int)M)
                    v = esimd::block_load<half,32>(dA + (size_t)(tr * 16 + 8 + r) * cin, esimd::overaligned_tag<16>{});
                esimd::simd<half,16> lo1 = v.template select<16,1>(0), hi1 = v.template select<16,1>(16);
                esimd::slm_block_store(ea + 256u + (uint)r*32u, lo1, esimd::overaligned_tag<16>{});    // block(kc0,strip1)
                esimd::slm_block_store(ea + 768u + (uint)r*32u, hi1, esimd::overaligned_tag<16>{});    // block(kc1,strip1)
            }
            esimd::barrier();   // v3c FIX: the A stores must be visible before the
                                // SLM loads (v3b had no SLM A; the removed weight
                                // barrier also guarded this -- restore it here)
            uint hs = SLM_HS_OFF + lid * 1024u;   // per-thread 1KB hidden stage (this chunk)
            esimd::simd<float,64> p00(0.f), p01(0.f), p10(0.f), p11(0.f);   // out cols 0..15
            esimd::simd<float,64> q00(0.f), q01(0.f), q10(0.f), q11(0.f);   // out cols 16..31
            const esimd::simd<half,8> z8((half)0.f);
            for (int c = 0; c < 4; ++c) {
                for (int tl = 0; tl < 2; ++tl) {
                    esimd::simd<float,64> e00(0.f), e01(0.f), e10(0.f), e11(0.f);
                    #pragma unroll
                    for (int kc = 0; kc < 2; ++kc) {
                        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+0u)*256u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+1u)*256u, esimd::overaligned_tag<16>{});
                        uint tc = (uint)(c * 2 + tl);
                        const half* bb = dEp + ((size_t)kc * 8u + tc) * 2u * 128u;
                        esimd::simd<half,128> b0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        e00 = esimd::xmx::dpas<8,8,float>(e00, b0, a0);
                        e01 = esimd::xmx::dpas<8,8,float>(e01, b1, a0);
                        e10 = esimd::xmx::dpas<8,8,float>(e10, b0, a1);
                        e11 = esimd::xmx::dpas<8,8,float>(e11, b1, a1);
                    }
                    uint hb = hs + (uint)(tl * 2u) * 256u;
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        bool in0 = (tr * 16 + r) < (int)M, in1 = (tr * 16 + 8 + r) < (int)M;
                        esimd::simd<half,8> h00, h01, h10, h11;
                        if (in0) { esimd::simd<float,8> a = e00.template select<8,1>(r*8), b = e01.template select<8,1>(r*8);
                            // v3d: the VECTORIZED pub (bench_pubvec: epi3 vector ==
                            // scalar IDENTICAL over 1M values, section 99) -- the
                            // scalar pub_esimd chain is the tail's last fat margin.
                            h00 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, a));
                            h01 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, b)); }
                        else { h00 = z8; h01 = z8; }
                        if (in1) { esimd::simd<float,8> a = e10.template select<8,1>(r*8), b = e11.template select<8,1>(r*8);
                            h10 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, a));
                            h11 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, b)); }
                        else { h10 = z8; h11 = z8; }
                        esimd::slm_block_store(hb + (uint)r * 32u, h00, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + (uint)r * 32u + 16u, h01, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u, h10, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u + 16u, h11, esimd::overaligned_tag<16>{});
                    }
                }
                // (v3: NO barrier here -- HS is this thread's private 1KB; the
                // in-order ESIMD pipeline orders the stores before the loads.
                // The v2 barriers were for the SHARED per-subgroup stage, gone now.)
                #pragma unroll
                for (int kc2 = 0; kc2 < 2; ++kc2) {
                    uint kcg = (uint)(c * 2 + kc2);
                    uint ab = hs + (uint)(kc2 * 2u) * 256u;
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256u, esimd::overaligned_tag<16>{});
                    const half* bb = dPp + ((size_t)kcg * 2u + 0u) * 2u * 128u;
                    esimd::simd<half,128> b0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    p00 = esimd::xmx::dpas<8,8,float>(p00, b0, a0);
                    p01 = esimd::xmx::dpas<8,8,float>(p01, b1, a0);
                    p10 = esimd::xmx::dpas<8,8,float>(p10, b0, a1);
                    p11 = esimd::xmx::dpas<8,8,float>(p11, b1, a1);
                    bb += 256;
                    esimd::simd<half,128> c0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> c1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    q00 = esimd::xmx::dpas<8,8,float>(q00, c0, a0);
                    q01 = esimd::xmx::dpas<8,8,float>(q01, c1, a0);
                    q10 = esimd::xmx::dpas<8,8,float>(q10, c0, a1);
                    q11 = esimd::xmx::dpas<8,8,float>(q11, c1, a1);
                }
            }
            size_t outb = (size_t)(tr * 16) * cin;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                if (tr * 16 + r < M) {
                    esimd::simd<float,8> f0 = p00.template select<8,1>(r*8), f1 = p01.template select<8,1>(r*8);
                    esimd::simd<float,8> g0 = q00.template select<8,1>(r*8), g1 = q01.template select<8,1>(r*8);
                    if (with_residual) {
                        esimd::simd<half,16> sk = esimd::block_load<half,16>(dSkip + (size_t)(tr*16+r) * cin + 0, esimd::overaligned_tag<16>{});
                        esimd::simd<float,16> cv = esimd::block_load<float,16>(dCos + 0, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> s0 = esimd::convert<float>(sk.template select<8,1>(0).read()), s1 = esimd::convert<float>(sk.template select<8,1>(8).read());
                        esimd::simd<float,8> c0f = cv.template select<8,1>(0), c1f = cv.template select<8,1>(8);
                        for (int e=0;e<8;++e) f0[e] = s0[e]*c0f[e] + f0.read()[e];
                        for (int e=0;e<8;++e) f1[e] = s1[e]*c1f[e] + f1.read()[e];
                        esimd::simd<half,16> sk2 = esimd::block_load<half,16>(dSkip + (size_t)(tr*16+r) * cin + 16, esimd::overaligned_tag<16>{});
                        esimd::simd<float,16> cv2 = esimd::block_load<float,16>(dCos + 16, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> s2 = esimd::convert<float>(sk2.template select<8,1>(0).read()), s3 = esimd::convert<float>(sk2.template select<8,1>(8).read());
                        esimd::simd<float,8> c2f = cv2.template select<8,1>(0), c3f = cv2.template select<8,1>(8);
                        for (int e=0;e<8;++e) g0[e] = s2[e]*c2f[e] + g0.read()[e];
                        for (int e=0;e<8;++e) g1[e] = s3[e]*c3f[e] + g1.read()[e];
                    }
                    f0.copy_to(outChip + outb + (size_t)r * cin + 0);
                    f1.copy_to(outChip + outb + (size_t)r * cin + 8);
                    g0.copy_to(outChip + outb + (size_t)r * cin + 16);
                    g1.copy_to(outChip + outb + (size_t)r * cin + 24);
                }
                if (tr * 16 + 8 + r < M) {
                    esimd::simd<float,8> f0 = p10.template select<8,1>(r*8), f1 = p11.template select<8,1>(r*8);
                    esimd::simd<float,8> g0 = q10.template select<8,1>(r*8), g1 = q11.template select<8,1>(r*8);
                    if (with_residual) {
                        esimd::simd<half,16> sk = esimd::block_load<half,16>(dSkip + (size_t)(tr*16+8+r) * cin + 0, esimd::overaligned_tag<16>{});
                        esimd::simd<float,16> cv = esimd::block_load<float,16>(dCos + 0, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> s0 = esimd::convert<float>(sk.template select<8,1>(0).read()), s1 = esimd::convert<float>(sk.template select<8,1>(8).read());
                        esimd::simd<float,8> c0f = cv.template select<8,1>(0), c1f = cv.template select<8,1>(8);
                        for (int e=0;e<8;++e) f0[e] = s0[e]*c0f[e] + f0.read()[e];
                        for (int e=0;e<8;++e) f1[e] = s1[e]*c1f[e] + f1.read()[e];
                        esimd::simd<half,16> sk2 = esimd::block_load<half,16>(dSkip + (size_t)(tr*16+8+r) * cin + 16, esimd::overaligned_tag<16>{});
                        esimd::simd<float,16> cv2 = esimd::block_load<float,16>(dCos + 16, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> s2 = esimd::convert<float>(sk2.template select<8,1>(0).read()), s3 = esimd::convert<float>(sk2.template select<8,1>(8).read());
                        esimd::simd<float,8> c2f = cv2.template select<8,1>(0), c3f = cv2.template select<8,1>(8);
                        for (int e=0;e<8;++e) g0[e] = s2[e]*c2f[e] + g0.read()[e];
                        for (int e=0;e<8;++e) g1[e] = s3[e]*c3f[e] + g1.read()[e];
                    }
                    f0.copy_to(outChip + outb + (size_t)(8+r) * cin + 0);
                    f1.copy_to(outChip + outb + (size_t)(8+r) * cin + 8);
                    g0.copy_to(outChip + outb + (size_t)(8+r) * cin + 16);
                    g1.copy_to(outChip + outb + (size_t)(8+r) * cin + 24);
                }
            }
        });
        });
        return std::vector<event>{ev}; });
    std::vector<float> a((size_t)M * cin), b((size_t)M * cin);
    q.memcpy(a.data(), outRef, a.size()*4).wait();
    q.memcpy(b.data(), outChip, b.size()*4).wait();
    size_t diff = 0; for (size_t i = 0; i < a.size(); ++i) if (a[i] != b[i]) diff++;
    printf("ffn-chip-v3 M=%u res=%d | split %7.3f  chip %7.3f (%.2fx) | diff %zu / %zu %s\n",
        M, (int)with_residual, t_split, t_chip, t_split / t_chip, diff, a.size(), diff ? "NOT-EXACT" : "EXACT");
    free(dA,q);free(dE,q);free(dP,q);free(dSkip,q);free(dCos,q);free(dEp,q);free(dPp,q);
    free(dAp,q);free(dHp,q);free(dC2,q);free(outRef,q);free(outChip,q);
}

int main(int argc, char** argv) {
    queue q(device{}, property::queue::enable_profiling{});
    one_ffn_chip(q, 130560u, true);
    one_ffn_chip(q, 130560u, false);
    return 0;
}
