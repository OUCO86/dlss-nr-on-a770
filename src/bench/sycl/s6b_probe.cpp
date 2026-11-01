// s6b_probe.cpp -- S6-1b STEP 2: the whole-block GEOMETRY stub for the 11-op chain (§16 实读).
// WHAT IT IS: one kernel that ALLOCATES every SLM slice of the step-1 plan (pk / hidden / qkv /
//   scores / out / 1267-f16-skip / 1270-f16, with the alias blocks) and runs the ELEVEN phase
//   boundaries, ONE sycl::group_barrier each. Inside a phase it only does an ELEMENTWISE
//   placeholder read/write over that phase's slices -- *** NO dpas, NO real GEMM/attention math,
//   NO quant numerics ***. The point is to price GEOMETRY: SLM footprint, barrier count, WG
//   shape, and the global round trips the plan forces (window k/v when T < TOK).
// WHAT IT ANSWERS: does the 11-slice layout live at all (live / HANG / compile-time reject),
//   what does its spillcheck ledger say (slm_size / grf / private / spill / scratch -- the
//   anchors are 1a's ffn2/ffn3: grf 128 top-out, private/spill/scratch 0, slm 31744B),
//   and what does pure geometry cost in ms (vs 1a's 0.4647 wall / 0.3878 GPU for the 6-op chain).
// BARRIER DISCIPLINE: exactly 11 group_barriers (one per phase boundary). Inside P9 the
//   scores -> att hand-off is kept THREAD-LOCAL (same thread writes and reads the same element)
//   so the stub needs no 12th fence; a REAL fused kernel would pay one more (or use per-row
//   blocks) -- that is recorded in the note, not silently hidden.
// DISCIPLINE: bench layer only. shipped three sources untouched. No commit. One process per
//   config (S6B_CFG=n) with a host-side watchdog; over-cap configs self-skip (SKIPROW) unless
//   S6B_FORCE=1, which ATTEMPTS the launch so the JIT rejection is recorded, not assumed.
// BUILD: cd src/bench/sycl && bash E:/DSH/s6/cc_bench.sh s6b_probe.cpp s6b_probe.exe
//   RUN:   powershell -File E:/DSH/s6/run_s6b.ps1 <cfg> <smoke|time> [capsec]
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <string>
#include <functional>
#include <algorithm>
#include <chrono>
#include <thread>
using namespace sycl;

static constexpr size_t cmax(size_t a, size_t b) { return a > b ? a : b; }
static constexpr size_t cmax3(size_t a, size_t b, size_t c) { return cmax(cmax(a, b), c); }

