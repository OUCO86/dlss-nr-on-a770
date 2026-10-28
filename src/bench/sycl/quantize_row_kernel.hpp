// quantize_row_kernel.hpp — the SYCL translation of src/gpu/quantize_row.comp.
// ONE source of truth, shared by the standalone probe (quantize_row_sycl.cpp) and the
// libxmx_sycl skeleton. Proven against the numpy contract (gate_quantize_numpy.py,
// ALL OK on 7 frame-real cases; plain/tiny/gather packed 0-differ vs numpy).
//
// Semantics copied line-for-line from the shipped .comp: warp-per-row (rows share a
// warp when short), 16-byte word reads, one scale per row (peak/127), roundEven grid,
// flag 0x400000 = window gather, flag 0x8000000 = e4m3 byte container. The row-max
// reduction uses local memory + one barrier (this toolchain has no public
// sub_group.shuffle_xor; see §20) — bit-exact (float max is associative/commutative).
// Division is ext::intel::math::fdiv_rn(v, scale): the shipped numpy contract
// (int8_quant.py:50 `wide / scale`) is ONE correctly-rounded division; icx lowers
// `v * (1.0f/scale)` to an approximate reciprocal (1 ULP off) which flips X.5 ties.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/math.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdlib>

static const unsigned QR_GRID = 65535u;   // x-extent cap, same as the GLSL

