// bench_vitcmp.cpp -- section 100 P11-CLOSE: the clean device-side comparison that
// the in-recorder dbg dumps (4-lane write race) could not give. One small input
// (M=32, heads=2, C=64); TWO paths on the SAME dC:
//   (A) the GREEN scalar two-pass (P7 merged form: row32 deq + ctree::vit_reciprocal
//       + the qr_half_round(cr_mul(...)) chain + qr_e4m3) -- the gate-proven form;
//   (B) the lane kernel (wbmega::qkv_norm_scatter_vit_esimd, table recip) with a
//       SINGLE-WRITER dbg slot (lane l==0 only).
// Dump per (r,head): normQ, recipQ, valQ0 (the pre-e4m3 float) from BOTH, diff.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <random>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "window_block_mega.hpp"

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// path A: the green merged scalar form, with dumps
static void scalar_pass(queue& q, const int32_t* dC, const float* as, const float* bs,
                        const float* qs, float* dump, sycl::half* Qs, sycl::half* Qs2,
                        float* dRef,   // per (r,head): [0..31]=row32, [32..63]=vv pre-e4m3
                        unsigned M, unsigned heads,
                        unsigned C, unsigned NH, unsigned tokens) {
    q.parallel_for(range((size_t)M * heads), [=](item<1> it) {
        size_t i = it.get_id(0);
        unsigned r = (unsigned)(i / heads), head = (unsigned)(i % heads);
        float row32[32];
        for (int c2 = 0; c2 < 32; ++c2) {
            unsigned n = head * 32u + (unsigned)c2;
            row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
        }
        float recip = ctree::vit_reciprocal(row32);
        float sc = qr_half_round(qs[head]);
        float val = qr_half_round(cr_mul(row32[0], recip));
        val = qr_half_round(cr_mul(val, ctree::VIT_ROOT));
        val = qr_half_round(cr_mul(val, sc));
        // publish ALL 32 columns into Qs (the scalar reference output). BISECT:
        // Qs = the recorder's qr_e4m3 spelling (the gate-proven form); Qs2 = the
        // SAME float fed through qr_e4m3_scalar (the spelling the lane kernel uses).
        // Qs-vs-Qs2 diffs isolate the e4m3 SPELLING from the value chain.
        unsigned w = r / tokens, t = r % tokens;
        size_t at = (((size_t)w * heads + head) * tokens + t) * 32u;
        for (int c2 = 0; c2 < 32; ++c2) {
            float vv = qr_half_round(cr_mul(row32[c2], recip));
            vv = qr_half_round(cr_mul(vv, ctree::VIT_ROOT));
            vv = qr_half_round(cr_mul(vv, sc));
            Qs[at + c2] = sycl::half(qr_e4m3(vv));          // the recorder's spelling
            Qs2[at + c2] = sycl::half(qr_e4m3_scalar(vv));  // the lane kernel's spelling
            dRef[(size_t)i * 64u + (size_t)c2] = row32[c2];        // the deq half value
            dRef[(size_t)i * 64u + 32u + (size_t)c2] = vv;         // the pre-e4m3 float
        }
        // the norm: recompute inline for the dump (same tree, up to the recip step)
        float rr[16];
        for (int c = 0; c < 16; ++c) rr[c] = ctree::cr_hfma(row32[c], row32[c], ctree::cr_hmul(row32[c+16], row32[c+16]));
        for (int c = 0; c < 8; ++c) rr[c] = ctree::cr_hadd(rr[c], rr[c+8]);
        for (int c = 0; c < 4; ++c) rr[c] = ctree::cr_hadd(rr[c], rr[c+4]);
        float norm = sycl::max(ctree::cr_hadd(ctree::cr_hadd(rr[0], rr[2]), ctree::cr_hadd(rr[1], rr[3])), qr_half_round(ctree::COSINE_NORM_FLOOR));
        dump[(size_t)i * 4u + 0u] = norm;
        dump[(size_t)i * 4u + 1u] = recip;
        dump[(size_t)i * 4u + 2u] = val;
        dump[(size_t)i * 4u + 3u] = row32[0];
    }).wait();
}

