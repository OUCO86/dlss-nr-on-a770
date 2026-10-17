// libxmx_sycl.cpp — the libxmx skeleton, route A' vertical slice.
//
// Proves the ARCHITECTURE (not just the bridge): the same C ABI xmxres.py binds
// (buffers as int handles, xmx_begin/record/xmx_submit), driving the proven
// quantize_row SYCL kernel. This is the shape the 81-function port will grow into;
// the rest (gemm/ffn/attention recorders, graph, D3D12 import) are additive once
// this slice is green.
//
// Model mirrors libxmx.c: a single device+queue at init (g.dev/g.q), buffers in a
// table keyed by int, a recording flag with a list of enqueued command groups, and
// submit that runs them in order. record/submit is faithful to what nr_replay.py
// depends on (begin -> rec_* -> submit), just with SYCL enqueues where libxmx had
// vkCmdDispatch into a command buffer.
//
// extern "C" + .def keep the C ABI intact for BOTH consumers (ctypes + nr_replay's
// GetProcAddress function pointers). See §20 + the abibridge gate for the proven base.
#include <sycl/sycl.hpp>
#include "quantize_row_kernel.hpp"
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "softmax_kernel.hpp"
#include "gemm_s8_v1_kernel.hpp"
#include "gemm_s8_v3_kernel.hpp"
#include "gemm_s8_v5_kernel.hpp"
#include <cstring>
#include <cstdio>
#include <vector>
#include <unordered_map>
#include <functional>

static sycl::queue* GQ = nullptr;
static sycl::device* GD = nullptr;
static char GERR[256] = {0};
#define FAILMSG(...) do { std::snprintf(GERR, sizeof GERR, __VA_ARGS__); return -1; } while (0)

// buffer table: int handle -> {device ptr, bytes, dtype-size}
struct Buf { void* p; size_t bytes; size_t esz; };
static std::unordered_map<int, Buf> g_bufs;
static int g_nextbuf = 1;

// recording
static bool g_recording = false;
static std::vector<std::function<void()>> g_cmds;

extern "C" {

const char* xmx_error(void) { return GERR; }

int xmx_init(void) {
    try {
        sycl::device dev;
        for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
            if (d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
        GD = new sycl::device(dev);
        GQ = new sycl::queue(dev);
        GERR[0] = 0;
        return 0;
    } catch (const std::exception& e) { FAILMSG("xmx_init: %s", e.what()); }
}

// int xmx_buf_create(unsigned long long bytes) — libxmx.c:96 shape. esz defaults 2 (half);
// the gate uses create_kind to set element size for int8/f32 outputs.
int xmx_buf_create_kind(unsigned long long bytes, int esz) {
    if (!GQ) FAILMSG("not initialised");
    if (!bytes || !esz) FAILMSG("bad buffer request");
    void* p = sycl::malloc_device<unsigned char>(bytes, *GQ);
    if (!p) FAILMSG("out of device memory");
    int id = g_nextbuf++;
    g_bufs[id] = { p, (size_t)bytes, (size_t)esz };
    return id;
}
int xmx_buf_create(unsigned long long bytes) { return xmx_buf_create_kind(bytes, 2); }

int xmx_buf_upload(int id, const void* src, unsigned long long off, unsigned long long n) {
    if (!GQ) FAILMSG("not initialised");
    auto it = g_bufs.find(id); if (it == g_bufs.end()) FAILMSG("no such buffer");
    GQ->memcpy((char*)it->second.p + off, src, n).wait();
    return 0;
}
int xmx_buf_download(int id, void* dst, unsigned long long off, unsigned long long n) {
    if (!GQ) FAILMSG("not initialised");
    auto it = g_bufs.find(id); if (it == g_bufs.end()) FAILMSG("no such buffer");
    GQ->memcpy(dst, (char*)it->second.p + off, n).wait();
    return 0;
}
int xmx_buf_zero(int id) {
    if (!GQ) FAILMSG("not initialised");
    auto it = g_bufs.find(id); if (it == g_bufs.end()) FAILMSG("no such buffer");
    GQ->memset(it->second.p, 0, it->second.bytes).wait();
    return 0;
}
int xmx_buf_destroy(int id) {
    auto it = g_bufs.find(id); if (it == g_bufs.end()) return 0;
    if (GQ) sycl::free(it->second.p, *GQ);
    g_bufs.erase(it); return 0;
}

int xmx_begin(void) { g_recording = true; g_cmds.clear(); return 0; }
int xmx_abort(void) { g_recording = false; g_cmds.clear(); return 0; }

// int xmx_rec_quant(int source, int packed, int scale, unsigned M, unsigned K)
// libxmx.c:2471 shape ([c_int]*3 + [c_uint]*2). Appends the proven SYCL kernel.
int xmx_rec_quant(int source, int packed, int scale, unsigned M, unsigned K) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !K || K % 16u) FAILMSG("quant needs K a multiple of 16");
    auto s = g_bufs.find(source), p = g_bufs.find(packed), c = g_bufs.find(scale);
    if (s == g_bufs.end() || p == g_bufs.end() || c == g_bufs.end()) FAILMSG("bad quant operand");
    sycl::half* a = (sycl::half*)s->second.p;
    sycl::uint2* pk = (sycl::uint2*)p->second.p;
    float* sc = (float*)c->second.p;
    g_cmds.push_back([=]() {
        qr_launch(*GQ, *GD, qr_kernel(), a, pk, sc, M, K, 0u, 0u, 0u, 0u, 0u, nullptr, nullptr);
    });
    return 0;
}

