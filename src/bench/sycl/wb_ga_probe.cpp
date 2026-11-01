// wb_ga_probe.cpp -- 诊断铲（只测不改）：把 shipped 图区里 window_block(10) 与
// global_attention(8) 这两族按 plan 实参**单独启动**，量 GPU/ wall 时间 + 内部分相。
// 不动 shipped 三源；只 include 它们的核头。untracked，不 commit。
//
// plan 实参（图区 5308..6643，见 E:\DSH\s6\wb_ga_ops.csv）：
//   WINDOW_BLOCK  plain flags=4352 (epi1|narrow) x7 + flags=0 (f32-out) x1 -> wbv4::launch_v4full
//                 pool  flags=0x800000  8160w 544x960 a120 p0   -> wbv4ph::launch_v4ph(pooling)
//                 head  flags=0x1000000 8349w 544x960 a121 p4|4 -> wbv4ph::launch_v4ph(head)
//                 windows/H/Wd/across/pad：2040/272/480/60/0 | 2135/…/61/0x40004 |
//                                            2074/…/61/0x4 | 2100/…/60/0x40000  （各 2 发）
//   GLOBAL_ATTENTION x8 全同：rows=192 tokens=192 heads=32
//     腿（libxmx_sycl.cpp:3986-4022，NR_GA_TILE/NR_GA_MERGE 默认 ON）：
//     pack_a16_b Q -> pack_b16_t_b K -> f16v1::gemm_b scores -> smax::vit_softmax_tiled
//     -> pack_b16_b V -> f16v1::gemm_b_merge_scale attnV(+merge fold)
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
#include "gemm_s8_v8_kernel.hpp"        // f16v1 依赖 s8v8（照 bench_v4full.cpp:27-28 的次序）
#include "gemm_f16_v1_kernel.hpp"
#include "window_block_v4.hpp"
#include "window_block_v4ph.hpp"
#include "pack_device.hpp"
#include "softmax_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ---------------------------------------------------------------- harness（照 s6b_att.cpp:623-732 的口径）
struct Stat { double msm = 0, msM = 0, msX = 0, med = 0; size_t ng = 0; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size()/2]; st.gms = gmin; return st;
}
// 单发：直接取该 kernel event 的 GPU 时间
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
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
// 多发链：两个 barrier 夹逼（§36 的仪器坑：per-launch event 对这些 shipped 核返回 0）
static Stat timeit_bracket(queue& q, std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
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
static Stat timeit_wall(std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            auto c0 = std::chrono::steady_clock::now();
            f();
            auto c1 = std::chrono::steady_clock::now();
            double ms = std::chrono::duration<double,std::milli>(c1-c0).count();
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
static void csvrow(const char* sect, const char* sh, const char* leg, const Stat& st, double gflop, const char* extra) {
    double tops = gflop > 0 ? gflop / st.msM * 1e3 : 0.0;      // GFLOP/ms = TOPS
    printf("CSVROW;%s;%s;%s;%.4f;%.4f;%.4f;%.4f;%.6f;%.4f;%s;groups=[%s]\n",
           sect, sh, leg, st.msm, st.msM, st.msX, st.med, gflop, tops, extra ? extra : "", gmfmt(st));
    fflush(stdout);
}
static void host_pack_b(const half* B, half* Bp, int K, int N){ f16v1::pack_b(B, Bp, K, N); }

// ---------------------------------------------------------------- smaxx: 诊断用**局部副本**
// 与 softmax_kernel.hpp:214-257 的 vit_softmax_tiled 逐字同算式，只是外面套 nd_range 把
// work-group 宽度钉死（=> 强制 IGC 的 SIMD 宽度），用来测"宽度阶梯"。
// 不动 shipped 头；只在 bench 里存在。数值不校验（纯计时），访存模式与 shipped 一致。
namespace smaxx {
template <int SG>
static auto tiled_sg(const float* src, sycl::half* Ap, float* recip, unsigned nrows,
                     unsigned tokens, unsigned stride) {
    return [=](nd_item<1> it) {
        unsigned r = (unsigned)it.get_global_linear_id();   // nd_item 只有 get_global_linear_id（没有 get_id/get_linear_id）
        if (r >= nrows) return;
        const float* row = src + (size_t)r * stride;
        unsigned blocks = (tokens + 63u) / 64u;
        float zero = smax::vit_weight(0.0f), total = 0.0f;
        for (unsigned b = 0; b < blocks; ++b) {
            float column[8];
            for (unsigned c = 0; c < 8u; ++c) {
                float pair[4];
                for (unsigned j = 0; j < 4u; ++j) {
                    unsigned k0 = b * 64u + c + 16u * j, k1 = k0 + 8u;
                    float w0 = k0 < tokens ? smax::vit_weight(row[k0]) : zero;
                    float w1 = k1 < tokens ? smax::vit_weight(row[k1]) : zero;
                    pair[j] = ctree::cr_hadd(w0, w1);
                }
                column[c] = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(pair[0], pair[1]), pair[2]), pair[3]);
            }
            float even = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[0], column[2]), column[4]), column[6]);
            float odd  = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[1], column[3]), column[5]), column[7]);
            total = ctree::cr_hadd(total, ctree::cr_hadd(even, odd));
        }
        unsigned padding = blocks * 64u - tokens;
        if (padding > 0u) total = ctree::cr_hadd(total, -ctree::cr_hmul(zero, (float)padding));
        recip[r] = qr_half_round(sycl::ext::intel::math::fdiv_rn(1.0f, total));
        unsigned rows_ = stride;
        unsigned h = r / rows_, srow = r % rows_;
        unsigned tr = srow / 16u, strip = (srow % 16u) / 8u, il = srow % 8u;
        unsigned kb_n = stride / 16u;
        size_t per = (size_t)(stride / 16u) * kb_n * 2u * 128u;
        sycl::half* Apb = Ap + (size_t)h * per;
        for (unsigned k = 0; k < stride; ++k) {
            sycl::half v = sycl::half(k < tokens ? qr_e4m3(smax::vit_weight(row[k])) : 0.0f);
            unsigned kc = k / 16u, k16 = k % 16u;
            Apb[((size_t)(tr * kb_n + kc) * 2u + strip) * 128u + il * 16u + k16] = v;
        }
    };
}
template <int SG>
static event launch_sg(queue& q, const float* src, half* Ap, float* recip,
                       unsigned nrows, unsigned tokens, unsigned stride) {
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)nrows), range((size_t)SG)),
                       tiled_sg<SG>(src, Ap, recip, nrows, tokens, stride));
    });
}
} // namespace smaxx