int main() {
    queue q(device{}, property::queue::enable_profiling{});
    // THE FRAME/GATE VIT SHAPE: gate label VIT-192x1024x32 = M(tokens) 192,
    // C=1024, heads=32 (C/32). rows = M*heads = 6144. (The earlier C=32/heads=1
    // bench was EXACT but the frame went 0% -- the shape itself is the suspect.)
    const unsigned M = 192, heads = 32, C = 1024, NH = 3 * C, tokens = 192;
    std::mt19937 rng(5); std::uniform_real_distribution<float> df(-6.f, 6.f);
    std::vector<int32_t> hC((size_t)M * NH);
    std::vector<float> has(M), hbs(NH), hqs(heads);
    for (auto& x : hC) x = (int)(rng() % 200000) - 100000;
    for (auto& x : has) x = 0.0005f;
    for (auto& x : hbs) x = 0.0005f;
    for (auto& x : hqs) x = df(rng) * 0.5f + 0.5f;
    int32_t* dC = malloc_device<int32_t>(hC.size(), q);
    float* as = malloc_device<float>(has.size(), q);
    float* bs = malloc_device<float>(hbs.size(), q);
    float* qs = malloc_device<float>(hqs.size(), q);
    q.memcpy(dC, hC.data(), hC.size()*4); q.memcpy(as, has.data(), has.size()*4);
    q.memcpy(bs, hbs.data(), hbs.size()*4); q.memcpy(qs, hqs.data(), hqs.size()*4); q.wait();
    size_t n = (size_t)M * heads * 16u;
    size_t nd = (size_t)M * heads * 4u * 64u;   // dbg: per (rh,lane) 64 floats (stride 64: t1/t2/t3 at +20/28/36)
    float* dA = malloc_device<float>(n, q); float* dB = malloc_device<float>(nd, q);
    float* dRef = malloc_device<float>((size_t)M * heads * 64u, q);   // scalar: row32 + vv
    q.memset(dA, 0, n*4); q.memset(dB, 0, nd*4); q.memset(dRef, 0, (size_t)M*heads*64u*4); q.wait();
    sycl::half *Qs = malloc_device<sycl::half>((size_t)M*C, q);
    sycl::half *Qs2 = malloc_device<sycl::half>((size_t)M*C, q);
    q.memset(Qs, 0, (size_t)M*C*2); q.memset(Qs2, 0, (size_t)M*C*2); q.wait();
    scalar_pass(q, dC, as, bs, qs, dA, Qs, Qs2, dRef, M, heads, C, NH, tokens);
    // the recip table (same builder as the recorder):
    std::vector<float> tab(65536);
    for (unsigned u = 0; u < 65536u; ++u) {
        sycl::half hh; unsigned short uu = (unsigned short)u;
        memcpy(&hh, &uu, 2);
        float norm = (float)hh;
        if (!(norm > 0.0f) || !(norm < 3.402823466e+38f)) { tab[u] = 0.0f; continue; }
        float s = std::sqrt(norm); volatile float vs = s;   // rsqrt-fusion barrier (the frame-0% bug)
        tab[u] = (float)sycl::half(1.0f / vs);
    }
    float* dtab = malloc_device<float>(65536, q);
    q.memcpy(dtab, tab.data(), 65536*4).wait();
    sycl::half *Q = malloc_device<sycl::half>((size_t)M*C, q), *Kk = malloc_device<sycl::half>((size_t)M*C, q), *V = malloc_device<sycl::half>((size_t)M*C, q);
    q.memset(Q, 0, (size_t)M*C*2); q.memset(Kk, 0, (size_t)M*C*2); q.memset(V, 0, (size_t)M*C*2); q.wait();
    // the lane kernel WITH the dbg slot (single writer: the kernel guards l==0 already
    // -- check the source: the dbg block writes per which; lane l==0 only? the guard is
    // 'if (dbg)' -- ALL FOUR lanes write the same rh slots with the SAME values (the
    // lanes are redundant for norm/recip/hq[0..7]? NO: hq[2g+e] differs per lane!).
    // The dbg hq dump writes lane-dependent hq -- RACE. Fix for THIS bench: pass dbg
    // and let the kernel write; but compare ONLY the lane-invariant fields (norm, recip,
    // and the val at column 0 = lane 0's hq[0]). Add a lane guard via a kernel edit?
    // NO kernel edit: instead dump from OUTSIDE: run the kernel, then recompute the
    // lane-0 pieces host-side? The kernel's Q[at+0] IS lane0's val0 pre-e4m3 published.
    // So compare: dA[i*4+2] (scalar val0) e4m3-published vs Q[at0]; and dA norm/recip
    // vs the dbg slot (norm/recip ARE lane-invariant: every lane computes the SAME
    // norm/recip from the same E values? NO -- each lane holds only ITS E pair; the
    // F step reads all 8 from SLM: norm/recip identical across lanes. The hq dump IS
    // lane-racy: skip it (read only +0,+1,+2,+3 fields? the dump layout: [rh*16 +
    // which*2] = norm, [+1] = recip, [+4..11] = hq (racy). norm/recip: all four lanes
    // write the SAME value (computed from the same SLM E block) -> benign. GOOD.
    wbmega::qkv_norm_scatter_vit_esimd(q, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens,
                                       (const float*)dtab, dB).wait();
    std::vector<float> a(n), b(nd), ref((size_t)M*heads*64u);
    q.memcpy(a.data(), dA, n*4).wait();
    q.memcpy(b.data(), dB, nd*4).wait();
    q.memcpy(ref.data(), dRef, (size_t)M*heads*64u*4).wait();
    unsigned dn=0, dr=0, dhq=0;
    for (size_t i = 0; i < M*heads; ++i) {
        // kernel dbg layout (single writer): (rh*4+l)*64 + {0:normQ,1:recipQ,2:normK,3:recipK,
        // 4..11:hq,12..19:hk, 20..27:t1, 28..35:t2, 36..43:t3 (the stepped Q publish chain)}
        for (unsigned l = 0; l < 4u; ++l) {
            size_t db = (i*4u + l)*64u;
            if (a[i*4] != b[db]) { if (dn<3) printf("norm rh=%zu l=%u A=%.9g B=%.9g\n", i, l, a[i*4], b[db]); dn++; }
            if (a[i*4+1] != b[db+1]) { if (dr<3) printf("recip rh=%zu l=%u A=%.9g B=%.9g\n", i, l, a[i*4+1], b[db+1]); dr++; }
        }
        // hq-vs-row32 per lane: lane l holds columns c2 = g*8+2l+e -> hq[2g+e]
        for (unsigned g = 0; g < 4u; ++g) for (unsigned l = 0; l < 4u; ++l) for (unsigned e = 0; e < 2u; ++e) {
            unsigned c2 = g*8u + 2u*l + e;
            float hlane = b[(i*4u + l)*64u + 4u + 2u*g + e];
            float href  = ref[i*64u + c2];
            if (hlane != href) {
                if (dhq<8) printf("HQDIFF rh=%zu col=%u lane=%u slot=%u lane=%.9g ref=%.9g bits %08X vs %08X\n",
                                  i, c2, l, 2u*g+e, hlane, href,
                                  sycl::bit_cast<unsigned>(hlane), sycl::bit_cast<unsigned>(href));
                dhq++;
            }
        }
    }
    // THREE-WAY published-Q compare:
    //   Q  = the lane kernel (eh_* chain + table recip + qr_e4m3_scalar)
    //   Qs = the recorder's scalar reference (cr_* chain + ctree recip + qr_e4m3)
    //   Qs2= the SAME reference float through the lane kernel's e4m3 SPELLING
    // Q vs Qs2 == 0 while Qs vs Qs2 != 0 pins the DIFFERENCE as the e4m3
    // SPELLING (qr_e4m3 vs qr_e4m3_scalar), not the value chain.
    std::vector<sycl::half> hQ((size_t)M*C), hQs((size_t)M*C), hQs2((size_t)M*C);
    q.memcpy(hQ.data(), Q, (size_t)M*C*2).wait();
    q.memcpy(hQs.data(), Qs, (size_t)M*C*2).wait();
    q.memcpy(hQs2.data(), Qs2, (size_t)M*C*2).wait();
    unsigned qd=0, spell=0, valc=0;
    unsigned colhit[32] = {0};
    for (size_t i = 0; i < (size_t)M*C; ++i) {
        if (hQ[i] != hQs[i]) {
            colhit[i % 32u]++;
            if (qd<6) {
                size_t row = i / 32u, col = i % 32u;
                printf("Qdiff idx=%zu row=%zu col=%zu lane=%zu laneval=%.9g refval=%.9g ref_scalar_spell=%.9g\n",
                       i, row, col, col/2u, (float)hQ[i], (float)hQs[i], (float)hQs2[i]);
            }
            qd++;
            if (hQs[i] != hQs2[i]) spell++;   // same float, different e4m3 spelling
            else valc++;                      // the VALUE chain differs
        }
    }
    printf("Q-published FULL diff: %zu / %zu   (spelling-family %zu, value-family %zu)\n",
           qd, (size_t)M*C, spell, valc);
    printf("Qs-vs-Qs2 (pure spelling diff, whole buffer): ");
    unsigned sd = 0;
    for (size_t i = 0; i < (size_t)M*C; ++i) if (hQs[i] != hQs2[i]) sd++;
    printf("%zu / %zu\n", sd, (size_t)M*C);
    printf("diff-by-col:");
    for (int c = 0; c < 32; ++c) if (colhit[c]) printf(" c%d(lane%u)=%u", c, c/2u, colhit[c]);
    printf("\n");
    printf("P11-CLOSE: norm-diff %u  recip-diff %u  hq-vs-row32-diff %u / %zu\n",
           dn, dr, dhq, (size_t)M*heads*32u);
    if (qd) {
        // replay the lane kernel's publish chain HOST-SIDE from its OWN hq and
        // compare against the scalar vv (ref[i*64+32+c2]) to see whether the
        // e4m3-input float differs or only the e4m3 rounding of equal floats.
        unsigned replaydiff = 0, floateq = 0;
        for (size_t i = 0; i < (size_t)M*C; ++i) {
            if (hQ[i] == hQs[i]) continue;
            size_t orow = i / 32u, c2 = i % 32u;
            // output row = (w*heads+head)*tokens + t  ->  rh = r*heads+head
            unsigned t = (unsigned)(orow % tokens);
            unsigned wh = (unsigned)(orow / tokens);
            unsigned head = wh % heads, w = wh / heads;
            unsigned r = w*tokens + t;
            size_t row = (size_t)r*heads + head;   // rh index (dbg/ref keyed by rh)
            unsigned g = (unsigned)(c2 / 8u); unsigned l = (unsigned)((c2 % 8u) / 2u); unsigned e = (unsigned)(c2 % 2u);
            float hlane = b[(row*4u + l)*64u + 4u + 2u*g + e];
            // replay the STEPPED lane publish chain host-side, step by step
            float recipQ = b[(row*4u + 0u)*64u + 1u];
            float sc_host = (float)(sycl::half)hqs[head];   // qr_half_round(qs[head])
            float rt1 = wbmega::eh_mul(hlane, recipQ);
            float rt2 = wbmega::eh_mul(rt1, ctree::VIT_ROOT);
            float rt3 = wbmega::eh_mul(rt2, sc_host);
            float vref = ref[row*64u + 32u + c2];
            // the kernel's ACTUAL stepped values
            float kt1 = b[(row*4u + l)*64u + 20u + 2u*g + e];
            float kt2 = b[(row*4u + l)*64u + 28u + 2u*g + e];
            float kt3 = b[(row*4u + l)*64u + 36u + 2u*g + e];
            if (rt3 == vref) floateq++;
            if (replaydiff < 8) {
                printf("STEP idx=%zu r=%zu c=%u l=%u | t1 k=%.9g(%08X) r=%.9g(%08X)%s | t2 k=%.9g(%08X) r=%.9g(%08X)%s | t3 k=%.9g(%08X) r=%.9g(%08X)%s | ref=%.9g(%08X)\n",
                       i, row, c2, l,
                       kt1, sycl::bit_cast<unsigned>(kt1), rt1, sycl::bit_cast<unsigned>(rt1), kt1==rt1?"":" <<T1",
                       kt2, sycl::bit_cast<unsigned>(kt2), rt2, sycl::bit_cast<unsigned>(rt2), kt2==rt2?"":" <<T2",
                       kt3, sycl::bit_cast<unsigned>(kt3), rt3, sycl::bit_cast<unsigned>(rt3), kt3==rt3?"":" <<T3",
                       vref, sycl::bit_cast<unsigned>(vref));
                replaydiff++;
            }
        }
        printf("replay: lane-chain float == scalar vv for %u of %zu Qdiffs (the rest: value differs pre-e4m3)\n",
               floateq, (size_t)qd);
    }
    free(dC,q);free(as,q);free(bs,q);free(qs,q);free(dA,q);free(dB,q);free(dRef,q);free(dtab,q);free(Q,q);free(Kk,q);free(V,q);free(Qs,q);free(Qs2,q);
    return 0;
}