// int xmx_rec_gemm_s8(int a, int b, int c, unsigned M, unsigned N, unsigned K)
// PATH-VALIDATION cut: runs the senior's proven v1 ESIMD int8 GEMM (exact int32 out)
// through this skeleton's begin->rec->submit pipeline. a,b are RAW int8 matrices
// (M*K, K*N); c is int32 (M*N). The closure host-packs (VNNI) then launches — a
// faithful-but-slow simplification for the path gate; the real design packs static
// weights once at init and has the producer emit pre-packed activations (§9 single
// world), so packing is not in the timed loop. Shapes must satisfy M%128==0,
// N%64==0, K%32==0 (v1's constraint).
int xmx_rec_gemm_s8(int a, int b, int c, unsigned M, unsigned N, unsigned K) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (M % 128u) || (N % 64u) || (K % 32u))
        FAILMSG("gemm_s8 needs M%%128==0, N%%64==0, K%%32==0");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end()) FAILMSG("bad gemm operand");
    int8_t* Araw = (int8_t*)ia->second.p;
    int8_t* Braw = (int8_t*)ib->second.p;
    int32_t* C32 = (int32_t*)ic->second.p;
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * K, nb = (size_t)K * N;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, na).wait();
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v1::pack_a(hA.data(), hAp.data(), (int)M, (int)K);
        s8v1::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        int8_t* dAp = sycl::malloc_device<int8_t>(na, *GQ);
        int8_t* dCp = sycl::malloc_device<int8_t>(nb, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dCp, hBp.data(), nb).wait();
        s8v1::gemm_s8(*GQ, dAp, dCp, C32, (int)M, (int)N, (int)K).wait();
        sycl::free(dAp, *GQ); sycl::free(dCp, *GQ);
    });
    return 0;
}

