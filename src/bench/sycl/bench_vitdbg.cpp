// bench_vitdbg.cpp -- isolate the P11 table mechanism: upload a 64K table, run a
// tiny ESIMD kernel that (a) reads the table at a known index, (b) extracts the
// half bits of a known norm, and dumps both. If the table READ works but the
// bits are wrong -> the extraction spelling; if the read is zero -> the upload
// or the pointer capture.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cmath>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

int main(){
    queue q(device{}, property::queue::enable_profiling{});
    std::vector<float> h(65536);
    for (unsigned u=0;u<65536u;++u){
        sycl::half hh; unsigned short uu=(unsigned short)u; __builtin_memcpy(&hh,&uu,2); float norm=(float)hh;
        if(!(norm>0.0f)){h[u]=0.0f;continue;}
        h[u]=(float)sycl::half(1.0f/std::sqrt(norm));
    }
    float* tab=(float*)malloc_device(65536u*4u,q);
    q.memcpy(tab,h.data(),65536u*4u).wait();
    float* out=malloc_device<float>(16,q);
    q.parallel_for(range(1),[=](item<1> it) SYCL_ESIMD_KERNEL {
        // norm = 4.0 (half bits 0x4400); table[0x4400] should be 0.5
        float norm = 4.0f;
        float a = norm;  // .bits() does not exist in this toolchain (the compile error IS the answer)
        // second: manual bit extraction via union-free memcpy
        sycl::half nh(norm); unsigned short nb;
        __builtin_memcpy(&nb,&nh,2);
        float b = tab[(unsigned)nb];
        // third: the table entry itself at a hardcoded index
        float c = tab[0x4400u];
        out[0]=a; out[1]=b; out[2]=c; out[3]=(float)nb;
    }).wait();
    std::vector<float> o(4); q.memcpy(o.data(),out,16).wait();
    printf("bits() lookup=%.6g  memcpy lookup=%.6g  direct tab[0x4400]=%.6g  nb=0x%04x (host table=%.6g)\n",
        o[0],o[1],o[2],(unsigned short)o[3], h[0x4400]);
    return 0;
}
