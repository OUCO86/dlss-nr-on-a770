// knife2_probe.cpp -- 刀 2 第 2 步原型：P8-b 块对角 wide-merge 放宽到 N=64/128/256 + f16 侧。
// 不接图、不动 dll/金标。3 个代表站点（plan 实参），每进程一站点：
//   K2_SITE=0  int8 640x64x256 b8  (closure 217 族)  split(gemm_b_pub BN64) vs wide(Nw=512,Kw=2048)
//   K2_SITE=1  f16 2040x32x128 b8  (closure 131 族)  split(gemm_b_pub_f16 nb=8) vs wide(Nw=256,Kw=1024)
//   K2_SITE=2  f16 640x256x64 b8 epi2 (closure 215 族) split vs wide(Nw=2048,Kw=512)
// 协议：逐字节 diff=0（P8-b 先例）；成对单价 min-of-15x5、5 组、组间 60ms、GPU event、nosink（军规 19/35）；
// 每形状 >=10 独立进程取中位（§8.3：三站全在低可信清单）。
// 用法：K2_SITE=<0|1|2> [K2_G=5] [K2_R=15] knife2_probe.exe
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <functional>
#include <algorithm>
#include <random>
#include <thread>
#include <chrono>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
#include "publish_kernel.hpp"
using namespace sycl;

// ---- f16 block-diagonal wide B pack（刀 2 新面；gather_pack_b16_b 的 batch=1 宽形 + 块对角选组）----
// mirror of packdev::gather_pack_b16_b index map with K->Kw=K*b, N->Nw=N*b:
//   B_w[k,n] = Braw[ob + (n/N)*sb + (k%K)*ldb + (n%N)]  if k/K == n/N, else 0.
static void gather_pack_b16_diag_b(sycl::queue& q, const sycl::half* Braw, sycl::half* Bp,
                                   int K, int N, int ldb, size_t sb, size_t ob, int batch) {
    const int TS = 16;
    const int Kw = K * batch, Nw = N * batch;
    int kb_n = Kw / TS, tc_n = Nw / TS;
    size_t per = (size_t)kb_n * tc_n * 2 * 128;      // = Kw*Nw
    q.parallel_for(sycl::range(per), [=](sycl::item<1> it) {
        size_t d = it.get_id(0);
        int inner = (int)(d % 128); size_t blk = d / 128;
        int js = (int)(blk % 2); size_t blk2 = blk / 2;
        int tc = (int)(blk2 % (size_t)tc_n); int kc = (int)(blk2 / (size_t)tc_n);
        int kq = inner / 16; int rem = inner % 16;
        int jl = rem / 2, kpar = rem % 2;
        int k = kq * 2 + kpar;
        int kk = kc * TS + k;            // wide row (K axis)
        int nn = tc * TS + js * 8 + jl;  // wide col (N axis)
        int g = nn / N;
        Bp[d] = (kk / K == g) ? Braw[ob + (size_t)g * sb + (size_t)(kk % K) * ldb + (size_t)(nn % N)]
                              : sycl::half(0.0f);
    });
}

struct Stat { double msm=0, msM=0, msX=0, med=0; std::vector<double> gms; };
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
    Stat st; st.gms = gmin;
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end()); st.med = all[all.size()/2];
    return st;
}
// void-returning pack legs: WALL timing with a per-call queue drain (same min-of-15x5 /
// 5 groups / 60ms gap protocol) -- the exact bench_n32 precedent for pack_a pricing
// (tm([&]{ gather_pack_a_b_v ... }, 15)). Carries ~5-15us launch+drain bias, SAME on both
// forms (paired comparison unaffected); gemm legs stay GPU-event timed.
static sycl::queue* GQK = nullptr;
static Stat timeitv(std::function<void()> f, int gap_ms = 60) {
    f(); GQK->wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < G_GRP; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < G_REP; ++it) {
            auto t0 = std::chrono::steady_clock::now();
            f(); GQK->wait();
            double ms = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count();
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    Stat st; st.gms = gmin;
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end()); st.med = all[all.size()/2];
    return st;
}
static const char* gmfmt(const Stat& st) {
    static char buf[200]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 180; ++i) o += snprintf(buf+o, sizeof(buf)-o, "%.4f ", st.gms[i]);
    return buf;
}
static void csvrow(const char* site, const char* dt, const char* leg, const char* form,
                   int M, int N, int K, int b, const Stat& st, double gf, const char* note) {
    double tops = gf > 0 ? gf / st.msM * 1e3 : 0.0;
    printf("CSVROW;%s;%s;%s;%s;%d;%d;%d;%d;%.4f;%.4f;%.4f;%.4f;%.6f;%.4f;%s;groups=[%s]\n",
           site, dt, leg, form, M, N, K, b, st.msm, st.msM, st.msX, st.med, gf, tops, note ? note : "", gmfmt(st));
    fflush(stdout);
}

