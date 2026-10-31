p='bench_b3.cpp'
s=open(p,encoding='utf-8').read()
anchor = 'printf("  slm_init floor ladder'
i = s.index(anchor)
j = s.index(');', i) + 2
block = '''printf("  slm_init floor ladder (empty body, %d WGs): 2K=%.4f 8K=%.4f 16K=%.4f 32K=%.4f 48K=%.4f 64K=%.4f ms\\n",
      tiles2, t_s2k,t_s8k,t_s16k,t_s32k,t_s48k,t_s64k);
    // cs8: the GRF-FOOTPRINT hypothesis -- same 64KB slm + grid, but the body
    // DECLARES and lightly touches 16 accumulator registers (8x simd<float,64>).
    // If THIS jumps, the shell floor = register pressure / SPILL (the section
    // 6.8 ledger noted chip scratch=1024-1312B/thread), not slm, not dispatch.
    double t_g16 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<65536u>();
        esimd::simd<float,64> a0(0.f),a1(0.f),a2(0.f),a3(0.f),b0(0.f),b1(0.f),b2(0.f),b3(0.f);
        a0+=1.f;a1+=1.f;a2+=1.f;a3+=1.f;b0+=1.f;b1+=1.f;b2+=1.f;b3+=1.f;
        float s=esimd::hmax<float,float,64>(a0)+esimd::hmax<float,float,64>(a1)+esimd::hmax<float,float,64>(a2)+esimd::hmax<float,float,64>(a3)
               +esimd::hmax<float,float,64>(b0)+esimd::hmax<float,float,64>(b1)+esimd::hmax<float,float,64>(b2)+esimd::hmax<float,float,64>(b3);
        float* o=(float*)o2; if(s==1234.5f) o[it.get_global_id(0)]=s; }); });
    double t_g8 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<65536u>();
        esimd::simd<float,64> a0(0.f),a1(0.f),a2(0.f),a3(0.f);
        a0+=1.f;a1+=1.f;a2+=1.f;a3+=1.f;
        float s=esimd::hmax<float,float,64>(a0)+esimd::hmax<float,float,64>(a1)+esimd::hmax<float,float,64>(a2)+esimd::hmax<float,float,64>(a3);
        float* o=(float*)o2; if(s==1234.5f) o[it.get_global_id(0)]=s; }); });
    double t_g4 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<65536u>();
        esimd::simd<float,64> a0(0.f),a1(0.f);
        a0+=1.f;a1+=1.f;
        float s=esimd::hmax<float,float,64>(a0)+esimd::hmax<float,float,64>(a1);
        float* o=(float*)o2; if(s==1234.5f) o[it.get_global_id(0)]=s; }); });
    printf("  GRF footprint ladder (64KB slm, %d WGs): 0acc=%.4f 4acc=%.4f 8acc=%.4f 16acc=%.4f ms\\n",
      tiles2, t_s64k, t_g4, t_g8, t_g16);'''
s = s[:i] + block + s[j:]
open(p,'w',encoding='utf-8').write(s)
print('cs8/cs9b/cs10 wired')