// prods/recips are diagnostics-only (nullptr in production paths).
inline auto qr_kernel() {
    return [](sycl::half* a_src, sycl::uint2* packed, float* scales,
              unsigned m, unsigned k, unsigned flags,
              unsigned image_h, unsigned image_w, unsigned window_cols, unsigned window_pad,
              float* prods, float* recips,
              sycl::local_accessor<float, 1> la
             ) {
        return [=](sycl::nd_item<2> it) {
            const unsigned words = k / 8u;
            const unsigned SUB = it.get_sub_group().get_local_range().size();
            const unsigned THREADS = it.get_local_range(0);
            const unsigned WARPS = THREADS / SUB;
            unsigned pr = (words >= SUB) ? SUB : 1u;
            if (words < SUB && words > 1u) { unsigned v = words - 1u, lg = 0; while (v >>= 1) ++lg; pr = 1u << (lg + 1u); }
            const unsigned per_row = pr;
            const unsigned rows_per_warp = SUB / per_row;
            unsigned gx = it.get_group(0), gy = it.get_group(1);
            unsigned lx = it.get_local_id(0);
            unsigned warp = lx / SUB, lane = lx % SUB;
            unsigned which = lane / per_row, within = lane % per_row;
            unsigned row = (gy * QR_GRID + gx) * (WARPS * rows_per_warp) + warp * rows_per_warp + which;
            unsigned held = row < m ? row : m - 1u;
            bool e4m3 = (flags & 0x8000000u) != 0u;
            bool gather = (flags & 0x400000u) != 0u && !e4m3;
            bool outside = false;
            unsigned base = held * words;
            if (gather) {
                const unsigned size = 8u;
                unsigned across = window_cols;
                unsigned pad_top = window_pad >> 16u, pad_left = window_pad & 0xFFFFu;
                unsigned token = held % (size * size), window = held / (size * size);
                int y = (int)((window / across) * size + token / size) - (int)pad_top;
                int x = (int)((window % across) * size + token % size) - (int)pad_left;
                outside = (y < 0 || x < 0 || y >= (int)image_h || x >= (int)image_w);
                if (!outside) base = ((unsigned)y * image_w + (unsigned)x) * words;
            }
            auto halves = [](sycl::uint4 w, float* f) {
                unsigned u[4] = { w.x(), w.y(), w.z(), w.w() };
                for (int i = 0; i < 4; ++i) {
                    sycl::half lo = sycl::bit_cast<sycl::half>((unsigned short)(u[i] & 0xFFFFu));
                    sycl::half hi = sycl::bit_cast<sycl::half>((unsigned short)(u[i] >> 16));
                    f[2*i] = (float)lo; f[2*i+1] = (float)hi;
                }
            };
            auto peak8 = [&](sycl::uint4 w) {
                float f[8]; halves(w, f);
                float p = 0.f; for (int i = 0; i < 8; ++i) p = sycl::fmax(p, sycl::fabs(f[i]));
                return p;
            };
            auto e4m3_decode = [](unsigned b) {
                unsigned exponent = (b >> 3u) & 15u, mantissa = b & 7u;
                float value = exponent == 0u ? (float)mantissa * sycl::exp2(-9.0f)
                                             : (1.0f + (float)mantissa * 0.125f) * sycl::exp2((float)exponent - 7.0f);
                return (b & 0x80u) ? -value : value;
            };
            auto peak8_e4m3 = [&](sycl::uint2 w) {
                unsigned u[2] = { w.x(), w.y() }; float p = 0.f;
                for (int i = 0; i < 2; ++i) for (int j = 0; j < 4; ++j)
                    p = sycl::fmax(p, sycl::fabs(e4m3_decode((u[i] >> (8*j)) & 0xFFu)));
                return p;
            };
            float peak = 0.0f;
            if (!outside) {
                if (e4m3) {
                    sycl::uint2* src8 = reinterpret_cast<sycl::uint2*>(a_src);
                    for (unsigned w = within; w < words; w += per_row)
                        peak = sycl::fmax(peak, peak8_e4m3(src8[base + w]));
                } else {
                    sycl::uint4* src4 = reinterpret_cast<sycl::uint4*>(a_src);
                    for (unsigned w = within; w < words; w += per_row)
                        peak = sycl::fmax(peak, peak8(src4[base + w]));
                }
            }
            // row-max: local memory + one barrier (see header note on shuffle_xor).
            la[lx] = peak;
            it.barrier(sycl::access::fence_space::local_space);
            unsigned base_lane = warp * SUB + which * per_row;
            float full = 0.0f;
            for (unsigned i = 0; i < per_row; ++i) full = sycl::fmax(full, la[base_lane + i]);
            peak = full;
            // fdiv_rn here too (section 77): `peak / 127.0f` is a division by a
            // NOT-exactly-representable constant, and icx lowers it to an approximate
            // reciprocal -- one ULP off on some peaks, which flips an X.5 tie in the
            // v/scale roundEven downstream (caught by the quant_window gate at row 119:
            // scale 1 ULP low -> 63.499996 vs 63.5 -> dev 64 vs gold 63). The header's
            // own rule ("ONE correctly-rounded division") applies to BOTH divisions;
            // the earlier gates' data simply never hit a bad peak.
            float scale = (peak == 0.0f) ? 1.0f : sycl::ext::intel::math::fdiv_rn(peak, 127.0f);
            if (row >= m) return;
            if (within == 0u) { scales[row] = scale; if (recips) recips[row] = sycl::ext::intel::math::fdiv_rn(1.0f, scale); }
            auto grid = [&](float v) {
                int r = (int)sycl::rint(sycl::ext::intel::math::fdiv_rn(v, scale));
                return (r < -127 ? -127 : (r > 127 ? 127 : r));
            };
            auto pack4 = [](int x0, int x1, int x2, int x3) {
                return ((unsigned)x0 & 0xFFu) | (((unsigned)x1 & 0xFFu) << 8u)
                     | (((unsigned)x2 & 0xFFu) << 16u) | (((unsigned)x3 & 0xFFu) << 24u);
            };
            sycl::uint2* dst = reinterpret_cast<sycl::uint2*>(packed);
            for (unsigned w = within; w < words; w += per_row) {
                unsigned at = row * words + w;
                sycl::uint2 out(0u, 0u);
                if (!outside) {
                    if (e4m3) {
                        sycl::uint2* src8 = reinterpret_cast<sycl::uint2*>(a_src);
                        sycl::uint2 sw = src8[base + w];
                        unsigned u[2] = { sw.x(), sw.y() }; unsigned o[2];
                        for (int i = 0; i < 2; ++i) {
                            int g0 = grid(e4m3_decode(u[i] & 0xFFu)), g1 = grid(e4m3_decode((u[i] >> 8u) & 0xFFu));
                            int g2 = grid(e4m3_decode((u[i] >> 16u) & 0xFFu)), g3 = grid(e4m3_decode(u[i] >> 24u));
                            o[i] = pack4(g0, g1, g2, g3);
                        }
                        out = sycl::uint2(o[0], o[1]);
                    } else {
                        sycl::uint4* src4 = reinterpret_cast<sycl::uint4*>(a_src);
                        sycl::uint4 sw = src4[base + w];
                        float f[8]; halves(sw, f);
                        int g[8]; for (int i = 0; i < 8; ++i) g[i] = grid(f[i]);
                        out = sycl::uint2(pack4(g[0],g[1],g[2],g[3]), pack4(g[4],g[5],g[6],g[7]));
                        if (prods) for (int i = 0; i < 8; ++i) prods[(size_t)row * k + w * 8u + i] = sycl::ext::intel::math::fdiv_rn(f[i], scale);
                    }
                }
                dst[at] = out;
            }
        };
    };
}

