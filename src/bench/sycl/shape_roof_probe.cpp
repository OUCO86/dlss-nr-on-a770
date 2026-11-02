// shape_roof_probe.cpp -- 胖形状普查铲 第 2.5 步：**实测屋顶表**（tools/xmx_roof.csv 的数据源）。
// 只测不改：不动 shipped 三源、不接图、不动 dll/金标。untracked（编译到 E:\DSH\oneapi）。
//
// 协议（照 §47 / tools/xmx_f16_roof.csv 的已立规矩）：
//   每个形状点 = 一个**独立进程**（SRP_GRP 选组），**6 个进程**取 msM 中位（军规 35b）；
//   进程内 = min-of-15x5（5 组 × 15 次，组间 60ms，GPU event 计时），**nosink**（军规 19：
//   计时腿的输出不写回 host，但 kernel 写满 C，DCE 不会剪 dpas —— 与 §47 的 roof 段同形）；
//   f16 与 int8 都测（军规 35a：N<64 不许按 N64 内插）；raw 腿与 pub（折叠 publish/requant）腿都测。
//
// 形状点成对给出：**小 M 原形** vs **合并形**（军规 1：batch 进 grid 维 / fat-N 多输出列 /
// block-diagonal wide-merge / fat-M 上界参照），这样"合并倍率"直接可算。
//
// 用法：SRP_GRP=<0..N> SRP_PUB=<0|1> SRP_G=<组数> SRP_R=<每组次数> ./shape_roof_probe.exe
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

struct Stat { double msm=0, msM=0, msX=0, med=0; size_t ng=0; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end()); st.med = all[all.size()/2]; st.gms = gmin; return st;
}
static size_t G_GRP = 5, G_REP = 15;
static Stat timeit(std::function<event()> f, int gap_ms = 60) {
    f().wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < G_GRP; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < G_REP; ++it) {
            event e = f(); e.wait();
            double ms = double(e.get_profiling_info<info::event_profiling::command_end>() -
                               e.get_profiling_info<info::event_profiling::command_start>()) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[200]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 180; ++i) o += snprintf(buf+o, sizeof(buf)-o, "%.4f ", st.gms[i]);
    return buf;
}
static void csvrow(const char* grp, const char* dt, const char* leg, int M, int N, int K, int b,
                   const Stat& st, double gf, const char* note) {
    double tops = gf > 0 ? gf / st.msM * 1e3 : 0.0;
    printf("CSVROW;%s;%s;%s;%d;%d;%d;%d;%.4f;%.4f;%.4f;%.4f;%.6f;%.4f;%s;groups=[%s]\n",
           grp, dt, leg, M, N, K, b, st.msm, st.msM, st.msX, st.med, gf, tops, note ? note : "", gmfmt(st));
    fflush(stdout);
}
struct Grp { const char* name; int M, N, K, batch; bool pub; };
// 形状点清单（成对：原形 / 合并形）。N/K 合法性：int8 要 K%32==0 && N%32==0；f16 要 %16==0。
static std::vector<Grp> GROUPS = {
  // --- ViT / head 深 K 小 M 原形 + 合并形 ---
  {"G00_vit_gemm192_4096_1024",     192, 4096, 1024, 1, true},
  {"G01_vit_gemm_b8",               192, 4096, 1024, 8, false},
  {"G02_vit_fatM1536",             1536, 4096, 1024, 1, true},
  {"G03_res_192_1024_4096",         192, 1024, 4096, 1, true},
  {"G04_res_b8",                    192, 1024, 4096, 8, false},
  {"G05_res_fatM1536",             1536, 1024, 4096, 1, true},
  {"G06_qkv1024_192_3072",          192, 3072, 1024, 1, true},
  {"G07_qkv1024_b8",                192, 3072, 1024, 8, false},
  {"G08_qkv1024_fatM1536",         1536, 3072, 1024, 1, true},
  {"G09_qkv1024b_192_1024",         192, 1024, 1024, 1, true},
  {"G10_qkv1024b_b8",               192, 1024, 1024, 8, false},
  {"G11_proj_640_512_512",          640,  512,  512, 1, true},
  {"G12_proj_b8",                   640,  512,  512, 8, false},
  {"G13_proj_fatM5120",            5120,  512,  512, 1, true},
  {"G14_qkv512_960_1536",           960, 1536,  512, 1, true},
  {"G15_qkv512_768_1536",           768, 1536,  512, 1, true},
  {"G16_qkv512_fatM1728",          1728, 1536,  512, 1, true},
  {"G17_qkv256_2560_768",          2560,  768,  256, 1, true},
  {"G18_qkv256_b8",                2560,  768,  256, 8, false},
  {"G19_qkv256_fatM20480",        20480,  768,  256, 1, true},
  {"G20_wres_2560_256_256",        2560,  256,  256, 1, true},
  {"G21_wres_b8",                  2560,  256,  256, 8, false},
  {"G22_wres_2040_256_256",        2040,  256,  256, 1, true},
  {"G23_wres_2040_b8",             2040,  256,  256, 8, false},
  // --- batched 家族：原形（b>1）vs fat-N 合并形（sa=0 ⇒ A 广播，多输出列）---
  {"G24_batched_2040_128_256_b8",  2040,  128,  256, 8, true},
  {"G25_wide_2040_1024_256",       2040, 1024,  256, 1, true},
  {"G26_fatM_16320_128_256",      16320,  128,  256, 1, true},
  {"G27_batched_8160_128_128_b4",  8160,  128,  128, 4, true},
  {"G28_wide_8160_512_128",        8160,  512,  128, 1, true},
  {"G29_batched_32640_128_64_b2", 32640,  128,   64, 2, true},
  {"G30_wide_32640_256_64",       32640,  256,   64, 1, true},
  {"G31_qkv128_9216_384",          9216,  384,  128, 1, true},
  {"G32_qkv128_8640_384",          8640,  384,  128, 1, true},
  {"G33_qkv128_b4",                9216,  384,  128, 4, false},
  {"G34_batched_640_64_256_b8",    640,   64,   256, 8, true},
  {"G35_widediag_640_512_2048",    640,  512,  2048, 1, true},
  // --- 已合并的 P8-b 对照（N=32 家族）：split 原形 vs 现在出货的 wide 形 ---
  {"G36_n32split_8160_32_128_b4",  8160,   32,   128, 4, true},
  {"G37_n32wide_8160_128_512",     8160,  128,   512, 1, true},
  {"G38_f16_640_256_64_b8",        640,   256,    64, 8, true},
  {"G39_f16wide_640_2048_512",     640,  2048,   512, 1, true},
  {"G40_f16_2040_32_128_b8",      2040,    32,   128, 8, true},
  {"G41_f16wide_2040_256_1024",   2040,   256,  1024, 1, true},
  // --- window_block 四腿在未测 M 档（军规 37：M 成轴）---
  {"G42_wb_136640",              136640,   96,    32, 1, true},
  {"G43_wb_134400",              134400,   96,    32, 1, true},
  {"G44_wb_132736",              132736,   96,    32, 1, true},
  {"G45_wb_534336",              534336,   96,    32, 1, true},
  // --- 缺的锚点 ---
  {"G46_anchor_130560_128_32",   130560,  128,    32, 1, true},
  {"G47_stem_522240_32_128",     522240,   32,   128, 1, true},
  {"G48_qkv64_35712_192",         35712,  192,    64, 1, true},
  {"G49_res_32640_64_64",         32640,   64,    64, 1, true},
  {"G50_ga_legs",                   192,  192,    32, 32, true},
  {"G51_wa_legs",                     64,   64,    32, 320, false},
};
// WB 四腿 / GA 两条 / WA 两条：这些组额外测同 M 的其余腿
static std::vector<std::pair<int,int>> extra_legs(int g) {
    if (g >= 42 && g <= 45) return {{64,32},{32,64},{32,32}};
    if (g == 50) return {{32,192}};
    if (g == 51) return {{32,64}};
    return {};
}