// int xmx_rec_gemm_s8rq(int a, int b, int c8, int col_scale, int new_scale,
//                       unsigned M, unsigned N, unsigned K)
// v3's fused-requantize int8 GEMM through the skeleton pipeline. a,b raw int8; c8 int8
// out; col_scale float[N] (the b_scale dequant); new_scale float[M] (the per-row output
// grid). N must be 64 (v3's BN=64 whole-row constraint, section 24). Same host-pack
// simplification as xmx_rec_gemm_s8 (path gate, not the timed-loop design).
int xmx_rec_gemm_s8rq(int a, int b, int c8, int col_scale, int new_scale,
                      unsigned M, unsigned N, unsigned K) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (M % 128u) || (N != 64u) || (K % 32u))
        FAILMSG("gemm_s8rq needs M%%128==0, N==64, K%%32==0");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c8);
    auto ics = g_bufs.find(col_scale), ins = g_bufs.find(new_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        ics == g_bufs.end() || ins == g_bufs.end()) FAILMSG("bad gemm_s8rq operand");
    int8_t* Araw = (int8_t*)ia->second.p;
    int8_t* Braw = (int8_t*)ib->second.p;
    int8_t* C8 = (int8_t*)ic->second.p;
    float* cs = (float*)ics->second.p;
    float* ns = (float*)ins->second.p;
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * K, nb = (size_t)K * N;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, na).wait();
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v3::pack_a(hA.data(), hAp.data(), (int)M, (int)K);
        s8v3::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        int8_t* dAp = sycl::malloc_device<int8_t>(na, *GQ);
        int8_t* dCp = sycl::malloc_device<int8_t>(nb, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dCp, hBp.data(), nb).wait();
        s8v3::gemm_s8(*GQ, dAp, dCp, cs, C8, ns, (int)M, (int)N, (int)K).wait();
        sycl::free(dAp, *GQ); sycl::free(dCp, *GQ);
    });
    return 0;
}

int xmx_submit(void) {
    if (!g_recording) FAILMSG("not recording");
    try {
        for (auto& fn : g_cmds) fn();   // each qr_launch already .wait()s; ordered like the plan
    } catch (const std::exception& e) { g_cmds.clear(); g_recording = false; FAILMSG("submit: %s", e.what()); }
    g_cmds.clear(); g_recording = false;
    return 0;
}

// int xmx_rec_unary32(int source, int dst, unsigned count, unsigned epilogue)
// float32 elementwise publish — the rounding-point contract, gated bit-exact against
// nr_model (test_resident.py:65). count is in elements; kernel works in float4.
int xmx_rec_unary32(int source, int dst, unsigned count, unsigned epilogue) {
    if (!g_recording) FAILMSG("not recording");
    if (!count || (count & 3u)) FAILMSG("unary32 count must be a multiple of 4");
    auto s = g_bufs.find(source), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad unary operand");
    sycl::float4* sp = (sycl::float4*)s->second.p;
    sycl::float4* dp = (sycl::float4*)d->second.p;
    unsigned n4 = count / 4u;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(n4), unary_kernel()(sp, dp, n4, epilogue)).wait();
    });
    return 0;
}

// int xmx_rec_unary_i8(int source, int scale, int dst, unsigned count, unsigned cols,
//                      unsigned epilogue)
// chain tail: int8 producer output + per-row scale -> dequant (island-3, cr_mul) ->
// publish rounding chain (island-4) -> float32. count elements, row-major, scale is
// float[count/cols] one per row. This pass is what the OLD chain split into a
// dequant + publish round-trip; the straight-through chain pays it once, at the end.
int xmx_rec_unary_i8(int source, int scale, int dst, unsigned count, unsigned cols,
                     unsigned epilogue) {
    if (!g_recording) FAILMSG("not recording");
    if (!count || !cols || (count % cols)) FAILMSG("unary_i8 needs count a multiple of cols");
    auto s = g_bufs.find(source), c = g_bufs.find(scale), d = g_bufs.find(dst);
    if (s == g_bufs.end() || c == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad unary_i8 operand");
    const signed char* sp = (const signed char*)s->second.p;
    const float* scp = (const float*)c->second.p;
    float* dp = (float*)d->second.p;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(count), unary_i8_kernel()(sp, scp, dp, count, cols, epilogue)).wait();
    });
    return 0;
}

