// port_e_chain.cpp -- B2: the END-TO-END port-E composition. Bench layer only: it touches no
// shipped source and no shipped artifact.
//
// ONE C=64 attention+FFN chain of the frame (plan closures 641..651 = 11 ops = 13 device launches
// on the shipped path) executed as THREE launches:
//   L1 PE_ATT::att5::fused<64,2,5,DUMP,LIVE>   5 plan legs in one launch:
//        QUANT_WINDOW -> GEMM_INT8_QKV -> WINDOW_ATTENTION -> QUANT -> GEMM_WINDOW_INT8_RESIDUAL
//        (writes the 1270 plane, token order, M x C f16)
//   L2 packdev::pack_a_fused                   the chain's own QUANT leg (closure 646) storing the
//        A face straight in dpas fragment order (the R1 producer; 0.0892 ms standalone)
//        => the FFN half needs NO packA leg
//   L3 PE_FFN::ffn3::fused<S,true,NPH-1,0>     the 1a/M2b FFN chain with P1 supplied by L2:
//        expand -> requant -> contract -> outquant -> residual   (writes 1267)
//   => 11 plan ops / 13 shipped launches -> 3 launches.
// Geometry locked by the order (knife2b #64/#68): T=32, LW=64, SLM 31,104 B (2 resident WG),
// grid = M/T = 1020 WG.  FORBIDDEN: LW=32 (#65), KN=1.
//
// ENTRY TICKET: every tap of the 3-launch chain must be BYTE-IDENTICAL to the 13-launch shipped
// reference chain on the same inputs. The required set = 13 FFN checkpoints + 4 interface items
//   (1) face byte order    : pk1-face (producer face vs the split packA face) + faceA-vs-faceB
//   (2) scale granularity  : sc1 / sc2 / sc3 (one float per row)
//   (3) the quant encoding : pk1 / pk2 / pk3 (int8 + row scale grid, e4m3 lattice untouched)
//   (4) epilogue outlet    : out1275 / pk3-frag / 1267-FINAL
// plus the 12 attention taps of the promoted att half, LIVENESS, --cross, and the rule-46 stress.
//
// Numerics VERBATIM: both halves are the promoted kernels themselves, extracted unmodified by
// s6/pe_mkchain.py into port_e_chain_bodies.inc. No esimd::shuffle anywhere.
//
// usage: port_e_chain.exe [--dump BLOB] [--cross BLOB] [--stress N] [--noprice]

#include "port_e_chain_bodies.inc"

#include <cstring>
#include <cstdlib>
#include <chrono>
#include <thread>
#include <algorithm>

static const char* argstr(int argc, char** argv, const char* flag) {
    for (int i = 1; i + 1 < argc; ++i) if (!strcmp(argv[i], flag)) return argv[i + 1];
    return nullptr;
}
static int argint(int argc, char** argv, const char* flag, int dflt) {
    for (int i = 1; i + 1 < argc; ++i) if (!strcmp(argv[i], flag)) return atoi(argv[i + 1]);
    return dflt;
}
static int argflag(int argc, char** argv, const char* flag) {
    for (int i = 1; i < argc; ++i) if (!strcmp(argv[i], flag)) return 1;
    return 0;
}

struct Stat { double msm = 0, msM = 0, msX = 0, med = 0; int ng = 0; };

// the promoted benches' protocol: 5 groups x 15 reps, 60 ms between groups, nosink.
static Stat timeit_wall(std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    std::vector<double> mins;
    for (size_t g = 0; g < groups; ++g) {
        double best = 1e30;
        for (size_t r = 0; r < reps; ++r) {
            auto t0 = std::chrono::high_resolution_clock::now();
            f();
            auto t1 = std::chrono::high_resolution_clock::now();
            double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
            if (ms < best) best = ms;
        }
        mins.push_back(best);
        std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
    }
    std::sort(mins.begin(), mins.end());
    Stat s; s.ng = (int)groups;
    s.msm = mins.front(); s.msX = mins.back(); s.msM = mins[mins.size() / 2]; s.med = s.msM;
    printf("  groups=[");
    for (auto v : mins) printf(" %.4f", v);
    printf(" ]");
    return s;
}

static size_t dbytes(const uint8_t* a, const uint8_t* b, size_t n) {
    size_t d = 0; for (size_t i = 0; i < n; ++i) if (a[i] != b[i]) ++d; return d;
}
static int gfails = 0;
static size_t dbytes3row(const uint8_t* a, const uint8_t* b, size_t nbytes, size_t cols) {
    for (size_t i = 0; i < nbytes; ++i) if (a[i] != b[i]) return i / (cols * 2);   // f16 plane -> row
    return 0;
}
static void ck(const uint8_t* a, const uint8_t* b, size_t n, size_t axis, const char* name, const char* why) {
    size_t d = 0, fo = 0;
    for (size_t i = 0; i < n; ++i) if (a[i] != b[i]) { ++d; if (!fo) fo = i + 1; }
    if (d) { ++gfails;
        printf("  DIFF %-16s %zu/%zu bytes; first byte %zu (row %zu col %zu)  <== %s\n",
               name, d, n, fo, axis ? fo / axis : 0, axis ? fo % axis : 0, why);
    } else {
        printf("  diff %-16s = 0  (%zu bytes)\n", name, n);
    }
    fflush(stdout);
}