int main(int argc, char** argv) {
    const int grp = getenv("SRP_GRP") ? atoi(getenv("SRP_GRP")) : 0;
    const bool pub = getenv("SRP_PUB") ? atoi(getenv("SRP_PUB")) != 0 : true;
    G_GRP = getenv("SRP_G") ? (size_t)atoi(getenv("SRP_G")) : 5;
    G_REP = getenv("SRP_R") ? (size_t)atoi(getenv("SRP_R")) : 15;
    if (grp < 0 || grp >= (int)GROUPS.size()) { printf("bad SRP_GRP\n"); return 1; }
    Grp G = GROUPS[grp];
    queue q(gpu_selector_v, property::queue::enable_profiling{});
    printf("device: %s\n", q.get_device().get_info<info::device::name>().c_str());
    printf("=== shape_roof_probe grp=%s M=%d N=%d K=%d b=%d pub=%d | groups=%zu reps=%zu gap=60ms nosink ===\n",
           G.name, G.M, G.N, G.K, G.batch, (int)pub, G_GRP, G_REP);
    std::vector<std::pair<int,int>> legs = {{G.N, G.K}};
    for (auto& e : extra_legs(grp)) legs.push_back(e);

    for (auto& LK : legs) {
        const int N = LK.first, K = LK.second;
        const int M = G.M, b = G.batch;
        const double gf = 2.0 * (double)M * N * K * (double)b / 1e9;
        const int Mp16 = ((M + 15) / 16) * 16;
        const int Mp8  = ((M + 127) / 128) * 128;
        // ---------------- f16 ----------------
        if ((N % 16 == 0) && (K % 16 == 0)) {
            half *dA = malloc_device<half>((size_t)b * Mp16 * K, q);
            half *dAp = malloc_device<half>((size_t)b * Mp16 * K, q);
            half *dB = malloc_device<half>((size_t)b * K * N, q);
            half *dBp = malloc_device<half>((size_t)b * K * N, q);
            float*dC = malloc_device<float>((size_t)b * Mp16 * N, q);
            q.memset(dA, 0x11, (size_t)b * Mp16 * K * 2);
            q.memset(dB, 0x22, (size_t)b * K * N * 2); q.wait();
            packdev::pack_a16_b(q, dA, dAp, Mp16, Mp16, K, b);
            packdev::pack_b16_b(q, dB, dBp, K, N, b);
            q.wait();
            Stat st = timeit([&]{ return f16v1::gemm_b(q, dAp, dBp, dC, Mp16, N, K, b); });
            csvrow(G.name, "f16", "gemm_b", M, N, K, b, st, gf, "raw int32/f32 C");
            if (pub) {
                Stat sp = timeit([&]{ return f16v1::gemm_b_pub_f16(q, dAp, dBp, (void*)dC, Mp16, Mp16,
                                                                   N, K, b, 4u, true, 0, (size_t)N, (unsigned)N, 0u); });
                csvrow(G.name, "f16", "gemm_b_pub_f16", M, N, K, b, sp, gf, "f16 out epi4 (half-round)");
            }
            sycl::free(dA,q); sycl::free(dAp,q); sycl::free(dB,q); sycl::free(dBp,q); sycl::free(dC,q);
        }
        // ---------------- int8 ----------------
        if ((N % 32 == 0) && (K % 32 == 0)) {
            std::vector<int8_t> hA((size_t)b * Mp8 * K), hAp((size_t)b * Mp8 * K);
            std::vector<int8_t> hB((size_t)b * N * K), hBp((size_t)b * N * K);
            for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((int)((i*37)%251) - 125);
            for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((int)((i*53)%251) - 125);
            for (int g = 0; g < b; ++g) {
                s8v8::pack_a(hA.data() + (size_t)g * Mp8 * K, hAp.data() + (size_t)g * Mp8 * K, Mp8, K);
                s8v8::pack_b(hB.data() + (size_t)g * N * K,  hBp.data() + (size_t)g * N * K, N, K);
            }
            int8_t*  dAp8 = malloc_device<int8_t>(hAp.size(), q);
            int8_t*  dBp8 = malloc_device<int8_t>(hBp.size(), q);
            int32_t* dC32 = malloc_device<int32_t>((size_t)b * Mp8 * N, q);
            q.memcpy(dAp8, hAp.data(), hAp.size()); q.memcpy(dBp8, hBp.data(), hBp.size()); q.wait();
            Stat st = (N % 64 == 0)
                ? timeit([&]{ return s8v8::gemm_b(q, dAp8, dBp8, dC32, Mp8, N, K, b); })
                : timeit([&]{ return s8v8::gemm32_b(q, dAp8, dBp8, dC32, Mp8, N, K, b); });
            csvrow(G.name, "int8", (N % 64 == 0) ? "gemm_b" : "gemm32_b", M, N, K, b, st, gf,
                   (N % 64 == 0) ? "raw int32 C BN64" : "raw int32 C BN32");
            if (pub && b == 1) {
                int8_t* dAp8b = dAp8; int8_t* dBp8b = dBp8;
                float* das = malloc_device<float>((size_t)Mp8, q);
                float* dbs = malloc_device<float>((size_t)N, q);
                half* dC16 = malloc_device<half>((size_t)Mp8 * N, q);
                std::vector<float> has(Mp8, 1.0f/127.f), hbs(N, 1.0f/127.f);
                q.memcpy(das, has.data(), has.size()*4); q.memcpy(dbs, hbs.data(), hbs.size()*4); q.wait();
                Stat sp = (N % 64 == 0)
                    ? timeit([&]{ return s8v8::gemm_b_pub(q, dAp8b, dBp8b, (void*)dC16, das, dbs, M, Mp8, N, K, 1,
                                                          (size_t)0, (unsigned)N, 0u, 0u, true, 4u); })
                    : timeit([&]{ return s8v8::gemm32_b_pub(q, dAp8b, dBp8b, (void*)dC16, das, dbs, M, Mp8, N, K, 1,
                                                            (size_t)0, (unsigned)N, 0u, 0u, true, 4u); });
                csvrow(G.name, "int8", (N % 64 == 0) ? "gemm_b_pub" : "gemm32_b_pub", M, N, K, b, sp, gf,
                       "f16 out epi4 requant folded");
                sycl::free(das,q); sycl::free(dbs,q); sycl::free(dC16,q);
            }
            sycl::free(dAp8,q); sycl::free(dBp8,q); sycl::free(dC32,q);
        }
    }
    printf("=== done grp=%s ===\n", G.name);
    return 0;
}
