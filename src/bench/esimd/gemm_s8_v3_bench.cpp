// gemm_s8_v3_bench.cpp — v3 (v1 main loop + v2 fused-requantize epilogue, BN=64 whole
// row in-group) checked against v2's OWN golden formula, then timed at the real
// N=64-padded shapes (section 8: attnV/outproj/FFNproj, N=32 padded to 64).
//
// Golden = the exact arithmetic v2's main() used (esimd_gemm_s8_v2.cpp:196-211):
//   fp[n] = (float)(int32 acc) * col_scale[n];  rmax = max|fp|;  ns = rmax/127;
//   want = clip(nearbyint(fp/ns), -127, 127).  Compared as int8 (exact) + scale.
// v2 PASSed this at 9216x128x128; v3 must PASS it at N=64 shapes with v1's faster loop.
#include "../sycl/gemm_s8_v3_kernel.hpp"
#include <cstdio>
#include <vector>
#include <array>
#include <cmath>
#include <algorithm>

using namespace sycl;
namespace es = s8v3;

static double dev_ms(event& e) {
    auto s = e.get_profiling_info<info::event_profiling::command_start>();
    auto t = e.get_profiling_info<info::event_profiling::command_end>();
    return (double)(t - s) / 1e3;   // us
}

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);
    device dev;
    for (auto& dd : device::get_devices(info::device_type::gpu))
        if (dd.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = dd; break; }
    queue q(dev, property::queue::enable_profiling{});
    std::printf("device: %s\n", dev.get_info<info::device::name>().c_str());

    auto run = [&](int M, int N, int K, const char* label) -> bool {
        std::vector<int8_t> hA((size_t)M*K), hB((size_t)K*N), hAp((size_t)M*K), hBp((size_t)K*N);
        std::vector<float> col_scale(N);
        for (int n=0;n<N;++n) col_scale[n]=0.001f*(n%37+1);
        for (size_t i=0;i<hA.size();++i) hA[i]=(int8_t)((i*7+3)%201-100);
        for (size_t i=0;i<hB.size();++i) hB[i]=(int8_t)((i*11+5)%181-90);
        es::pack_a(hA.data(),hAp.data(),M,K); es::pack_b(hB.data(),hBp.data(),K,N);
        int8_t* dA=malloc_device<int8_t>(hAp.size(),q), *dB=malloc_device<int8_t>(hBp.size(),q);
        float* dcs=malloc_device<float>(N,q);
        int8_t* dC8=malloc_device<int8_t>((size_t)M*N,q);
        float* dns=malloc_device<float>(M,q);
        q.memcpy(dA,hAp.data(),hAp.size()); q.memcpy(dB,hBp.data(),hBp.size());
        q.memcpy(dcs,col_scale.data(),N*sizeof(float)).wait();
        es::gemm_s8(q,dA,dB,dcs,dC8,dns,M,N,K).wait();
        std::vector<int8_t> hC8((size_t)M*N); std::vector<float> hns(M);
        q.memcpy(hC8.data(),dC8,hC8.size()); q.memcpy(hns.data(),dns,M*sizeof(float)).wait();
        long long bad=0; int shown=0; std::vector<float> fp(N);
        for (int m=0;m<M;++m) {
            float rmax=0.f;
            for (int n=0;n<N;++n) {
                int32_t acc=0;
                for (int k=0;k<K;++k) acc+=(int32_t)hA[(size_t)m*K+k]*hB[(size_t)k*N+n];
                fp[n]=(float)acc*col_scale[n];
                if (std::fabs(fp[n])>rmax) rmax=std::fabs(fp[n]);
            }
            float ns=rmax/127.0f;
            if (std::fabs(hns[m]-ns)>1e-4f*(ns+1.f)) { if(shown<3) std::printf("  scale m=%d got %.6f want %.6f\n",m,hns[m],ns); ++shown; ++bad; }
            for (int n=0;n<N;++n) {
                int8_t want=(int8_t)std::max(-127,std::min(127,(int)std::nearbyint(fp[n]/ns)));
                if (hC8[(size_t)m*N+n]!=want) { if(bad<3) std::printf("  out (%d,%d): got %d want %d\n",m,n,(int)hC8[(size_t)m*N+n],(int)want); ++bad; }
            }
        }
        // timing
        double best=1e18;
        for (int r=0;r<7;++r){ event e=es::gemm_s8(q,dA,dB,dcs,dC8,dns,M,N,K); e.wait(); double us=dev_ms(e); if(us<best)best=us; }
        double tops=2.0*M*N*K/(best*1e-6)/1e12;
        std::printf("%-16s %7dx%3dx%4d: %s (%lld/%lld wrong, %d scale)  %8.1f us  %5.1f TOPS\n",
                    label,M,N,K,bad?"FAIL":"PASS",bad,(long long)M*N,shown,best,tops);
        free(dA,q);free(dB,q);free(dcs,q);free(dC8,q);free(dns,q);
        return bad==0;
    };

    bool all=true;
    all &= run(256,64,64,"small");
    all &= run(8192,64,64,"l2 attnV");
    all &= run(32640,64,64,"l3 attnV");
    all &= run(130560,64,64,"l4 attnV");
    all &= run(130560,64,128,"l4 outproj");
    all &= run(130560,64,512,"deep K");
    std::printf("V3 %s\n", all?"ALL-PASS":"FAILURES");
    return all?0:1;
}
