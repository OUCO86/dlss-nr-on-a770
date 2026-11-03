// batch_merge_probe.cpp -- KNIFE 1 (A1+A2+A3, "batch into the grid dim") phase-A instrument.
// Bench-only: touches no shipped source, no dll, no golden, no plan.
//
// Questions it answers with MEASURED numbers (not the apportioned violation_ms of section 50):
//   (1) DIFF : does merging b independent same-shape launches into ONE launch with batch=b change
//              any output byte?  It must not -- per-element reduction order is untouched, batch is
//              only a grid dim (and a pointer stride).
//   (2) PAIR : price ratio  split (b launches, batch=1)  vs  merged (1 launch, batch=b).
//              Gate: best-b ratio >= 1.5, measured IN THE SAME PROCESS (P13: absolute ms are not
//              comparable across processes/sessions, only within-run pairs).
//
// Four families = the ALIVE knife-1 sites of tools/shapes_alive.csv (plan truth from the census):
//   F0 A1  xmx_rec_gemm_int8_qkv              2560 x 768 x 256  b1 -> b8   (16 sites)
//   F1 A2  xmx_rec_gemm_window_int8_residual  2560 x 256 x 256  b1 -> b8   (16 sites)
//   F2 A3  xmx_rec_gemm_int8_residual         2040 x 256 x 256  b1 -> b8   (16 sites)
//   F3 A3  xmx_rec_gemm_int8_residual         8160 x 128 x 128  b1 -> b4   (12 sites)
// Legs: raw (s8v8::gemm_b / f16v1::gemm_b) and pub (s8v8::gemm_b_pub / f16v1::gemm_b_pub_f16).
// pub is measured at epi=1 (the form the chains really carry: e4m3 snap) AND epi=4 (the half-round
// form the section-50 roof table used) -- that closes section 50's "epi=4 vs epi=1" open risk.
// Both dtypes measured (rule 35a: never interpolate int8 off f16).
//
// NOTE for phase B (honest scope, not a probe flaw): the three FRAME kernels of these families
// (gemm_b_res / gemm_b_res_window / the qkv tail) currently have NO batch parameter
// (gemm_s8_v8_kernel.hpp:862/:1128 -- wg = (Mp/BM)*(N/BN), no *batch). The dpas main loop is
// byte-identical to gemm_b/gemm_b_pub (same file, :824 comment), so the merge price measured here
// transfers, but 刀 1 must ADD the batch dim to those three kernels.
//
// Protocol: 5 groups x min-of-15, 60 ms between groups, nosink, GPU-event timing summed per form.
// env: BMP_FAM=0..3 (required) | BMP_G=5 | BMP_R=15 | BMP_B="1,4,8,16" | BMP_EPI="1,4"
//      BMP_RAW=1 BMP_PUB=1 BMP_DIFF=1 (diff at every b for epi0 raw + epi1 pub; epi4 priced only)
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <functional>
#include <algorithm>
#include <thread>
#include <chrono>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;

struct Stat { double msm=0, msM=0, msX=0, med=0; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end()); st.med = all[all.size()/2]; st.gms = gmin; return st;
}
static size_t G_GRP = 5, G_REP = 15;
// one "rep" = one whole form (b launches for split, 1 launch for merged); the rep's value is the
// SUM of its GPU-event durations, so split vs merged are compared as total GPU time of the form.
static Stat timeit(std::function<std::vector<event>()> f, int gap_ms = 60) {
    for (auto& e : f()) e.wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < G_GRP; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < G_REP; ++it) {
            std::vector<event> ev = f(); double tot = 0;
            for (auto& e : ev) {
                e.wait();
                tot += double(e.get_profiling_info<info::event_profiling::command_end>() -
                              e.get_profiling_info<info::event_profiling::command_start>()) / 1e6;
            }
            lo = std::min(lo, tot); all.push_back(tot);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[220]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 200; ++i) o += snprintf(buf+o, sizeof(buf)-o, "%.4f ", st.gms[i]);
    return buf;
}
struct Fam { const char* name; const char* plan_family; int M, N, K, btarget; };
static const Fam FAMs[4] = {
  {"F0_A1_qkv_2560_768_256",  "xmx_rec_gemm_int8_qkv",             2560, 768, 256, 8},
  {"F1_A2_wres_2560_256_256", "xmx_rec_gemm_window_int8_residual", 2560, 256, 256, 8},
  {"F2_A3_res_2040_256_256",  "xmx_rec_gemm_int8_residual",        2040, 256, 256, 8},
  {"F3_A3_res_8160_128_128",  "xmx_rec_gemm_int8_residual",        8160, 128, 128, 4},
};
static std::vector<int> blist, epis;
static bool do_raw, do_pub, do_diff, do_i8, do_f16;

