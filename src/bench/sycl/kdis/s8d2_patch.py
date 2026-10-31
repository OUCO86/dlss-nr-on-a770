p='gemm_s8_v8_kernel.hpp'
s=open(p,encoding='utf-8').read()

# insert gemm_b_d2 right before the BN=32 variant comment
anchor='''// --- BN=32 variant for the batched family's N=32 column blocks (section 73):'''
assert anchor in s

new='''// B3-s8d2 (2026-10-31, the S1 ILP blade the corrected ledger pins: our DRAM-heavy
// gemms run 100-190 GB/s effective vs the 592-734 laws in-flight ceiling = the
// 19.4ms bubble between us and the senior's 47.19 roofline ride). The v8 loop is
// a DEPTH-1 software pipeline: iteration b issues the global load of b+1 while
// dpas'ing b -- one 192B/thread pair in flight, ~300-500ns DRAM vs ~150ns of
// dpas per block => the pipeline drains and every kb iteration eats raw latency.
// THE CUT: three SLM buffers, prefetch kb+1 AND kb+2 = two pairs in flight per
// thread (384B), dpas(b) never waits on load(b+1). SLM 12KB -> 18KB (three
// buffers): occupancy 5->3 WG/SM at NT32, the trade laws says to make (ILP8-16
// beat everything on this card). Operand order per kb VERBATIM = bit-exact by
// construction; bench_batched prices it before ANY dll touches.
static inline sycl::event gemm_b_d2(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                 int32_t* C32, int Mp, int N, int K, int batch) {
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K, cb = (size_t)Mp * N;
    const int SLM3_A = SLM_A, SLM3_B = SLM_B, SLM3_BBASE = 3 * SLM_A;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb_g = Ap + (size_t)g * apb;
            const int8_t* bp_g  = Bp + (size_t)g * bpb;
            int32_t* c_g = C32 + (size_t)g * cb;
            const int8_t* apb = apb_g + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM3_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM3_A + lid * 128, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLM3_BBASE + buf * SLM3_B + lid * 64, bv, esimd::overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM3_A + wi_row * 512;
                uint32_t offB = SLM3_BBASE + buf * SLM3_B + wi_col * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            int kb_n = K / BK;
            // prologue: fill buffers 0 and 1 (kb 0, 1) BEFORE the loop
            load_block(0, 0);
            if (kb_n > 1) load_block(1, 1);
            esimd::barrier();
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // depth-2 prefetch
                load_grf(cur, a0, a1, b0, b1);
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<int32_t, 16> row0;
                row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                esimd::simd<int32_t, 16> row1;
                row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
}

'''
s=s.replace(anchor, new+anchor,1)
open(p,'w',encoding='utf-8').write(s)
print('gemm_b_d2 added')