int main(int argc, char** argv) {
    using namespace sycl;
    const char* dumpf = argstr(argc, argv, "--dump");
    const char* crossf = argstr(argc, argv, "--cross");
    const int NSTRESS = argint(argc, argv, "--stress", 0) + argint(argc, argv, "--stress0", 0);
    const bool STRESS_DUMP0 = argint(argc, argv, "--stress0", 0) > 0;   // the SHIPPING form (no taps)
    const bool noprice = argflag(argc, argv, "--noprice") != 0;

    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 2; }
    // an async handler so a dropped/failed submission reports instead of leaving a plane at zero
    async_handler ah = [](sycl::exception_list el) {
        for (auto& e : el) { try { std::rethrow_exception(e); }
                             catch (std::exception const& ex) { printf("[async] %s\n", ex.what()); fflush(stdout); } }
    };
    queue q(dev, ah);      // queue(device, async_handler, property_list = {})
    auto W = [&](sycl::event ev) { ev.wait_and_throw(); };
    printf("[dev] %ls local_mem=%u max_wg=%u global_mem=%llu MB\n",
           dev.get_info<info::device::name>().c_str(), dev.get_info<info::device::local_mem_size>(),
           dev.get_info<info::device::max_work_group_size>(),
           (unsigned long long)dev.get_info<info::device::global_mem_size>() / 1048576ull);

    // ---- the C=64 tier (plan closures 641..651): 510 windows of 8x8 tokens ----
    const unsigned windows = 510u, TOK = 64u, C = 64u, heads = 2u;
    const unsigned image_h = 136u, image_w = 240u, across = 30u, pad = 0u;
    const unsigned M = windows * TOK, Mp = ((M + 127u) / 128u) * 128u;
    const unsigned NH = 3u * C, batches = windows * heads;
    const unsigned top = pad >> 16, left = pad & 0xffffu;
    const int HID = 256, N_e = 128, b_e = 2, N_p = 32, K_p = 128, b_p = 2;
    const size_t imgn = (size_t)image_h * image_w * C;
    const size_t nC = (size_t)M * C, nH = (size_t)M * HID, faceBytes = (size_t)Mp * C, nHfrag = (size_t)Mp * HID;
    printf("#### chain S1 C64 windows=%u M=%u Mp=%u C=%u heads=%u batches=%u image=%ux%u across=%u"
           " HID=%d N_e=%d b_e=%d N_p=%d K_p=%d b_p=%d\n",
           windows, M, Mp, C, heads, batches, image_h, image_w, across, HID, N_e, b_e, N_p, K_p, b_p);

    // ---- host inputs, fixed seed ----
    std::mt19937 rng(20261104u);
    std::uniform_int_distribution<int> di(-127, 127);
    std::uniform_real_distribution<float> dsc(0.002f, 0.02f), df(-1.5f, 1.5f);
    std::vector<int8_t> hWq((size_t)NH * C), hWo((size_t)C * C);
    for (auto& x : hWq) x = (int8_t)di(rng);
    for (auto& x : hWo) x = (int8_t)di(rng);
    std::vector<float> hBS(NH), hQS(heads), hBias((size_t)heads * 4096u), hBS2(C), hCos(C);
    for (auto& x : hBS) x = dsc(rng);
    for (auto& x : hQS) x = dsc(rng) * 4.f;
    for (auto& x : hBias) x = df(rng) * 0.5f;
    for (auto& x : hBS2) x = dsc(rng);
    for (auto& x : hCos) x = df(rng);
    std::vector<half> hImg(imgn);
    for (auto& x : hImg) x = half(df(rng));
    std::vector<int8_t> hWEgrp((size_t)b_e * N_e * C);
    for (auto& x : hWEgrp) x = (int8_t)di(rng);
    std::vector<float>  hSE((size_t)b_e * N_e);       for (auto& x : hSE) x = dsc(rng);
    std::vector<int8_t> hWP((size_t)b_p * N_p * K_p); for (auto& x : hWP) x = (int8_t)di(rng);
    std::vector<float>  hSP((size_t)C);               for (auto& x : hSP) x = dsc(rng);
    std::vector<int8_t> hWR((size_t)C * C);           for (auto& x : hWR) x = (int8_t)di(rng);
    std::vector<float>  hSR(C);                       for (auto& x : hSR) x = dsc(rng);
    std::vector<int8_t> hWEwide((size_t)HID * C);
    for (int g = 0; g < b_e; ++g) for (int n = 0; n < N_e; ++n) for (int k = 0; k < (int)C; ++k)
        hWEwide[(size_t)(g * N_e + n) * C + k] = hWEgrp[(size_t)g * N_e * C + (size_t)n * C + k];

    size_t devbytes = 0;
    auto md = [&](size_t n) { devbytes += n; void* p = malloc_device<uint8_t>(n, q); q.memset(p, 0, n).wait(); return p; };
    auto mh = [&](size_t n) { return (half*)md(n); };
    auto mi = [&](size_t n) { return (int8_t*)md(n); };
    auto mf = [&](size_t n) { return (float*)md(n); };

    half* dImg = mh(imgn * 2);
    int8_t *dWq = mi(hWq.size()), *dWo = mi(hWo.size());
    int8_t *dBp = mi((size_t)NH * C), *dOp = mi((size_t)C * C);
    float *dBS = mf((size_t)NH * 4), *dQS = mf((size_t)heads * 4), *dBias = mf(hBias.size() * 4),
          *dBS2 = mf((size_t)C * 4), *dCos = mf((size_t)C * 4);
    q.memcpy(dImg, hImg.data(), imgn * 2);
    q.memcpy(dWq, hWq.data(), hWq.size()); q.memcpy(dWo, hWo.data(), hWo.size());
    q.memcpy(dBS, hBS.data(), hBS.size() * 4); q.memcpy(dQS, hQS.data(), hQS.size() * 4);
    q.memcpy(dBias, hBias.data(), hBias.size() * 4);
    q.memcpy(dBS2, hBS2.data(), (size_t)C * 4); q.memcpy(dCos, hCos.data(), (size_t)C * 4);
    packdev::pack_b(q, dWq, dBp, (int)NH, (int)C);
    packdev::pack_b(q, dWo, dOp, (int)C, (int)C);
    q.ext_oneapi_submit_barrier();
    int8_t* dWEW  = mi(hWEwide.size()); q.memcpy(dWEW, hWEwide.data(), hWEwide.size());
    int8_t* dBpEW = mi(hWEwide.size());
    packdev::pack_b(q, dWEW, dBpEW, HID, C);      // R2: the fused chain's wide expand pack
    q.ext_oneapi_submit_barrier();                // P20: producer -> consumer needs a barrier, not just wait
    int8_t* dBpE = mi((size_t)b_e * N_e * C);
    int8_t* dBpP = mi((size_t)C * HID);
    int8_t* dBpR = mi(hWR.size());
    float* dSE = mf(hSE.size() * 4); float* dSP = mf((size_t)C * 4); float* dSR = mf((size_t)C * 4);
    q.memcpy(dSE, hSE.data(), hSE.size() * 4); q.memcpy(dSP, hSP.data(), hSP.size() * 4);
    q.memcpy(dSR, hSR.data(), hSR.size() * 4);
    int8_t* dWER = mi(hWEgrp.size()); q.memcpy(dWER, hWEgrp.data(), hWEgrp.size());
    // the promoted benches put an explicit barrier between a producer kernel and its consumer:
    // on this driver a plain q.wait() is NOT always enough for a kernel-written plane that the next
    // kernel reads (the discrete-memory path); without it gather_pack_b_b intermittently leaves its
    // output at zero (measured 2026-11-04 02:4x: 2 of 4 processes).
    q.ext_oneapi_submit_barrier();
    packdev::gather_pack_b_b(q, dWER, dBpE, N_e, C, C, (size_t)N_e * C, b_e);
    q.ext_oneapi_submit_barrier();
    q.wait();
    {   // probe: did the raw weights land, and did the pack run?
        std::vector<int8_t> rw(8), pk(8);
        q.memcpy(rw.data(), dWER, 8); q.memcpy(pk.data(), dBpE, 8); q.wait();
        printf("  PACK-PROBE dWER[0..7]=%d %d %d %d %d %d %d %d | dBpE[0..7]=%d %d %d %d %d %d %d %d\n",
               rw[0],rw[1],rw[2],rw[3],rw[4],rw[5],rw[6],rw[7], pk[0],pk[1],pk[2],pk[3],pk[4],pk[5],pk[6],pk[7]);
        fflush(stdout);
    }
    int8_t* dWPR = mi(hWP.size()); q.memcpy(dWPR, hWP.data(), hWP.size());
    packdev::gather_pack_b_diag_b(q, dWPR, dBpP, N_p, K_p, K_p, (size_t)N_p * K_p, b_p);
    q.ext_oneapi_submit_barrier();
    int8_t* dWRR = mi(hWR.size()); q.memcpy(dWRR, hWR.data(), hWR.size());
    packdev::pack_b(q, dWRR, dBpR, C, C);
    q.ext_oneapi_submit_barrier();
    q.wait();
    printf("-- operands + weight packs done (cache-owned, not timed) --\n");

    // =============================== the 13-launch REFERENCE ===============================
    int8_t* rAp = mi((size_t)Mp * C);   float* rAS = mf((size_t)Mp * 4);
    half *rQ = mh(nC * 2), *rK = mh(nC * 2), *rV = mh(nC * 2);
    half* r1277 = mh(nC * 2);
    int8_t* rAp2 = mi((size_t)Mp * C);  float* rAS2 = mf((size_t)Mp * 4);
    half* r1270 = mh(imgn * 2);
    half* r1267 = mh(nC * 2);
    int8_t* dPK = mi(nHfrag);
    float*  dSCt = mf((size_t)Mp * 4);
    int8_t* dApE = mi((size_t)b_e * Mp * C);
    int8_t* dApP = mi(nHfrag);
    int8_t* dApR = mi(faceBytes);
    half* dH = mh(nH * 2);
    half* dOt = mh(nC * 2);
    half* rDq = mh((size_t)batches * 64 * 32 * 2);  half* rDk = mh((size_t)batches * 64 * 32 * 2);
    half* rProbs = mh((size_t)batches * 4096 * 2);  half* rProbsPack = mh((size_t)batches * 4096 * 2);
    float* rScores = mf((size_t)batches * 4096 * 4);

    std::vector<uint8_t> Rpk0((size_t)Mp * C), Rsc0((size_t)Mp * 4), RQ(nC * 2), RK(nC * 2), RV(nC * 2),
        R1277(nC * 2), RAp2((size_t)Mp * C), RAS2((size_t)Mp * 4), RpkAtt(nC), RscAtt((size_t)M * 4),
        R1270(imgn * 2), Rres(nC * 2), Rout(nC * 2), Rhid(nH * 2), Rpk2(nH), Rsc2((size_t)M * 4),
        Fpk1(nC), Fsc1((size_t)M * 4), RfaceE(faceBytes), RfaceH(nHfrag), RfaceR(faceBytes),
        Rpk3(nC), Rsc3((size_t)M * 4), RProbs((size_t)batches * 4096 * 2), RScores((size_t)batches * 4096 * 4);
    auto snap = [&](void* dst, const void* src, size_t n) { q.memcpy(dst, src, n); q.wait(); };

    printf("-- REF: the shipped 13-launch chain --\n");
    packdev::pack_a_fused_gather(q, dImg, rAp, rAS, (int)M, (int)Mp, (int)C, image_h, image_w, across, pad); q.wait();
    snap(Rpk0.data(), rAp, Rpk0.size()); snap(Rsc0.data(), rAS, Rsc0.size());
    qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS, (int)M, (int)Mp, (int)C, (int)NH,
                       (int)heads, (int)TOK, false, nullptr).wait();
    snap(RQ.data(), rQ, nC * 2); snap(RK.data(), rK, nC * 2); snap(RV.data(), rV, nC * 2);
    wares::launch_wa_res(q, rQ, rK, rV, nullptr, dBias, r1277, batches, heads, true).wait();
    snap(R1277.data(), r1277, nC * 2);
    packdev::pack_a_fused(q, r1277, rAp2, rAS2, (int)M, (int)Mp, (int)C); q.ext_oneapi_submit_barrier(); q.wait();
    snap(RAp2.data(), rAp2, RAp2.size()); snap(RAS2.data(), rAS2, RAS2.size());
    qr_launch_esimd(q, dev, r1277, (sycl::uint2*)dPK, dSCt, M, C); q.wait();
    snap(RpkAtt.data(), dPK, nC); snap(RscAtt.data(), dSCt, (size_t)M * 4);
    s8v8::gemm_b_res_window(q, rAp2, dOp, (void*)r1270, rAS2, dBS2, dImg, dCos, (int)M, (int)Mp,
                            (int)C, (int)C, true, true, 1u, across, top, left, image_h, image_w).wait();
    snap(R1270.data(), r1270, imgn * 2);
    // FFN half: 8 shipped launches, input = the 1270 plane
    qr_launch_esimd(q, dev, r1270, (sycl::uint2*)dPK, dSCt, M, C); q.wait();
    snap(Fpk1.data(), dPK, nC); snap(Fsc1.data(), dSCt, (size_t)M * 4);
    packdev::gather_pack_a_b_v(q, dPK, dApE, M, Mp, C, C, 0, b_e); q.ext_oneapi_submit_barrier(); q.wait();
    snap(RfaceE.data(), dApE, faceBytes);
    {   // which side is empty? probe the A face and the packed B before the expand
        std::vector<uint8_t> pa(16), pb(16), ps(8);
        q.memcpy(pa.data(), dApE, 16); q.memcpy(pb.data(), dBpE, 16); q.memcpy(ps.data(), dSCt, 8); q.wait();
        float s0; memcpy(&s0, ps.data(), 4);
        printf("  REF pre-expand probe: dApE[0..7]=%d %d %d %d %d %d %d %d | dBpE[0..7]=%d %d %d %d %d %d %d %d | dSCt[0]=%.4f\n",
               (int)pa[0],(int)pa[1],(int)pa[2],(int)pa[3],(int)pa[4],(int)pa[5],(int)pa[6],(int)pa[7],
               (int)pb[0],(int)pb[1],(int)pb[2],(int)pb[3],(int)pb[4],(int)pb[5],(int)pb[6],(int)pb[7], s0);
        fflush(stdout);
    }
    W(s8v8::gemm_b_pub_slm<false>(q, dApE, dBpE, (void*)dH, dSCt, dSE, M, Mp, N_e, C, b_e,
                                (size_t)N_e, (unsigned)HID, 0u, (unsigned)N_e, true, 3u));
    snap(Rhid.data(), dH, nH * 2);
    {   // is the plane on the device empty, or did the D2H come back empty?
        std::vector<uint8_t> p(64); q.memcpy(p.data(), dH, 64); q.wait();
        printf("  REF-dH device probe: ");
        for (int c = 0; c < 8; ++c) { half v; memcpy(&v, &p[c * 2], 2); printf("%.4f ", (float)v); }
        printf(" | host snapshot: ");
        for (int c = 0; c < 8; ++c) { half v; memcpy(&v, &Rhid[c * 2], 2); printf("%.4f ", (float)v); }
        printf("\n"); fflush(stdout);
    }
    qr_launch_esimd(q, dev, dH, (sycl::uint2*)dPK, dSCt, M, (unsigned)HID); q.wait();
    snap(Rpk2.data(), dPK, nH); snap(Rsc2.data(), dSCt, (size_t)M * 4);
    packdev::gather_pack_a_b_v(q, dPK, dApP, M, Mp, HID, HID, 0, 1); q.ext_oneapi_submit_barrier(); q.wait();
    snap(RfaceH.data(), dApP, nHfrag);
    s8v8::gemm_b_pub(q, dApP, dBpP, (void*)dOt, dSCt, dSP, M, Mp, C, HID, 1, (size_t)0,
                     (unsigned)C, 0u, 0u, true, 1u).wait();
    snap(Rout.data(), dOt, nC * 2);
    packdev::pack_a_fused(q, dOt, dApR, dSCt, M, Mp, C); q.ext_oneapi_submit_barrier(); q.wait();
    snap(RfaceR.data(), dApR, faceBytes);
    std::vector<uint8_t> pkTmp(nC); memcpy(pkTmp.data(), RfaceR.data(), nC);   // row-major part differs; keep frag
    qr_launch_esimd(q, dev, dOt, (sycl::uint2*)dPK, dSCt, M, C); q.wait();
    snap(Rpk3.data(), dPK, nC); snap(Rsc3.data(), dSCt, (size_t)M * 4);
    s8v8::gemm_b_res(q, dApR, dBpR, (void*)r1267, dSCt, dSR, (const void*)r1270, dCos, M, Mp, C, C,
                     true, true, 1u).wait();
    snap(Rres.data(), r1267, nC * 2);
    // scores/probs authorities (gate only): the split-attention sub-chain, exactly as s6b_att builds it
    packdev::pack_a16_b(q, rQ, rDq, 64, 64, 32, (int)batches);
    packdev::pack_b16_t_b(q, rK, rDk, 32, 64, (int)batches); q.wait();
    f16v2::gemm_b2<64>(q, rDq, rDk, rScores, 64, 64, 32, (int)batches).wait();
    q.parallel_for(range((size_t)batches * 64u),
                   smax::softmax_kernel()(rScores, rProbs, batches * 64u, 64u, dBias, heads)).wait();
    packdev::pack_a16_b(q, rProbs, rProbsPack, 64, 64, 64, (int)batches); q.wait();
    snap(RProbs.data(), rProbsPack, RProbs.size());
    snap(RScores.data(), rScores, RScores.size());
    printf("-- REF done (device bytes allocated so far = %.0f MB) --\n", devbytes / 1e6);

    // =============================== the 3-launch CHAIN ===============================
    half* f1270 = mh(imgn * 2);
    int8_t* faceB = mi(faceBytes);  float* scB = mf((size_t)Mp * 4);
    half* f1267 = mh(nC * 2);
    int8_t* fPK0 = mi((size_t)Mp * C); float* fSC0 = mf((size_t)Mp * 4);
    half *fQ = mh(nC * 2), *fK = mh(nC * 2), *fV = mh(nC * 2);       // the kernel's fragment-order faces
    half *pQ = mh(nC * 2), *pK = mh(nC * 2), *pV = mh(nC * 2);       // DUMP: shipped-order copies (separate!)
    float* fScores = mf((size_t)batches * 4096 * 4);
    half* fProbs = mh((size_t)batches * 4096 * 2);
    half* fATT = mh(2 * nC * 2);      // 2 heads x M x 32 halfs, exactly as s6b_att sizes it
    int8_t* fPKT = mi(nC); float* fAS2 = mf((size_t)M * 4);
    PE_ATT::att5::Outlets o;
    o.pk0p = fPK0; o.sc0p = fSC0; o.pQ = pQ; o.pK = pK; o.pV = pV;
    o.scores = fScores; o.probs = fProbs; o.att = fATT; o.pkt = fPKT; o.as2 = fAS2;

    // The M-rungs are compile-time macros and Shape() asserts that its parameters mirror them, so
    // this TU is BUILT with the M2b defines: /DM_P4FORM=0 /DM_PEAK=1 /DM_P3SPLIT=1 (the rung that
    // measured 0.4109-0.4142 ms and passed 13/13 + 9/9 in knife2b #60/§66). See
    // s6/cc_portE.ps1 -Defs. Shape<> therefore takes the macro defaults here.
    using S = PE_FFN::ffn2::Shape<32, 64, 256, false, 4, 2>;
    half* gHID = mh(nH * 2);
    int8_t* gPK2 = mi(nH);        float* gSC2 = mf((size_t)M * 4);
    half* gOUT = mh(nC * 2);
    int8_t* gPK3 = mi(nC);        float* gSC3 = mf((size_t)M * 4);
    int8_t* gPK2F = mi(nHfrag);   int8_t* gPK3F = mi(faceBytes);
    PE_FFN::ffn2::Args fa;
    fa.dIn = f1270; fa.dOut = f1267;
    fa.Bexp = dBpEW; fa.bsExp = dSE; fa.Bproj = dBpP; fa.bsProj = dSP; fa.BprojH = nullptr;
    fa.Bres = dBpR; fa.bsRes = dSR; fa.cos = dCos; fa.M = (int)M; fa.NP = b_p;
    fa.dpk1 = nullptr; fa.dsc1 = nullptr; fa.dHid = gHID;
    fa.dpk2 = gPK2; fa.dsc2 = gSC2; fa.dOut1275 = gOUT; fa.dpk3 = gPK3; fa.dsc3 = gSC3;
    fa.face = faceB; fa.scA = scB; fa.dpk2frag = gPK2F; fa.dpk3frag = gPK3F; fa.probe = nullptr;

    auto L1 = [&] { PE_ATT::att5::fused<64, 2, 5, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp,
                                                                dBS2, dCos, f1270, fQ, fK, fV,
                                                                windows, across, top, left,
                                                                image_h, image_w, o).wait(); };
    auto L2 = [&] { packdev::pack_a_fused(q, f1270, faceB, scB, M, Mp, C); q.ext_oneapi_submit_barrier(); q.wait(); };
    auto L3 = [&] { PE_FFN::ffn3::fused<S, true, S::NPH - 1, 0>(q, fa).wait(); };
    auto CHAIN3 = [&] { L1(); L2(); L3(); };

    printf("-- CHAIN: 3 launches --\n");
    CHAIN3();
    printf("-- CHAIN done --\n");

    // ---- the SHIPPING form: DUMP=false on both halves. The taps above exist only to pass the
    // gate; a DUMP=true launch writes ~90 MB of diagnostic planes, so pricing it would price the
    // instrument instead of the chain.
    auto L1n = [&] { PE_ATT::att5::fused<64, 2, 5, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp,
                                                                 dBS2, dCos, f1270, fQ, fK, fV,
                                                                 windows, across, top, left,
                                                                 image_h, image_w, o).wait(); };
    auto L3n = [&] { PE_FFN::ffn3::fused<S, false, S::NPH - 1, 0>(q, fa).wait(); };
    auto CHAIN3n = [&] { L1n(); L2(); L3n(); };
    // the 2-launch variant: the shipped 1a half (ffn2) quantizes 1270 inside its own P1, so no
    // producer leg is needed at all -- 11 plan ops -> 2 launches.
    auto CHAIN2 = [&] { L1n(); PE_FFN::ffn2::fused<S, false, S::NPH, 0>(q, fa).wait(); };

    // the two-pass producer face (qr + ffn3::retile_a) = the face the SPLIT path builds
    std::vector<uint8_t> hPkT(nC), hFaceA(faceBytes), hScT((size_t)Mp * 4), hFaceB(faceBytes), hScB((size_t)Mp * 4);
    {
        int8_t* pkT = mi((size_t)Mp * C); int8_t* faceA = mi(faceBytes); float* scT = mf((size_t)Mp * 4);
        qr_launch_esimd(q, dev, f1270, (sycl::uint2*)pkT, scT, M, C); q.wait();
        PE_FFN::ffn3::retile_a(q, pkT, faceA, M, Mp, C); q.wait();
        snap(hPkT.data(), pkT, nC); snap(hFaceA.data(), faceA, faceBytes); snap(hScT.data(), scT, hScT.size());
        free(pkT, q); free(faceA, q); free(scT, q);
    }
    snap(hFaceB.data(), faceB, faceBytes); snap(hScB.data(), scB, hScB.size());

    // ------------------------------ the gates ------------------------------
    printf("-- diff (CHAIN vs REF) --\n");
    {
        std::vector<uint8_t> h((size_t)Mp * C); snap(h.data(), fPK0, h.size());
        ck(h.data(), Rpk0.data(), h.size(), C, "pk0(P7)", "L1 quant_window pack_a order");
        h.assign((size_t)Mp * 4, 0); snap(h.data(), fSC0, h.size());
        ck(h.data(), Rsc0.data(), h.size(), 4, "sc0(P7)", "L1 row scales");
        h.assign(nC * 2, 0); snap(h.data(), pQ, h.size()); ck(h.data(), RQ.data(), h.size(), C, "Q-plane(P8)", "L1 P8 (shipped-order outlet)");
        h.assign(nC * 2, 0); snap(h.data(), pK, h.size()); ck(h.data(), RK.data(), h.size(), C, "K-plane(P8)", "L1 P8 (shipped-order outlet)");
        h.assign(nC * 2, 0); snap(h.data(), pV, h.size()); ck(h.data(), RV.data(), h.size(), C, "V-plane(P8)", "L1 P8 (shipped-order outlet)");
        h.assign((size_t)batches * 4096 * 4, 0); snap(h.data(), fScores, h.size());
        ck(h.data(), RScores.data(), h.size(), 4, "scores(P9)", "L1 P9 vs the f16v2 authority");
        h.assign((size_t)batches * 4096 * 2, 0); snap(h.data(), fProbs, h.size());
        ck(h.data(), RProbs.data(), h.size(), 2, "probs(P9)", "L1 P9 softmax + pack_a16 map");
        // ATT: head0 vs the 1277 plane's first 32 columns, head1 vs the next 32 (s6b_att's exact map)
        std::vector<uint16_t> xa(2 * nC);
        snap(xa.data(), fATT, xa.size() * 2);
        const uint16_t* xb = (const uint16_t*)R1277.data();      // the REF's 1277 plane (host copy)
        {
            const uint16_t* A = xa.data(); const uint16_t* B = xb;
            const size_t stride = (size_t)M * 32u;
            size_t d1 = 0, fi = 0;
            for (unsigned hh = 0; hh < heads; ++hh)
                for (size_t r = 0; r < (size_t)M; ++r)
                    for (unsigned c = 0; c < 32; ++c)
                        if (A[hh * stride + r * 32u + c] != B[r * C + (size_t)hh * 32u + c]) {
                            ++d1; if (!fi) fi = r * C + (size_t)hh * 32u + c;
                        }
            if (d1) { ++gfails; printf("  DIFF %-16s %zu / %zu halfs; first flat idx %zu  <== L1 P9 head planes vs 1277\n",
                                       "att(P9)", d1, (size_t)M * 32, fi); }
            else    { printf("  diff %-16s = 0   (%zu halfs x %u heads)\n", "att(P9)", (size_t)M * 32, heads); }
            fflush(stdout);
        }
        h.assign(nC, 0); snap(h.data(), fPKT, nC);
        ck(h.data(), RpkAtt.data(), nC, C, "pk2(P10)", "L1 P10 vs the rowthread authority");
        h.assign((size_t)M * 4, 0); snap(h.data(), fAS2, h.size());
        ck(h.data(), RscAtt.data(), h.size(), 4, "sc2(P10)", "L1 P10 row scales");
        {
            // pk2-folded: the REF's pack_a_fused plane (fragment map, band = r/128) un-fragmentd and
            // compared against the fused kernel's PKT row-major tap -- s6b_att's exact map.
            std::vector<int8_t> pa((size_t)Mp * C); snap(pa.data(), rAp2, pa.size());
            std::vector<int8_t> xa2(nC), xb2(nC);
            snap(xb2.data(), fPKT, nC);
            for (size_t r = 0; r < M; ++r) {
                size_t band = r / 128u, rem = r % 128u;
                size_t base = band * (size_t)(C / 32) * 4096u + (rem / 16u) * 512u + (rem % 16u) * 32u;
                for (int kb = 0; kb < (int)(C / 32); ++kb)
                    for (int c = 0; c < 32; ++c)
                        xa2[r * C + kb * 32 + c] = pa[base + (size_t)kb * 4096u + c];
            }
            ck((const uint8_t*)xa2.data(), (const uint8_t*)xb2.data(), nC, C, "pk2-folded", "L1 in-kernel PKT vs the pack_a_fused path");
        }
        h.assign(imgn * 2, 0); snap(h.data(), f1270, h.size());
        ck(h.data(), R1270.data(), h.size(), C, "1270-FINAL", "L1 outlet = the FFN half's input");
    }
    {
        ck(hPkT.data(), Fpk1.data(), nC, C, "pk1", "INTERFACE(3) quant encoding: one-pass vs rowthread");
        ck(hFaceB.data(), RfaceE.data(), faceBytes, C, "pk1-face", "INTERFACE(1) face byte order vs split packA");
        ck(hFaceB.data(), hFaceA.data(), faceBytes, C, "faceA-vs-faceB", "INTERFACE(1) one-pass vs two-pass producer");
        ck(hScB.data(), Fsc1.data(), (size_t)M * 4, 4, "sc1", "INTERFACE(2) scale granularity (per row)");
        std::vector<uint8_t> h(nH * 2); snap(h.data(), gHID, h.size());
        ck(h.data(), Rhid.data(), h.size(), HID, "hid", "L3 P2 expand hidden f16");
        {   // forensic: is the mismatch an UNWRITTEN DUMP region (all zeros) or real value drift?
            size_t zchain = 0, zref = 0, rowdiff = 0;
            for (size_t i = 0; i < h.size(); i += 2) { if (!h[i] && !h[i+1]) ++zchain; }
            for (size_t i = 0; i < Rhid.size(); i += 2) { if (!Rhid[i] && !Rhid[i+1]) ++zref; }
            for (size_t r = 0; r < M; ++r) {
                bool d = false;
                for (size_t c = 0; c < (size_t)HID * 2; ++c) if (h[r*(size_t)HID*2 + c] != Rhid[r*(size_t)HID*2 + c]) { d = true; break; }
                if (d) ++rowdiff;
            }
            printf("  HID-FORENSIC chain_zero_halfs=%zu ref_zero_halfs=%zu rows_differing=%zu/%u\n",
                   zchain, zref, rowdiff, M);
            printf("  chain row0[0..7]: "); for (int c = 0; c < 8; ++c) { half v; memcpy(&v, &h[(size_t)c*2], 2); printf("%.4f ", (float)v); }
            printf("\n  ref   row0[0..7]: "); for (int c = 0; c < 8; ++c) { half v; memcpy(&v, &Rhid[(size_t)c*2], 2); printf("%.4f ", (float)v); }
            printf("\n  chain row1[0..7]: "); for (int c = 0; c < 8; ++c) { half v; memcpy(&v, &h[((size_t)HID + c)*2], 2); printf("%.4f ", (float)v); }
            printf("\n  ref   row1[0..7]: "); for (int c = 0; c < 8; ++c) { half v; memcpy(&v, &Rhid[((size_t)HID + c)*2], 2); printf("%.4f ", (float)v); }
            printf("\n");
            // does a 16-row band permutation explain it? (the fragment map's band stride)
            size_t dperm = 0;
            for (size_t r = 0; r < 64; ++r) {
                size_t band = r / 16u, rem = r % 16u;
                size_t rr = band * 16u + rem;             // identity check on a small window
                for (int c = 0; c < 4; ++c)
                    if (memcmp(&h[rr*(size_t)HID*2 + (size_t)c*2], &Rhid[r*(size_t)HID*2 + (size_t)c*2], 2)) ++dperm;
            }
            printf("  HID-FORENSIC identity-band-perm mismatches in the first 64 rows = %zu\n", dperm);
            fflush(stdout);
        }
        h.assign(nH, 0); snap(h.data(), gPK2, nH);
        ck(h.data(), Rpk2.data(), nH, HID, "pk2", "L3 P3 requant (row-major tap)");
        h.assign(nHfrag, 0); snap(h.data(), gPK2F, nHfrag);
        ck(h.data(), RfaceH.data(), nHfrag, HID, "pk2-frag", "L3 P3 fragment-order tap");
        h.assign((size_t)M * 4, 0); snap(h.data(), gSC2, h.size());
        ck(h.data(), Rsc2.data(), h.size(), 4, "sc2", "L3 P3 row scales");
        h.assign(nC * 2, 0); snap(h.data(), gOUT, h.size());
        ck(h.data(), Rout.data(), h.size(), C, "out1275", "INTERFACE(4) epilogue outlet form");
        h.assign(nC, 0); snap(h.data(), gPK3, nC);
        ck(h.data(), Rpk3.data(), nC, C, "pk3", "L3 P5 outquant");
        h.assign(faceBytes, 0); snap(h.data(), gPK3F, faceBytes);
        ck(h.data(), RfaceR.data(), faceBytes, C, "pk3-frag", "INTERFACE(4) fragment-order outlet");
        h.assign((size_t)M * 4, 0); snap(h.data(), gSC3, h.size());
        ck(h.data(), Rsc3.data(), h.size(), 4, "sc3", "L3 P5 row-peak scales");
        h.assign(nC * 2, 0); snap(h.data(), f1267, h.size());
        ck(h.data(), Rres.data(), h.size(), C, "1267-FINAL", "the chain outlet = the frame's next-plane input");
    }
    printf("GATE: %s (%d checkpoints differ)\n", gfails ? "RED" : "GREEN", gfails);
    fflush(stdout);

    // ---- the 2-launch form (shipped 1a half, no producer leg) must also land byte-identical ----
    {
        // ffn2's DUMP writes the pk1/sc1 taps: they must be real buffers (a null tap store
        // faults the device -- measured 2026-11-04 04:1x, 0xC0000409 right after GATE GREEN).
        int8_t* f2PK1 = mi(nC); float* f2SC1 = mf((size_t)M * 4);
        PE_FFN::ffn2::Args fa2 = fa; fa2.face = nullptr; fa2.scA = nullptr;
        fa2.dpk1 = f2PK1; fa2.dsc1 = f2SC1;
        L1n();
        PE_FFN::ffn2::fused<S, true, S::NPH, 0>(q, fa2).wait();
        std::vector<uint8_t> h(nC * 2); snap(h.data(), f1267, h.size());
        ck(h.data(), Rres.data(), h.size(), C, "CHAIN2-1267", "the 2-launch form's outlet (att fused + ffn2)");
        std::vector<uint8_t> h2(nC); snap(h2.data(), gPK3, nC);
        ck(h2.data(), Rpk3.data(), nC, C, "CHAIN2-pk3", "the 2-launch form's own outquant tap");
        if (STRESS_DUMP0) CHAIN3n(); else CHAIN3();   // restore the 3-launch state for the later sections
    }

    // ------------------------------ LIVENESS ------------------------------
    if (!gfails) {
        std::vector<uint8_t> before(nC * 2), after(nC * 2);
        snap(before.data(), f1267, nC * 2);
        q.parallel_for(range(faceBytes), [=](id<1> i) {
            int8_t* p = (int8_t*)faceB; p[i[0]] = (int8_t)((int)p[i[0]] >> 1);
        }).wait();
        L3();
        snap(after.data(), f1267, nC * 2);
        size_t d = dbytes(before.data(), after.data(), nC * 2);
        printf("LIVENESS(faceB/2): 1267 differs in %zu / %zu bytes -> %s\n", d, nC * 2,
               d ? "the shared face really feeds the outlet (NOT a dud)" : "DUD: the face is unused!");
        if (!d) ++gfails;
        fflush(stdout);
    }

    // ------------------------------ rule-46 stress (the WHOLE 3-launch composition) ------------------------------
    if (NSTRESS > 1) {
        // scrub every cross-launch handoff plane, relaunch L1+L2+L3, and compare against launch 0.
        // This is the composition's self-reproducibility gate: it covers L1's global Q/K/V
        // read-after-write (P8 -> P9 inside the kernel), the L1->L2 handoff (1270), the L2->L3
        // handoff (the fragment face + scales) and L3's own SLM phase boundaries.
        std::vector<uint8_t> h1270(imgn * 2), h1270b(imgn * 2), hface(faceBytes), hfaceb(faceBytes);
        std::vector<uint8_t> hsc((size_t)Mp * 4), hscb((size_t)Mp * 4), hres(nC * 2), hresb(nC * 2);
        std::vector<uint8_t> hout(nC * 2), houtb(nC * 2), hpk3(nC), hpk3b(nC);
        if (STRESS_DUMP0) CHAIN3n(); else CHAIN3();
        snap(h1270b.data(), f1270, h1270b.size()); snap(hfaceb.data(), faceB, faceBytes);
        snap(hscb.data(), scB, hscb.size());       snap(hresb.data(), f1267, hresb.size());
        snap(houtb.data(), gOUT, houtb.size());    snap(hpk3b.data(), gPK3, hpk3b.size());
        int nbad = 0, first_s = -1; size_t first_row = 0;
        for (int s = 1; s < NSTRESS; ++s) {
            q.memset(f1270, 0xA5, imgn * 2).wait();
            q.memset(faceB, 0xA5, faceBytes).wait();
            q.memset(scB, 0xA5, (size_t)Mp * 4).wait();
            q.memset(f1267, 0xA5, nC * 2).wait();
            q.memset(gOUT, 0xA5, nC * 2).wait();
            q.memset(gPK3, 0xA5, nC).wait();
            if (STRESS_DUMP0) CHAIN3n(); else CHAIN3();
            snap(h1270.data(), f1270, h1270.size()); snap(hface.data(), faceB, faceBytes);
            snap(hsc.data(), scB, hsc.size());       snap(hres.data(), f1267, hres.size());
            snap(hout.data(), gOUT, hout.size());    snap(hpk3.data(), gPK3, hpk3.size());
            size_t d0 = dbytes(h1270.data(), h1270b.data(), h1270.size());
            size_t d1 = dbytes(hface.data(), hfaceb.data(), faceBytes);
            size_t d2 = dbytes(hsc.data(), hscb.data(), hsc.size());
            size_t d3 = dbytes(hres.data(), hresb.data(), hres.size());
            // dout/dpk3 are DUMP-only taps: with --stress0 (the shipping form) the kernel never
            // writes them, so comparing them would flag the scrub instead of the chain. Skip them.
            size_t d4 = STRESS_DUMP0 ? 0 : dbytes(hout.data(), houtb.data(), hout.size());
            size_t d5 = STRESS_DUMP0 ? 0 : dbytes(hpk3.data(), hpk3b.data(), hpk3.size());
            if (d0 || d1 || d2 || d3 || d4 || d5) {
                ++nbad; if (first_s < 0) { first_s = s; first_row = d3 ? (dbytes3row(hres.data(), hresb.data(), nC, C)) : 0; }
                printf("STRESS s=%d d1270=%zu dface=%zu dsc=%zu d1267=%zu dout=%zu dpk3=%zu first_row=%zu mod16=%d\n",
                       s, d0, d1, d2, d3, d4, d5, first_row, (int)(first_row % 16u));
                fflush(stdout);
            }
        }
        printf("STRESS SUMMARY port_e_chain L1+L2+L3 launches=%d bad=%d first_bad_s=%d dump0=%d\n",
               NSTRESS, nbad, first_s, STRESS_DUMP0 ? 1 : 0);
        fflush(stdout);
    }

    // ------------------------------ dump / cross ------------------------------
    if (dumpf || crossf) {
        std::vector<uint8_t> blob, h;
        auto add = [&](const uint8_t* b, size_t n) { blob.insert(blob.end(), b, b + n); };
        h.assign(imgn * 2, 0);  snap(h.data(), f1270, h.size());  add(h.data(), h.size());
        h.assign(nC * 2, 0);    snap(h.data(), f1267, h.size());  add(h.data(), h.size());
        h.assign(faceBytes, 0); snap(h.data(), faceB, faceBytes); add(hFaceB.data(), hFaceB.size());
        h.assign(nC * 2, 0);    snap(h.data(), gOUT, nC * 2);     add(h.data(), h.size());
        h.assign(nC, 0);        snap(h.data(), gPK3, nC);         add(h.data(), h.size());
        h.assign((size_t)M * 4, 0); snap(h.data(), gSC3, h.size()); add(h.data(), h.size());
        if (dumpf) { FILE* w = fopen(dumpf, "wb"); if (w) { fwrite(blob.data(), 1, blob.size(), w); fclose(w); }
                     printf("DUMP %s %zu bytes\n", dumpf, blob.size()); }
        if (crossf) { FILE* r = fopen(crossf, "rb"); if (!r) { printf("CROSS: missing %s\n", crossf); return 3; }
                      std::vector<uint8_t> old(blob.size()); size_t got = fread(old.data(), 1, blob.size(), r); fclose(r);
                      bool same = (got == blob.size()) && !memcmp(old.data(), blob.data(), blob.size());
                      printf("CROSS %s: %s (%zu vs %zu bytes)\n", crossf, same ? "IDENTICAL" : "DIFFERENT", got, blob.size());
                      if (!same) ++gfails; }
        fflush(stdout);
    }

    // ------------------------------ pricing ------------------------------

    if (!noprice) {
        Stat c13 = timeit_wall([&] {
            packdev::pack_a_fused_gather(q, dImg, rAp, rAS, (int)M, (int)Mp, (int)C, image_h, image_w, across, pad);
            qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS, (int)M, (int)Mp, (int)C, (int)NH, (int)heads, (int)TOK, false, nullptr);
            wares::launch_wa_res(q, rQ, rK, rV, nullptr, dBias, r1277, batches, heads, true);
            packdev::pack_a_fused(q, r1277, rAp2, rAS2, (int)M, (int)Mp, (int)C);
            s8v8::gemm_b_res_window(q, rAp2, dOp, (void*)r1270, rAS2, dBS2, dImg, dCos, (int)M, (int)Mp, (int)C, (int)C, true, true, 1u, across, top, left, image_h, image_w);
            qr_launch_esimd(q, dev, r1270, (sycl::uint2*)dPK, dSCt, M, C);
            packdev::gather_pack_a_b_v(q, dPK, dApE, M, Mp, C, C, 0, b_e);
            s8v8::gemm_b_pub_slm<false>(q, dApE, dBpE, (void*)dH, dSCt, dSE, M, Mp, N_e, C, b_e, (size_t)N_e, (unsigned)HID, 0u, (unsigned)N_e, true, 3u);
            qr_launch_esimd(q, dev, dH, (sycl::uint2*)dPK, dSCt, M, (unsigned)HID);
            packdev::gather_pack_a_b_v(q, dPK, dApP, M, Mp, HID, HID, 0, 1);
            s8v8::gemm_b_pub(q, dApP, dBpP, (void*)dOt, dSCt, dSP, M, Mp, C, HID, 1, (size_t)0, (unsigned)C, 0u, 0u, true, 1u);
            packdev::pack_a_fused(q, dOt, dApR, dSCt, M, Mp, C);
            s8v8::gemm_b_res(q, dApR, dBpR, (void*)r1267, dSCt, dSR, (const void*)r1270, dCos, M, Mp, C, C, true, true, 1u);
            q.wait();
        });
        Stat c3 = timeit_wall(CHAIN3);
        Stat c3n = timeit_wall(CHAIN3n);
        Stat c2 = timeit_wall(CHAIN2);
        printf("CSVROW;S1-C64;REF13;%.4f;%.4f;%.4f;%.4f\n", c13.msm, c13.msM, c13.msX, c13.med);
        printf("CSVROW;S1-C64;CHAIN3;%.4f;%.4f;%.4f;%.4f\n", c3.msm, c3.msM, c3.msX, c3.med);
        printf("CSVROW;S1-C64;CHAIN3n;%.4f;%.4f;%.4f;%.4f\n", c3n.msm, c3n.msM, c3n.msX, c3n.med);
        printf("CSVROW;S1-C64;CHAIN2;%.4f;%.4f;%.4f;%.4f\n", c2.msm, c2.msM, c2.msX, c2.med);
        fflush(stdout);
    }

    printf("#### port_e_chain: %s (fails=%d)\n", gfails ? "RED" : "GREEN", gfails);
    return gfails ? 1 : 0;
}