static void report(const Fam& F, const char* dt, const char* leg, int epi,
                   int M, int Mp, int N, int K, int b, const Stat& s1, const Stat& s2, double gf) {
    printf("CSVROW;%s;%s;%s;epi%d;split;%d;%d;%d;%d;%d;%.4f;%.4f;%.4f;%.4f;%.6f;%.4f;groups=[%s]\n",
           F.name, dt, leg, epi, M, Mp, N, K, b, s1.msm, s1.msM, s1.msX, s1.med, gf, gf/s1.msM, gmfmt(s1));
    printf("CSVROW;%s;%s;%s;epi%d;merged;%d;%d;%d;%d;%d;%.4f;%.4f;%.4f;%.4f;%.6f;%.4f;groups=[%s]\n",
           F.name, dt, leg, epi, M, Mp, N, K, b, s2.msm, s2.msM, s2.msX, s2.med, gf, gf/s2.msM, gmfmt(s2));
    printf("PAIR;%s;%s;%s;epi%d;b=%d;split_total=%.4f;merged_total=%.4f;ratio=%.3f\n",
           F.name, dt, leg, epi, b, s1.msM, s2.msM, s1.msM / s2.msM);
    fflush(stdout);
}
static void diffline(const Fam& F, const char* dt, const char* leg, int epi, int b,
                     size_t diffbytes, size_t cmp, size_t firstoff) {
    printf("DIFF;%s;%s;%s;epi%d;b=%d;diff=%zu;cmp=%zu;first_off=%zu\n",
           F.name, dt, leg, epi, b, diffbytes, cmp, firstoff);
    fflush(stdout);
}