// ===================== the step-1 layout, as a compile-time plan =====================
// C = channels, T = tokens per WG, TOK = window tokens (64 on this graph),
// KVSLM = 1 -> the WHOLE window's k/v lives in SLM; 0 -> it goes to global and is read back
//   (that is the §16 round trip the ownership split re-buys),
// BT = weight-tile bytes kept in SLM (8192 = expand BK32xBN128 double-buffered; 0 = B streamed
//   from global straight to registers, the R2 form),
// SCG = 1 -> the per-row int8 scales (4B/token) live in GLOBAL, not SLM.
template <int C_, int T_, int TOK_, int KVSLM_, int BT_, int SCG_, int INPLACE_ = 0, int NBAR_ = 11>
struct Shape {
    static constexpr int C = C_, T = T_, TOK = TOK_, KVSLM = KVSLM_, SCG = SCG_, INPLACE = INPLACE_, NBAR = NBAR_;
    static constexpr int HID = 4 * C;
    // ---- per-slice BYTES (f16 plane = 2B/elem, pk int8 = 1B/elem, sc = 4B/token) ----
    // *** SCG SEMANTICS FIXED (the first probe run had it INVERTED: it added the 4B/token
    //     scales when SCG=1, so cfg0 measured 73728B instead of the correct 73984B) ***
    // SCG=1 -> the row scales live in GLOBAL and cost NO SLM bytes.
    // INPLACE=1 -> pk2 (the int8 requant of hidden) is compacted IN PLACE into the hidden
    //     block (per-row: read the row's 8C f16, then write its 4C int8 at the row head),
    //     which is legal because the row's f16 is fully consumed before it is overwritten.
    static constexpr size_t S_IN   = 2ull * C * T;                          // 1270 f16 (in + P6 skip)
    static constexpr size_t S_PK   = (size_t)(C + (SCG ? 0 : 4)) * T;       // pk(C) [+sc]
    static constexpr size_t S_PKH  = INPLACE ? 0ull
                                   : (size_t)(4 * C + (SCG ? 0 : 4)) * T;   // pk(4C=hidden) [+sc]
    static constexpr size_t S_HID  = 8ull * C * T;                          // hidden f16 (4C wide)
    static constexpr size_t S_OUT  = 2ull * C * T;                          // 1275 f16
    static constexpr size_t S_1267 = 2ull * C * T;                          // 1267 f16 (P7 src + P11 skip)
    static constexpr size_t S_Q    = 2ull * C * T;                          // q f16 (owned rows)
    static constexpr size_t S_KV   = KVSLM ? 4ull * C * TOK : 0ull;         // window k+v f16
    static constexpr size_t S_SC   = 2ull * T * TOK;                        // scores f16 (T x TOK)
    static constexpr size_t S_ATT  = 2ull * C * T;                          // 1277 attention out f16
    static constexpr size_t S_O2   = 2ull * C * T;                          // 1270 out staging f16
    static constexpr size_t S_B    = (size_t)BT_;                           // dpas B weight tile
    // ---- alias blocks (lifetimes disjoint -> same bytes) ----
    static constexpr size_t BLKA = cmax3(S_HID, S_Q + S_KV + S_ATT, S_OUT); // hidden | (q+kv+att) | 1275
    static constexpr size_t BLKB = cmax3(S_PKH, S_SC, S_PK);                // pk2 | scores | pk1/3/4/5
    static constexpr size_t BLKC = cmax(S_IN, S_O2);                        // in(1270) | 1270-out
    static constexpr size_t BLKD = S_1267;                                  // 1267: live P6..P11, NOT aliasable
    static constexpr size_t BLKE = S_B;                                     // weight tile
    static constexpr size_t SLMRAW = BLKA + BLKB + BLKC + BLKD + BLKE;
    static constexpr size_t SLM  = ((SLMRAW + 15u) / 16u) * 16u;
    static constexpr size_t NOALIAS = S_IN + (size_t)(C + (SCG ? 0 : 4)) * T
        + (size_t)(4 * C + (SCG ? 0 : 4)) * T + S_HID + S_OUT + S_1267 + S_Q + S_KV + S_SC
        + S_ATT + S_O2 + S_B;
    // ---- slice -> block offsets ----
    static constexpr size_t O_A = 0, O_B = BLKA, O_C = O_B + BLKB, O_D = O_C + BLKC, O_E = O_D + BLKD;
    static constexpr size_t P_HID = O_A, P_OUT = O_A, P_Q = O_A, P_KV = O_A + S_Q, P_ATT = O_A + S_Q + S_KV;
    static constexpr size_t P_PK = O_B, P_SC = O_B;
    static constexpr size_t P_PKH = INPLACE ? O_A : O_B;   // the in-place compaction target
    static constexpr size_t P_IN = O_C, P_O2 = O_C;
    static constexpr size_t P_1267 = O_D, P_B = O_E;
    static constexpr int NPH = 11;
};

