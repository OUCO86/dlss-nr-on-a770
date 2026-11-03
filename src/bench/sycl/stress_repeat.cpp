// stress_repeat.cpp -- the rule-46 instrument, in-repo and executable.
//
// WHAT IT MEASURES: self-reproducibility of a kernel launch. Inside ONE process we relaunch the
// same kernel N times, scrubbing the planes under test with the 0xA5 sentinel before every launch,
// and byte-compare every launch against launch 0. A single launch cannot separate a RACE from a
// BUG; N launches can:
//     identical bytes every launch  => deterministic (bad=0)
//     bytes change across launches  => an ordering/visibility failure inside the kernel (bad>0)
// and the sentinel separates the two failure shapes: a wrong byte that IS 0xA5 = the launch never
// wrote that slot; a wrong byte that is NOT 0xA5 = a real value from somewhere else (stale /
// other-row data) -- which is what the port core does (s6/knife2b.md #65: 4 of 200 launches at
// KN=1 LW=16, wrong rows all multiples of 16 = work-group band boundaries).
//
// THIS FILE IS THE NEGATIVE CONTROL (it MUST print bad=0, otherwise the instrument has no teeth):
// qr_launch_esimd / qr_kernel_rowthread -- one item per row, no SLM, no barrier, no cross-wave
// handoff, so nothing can race.
//
// THE OTHER ARMS live in their own bench TUs (the kernels are defined there, not in a header):
//   port core (POSITIVE control, expect bad>0):  PORT_STRESS=200   port_ffn_fused.exe
//   att half   (our kernel, B2's left leg):      S6B_ATT_REPEAT=200 s6b_att.exe
//   1a chain   (SHIPPED core, the exposure test): M_REPEAT=200      s6_ffn_block4.exe (C2_STAGE=1)
// tools/stress_repeat.ps1 drives the whole matrix with >= 60 s between processes (rule 47).
//
// ASCII only. Bench layer only: it touches no shipped source and no shipped artifact.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <vector>

#include "quantize_row_kernel.hpp"

int main(int argc, char** argv) {
    const int N = (argc > 1) ? atoi(argv[1]) : 200;
    const unsigned C = 64;
    const unsigned M = 32640;                 // the C=64 chain's token count (510 windows x 64)
    std::vector<sycl::half> hin((size_t)M * C);
    for (size_t i = 0; i < hin.size(); ++i) {
        uint32_t v = (uint32_t)(i * 2654435761u);
        int32_t  s = (int32_t)((v >> 3) % 2048) - 1024;          // [-1024, 1023]
        hin[i] = sycl::half((float)s / 4.0f);
    }

    sycl::device dev;
    for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
        if (d.get_backend() == sycl::backend::ext_oneapi_level_zero &&
            d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != sycl::backend::ext_oneapi_level_zero) { std::printf("no L0 Arc\n"); return 2; }
    sycl::queue q(dev, sycl::property::queue::enable_profiling{});
    std::printf("device: %ls\n", dev.get_info<sycl::info::device::name>().c_str());

    const size_t bIn = hin.size() * 2, bPk = (size_t)M * C, bSc = (size_t)M * 4;
    sycl::half* dIn = (sycl::half*)sycl::malloc_device(bIn, q);
    int8_t*     dPk = (int8_t*)sycl::malloc_device(bPk, q);
    float*      dSc = (float*)sycl::malloc_device(bSc, q);
    q.memcpy(dIn, hin.data(), bIn); q.wait();

    auto LAUNCH = [&]() {
        qr_launch_esimd(q, dev, dIn, (sycl::uint2*)dPk, dSc, M, C);
        q.wait();
    };
    std::vector<uint8_t> r0Pk(bPk), r0Sc(bSc), r1Pk(bPk), r1Sc(bSc);
    LAUNCH();
    q.memcpy(r0Pk.data(), dPk, bPk); q.memcpy(r0Sc.data(), dSc, bSc); q.wait();

    int nbad = 0, first_s = -1; size_t first_row = 0;
    for (int s = 1; s < N; ++s) {
        q.memset(dPk, 0xA5, bPk).wait();
        q.memset(dSc, 0xA5, bSc).wait();
        LAUNCH();
        q.memcpy(r1Pk.data(), dPk, bPk); q.memcpy(r1Sc.data(), dSc, bSc); q.wait();
        size_t dPkN = 0, dScN = 0, sent = 0;
        for (size_t i = 0; i < bPk; ++i) if (r1Pk[i] != r0Pk[i]) { if (!dPkN) first_row = i / (size_t)C; ++dPkN; }
        for (size_t i = 0; i < bSc; ++i) if (r1Sc[i] != r0Sc[i]) ++dScN;
        for (size_t i = 0; i + 3 < bSc; i += 4)
            if (r1Sc[i] == 0xA5 && r1Sc[i+1] == 0xA5 && r1Sc[i+2] == 0xA5 && r1Sc[i+3] == 0xA5) ++sent;
        if (dPkN || dScN) {
            ++nbad; if (first_s < 0) first_s = s;
            std::printf("STRESS s=%d dPk=%zu dSc=%zu unwritten_sentinels=%zu first_pk_row=%zu mod16=%d\n",
                        s, dPkN, dScN, sent, first_row, (int)(first_row % 16u));
            std::fflush(stdout);
        }
    }
    std::printf("STRESS SUMMARY CTRL qr_kernel_rowthread<%u> M=%u launches=%d bad=%d first_bad_s=%d "
                "(this arm MUST be bad=0 or the instrument has no teeth)\n", C, M, N, nbad, first_s);
    std::fflush(stdout);
    sycl::free(dIn, q); sycl::free(dPk, q); sycl::free(dSc, q);
    return nbad ? 1 : 0;
}
