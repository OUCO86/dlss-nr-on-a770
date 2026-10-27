// bench_qfused2.cpp -- section 100 P2 PARALLELISM probe (the user's step-1): the
// shipped pack_a_fused (ROW-parallel, Mp items, kb loop inside) vs a (row x kb_group)
// TWO-LEVEL variant -- each item owns ONE 32-k block, re-derives the row peak with a
// redundant scan (second row read served by L1; a row is <=8KB f16), zero barriers,
// zero atomics, zero CPU round-trip. Frame-real shapes incl the big-K ones.
// Judges: fused kernel time vs the two-pass (quant+pack) chain on the SAME shapes.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
using namespace sycl;
template<class T> static void scales_w(T* p, unsigned r, float v){ p[r]=v; } // benign: all groups write the SAME value
namespace esimd = sycl::ext::intel::esimd;

// ---- the two-pass baseline (shipped: rowthread quant + pack_a scatter) ----
template <int KMAX>
auto k_quant(){
    return [=](sycl::half* a_src, int8_t* packed, float* scales, unsigned m){
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            unsigned row = (unsigned)it.get_id(0);
            const size_t base = (size_t)row * KMAX;
            esimd::simd<float,KMAX> reg = esimd::convert<float>(
                esimd::block_load<sycl::half,KMAX>(a_src + base, esimd::overaligned_tag<16>{}));
            float peak = esimd::hmax<float,float,KMAX>(esimd::abs(reg));
            const float scale = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            scales[row] = scale;
            esimd::simd<float,KMAX> q = esimd::div_ieee<float,KMAX>(reg, esimd::simd<float,KMAX>(scale));
            q = esimd::min(esimd::max(esimd::rnde<float,KMAX>(q), esimd::simd<float,KMAX>(-127.f)), esimd::simd<float,KMAX>(127.f));
            esimd::block_store<int8_t,KMAX>(packed + base,
                esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
        };
    };
}
auto k_pack_a(){   // int8 pk -> pack_a tile (BM128 BK32), elementwise (the shipped map)
    return [=](const int8_t* A, int8_t* Ap, int M, int Mp, int K){
        return [=](sycl::item<1> it){
            const int BM=128, BK=32; int kb_n=K/BK;
            size_t d = (size_t)it.get_id(0);
            size_t blk = d / 512; int off = (int)(d % 512);
            int wi = (int)(blk % 8); size_t wk = blk / 8;
            int kb = (int)(wk % (size_t)kb_n); int w = (int)(wk / (size_t)kb_n);
            int row = off / 32, k = off % 32;
            int srow = w * BM + wi * 16 + row;
            Ap[d] = srow < M ? A[(size_t)srow * K + kb * BK + k] : (int8_t)0;
        };
    };
}
// ---- fused variant A: ROW-parallel (the shipped pack_a_fused) ----
template <int KMAX>
auto k_fp_row(){
    return [=](sycl::half* a_src, int8_t* Ap, float* scales, unsigned m, unsigned Mp){
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            const int BM=128, BK=32; const int kb_n=KMAX/BK;
            int srow=(int)it.get_id(0);
            int w=srow/BM, rem=srow%BM, wi=rem/16, row=rem%16;
            size_t per_blk=((size_t)w*kb_n)*8+wi;
            if (srow>=(int)m){ esimd::simd<int8_t,32> z((int8_t)0);
                for(int kb=0;kb<kb_n;++kb) esimd::block_store<int8_t,32>(Ap+(per_blk+(size_t)kb*8)*512+row*32,z,esimd::overaligned_tag<16>{});
                return; }
            esimd::simd<float,32> mx(esimd::simd<float,32>(0.f));
            for(int kb=0;kb<kb_n;++kb){
                esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(
                    a_src+(size_t)srow*KMAX+kb*BK, esimd::overaligned_tag<16>{}));
                mx=esimd::max(mx,esimd::abs(reg)); }
            float peak=esimd::hmax<float,float,32>(mx);
            const float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
            scales[srow]=scale;
            for(int kb=0;kb<kb_n;++kb){
                esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(
                    a_src+(size_t)srow*KMAX+kb*BK, esimd::overaligned_tag<16>{}));
                esimd::simd<float,32> qq=esimd::div_ieee<float,32>(reg,esimd::simd<float,32>(scale));
                qq=esimd::min(esimd::max(esimd::rnde<float,32>(qq),esimd::simd<float,32>(-127.f)),esimd::simd<float,32>(127.f));
                esimd::block_store<int8_t,32>(Ap+(per_blk+(size_t)kb*8)*512+row*32,
                    esimd::convert<int8_t>(esimd::convert<int>(qq)),esimd::overaligned_tag<16>{}); }
        };
    };
}
// ---- fused variant B: (row x kb_group) two-level, redundant row-peak per item ----
// items = Mp * kbs_per_grp groups; each item scans the WHOLE row for the peak (L2/L1
// re-reads; rows <= 8KB f16), then quantizes+stores only its OWN kb blocks.
template <int KMAX, int GRP>   // GRP = kb blocks each item owns
auto k_fp_2lvl(){
    return [=](sycl::half* a_src, int8_t* Ap, float* scales, unsigned m, unsigned Mp){
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            const int BM=128, BK=32; const int kb_n=KMAX/BK; const int ngrp=kb_n/GRP;
            size_t d=(size_t)it.get_id(0);
            int srow=(int)(d/ngrp), g=(int)(d%ngrp);
            int w=srow/BM, rem=srow%BM, wi=rem/16, row=rem%16;
            size_t per_blk=((size_t)w*kb_n)*8+wi;
            if (srow>=(int)m){ esimd::simd<int8_t,32> z((int8_t)0);
                for(int kb=g*GRP;kb<(g+1)*GRP;++kb) esimd::block_store<int8_t,32>(Ap+(per_blk+(size_t)kb*8)*512+row*32,z,esimd::overaligned_tag<16>{});
                return; }
            esimd::simd<float,32> mx(esimd::simd<float,32>(0.f));
            for(int kb=0;kb<kb_n;++kb){          // FULL row peak (redundant across g)
                esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(
                    a_src+(size_t)srow*KMAX+kb*BK, esimd::overaligned_tag<16>{}));
                mx=esimd::max(mx,esimd::abs(reg)); }
            float peak=esimd::hmax<float,float,32>(mx);
            const float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
            scales[srow]=scale;                   // idempotent (same value per g)
            for(int kb=g*GRP;kb<(g+1)*GRP;++kb){  // own quantize+scatter
                esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(
                    a_src+(size_t)srow*KMAX+kb*BK, esimd::overaligned_tag<16>{}));
                esimd::simd<float,32> qq=esimd::div_ieee<float,32>(reg,esimd::simd<float,32>(scale));
                qq=esimd::min(esimd::max(esimd::rnde<float,32>(qq),esimd::simd<float,32>(-127.f)),esimd::simd<float,32>(127.f));
                esimd::block_store<int8_t,32>(Ap+(per_blk+(size_t)kb*8)*512+row*32,
                    esimd::convert<int8_t>(esimd::convert<int>(qq)),esimd::overaligned_tag<16>{}); }
        };
    };
}

