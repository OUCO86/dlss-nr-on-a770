// quantize_row_sycl.cpp — route A' first cut: the shipped quantize_row.comp
// (src/gpu/quantize_row.comp, 238 lines) translated to SYCL, plus a host
// reference in the same file. Gate = bit-exact packed int8 + scales on the
// frame's real shapes, plain / window-gather / e4m3 branches.
//
// Translation map (semantics copied line-for-line, not re-derived):
//   push constants            -> USM device pointers + scalar kernel args
//   unpackHalf2x16            -> bitcast 16 bits to sycl::half, then to float (exact)
//   roundEven                 -> sycl::rint (IEEE round-to-nearest-even = numpy np.round
//                                = the shipped host reference; see int8_quant.py)
//   subgroupShuffleXor        -> NOT AVAILABLE as a public primitive in this toolchain
//                                (sycl/sub_group.hpp exposes only block ops; shuffle_xor
//                                lives in detail/spirv.hpp with no public wrapper).
//                                First cut uses local memory + one barrier instead:
//                                bit-exact (float max is associative/commutative, no
//                                rounding). The shuffle form is a phase-2 perf step.
//   findMSB(words-1)          -> integer log2 (words>=1; k>=8 in practice)
//   pack4 / grid / clamp      -> identical bit ops, all float32
//   e4m3_decode / gather      -> identical integer math, same flag bits (0x400000, 0x8000000)
//
// Build: bash ../esimd/build_esimd.sh quantize_row_sycl.cpp qrsycl.exe  (stages+runs
// from oneapi/ where sycl9.dll lives; SYCL_DEVICE_FILTER=level_zero:gpu).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/math.hpp>   // ext::intel::math::fdiv_rn — correctly-rounded division
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <vector>