// ---------------- int8 ----------------
static void run_int8(queue& q, const Fam& F, int b) {
    const int Mp = ((F.M + 127) / 128) * 128;                    // BM = 128 (l0_ceil_bm)
    const size_t apb = (size_t)Mp * F.K, bpb = (size_t)F.N * F.K, cb = (size_t)Mp * F.N;
    const double gf = 2.0 * (double)F.M * F.N * F.K * (double)b / 1e9;
    std::vector<int8_t> hA((size_t)b * apb), hAp((size_t)b * apb), hB((size_t)b * bpb), hBp((size_t)b * bpb);
    for (size_t g = 0; g < (size_t)b; ++g) {
        const size_t sA = 17 + 31 * (g % 7), sB = 23 + 41 * (g % 5);
        for (size_t i = 0; i < apb; ++i) hA[g*apb + i] = (int8_t)(int)(((i + g*7919) * sA) % 251) - 125;
        for (size_t i = 0; i < bpb; ++i) hB[g*bpb + i] = (int8_t)(int)(((i + g*104729) * sB) % 251) - 125;
        s8v8::pack_a(hA.data() + g*apb, hAp.data() + g*apb, Mp, F.K);
        s8v8::pack_b(hB.data() + g*bpb, hBp.data() + g*bpb, F.N, F.K);
    }
    std::vector<float> has((size_t)b * Mp), hbs((size_t)b * F.N);
    for (size_t g = 0; g < (size_t)b; ++g) {
        for (int i = 0; i < Mp; ++i) has[g*Mp + i] = 1.0f / (127.0f + (float)(i % 13) + (float)g);
        for (int j = 0; j < F.N; ++j) hbs[g*F.N + j] = 1.0f / (129.0f + (float)(j % 11) + (float)g);
    }
    int8_t* dAp = malloc_device<int8_t>(hAp.size(), q);
    int8_t* dBp = malloc_device<int8_t>(hBp.size(), q);
    float*  das = malloc_device<float>(has.size(), q);
    float*  dbs = malloc_device<float>(hbs.size(), q);
    q.memcpy(dAp, hAp.data(), hAp.size()); q.memcpy(dBp, hBp.data(), hBp.size());
    q.memcpy(das, has.data(), has.size()*4); q.memcpy(dbs, hbs.data(), hbs.size()*4); q.wait();
    // per-group output stride in ELEMENTS: int32 for raw, half for pub(narrow)
    auto do_leg = [&](bool publeg, int epi) {
        const size_t esz   = publeg ? 2 : 4;
        const size_t cbytes = cb * esz * (size_t)b;
        uint8_t* dCm = malloc_device<uint8_t>(cbytes, q);
        uint8_t* dCs = malloc_device<uint8_t>(cbytes, q);
        auto merged = [&]() -> std::vector<event> {
            std::vector<event> ev;
            if (!publeg) ev.push_back(s8v8::gemm_b(q, dAp, dBp, (int32_t*)dCm, Mp, F.N, F.K, b));
            else ev.push_back(s8v8::gemm_b_pub(q, dAp, dBp, (void*)dCm, das, dbs, F.M, Mp, F.N, F.K, b,
                                               cb, (unsigned)F.N, (unsigned)Mp, (unsigned)F.N, true, (unsigned)epi));
            return ev;
        };
        auto split = [&]() -> std::vector<event> {
            std::vector<event> ev;
            for (int g = 0; g < b; ++g) {
                if (!publeg) ev.push_back(s8v8::gemm_b(q, dAp + g*apb, dBp + g*bpb,
                                                       (int32_t*)(dCs + (size_t)g*cb*esz), Mp, F.N, F.K, 1));
                else ev.push_back(s8v8::gemm_b_pub(q, dAp + g*apb, dBp + g*bpb,
                                                   (void*)(dCs + (size_t)g*cb*esz),
                                                   das + (size_t)g*Mp, dbs + (size_t)g*F.N,
                                                   F.M, Mp, F.N, F.K, 1,
                                                   cb, (unsigned)F.N, (unsigned)Mp, (unsigned)F.N,
                                                   true, (unsigned)epi));
            }
            return ev;
        };
        if (do_diff && (epi != 4)) {
            q.memset(dCs, 0xAA, cbytes); q.memset(dCm, 0xAA, cbytes); q.wait();
            for (auto& e : split()) e.wait();
            for (auto& e : merged()) e.wait();
            // chunked host compare: a full-size pair of host vectors (up to 252 MB at b=16 raw)
            // is what the host died on -- 0xC0000409 at the last leg of the process (12:4x).
            const size_t CH = 8u << 20;
            std::vector<uint8_t> a(CH), c(CH);
            size_t dnum = 0, firstoff = 0;
            for (size_t off = 0; off < cbytes; off += CH) {
                size_t n = std::min(CH, cbytes - off);
                q.memcpy(a.data(), dCs + off, n).wait();
                q.memcpy(c.data(), dCm + off, n).wait();
                for (size_t i = 0; i < n; ++i) if (a[i] != c[i]) { if (!firstoff) firstoff = off + i + 1; ++dnum; }
            }
            diffline(F, "int8", publeg ? "pub" : "raw", publeg ? epi : 0, b, dnum, cbytes, firstoff);
        }
        Stat s1, s2;
        if ((b / 4) % 2 == 0) { s1 = timeit(split);  s2 = timeit(merged); }
        else                  { s2 = timeit(merged); s1 = timeit(split); }
        report(F, "int8", publeg ? "pub" : "raw", publeg ? epi : 0, F.M, Mp, F.N, F.K, b, s1, s2, gf);
        sycl::free(dCm, q); sycl::free(dCs, q);
    };
    if (do_raw) do_leg(false, 0);
    if (do_pub) for (int epi : epis) do_leg(true, epi);
    sycl::free(dAp, q); sycl::free(dBp, q); sycl::free(das, q); sycl::free(dbs, q);
}