template <int KMAX, int GRP>
static void one(queue& q, unsigned m, const char* lbl){
    size_t n=(size_t)m*KMAX; int Mp=(int)((m+127u)/128u)*128;
    size_t npk=(size_t)Mp*KMAX;
    sycl::half* src = malloc_device<sycl::half>(n,q);
    int8_t* pkA = malloc_device<int8_t>(n,q);
    int8_t* tA = malloc_device<int8_t>(npk,q);
    int8_t* tB = malloc_device<int8_t>(npk,q);
    int8_t* tC = malloc_device<int8_t>(npk,q);
    float* sA = malloc_device<float>(Mp,q);
    float* sB = malloc_device<float>(Mp,q);
    float* sC = malloc_device<float>(Mp,q);
    std::vector<sycl::half> h(n);
    std::mt19937 rng(11); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(size_t i=0;i<n;++i) h[i]=sycl::half(df(rng));
    q.memcpy(src,h.data(),n*2).wait();
    q.memset(pkA,0,n); q.memset(tA,0,npk); q.memset(tB,0,npk); q.memset(tC,0,npk); q.memset(sA,0,Mp*4); q.memset(sB,0,Mp*4); q.memset(sC,0,Mp*4); q.wait();
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9;
        for(int it=0;it<15;++it){ auto es=fn(); for(auto&e:es) e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()
                                              - e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    double t2 = timeit([&]{
        event e1=q.parallel_for(range(m), k_quant<KMAX>()(src,pkA,sA,m));
        event e2=q.parallel_for(range(npk), k_pack_a()(pkA,tA,(int)m,Mp,KMAX));
        return std::vector<event>{e1,e2}; });
    double tr = timeit([&]{ return std::vector<event>{q.parallel_for(range((unsigned)Mp), k_fp_row<KMAX>()(src,tB,sB,m,(unsigned)Mp))}; });
    int ngrp=(KMAX/32)/GRP;
    double tb = timeit([&]{ return std::vector<event>{q.parallel_for(range((size_t)Mp*ngrp), k_fp_2lvl<KMAX,GRP>()(src,tC,sC,m,(unsigned)Mp))}; });
    // correctness: tB == tC == pack_a(quant(m)) tile-wise; scales B == C == A
    std::vector<int8_t> a(npk), b(npk), c2(npk);
    q.memcpy(a.data(),tA,npk).wait(); q.memcpy(b.data(),tB,npk).wait(); q.memcpy(c2.data(),tC,npk).wait();
    std::vector<float> ha(Mp),hb(Mp),hc(Mp);
    q.memcpy(ha.data(),sA,Mp*4).wait(); q.memcpy(hb.data(),sB,Mp*4).wait(); q.memcpy(hc.data(),sC,Mp*4).wait();
    size_t db=0,dc=0,dsb=0,dsc=0;
    for(size_t i=0;i<npk;++i){ if(a[i]!=b[i])db++; if(a[i]!=c2[i])dc++; }
    for(int i=0;i<Mp;++i){ if(ha[i]!=hb[i])dsb++; if(ha[i]!=hc[i])dsc++; }
    printf("%-16s M=%6u K=%4d Mp=%6d | two-pass %7.3f  row-fused %7.3f (%.2fx)  2lvl(GRP=%d) %7.3f (%.2fx)  | tileB %zu tileC %zu scB %zu scC %zu %s\n",
        lbl,m,KMAX,Mp,t2,tr,t2/tr,GRP,tb,t2/tb,db,dc,dsb,dsc,(db||dc||dsb||dsc)?"NOT-EXACT":"EXACT");
    free(src,q);free(pkA,q);free(tA,q);free(tB,q);free(tC,q);free(sA,q);free(sB,q);free(sC,q);
}


// ---- batched-shape probe: WIDE-ROW quant (lda=2048) split into K=256 column GROUPS
// with shared row-scales (scale_stride=0). Two-pass: quant(M=640,K=2048) -> pack_a_b
// (8 groups read the int8). Fused: per (group,row) item re-scans the FULL 2048 row for
// the peak (8x redundant) + writes its 256 slice. Does the redundant peak lose? ----
static void one_batched(queue& q, unsigned M, unsigned lda, unsigned K, unsigned batch){
    size_t n=(size_t)M*lda; int Mp=(int)((M+127u)/128u)*128;
    size_t npk=(size_t)batch*Mp*K;
    sycl::half* src=malloc_device<sycl::half>(n,q);
    int8_t* pkA=malloc_device<int8_t>(n,q);
    int8_t* tA=malloc_device<int8_t>(npk,q);
    int8_t* tB=malloc_device<int8_t>(npk,q);
    float* sA=malloc_device<float>(M+128,q);   // k_quant<2048> writes m rows only, but
    float* sB=malloc_device<float>(M+128,q);   // keep headroom; scales_w guard below
    std::vector<sycl::half> h(n);
    std::mt19937 rng(11); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(size_t i=0;i<n;++i) h[i]=sycl::half(df(rng));
    q.memcpy(src,h.data(),n*2).wait();
    q.memset(pkA,0,n); q.memset(tA,0,npk); q.memset(tB,0,npk); q.memset(sA,0,M*4); q.memset(sB,0,M*4); q.wait();
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9; for(int it=0;it<15;++it){ auto es=fn(); for(auto&e:es)e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    // two-pass: quant wide row + gather_pack_a_b (elementwise int8->tile, batched)
    double t2=timeit([&]{
        event e1=q.parallel_for(range(M), k_quant<2048>()(src,pkA,sA,M)); // wide-row quant
        event e2=q.parallel_for(range((size_t)batch*Mp*K), [=](sycl::item<1> it){
            const int BM=128,BK=32; int kb_n=K/BK; size_t per=(size_t)(Mp/BM)*kb_n*8*512;
            size_t gg=(size_t)it.get_id(0)/per, d=(size_t)it.get_id(0)%per;
            size_t blk=d/512; int off=(int)(d%512); int wi=(int)(blk%8); size_t wk=blk/8;
            int kb=(int)(wk%(size_t)kb_n), w=(int)(wk/(size_t)kb_n); int row=off/32,k=off%32;
            int srow=w*BM+wi*16+row;
            ((int8_t*)tA)[gg*per+d]= srow<(int)M ? pkA[(size_t)srow*lda+gg*((size_t)K)+kb*BK+k] : (int8_t)0; });
        return std::vector<event>{e1,e2}; });
    // fused: (group,row) item, re-scan full lda peak + write own K slice into tile
    double tf=timeit([&]{ return std::vector<event>{q.parallel_for(range((size_t)batch*M), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        const int BM=128,BK=32; int kb_n=K/BK; size_t per=(size_t)(Mp/BM)*kb_n*8*512;
        size_t d=(size_t)it.get_id(0); int gg=(int)(d/M), srow=(int)(d%M);
        int w=srow/BM, rem=srow%BM, wi=rem/16, row=rem%16; size_t per_blk=((size_t)w*kb_n)*8+wi;
        esimd::simd<float,32> mx(esimd::simd<float,32>(0.f));
        for(int kb=0;kb<(int)(lda/32);++kb){ esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(src+(size_t)srow*lda+kb*32,esimd::overaligned_tag<16>{})); mx=esimd::max(mx,esimd::abs(reg)); }
        float peak=esimd::hmax<float,float,32>(mx);
        float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
        scales_w(sB,srow,scale);
        for(int kb=0;kb<kb_n;++kb){ esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(src+(size_t)srow*lda+gg*(size_t)K+kb*BK,esimd::overaligned_tag<16>{}));
            esimd::simd<float,32> qq=esimd::div_ieee<float,32>(reg,esimd::simd<float,32>(scale));
            qq=esimd::min(esimd::max(esimd::rnde<float,32>(qq),esimd::simd<float,32>(-127.f)),esimd::simd<float,32>(127.f));
            esimd::block_store<int8_t,32>(tB+gg*per+(per_blk+(size_t)kb*8)*512+row*32, esimd::convert<int8_t>(esimd::convert<int>(qq)),esimd::overaligned_tag<16>{}); }
    })}; });
    std::vector<int8_t> a(npk),b(npk); q.memcpy(a.data(),tA,npk).wait(); q.memcpy(b.data(),tB,npk).wait();
    std::vector<float> ha(M),hb(M); q.memcpy(ha.data(),sA,M*4).wait(); q.memcpy(hb.data(),sB,M*4).wait();
    size_t d=0; for(size_t i=0;i<npk;++i) if(a[i]!=b[i])d++;
    size_t sd=0; for(unsigned i=0;i<M;++i) if(ha[i]!=hb[i])sd++;
    printf("batched M=%u lda=%u K=%u b=%u | two-pass %7.3f  fused %7.3f (%.2fx) | tile-diff %zu scale-diff %zu %s\n",
        M,lda,K,batch,t2,tf,t2/tf,d,sd,(d||sd)?"NOT-EXACT":"EXACT");
    free(src,q);free(pkA,q);free(tA,q);free(tB,q);free(sA,q);free(sB,q);
}


