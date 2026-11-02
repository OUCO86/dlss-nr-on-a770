// wb_int8_probe.cpp -- WB int8 铲 第 1 步（GO/NO-GO）净价探针。**只测不改**。
// 不动 shipped 三源；只 include 它们的核头。untracked，不 commit。
//
// 量三笔，全部独立进程（军规 16）、min-of-15x5（5 组 60ms 间隔）、nosink（军规 19）：
//   (1) f16 腿现值     —— 对照 §37 的 stop_stage 分相（2040w: 0.3611/0.2828/0.1729/0.1078）
//   (2) int8 腿同形状  —— 先按 tools/xmx_f16_roof.csv 预测，再实测（差 >25% 要说明）
//   (3) 换精度的代价   —— A: 激活面量化腿（pack_a_fused vs pack_a16_b/pack_a）
//                        B: int8 权重预整定（init 期一次，不计入帧）
//                        C: epilogue requant（gemm32_b_pub/gemm_b_pub 减 gemm32_b/gemm_b）
//
// 形状（plan 实参，E:\DSH\s6\wb_ga_ops.csv，十发里的 2040w/8160w 两个 M）：
//   QKV M x 96 x 32 | scores M x 64 x 32 | attnV M x 32 x 64 | proj M x 32 x 32
// int8 引擎约束：M 补到 128 的倍数（130560/522240 都已是）、K%32==0、N%32==0（BN32）或 N%64==0（BN64）。
//
// 用法：WB8_M=<130560|522240> WB8_SEC=<legs|quant|packb>  （每个组合一个进程）
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include <thread>
#include <chrono>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;

// ---------------------------------------------------------------- harness（照 wb_ga_probe.cpp）
struct Stat { double msm=0, msM=0, msX=0, med=0; size_t ng=0; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size()/2]; st.gms = gmin; return st;
}
static size_t G_GRP = 5, G_REP = 15;   // 由 WB8_G/WB8_R 覆盖（0 = 用默认）
static Stat timeit(std::function<event()> f, size_t groups = 0, size_t reps = 0, int gap_ms = 60) {
    if (!groups) groups = G_GRP;
    if (!reps)   reps   = G_REP;
    f().wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event e = f(); e.wait();
            double ms = double(e.get_profiling_info<info::event_profiling::command_end>() -
                               e.get_profiling_info<info::event_profiling::command_start>()) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
// pack_* 族是 void 返回的 parallel_for —— 用两个 barrier 夹逼取 GPU 段时间（同 wb_ga_probe 的 timeit_bracket）
static Stat timeit_void(queue& q, std::function<void()> f, size_t groups = 0, size_t reps = 0, int gap_ms = 60) {
    if (!groups) groups = G_GRP;
    if (!reps)   reps   = G_REP;
    f(); q.wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event a = q.ext_oneapi_submit_barrier();
            f();
            event b = q.ext_oneapi_submit_barrier();
            a.wait(); b.wait();
            double ms = double(b.get_profiling_info<info::event_profiling::command_start>() -
                               a.get_profiling_info<info::event_profiling::command_end>()) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[160]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 140; ++i) o += snprintf(buf+o, sizeof(buf)-o, "%.4f ", st.gms[i]);
    return buf;
}
static void csvrow(const char* sect, const char* sh, const char* leg, const Stat& st,
                   double gflop, const char* extra) {
    double tops = gflop > 0 ? gflop / st.msM * 1e3 : 0.0;
    printf("CSVROW;%s;%s;%s;%.4f;%.4f;%.4f;%.4f;%.6f;%.4f;%s;groups=[%s]\n",
           sect, sh, leg, st.msm, st.msM, st.msX, st.med, gflop, tops, extra ? extra : "", gmfmt(st));
    fflush(stdout);
}

