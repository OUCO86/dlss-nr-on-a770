// smoke_sycl.cpp — first gate: can the conda SYCL toolchain compile and run a
// device query + trivial kernel on the A770?  No ESIMD yet — this only proves
// the icx //fsycl -> level-zero -> A770 path works end to end.  The ESIMD DPAS
// micro-kernel comes next once this prints the device and a sum.
#include <sycl/sycl.hpp>
#include <cstdio>

int main() {
    sycl::device dev;
    {
        // prefer the discrete GPU
        auto devs = sycl::device::get_devices(sycl::info::device_type::gpu);
        for (auto& dd : devs) {
            if (dd.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = dd; break; }
        }
    }
    std::printf("device: %s\n", dev.get_info<sycl::info::device::name>().c_str());
    std::printf("driver: %s\n", dev.get_info<sycl::info::device::driver_version>().c_str());
    std::printf("max_work_group_size: %u\n", (unsigned)dev.get_info<sycl::info::device::max_work_group_size>());
    std::printf("sub_group_sizes: ");
    for (auto sg : dev.get_info<sycl::info::device::sub_group_sizes>()) std::printf("%u ", (unsigned)sg);
    std::printf("\n");

    sycl::queue q(dev);
    int* buf = sycl::malloc_device<int>(256, q);
    q.parallel_for(256, [=](sycl::item<1> it) { buf[it.get_id(0)] = (int)it.get_id(0); });
    int out[256];
    q.memcpy(out, buf, 256 * sizeof(int)).wait();
    sycl::free(buf, q);
    int sum = 0; for (int i = 0; i < 256; ++i) sum += out[i];
    std::printf("trivial kernel sum(0..255) = %d (expect 32640)\n", sum);
    std::printf("SMOKE_OK\n");
    return 0;
}