// ---- batched fused v3: ZERO-REDUNDANCY row-parallel. One item per row: scans the
// lda-wide row ONCE for the peak, then writes ALL batch groups' K-slices into their
// tiles (col-slice form: group gg owns cols gg*K..gg*K+K-1, lda == batch*K). No
// barrier, no SLM, no atomics -- the redundancy dies because ONE item owns the row.
// Parallelism = Mp items x 32 lanes (640x32 = 20480 lanes > 512 EU x 32: one wave+).
static void one_batched_v3(queue& q, unsigned M, unsigned lda, unsigned K, unsigned batch){
    size_t n=(size_t)M*lda; int Mp=(int)((M+127u)/128u)*128;
    size_t npk=(size_t)batch*Mp*K;
    sycl::half* src=malloc_device<sycl::half>(n,q);
    int8_t* pkA=malloc_device<int8_t>(n,q);
    int8_t* tA=malloc_device<int8_t>(npk,q);   // two-pass ref tile
    int8_t* tC=malloc_device<int8_t>(npk,q);   // v3 tile
    float* sA=malloc_device<float>(M+128,q);
    float* sC=malloc_device<float>(M+128,q);
    std::vector<sycl::half> h(n);
    std::mt19937 rng(11); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(size_t i=0;i<n;++i) h[i]=sycl::half(df(rng));
    q.memcpy(src,h.data(),n*2).wait();
    q.memset(pkA,0,n); q.memset(tA,0,npk); q.memset(tC,0,npk); q.memset(sA,0,(M+128)*4); q.memset(sC,0,(M+128)*4); q.wait();
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9; for(int it=0;it<15;++it){ auto es=fn(); for(auto&e:es)e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    double t2=timeit([&]{
        event e1=q.parallel_for(range(M), k_quant<2048>()(src,pkA,sA,M));
        event e2=q.parallel_for(range((size_t)batch*Mp*K), [=](sycl::item<1> it){
            const int BM=128,BK=32; int kb_n=K/BK; size_t per=(size_t)(Mp/BM)*kb_n*8*512;
            size_t gg=(size_t)it.get_id(0)/per, d=(size_t)it.get_id(0)%per;
            size_t blk=d/512; int off=(int)(d%512); int wi=(int)(blk%8); size_t wk=blk/8;
            int kb=(int)(wk%(size_t)kb_n), w=(int)(wk/(size_t)kb_n); int row=off/32,k=off%32;
            int srow=w*BM+wi*16+row;
            ((int8_t*)tA)[gg*per+d]= srow<(int)M ? pkA[(size_t)srow*lda+gg*((size_t)K)+kb*BK+k] : (int8_t)0; });
        return std::vector<event>{e1,e2}; });
    double t3=timeit([&]{ return std::vector<event>{q.parallel_for(range((unsigned)Mp), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        const int BM=128,BK=32; int kb_n=K/BK; size_t per=(size_t)(Mp/BM)*kb_n*8*512;
        int srow=(int)it.get_id(0);
        int w=srow/BM, rem=srow%BM, wi=rem/16, row=rem%16;
        if (srow>=(int)M){ esimd::simd<int8_t,32> z((int8_t)0);
            for(int gg=0;gg<(int)batch;++gg){ size_t per_blk=((size_t)w*kb_n)*8+wi;
                for(int kb=0;kb<kb_n;++kb) esimd::block_store<int8_t,32>((int8_t*)tC+gg*per+(per_blk+(size_t)kb*8)*512+row*32,z,esimd::overaligned_tag<16>{}); }
            return; }
        esimd::simd<float,32> mx(esimd::simd<float,32>(0.f));
        for(int kb=0;kb<(int)(lda/32);++kb){ esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(src+(size_t)srow*lda+kb*32,esimd::overaligned_tag<16>{})); mx=esimd::max(mx,esimd::abs(reg)); }
        float peak=esimd::hmax<float,float,32>(mx);
        float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
        scales_w(sC,srow,scale);
        size_t per_blk=((size_t)w*kb_n)*8+wi;
        for(int gg=0;gg<(int)batch;++gg){
            for(int kb=0;kb<kb_n;++kb){
                esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(src+(size_t)srow*lda+gg*(size_t)K+kb*BK,esimd::overaligned_tag<16>{}));
                esimd::simd<float,32> qq=esimd::div_ieee<float,32>(reg,esimd::simd<float,32>(scale));
                qq=esimd::min(esimd::max(esimd::rnde<float,32>(qq),esimd::simd<float,32>(-127.f)),esimd::simd<float,32>(127.f));
                esimd::block_store<int8_t,32>((int8_t*)tC+gg*per+(per_blk+(size_t)kb*8)*512+row*32, esimd::convert<int8_t>(esimd::convert<int>(qq)),esimd::overaligned_tag<16>{}); } }
    })}; });
    std::vector<int8_t> a(npk),c2(npk); q.memcpy(a.data(),tA,npk).wait(); q.memcpy(c2.data(),tC,npk).wait();
    std::vector<float> ha(M),hc(M); q.memcpy(ha.data(),sA,M*4).wait(); q.memcpy(hc.data(),sC,M*4).wait();
    size_t d=0; for(size_t i=0;i<npk;++i) if(a[i]!=c2[i])d++;
    size_t sd=0; for(unsigned i=0;i<M;++i) if(ha[i]!=hc[i])sd++;
    printf("batched-v3 1x-peak M=%u lda=%u K=%u b=%u | two-pass %7.3f  v3 %7.3f (%.2fx) | tile-diff %zu scale-diff %zu %s\n",
        M,lda,K,batch,t2,t3,t2/t3,d,sd,(d||sd)?"NOT-EXACT":"EXACT");
    free(src,q);free(pkA,q);free(tA,q);free(tC,q);free(sA,q);free(sC,q);
}