// dispatch sizing: over-dispatch using the LARGEST supported sub-group size as the
// upper bound for per_row => every row is covered whatever the runtime picks; extra
// groups exit at the row>=m guard. (Same as the gated probe.)
template <typename K>
inline void qr_launch(sycl::queue& q, sycl::device& dev, K kern,
                      sycl::half* dsrc, sycl::uint2* dpack, float* dscale,
                      unsigned m, unsigned k, unsigned flags,
                      unsigned image_h, unsigned image_w, unsigned window_cols, unsigned window_pad,
                      float* dprod, float* drecip) {
    unsigned words = k / 8u;
    auto sgs = dev.get_info<sycl::info::device::sub_group_sizes>();
    unsigned SUB_max = 1u; for (unsigned s : sgs) if (s > SUB_max) SUB_max = s;
    unsigned lg = 0; while ((1u << lg) < words) ++lg;
    unsigned per_row_ub = (1u << lg) < SUB_max ? (1u << lg) : SUB_max;
    unsigned rows_per_wg = 256u / per_row_ub;
    unsigned ngroups = (m + rows_per_wg - 1u) / rows_per_wg;
    unsigned gxx = ngroups < QR_GRID ? ngroups : QR_GRID;
    unsigned gyy = (ngroups + gxx - 1u) / gxx;
    q.submit([&](sycl::handler& h) {
        sycl::local_accessor<float, 1> la(sycl::range<1>(256u), h);
        h.parallel_for(sycl::nd_range<2>(sycl::range(256u * gxx, gyy), sycl::range(256u, 1u)),
            kern(dsrc, dpack, dscale, m, k, flags, image_h, image_w, window_cols, window_pad, dprod, drecip, la));
    });   // no .wait(): the in-order queue orders quant->consumer, graph_run drains once (section 92)
}

