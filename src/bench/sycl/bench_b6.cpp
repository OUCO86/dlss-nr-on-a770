// bench_b6.cpp -- B6-1 instrument (the wa_res/lfw promotion discipline): the
// fused b6 kernel (qkv+wa+attended-quant+outproj+residual-fold, ONE launch per
// window) vs the shipped chain back-to-back = qres::gemm_qkv_res (planes) ->
// wares::launch_wa_res (1277) -> qr_kernel_rowthread<64> (1277 -> pk + scales)
// -> pack_a_v + s8v8::gemm_b_res_window (1270 image slots).
// Inputs shared at the PACK level (dAp/dBp random int8 tiles, as/bs/qs/dBias
// random; W random int8 packed via pack_b) -- both chains consume the SAME
// operands; the diff target = the 1270 f16 image slice. Secondary: the Q/K/V
// planes (proven already by bench_lfw; re-checked free here).
// Shape = the frame's 16 biggest lfw layers: M=32640 (windows=510), C=64,
// heads=2, tokens=64; image map across=17, image_h=240, image_w=136, top=left=0
// (full coverage, no cull -- synthetic but the cull path is the shipped kernel's,
// gate-covered).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <random>
#include <functional>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "qkv_resident.hpp"
#include "wa_res_kernel.hpp"
#include "quantize_row_kernel.hpp"
#include "pack_device.hpp"
#include "b6_res_kernel.hpp"

using namespace sycl;

static int diff_half(queue& q, sycl::half* a, sycl::half* b, size_t n, const char* lab) {
    std::vector<uint16_t> ha(n), hb(n);
    q.memcpy(ha.data(), a, n*2).wait(); q.memcpy(hb.data(), b, n*2).wait();
    size_t d=0, first=(size_t)-1;
    for (size_t i=0;i<n;++i) if (ha[i]!=hb[i]) { ++d; if (first==(size_t)-1) first=i; }
    printf("b6 vs ref %-12s diff %zu / %zu %s\n", lab, d, n, d?"NOT-EXACT":"EXACT");
    if (d) { sycl::half x; memcpy(&x,&ha[first],2); sycl::half y; memcpy(&y,&hb[first],2);
        printf("   first idx %zu (row %zu col %zu): got %.6g want %.6g\n",
               first, first/64, first%64, (float)x, (float)y); }
    return (int)d;
}