int main() {
    const int site = getenv("K2_SITE") ? atoi(getenv("K2_SITE")) : 0;
    G_GRP = getenv("K2_G") ? (size_t)atoi(getenv("K2_G")) : 5;
    G_REP = getenv("K2_R") ? (size_t)atoi(getenv("K2_R")) : 15;
    queue q(gpu_selector_v, property::queue::enable_profiling{});
    GQK = &q;
    printf("device: %s\n", q.get_device().get_info<info::device::name>().c_str());

    if (site == 0) {
        // int8 640x64x256 b8, plan form: lda=2048(=Kw) sa=256(=K) ldb=256(=K) sb=16384(=N*K)
        // sc=64 ldc=512 ss=0 epi1 narrow=1, B stored TRANSPOSED (N x K)
        const int M=640, N=64, K=256, b=8;
        const int Mp=((M+127)/128)*128, Nw=N*b, Kw=K*b;
        printf("=== K2 site0 int8 640x64x256b8 -> wide 640x512x2048 | groups=%zu reps=%zu gap=60ms nosink ===\n", G_GRP, G_REP);
        std::vector<int8_t> A((size_t)M*Kw), B((size_t)b*N*K);
        std::mt19937 rng(7); std::uniform_int_distribution<int> da(-127,127);
        for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
        std::vector<float> as((size_t)Mp), bs((size_t)Nw);
        std::uniform_real_distribution<float> ds(0.5f,2.f);
        for(auto&x:as)x=ds(rng); for(auto&x:bs)x=ds(rng);
        int8_t *dA=(int8_t*)malloc_device(A.size(),q),*dB=(int8_t*)malloc_device(B.size(),q);
        int8_t *dAp=(int8_t*)malloc_device((size_t)b*Mp*K,q),*dBp=(int8_t*)malloc_device((size_t)b*N*K,q);
        int8_t *dApW=(int8_t*)malloc_device((size_t)Mp*Kw,q),*dBpW=(int8_t*)malloc_device((size_t)Nw*Kw,q);
        float *das=(float*)malloc_device(as.size()*4,q),*dbs=(float*)malloc_device(bs.size()*4,q);
        half *dCs=(half*)malloc_device((size_t)Mp*Nw*2,q),*dCw=(half*)malloc_device((size_t)Mp*Nw*2,q);
        q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
        q.memcpy(das,as.data(),as.size()*4).wait(); q.memcpy(dbs,bs.data(),bs.size()*4).wait();
        // pack (frame pays pack_a; pack_b is cache-owned init-only -> priced separately, note it)
        packdev::gather_pack_a_b_v(q,dA,dAp,M,Mp,K,Kw,(size_t)K,b);
        packdev::gather_pack_b_b(q,dB,dBp,N,K,K,(size_t)N*K,b);
        packdev::gather_pack_a_b_v(q,dA,dApW,M,Mp,Kw,Kw,0,1);
        packdev::gather_pack_b_diag_b(q,dB,dBpW,N,K,K,(size_t)N*K,b);
        q.wait();
        double gf = 2.0*M*(double)Nw*Kw/1e9;   // same FLOPs both forms
        Stat s_pa = timeitv([&]{ packdev::gather_pack_a_b_v(q,dA,dAp,M,Mp,K,Kw,(size_t)K,b); });
        Stat s_gm = timeit([&]{ return s8v8::gemm_b_pub(q,dAp,dBp,(void*)dCs,das,dbs,M,Mp,N,K,b,64u,512u,0u,(unsigned)N,true,1u); });
        Stat w_pa = timeitv([&]{ packdev::gather_pack_a_b_v(q,dA,dApW,M,Mp,Kw,Kw,0,1); });
        Stat w_gm = timeit([&]{ return s8v8::gemm_b_pub(q,dApW,dBpW,(void*)dCw,das,dbs,M,Mp,Nw,Kw,1,(size_t)0,(unsigned)Nw,0u,0u,true,1u); });
        Stat i_pb = timeitv([&]{ packdev::gather_pack_b_b(q,dB,dBp,N,K,K,(size_t)N*K,b); });
        Stat i_pbw = timeitv([&]{ packdev::gather_pack_b_diag_b(q,dB,dBpW,N,K,K,(size_t)N*K,b); });
        csvrow("S0_i8_640x64x256b8","int8","pack_a","split",M,N,K,b,s_pa,gf,"frame leg");
        csvrow("S0_i8_640x64x256b8","int8","gemm_b_pub","split",M,N,K,b,s_gm,gf,"frame leg BN64 b=8");
        csvrow("S0_i8_640x64x256b8","int8","pack_a","wide",M,N,K,b,w_pa,gf,"frame leg");
        csvrow("S0_i8_640x64x256b8","int8","gemm_b_pub","wide",M,Nw,Kw,1,w_gm,gf,"frame leg Nw*Kw b=1");
        csvrow("S0_i8_640x64x256b8","int8","pack_b","split",M,N,K,b,i_pb,gf,"INIT ONLY (wcache)");
        csvrow("S0_i8_640x64x256b8","int8","pack_b_diag","wide",M,N,K,b,i_pbw,gf,"INIT ONLY (wcache)");
        printf("PAIR;%s;split_total=%.4f;wide_total=%.4f;ratio=%.3f\n","S0_i8_640x64x256b8",
               s_pa.msM+s_gm.msM, w_pa.msM+w_gm.msM, (s_pa.msM+s_gm.msM)/(w_pa.msM+w_gm.msM));
        // byte diff: split chain one deterministic pass vs wide pass
        s8v8::gemm_b_pub(q,dAp,dBp,(void*)dCs,das,dbs,M,Mp,N,K,b,64u,512u,0u,(unsigned)N,true,1u).wait();
        s8v8::gemm_b_pub(q,dApW,dBpW,(void*)dCw,das,dbs,M,Mp,Nw,Kw,1,(size_t)0,(unsigned)Nw,0u,0u,true,1u).wait();
        std::vector<half> hs((size_t)Mp*Nw), hw((size_t)Mp*Nw);
        q.memcpy(hs.data(),dCs,hs.size()*2).wait(); q.memcpy(hw.data(),dCw,hw.size()*2).wait();
        size_t wd=0;
        for(int r2=0;r2<M;++r2) for(int cw=0;cw<Nw;++cw){
            int g2=cw/N, col=cw%N;
            half a=hw[(size_t)r2*Nw+cw], bb_=hs[(size_t)g2*Mp*N+(size_t)r2*N+col];
            if(memcmp(&a,&bb_,2)){ if(wd<4) printf("WDIFF r=%d cw=%d wide=%.6g split=%.6g\n",r2,cw,(float)a,(float)bb_); wd++; }
        }
        printf("DIFF;%s;diff=%zu;cmp=%zu\n","S0_i8_640x64x256b8",wd,(size_t)M*Nw);
        free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(dApW,q);free(dBpW,q);
        free(das,q);free(dbs,q);free(dCs,q);free(dCw,q);
    } else if (site == 1 || site == 2) {
        // f16: site1 = 2040x32x128 b8 epi1 ; site2 = 640x256x64 b8 epi2
        const int M = site==1?2040:640, N = site==1?32:256, K = site==1?128:64, b=8;
        const unsigned epi = site==1?1u:2u;
        const int Mp=((M+15)/16)*16, Nw=N*b, Kw=K*b;
        printf("=== K2 site%d f16 %dx%dx%d b8 epi%u -> wide %dx%dx%d | groups=%zu reps=%zu gap=60ms nosink ===\n",
               site,M,N,K,epi,M,Nw,Kw,G_GRP,G_REP);
        std::vector<half> Ah((size_t)M*Kw), Bh((size_t)b*K*N);
        std::mt19937 rng(11); std::uniform_real_distribution<float> df(-1.f,1.f);
        for(auto&x:Ah)x=(half)df(rng); for(auto&x:Bh)x=(half)df(rng);
        half *dA=(half*)malloc_device(Ah.size()*2,q),*dB=(half*)malloc_device(Bh.size()*2,q);
        half *dAp=(half*)malloc_device((size_t)b*Mp*K*2,q),*dBp=(half*)malloc_device((size_t)b*K*N*2,q);
        half *dApW=(half*)malloc_device((size_t)Mp*Kw*2,q),*dBpW=(half*)malloc_device((size_t)Kw*Nw*2,q);
        half *dCs=(half*)malloc_device((size_t)Mp*Nw*2,q),*dCw=(half*)malloc_device((size_t)Mp*Nw*2,q);
        q.memcpy(dA,Ah.data(),Ah.size()*2).wait(); q.memcpy(dB,Bh.data(),Bh.size()*2).wait();
        // recorder split form: lda=Kw sa=K ldb=K sb=K*N sc=N ldc=N*b; fold pub (B5-2 default)
        packdev::gather_pack_a16_b(q,dA,dAp,M,Mp,K,Kw,(size_t)K,0u,b);
        packdev::gather_pack_b16_b(q,dB,dBp,K,N,K,(size_t)K*N,0u,b);
        packdev::gather_pack_a16_b(q,dA,dApW,M,Mp,Kw,Kw,0u,0u,1);
        gather_pack_b16_diag_b(q,dB,dBpW,K,N,K,(size_t)K*N,0u,b);
        q.wait();
        double gf = 2.0*M*(double)Nw*Kw/1e9;
        const char* nm = site==1?"S1_f16_2040x32x128b8":"S2_f16_640x256x64b8";
        Stat s_pa = timeitv([&]{ packdev::gather_pack_a16_b(q,dA,dAp,M,Mp,K,Kw,(size_t)K,0u,b); });
        Stat s_gm = timeit([&]{ return f16v1::gemm_b_pub_f16(q,dAp,dBp,(void*)dCs,M,Mp,N,K,b,epi,true,0u,(size_t)N,(unsigned)Nw,(unsigned)Kw); });
        Stat w_pa = timeitv([&]{ packdev::gather_pack_a16_b(q,dA,dApW,M,Mp,Kw,Kw,0u,0u,1); });
        Stat w_gm = timeit([&]{ return f16v1::gemm_b_pub_f16(q,dApW,dBpW,(void*)dCw,M,Mp,Nw,Kw,1,epi,true,0u,(size_t)0,(unsigned)Nw,(unsigned)Kw); });
        Stat i_pb = timeitv([&]{ packdev::gather_pack_b16_b(q,dB,dBp,K,N,K,(size_t)K*N,0u,b); });
        Stat i_pbw = timeitv([&]{ gather_pack_b16_diag_b(q,dB,dBpW,K,N,K,(size_t)K*N,0u,b); });
        csvrow(nm,"f16","pack_a","split",M,N,K,b,s_pa,gf,"frame leg");
        csvrow(nm,"f16","gemm_b_pub_f16","split",M,N,K,b,s_gm,gf,"frame leg fold-pub (B5-2 shipped)");
        csvrow(nm,"f16","pack_a","wide",M,N,K,b,w_pa,gf,"frame leg");
        csvrow(nm,"f16","gemm_b_pub_f16","wide",M,Nw,Kw,1,w_gm,gf,"frame leg Nw*Kw b=1");
        csvrow(nm,"f16","pack_b","split",M,N,K,b,i_pb,gf,"INIT ONLY (wcache)");
        csvrow(nm,"f16","pack_b_diag","wide",M,N,K,b,i_pbw,gf,"INIT ONLY (wcache, NEW face)");
        printf("PAIR;%s;split_total=%.4f;wide_total=%.4f;ratio=%.3f\n",nm,
               s_pa.msM+s_gm.msM, w_pa.msM+w_gm.msM, (s_pa.msM+s_gm.msM)/(w_pa.msM+w_gm.msM));
        // byte diff
        f16v1::gemm_b_pub_f16(q,dAp,dBp,(void*)dCs,M,Mp,N,K,b,epi,true,0u,(size_t)N,(unsigned)Nw,(unsigned)Kw).wait();
        f16v1::gemm_b_pub_f16(q,dApW,dBpW,(void*)dCw,M,Mp,Nw,Kw,1,epi,true,0u,(size_t)0,(unsigned)Nw,(unsigned)Kw).wait();
        std::vector<half> hs((size_t)Mp*Nw), hw((size_t)Mp*Nw);
        q.memcpy(hs.data(),dCs,hs.size()*2).wait(); q.memcpy(hw.data(),dCw,hw.size()*2).wait();
        size_t wd=0;
        for(int r2=0;r2<Mp;++r2) for(int cw=0;cw<Nw;++cw)
            if(memcmp(&hs[(size_t)r2*Nw+cw],&hw[(size_t)r2*Nw+cw],2)){
                if(wd<4) printf("WDIFF r=%d cw=%d split=%.6g wide=%.6g\n",r2,cw,(float)hs[(size_t)r2*Nw+cw],(float)hw[(size_t)r2*Nw+cw]);
                ++wd; }
        printf("DIFF;%s;diff=%zu;cmp=%zu\n",nm,wd,(size_t)Mp*Nw);
        free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(dApW,q);free(dBpW,q);free(dCs,q);free(dCw,q);
    } else { printf("bad K2_SITE\n"); return 1; }
    return 0;
}