// int xmx_rec_cosine_norm(int source, int dst, unsigned rows, unsigned vit)
// island-2 building block: rows x 32 f32 -> cosine-normalised f32 (each output element
// half-rounded, exactly like nr_model.vendor_cosine_normalize / _vit_norm). Bit-exact
// gate, the senior's contract for the rounding points.
int xmx_rec_cosine_norm(int source, int dst, unsigned rows, unsigned vit) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows) FAILMSG("cosine_norm needs rows>0");
    auto s = g_bufs.find(source), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad cosine_norm operand");
    const float* sp = (const float*)s->second.p;
    float* dp = (float*)d->second.p;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         ctree::cosine_norm_kernel()(sp, dp, rows, vit, nullptr, 0)).wait();
    });
    return 0;
}

// int xmx_rec_cosine_norm_q(int source, int dst, int scale, unsigned rows, unsigned heads,
//                           unsigned vit)
// the Q variant: same tree, then the learned per-head scale applied after the norm
// (qkv_epilogue.glsl:52-54; vit inserts VIT_ROOT between). scale = float[heads].
int xmx_rec_cosine_norm_q(int source, int dst, int scale, unsigned rows, unsigned heads,
                          unsigned vit) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !heads || (rows % heads)) FAILMSG("cosine_norm_q needs heads | rows");
    auto s = g_bufs.find(source), d = g_bufs.find(dst), c = g_bufs.find(scale);
    if (s == g_bufs.end() || d == g_bufs.end() || c == g_bufs.end()) FAILMSG("bad cosine_norm_q operand");
    const float* sp = (const float*)s->second.p;
    float* dp = (float*)d->second.p;
    const float* scp = (const float*)c->second.p;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         ctree::cosine_norm_kernel()(sp, dp, rows, vit, scp, heads)).wait();
    });
    return 0;
}

// int xmx_rec_softmax(int source, int dst, unsigned rows, unsigned cols)
// island-1: the vendor's half bit-affine softmax, f32 logits (rows x cols, cols even) ->
// e4m3 probability halves. Bit-exact gate vs nr_model.vendor_approximate_softmax (:211).
int xmx_rec_softmax(int source, int dst, unsigned rows, unsigned cols) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !cols || (cols & 1u)) FAILMSG("softmax needs rows>0, even cols");
    auto s = g_bufs.find(source), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad softmax operand");
    const float* sp = (const float*)s->second.p;
    sycl::half* dp = (sycl::half*)d->second.p;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows), smax::softmax_kernel()(sp, dp, rows, cols)).wait();
    });
    return 0;
}

// int xmx_rec_gemm_qkv_v(int a, int b, int v, int a_scale, int b_scale,
//                        unsigned M, unsigned channels, unsigned heads, unsigned tokens)
// QKV V-branch fused epilogue (section 33/35): int8 GEMM -> dequantise (island-3) ->
// e4m3 (island-4) -> scatter to (window,head,token,32) halves, one pass. V skips the
// cosine normalise (qkv_epilogue.glsl:57), so no cross-WI float stage is needed -- this
// is the first QKV step; Q/K's fragment-tree branch comes next (it reuses the proven
// cosine_tree_kernel.hpp block). M % 128 == 0 (v1 geometry BM=128), channels % 64 == 0
// (xmxres.py:1331 guard), heads = channels/32. Same host-pack simplification as the
// other rec_gemm_* (path gate).
int xmx_rec_gemm_qkv_v(int a, int b, int v, int a_scale, int b_scale,
                       unsigned M, unsigned channels, unsigned heads, unsigned tokens) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !channels || !heads || !tokens || (M % 128u) || (channels % 64u))
        FAILMSG("gemm_qkv_v needs M%%128==0, channels%%64==0");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), iv = g_bufs.find(v);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || iv == g_bufs.end() ||
        ias == g_bufs.end() || ibs == g_bufs.end()) FAILMSG("bad gemm_qkv_v operand");
    int8_t* Araw = (int8_t*)ia->second.p;
    int8_t* Braw = (int8_t*)ib->second.p;
    sycl::half* V = (sycl::half*)iv->second.p;
    float* as = (float*)ias->second.p;
    float* bs = (float*)ibs->second.p;
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * channels, nb = (size_t)channels * channels;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, na).wait();
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v5::pack_a(hA.data(), hAp.data(), (int)M, (int)channels);
        s8v5::pack_b(hB.data(), hBp.data(), (int)channels, (int)channels);
        int8_t* dAp = sycl::malloc_device<int8_t>(na, *GQ);
        int8_t* dBp = sycl::malloc_device<int8_t>(nb, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dBp, hBp.data(), nb).wait();
        s8v5::gemm_qkv_v(*GQ, dAp, dBp, as, bs, V, (int)M, (int)channels,
                         (int)heads, (int)tokens).wait();
        sycl::free(dAp, *GQ); sycl::free(dBp, *GQ);
    });
    return 0;
}