// ===================== the stub: 11 phases, elementwise only =====================
template <class S>
static event probe(queue& q, const half* dIn, half* dO2, half* dQKV, float* dScG,
                   const uint8_t* dB, size_t ngrp, int LS) {
    return q.submit([&](handler& h) {
        local_accessor<uint8_t, 1> SL(range<1>(S::SLM), h);
        h.parallel_for(nd_range<1>(range<1>(ngrp * (size_t)LS), range<1>(LS)), [=](nd_item<1> it) {
            uint8_t*  slm = SL.get_pointer();
            const int lid = (int)it.get_local_id(0);
            const size_t g = it.get_group(0);
            half*       in   = (half*)(slm + S::P_IN);
            int8_t*     pk   = (int8_t*)(slm + S::P_PK);
            half*       hid  = (half*)(slm + S::P_HID);
            int8_t*     pkh  = (int8_t*)(slm + S::P_PKH);
            half*       outp = (half*)(slm + S::P_OUT);
            half*       p67  = (half*)(slm + S::P_1267);
            half*       qq   = (half*)(slm + S::P_Q);
            half*       kv   = (half*)(slm + S::P_KV);
            half*       sco  = (half*)(slm + S::P_SC);
            half*       att  = (half*)(slm + S::P_ATT);
            half*       o2   = (half*)(slm + S::P_O2);
            // weight source: the SLM tile when BT>0, otherwise the GLOBAL face (R2 form, streamed)
            const size_t WSPAN = S::S_B ? S::S_B : 65536u;
            const uint8_t* W = S::S_B ? (slm + S::P_B) : dB;
            const size_t CT  = (size_t)S::C * S::T;      // halfs in a C-wide f16 slice
            const size_t HT  = (size_t)S::HID * S::T;    // halfs in the hidden slice
            const size_t KT  = (size_t)S::C * S::TOK;    // halfs in ONE of k / v of a whole window
            const size_t ST  = (size_t)S::T * S::TOK;    // scores halfs
            const half*  gIn = dIn + g * CT;
            half*        gO2 = dO2 + g * CT;
            const size_t win = (g * S::T) / S::TOK;      // which window this group's rows belong to
            half*        gqk = dQKV + win * 3ull * (size_t)S::C * S::TOK;
            auto grp = it.get_group();
            // BAR(k) fires the k-th group_barrier only when k <= NBAR: the barrier-count knob
            // (11 = the real chain; 1 / 0 isolate what ELEVEN fences cost, nothing else changed).
            auto BAR = [&](int k){ if (k <= S::NBAR) group_barrier(grp); };
            // ---- P1 QUANT (1270 -> pk1): read the global 1270 block, KEEP the f16 (it is also
            //      the P6 skip source), write the int8 pk plane (+ scales to global if SCG).
            for (size_t i = lid; i < CT; i += LS) { half v = gIn[i]; in[i] = v; pk[i] = (int8_t)(int)(float)v; }
            if (S::SCG) for (size_t i = lid; i < (size_t)S::T; i += LS) dScG[g * S::T + i] = 1.0f;
            BAR(1);                                                   // boundary 1
            // ---- P2 BATCHED expand (pk1 x W -> hidden f16): placeholder = elementwise mix of
            //      pk1 and the weight source, so BOTH slices and the B block carry traffic.
            for (size_t i = lid; i < HT; i += LS)
                hid[i] = half(float(pk[i % CT]) * float(W[(i / S::C) % WSPAN] + 1));
            BAR(2);                                                   // boundary 2
            // ---- P3 QUANT (hidden -> pk2)
            for (size_t i = lid; i < HT; i += LS) pkh[i] = (int8_t)(int)hid[i];
            BAR(3);                                                   // boundary 3
            // ---- P4 BATCHED projection (pk2 x W -> 1275 f16)
            for (size_t i = lid; i < CT; i += LS)
                outp[i] = half(float(pkh[i % HT]) * float(W[(i + 7) % WSPAN] + 1));
            BAR(4);                                                   // boundary 4
            // ---- P5 QUANT (1275 -> pk3)
            for (size_t i = lid; i < CT; i += LS) pk[i] = (int8_t)(int)outp[i];
            BAR(5);                                                   // boundary 5
            // ---- P6 GEMM_INT8_RESIDUAL (pk3 x W + 1270-skip -> 1267)
            for (size_t i = lid; i < CT; i += LS)
                p67[i] = half(float(pk[i]) * float(W[i % WSPAN] + 1) + float(in[i]));
            BAR(6);                                                   // boundary 6
            // ---- P7 QUANT_WINDOW (1267 -> pk4)
            for (size_t i = lid; i < CT; i += LS) pk[i] = (int8_t)(int)p67[i];
            BAR(7);                                                   // boundary 7
            // ---- P8 GEMM_INT8_QKV (pk4 x W -> q,k,v)
            for (size_t i = lid; i < CT; i += LS)
                qq[i] = half(float(pk[i]) * float(W[(i + 3) % WSPAN] + 1));
            if (S::KVSLM) {           // the whole window's k+v land in SLM
                for (size_t i = lid; i < 2 * KT; i += LS)
                    kv[i] = half(float(pk[i % CT]) * float(W[(i + 5) % WSPAN] + 1));
            } else {                  // ... or they go to GLOBAL (the round trip S6-1b re-buys)
                half* gq = dQKV + g * 3ull * CT;
                for (size_t i = lid; i < 3 * CT; i += LS) gq[i] = half(float(pk[i % CT]) * 0.5f);
            }
            BAR(8);                                                   // boundary 8
            // ---- P9 WINDOW_ATTENTION (q,k,v -> scores -> att). scores->att hand-off is kept
            //      thread-local (element i written then read by the SAME thread) so the stub
            //      does not need a 12th fence; a real kernel would.
            for (size_t i = lid; i < ST; i += LS) {
                size_t r = i / S::TOK, c = i % S::TOK;
                half kk = S::KVSLM ? kv[c] : gqk[c * 3 * S::C];
                half vv = S::KVSLM ? kv[KT + c] : gqk[(c * 3 + 1) * S::C];
                sco[i] = half(float(qq[(r * S::C) % CT]) * float(kk) + float(vv));
                att[i] = half(float(sco[i]) * 0.25f + float(qq[i % CT]));
            }
            for (size_t i = ST + lid; i < CT; i += LS) att[i] = half(float(qq[i]) * 0.75f);
            BAR(9);                                                   // boundary 9
            // ---- P10 QUANT (1277 -> pk5)
            for (size_t i = lid; i < CT; i += LS) pk[i] = (int8_t)(int)att[i];
            BAR(10);                                                   // boundary 10
            // ---- P11 GEMM_WINDOW_INT8_RESIDUAL (pk5 x W + 1267-skip -> 1270)
            for (size_t i = lid; i < CT; i += LS)
                o2[i] = half(float(pk[i]) * float(W[(i + 11) % WSPAN] + 1) + float(p67[i]));
            for (size_t i = lid; i < CT; i += LS) gO2[i] = o2[i];                 // the only global store
            BAR(11);                                                   // boundary 11
        });
    });
}