// ============================================================================
// SECTION 99: ESIMD quantize_row -- the speed fix for the fdiv_rn wall.
// bench_qvar A/B: the shipped plain kernel runs at 2-24 GB/s because the
// per-element division is ext::intel::math::fdiv_rn = __imf_fdiv_rn, an IMF
// SOFTWARE routine. Plain '/' and native::divide are fast but NOT bit-exact on
// this stack (approximate reciprocal; the frame went 0%-bit-exact with it --
// the §77 trap applies to runtime divisors too). esimd::div_ieee = __esimd_ieee_div
// = the HARDWARE correctly-rounded fdiv, proven bit-identical to fdiv_rn by the
// bench_v9 gate (0/8.3M diff). esimd intrinsics THROW at submit inside plain
// kernels (gate l2/l0/tiny "submit ran the SYCL kernel" FAIL, 2026-10-25), so
// the whole kernel goes ESIMD: 16-half vector chunks (32B loads / 16B stores =
// P4 width), segmented shuffle_xor row-max (no local_accessor, no barrier),
// rnde = ties-to-even == sycl::rint. Semantics identical to the .comp golden:
// scale = (peak==0)?1:peak/127 (one correctly-rounded div), q = clip(rint(v/scale)).
// Scope: the PLAIN path (flags==0, K%16==0) -- all 448 frame xmx_rec_quant passes.
// gather/e4m3 variants (quant_window) keep the proven plain kernel for now.
// ============================================================================
inline auto qr_kernel_esimd() {
    return [](sycl::half* a_src, sycl::uint2* packed, float* scales,
              unsigned m, unsigned k) {
        return [=](sycl::nd_item<2> it) SYCL_ESIMD_KERNEL {
            namespace esimd = sycl::ext::intel::esimd;
            esimd::slm_init<64 * 4>();    // per-lane row-max slots (LW=64: §96 GRF rule)
            const unsigned words = k / 8u;          // 8-half words (16B)
            const unsigned chunks = words / 2u;     // 16-half chunks (32B in / 16B out)
            const unsigned SUB = it.get_sub_group().get_local_range().size();
            const unsigned THREADS = it.get_local_range(0);
            const unsigned WARPS = THREADS / SUB;
            unsigned pr = (chunks >= SUB) ? SUB : 1u;
            if (chunks < SUB && chunks > 1u) { unsigned v = chunks - 1u, lg = 0; while (v >>= 1) ++lg; pr = 1u << (lg + 1u); }
            const unsigned per_row = pr;
            const unsigned rows_per_warp = SUB / per_row;
            unsigned gx = it.get_group(0), gy = it.get_group(1), lx = it.get_local_id(0);
            unsigned warp = lx / SUB, lane = lx % SUB;
            unsigned which = lane / per_row, within = lane % per_row;
            unsigned row = (gy * QR_GRID + gx) * (WARPS * rows_per_warp) + warp * rows_per_warp + which;
            // §96 barrier-deadlock rule: NO early return before esimd::barrier(). Out-of-
            // range rows clamp to the last row (harmless reads; stores guarded below).
            bool live = row < m;
            unsigned held = live ? row : m - 1u;
            const size_t base = (size_t)held * k;                      // halves
            using f16 = esimd::simd<float, 16>;
            f16 accmax(0.f);
            for (unsigned c = within; c < chunks; c += per_row) {
                esimd::simd<sycl::half,16> h = esimd::block_load<sycl::half,16>(
                    a_src + base + (size_t)c * 16u, esimd::overaligned_tag<16>{});
                accmax = esimd::max(accmax, esimd::abs(esimd::convert<float>(h)));
            }
            // cross-lane row-max: NO public shuffle in this ESIMD (the §20 note), so the
            // SAME SLM+barrier shape the plain kernel uses (proven bit-exact: float max is
            // associative/commutative). SLM slot = lx (256 floats).
            esimd::slm_block_store(lx * 4, esimd::simd<float,1>(esimd::hmax<float,float,16>(accmax)),
                                   esimd::overaligned_tag<16>{});
            esimd::barrier();
            // slot BYTE offset = lane*4 (matches the store). The segment base is
            // (warp*SUB + which*per_row) LANES -> *4 bytes. BUG FIXED: was bl + i*4
            // (base not scaled) -> read wrong slots -> wrong row-max -> 0% frame.
            unsigned bl = (warp * SUB + which * per_row) * 4u;
            float full = 0.f;
            for (unsigned i = 0; i < per_row; ++i) {
                float v = esimd::slm_block_load<float,1>(bl + i * 4u)[0];
                full = full > v ? full : v;
            }
            const float peak = full;
            const float scale = (peak == 0.0f) ? 1.0f : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            if (live && within == 0u) scales[row] = scale;
            sycl::uint4* dst4 = reinterpret_cast<sycl::uint4*>(packed);
            const size_t row4 = (size_t)row * (words / 2u);            // uint4 units per row
            for (unsigned c = within; c < chunks; c += per_row) {
                esimd::simd<sycl::half,16> h = esimd::block_load<sycl::half,16>(
                    a_src + base + (size_t)c * 16u, esimd::overaligned_tag<16>{});
                f16 f = esimd::convert<float>(h);
                f16 q = esimd::div_ieee<float,16>(f, f16(scale));
                q = esimd::min(esimd::max(esimd::rnde<float,16>(q), f16(-127.f)), f16(127.f));
                esimd::simd<int8_t,16> o = esimd::convert<int8_t>(esimd::convert<int>(q));
                if (live) esimd::block_store<unsigned,4>(
                    (unsigned*)(dst4 + row4 + c),
                    o.template bit_cast_view<unsigned>());
            }
        };
    };
}

