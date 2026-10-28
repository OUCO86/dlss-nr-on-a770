#pragma once
#pragma once_placeholder_x
// the RG sweep kernel (bench_qr2/3 shared)
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
// generalized: LW threads/row, SLM reduce over LW slots (LW<=128)
template <int LW, int CH16>   // LW threads/row; each CH16 x simd<half,16>
inline void rg_launch(sycl::queue& q, sycl::half* a, sycl::uint2* pk, float* sc, unsigned m, unsigned k);
template <int LW, int CH16>
inline void rg_launch_impl(sycl::queue& q, sycl::half* a, sycl::uint2* pk, float* sc, unsigned m, unsigned k){
    namespace esimd = sycl::ext::intel::esimd;
    q.submit([&](handler& h){
        h.parallel_for(nd_range<1>(range((size_t)m*LW), range((size_t)LW)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<(LW==128)?512u:256u>();
            unsigned row = (unsigned)it.get_group(0);
            unsigned tid = (unsigned)it.get_local_id(0);
            const size_t base = (size_t)row * k;
            esimd::simd<sycl::half,16> reg[CH16];
            esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
            #pragma unroll
            for (int c = 0; c < CH16; ++c){
                reg[c] = esimd::block_load<sycl::half,16>(a + base + (size_t)(c*LW + tid)*16u, esimd::overaligned_tag<16>{});
                mx = esimd::max(mx, esimd::abs(esimd::convert<float>(reg[c])));
            }
            float local = esimd::hmax<float,float,16>(mx);
            esimd::slm_block_store(tid*4u, esimd::simd<float,1>(local), esimd::overaligned_tag<16>{});
            esimd::barrier();
            constexpr int SW = (LW==128)? 128 : 64;
            esimd::simd<float,SW> all = esimd::slm_block_load<float,SW>(0u, esimd::overaligned_tag<16>{});
            float peak = esimd::hmax<float,float,SW>(all);
            const float scale = (peak==0.0f)?1.0f : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            if (tid==0u) sc[row]=scale;
            #pragma unroll
            for (int c=0;c<CH16;++c){
                esimd::simd<float,16> f = esimd::convert<float>(reg[c]);
                esimd::simd<float,16> qq = esimd::div_ieee<float,16>(f, esimd::simd<float,16>(scale));
                qq = esimd::min(esimd::max(esimd::rnde<float,16>(qq), esimd::simd<float,16>(-127.f)), esimd::simd<float,16>(127.f));
                esimd::block_store<int8_t,16>((int8_t*)pk + base + (size_t)(c*LW+tid)*16u, esimd::convert<int8_t>(esimd::convert<int>(qq)), esimd::overaligned_tag<16>{});
            }
        });
    });
}

template <int LW, int CH16>
inline void rg_launch(sycl::queue& q, sycl::half* a, sycl::uint2* pk, float* sc, unsigned m, unsigned k){
    rg_launch_impl<LW,CH16>(q,a,pk,sc,m,k);
}