// ---------------- f16 ----------------
static void run_f16(queue& q, const Fam& F, int b) {
    const int Mp = ((F.M + 15) / 16) * 16;                       // TS = 16
    const size_t apb = (size_t)Mp * F.K, bpb = (size_t)F.K * F.N, cb = (size_t)Mp * F.N;
    const double gf = 2.0 * (double)F.M * F.N * F.K * (double)b / 1e9;
    half* dA  = malloc_device<half>((size_t)b * apb, q);
    half* dAp = malloc_device<half>((size_t)b * apb, q);
    half* dB  = malloc_device<half>((size_t)b * bpb, q);
    half* dBp = malloc_device<half>((size_t)b * bpb, q);
    q.memset(dA, 0x11, (size_t)b * apb * 2); q.memset(dB, 0x22, (size_t)b * bpb * 2); q.wait();
    packdev::pack_a16_b(q, dA, dAp, Mp, Mp, F.K, b);
    packdev::pack_b16_b(q, dB, dBp, F.K, F.N, b);
    q.wait();
    auto do_leg = [&](bool publeg, int epi) {
        const size_t esz = publeg ? 2 : 4;
        const size_t cbytes = cb * esz * (size_t)b;
        uint8_t* dCm = malloc_device<uint8_t>(cbytes, q);
        uint8_t* dCs = malloc_device<uint8_t>(cbytes, q);
        auto merged = [&]() -> std::vector<event> {
            std::vector<event> ev;
            if (!publeg) ev.push_back(f16v1::gemm_b(q, dAp, dBp, (float*)dCm, Mp, F.N, F.K, b));
            else ev.push_back(f16v1::gemm_b_pub_f16(q, dAp, dBp, (void*)dCm, F.M, Mp, F.N, F.K, b,
                                                    (unsigned)epi, true, 0, cb, (unsigned)F.N, 0u));
            return ev;
        };
        auto split = [&]() -> std::vector<event> {
            std::vector<event> ev;
            for (int g = 0; g < b; ++g) {
                if (!publeg) ev.push_back(f16v1::gemm_b(q, dAp + g*apb, dBp + g*bpb,
                                                        (float*)(dCs + (size_t)g*cb*esz), Mp, F.N, F.K, 1));
                else ev.push_back(f16v1::gemm_b_pub_f16(q, dAp + g*apb, dBp + g*bpb,
                                                        (void*)(dCs + (size_t)g*cb*esz),
                                                        F.M, Mp, F.N, F.K, 1, (unsigned)epi, true,
                                                        0, cb, (unsigned)F.N, 0u));
            }
            return ev;
        };
        if (do_diff && (epi != 4)) {
            q.memset(dCs, 0xAA, cbytes); q.memset(dCm, 0xAA, cbytes); q.wait();
            for (auto& e : split()) e.wait();
            for (auto& e : merged()) e.wait();
            // chunked host compare: a full-size pair of host vectors (up to 252 MB at b=16 raw)
            // is what the host died on -- 0xC0000409 at the last leg of the process (12:4x).
            const size_t CH = 8u << 20;
            std::vector<uint8_t> a(CH), c(CH);
            size_t dnum = 0, firstoff = 0;
            for (size_t off = 0; off < cbytes; off += CH) {
                size_t n = std::min(CH, cbytes - off);
                q.memcpy(a.data(), dCs + off, n).wait();
                q.memcpy(c.data(), dCm + off, n).wait();
                for (size_t i = 0; i < n; ++i) if (a[i] != c[i]) { if (!firstoff) firstoff = off + i + 1; ++dnum; }
            }
            diffline(F, "f16", publeg ? "pub" : "raw", publeg ? epi : 0, b, dnum, cbytes, firstoff);
        }
        Stat s1, s2;
        if ((b / 4) % 2 == 0) { s1 = timeit(split);  s2 = timeit(merged); }
        else                  { s2 = timeit(merged); s1 = timeit(split); }
        report(F, "f16", publeg ? "pub" : "raw", publeg ? epi : 0, F.M, Mp, F.N, F.K, b, s1, s2, gf);
        sycl::free(dCm, q); sycl::free(dCs, q);
    };
    if (do_raw) do_leg(false, 0);
    if (do_pub) for (int epi : epis) do_leg(true, epi);
    sycl::free(dA, q); sycl::free(dAp, q); sycl::free(dB, q); sycl::free(dBp, q);
}

