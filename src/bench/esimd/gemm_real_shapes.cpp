// gemm_real_shapes.cpp — the offline merged-shape timing table (section 22 step 2,
// "measure before designing the scheduler"). Times the senior's v1 kernel at the
// REAL pipeline GEMM shapes (section 8's B1 table), padded to v1's tiling
// (M%128, N%64, K%32), printing device us — because at short K the GEMMs are
// likely MEMORY-bound (int32 C traffic), not compute-bound, and TOPS is then the
// wrong lens: us vs the coopmat ledger is the decision number.
//
// Shape sources (notes section 8): l2 QKV 8160x96x64, l3 32640x96x64, l4 130560x96x64,
// l0 QKV 192x96x1024, attnV x32x64, outproj x32x128, FFN expand x128x32, FFN project
// x32x128. Padded to v1: N 96->128, 32->64; M 8160->8192, 192->256.
// The pad waste is itself a finding: it is what a BN=32 variant would recover.
#include "../sycl/gemm_s8_v1_kernel.hpp"
#include <cstdio>
#include <vector>
#include <array>

using namespace sycl;
namespace es = s8v1;

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

    // {label, M, N, K} — padded where v1's tiling demands
    struct Cfg { const char* label; int M, N, K; };
    std::vector<Cfg> cfgs = {
        {"l2 QKV      ",  8192, 128,   64},
        {"l3 QKV      ", 32640, 128,   64},
        {"l4 QKV      ",130560, 128,   64},
        {"l0 QKV K1024",   256, 128, 1024},
        {"l4 attnV N32",130560,  64,   64},
        {"l4 outproj  ",130560,  64,  128},
        {"l4 FFNexp   ",130560, 128,   32},
        {"l4 FFNproj  ",130560,  64,  128},
        {"wide ref    ",  4096,4096, 4096},
    };
    std::printf("%-14s %8s %5s %5s  %10s %8s  %10s\n",
                "shape","M","N","K","us","TOPS","C-bytes-MB");
    for (auto& c : cfgs) {
        int M=c.M, N=c.N, K=c.K;
        std::vector<int8_t> hA((size_t)M*K), hB((size_t)K*N), hAp((size_t)M*K), hBp((size_t)K*N);
        for (size_t i=0;i<hA.size();++i) hA[i]=(int8_t)((i*7+3)%201-100);
        for (size_t i=0;i<hB.size();++i) hB[i]=(int8_t)((i*11+5)%181-90);
        es::pack_a(hA.data(),hAp.data(),M,K); es::pack_b(hB.data(),hBp.data(),K,N);
        int8_t* dA=malloc_device<int8_t>(hAp.size(),q), *dB=malloc_device<int8_t>(hBp.size(),q);
        int32_t* dC=malloc_device<int32_t>((size_t)M*N,q);
        q.memcpy(dA,hAp.data(),hAp.size()); q.memcpy(dB,hBp.data(),hBp.size()).wait();
        es::gemm_s8(q,dA,dB,dC,M,N,K).wait();
        double best=1e18;
        for(int r=0;r<7;++r){ event e=es::gemm_s8(q,dA,dB,dC,M,N,K); e.wait(); double us=dev_ms(e); if(us<best)best=us; }
        double tops = 2.0*M*N*K/(best*1e-6)/1e12;
        double cbytes = (double)M*N*4/1e6;
        std::printf("%-14s %8d %5d %5d  %10.1f %8.1f  %10.1f\n",
                    c.label, M, N, K, best, tops, cbytes);
        free(dA,q); free(dB,q); free(dC,q);
    }
    std::printf("REALSHAPES_DONE\n");
    return 0;
}