// ---- section 99 ROW-THREAD quantize (the senior fastest-operator geometry, bench_qv3
// measured): ONE thread per row, K in {64,128,256,512} = the whole row in GRF registers,
// hmax intra-thread (float max is associative/commutative -> bit-exact vs any order),
// ZERO SLM, ZERO barrier, ONE global read. bench_qv3: K=256 -> 357 GB/s (senior 374),
// K=128 -> 187, K=64 -> 221; the double-read ESIMD form ran 54-77. div_ieee + rnde +
// clip = the shipping chain VERBATIM -> bit-exact by construction; the QUANT gate
// (numpy golden) is the judge. k must EQUAL KMAX exactly. ----
template <int KMAX>
inline auto qr_kernel_rowthread() {
    return [](sycl::half* a_src, sycl::uint2* packed, float* scales, unsigned m, unsigned k) {
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            namespace esimd = sycl::ext::intel::esimd;
            unsigned row = (unsigned)it.get_id(0);
            const size_t base = (size_t)row * k;
            esimd::simd<float,KMAX> reg = esimd::convert<float>(
                esimd::block_load<sycl::half,KMAX>(a_src + base, esimd::overaligned_tag<16>{}));
            float peak = esimd::hmax<float,float,KMAX>(esimd::abs(reg));
            const float scale = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            scales[row] = scale;
            esimd::simd<float,KMAX> q = esimd::div_ieee<float,KMAX>(reg, esimd::simd<float,KMAX>(scale));
            q = esimd::min(esimd::max(esimd::rnde<float,KMAX>(q), esimd::simd<float,KMAX>(-127.f)), esimd::simd<float,KMAX>(127.f));
            esimd::simd<int8_t,KMAX> o = esimd::convert<int8_t>(esimd::convert<int>(q));
            esimd::block_store<int8_t,KMAX>((int8_t*)packed + base, o, esimd::overaligned_tag<16>{});
        };
    };
}