// int xmx_rec_gemm_qkv_deq(int a, int b, int out, int a_scale, int b_scale,
//                          unsigned M, unsigned channels)
// S3a pass 1: int8 GEMM -> dequantise (island-3) -> float32 global, tile-local. The Q/K
// chain's first leg; the norm (cosine_norm_q) and publish+scatter (qkv_scatter) follow.
int xmx_rec_gemm_qkv_deq(int a, int b, int out, int a_scale, int b_scale,
                         unsigned M, unsigned channels) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !channels || (M % 128u) || (channels % 64u))
        FAILMSG("gemm_qkv_deq needs M%%128==0, channels%%64==0");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), io = g_bufs.find(out);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || io == g_bufs.end() ||
        ias == g_bufs.end() || ibs == g_bufs.end()) FAILMSG("bad gemm_qkv_deq operand");
    int8_t* Araw = (int8_t*)ia->second.p;
    int8_t* Braw = (int8_t*)ib->second.p;
    float* OUT = (float*)io->second.p;
    float* as = (float*)ias->second.p;
    float* bs = (float*)ibs->second.p;
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * channels, nb = (size_t)channels * channels;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, na).wait();
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v5::pack_a(hA.data(), hAp.data(), (int)M, (int)channels);
        s8v5::pack_b(hB.data(), hBp.data(), (int)channels, (int)channels);
        int8_t* dAp = sycl::malloc_device<int8_t>(na, *GQ);
        int8_t* dBp = sycl::malloc_device<int8_t>(nb, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dBp, hBp.data(), nb).wait();
        s8v5::gemm_qkv_deq(*GQ, dAp, dBp, as, bs, OUT, (int)M, (int)channels).wait();
        sycl::free(dAp, *GQ); sycl::free(dBp, *GQ);
    });
    return 0;
}

// int xmx_rec_qkv_scatter(int src, int dst, unsigned rows, unsigned heads, unsigned tokens)
// S3a pass 3: normalised f32 (row-major, channel=head*32+c) -> e4m3 -> (window,head,
// token,32) scatter. Plain SYCL, qr_e4m3 (PUBLISH-gated).
int xmx_rec_qkv_scatter(int src, int dst, unsigned rows, unsigned heads, unsigned tokens) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !heads || !tokens) FAILMSG("qkv_scatter needs rows/heads/tokens");
    auto s = g_bufs.find(src), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad qkv_scatter operand");
    const float* sp = (const float*)s->second.p;
    sycl::half* dp = (sycl::half*)d->second.p;
    unsigned n = rows * heads * 32u;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(n), qkv_scatter_kernel()(sp, dp, rows, heads, tokens)).wait();
    });
    return 0;
}

// int xmx_rec_gemm_qkv_qk(int a, int b, int t, int a_scale, int b_scale, int qkv_scale,
//                         unsigned M, unsigned channels, unsigned heads, unsigned tokens,
//                         unsigned vit, unsigned is_q)
// REMOVED (S3a): ESIMD cannot call the libdevice rounding ops the proven cosine tree uses.
// The Q/K chain is now three composed passes: xmx_rec_gemm_qkv_deq + xmx_rec_cosine_norm[_q]
// + xmx_rec_qkv_scatter. S3b folds them back into the main loop with esimd-native math.

} // extern "C"
