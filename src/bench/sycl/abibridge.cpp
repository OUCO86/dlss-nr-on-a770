// abibridge.cpp — the make-or-break premise of route A': an icx-compiled C++/SYCL
// dll that exports the SAME C ABI xmxres.py binds (extern "C", restype c_int,
// ctypes-compatible argtypes), and drives a real SYCL kernel through it.
//
// If ctypes can load this and call xmx_init / xmx_transform / xmx_error with the
// exact signatures xmxres.py uses, the rewrite's host<->kernel bridge is proven and
// the 81-function skeleton is mechanical porting. If not, route A' has a hidden wall.
//
// Build (C++/SYCL, def-based exports like build_fused.bat does for the C libxmx):
//   icx //fsycl //Fe:abibridge.dll //LD abibridge.cpp //link abibridge.def
// Then a Python ctypes harness loads it and checks the ABI + kernel result.
#include <sycl/sycl.hpp>
#include <cstring>
#include <cstdio>

// one device-side queue, created at init (mirrors libxmx's single g.dev/g.q model)
static sycl::queue* GQ = nullptr;
static char GERR[256] = {0};

extern "C" {

// const char* xmx_error(void)  — libxmx.c:267 exact shape
const char* xmx_error(void) { return GERR; }

// int xmx_init() — restype c_int in xmxres; picks the Arc device
int xmx_init(void) {
    try {
        sycl::device dev;
        for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
            if (d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
        GQ = new sycl::queue(dev);
        return 0;
    } catch (const std::exception& e) {
        std::snprintf(GERR, sizeof GERR, "xmx_init: %s", e.what());
        return -1;
    }
}

// int xmx_transform(unsigned long long src, unsigned long long dst, unsigned n)
// ctypes: [c_ulonglong, c_ulonglong, c_uint] -> c_int. Runs a real SYCL kernel on
// device pointers passed as integers (the USM-pointer-as-u64 idiom libxmx uses).
int xmx_transform(unsigned long long src, unsigned long long dst, unsigned n) {
    if (!GQ) { std::snprintf(GERR, sizeof GERR, "not initialised"); return -1; }
    try {
        float* s = reinterpret_cast<float*>(src);
        float* d = reinterpret_cast<float*>(dst);
        GQ->parallel_for(sycl::range(n), [=](sycl::id<1> i) { d[i[0]] = s[i[0]] * 2.0f + 1.0f; }).wait();
        return 0;
    } catch (const std::exception& e) {
        std::snprintf(GERR, sizeof GERR, "xmx_transform: %s", e.what());
        return -1;
    }
}

// int xmx_alloc(unsigned long long* out, unsigned n) — USM device alloc, handle out as u64
int xmx_alloc(unsigned long long* out, unsigned n) {
    if (!GQ) { std::snprintf(GERR, sizeof GERR, "not initialised"); return -1; }
    *out = reinterpret_cast<unsigned long long>(sycl::malloc_device<float>(n, *GQ));
    return *out ? 0 : -1;
}
int xmx_free(unsigned long long p) { if (GQ) sycl::free(reinterpret_cast<void*>(p), *GQ); return 0; }

// int xmx_write(unsigned long long dst, const void* src, unsigned n)  — host->device
int xmx_write(unsigned long long dst, const void* src, unsigned n) {
    if (!GQ) return -1;
    GQ->memcpy(reinterpret_cast<void*>(dst), src, n).wait(); return 0;
}
// int xmx_read(void* dst, unsigned long long src, unsigned n)  — device->host
int xmx_read(void* dst, unsigned long long src, unsigned n) {
    if (!GQ) return -1;
    GQ->memcpy(dst, reinterpret_cast<void*>(src), n).wait(); return 0;
}

} // extern "C"