// ===================== host: timing protocol (gemm32_tile TRAP 1-9 verbatim) =====================
struct Stat { double msm, msM, msX, med; size_t ng; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size() / 2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size() / 2]; st.gms = gmin; return st;
}
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f().wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event e = f(); e.wait();
            auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
            auto t0 = e.get_profiling_info<info::event_profiling::command_end>();
            double ms = (double)(t0 - s0) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static Stat timeit_wall(std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            auto c0 = std::chrono::steady_clock::now(); f(); auto c1 = std::chrono::steady_clock::now();
            double ms = std::chrono::duration<double, std::milli>(c1 - c0).count();
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[160]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 140; ++i) o += snprintf(buf + o, sizeof(buf) - o, "%.4f ", st.gms[i]);
    return buf;
}

// ===================== config driver =====================
template <class S>
static int one(int cfg, const char* name, int M, queue& q, device& dev) {
    const int T = S::T, C = S::C;
    const size_t Mp = ((size_t)M + S::TOK - 1) / S::TOK * S::TOK;
    const size_t ngrp = Mp / T;
    const int LS = 64;                       // 64 threads/WG, the 1a/s8v8 sweet-spot shape
    printf("\n#### cfg%-2d %-22s C=%-3d T=%-2d TOK=%d KVSLM=%d BT=%-4d SCG=%d INP=%d NBAR=%2d | SLM=%zuB (raw %zu, no-alias %zu) | ngrp=%zu x %d = %zu thr\n",
           cfg, name, C, T, S::TOK, (int)S::KVSLM, (int)S::S_B, (int)S::SCG, (int)S::INPLACE, (int)S::NBAR, S::SLM, S::SLMRAW, S::NOALIAS, ngrp, LS, ngrp * (size_t)LS);
    printf("     blocks A=%zu B=%zu C=%zu D=%zu E=%zu | slices in=%zu pk=%zu hid=%zu pk2=%zu out=%zu 1267=%zu q=%zu kv=%zu sco=%zu att=%zu o2=%zu B=%zu\n",
           S::BLKA, S::BLKB, S::BLKC, S::BLKD, S::BLKE,
           S::S_IN, S::S_PK, S::S_HID, S::S_PKH, S::S_OUT, S::S_1267, S::S_Q, S::S_KV, S::S_SC, S::S_ATT, S::S_O2, S::S_B);
    const uint32_t cap = dev.get_info<info::device::local_mem_size>();
    printf("     [dev] local_mem_size = %u | max_work_group_size = %u | residency bound floor(cap/slm) = %u\n",
           cap, (unsigned)dev.get_info<info::device::max_work_group_size>(), (uint32_t)(cap / (uint32_t)S::SLMRAW));
    fflush(stdout);
    if (S::SLM > cap && !getenv("S6B_FORCE")) {
        printf("SKIPROW cfg=%d slm=%zu > cap=%u (self-refused; rerun with S6B_FORCE=1 to let the JIT refuse it)\n",
               cfg, S::SLMRAW, cap);
        printf("CSVROW;%d;%s;%d;%d;%zu;%zu;%d;%d;%d;%d;%d;SKIP;0;0;0;0;0;0\n",
               cfg, name, T, C, S::SLMRAW, S::SLM, (int)S::KVSLM, (int)S::S_B, (int)S::SCG, (int)S::INPLACE, (int)S::NBAR);
        return 0;
    }
    std::vector<half> hIn(Mp * C);
    for (size_t i = 0; i < hIn.size(); ++i) hIn[i] = half((float)((int)(i % 200) - 100));
    half *dIn = malloc_device<half>(hIn.size(), q), *dO2 = malloc_device<half>(hIn.size(), q);
    half* dQKV = S::KVSLM ? nullptr : malloc_device<half>(Mp * 3ull * C, q);
    float* dScG = S::SCG ? malloc_device<float>(ngrp * (size_t)T, q) : nullptr;
    uint8_t* dB = malloc_device<uint8_t>(65536, q);
    q.memcpy(dIn, hIn.data(), hIn.size() * 2);
    q.memset(dB, 3, 65536);
    q.wait();
    int rc = 0;
    try {
        probe<S>(q, dIn, dO2, dQKV, dScG, dB, ngrp, LS).wait();
        printf("     LIVE: the 11-phase stub launched and completed (slm %zuB, %d group_barriers)\n", S::SLM, (int)S::NBAR);
        fflush(stdout);
        // sanity: the stub must have written the 1270 out plane (proof the 11 phases were not DCE'd)
        std::vector<half> hO2((size_t)C);
        q.memcpy(hO2.data(), dO2, (size_t)C * 2).wait();
        int nz = 0; for (int i = 0; i < C; ++i) if (float(hO2[i]) != 0.0f) ++nz;
        printf("     DCE check: row0 of the 1270 out plane = %d/%d non-zero halves\n", nz, C);
        if (!nz) { printf("     *** the stub got DCE'd: the ms numbers are meaningless ***\n"); rc = 4; }
        if (getenv("S6B_SMOKE")) {
            printf("     (S6B_SMOKE: timing skipped; one launch only)\n");
            printf("CSVROW;%d;%s;%d;%d;%zu;%zu;%d;%d;%d;%d;%d;LIVE-smoke;0;0;0;0;0;%d\n",
                   cfg, name, T, C, S::SLMRAW, S::SLM, (int)S::KVSLM, (int)S::S_B, (int)S::SCG, (int)S::INPLACE, (int)S::NBAR, nz);
        } else {
            Stat gw = timeit_wall([&]{ probe<S>(q, dIn, dO2, dQKV, dScG, dB, ngrp, LS).wait(); });
            Stat ge = timeit([&]{ return probe<S>(q, dIn, dO2, dQKV, dScG, dB, ngrp, LS); });
            printf("     WALL  msm=%.4f msM=%.4f msX=%.4f med=%.4f groups=[%s]\n", gw.msm, gw.msM, gw.msX, gw.med, gmfmt(gw));
            printf("     GPU   msm=%.4f msM=%.4f msX=%.4f med=%.4f groups=[%s]\n", ge.msm, ge.msM, ge.msX, ge.med, gmfmt(ge));
            fflush(stdout);
            printf("CSVROW;%d;%s;%d;%d;%zu;%zu;%d;%d;%d;%d;%d;LIVE;%.4f;%.4f;%.4f;%.4f;%.4f;%d\n",
                   cfg, name, T, C, S::SLMRAW, S::SLM, (int)S::KVSLM, (int)S::S_B, (int)S::SCG, (int)S::INPLACE, (int)S::NBAR,
               ge.msm, ge.msM, ge.msX, ge.med, gw.msM, nz);
        }
    } catch (const sycl::exception& e) {
        printf("     REJECTED at JIT/compile: %s (code=%d)\n", e.what(), e.code() ? e.code().value() : -1);
        printf("CSVROW;%d;%s;%d;%d;%zu;%zu;%d;%d;%d;%d;%d;REJECT;0;0;0;0;0;0\n",
               cfg, name, T, C, S::SLMRAW, S::SLM, (int)S::KVSLM, (int)S::S_B, (int)S::SCG, (int)S::INPLACE, (int)S::NBAR);
        rc = 2;
    }
    fflush(stdout);
    free(dIn, q); free(dO2, q); if (dQKV) free(dQKV, q); if (dScG) free(dScG, q); free(dB, q);
    return rc;
}

