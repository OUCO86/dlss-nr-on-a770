// bench_vitframe.cpp -- P11 frame-0%-hunt: replay the REAL frame's first vit QKV
// call (dumped by the recorder under NR_VITDUMP: vitdump.bin = header{M,C,heads,
// tokens,NH} + dC(Mp*NH int32) + as(M) + bs(NH) + qs(heads) + Q/K/V(M*C half)
// as the LANE KERNEL produced them in the frame). Feed the same inputs to:
//   (A) the lane kernel (table recip) -> compare against the frame's own Q/K/V
//       (must be bit-equal: same kernel, same inputs -- the harness sanity check);
//   (B) the scalar reference chain (P7 merged form) -> diff against the frame's
//       lane output: WHERE the frame-domain difference actually is.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "window_block_mega.hpp"

using namespace sycl;

static unsigned l0_ceil_bm(unsigned M) { return (M + 127u) / 128u * 128u; }

int main(int argc, char** argv) {
    const char* path = (argc > 1) ? argv[1] : "vitdump.bin";
    FILE* f = fopen(path, "rb");
    if (!f) { printf("cannot open %s\n", path); return 1; }
    unsigned hdr[5];
    if (fread(hdr, 4, 5, f) != 5) { printf("bad header\n"); return 1; }
    unsigned M = hdr[0], C = hdr[1], heads = hdr[2], tokens = hdr[3], NH = hdr[4];
    unsigned Mp = l0_ceil_bm(M);
    printf("vitdump: M=%u Mp=%u C=%u heads=%u tokens=%u NH=%u\n", M, Mp, C, heads, tokens, NH);
    std::vector<int32_t> iC((size_t)Mp * NH);
    std::vector<float> ias(M), ibs(NH), iqs(heads);
    std::vector<sycl::half> oQ((size_t)M*C), oK((size_t)M*C), oV((size_t)M*C);
    fread(iC.data(), 4, iC.size(), f); fread(ias.data(), 4, M, f);
    fread(ibs.data(), 4, NH, f); fread(iqs.data(), 4, heads, f);
    fread(oQ.data(), 2, (size_t)M*C, f); fread(oK.data(), 2, (size_t)M*C, f);
    fread(oV.data(), 2, (size_t)M*C, f); fclose(f);

    queue q(device{});
    int32_t* dC = malloc_device<int32_t>(iC.size(), q);
    float* as = malloc_device<float>(M, q), *bs = malloc_device<float>(NH, q), *qs = malloc_device<float>(heads, q);
    q.memcpy(dC, iC.data(), iC.size()*4); q.memcpy(as, ias.data(), M*4);
    q.memcpy(bs, ibs.data(), NH*4); q.memcpy(qs, iqs.data(), heads*4); q.wait();

    // the recip table (same builder as the recorder)
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
    {   // device-side table audit: the inf/NaN slots the frame domain lands on
        float chk[8];
        unsigned slots[8] = {0x7C00u, 0xFC00u, 0x7BFFu, 0x7E00u, 0xFFFFu, 0x0000u, 0x8000u, 0x0001u};
        for (int i = 0; i < 8; ++i) q.memcpy(chk, dtab + slots[i], 4).wait();
        printf("dev tab[0x7C00(+inf)]=%.9g [0xFC00]=%.9g [0x7BFF(max half)]=%.9g [0x7E00(NaN)]=%.9g [0xFFFF]=%.9g [0]=%.9g [0x8000]=%.9g [1]=%.9g\n",
               chk[0],chk[1],chk[2],chk[3],chk[4],chk[5],chk[6],chk[7]);
        printf("host tab[0x7C00]=%.9g [0xFC00]=%.9g [0x7BFF]=%.9g [0x7E00]=%.9g [0xFFFF]=%.9g\n",
               tab[0x7C00], tab[0xFC00], tab[0x7BFF], tab[0x7E00], tab[0xFFFF]);
    }

    // (A) re-run the lane kernel on the frame inputs -> must equal the frame outputs
    sycl::half *Q = malloc_device<sycl::half>((size_t)M*C, q), *Kk = malloc_device<sycl::half>((size_t)M*C, q), *V = malloc_device<sycl::half>((size_t)M*C, q);
    q.memset(Q, 0, (size_t)M*C*2); q.memset(Kk, 0, (size_t)M*C*2); q.memset(V, 0, (size_t)M*C*2); q.wait();
    size_t rows = (size_t)M * heads;
    float* ddbg = malloc_device<float>(rows * 4u * 64u, q);
    q.memset(ddbg, 0, rows * 4u * 64u * 4); q.wait();
    wbmega::qkv_norm_scatter_vit_esimd(q, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens,
                                       (const float*)dtab, ddbg).wait();
    {   // dbg slot decode for rh=0 (row0 head0): lane l holds columns g*8+2l+e
        std::vector<float> dg(rows * 4u * 64u);
        q.memcpy(dg.data(), ddbg, dg.size()*4).wait();
        // host reference deq for rh=0
        printf("dbg rh=0: lane0 normQ=%.9g recipQ=%.9g hq[0..3]=%.6g %.6g %.6g %.6g | lane1 normQ=%.9g recipQ=%.9g hq0=%.6g\n",
               dg[0*64+0], dg[0*64+1], dg[0*64+4], dg[0*64+5], dg[0*64+6], dg[0*64+7],
               dg[1*64+0], dg[1*64+1], dg[1*64+4]);
        printf("dbg rh=0 lane0 stepped: t1[0..1]=%.9g %.9g t2[0..1]=%.9g %.9g t3[0..1]=%.9g %.9g (bits t3_0=%08X)\n",
               dg[0*64+20], dg[0*64+21], dg[0*64+28], dg[0*64+29], dg[0*64+36], dg[0*64+37],
               sycl::bit_cast<unsigned>(dg[0*64+36]));
        printf("host deq rh=0: col0=%.6g col1=%.6g (as=%.6g bs0=%.6g dC0=%d)\n",
               qr_half_round(cr_mul(cr_mul((float)iC[0], ias[0]), ibs[0])),
               qr_half_round(cr_mul(cr_mul((float)iC[1], ias[0]), ibs[1])),
               ias[0], ibs[0], iC[0]);
        float row32[32];
        for (int c2 = 0; c2 < 32; ++c2) row32[c2] = qr_half_round(cr_mul(cr_mul((float)iC[c2], ias[0]), ibs[c2]));
        float refnorm = ctree::vit_reciprocal(row32);
        printf("host recip rh=0 = %.9g\n", refnorm);
        // how many rows have the kernel's recip == host's recip?
        unsigned rd = 0;
        for (size_t rh = 0; rh < rows; ++rh) {
            for (unsigned hd = 0; hd < 32u; ++hd) {
                unsigned r = (unsigned)(rh / heads), head = (unsigned)(rh % heads);
                float rr[32];
                for (int c2 = 0; c2 < 32; ++c2) {
                    unsigned n = head * 32u + (unsigned)c2;
                    rr[c2] = qr_half_round(cr_mul(cr_mul((float)iC[(size_t)r * NH + n], ias[r]), ibs[n]));
                }
                float rc = ctree::vit_reciprocal(rr);
                if (rc != dg[(rh*4u+0u)*64u + 1u]) { if (rd < 4) printf("RECIPISDIFF rh=%zu host=%.9g kern=%.9g\n", rh, rc, dg[(rh*4u)*64u+1u]); rd++; }
            }
        }
        printf("recip host-vs-kernel diff: %zu / %zu rows\n", rd, rows);
    }
    std::vector<sycl::half> rQ((size_t)M*C), rK((size_t)M*C), rV((size_t)M*C);
    q.memcpy(rQ.data(), Q, (size_t)M*C*2).wait(); q.memcpy(rK.data(), Kk, (size_t)M*C*2).wait(); q.memcpy(rV.data(), V, (size_t)M*C*2).wait();
    unsigned sa=0, sb=0, sc2=0;
    for (size_t i = 0; i < (size_t)M*C; ++i) { if (rQ[i]!=oQ[i]) sa++; if (rK[i]!=oK[i]) sb++; if (rV[i]!=oV[i]) sc2++; }
    printf("(A) lane rerun vs frame dump: Q %zu K %zu V %zu / %zu\n", sa, sb, sc2, (size_t)M*C);

    // (B) the scalar reference chain on the SAME dC -> diff vs the lane output
    sycl::half *Qs = malloc_device<sycl::half>((size_t)M*C, q), *Ks = malloc_device<sycl::half>((size_t)M*C, q), *Vs = malloc_device<sycl::half>((size_t)M*C, q);
    q.memset(Qs, 0, (size_t)M*C*2); q.memset(Ks, 0, (size_t)M*C*2); q.memset(Vs, 0, (size_t)M*C*2); q.wait();
    q.parallel_for(range((size_t)M * heads), [=](item<1> it) {
        size_t i = it.get_id(0);
        unsigned r = (unsigned)(i / heads), head = (unsigned)(i % heads);
        float row32[32];
        for (int c2 = 0; c2 < 32; ++c2) {
            unsigned n = head * 32u + (unsigned)c2;
            row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
        }
        float recip = ctree::vit_reciprocal(row32);
        float scl = qr_half_round(qs[head]);
        unsigned w = r / tokens, t = r % tokens;
        size_t at = (((size_t)w * heads + head) * tokens + t) * 32u;
        for (int c2 = 0; c2 < 32; ++c2) {
            float vv = qr_half_round(cr_mul(row32[c2], recip));
            vv = qr_half_round(cr_mul(vv, ctree::VIT_ROOT));
            vv = qr_half_round(cr_mul(vv, scl));
            Qs[at + c2] = sycl::half(qr_e4m3(vv));
        }
        for (int c2 = 0; c2 < 32; ++c2) {
            unsigned n = C + head * 32u + (unsigned)c2;
            row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
        }
        float krec = ctree::vit_reciprocal(row32);
        for (int c2 = 0; c2 < 32; ++c2) {
            float vv = qr_half_round(cr_mul(row32[c2], krec));
            Ks[at + c2] = sycl::half(qr_e4m3(vv));
        }
        for (int c2 = 0; c2 < 32; ++c2) {
            unsigned n = 2u * C + head * 32u + (unsigned)c2;
            float vv = cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]);
            Vs[at + c2] = sycl::half(qr_e4m3(vv));
        }
    }).wait();
    std::vector<sycl::half> hQs((size_t)M*C), hKs((size_t)M*C), hVs((size_t)M*C);
    q.memcpy(hQs.data(), Qs, (size_t)M*C*2).wait(); q.memcpy(hKs.data(), Ks, (size_t)M*C*2).wait(); q.memcpy(hVs.data(), Vs, (size_t)M*C*2).wait();
    unsigned qd=0, kd=0, vd=0;
    for (size_t i = 0; i < (size_t)M*C; ++i) {
        if (oQ[i]!=hQs[i]) { if (qd<6) { size_t row=i/32u,col=i%32u;
            printf("FRAME-QDIFF idx=%zu row=%zu col=%zu lane=%.9g scalar=%.9g\n", i, row, col, (float)oQ[i], (float)hQs[i]); } qd++; }
        if (oK[i]!=hKs[i]) kd++;
        if (oV[i]!=hVs[i]) vd++;
    }
    printf("(B) frame-lane vs scalar-ref: Q %zu K %zu V %zu / %zu\n", qd, kd, vd, (size_t)M*C);
    // the deq domain: how big are the row32 values actually?
    double maxabs = 0.0; unsigned big = 0;
    for (size_t r = 0; r < M; ++r) for (unsigned n = 0; n < C; ++n) {
        float h = qr_half_round(cr_mul(cr_mul((float)iC[r*NH+n], ias[r]), ibs[n]));
        double a = std::abs(h); if (a > maxabs) maxabs = a; if (a > 3.0) big++;
    }
    printf("frame deq domain: max |h| = %.6g, count |h|>3: %u of %zu\n", maxabs, big, (size_t)M*C);
    free(dC,q);free(as,q);free(bs,q);free(qs,q);free(dtab,q);free(Q,q);free(Kk,q);free(V,q);free(Qs,q);free(Ks,q);free(Vs,q);
    return 0;
}