// v4 row-item form for batched: item=row; peak scans lda ONCE; then per group g:
// quantize the g-slice (cols g*K..) and scatter to tile g. Mp items (640 here).
static void one_batched_v4(queue& q, unsigned M, unsigned lda, unsigned K, unsigned batch){
    size_t n=(size_t)M*lda; int Mp=(int)((M+127u)/128u)*128;
    size_t npk=(size_t)batch*Mp*K;
    sycl::half* src=malloc_device<sycl::half>(n,q);
    int8_t* pkA=malloc_device<int8_t>(n,q);
    int8_t* tA=malloc_device<int8_t>(npk,q); int8_t* tD=malloc_device<int8_t>(npk,q);
    float* sA=malloc_device<float>(M+128,q); float* sD=malloc_device<float>(M+128,q);
    std::vector<sycl::half> h(n);
    std::mt19937 rng(11); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(size_t i=0;i<n;++i) h[i]=sycl::half(df(rng));
    q.memcpy(src,h.data(),n*2).wait();
    q.memset(pkA,0,n); q.memset(tA,0,npk); q.memset(tD,0,npk); q.memset(sA,0,(M+128)*4); q.memset(sD,0,(M+128)*4); q.wait();
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9; for(int it=0;it<15;++it){ auto es=fn(); for(auto&e:es)e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    double t2=timeit([&]{
        event e1=q.parallel_for(range(M), k_quant<2048>()(src,pkA,sA,M));
        event e2=q.parallel_for(range((size_t)batch*Mp*K), [=](sycl::item<1> it){
            const int BM=128,BK=32; int kb_n=K/BK; size_t per=(size_t)(Mp/BM)*kb_n*8*512;
            size_t gg=(size_t)it.get_id(0)/per, d=(size_t)it.get_id(0)%per;
            size_t blk=d/512; int off=(int)(d%512); int wi=(int)(blk%8); size_t wk=blk/8;
            int kb=(int)(wk%(size_t)kb_n), w=(int)(wk/(size_t)kb_n); int row=off/32,k=off%32;
            int srow=w*BM+wi*16+row;
            ((int8_t*)tA)[gg*per+d]= srow<(int)M ? pkA[(size_t)srow*lda+gg*((size_t)K)+kb*BK+k] : (int8_t)0; });
        return std::vector<event>{e1,e2}; });
    double t4=timeit([&]{ return std::vector<event>{q.parallel_for(range((unsigned)Mp), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        const int BM=128,BK=32; int kb_n=K/BK; size_t per=(size_t)(Mp/BM)*kb_n*8*512;
        int srow=(int)it.get_id(0);
        int w=srow/BM, rem=srow%BM, wi=rem/16, row=rem%16;
        size_t per_blk=((size_t)w*kb_n)*8+wi;
        if (srow>=(int)M){ esimd::simd<int8_t,32> z((int8_t)0);
            for(int gg=0;gg<(int)batch;++gg) for(int kb=0;kb<kb_n;++kb)
                esimd::block_store<int8_t,32>((int8_t*)tD+gg*per+(per_blk+(size_t)kb*8)*512+row*32,z,esimd::overaligned_tag<16>{});
            return; }
        esimd::simd<float,32> mx(esimd::simd<float,32>(0.f));
        for(int kb=0;kb<(int)(lda/32);++kb){ esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(src+(size_t)srow*lda+kb*32,esimd::overaligned_tag<16>{})); mx=esimd::max(mx,esimd::abs(reg)); }
        float peak=esimd::hmax<float,float,32>(mx);
        float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
        scales_w(sD,srow,scale);
        for(int gg=0;gg<(int)batch;++gg){
            for(int kb=0;kb<kb_n;++kb){
                esimd::simd<float,32> reg=esimd::convert<float>(esimd::block_load<sycl::half,32>(src+(size_t)srow*lda+gg*(size_t)K+kb*BK,esimd::overaligned_tag<16>{}));
                esimd::simd<float,32> qq=esimd::div_ieee<float,32>(reg,esimd::simd<float,32>(scale));
                qq=esimd::min(esimd::max(esimd::rnde<float,32>(qq),esimd::simd<float,32>(-127.f)),esimd::simd<float,32>(127.f));
                esimd::block_store<int8_t,32>((int8_t*)tD+gg*per+(per_blk+(size_t)kb*8)*512+row*32, esimd::convert<int8_t>(esimd::convert<int>(qq)),esimd::overaligned_tag<16>{}); } }
    })}; });
    std::vector<int8_t> a(npk),d2(npk); q.memcpy(a.data(),tA,npk).wait(); q.memcpy(d2.data(),tD,npk).wait();
    std::vector<float> ha(M),hd(M); q.memcpy(ha.data(),sA,M*4).wait(); q.memcpy(hd.data(),sD,M*4).wait();
    size_t dd=0; for(size_t i=0;i<npk;++i) if(a[i]!=d2[i])dd++;
    size_t sd=0; for(unsigned i=0;i<M;++i) if(ha[i]!=hd[i])sd++;
    printf("batched-v4 row-item M=%u lda=%u K=%u b=%u | two-pass %7.3f  v4 %7.3f (%.2fx) | tile-diff %zu scale-diff %zu %s\n",
        M,lda,K,batch,t2,t4,t2/t4,dd,sd,(dd||sd)?"NOT-EXACT":"EXACT");
    free(src,q);free(pkA,q);free(tA,q);free(tD,q);free(sA,q);free(sD,q);
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  setvbuf(stdout, NULL, _IONBF, 0);
  fprintf(stderr,"[bench] queue create...\n");
  queue q(dev,property::queue::enable_profiling{});
  // frame-real per-call shapes (the fused families' quants):
  fprintf(stderr,"[bench] one64\n"); one<64,1>(q, 32640, "res K64");
  one<128,1>(q, 8160, "win K128");
  one<256,1>(q, 2040, "int8 K256");      // the +4.3ms family shapes below
  one<512,1>(q, 640,  "res K512");
  one<2048,4>(q, 640, "res K2048");
  one<4096,8>(q, 192, "qkv K4096");
  fprintf(stderr,"[bench] one_batched 640/2048\n"); one_batched(q, 640, 2048, 256, 8);
  fprintf(stderr,"[bench] one_batched_v3 640/2048\n"); one_batched_v3(q, 640, 2048, 256, 8);; fprintf(stderr,"[bench] v4 640/2048\n"); one_batched_v4(q, 640, 2048, 256, 8); fprintf(stderr,"[bench] v4 2040/256\n");   // (2040/256 removed: k_quant<2048> would read an lda=256 buffer with 2048-wide rows = OOB = GPU fault, the black-screen class again)
  return 0;
}