int main(int argc, char** argv) {
    const int M  = getenv("WB8_M")  ? atoi(getenv("WB8_M"))  : 130560;
    const char* sec = getenv("WB8_SEC") ? getenv("WB8_SEC") : "legs";
    queue q(gpu_selector_v, property::queue::enable_profiling{});
    printf("device: %s\n", q.get_device().get_info<info::device::name>().c_str());
    printf("=== wb_int8_probe sec=%s M=%d (min-of-15x5, 5 groups, 60ms gap, nosink) ===\n", sec, M);

    struct LS { const char* n; int N; int K; bool btrans; };   // btrans: B stored (N,K) row-major
    // 10 发里的真实四腿（2040w plain 与 8160w POOL 同 N/K，只差 M）
    std::vector<LS> legs = {
        {"qkv",    96, 32, false},   // B = wqkv 权重 (32x96 row-major)
        {"scores", 64, 32, true },   // B = k 面，(N,K)=(64,32) row-major
        {"attnV",  32, 64, false},   // B = v 面 (64x32)
        {"proj",   32, 32, false},   // B = wproj 权重 (32x32)
    };
    // WB8_EXTRA=1：把 N 补到 BN64 的对照（问 "BN32 的 pub 几何是不是贵在那儿"）
    if (getenv("WB8_EXTRA")) {
        legs.push_back({"qkv_pad128", 128, 32, false});
        legs.push_back({"proj_pad64",  64, 32, false});
        legs.push_back({"attnV_pad64", 64, 64, false});
    }
    const int Mp16 = ((M + 15) / 16) * 16;      // f16v1 只要 16 对齐（这里 M 已对齐）
    const int Mp8  = ((M + 127) / 128) * 128;   // s8v8 要 128 对齐（这里 M 已对齐）
    // WB8_EPI：publish/requant 的出口形态。4 = half-round；1 = e4m3 snap（= 链上真实形态）
    const unsigned EPI = (unsigned)(getenv("WB8_EPI") ? atoi(getenv("WB8_EPI")) : 4);
    G_GRP = getenv("WB8_G") ? (size_t)atoi(getenv("WB8_G")) : 5;   // 组数
    G_REP = getenv("WB8_R") ? (size_t)atoi(getenv("WB8_R")) : 15;  // 每组 reps
    const size_t GRP = G_GRP, REP = G_REP;
    printf("  EPI=%u groups=%zu reps=%zu\n", EPI, GRP, REP);

    if (!strcmp(sec, "legs")) {
        for (auto& L : legs) {
            const int N = L.N, K = L.K;
            double gf = 2.0 * (double)M * N * K / 1e9;
            char sh[64]; snprintf(sh, sizeof sh, "M%d_N%d_K%d_e%u", M, N, K, EPI);

            // ---------- f16 腿（对照 §37 屋顶表 / stop_stage 分相）----------
            {
                half *dA = malloc_device<half>((size_t)Mp16*K, q);
                half *dAp = malloc_device<half>((size_t)Mp16*K, q);
                half *dB = malloc_device<half>((size_t)K*N, q);
                half *dBp = malloc_device<half>((size_t)K*N, q);
                float* dC = malloc_device<float>((size_t)Mp16*N, q);
                q.memset(dA, 0x11, (size_t)Mp16*K*2);
                q.memset(dB, 0x22, (size_t)K*N*2); q.wait();
                packdev::pack_a16_b(q, dA, dAp, Mp16, Mp16, K, 1);
                if (L.btrans) packdev::pack_b16_t_b(q, dB, dBp, K, N, 1);
                else          packdev::pack_b16_b(q, dB, dBp, K, N, 1);
                q.wait();
                Stat st = timeit([&]{ return f16v1::gemm_b(q, dAp, dBp, dC, Mp16, N, K, 1); });
                csvrow("LEG_f16_raw", sh, "gemm_b_f32out", st, gf, "f16 dpas, f32 C");
                // f16 + 折进 store 的 publish（narrow f16 out，epi4 = half-round）：对照 epilogue 的 f16 侧代价
                Stat sp = timeit([&]{ return f16v1::gemm_b_pub_f16(q, dAp, dBp, (void*)dC, Mp16, Mp16,
                                                                   N, K, 1, EPI, true, 0, (size_t)N, (unsigned)N, 0u); });
                csvrow("LEG_f16_pub", sh, "gemm_b_pub_f16_f16out", sp, gf, "f16 dpas, f16 out (epi4)");
                sycl::free(dA,q); sycl::free(dAp,q); sycl::free(dB,q); sycl::free(dBp,q); sycl::free(dC,q);
            }
            // ---------- int8 腿（host pack，与屋顶表同配方）----------
            {
                std::vector<int8_t> hA((size_t)Mp8*K), hB((size_t)N*K), hAp((size_t)Mp8*K), hBp((size_t)N*K);
                for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((int)((i*37)%251) - 125);
                for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((int)((i*53)%251) - 125);
                s8v8::pack_a(hA.data(), hAp.data(), Mp8, K);
                s8v8::pack_b(hB.data(), hBp.data(), N, K);
                int8_t*  dAp8 = malloc_device<int8_t>(hAp.size(), q);
                int8_t*  dBp8 = malloc_device<int8_t>(hBp.size(), q);
                int32_t* dC32 = malloc_device<int32_t>((size_t)Mp8*N, q);
                q.memcpy(dAp8, hAp.data(), hAp.size()); q.memcpy(dBp8, hBp.data(), hBp.size()); q.wait();
                Stat st = (N % 64 == 0)
                    ? timeit([&]{ return s8v8::gemm_b(q, dAp8, dBp8, dC32, Mp8, N, K, 1); })
                    : timeit([&]{ return s8v8::gemm32_b(q, dAp8, dBp8, dC32, Mp8, N, K, 1); });
                char nb[80]; snprintf(nb,sizeof nb,"int8 %s, int32 C", (N%64==0)?"gemm_b(BN64)":"gemm32_b(BN32)");
                csvrow("LEG_i8_raw", sh, (N%64==0)?"gemm_b":"gemm32_b", st, gf, nb);
                sycl::free(dAp8,q); sycl::free(dBp8,q); sycl::free(dC32,q);
            }
            // ---------- int8 + 折进 epilogue 的 requant（as/bs -> f16 出口面）----------
            {
                std::vector<int8_t> hA((size_t)Mp8*K), hB((size_t)N*K), hAp((size_t)Mp8*K), hBp((size_t)N*K);
                for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((int)((i*37)%251) - 125);
                for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((int)((i*53)%251) - 125);
                s8v8::pack_a(hA.data(), hAp.data(), Mp8, K);
                s8v8::pack_b(hB.data(), hBp.data(), N, K);
                int8_t* dAp8 = malloc_device<int8_t>(hAp.size(), q);
                int8_t* dBp8 = malloc_device<int8_t>(hBp.size(), q);
                float*  das  = malloc_device<float>((size_t)Mp8, q);
                float*  dbs  = malloc_device<float>((size_t)N, q);
                half*   dC16 = malloc_device<half>((size_t)Mp8*N, q);
                std::vector<float> has(Mp8, 1.0f/127.f), hbs(N, 1.0f/127.f);
                q.memcpy(dAp8, hAp.data(), hAp.size()); q.memcpy(dBp8, hBp.data(), hBp.size());
                q.memcpy(das, has.data(), has.size()*4); q.memcpy(dbs, hbs.data(), hbs.size()*4); q.wait();
                Stat st = (N % 64 == 0)
                    ? timeit([&]{ return s8v8::gemm_b_pub(q, dAp8, dBp8, (void*)dC16, das, dbs, M, Mp8, N, K, 1,
                                                          (size_t)0, (unsigned)N, 0u, 0u, true, EPI); })
                    : timeit([&]{ return s8v8::gemm32_b_pub(q, dAp8, dBp8, (void*)dC16, das, dbs, M, Mp8, N, K, 1,
                                                            (size_t)0, (unsigned)N, 0u, 0u, true, EPI); });
                char nb[80]; snprintf(nb,sizeof nb,"int8 %s + 折叠 requant(epi4), f16 C",
                                      (N%64==0)?"gemm_b_pub":"gemm32_b_pub");
                csvrow("LEG_i8_pub", sh, (N%64==0)?"gemm_b_pub":"gemm32_b_pub", st, gf, nb);
                sycl::free(dAp8,q); sycl::free(dBp8,q); sycl::free(das,q); sycl::free(dbs,q); sycl::free(dC16,q);
            }
        }
    }

    if (!strcmp(sec, "quant")) {
        // 激活面量化腿：每个腿的 A 面（M x K，K=32/64）
        for (int K : {32, 64}) {
            char sh[48]; snprintf(sh, sizeof sh, "Aplane_M%d_K%d", M, K);
            const size_t nA = (size_t)M * K;
            half*   dAf = malloc_device<half>(nA, q);
            half*   dAp16 = malloc_device<half>((size_t)Mp16*K, q);
            int8_t* dAp8 = malloc_device<int8_t>((size_t)Mp8*K, q);
            float*  dsc  = malloc_device<float>((size_t)Mp8, q);
            q.memset(dAf, 0x11, nA*2); q.wait();
            // (a) 现链的 A-pack 腿：f16 面 -> f16 packed（零 ALU，只搬运）
            Stat s16 = timeit_void(q, [&]{ packdev::pack_a16_b(q, dAf, dAp16, M, Mp16, K, 1); });
            csvrow("QUANT_f16pack", sh, "pack_a16_b", s16, 0.0, "f16 read -> f16 packed write");
            Stat s8p = timeit_void(q, [&]{ packdev::pack_a(q, (const int8_t*)dAf, dAp8, M, Mp8, K); });
            char nb[64]; snprintf(nb,sizeof nb,"int8 read(假面,借 f16 缓冲)-> int8 packed");
            csvrow("QUANT_i8pack", sh, "pack_a", s8p, 0.0, nb);
            Stat sfu = timeit_void(q, [&]{ packdev::pack_a_fused(q, dAf, dAp8, dsc, M, Mp8, K); });
            csvrow("QUANT_fused", sh, "pack_a_fused", sfu, 0.0, "f16 read -> int8 packed + 行 scale（一次读）");
            printf("  QUANT %s: pack_a16_b=%.4f pack_a=%.4f pack_a_fused=%.4f ms | Δ(fused-f16pack)=%+.4f\n",
                   sh, s16.msM, s8p.msM, sfu.msM, sfu.msM - s16.msM);
            sycl::free(dAf,q); sycl::free(dAp16,q); sycl::free(dAp8,q); sycl::free(dsc,q);
        }
    }

    if (!strcmp(sec, "quantg")) {
        // A 侧"激活面量化腿"的**折进 pack/gather 形态**（P4b 的 pack_a_fused_gather）：
        // 一个 item 一行 gemm 行，按 window map 从 f16 图面 gather + 行峰 + fdiv_rn 量化 +
        // scatter 进 pack_a 的 BM128/BK32 int8 tile —— 对照同一 gather 形状的 f16 pack。
        // WB plan 实参：POOL 544x960 across=120 pad=0；plain 272x480 across=60 pad=0。
        struct GS { unsigned H, W, across, pad; };
        std::vector<GS> gs = { M == 522240 ? GS{544u,960u,120u,0u} : GS{272u,480u,60u,0u} };
        for (auto& g : gs) {
            for (int K : {32, 64}) {
                char sh[64]; snprintf(sh, sizeof sh, "GATH_M%d_K%d_%ux%u", M, K, g.H, g.W);
                const size_t nA = (size_t)M * K;
                half*   dAf   = malloc_device<half>(nA, q);
                half*   dAp16 = malloc_device<half>((size_t)Mp16*K, q);
                int8_t* dAp8  = malloc_device<int8_t>((size_t)Mp8*K, q);
                float*  dsc   = malloc_device<float>((size_t)Mp8, q);
                q.memset(dAf, 0x11, nA*2); q.wait();
                // 同一 gather 映射的 f16 侧（线性 lda：image 行连续，只当上界对照）
                Stat g16 = timeit_void(q, [&]{ packdev::gather_pack_a16(q, dAf, dAp16, M, Mp16, K, K, (size_t)K, 0, 0); });
                csvrow("QG_f16gather", sh, "gather_pack_a16", g16, 0.0, "f16 gather + pack f16（对照）");
                Stat gf = timeit_void(q, [&]{ packdev::pack_a_fused_gather(q, dAf, dAp8, dsc, M, Mp8, K,
                                                                           g.H, g.W, g.across, g.pad); });
                csvrow("QG_i8fusedgather", sh, "pack_a_fused_gather", gf, 0.0,
                       "f16 图面 gather + 行峰 + fdiv_rn + int8 pack（折叠形态）");
                printf("  QUANTG %s: gather_pack_a16=%.4f pack_a_fused_gather=%.4f  delta=%+.4f ms\n",
                       sh, g16.msM, gf.msM, gf.msM - g16.msM);
                sycl::free(dAf,q); sycl::free(dAp16,q); sycl::free(dAp8,q); sycl::free(dsc,q);
            }
        }
    }

    if (!strcmp(sec, "packb")) {
        // 权重预整定：init 期一次，不计入帧。报字节数 + 一次性 device pack 的价。
        for (auto& L : legs) {
            const int N = L.N, K = L.K;
            char sh[48]; snprintf(sh, sizeof sh, "W_N%d_K%d", N, K);
            half*  dB16 = malloc_device<half>((size_t)K*N, q);
            half*  dBp16 = malloc_device<half>((size_t)K*N, q);
            int8_t* dB8 = malloc_device<int8_t>((size_t)N*K, q);
            int8_t* dBp8 = malloc_device<int8_t>((size_t)N*K, q);
            q.memset(dB16, 0x22, (size_t)K*N*2); q.memset(dB8, 0x22, (size_t)N*K); q.wait();
            Stat a = timeit_void(q, [&]{ packdev::pack_b16_b(q, dB16, dBp16, K, N, 1); });
            Stat b = timeit_void(q, [&]{ packdev::pack_b(q, dB8, dBp8, N, K); });
            printf("  PACKB %s: f16 weight=%zuB packed=%zuB | int8 weight=%zuB packed=%zuB | "
                   "init pack f16=%.4f int8=%.4f ms\n", sh,
                   (size_t)K*N*2, (size_t)K*N*2, (size_t)N*K, (size_t)N*K, a.msM, b.msM);
            csvrow("PACKB_f16", sh, "pack_b16_b", a, 0.0, "init-time only");
            csvrow("PACKB_i8",  sh, "pack_b", b, 0.0, "init-time only");
            sycl::free(dB16,q); sycl::free(dBp16,q); sycl::free(dB8,q); sycl::free(dBp8,q);
        }
    }
    printf("=== done ===\n");
    return 0;
}