static const unsigned GRID = 65535u;   // same x-extent cap as the GLSL

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);
    sycl::device dev;
    for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
        if (d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    sycl::queue q(dev);
    std::printf("device: %s\n", dev.get_info<sycl::info::device::name>().c_str());

    // ---- the kernel, as SYCL (mirrors quantize_row.comp main() line by line) ----
    auto kern = [](sycl::half* a_src, sycl::uint2* packed, float* scales,
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
            unsigned row = (gy * GRID + gx) * (WARPS * rows_per_warp) + warp * rows_per_warp + which;
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
            // row-max reduction: local memory + one barrier (bit-exact; see header note
            // on why not shuffle). Each lane parks its partial peak at la[lx]; then every
            // lane folds the per_row slots that own its row.
            la[lx] = peak;
            it.barrier(sycl::access::fence_space::local_space);
            unsigned base_lane = warp * SUB + which * per_row;
            float full = 0.0f;
            for (unsigned i = 0; i < per_row; ++i) full = sycl::fmax(full, la[base_lane + i]);
            peak = full;
            float scale = (peak == 0.0f) ? 1.0f : peak / 127.0f;
            if (row >= m) return;
            if (within == 0u) { scales[row] = scale; if (recips) recips[row] = sycl::ext::intel::math::fdiv_rn(1.0f, scale); }
            // CONTRACT: the shipped reference (int8_quant.py:50) is `wide / scale` — ONE
            // correctly-rounded float32 division, not a multiply by a reciprocal. The
            // compiler lowers `1.0f/scale` to an approximate reciprocal on the GPU (off by
            // 1 ULP), which flips X.5 ties. fdiv_rn forces the IEEE division the host does.
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
                        // DIAG: record the device's actual products for this word
                        if (prods) for (int i = 0; i < 8; ++i) prods[(size_t)row * k + w * 8u + i] = sycl::ext::intel::math::fdiv_rn(f[i], scale);
                    }
                }
                dst[at] = out;
            }
        };
    };

    // ---- host reference (layout-independent; mirrors int8_quant.py / the GLSL math) ----
    auto ref = [](const std::vector<sycl::half>& src, unsigned m, unsigned k, unsigned flags,
                  unsigned image_h, unsigned image_w, unsigned window_cols, unsigned window_pad,
                  std::vector<float>& scales_out, std::vector<unsigned char>& packed_out,
                  bool e4m3src) {
        unsigned words = k / 8u;
        scales_out.assign(m, 1.0f);
        packed_out.assign((size_t)m * k, 0u);
        for (unsigned row = 0; row < m; ++row) {
            bool outside = false; unsigned base = row * words;
            if ((flags & 0x400000u) && !e4m3src) {
                const unsigned size = 8u;
                unsigned token = row % (size*size), window = row / (size*size);
                int y = (int)((window / window_cols) * size + token / size) - (int)(window_pad >> 16u);
                int x = (int)((window % window_cols) * size + token % size) - (int)(window_pad & 0xFFFFu);
                outside = (y < 0 || x < 0 || y >= (int)image_h || x >= (int)image_w);
                if (!outside) base = ((unsigned)y * image_w + (unsigned)x) * words;
            }
            std::vector<float> vals(k, 0.0f);
            float peak = 0.0f;
            if (!outside) {
                for (unsigned w = 0; w < words; ++w) {
                    if (e4m3src) {
                        const unsigned char* b = reinterpret_cast<const unsigned char*>(&src[(base + w) * 4u]);
                        for (int j = 0; j < 8; ++j) {
                            unsigned bb = b[j]; unsigned exponent=(bb>>3)&15, mantissa=bb&7;
                            float v = exponent==0 ? (float)mantissa*std::exp2(-9.0f)
                                                  : (1.0f+(float)mantissa*0.125f)*std::exp2((float)exponent-7.0f);
                            if (bb & 0x80u) v = -v;
                            vals[w*8+j] = v; peak = std::fmax(peak, std::fabs(v));
                        }
                    } else {
                        for (int j = 0; j < 8; ++j) {
                            float v = (float)src[(base + w) * 8u + j];
                            vals[w*8+j] = v; peak = std::fmax(peak, std::fabs(v));
                        }
                    }
                }
            }
            float scale = peak == 0.0f ? 1.0f : peak / 127.0f;
            scales_out[row] = scale;
            // CONTRACT mirrors numpy int8_quant.py:50 exactly: np.round(wide / scale).
            // host C float32 `/` is IEEE correctly-rounded, same as the device's fdiv_rn.
            for (unsigned j = 0; j < k; ++j) {
                int r = (int)std::nearbyint(vals[j] / scale); // FE_TONEAREST default = half-to-even
                r = r < -127 ? -127 : (r > 127 ? 127 : r);
                packed_out[(size_t)row * k + j] = (unsigned char)r;
            }
        }
    };

    int fails = 0;
    auto run_case = [&](unsigned m, unsigned k, unsigned flags,
                        unsigned image_h, unsigned image_w, unsigned window_cols, unsigned window_pad,
                        bool e4m3src, const char* name) {
        unsigned words = k / 8u;
        size_t src_elems = (flags & 0x400000u) ? (size_t)image_h * image_w * k : (size_t)m * k;
        if (e4m3src) src_elems = (size_t)m * k;
        std::vector<sycl::half> hsrc(src_elems);
        srand(1234u + m * 7u + k);
        for (auto& h : hsrc) h = sycl::half(((rand() % 2001) - 1000) / 500.0f);
        if (e4m3src) {
            unsigned char* b = reinterpret_cast<unsigned char*>(hsrc.data());
            for (size_t i = 0; i < (size_t)m * k; ++i) {
                int c = rand() & 0xFF;                 // full code space incl. sign bit
                if (c == 0x7F || c == 0xFF) c = 0;     // NaN codes excluded (senior's CODES)
                b[i] = (unsigned char)c;
            }
        }
        sycl::half* dsrc = sycl::malloc_device<sycl::half>(src_elems, q);
        sycl::uint2* dpack = sycl::malloc_device<sycl::uint2>((size_t)m * words, q);
        float* dscale = sycl::malloc_device<float>(m, q);
        float* drecip = sycl::malloc_device<float>(m, q);
        float* dprod = sycl::malloc_device<float>((flags & 0x400000u) || e4m3src ? 0 : (size_t)m * k, q);
        if (!((flags & 0x400000u) || e4m3src)) q.memset(dprod, 0, (size_t)m * k * 4).wait();
        q.memcpy(dsrc, hsrc.data(), src_elems * 2).wait();
        q.memset(dpack, 0, (size_t)m * words * 8).wait();
        // dispatch sizing: over-dispatch using the LARGEST supported sub-group size as
        // the upper bound for per_row => every row is covered whatever the runtime picks;
        // extra groups exit at the row>=m guard.
        auto sgs = dev.get_info<sycl::info::device::sub_group_sizes>();
        unsigned SUB_max = 1u; for (unsigned s : sgs) if (s > SUB_max) SUB_max = s;
        unsigned lg = 0; while ((1u << lg) < words) ++lg;
        unsigned per_row_ub = (1u << lg) < SUB_max ? (1u << lg) : SUB_max;
        unsigned rows_per_wg = 256u / per_row_ub;
        unsigned ngroups = (m + rows_per_wg - 1u) / rows_per_wg;
        unsigned gxx = ngroups < GRID ? ngroups : GRID;
        unsigned gyy = (ngroups + gxx - 1u) / gxx;
        q.submit([&](sycl::handler& h) {
            sycl::local_accessor<float, 1> la(sycl::range<1>(256u), h);
            h.parallel_for(sycl::nd_range<2>(sycl::range(256u * gxx, gyy), sycl::range(256u, 1u)),
                kern(dsrc, dpack, dscale, m, k, flags, image_h, image_w, window_cols, window_pad, dprod, drecip, la));
        }).wait();
        std::vector<unsigned char> gotpack((size_t)m * k);
        std::vector<float> getscale(m);
        q.memcpy(gotpack.data(), dpack, (size_t)m * k).wait();
        q.memcpy(getscale.data(), dscale, (size_t)m * 4).wait();
        std::vector<float> rscale; std::vector<unsigned char> rpack;
        ref(hsrc, m, k, flags, image_h, image_w, window_cols, window_pad, rscale, rpack, e4m3src);
        size_t badp = 0, bads = 0;
        size_t firstbad = (size_t)-1;
        for (size_t i = 0; i < gotpack.size(); ++i) if (gotpack[i] != rpack[i]) { if (firstbad==(size_t)-1) firstbad=i; badp++; }
        for (size_t i = 0; i < m; ++i) if (getscale[i] != rscale[i]) bads++;
        if (firstbad != (size_t)-1) {
            size_t row = firstbad / k, col = firstbad % k;
            float v = (float)hsrc[row * k + col];
            float sc = rscale[row];
            float hostprod = v / sc;   // the host ref's ACTUAL arithmetic (divide, = numpy)
            std::vector<float> dprods((size_t)m * k);
            std::vector<float> drecips(m);
            q.memcpy(drecips.data(), drecip, (size_t)m * 4).wait();
            if (!((flags & 0x400000u) || e4m3src)) q.memcpy(dprods.data(), dprod, (size_t)m * k * 4).wait();
            float devprod = dprods[firstbad];
            float devrecip = drecips[row];
            unsigned hbits, dbits, rbh, rbd, vbh, vbd, sbh, sbd;
            memcpy(&hbits,&hostprod,4); memcpy(&dbits,&devprod,4);
            memcpy(&rbh,&sc,4); memcpy(&rbd,&devrecip,4);
            float hv = v; float dv = hv; // device v: read it back from dsrc region? use same hsrc bits
            memcpy(&vbh,&hv,4); memcpy(&vbd,&dv,4);
            float hscale = rscale[row], dscale_v = getscale[row];
            memcpy(&sbh,&hscale,4); memcpy(&sbd,&dscale_v,4);
            std::printf("   DIAG idx=%zu row=%zu col=%zu\n"
                        "        v bits host=0x%08x  scale bits host=0x%08x dev=0x%08x\n"
                        "        host v/scale=0x%08x (%.9g)  dev fdiv_rn=0x%08x (%.9g)  ULPdiff=%d\n"
                        "        dev=%d host=%d\n",
                        firstbad, row, col,
                        vbh, sbh, sbd,
                        hbits, hostprod, dbits, devprod, (int)(dbits - hbits),
                        (int)(signed char)gotpack[firstbad], (int)(signed char)rpack[firstbad]);
        }
        std::printf("%-22s m=%6u k=%4u flags=0x%x : packed %s (%zu/%zu)  scales %s (%zu)\n",
                    name, m, k, flags, badp ? "FAIL" : "OK", badp, gotpack.size(), bads ? "FAIL" : "OK", bads);
        if (badp || bads) fails++;
        // dump input + device outputs for the AUTHORITATIVE numpy gate (int8_quant.py).
        // The C++ host ref above is a convenience; the shipped contract is numpy's, so a
        // disagreement here may be the ref's bug, not the kernel's. Python decides.
        {
            char fn[96]; snprintf(fn, sizeof fn, "qr_%s.bin", name); for (char* p=fn; *p; ++p) if (*p==' ') *p='_';
            FILE* f = fopen(fn, "wb");
            if (f) {
                // the device consumed exactly this many source bytes: half path = 2/value,
                // e4m3 path = 1/value (byte container, read as consecutive codes).
                size_t src_bytes = e4m3src ? (size_t)m * k : ((flags & 0x400000u) ? (size_t)image_h * image_w * k * 2 : (size_t)m * k * 2);
                unsigned hdr[5] = { m, k, flags, (unsigned)e4m3src, (unsigned)src_bytes };
                fwrite(hdr, 4, 5, f);
                fwrite(hsrc.data(), 1, src_bytes, f);
                fwrite(gotpack.data(), 1, (size_t)m * k, f);
                fwrite(getscale.data(), 4, m, f);
                fclose(f);
            }
        }
        sycl::free(dsrc, q); sycl::free(dpack, q); sycl::free(dscale, q); sycl::free(drecip, q); sycl::free(dprod, q);
    };

    // frame-real shapes (ledger): l2 8160x64, l3 32640x64, l4 130560x32, l0 192x1024
    run_case(8160u, 64u, 0u, 0u, 0u, 0u, 0u, false, "plain l2");
    run_case(32640u, 64u, 0u, 0u, 0u, 0u, 0u, false, "plain l3");
    run_case(130560u, 32u, 0u, 0u, 0u, 0u, 0u, false, "plain l4 k32");
    run_case(192u, 1024u, 0u, 0u, 0u, 0u, 0u, false, "plain l0 k1024");
    run_case(8u*8u*8u, 64u, 0x400000u, 448u, 768u, 8u, (2u<<16)|3u, false, "window gather");
    run_case(2048u, 64u, 0x8000000u, 0u, 0u, 0u, 0u, true, "e4m3 container");
    run_case(64u, 8u, 0u, 0u, 0u, 0u, 0u, false, "tiny k8 words=1");

    std::printf("QRSYCL %s (%d fails)\n", fails ? "RED" : "GREEN", fails);
    return fails ? 2 : 0;
}
