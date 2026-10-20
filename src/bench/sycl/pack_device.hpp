// pack_device.hpp -- device-side VNNI packing (section 92, phase-2 first cut). The
// correctness scaffold (section 22) host-packed every GEMM operand EVERY frame:
// download A+B -> CPU pack -> upload. The decomposition (bench_prepost.cpp) proved that
// is the whole 89s/frame (691 passes x ~100ms of round-trips; the GPU gemm itself is
// ~15ms). The §9 single-world design never pays that: data stays on device. This header
// moves the SAME index maps to a device kernel -- a pure gather, so it is bit-exact by
// construction against the host packs it replaces (same source index, same destination
// index, just computed on the GPU). No arithmetic, so no rounding/contraction questions.
//
// Each kernel is one work-item per destination element (the maps are trivially
// parallel -- the host versions' inner loops are independent gathers).
#pragma once
#include <sycl/sycl.hpp>

namespace packdev {

// ---- int8 family (gemm_s8_v8_kernel.hpp's maps, BM=128 BK=32) ----
// pack_a: A (M x K row-major, real rows only) -> Ap (Mp x K layout), dest =
//         ((w*kb_n+kb)*8+wi)*512 + row*32 + k ; src = (w*BM + wi*16 + row)*K + kb*BK + k.
//         M is the REAL row count, Mp the padded: rows >= M read zero (the host version
//         copies into a zero-padded buffer first -- the guard matches it AND keeps the
//         read inside the M*K source).
static inline void pack_a(sycl::queue& q, const int8_t* A, int8_t* Ap, int M, int Mp, int K) {
    const int BM = 128, BK = 32;
    int wgr = Mp / BM, kb_n = K / BK;
    size_t n = (size_t)wgr * kb_n * 8 * 512;   // = Mp*K
    q.parallel_for(sycl::range(n), [=](sycl::item<1> it) {
        size_t d = it.get_id(0);
        size_t blk = d / 512; int off = (int)(d % 512);
        int wi = (int)(blk % 8); size_t wk = blk / 8;
        int kb = (int)(wk % (size_t)kb_n); int w = (int)(wk / (size_t)kb_n);
        int row = off / 32, k = off % 32;
        int srow = w * BM + wi * 16 + row;
        Ap[d] = srow < M ? A[(size_t)srow * K + kb * BK + k] : (int8_t)0;
    }).wait();
}
// pack_b (B stored TRANSPOSED, N x K row-major): dest = ((kk32*(N/8)+ntile)*64+kq*8+nl)*4+j
//         src = (ntile*8+nl)*K + (kk32*32 + kq*4 + j)
static inline void pack_b(sycl::queue& q, const int8_t* B, int8_t* Bp, int N, int K) {
    int nt_n = N / 8, kk_n = K / 32;
    size_t n = (size_t)kk_n * nt_n * 64 * 4;   // = N*K
    q.parallel_for(sycl::range(n), [=](sycl::item<1> it) {
        size_t d = it.get_id(0);
        int j = (int)(d % 4); size_t rest = d / 4;
        int nl = (int)(rest % 8); rest /= 8;
        int kq = (int)(rest % 8); rest /= 8;
        size_t blk = rest;                     // kk32*(N/8) + ntile
        int ntile = (int)(blk % (size_t)nt_n); int kk32 = (int)(blk / (size_t)nt_n);
        Bp[d] = B[(size_t)(ntile * 8 + nl) * K + (kk32 * 32 + kq * 4 + j)];
    }).wait();
}

// ---- f16 family (gemm_f16_v1_kernel.hpp's maps, TS=16) ----
// pack_a16: A (M x K real rows) -> Ap (Mp x K layout), dest = ((tr*kb_n+kc)*2+strip)*128
//           + il*16 + k ; src = (tr*TS + strip*8 + il)*K + kc*TS + k. Rows >= M read zero
//           (the host version zero-pads first -- the guard matches it and stays in-bounds).
static inline void pack_a16(sycl::queue& q, const sycl::half* A, sycl::half* Ap, int M, int Mp, int K) {
    const int TS = 16;
    int tr_n = Mp / TS, kb_n = K / TS;
    size_t n = (size_t)tr_n * kb_n * 2 * 128;  // = Mp*K
    q.parallel_for(sycl::range(n), [=](sycl::item<1> it) {
        size_t d = it.get_id(0);
        int k = (int)(d % 16); size_t rest = d / 16;
        int il = (int)(rest % 8); rest /= 8;
        int strip = (int)(rest % 2); size_t blk = rest / 2;   // blk = tr*kb_n + kc
        int kc = (int)(blk % (size_t)kb_n); int tr = (int)(blk / (size_t)kb_n);
        int srow = tr * TS + strip * 8 + il;
        Ap[d] = srow < M ? A[(size_t)srow * K + kc * TS + k] : sycl::half(0.0f);
    }).wait();
}
// pack_b: B (K x N row-major) -> Bp, dest = ((kc*tc_n+tc)*2+js)*128 + (k/2)*16 + jl*2 + (k%2)
//         src = (kc*TS + k)*N + tc*TS + js*8 + jl
static inline void pack_b16(sycl::queue& q, const sycl::half* B, sycl::half* Bp, int K, int N) {
    const int TS = 16;
    int kb_n = K / TS, tc_n = N / TS;
    size_t n = (size_t)kb_n * tc_n * 2 * 128;  // = K*N
    q.parallel_for(sycl::range(n), [=](sycl::item<1> it) {
        size_t d = it.get_id(0);
        int inner = (int)(d % 128); size_t blk = d / 128;   // blk = (kc*tc_n+tc)*2 + js
        int js = (int)(blk % 2); size_t blk2 = blk / 2;     // blk2 = kc*tc_n + tc
        int tc = (int)(blk2 % (size_t)tc_n); int kc = (int)(blk2 / (size_t)tc_n);
        int kq = inner / 16; int rem = inner % 16;          // inner = (k/2)*16 + jl*2 + (k%2)
        int jl = rem / 2, kpar = rem % 2;
        int k = kq * 2 + kpar;
        Bp[d] = B[(size_t)(kc * TS + k) * N + tc * TS + js * 8 + jl];
    }).wait();
}
// pack_b_t (scores leg: B stored (N,K) row-major, logical B[k][j]=Bmem[j*K+k]):
//   same dest, src = (tc*TS + js*8 + jl)*K + kc*TS + k
static inline void pack_b16_t(sycl::queue& q, const sycl::half* B, sycl::half* Bp, int K, int N) {
    const int TS = 16;
    int kb_n = K / TS, tc_n = N / TS;
    size_t n = (size_t)kb_n * tc_n * 2 * 128;
    q.parallel_for(sycl::range(n), [=](sycl::item<1> it) {
        size_t d = it.get_id(0);
        int inner = (int)(d % 128); size_t blk = d / 128;
        int js = (int)(blk % 2); size_t blk2 = blk / 2;
        int tc = (int)(blk2 % (size_t)tc_n); int kc = (int)(blk2 / (size_t)tc_n);
        int kq = inner / 16; int rem = inner % 16;
        int jl = rem / 2, kpar = rem % 2;
        int k = kq * 2 + kpar;
        Bp[d] = B[(size_t)(tc * TS + js * 8 + jl) * K + kc * TS + k];
    }).wait();
}

// ---- batched variants (section 92): window_attention's legs run the SAME tile over
// `batches` independent matrices. The per-batch host loop was the pathology (4 sync
// memcpys + 4 malloc/free + 2 launches PER batch, batches up to 2040 -> tens of
// thousands of sync points = the 34s). One launch covers all batches; source and dest
// are contiguous per batch (A at b*M*K, Ap at b*Mp*K, B at b*K*N or b*N*K, Bp at b*K*N).
// Same index maps as the single-matrix versions -- bit-exact by construction. ----
static inline void pack_a16_b(sycl::queue& q, const sycl::half* A, sycl::half* Ap,
                              int M, int Mp, int K, int batches) {
    const int TS = 16;
    int tr_n = Mp / TS, kb_n = K / TS;
    size_t per = (size_t)tr_n * kb_n * 2 * 128;          // = Mp*K
    q.parallel_for(sycl::range((size_t)batches * per), [=](sycl::item<1> it) {
        size_t g = it.get_id(0);
        size_t b = g / per; size_t d = g % per;
        const sycl::half* Ab = A + b * (size_t)M * K; sycl::half* Apb = Ap + b * per;
        int k = (int)(d % 16); size_t rest = d / 16;
        int il = (int)(rest % 8); rest /= 8;
        int strip = (int)(rest % 2); size_t blk = rest / 2;
        int kc = (int)(blk % (size_t)kb_n); int tr = (int)(blk / (size_t)kb_n);
        int srow = tr * TS + strip * 8 + il;
        Apb[d] = srow < M ? Ab[(size_t)srow * K + kc * TS + k] : sycl::half(0.0f);
    }).wait();
}
static inline void pack_b16_b(sycl::queue& q, const sycl::half* B, sycl::half* Bp,
                              int K, int N, int batches) {
    const int TS = 16;
    int kb_n = K / TS, tc_n = N / TS;
    size_t per = (size_t)kb_n * tc_n * 2 * 128;          // = K*N
    q.parallel_for(sycl::range((size_t)batches * per), [=](sycl::item<1> it) {
        size_t g = it.get_id(0);
        size_t b = g / per; size_t d = g % per;
        const sycl::half* Bb = B + b * (size_t)K * N; sycl::half* Bpb = Bp + b * per;
        int inner = (int)(d % 128); size_t blk = d / 128;
        int js = (int)(blk % 2); size_t blk2 = blk / 2;
        int tc = (int)(blk2 % (size_t)tc_n); int kc = (int)(blk2 / (size_t)tc_n);
        int kq = inner / 16; int rem = inner % 16;
        int jl = rem / 2, kpar = rem % 2;
        int k = kq * 2 + kpar;
        Bpb[d] = Bb[(size_t)(kc * TS + k) * N + tc * TS + js * 8 + jl];
    }).wait();
}
static inline void pack_b16_t_b(sycl::queue& q, const sycl::half* B, sycl::half* Bp,
                                int K, int N, int batches) {
    const int TS = 16;
    int kb_n = K / TS, tc_n = N / TS;
    size_t per = (size_t)kb_n * tc_n * 2 * 128;
    q.parallel_for(sycl::range((size_t)batches * per), [=](sycl::item<1> it) {
        size_t g = it.get_id(0);
        size_t b = g / per; size_t d = g % per;
        const sycl::half* Bb = B + b * (size_t)N * K; sycl::half* Bpb = Bp + b * per;
        int inner = (int)(d % 128); size_t blk = d / 128;
        int js = (int)(blk % 2); size_t blk2 = blk / 2;
        int tc = (int)(blk2 % (size_t)tc_n); int kc = (int)(blk2 / (size_t)tc_n);
        int kq = inner / 16; int rem = inner % 16;
        int jl = rem / 2, kpar = rem % 2;
        int k = kq * 2 + kpar;
        Bpb[d] = Bb[(size_t)(tc * TS + js * 8 + jl) * K + kc * TS + k];
    }).wait();
}

} // namespace packdev