// ---------------------------------------------------------------- main
int main(int argc, char** argv) {
    const char* only = (argc > 1) ? argv[1] : "";     // "wb" / "ga" / "" = 全部
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    queue q(dev, property::queue::enable_profiling{});
    printf("device=%s\n", dev.get_info<info::device::name>().c_str());

    const unsigned C = 32u, NH = 96u, TOK = 64u;
    // ---------------- WB 侧缓冲（按帧上最大形状分配：544x960 图面）
    const unsigned big_h = 544, big_w = 960;
    const size_t img_elems = (size_t)big_h * big_w * C;
    std::mt19937 rng(11);
    std::uniform_real_distribution<float> df(-6.f, 6.f);
    std::vector<float> hImg(img_elems);
    for (auto& x : hImg) x = df(rng);
    std::vector<half> wq((size_t)C*NH), wp((size_t)C*C), wh((size_t)C*16);
    for (auto& x : wq) x = half(df(rng));
    for (auto& x : wp) x = half(df(rng));
    for (auto& x : wh) x = half(df(rng));
    std::vector<half> wqpk((size_t)C*NH), wppk((size_t)C*C), whpk((size_t)C*16);
    host_pack_b(wq.data(), wqpk.data(), (int)C, (int)NH);
    host_pack_b(wp.data(), wppk.data(), (int)C, (int)C);
    host_pack_b(wh.data(), whpk.data(), (int)C, 16);
    std::vector<float> bias((size_t)64*64); for (auto& x : bias) x = df(rng)*0.1f;
    std::vector<float> cosv(C); for (auto& x : cosv) x = df(rng)*0.2f;
    float qs[1] = {0.125f};

    float*   dImg  = malloc_device<float>(hImg.size(), q);
    half*    dWq   = malloc_device<half>(wqpk.size(), q);
    half*    dWp   = malloc_device<half>(wppk.size(), q);
    half*    dWh   = malloc_device<half>(whpk.size(), q);
    float*   dBias = malloc_device<float>(bias.size()*4, q);
    float*   dCos  = malloc_device<float>(C*4, q);
    float*   dQs   = malloc_device<float>(4, q);
    // Tgt：narrow 面 (h*w*C halves) 与 f32 面 (h*w*C floats) 都装得下；head 用 h*w*4 floats
    half*    dTgt  = malloc_device<half>(img_elems*2*2, q);
    half*    dPl   = malloc_device<half>((size_t)(big_h/2)*(big_w/2)*C, q);
    q.memcpy(dImg, hImg.data(), hImg.size()*4).wait();
    q.memcpy(dWq,  wqpk.data(), wqpk.size()*2).wait();
    q.memcpy(dWp,  wppk.data(), wppk.size()*2).wait();
    q.memcpy(dWh,  whpk.data(), whpk.size()*2).wait();
    q.memcpy(dBias, bias.data(), bias.size()*4).wait();
    q.memcpy(dCos, cosv.data(), C*4).wait();
    q.memcpy(dQs, qs, 4).wait();
    q.memset(dTgt, 0, img_elems*2*2).wait();
    q.memset(dPl, 0, (size_t)(big_h/2)*(big_w/2)*C*2).wait();

    struct S { const char* n; unsigned w,h,wd,ac,pt,pl,epi; int narrow; int pool; int head; };
    // flags 4352 -> epi=1 narrow=1 ; flags 0 -> epi=0 narrow=0 ; pool/head -> 由 flag 位定
    std::vector<S> shapes = {
        {"wb2040_f4352", 2040,272,480,60,0,0, 1u,1,0,0},
        {"wb2135_f4352", 2135,272,480,61,4,4, 1u,1,0,0},
        {"wb2074_f4352", 2074,272,480,61,0,4, 1u,1,0,0},
        {"wb2100_f4352", 2100,272,480,60,4,0, 1u,1,0,0},
        {"wb2100_f0",    2100,272,480,60,4,0, 0u,0,0,0},   // plan 5329：f32-out
        {"wb8160_POOL",  8160,544,960,120,0,0, 0u,0,1,0},
        {"wb8349_HEAD",  8349,544,960,121,4,4, 0u,0,0,1},
    };
    const double FLOP_PER_WIN = 2.0 * 524288.0;   // 4 条 gemm 腿（dpas 计数交叉核对见 wbga.md）
    const double FLOP_HEAD_EXTRA = 2.0 * 32768.0; // head GEMM: 64x16x32

    if (!*only || !strcmp(only, "wb")) {
      printf("=== WB: 单发夹逼（v4full / v4ph，plan 实参）===\n");
      for (auto& sh : shapes) {
        double gf = sh.w * FLOP_PER_WIN / 1e9 + (sh.head ? sh.w * FLOP_HEAD_EXTRA / 1e9 : 0.0);
        char note[128]; snprintf(note, sizeof note, "w=%u %ux%u a%u p%u|%u epi=%u narrow=%d pool=%d head=%d route=%s",
            sh.w, sh.h, sh.wd, sh.ac, sh.pt, sh.pl, sh.epi, sh.narrow, sh.pool, sh.head,
            (sh.pool||sh.head) ? "v4ph" : "v4full");
        auto call = [&](unsigned st)->event {
            if (sh.pool || sh.head)
                return wbv4ph::launch_v4ph(q, dImg, false, dWq, dWp, dTgt, (float*)dTgt,
                                           dBias, dCos, dQs, sh.w, sh.h, sh.wd, sh.ac, sh.pt, sh.pl,
                                           sh.epi, sh.narrow!=0, st, nullptr,
                                           sh.pool!=0, sh.head!=0, dPl, dWh, nullptr, nullptr, nullptr);
            return wbv4::launch_v4full(q, dImg, false, dWq, dWp,
                                       sh.narrow ? dTgt : nullptr, sh.narrow ? nullptr : (float*)dTgt,
                                       dBias, dCos, dQs, sh.w, sh.h, sh.wd, sh.ac, sh.pt, sh.pl,
                                       sh.epi, sh.narrow!=0, st, nullptr);
        };
        Stat g = timeit([&]{ return call(0u); });
        csvrow("WB_price", sh.n, "FULL", g, gf, note);
        Stat wl = timeit_wall([&]{ call(0u).wait(); });
        csvrow("WB_price", sh.n, "FULL_wall_submit_drained", wl, gf, "wall incl host submit+wait");
      }

      // ---- 分相阶梯（纯 stop，无 dump 出口；shipped 核只有 10/5/6/8/9/0 这六个出口，
      //      101/102/103 是 bench_v4full.cpp 自己加的，shipped 里没有）
      //      军规 20：只看 cum 形，<0.05ms 的单相绝对值不作裁决。
      printf("=== WB: stop_stage 阶梯（cum；纯 stop，无 dump）===\n");
      const char* sn[] = {"QKV(10)","scores(5)","probs(6)","attend(8)","proj(9)","FULL(0)"};
      const unsigned sv[] = {10u,5u,6u,8u,9u,0u};
      for (auto& sh : shapes) {
        if (strcmp(sh.n,"wb2040_f4352") && strcmp(sh.n,"wb8160_POOL") && strcmp(sh.n,"wb8349_HEAD")) continue;
        auto call = [&](unsigned st)->event {
            if (sh.pool || sh.head)
                return wbv4ph::launch_v4ph(q, dImg, false, dWq, dWp, dTgt, (float*)dTgt,
                                           dBias, dCos, dQs, sh.w, sh.h, sh.wd, sh.ac, sh.pt, sh.pl,
                                           sh.epi, sh.narrow!=0, st, nullptr,
                                           sh.pool!=0, sh.head!=0, dPl, dWh, nullptr, nullptr, nullptr);
            return wbv4::launch_v4full(q, dImg, false, dWq, dWp,
                                       sh.narrow ? dTgt : nullptr, sh.narrow ? nullptr : (float*)dTgt,
                                       dBias, dCos, dQs, sh.w, sh.h, sh.wd, sh.ac, sh.pt, sh.pl,
                                       sh.epi, sh.narrow!=0, st, nullptr);
        };
        std::vector<Stat> cum;
        for (int i = 0; i < 6; ++i) { Stat st = timeit([&]{ return call(sv[i]); }); cum.push_back(st);
            char nb[64]; snprintf(nb,sizeof nb,"cum_stop=%u",sv[i]);
            csvrow("WB_ladder", sh.n, sn[i], st, 0.0, nb); }
        printf("  LADDER %s: %s\n", sh.n, "QKV | scores | probs | attend | proj | FULL");
        printf("         msM:");
        for (auto& st : cum) printf(" %.4f", st.msM);
        printf("\n         delta:");
        for (size_t i = 0; i < cum.size(); ++i) printf(" %.4f", i ? cum[i].msM - cum[i-1].msM : cum[i].msM);
        printf("\n");
      }
    }

    if (!*only || !strcmp(only, "roof")) {
      // ---- 屋顶-by-形状：同引擎、同进程、宽 M=130560、batch=1，f16 与 int8 各扫 N/K 阶梯。
      //      以后任何"离屋顶几倍"必须先查这张表（int8 的 22.6 不是通用屋顶）。
      printf("=== ROOF: f16v1::gemm_b / s8v8::gemm_b 宽 M=130560，N/K 阶梯 ===\n");
      const int M = 130560, Mp = 130560;
      struct RS { const char* n; int N; int K; };
      std::vector<RS> rs = {
        {"N32_K32",32,32}, {"N32_K64",32,64}, {"N32_K128",32,128}, {"N32_K192",32,192}, {"N32_K384",32,384},
        {"N64_K32",64,32}, {"N64_K64",64,64}, {"N64_K128",64,128}, {"N64_K192",64,192}, {"N64_K384",64,384},
        {"N96_K32",96,32}, {"N96_K64",96,64}, {"N96_K128",96,128}, {"N96_K384",96,384},
        {"N192_K32",192,32}, {"N192_K128",192,128}, {"N192_K192",192,192}, {"N384_K128",384,128} };
      for (auto& r : rs) {
        half* dAraw = malloc_device<half>((size_t)Mp*r.K, q);
        half* dApk  = malloc_device<half>((size_t)Mp*r.K, q);
        half* dBraw = malloc_device<half>((size_t)r.K*r.N, q);
        half* dBpk  = malloc_device<half>((size_t)r.K*r.N, q);
        float* dC   = malloc_device<float>((size_t)Mp*r.N, q);
        q.memset(dAraw, 0x11, (size_t)Mp*r.K*2);
        q.memset(dBraw, 0x22, (size_t)r.K*r.N*2); q.wait();
        packdev::pack_a16_b(q, dAraw, dApk, Mp, Mp, r.K, 1);
        packdev::pack_b16_b(q, dBraw, dBpk, r.K, r.N, 1);
        q.wait();
        Stat st = timeit([&]{ return f16v1::gemm_b(q, dApk, dBpk, dC, Mp, r.N, r.K, 1); });
        double gf = 2.0 * (double)Mp * r.N * r.K / 1e9;
        char nb[96]; snprintf(nb,sizeof nb,"M=%d N=%d K=%d batch=1 f16", Mp, r.N, r.K);
        csvrow("ROOF_f16", r.n, "gemm_b_wideM", st, gf, nb);
        sycl::free(dAraw, q); sycl::free(dApk, q); sycl::free(dBraw, q); sycl::free(dBpk, q); sycl::free(dC, q);
      }
      // int8 阶梯：s8v8 要求 N%64==0、K%32==0、M 补到 128 的倍数（130560 = 1020x128 ✓）
      {
        const int Mp8 = 130560;
        std::vector<RS> i8 = {
          {"N64_K32",64,32}, {"N64_K64",64,64}, {"N64_K128",64,128}, {"N64_K192",64,192},
          {"N64_K256",64,256}, {"N64_K384",64,384},
          {"N128_K32",128,32}, {"N128_K128",128,128}, {"N128_K384",128,384},
          {"N192_K32",192,32}, {"N192_K128",192,128}, {"N384_K128",384,128} };
        for (auto& r : i8) {
          std::vector<int8_t> hA((size_t)Mp8*r.K), hB((size_t)r.N*r.K), hAp((size_t)Mp8*r.K), hBp((size_t)r.N*r.K);
          for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((int)((i*37)%251) - 125);
          for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((int)((i*53)%251) - 125);
          s8v8::pack_a(hA.data(), hAp.data(), Mp8, r.K);
          s8v8::pack_b(hB.data(), hBp.data(), r.N, r.K);
          int8_t*  dAp8 = malloc_device<int8_t>(hAp.size(), q);
          int8_t*  dBp8 = malloc_device<int8_t>(hBp.size(), q);
          int32_t* dC32 = malloc_device<int32_t>((size_t)Mp8*r.N, q);
          q.memcpy(dAp8, hAp.data(), hAp.size()); q.memcpy(dBp8, hBp.data(), hBp.size()); q.wait();
          Stat st = timeit([&]{ return s8v8::gemm_b(q, dAp8, dBp8, dC32, Mp8, r.N, r.K, 1); });
          double gf = 2.0 * (double)Mp8 * r.N * r.K / 1e9;
          char nb[96]; snprintf(nb,sizeof nb,"M=%d N=%d K=%d batch=1 int8", Mp8, r.N, r.K);
          csvrow("ROOF_int8", r.n, "gemm_b_wideM", st, gf, nb);
          sycl::free(dAp8, q); sycl::free(dBp8, q); sycl::free(dC32, q);
        }
      }
    }

    if (!*only || !strcmp(only, "ga")) {
      // ---- GA：plan 实参 rows=192 tokens=192 heads=32，逐腿 + 累积阶梯
      printf("=== GA: 单发夹逼（6 腿链，plan 实参）===\n");
      // ★ 关键：rows/tokens/heads 走 **运行期** 取值（getenv），不让编译器把它们折成常量
      //   —— 否则 3 个 block 的求和循环与 192 次 normalize 会被全展开，实例化就 ≠ shipped dll
      //   （dll 里这三个是 recorder 的函数形参，运行期值）。这是 GA 停线的第一个候选解释。
      unsigned R   = (unsigned)(getenv("WBGA_R")   ? atoi(getenv("WBGA_R"))   : 192);
      unsigned TOKn= (unsigned)(getenv("WBGA_T")   ? atoi(getenv("WBGA_T"))   : 192);
      unsigned HD  = (unsigned)(getenv("WBGA_H")   ? atoi(getenv("WBGA_H"))   : 32);
      unsigned Mp  = ((R+15u)/16u)*16u, CH = HD*32u;
      printf("  GA runtime shape: rows=%u tokens=%u heads=%u (Mp=%u CH=%u)\n", R, TOKn, HD, Mp, CH);
      std::vector<half> hQ((size_t)HD*R*32), hK((size_t)HD*R*32), hV((size_t)HD*R*32);
      for (auto& x : hQ) x = half(df(rng)); for (auto& x : hK) x = half(df(rng)); for (auto& x : hV) x = half(df(rng));
      half *dQ = malloc_device<half>(hQ.size(), q), *dK = malloc_device<half>(hK.size(), q), *dV = malloc_device<half>(hV.size(), q);
      q.memcpy(dQ,hQ.data(),hQ.size()*2); q.memcpy(dK,hK.data(),hK.size()*2); q.memcpy(dV,hV.data(),hV.size()*2); q.wait();
      half *dAq = malloc_device<half>((size_t)HD*Mp*32, q), *dBk = malloc_device<half>((size_t)HD*32*R, q);
      half *dAp = malloc_device<half>((size_t)HD*Mp*R, q), *dBv = malloc_device<half>((size_t)HD*R*32, q);
      float *dSc = malloc_device<float>((size_t)HD*R*R, q), *dRec = malloc_device<float>((size_t)HD*R, q);
      half *dMerged = malloc_device<half>((size_t)R*CH, q);
      auto L1=[&]{ packdev::pack_a16_b(q, dQ, dAq, (int)R, (int)Mp, 32, (int)HD); };
      auto L2=[&]{ packdev::pack_b16_t_b(q, dK, dBk, 32, (int)R, (int)HD); };
      auto L3=[&]{ f16v1::gemm_b(q, dAq, dBk, dSc, (int)Mp, (int)R, 32, (int)HD).wait(); };
      auto L4=[&]{ q.parallel_for(sycl::range((size_t)HD*R), smax::vit_softmax_tiled()(dSc, dAp, dRec, HD*R, TOKn, R)).wait(); };
      auto L5=[&]{ packdev::pack_b16_b(q, dV, dBv, (int)R, 32, (int)HD); };
      auto L6=[&]{ f16v1::gemm_b_merge_scale(q, dAp, dBv, dMerged, dRec, (int)Mp, 32, (int)R, (int)HD).wait(); };
      double GF_ga = 2.0 * (double)HD*R*R*32 * 2.0 / 1e9;   // 两条 gemm 腿合计
      printf("-- 整链（GPU 夹逼 / wall）\n");
      Stat chain = timeit_bracket(q, [&]{ L1();L2();L3();L4();L5();L6(); });
      csvrow("GA_price","ga192_h32","CHAIN_6legs", chain, GF_ga, "rows=192 tokens=192 heads=32");
      Stat chainw = timeit_wall([&]{ L1();L2();L3();L4();L5();L6(); });
      csvrow("GA_price","ga192_h32","CHAIN_6legs_wall", chainw, GF_ga, "wall incl host submits");
      printf("-- 累积阶梯（L1..L6，GPU 夹逼）\n");
      std::vector<Stat> cum;
      cum.push_back(timeit_bracket(q,[&]{ L1(); }));                                   csvrow("GA_ladder","ga192_h32","cum_L1 packA_Q",cum.back(),0.0,"");
      cum.push_back(timeit_bracket(q,[&]{ L1();L2(); }));                              csvrow("GA_ladder","ga192_h32","cum_L2 +packB_K",cum.back(),0.0,"");
      cum.push_back(timeit_bracket(q,[&]{ L1();L2();L3(); }));                         csvrow("GA_ladder","ga192_h32","cum_L3 +gemm_scores",cum.back(),0.0,"");
      cum.push_back(timeit_bracket(q,[&]{ L1();L2();L3();L4(); }));                    csvrow("GA_ladder","ga192_h32","cum_L4 +softmax",cum.back(),0.0,"");
      cum.push_back(timeit_bracket(q,[&]{ L1();L2();L3();L4();L5(); }));               csvrow("GA_ladder","ga192_h32","cum_L5 +packB_V",cum.back(),0.0,"");
      cum.push_back(timeit_bracket(q,[&]{ L1();L2();L3();L4();L5();L6(); }));          csvrow("GA_ladder","ga192_h32","cum_L6 +gemm_attnV",cum.back(),0.0,"");
      printf("  cum msM:"); for (auto& s : cum) printf(" %.4f", s.msM); printf("\n  delta:");
      for (size_t i=0;i<cum.size();++i) printf(" %.4f", cum[i].msM-(i?cum[i-1].msM:0.0)); printf("\n");
      printf("-- 单腿（各自 GPU 夹逼：gemm 腿=单发 event；pack/softmax 腿=barrier 夹逼）\n");
      Stat g3 = timeit([&]{ return f16v1::gemm_b(q, dAq, dBk, dSc, (int)Mp, (int)R, 32, (int)HD); });
      csvrow("GA_leg","ga192_h32","only_gemm_scores", g3, 2.0*(double)HD*R*R*32/1e9, "M192 N192 K32 b32");
      Stat g6 = timeit([&]{ return f16v1::gemm_b_merge_scale(q, dAp, dBv, dMerged, dRec, (int)Mp, 32, (int)R, (int)HD); });
      csvrow("GA_leg","ga192_h32","only_gemm_attnV", g6, 2.0*(double)HD*R*32*R/1e9, "M192 N32 K192 b32");
      Stat p1 = timeit_bracket(q,[&]{ L1(); });  csvrow("GA_leg","ga192_h32","only_packA_Q", p1, 0.0, "393KB->393KB");
      Stat p2 = timeit_bracket(q,[&]{ L2(); });  csvrow("GA_leg","ga192_h32","only_packB_K", p2, 0.0, "");
      Stat p4 = timeit_bracket(q,[&]{ L4(); });  csvrow("GA_leg","ga192_h32","only_softmax", p4, 0.0, "4.72MB f32 in -> 2.36MB half out");
      Stat p5 = timeit_bracket(q,[&]{ L5(); });  csvrow("GA_leg","ga192_h32","only_packB_V", p5, 0.0, "");
      // 空腿基线：一次 barrier 夹逼里放 0 个 kernel = 仪器底噪
      Stat nil = timeit_bracket(q,[&]{ });       csvrow("GA_leg","ga192_h32","INSTRUMENT_FLOOR_empty_bracket", nil, 0.0, "底噪");
      // 逃生门对照：NR_GA_TILE=0 / NR_GA_MERGE=0 的 split 形（多两腿）
      half* dProbs = malloc_device<half>((size_t)HD*R*R, q);
      float* dCtx  = malloc_device<float>((size_t)HD*R*32, q);
      Stat split = timeit_bracket(q,[&]{
          L1(); L2();
          f16v1::gemm_b(q, dAq, dBk, dSc, (int)Mp, (int)R, 32, (int)HD).wait();
          q.parallel_for(sycl::range((size_t)HD*R), smax::vit_softmax_kernel()(dSc, dProbs, dRec, HD*R, TOKn, R)).wait();
          packdev::pack_a16_b(q, dProbs, dAp, (int)R, (int)Mp, (int)R, (int)HD);
          L5();
          f16v1::gemm_b(q, dAp, dBv, dCtx, (int)Mp, 32, (int)R, (int)HD).wait();
          q.parallel_for(sycl::range((size_t)R*CH), [=](item<1> it){
              unsigned index = (unsigned)it.get_id(0);
              unsigned c = index % CH, token = index / CH;
              size_t at = (size_t)(c/32u)*R + token;
              float value = qr_half_round(cr_mul(qr_half_round(dCtx[at*32u + (c%32u)]), dRec[at]));
              ((half*)dMerged)[index] = sycl::half(qr_e4m3(value));
          }).wait();
      });
      csvrow("GA_price","ga192_h32","CHAIN_split(GA_TILE=0,GA_MERGE=0)", split, GF_ga, "8 腿对照");
      q.wait();   // 不逐块 free：进程退出即回收（sycl::free 不接受多指针）
    }
    if (!*only || !strcmp(only, "smx")) {
      // ---- softmax 宽度阶梯（诊断：dll 实例 simd=8、探针实例 simd=16 => 2.3x 差）
      printf("=== SMX: vit_softmax_tiled 局部副本 + 强制 work-group 宽度（=SIMD 宽度）阶梯 ===\n");
      const unsigned R2 = 192, T2 = 192, H2 = 32;
      float*  dSc2  = malloc_device<float>((size_t)H2*R2*R2, q);
      half*   dAp2  = malloc_device<half>((size_t)H2*R2*R2, q);
      half*   dApB  = malloc_device<half>((size_t)H2*R2*R2, q);
      float*  dRc2  = malloc_device<float>((size_t)H2*R2, q);
      std::vector<float> hs((size_t)H2*R2*R2);
      for (size_t i = 0; i < hs.size(); ++i) hs[i] = (float)((int)((i*37)%201) - 100) * 0.5f;
      q.memcpy(dSc2, hs.data(), hs.size()*4).wait();
      q.memset(dAp2, 0, (size_t)H2*R2*R2*2); q.memset(dApB, 0, (size_t)H2*R2*R2*2); q.wait();
      // 先跑一次 shipped 版做参考，再跑 SG=8 对拍（证明副本不是另一套算式）
      q.parallel_for(sycl::range((size_t)H2*R2), smax::vit_softmax_tiled()(dSc2, dAp2, dRc2, H2*R2, T2, R2)).wait();
      Stat s8 = timeit([&]{ return smaxx::launch_sg<8>(q, dSc2, dApB, dRc2, H2*R2, T2, R2); });
      std::vector<half> a((size_t)H2*R2*R2), b((size_t)H2*R2*R2);
      q.memcpy(a.data(), dAp2, a.size()*2); q.memcpy(b.data(), dApB, b.size()*2); q.wait();
      size_t bad = 0; for (size_t i = 0; i < a.size(); ++i) if (std::memcmp(&a[i], &b[i], 2)) ++bad;
      printf("  副本 vs shipped 逐字节：mismatch=%zu / %zu  %s\n", bad, a.size(), bad? "BAD":"EXACT");
      csvrow("SMX_width","ga192_h32","shipped_vit_softmax_tiled(dll 同算式)",
             timeit([&]{ return q.parallel_for(sycl::range((size_t)H2*R2), smax::vit_softmax_tiled()(dSc2, dAp2, dRc2, H2*R2, T2, R2)); }),
             0.0, "range<1>，WG 宽度由 IGC 自选（dll 台账 simd=8）");
      csvrow("SMX_width","ga192_h32","copy_SG4",  timeit([&]{ return smaxx::launch_sg<4> (q, dSc2, dApB, dRc2, H2*R2, T2, R2); }), 0.0, "nd_range local=4");
      csvrow("SMX_width","ga192_h32","copy_SG8",  s8, 0.0, "nd_range local=8");
      csvrow("SMX_width","ga192_h32","copy_SG16", timeit([&]{ return smaxx::launch_sg<16>(q, dSc2, dApB, dRc2, H2*R2, T2, R2); }), 0.0, "nd_range local=16");
      csvrow("SMX_width","ga192_h32","copy_SG32", timeit([&]{ return smaxx::launch_sg<32>(q, dSc2, dApB, dRc2, H2*R2, T2, R2); }), 0.0, "nd_range local=32");
    }
    printf("DONE\n");
    return 0;
}