// P8-j (section 100): the WORKGROUP-PER-ROW SINGLE-READ quantize for K>512. The
// old ESIMD path read the row TWICE (peak pass + quantize pass) and ran 12-28 GB/s
// at the frame's 640x2048 / 192x1024 / 192x4096 (bench_qesimd: the census-weighted
// 12.4ms at 84 GB/s vs the rowthread's 190-306). The new form: LW=64 threads own
// one row, each holds CH16 = K/1024 x simd<half,16> IN REGISTERS (K=1024->1,
// 2048->2, 4096->4 = 4-16 GRF regs/thread, the safe zone), ONE global read, the
// row peak = in-thread hmax then a 256B SLM cross-thread max (float max is
// associative/commutative -> bit-identical to any order, the rowthread precedent),
// quantize from the registers. bench_qrg: diff 0 AND scale-diff 0 on all five
// shapes, 3-4x (640x2048 0.206->0.051 = 77 GB/s; 32640x1024 3.56->0.92 = 109).
// SLM declares EXACTLY 256B (the P8-c bucket rule -- an undersized/odd declaration
// costs resident workgroups). The frame's K>512 quants are always K%1024==0.
template <int CH16>
inline auto qr_kernel_rowgroup() {
    return [](sycl::half* a_src, sycl::uint2* packed, float* scales, unsigned m, unsigned k) {
        return [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
            namespace esimd = sycl::ext::intel::esimd;
            esimd::slm_init<256>();
            constexpr int K = CH16 * 16 * 64;
            unsigned row = (unsigned)it.get_group(0);
            unsigned tid = (unsigned)it.get_local_id(0);
            const size_t base = (size_t)row * K;
            esimd::simd<sycl::half,16> reg[CH16];
            esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
            #pragma unroll
            for (int c = 0; c < CH16; ++c) {
                reg[c] = esimd::block_load<sycl::half,16>(a_src + base + (size_t)(c*64u + tid)*16u,
                                                          esimd::overaligned_tag<16>{});
                mx = esimd::max(mx, esimd::abs(esimd::convert<float>(reg[c])));
            }
            float local = esimd::hmax<float,float,16>(mx);
            esimd::slm_block_store(tid * 4u, esimd::simd<float,1>(local), esimd::overaligned_tag<16>{});
            esimd::barrier();
            esimd::simd<float,64> all = esimd::slm_block_load<float,64>(0u, esimd::overaligned_tag<16>{});
            float peak = esimd::hmax<float,float,64>(all);
            const float scale = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            if (tid == 0u) scales[row] = scale;
            #pragma unroll
            for (int c = 0; c < CH16; ++c) {
                esimd::simd<float,16> f = esimd::convert<float>(reg[c]);
                esimd::simd<float,16> qq = esimd::div_ieee<float,16>(f, esimd::simd<float,16>(scale));
                qq = esimd::min(esimd::max(esimd::rnde<float,16>(qq), esimd::simd<float,16>(-127.f)), esimd::simd<float,16>(127.f));
                esimd::block_store<int8_t,16>((int8_t*)packed + base + (size_t)(c*64u + tid)*16u,
                    esimd::convert<int8_t>(esimd::convert<int>(qq)), esimd::overaligned_tag<16>{});
            }
        };
    };
}
// launcher for the ESIMD variant (plain path). Same over-dispatch rule as qr_launch
// but per_row is computed from CHUNKS (16-half units), and no local_accessor.
inline void qr_launch_esimd(sycl::queue& q, sycl::device& dev,
                            sycl::half* dsrc, sycl::uint2* dpack, float* dscale,
                            unsigned m, unsigned k) {
    // ROW-THREAD dispatch (section 99): exact small-K shapes get the senior geometry.
    if (k == 64u)  { q.parallel_for(sycl::range(m), qr_kernel_rowthread<64>()(dsrc, dpack, dscale, m, k)); return; }
    if (k == 128u) { q.parallel_for(sycl::range(m), qr_kernel_rowthread<128>()(dsrc, dpack, dscale, m, k)); return; }
    if (k == 256u) { q.parallel_for(sycl::range(m), qr_kernel_rowthread<256>()(dsrc, dpack, dscale, m, k)); return; }
    if (k == 512u) { q.parallel_for(sycl::range(m), qr_kernel_rowthread<512>()(dsrc, dpack, dscale, m, k)); return; }
    // P8-j: K>512 -> the single-read rowgroup form (the double-read ESIMD path
    // below stays as the NR_QR_RG=0 escape hatch). K%1024==0 required (the frame
    // census: 1024/2048/4096 only); other K fall through to the old path.
    static bool rg = !getenv("NR_QR_RG") || atoi(getenv("NR_QR_RG")) != 0;
    if (rg && k % 1024u == 0u && k <= 4096u) {
        if (k == 1024u) { q.submit([&](sycl::handler& h){ h.parallel_for(sycl::nd_range<1>(sycl::range(m*64u), sycl::range(64u)), qr_kernel_rowgroup<1>()(dsrc, dpack, dscale, m, k)); }); return; }
        if (k == 2048u) { q.submit([&](sycl::handler& h){ h.parallel_for(sycl::nd_range<1>(sycl::range(m*64u), sycl::range(64u)), qr_kernel_rowgroup<2>()(dsrc, dpack, dscale, m, k)); }); return; }
        if (k == 4096u) { q.submit([&](sycl::handler& h){ h.parallel_for(sycl::nd_range<1>(sycl::range(m*64u), sycl::range(64u)), qr_kernel_rowgroup<4>()(dsrc, dpack, dscale, m, k)); }); return; }
    }
    // LW: §96/bench_v2crash proved the BIG-state v2 ESIMD+barrier kernels HANG at
    // LW>=128 (GRF rule). The quant kernel's state is small (one 32-wide vector), so
    // the rule may not bind here -- NR_QR_LW lets the experiment pick. Default 64.
    const unsigned LW = getenv("NR_QR_LW") ? (unsigned)atoi(getenv("NR_QR_LW")) : 64u;
    const unsigned chunks = k / 16u;
    auto sgs = dev.get_info<sycl::info::device::sub_group_sizes>();
    unsigned SUB_max = 1u; for (unsigned s : sgs) if (s > SUB_max) SUB_max = s;
    if (SUB_max > LW) SUB_max = LW;
    unsigned lg = 0; { unsigned v = (chunks > 1u ? chunks - 1u : 0u); while (v >>= 1) ++lg; }
    unsigned prub = (chunks >= SUB_max) ? SUB_max : (chunks <= 1u ? 1u : (1u << (lg + 1u)));
    unsigned rows_per_wg = LW / prub;
    unsigned ngroups = (m + rows_per_wg - 1u) / rows_per_wg;
    unsigned gxx = ngroups < QR_GRID ? ngroups : QR_GRID;
    unsigned gyy = (ngroups + gxx - 1u) / gxx;
    q.submit([&](sycl::handler& h) {
        h.parallel_for(sycl::nd_range<2>(sycl::range(LW * gxx, gyy), sycl::range(LW, 1u)),
            qr_kernel_esimd()(dsrc, dpack, dscale, m, k));
    });
}