// ---------------- RES-TWIN bisect (BMP_RES_TWIN=1) ----------------
// The engine-side knife-1 merge fails the 1301 bit-exact gate even for a 2-member group
// (2026-11-03 13:0x: MAX2/MAX4/MAX16 all MISMATCH, four processes four different md5s), while
// every ordering guard says the group is safe. This bisects the two remaining suspects:
//   (a) the generated twin kernel s8v8::gemm_b_res_batch + its device S8ResDesc table, vs
//   (b) the engine's deferred-write plumbing.
// It runs the SHIPPED gemm_b_res b times and the twin ONCE with a desc table, on identical
// synthetic inputs (packed A/B, per-group as/bs, half skip plane, cosine plane), and byte-compares.
static void run_res_twin(queue& q, const Fam& F, int b) {
    const int Mp = ((F.M + 127) / 128) * 128;
    const size_t apb = (size_t)Mp * F.K, bpb = (size_t)F.N * F.K, cb = (size_t)Mp * F.N;
    std::vector<int8_t> hA((size_t)b * apb), hAp((size_t)b * apb), hB((size_t)b * bpb), hBp((size_t)b * bpb);
    for (size_t g = 0; g < (size_t)b; ++g) {
        const size_t sA = 13 + 37 * (g % 11), sB = 7 + 43 * (g % 3);
        for (size_t i = 0; i < apb; ++i) hA[g*apb + i] = (int8_t)(int)(((i + g*151) * sA) % 251) - 125;
        for (size_t i = 0; i < bpb; ++i) hB[g*bpb + i] = (int8_t)(int)(((i + g*991) * sB) % 251) - 125;
        s8v8::pack_a(hA.data() + g*apb, hAp.data() + g*apb, Mp, F.K);
        s8v8::pack_b(hB.data() + g*bpb, hBp.data() + g*bpb, F.N, F.K);
    }
    std::vector<float> has((size_t)b * Mp), hbs((size_t)b * F.N), hcos((size_t)b * F.N);
    std::vector<sycl::half> hsk((size_t)b * Mp * F.N);
    for (size_t g = 0; g < (size_t)b; ++g) {
        for (int i = 0; i < Mp; ++i) has[g*Mp + i] = 1.0f / (127.0f + (float)(i % 13) + (float)g);
        for (int j = 0; j < F.N; ++j) { hbs[g*F.N + j] = 1.0f / (129.0f + (float)(j % 11) + (float)g);
                                        hcos[g*F.N + j] = 0.5f + (float)(j % 7) * 0.125f; }
        for (size_t i = 0; i < (size_t)Mp * F.N; ++i)
            hsk[g*(size_t)Mp*F.N + i] = sycl::half((float)((int)(i % 513) - 256) / 256.0f);
    }
    int8_t* dAp = malloc_device<int8_t>(hAp.size(), q);
    int8_t* dBp = malloc_device<int8_t>(hBp.size(), q);
    float*  das = malloc_device<float>(has.size(), q);
    float*  dbs = malloc_device<float>(hbs.size(), q);
    float*  dcs = malloc_device<float>(hcos.size(), q);
    sycl::half* dsk = malloc_device<sycl::half>(hsk.size(), q);
    q.memcpy(dAp, hAp.data(), hAp.size()); q.memcpy(dBp, hBp.data(), hBp.size());
    q.memcpy(das, has.data(), has.size()*4); q.memcpy(dbs, hbs.data(), hbs.size()*4);
    q.memcpy(dcs, hcos.data(), hcos.size()*4); q.memcpy(dsk, hsk.data(), hsk.size()*2); q.wait();
    const size_t cbytes = cb * 2 * (size_t)b;                 // narrow (half) output
    uint8_t* dCs = malloc_device<uint8_t>(cbytes, q);
    uint8_t* dCm = malloc_device<uint8_t>(cbytes, q);
    s8v8::S8ResDesc* dt = malloc_device<s8v8::S8ResDesc>((size_t)b, q);
    std::vector<s8v8::S8ResDesc> hd(b);
    for (int g = 0; g < b; ++g)
        hd[g] = s8v8::S8ResDesc{ dAp + g*apb, dBp + g*bpb, (void*)(dCm + (size_t)g*cb*2),
                                 das + (size_t)g*Mp, dbs + (size_t)g*F.N,
                                 (const void*)(dsk + (size_t)g*Mp*F.N), dcs + (size_t)g*F.N };
    q.memcpy(dt, hd.data(), sizeof(s8v8::S8ResDesc) * (size_t)b); q.wait();
    // shipped form: b separate launches, each writing its own C
    for (int g = 0; g < b; ++g)
        s8v8::gemm_b_res(q, dAp + g*apb, dBp + g*bpb, (void*)(dCs + (size_t)g*cb*2),
                         das + (size_t)g*Mp, dbs + (size_t)g*F.N,
                         (const void*)(dsk + (size_t)g*Mp*F.N), dcs + (size_t)g*F.N,
                         F.M, Mp, F.N, F.K, true, true, 1u);
    // twin: ONE launch over a desc table (its own output buffer, same layout)
    s8v8::gemm_b_res_batch(q, dt, F.M, Mp, F.N, F.K, b, true, true, 1u);
    q.wait();
    const size_t CH = 8u << 20;
    std::vector<uint8_t> a(CH), c(CH);
    size_t dnum = 0, firstoff = 0;
    for (size_t off = 0; off < cbytes; off += CH) {
        size_t n = std::min(CH, cbytes - off);
        q.memcpy(a.data(), dCs + off, n).wait();
        q.memcpy(c.data(), dCm + off, n).wait();
        for (size_t i = 0; i < n; ++i) if (a[i] != c[i]) { if (!firstoff) firstoff = off + i + 1; ++dnum; }
    }
    printf("RESTWIN;%s;b=%d;diff=%zu;cmp=%zu;first_off=%zu\n", F.name, b, dnum, cbytes, firstoff);
    fflush(stdout);
    sycl::free(dAp,q); sycl::free(dBp,q); sycl::free(das,q); sycl::free(dbs,q);
    sycl::free(dcs,q); sycl::free(dsk,q); sycl::free(dCs,q); sycl::free(dCm,q); sycl::free(dt,q);
}

