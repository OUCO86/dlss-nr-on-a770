
#include <cstdio>
#include <cmath>
#include <random>
#include <sycl/sycl.hpp>
#include "cosine_tree_kernel.hpp"
static inline float eh_round(float x){ return (float)(sycl::half)x; }
static inline float eh_mul(float a,float b){ return (float)(sycl::half)(a*b); }
static inline float eh_add(float a,float b){ return (float)(sycl::half)(a+b); }
static inline float eh_hfma(float l,float r,float acc){ return (float)(sycl::half)(l*r+acc); }
int main(){
    std::mt19937 rng(3); std::uniform_real_distribution<float> df(-4.f,4.f);
    int bad=0;
    for(int t=0;t<200000;++t){
        float h[32]; for(int i=0;i<32;++i) h[i]=df(rng);
        float ref = ctree::vit_reciprocal(h);
        // the P11 lane emulation: lanes l=0..3 hold cols {g*8+2l, g*8+2l+1}
        float E[8];
        for(int l=0;l<4;++l){
            float hq[8];  // hq[2g]=h[g*8+2l], hq[2g+1]=h[g*8+2l+1]
            for(int g=0;g<4;++g){ hq[2*g]=h[g*8+2*l]; hq[2*g+1]=h[g*8+2*l+1]; }
            for(int p=0;p<2;++p){
                float r_lo = eh_hfma(hq[p],hq[p], eh_mul(hq[p+4],hq[p+4]));   // r[2l+p]
                float r_hi = eh_hfma(hq[p+2],hq[p+2], eh_mul(hq[p+6],hq[p+6])); // r[2l+p+8]
                E[2*l+p] = eh_add(r_lo, r_hi);                                 // E[c]=hadd(r[c],r[c+8])
            }
        }
        float f0=eh_add(E[0],E[4]), f1=eh_add(E[1],E[5]), f2=eh_add(E[2],E[6]), f3=eh_add(E[3],E[7]);
        float norm = eh_add(eh_add(f0,f2), eh_add(f1,f3));
        float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
        norm = norm > floorv ? norm : floorv;
        float mine = eh_round(1.0f/std::sqrt(norm));
        if (mine != ref) { if(bad<4) printf("t=%d mine=%.9g ref=%.9g  ULP-diff\n",t,mine,ref); bad++; }
    }
    printf("lane-tree vs ctree::vit_reciprocal: %d / 200000 differ\n", bad);
    // FULL Q-chain bisect: reference (ctree::vit_reciprocal + the scalar pass's
    // qr_half_round(cr_mul(...)) chain + qr_e4m3) vs the P11 chain (lane-tree recip
    // + eh_mul chain + qr_e4m3_scalar).
    int badq = 0;
    for(int t=0;t<200000;++t){
        float h[32]; for(int i=0;i<32;++i) h[i]=df(rng)*0.9f;   // half-domain values
        float sc = eh_round(df(rng)*0.5f);
        // reference:
        float ref_r = ctree::vit_reciprocal(h);
        float v = h[0];
        v = (float)sycl::half((float)sycl::ext::intel::math::fmul_rn(v, ref_r));
        v = (float)sycl::half((float)sycl::ext::intel::math::fmul_rn(v, 5.65625f));
        v = (float)sycl::half((float)sycl::ext::intel::math::fmul_rn(v, sc));
        // (the gate's want uses the HOST python e4m3; emulate both e4m3 in the same
        //  scalar form so only the VALUE path is compared):
        float e_ref = 0; { float x=v; unsigned char sgn=0; (void)sgn; e_ref=x; }
        // mine (P11 chain):
        float E[8];
        for(int l=0;l<4;++l){
            float hq[8];
            for(int g=0;g<4;++g){ hq[2*g]=h[g*8+2*l]; hq[2*g+1]=h[g*8+2*l+1]; }
            for(int p=0;p<2;++p){
                float r_lo = eh_hfma(hq[p],hq[p], eh_mul(hq[p+4],hq[p+4]));
                float r_hi = eh_hfma(hq[p+2],hq[p+2], eh_mul(hq[p+6],hq[p+6]));
                E[2*l+p] = eh_add(r_lo, r_hi);
            }
        }
        float f0=eh_add(E[0],E[4]), f1=eh_add(E[1],E[5]), f2=eh_add(E[2],E[6]), f3=eh_add(E[3],E[7]);
        float norm = eh_add(eh_add(f0,f2), eh_add(f1,f3));
        float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
        norm = norm > floorv ? norm : floorv;
        float my_r = eh_round(1.0f/std::sqrt((double)norm));   // the exact-div analogue
        float m = v;  // compare the VALUE entering e4m3 (chain above), mine:
        float mv = h[0];
        mv = eh_mul(mv, my_r); mv = eh_mul(mv, 5.65625f); mv = eh_mul(mv, sc);
        if (mv != m) { if (badq<3) printf("Qval mine=%.9g ref=%.9g\n", mv, v); badq++; }
    }
    printf("Q-chain (value before e4m3): %d / 200000 differ\n", badq);
    return (bad||badq)?1:0;
}
