p='bench_b3.cpp'
s=open(p,encoding='utf-8').read()
old='''    float* o3=malloc_device<float>((size_t)Mp*cin*4,q); q.memset(o3,0,(size_t)Mp*cin*4); q.wait();
    double t_csp = timeit([&]{ return ffnc::launch_ffn_chip_cs<16,false>(q,dAp,dEp,dPp,o3,(int)M,(int)Mp,dSkip,dCos,false,true); });'''
new='''    float* o3=malloc_device<float>((size_t)Mp*cin*4,q); q.memset(o3,0,(size_t)Mp*cin*4); q.wait();
    float* o4=malloc_device<float>((size_t)Mp*cin*4,q); q.memset(o4,0,(size_t)Mp*cin*4); q.wait();
    double t_csp = timeit([&]{ return ffnc::launch_ffn_chip_cs<16,false>(q,dAp,dEp,dPp,o3,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_csp2 = timeit([&]{ return ffnc::launch_ffn_chip_cs2<16,false>(q,dAp,dEp,dPp,o4,(int)M,(int)Mp,dSkip,dCos,false,true); });'''
assert old in s; s=s.replace(old,new)
old2='''    std::vector<float> cc((size_t)Mp*cin); q.memcpy(cc.data(),o3,(size_t)Mp*cin*4).wait();
    size_t dcsp=0; for(size_t i=0;i<a.size();++i) if(memcmp(&a[i],&cc[i],4)) ++dcsp;
    printf("   COLSPLIT %.4f ms | diff-vs-shipping %zu %s\\n", t_csp, dcsp, dcsp?"MISMATCH":"EXACT");'''
new2='''    std::vector<float> cc((size_t)Mp*cin); q.memcpy(cc.data(),o3,(size_t)Mp*cin*4).wait();
    size_t dcsp=0; for(size_t i=0;i<a.size();++i) if(memcmp(&a[i],&cc[i],4)) ++dcsp;
    std::vector<float> c4((size_t)Mp*cin); q.memcpy(c4.data(),o4,(size_t)Mp*cin*4).wait();
    size_t dcsp2=0; for(size_t i=0;i<a.size();++i) if(memcmp(&a[i],&c4[i],4)) ++dcsp2;
    printf("   COLSPLIT-v1 %.4f ms (diff %zu %s) | COLSPLIT-v2 %.4f ms (diff %zu %s)\\n",
      t_csp, dcsp, dcsp?"MISMATCH":"EXACT", t_csp2, dcsp2, dcsp2?"MISMATCH":"EXACT");'''
assert old2 in s; s=s.replace(old2,new2)
open(p,'w',encoding='utf-8').write(s); print('cs2 in bench')