int main() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend()==backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc")!=std::string::npos) { dev=d; break; }
    queue q(dev, property::queue::enable_profiling{});
    constexpr unsigned C=64u, heads=2u, tokens=64u, NH=192u;
    for (unsigned windows : {510u, 558u}) {
        unsigned M = windows*tokens, Mp = ((M+127u)/128u)*128u, batches = windows*heads;
        std::mt19937 rng(11);
        std::uniform_int_distribution<int> di(-127,127), dsw(-127,127);
        std::uniform_real_distribution<float> dsc(0.001f,0.02f), df(-4.f,4.f);
        std::vector<int8_t> hAp((size_t)Mp*C), hBp((size_t)NH*C), hW((size_t)C*C);
        for (auto&x:hAp)x=(int8_t)di(rng);
        for (auto&x:hBp)x=(int8_t)di(rng);
        for (auto&x:hW)x=(int8_t)dsw(rng);
        std::vector<float> hAS(Mp),hBS(NH),hQS(heads),hBias((size_t)heads*4096u);
        std::vector<float> hBS2(C), hCos(C);
        for (auto&x:hAS)x=dsc(rng); for (auto&x:hBS)x=dsc(rng);
        for (auto&x:hQS)x=dsc(rng)*4.f; for (auto&x:hBias)x=df(rng)*0.5f;
        for (auto&x:hBS2)x=dsc(rng); for (auto&x:hCos)x=df(rng)*0.1f;
        unsigned across=17, image_h=240, image_w=136, top=0, left=0;
        size_t imgn=(size_t)image_h*image_w*C;
        std::vector<sycl::half> hSkip(imgn);
        for (auto&x:hSkip)x=sycl::half(df(rng));
        // device
        int8_t *dAp=malloc_device<int8_t>(hAp.size(),q), *dBp=malloc_device<int8_t>(hBp.size(),q), *dW=malloc_device<int8_t>(hW.size(),q);
        float *dAS=malloc_device<float>(Mp,q),*dBS=malloc_device<float>(NH,q),*dQS=malloc_device<float>(heads,q),
              *dBias=malloc_device<float>(hBias.size(),q),*dBS2=malloc_device<float>(C,q),*dCos=malloc_device<float>(C,q);
        sycl::half *dSkip=malloc_device<sycl::half>(imgn,q);
        q.memcpy(dAp,hAp.data(),hAp.size()); q.memcpy(dBp,hBp.data(),hBp.size()); q.memcpy(dW,hW.data(),hW.size());
        q.memcpy(dAS,hAS.data(),Mp*4); q.memcpy(dBS,hBS.data(),NH*4); q.memcpy(dQS,hQS.data(),heads*4);
        q.memcpy(dBias,hBias.data(),hBias.size()*4); q.memcpy(dBS2,hBS2.data(),C*4); q.memcpy(dCos,hCos.data(),C*4);
        q.memcpy(dSkip,hSkip.data(),imgn*2); q.wait();
        size_t npl=(size_t)M*C;
        sycl::half *Q1=malloc_device<sycl::half>(npl,q),*K1=malloc_device<sycl::half>(npl,q),*V1=malloc_device<sycl::half>(npl,q);
        sycl::half *Q2=malloc_device<sycl::half>(npl,q),*K2=malloc_device<sycl::half>(npl,q),*V2=malloc_device<sycl::half>(npl,q);
        sycl::half *A177=malloc_device<sycl::half>(npl,q);   // the 1277 attended plane (batches*64*32 halves = M*C halves)
        sycl::uint2 *pk1=malloc_device<sycl::uint2>((size_t)M*C/4u,q);   // quant out row-major (the rowthread packed type)
        float *sc1=malloc_device<float>(M,q);
        int8_t *pkAp=malloc_device<int8_t>((size_t)Mp*C,q);
        int8_t *dOp=malloc_device<int8_t>(hW.size(),q);
        sycl::half *Oref=malloc_device<sycl::half>(imgn,q), *Ob6=malloc_device<sycl::half>(imgn,q);
        q.memset(Q1,0,npl*2);q.memset(K1,0,npl*2);q.memset(V1,0,npl*2);
        q.memset(Q2,0,npl*2);q.memset(K2,0,npl*2);q.memset(V2,0,npl*2);
        q.memset(A177,0,npl*2); q.memset(pk1,0,(size_t)M*C); q.memset(sc1,0,M*4);
        q.memset(pkAp,0,(size_t)Mp*C); q.memset(dOp,0,hW.size());
        q.memset(Oref,0,imgn*2); q.memset(Ob6,0,imgn*2); q.wait();
        // ---- reference chain ----
        qres::gemm_qkv_res(q,dAp,dBp,Q1,K1,V1,dAS,dBS,dQS,(int)M,(int)Mp,(int)C,(int)NH,(int)heads,(int)tokens,false,nullptr).wait();
        wares::launch_wa_res(q,Q1,K1,V1,nullptr,dBias,A177,batches,heads,true).wait();
        q.parallel_for(sycl::range((size_t)M), qr_kernel_rowthread<64>()(A177, pk1, sc1, M, 64u)).wait();
        packdev::pack_a_v(q,(const int8_t*)pk1,pkAp,(int)M,(int)Mp,64);
        packdev::pack_b(q,dW,dOp,64,64); q.wait();
        s8v8::gemm_b_res_window(q,pkAp,dOp,(void*)Oref,sc1,dBS2,dSkip,dCos,(int)M,(int)Mp,64,64,true,true,1u,across,top,left,image_h,image_w).wait();
        // ---- b6 fused (with PKT/AS debug outlets vs the reference pk1/sc1) ----
        int8_t *dbgP=malloc_device<int8_t>((size_t)M*C,q); float *dbgS=malloc_device<float>(M,q); sycl::half *dbgATT=malloc_device<sycl::half>(2u*(size_t)M*32u,q); q.memset(dbgATT,0,2u*(size_t)M*32u*2);   // ATT dump (halfs in a float-typed buffer: head0 rows at 0, head1 at +2048*64 halfs... see kernel)
        q.memset(dbgP,0,(size_t)M*C); q.memset(dbgS,0,M*4); q.wait();
        b6::launch_b6(q,dAp,dBp,dAS,dBS,dQS,dBias,windows,Q2,K2,V2,dOp,dBS2,dCos,dSkip,Ob6,across,top,left,image_h,image_w,dbgP,dbgS,dbgATT).wait();

        { std::vector<int8_t> a((size_t)M*C),bb((size_t)M*C); q.memcpy(a.data(),dbgP,(size_t)M*C).wait(); q.memcpy(bb.data(),pk1,(size_t)M*C).wait();
          size_t d=0; for(size_t i=0;i<a.size();++i) if(a[i]!=bb[i])++d;
          printf("b6 vs ref %-12s diff %zu / %zu %s\n","PKT",d,a.size(),d?"NOT-EXACT":"EXACT"); if(d){for(size_t i=0;i<a.size();++i)if(a[i]!=bb[i]){printf("   first %zu got %d want %d\n",i,(int)a[i],(int)bb[i]);break;}} }
        { std::vector<float> a(M),bb(M); q.memcpy(a.data(),dbgS,M*4).wait(); q.memcpy(bb.data(),sc1,M*4).wait();
          size_t d=0; for(size_t i=0;i<M;++i){unsigned u1,u2;memcpy(&u1,&a[i],4);memcpy(&u2,&bb[i],4);if(u1!=u2)++d;}
          printf("b6 vs ref %-12s diff %zu / %zu %s\n","AS",d,M,d?"NOT-EXACT":"EXACT");
          if(d){for(size_t i=0;i<M;++i){unsigned u1,u2;memcpy(&u1,&a[i],4);memcpy(&u2,&bb[i],4);if(u1!=u2){printf("   AS first row %zu (w=%zu t=%zu): got %.9g want %.9g\n",i,i/64,i%64,a[i],bb[i]);break;}}} }
        { std::vector<int8_t> a((size_t)M*C),bb((size_t)M*C); q.memcpy(a.data(),dbgP,(size_t)M*C).wait(); q.memcpy(bb.data(),pk1,(size_t)M*C).wait();
          // print row 0 side by side (first 16 cols)
          printf("   PKT row0 got: "); for(int c=0;c<16;++c) printf("%d ",(int)a[c]);
          printf("want: "); for(int c=0;c<16;++c) printf("%d ",(int)bb[c]); printf("\n");
          std::vector<uint16_t> att(64), a177(64);
          q.memcpy(att.data(),dbgATT,64*2).wait(); q.memcpy(a177.data(),A177,64*2).wait();
          printf("   ATT row0: "); for(int c=0;c<8;++c){float f; sycl::half h; memcpy(&h,&att[c],2); f=h; printf("%.4f ",f);} printf("\n");
          printf("   A177row0: "); for(int c=0;c<8;++c){float f; sycl::half h; memcpy(&h,&a177[c],2); f=h; printf("%.4f ",f);} printf("\n"); }
        { std::vector<uint16_t> a(2u*M*32u),bb(2u*M*32u); q.memcpy(a.data(),dbgATT,2u*M*32u*2).wait(); q.memcpy(bb.data(),A177,M*64*2).wait();
          // a: head0 rows at [(w*64+t)*32 + c], head1 rows at +2048*64 halfs
          size_t d0=0,d1=0;
          for (size_t r=0;r<(size_t)M;++r) for(unsigned c=0;c<32;++c){
             if (a[r*32u+c]!=bb[r*64u+c]) ++d0;
             if (a[(size_t)M*32u+r*32u+c]!=bb[r*64u+32u+c]) ++d1; }
          printf("b6 vs ref ATT-head0 diff %zu / %zu %s\n",d0,(size_t)M*32u,d0?"NOT-EXACT":"EXACT");
          { std::vector<int> rowerr(64,0), colerr(32,0); int rows_bad=0;
            for (size_t r=0;r<(size_t)M;++r){ bool any=false;
              for(unsigned c=0;c<32u;++c) if (a[r*32u+c]!=bb[r*64u+c]) { rowerr[r%64]++; colerr[c]++; any=true; }
              if (any) ++rows_bad; }
            printf("h0 bad rows %d / %u; row%64 hist:",rows_bad,tokens); for(int i=0;i<64;++i) if(rowerr[i]) printf(" t%d=%d",i,rowerr[i]/32); printf("\n");
            printf("h0 col hist:"); for(int i=0;i<32;++i) if(colerr[i]) printf(" c%d=%d",i,colerr[i]); printf("\n"); }
          printf("b6 vs ref ATT-head1 diff %zu / %zu %s\n",d1,(size_t)M*32u,d1?"NOT-EXACT":"EXACT"); }
        diff_half(q,Q2,Q1,npl,"Q-plane"); diff_half(q,K2,K1,npl,"K-plane"); diff_half(q,V2,V1,npl,"V-plane");
        int d = diff_half(q,Ob6,Oref,imgn,"1270-out");
        // timing: shipped trio vs b6 single launch
        auto timeit=[&](std::function<event()> fn){ double best=1e9;
            for(int it=0;it<9;++it){ event e=fn(); e.wait();
              double t=0; t=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
              best=std::min(best,t/1e6);} return best;};
        double t_ref = 0;
        for (int it=0; it<9; ++it) {
            double tt=0;
            { event e=qres::gemm_qkv_res(q,dAp,dBp,Q1,K1,V1,dAS,dBS,dQS,(int)M,(int)Mp,(int)C,(int)NH,(int)heads,(int)tokens,false,nullptr); e.wait();
              tt+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>()); }
            { event e=wares::launch_wa_res(q,Q1,K1,V1,nullptr,dBias,A177,batches,heads,true); e.wait();
              tt+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>()); }
            { event e=q.parallel_for(sycl::range((size_t)M), qr_kernel_rowthread<64>()(A177,pk1,sc1,M,64u)); e.wait();
              tt+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>()); }
            { event e=s8v8::gemm_b_res_window(q,pkAp,dOp,(void*)Oref,sc1,dBS2,dSkip,dCos,(int)M,(int)Mp,64,64,true,true,1u,across,top,left,image_h,image_w); e.wait();
              tt+=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>()); }
            t_ref=std::min(t_ref,tt/1e6);
        }
        double t_b6f=timeit([&]{ return b6::launch_b6(q,dAp,dBp,dAS,dBS,dQS,dBias,windows,Q2,K2,V2,dOp,dBS2,dCos,dSkip,Ob6,across,top,left,image_h,image_w); });
        printf("windows=%u: qres+wa+quant+wres trio = %.4f ms | b6 single = %.4f ms | ratio %.2fx %s\n",
               windows, t_ref, t_b6f, t_ref/t_b6f, d?"NOT-EXACT":"");
    }
    return 0;
}
