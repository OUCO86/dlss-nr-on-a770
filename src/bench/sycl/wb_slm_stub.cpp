// wb_slm_stub.cpp -- (b1) codegen stub: instantiate wbv4phS::launch_v4ph under WBS_STATE so the
// device .text exists for the ocloc comparison. Nothing here runs the kernel: stop_stage=0xFFFF
// makes the kernel return at its first line, and the pointers are null.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include "wb_v4ph_slm.hpp"

int main(int argc, char** argv) {
    sycl::device dev;
    sycl::queue q(dev);
    if (argc > 1) {   // only touched to keep the call alive; never reached in practice
        wbv4phS::launch_v4ph(q, (const void*)1, false, (sycl::half*)1, (sycl::half*)1,
                             (sycl::half*)1, (float*)1, (const float*)1, (const float*)1, (const float*)1,
                             1u, 1u, 1u, 1u, 0u, 0u, 0u, false,
                             0xFFFFu, nullptr, false, false, nullptr, nullptr, nullptr, nullptr, nullptr);
    }
    std::printf("wb_slm_stub: WBS_STATE=%d WBS_SLM=%d\n", WBS_STATE, WBS_SLM);
    return 0;
}
