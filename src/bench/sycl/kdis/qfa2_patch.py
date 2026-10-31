p='pack_device.hpp'
s=open(p,encoding='utf-8').read()

anchor='''// ---- P4b: the GATHERED window quant folded into the QKV gemm's pack_a ----'''
assert anchor in s
new_fn='''// ---- QFALIAS-v2: the batched fused pack, SINGLE-READ form (the +25ms of the
// first QFALIAS attempt was the peak pass: pack_a_fused_b above re-reads the
// FULL lda-wide row for the peak ONCE PER GROUP (batch=8 -> 8 x 133MB of L2/DRAM
// reads per call). The row's scale is SHARED across groups (scale_stride==0,
// the frame census), so read the row ONCE into GRF (lda <= 512 halfs = safe at
// the rowthread proven limit), compute peak+scale once, then loop the groups
// writing each packed slice. Arithmetic per element VERBATIM (same scale, same
// div_ieee/rnde/clip, same store map) = bit-exact by construction. ----
static inline void pack_a_fused_b1(sycl::queue& q, const sycl::half* A_f16, int8_t* Ap,
                                   float* scales, int M, int Mp, int K, int lda,
                                   size_t sa, int batch) {
    const int BM = 128, BK = 32;
    const int kb_n = K / BK;
    const size_t per = (size_t)(Mp / BM) * kb_n * 8 * 512;   // = Mp*K per group
    q.parallel_for(sycl::range((size_t)Mp), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        int srow = (int)it.get_id(0);
        int w = srow / BM, rem = srow % BM, wi = rem / 16, row = rem % 16;
        size_t per_blk = ((size_t)w * kb_n) * 8 + wi;
        if (srow >= M) {
            esimd::simd<int8_t,32> z((int8_t)0);
            for (int gg = 0; gg < batch; ++gg) {
                int8_t* Apg = Ap + (size_t)gg * per;
                for (int kb = 0; kb < kb_n; ++kb)
                    esimd::block_store<int8_t,32>(Apg + (per_blk + (size_t)kb*8)*512 + row*32,
                        z, esimd::overaligned_tag<16>{});
            }
            return;
        }
        // ONE row read: lda in {64,128,256,512} (the frame census) -> GRF form.
        esimd::simd<float,512> reg(0.f);
        if (lda == 64)  reg.template select<64,1>(0)  = esimd::convert<float>(esimd::block_load<sycl::half,64>(A_f16 + (size_t)srow*lda, esimd::overaligned_tag<16>{}));
        else if (lda == 128) reg.template select<128,1>(0) = esimd::convert<float>(esimd::block_load<sycl::half,128>(A_f16 + (size_t)srow*lda, esimd::overaligned_tag<16>{}));
        else if (lda == 256) reg.template select<256,1>(0) = esimd::convert<float>(esimd::block_load<sycl::half,256>(A_f16 + (size_t)srow*lda, esimd::overaligned_tag<16>{}));
        else reg = esimd::convert<float>(esimd::block_load<sycl::half,512>(A_f16 + (size_t)srow*lda, esimd::overaligned_tag<16>{}));
        esimd::simd<float,512> mx = esimd::abs(reg);
        float peak = esimd::hmax<float,float,512>(mx);
        const float scale = (peak == 0.f) ? 1.f
            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.f))[0];
        scales[srow] = scale;
        const esimd::simd<float,512> rs(scale);
        esimd::simd<float,512> qq = esimd::div_ieee<float,512>(reg, rs);
        qq = esimd::min(esimd::max(esimd::rnde<float,512>(qq), esimd::simd<float,512>(-127.f)), esimd::simd<float,512>(127.f));
        esimd::simd<int8_t,512> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
        for (int gg = 0; gg < batch; ++gg) {
            int8_t* Apg = Ap + (size_t)gg * per;
            const int off = gg * (int)sa;   // the group's column slice within the row
            #pragma unroll
            for (int kb = 0; kb < kb_n; ++kb)
                esimd::block_store<int8_t,32>(Apg + (per_blk + (size_t)kb*8)*512 + row*32,
                    qi.template select<32,1>(kb*32 + off), esimd::overaligned_tag<16>{});
        }
    });
}
'''
s=s.replace(anchor, new_fn+anchor)
open(p,'w',encoding='utf-8').write(s)
print('pack_a_fused_b1 added')

# route the recorder: lda<=512 -> b1 form
p2='libxmx_sycl.cpp'
s2=open(p2,encoding='utf-8').read()
old='''        if (fused_b) { bfp++; packdev::pack_a_fused_b(*GQ, a16b, dAp, (float*)ias->second.p, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch); }'''
new='''        if (fused_b) { bfp++;
            static int qfmode = getenv("NR_QF_B1") ? atoi(getenv("NR_QF_B1")) : 1;   // 1 = single-read b1 (QFALIAS-v2), 0 = the old per-group peak
            if (qfmode == 1 && lda_e <= 512 && sa + K <= lda_e)
                packdev::pack_a_fused_b1(*GQ, a16b, dAp, (float*)ias->second.p, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch);
            else
                packdev::pack_a_fused_b(*GQ, a16b, dAp, (float*)ias->second.p, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch); }'''
assert old in s2, 'recorder anchor miss'
s2=s2.replace(old,new)
open(p2,'w',encoding='utf-8').write(s2)
print('recorder routed to b1')