int main(int argc, char** argv) {
    const int fam = getenv("BMP_FAM") ? atoi(getenv("BMP_FAM")) : -1;
    if (fam < 0 || fam > 3) { printf("BMP_FAM must be 0..3\n"); return 1; }
    G_GRP = getenv("BMP_G") ? (size_t)atoi(getenv("BMP_G")) : 5;
    G_REP = getenv("BMP_R") ? (size_t)atoi(getenv("BMP_R")) : 15;
    do_raw  = !getenv("BMP_RAW")  || atoi(getenv("BMP_RAW"))  != 0;
    do_pub  = !getenv("BMP_PUB")  || atoi(getenv("BMP_PUB"))  != 0;
    do_diff = !getenv("BMP_DIFF") || atoi(getenv("BMP_DIFF")) != 0;
    const char* dts = getenv("BMP_DT"); if (!dts) dts = "both";
    do_i8  = (strcmp(dts, "f16") != 0);
    do_f16 = (strcmp(dts, "int8") != 0);
    const char* bp = getenv("BMP_B"); if (!bp) bp = "1,4,8,16";
    for (const char* p = bp; *p; ) { int v = atoi(p); if (v > 0) blist.push_back(v); while (*p && *p != ',') ++p; if (*p == ',') ++p; }
    const char* ep = getenv("BMP_EPI"); if (!ep) ep = "1,4";
    for (const char* p = ep; *p; ) { epis.push_back(atoi(p)); while (*p && *p != ',') ++p; if (*p == ',') ++p; }
    queue q(gpu_selector_v, property::queue::enable_profiling{});
    printf("device: %s\n", q.get_device().get_info<info::device::name>().c_str());
    const Fam F = FAMs[fam];
    printf("=== batch_merge_probe fam=%s plan_family=%s M=%d N=%d K=%d plan_btarget=%d groups=%zu reps=%zu gap=60ms nosink paired-in-process ===\n",
           F.name, F.plan_family, F.M, F.N, F.K, F.btarget, G_GRP, G_REP);
    const bool res_twin = getenv("BMP_RES_TWIN") && atoi(getenv("BMP_RES_TWIN")) != 0;
    for (int b : blist) {
        if (res_twin) { run_res_twin(q, F, b); continue; }
        if (do_i8)  run_int8(q, F, b);
        if (do_f16) run_f16(q, F, b);
    }
    printf("=== done fam=%s ===\n", F.name);
    return 0;
}