int main() {
    const char* sel = getenv("S6B_CFG");
    int want = sel ? atoi(sel) : -1;
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 1; }
    queue q(dev, property::queue::enable_profiling{});
    printf("device: %s\n", dev.get_info<info::device::name>().c_str());
    printf("M(S1)=32640 (510 windows of 64) | M(S2)=8160 -> Mp=8192 (128 windows of 64)\n");
    int rc = 0;
    // (C, T, TOK, KVSLM, BT, SCG, INPLACE). The FOUR required configs = 0..3:
    //   C=64 at T=64 / T=16 and C=128 at T=64 / T=16, all with the FULL plan
    //   (whole-window k/v in SLM + the B weight tile in SLM + scales in SLM).
    if (want < 0 || want == 0)  rc |= one<Shape<64,  64, 64, 1, 8192, 0, 0>>(0,  "C64_T64_full",       32640, q, dev);
    if (want < 0 || want == 1)  rc |= one<Shape<64,  16, 64, 1, 8192, 0, 0>>(1,  "C64_T16_full",       32640, q, dev);
    if (want < 0 || want == 2)  rc |= one<Shape<128, 64, 64, 1, 8192, 0, 0>>(2,  "C128_T64_full",       8160, q, dev);
    if (want < 0 || want == 3)  rc |= one<Shape<128, 16, 64, 1, 8192, 0, 0>>(3,  "C128_T16_full",       8160, q, dev);
    // the step-1 CUT candidates (judgement line 3)
    if (want < 0 || want == 4)  rc |= one<Shape<64,  64, 64, 1, 0,    0, 0>>(4,  "C64_T64_noBtile",    32640, q, dev);
    if (want < 0 || want == 5)  rc |= one<Shape<64,  64, 64, 1, 0,    1, 0>>(5,  "C64_T64_noB_scGlob", 32640, q, dev);
    if (want < 0 || want == 6)  rc |= one<Shape<64,  64, 64, 1, 8192, 0, 1>>(6,  "C64_T64_pk2inplace", 32640, q, dev);
    if (want < 0 || want == 7)  rc |= one<Shape<64,  16, 64, 0, 8192, 0, 0>>(7,  "C64_T16_kvGlobal",   32640, q, dev);
    if (want < 0 || want == 8)  rc |= one<Shape<64,  16, 64, 0, 0,    1, 0>>(8,  "C64_T16_cut_all",    32640, q, dev);
    if (want < 0 || want == 9)  rc |= one<Shape<128, 16, 64, 0, 8192, 0, 0>>(9,  "C128_T16_kvGlobal",   8160, q, dev);
    if (want < 0 || want == 10) rc |= one<Shape<128, 16, 64, 0, 0,    1, 0>>(10, "C128_T16_cut_all",    8160, q, dev);
    if (want < 0 || want == 11) rc |= one<Shape<64,  32, 64, 1, 8192, 0, 0>>(11, "C64_T32_full",      32640, q, dev);
    if (want < 0 || want == 12) rc |= one<Shape<64,  32, 64, 0, 8192, 0, 0>>(12, "C64_T32_kvGlobal",  32640, q, dev);
    if (want < 0 || want == 13) rc |= one<Shape<128, 32, 64, 0, 8192, 0, 0>>(13, "C128_T32_kvGlobal",  8160, q, dev);
    if (want < 0 || want == 14) rc |= one<Shape<64,  64, 64, 1, 4096, 1, 1>>(14, "C64_T64_ip_B4k_scG", 32640, q, dev);
    // ---- the BARRIER-COUNT knob: identical layout / identical traffic, fewer fences.
    //      bar1 / bar0 are RACY by construction (that is the point: they price the fences, not
    //      correctness). cfg0 = the same layout as 15/16 with all 11 fences.
    if (want < 0 || want == 15) rc |= one<Shape<64,  16, 64, 1, 8192, 0, 0,  1>>(15, "C64_T16_full_bar1",   32640, q, dev);
    if (want < 0 || want == 16) rc |= one<Shape<64,  16, 64, 1, 8192, 0, 0,  0>>(16, "C64_T16_full_bar0",   32640, q, dev);
    if (want < 0 || want == 17) rc |= one<Shape<64,  16, 64, 0, 8192, 0, 0,  1>>(17, "C64_T16_kvG_bar1",    32640, q, dev);
    if (want < 0 || want == 18) rc |= one<Shape<64,  16, 64, 0, 8192, 0, 0,  0>>(18, "C64_T16_kvG_bar0",    32640, q, dev);
    if (want < 0 || want == 19) rc |= one<Shape<64,  64, 64, 1, 8192, 0, 1,  1>>(19, "C64_T64_ip_bar1",     32640, q, dev);
    if (want < 0 || want == 20) rc |= one<Shape<64,  64, 64, 1, 8192, 0, 1,  0>>(20, "C64_T64_ip_bar0",     32640, q, dev);
    printf("\nPROBE DONE rc=%d\n", rc);
    return rc;
}
