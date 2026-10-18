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
#include <level_zero/ze_api.h>
#include "quantize_row_kernel.hpp"
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "softmax_kernel.hpp"
#include "requant_kernel.hpp"
#include "gemm_s8_v1_kernel.hpp"
#include "gemm_s8_v3_kernel.hpp"
#include "gemm_s8_v5_kernel.hpp"
#include "gemm_s8_v7_kernel.hpp"
#include "gemm_s8_v8_kernel.hpp"
#include <cstring>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <unordered_map>
#include <functional>

static sycl::queue* GQ = nullptr;
static sycl::device* GD = nullptr;
static char GERR[256] = {0};
#define FAILMSG(...) do { std::snprintf(GERR, sizeof GERR, __VA_ARGS__); return -1; } while (0)

// buffer table: int handle -> {device ptr, bytes, dtype-size, imported}. An imported
// pointer (xmx_buf_import_win32) aliases a buffer owned by the OTHER engine -- freeing
// our import releases only our reference, the producer keeps the allocation alive.
struct Buf { void* p; size_t bytes; size_t esz; bool imported = false; };
static std::unordered_map<int, Buf> g_bufs;
static int g_nextbuf = 1;

// recording
static bool g_recording = false;
static std::vector<std::function<void()>> g_cmds;

extern "C" {

const char* xmx_error(void) { return GERR; }

int xmx_init(void) {
    try {
        std::fprintf(stderr, "[xmx_init] enumerated GPUs://n");
        for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
            std::fprintf(stderr, "   backend=%d name=%s\n", (int)d.get_backend(),
                         d.get_info<sycl::info::device::name>().c_str());
        std::fprintf(stderr, "[xmx_init] SYCL_DEVICE_FILTER now = %s\n",
                     getenv("SYCL_DEVICE_FILTER") ? getenv("SYCL_DEVICE_FILTER") : "(unset)");
        sycl::device dev;
        // the gate pairing (section 60) runs this dll IN THE SAME PROCESS as the shipped
        // Vulkan runtime: SYCL then enumerates the A770 through several adapters, and an
        // OpenCL-backed Arc would make get_native<ext_oneapi_level_zero> throw "Backends
        // mismatch". Pick the Arc that IS Level Zero-backed; fall back to name-only for
        // the standalone gates (their filter pins level_zero anyway, both paths agree).
        for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
            if (d.get_backend() == sycl::backend::ext_oneapi_level_zero &&
                d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
        if (dev.get_backend() != sycl::backend::ext_oneapi_level_zero)
            for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
                if (d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
        std::fprintf(stderr, "[xmx_init] chosen: backend=%d name=%s\n",
                     (int)dev.get_backend(), dev.get_info<sycl::info::device::name>().c_str());
        GD = new sycl::device(dev);
        GQ = new sycl::queue(dev);
        GERR[0] = 0;
        return 0;
    } catch (const std::exception& e) { FAILMSG("xmx_init: %s", e.what()); }
}

// int xmx_buf_create(unsigned long long bytes) — libxmx.c:96 shape. esz defaults 2 (half);
// the gate uses create_kind to set element size for int8/f32 outputs.
// int xmx_buf_create_kind(unsigned long long bytes, int kind) -- the GAME ABI's second
// argument is the buffer KIND (xmxres.py:283 GRAPH=0/HOST_READ=1/HOST_WRITE=2), which is
// what a walk of the plan feeds and what the shipped libxmx.c takes. It is metadata only
// for us: nothing addresses by it (every kernel gets explicit byte counts or plan args --
// checked), so the guard no longer rejects kind==0. esz was the old gate's misuse of the
// slot; kept as a stored field so buf_download sizing and import bookkeeping still have a
// width for the gates that pass one.
int xmx_buf_create_kind(unsigned long long bytes, int kind) {
    if (!GQ) FAILMSG("not initialised");
    if (!bytes) FAILMSG("bad buffer request");
    void* p = sycl::malloc_device<unsigned char>(bytes, *GQ);
    if (!p) FAILMSG("out of device memory");
    int id = g_nextbuf++;
    g_bufs[id] = { p, (size_t)bytes, (size_t)(kind == 0 ? 2 : kind) };
    return id;
}
int xmx_buf_create(unsigned long long bytes) { return xmx_buf_create_kind(bytes, 2); }

// int xmx_buf_import_win32(unsigned long long handle, unsigned long long bytes, int esz)
// P1 wiring (sections 58/59): take the OTHER engine's allocation as OUR device pointer.
// The shipped runtime already exports OPAQUE_WIN32 NT handles for its buffers (libxmx
// xmx_buf_exported / the extmem path); the probe (probe_vk_l0_import, section 59) proved
// GATE 1 -- zeMemAllocDevice with pNext=import_win32{OPAQUE_WIN32} returns a device
// pointer on this box (same A770, same daemon process -> the NT handle is directly
// usable, no duplication step; cross-PROCESS would DuplicateHandle first, the extmem
// path already does exactly that dance for semaphores). The recorders then eat the
// producer's bytes IN PLACE -- zero host copies, the single world at the buffer level.
static ze_driver_handle_t g_zdrv = nullptr;
static ze_context_handle_t g_zctx = nullptr;
static ze_device_handle_t  g_zdev = nullptr;
// bring up OUR OWN ze world once (never SYCL get_native: the paired-process opencl-adapter
// trap of section 60 only bites when borrowing SYCL handles). The section-18/59 probes'
// form: zeInit(GPU_ONLY), pick the Intel Arc, create our context. Same card, same driver,
// one more context in the process -- and gate_coexist proved it comes up fine even with a
// LIVE D3D12 device in the process (section 66), which is the game's actual condition.
static int ensure_ze_world() {
    if (g_zctx) return 0;
    // FIRST try to adopt SYCL's OWN Level-Zero context: import + upload/download then all
    // live in one runtime (the section-60 paired-Vulkan crash was exactly SYCL-queue-touching-
    // foreign-ze-memory). get_native<level_zero> only works if SYCL selected the L0 backend
    // here; section 60 saw OpenCL (backend=1) under Vulkan pairing -- gate_coexist's census
    // said the same under D3D12, so this probe records which it actually is.
    try {
        auto& q = *GQ;
        g_zctx = sycl::get_native<sycl::backend::ext_oneapi_level_zero>(q.get_context());
        g_zdev = sycl::get_native<sycl::backend::ext_oneapi_level_zero>(q.get_device());
        if (g_zctx && g_zdev) {
            std::fprintf(stderr, "[import] adopted SYCL's native L0 context (one runtime)\n");
            return 0;
        }
    } catch (...) {
        std::fprintf(stderr, "[import] get_native<level_zero> unavailable in this process "
                             "(SYCL on another backend); falling back to own ze context\n");
    }
    if (!GQ) FAILMSG("not initialised");
    ze_result_t r0 = zeInit(ZE_INIT_FLAG_GPU_ONLY);
    if (r0 != ZE_RESULT_SUCCESS) FAILMSG("zeInit: 0x%x", (unsigned)r0);
    uint32_t nd = 0; zeDriverGet(&nd, nullptr);
    std::vector<ze_driver_handle_t> ds(nd);
    if (nd) zeDriverGet(&nd, ds.data());
    for (uint32_t i = 0; i < nd && !g_zdev; ++i) {
        uint32_t m = 0; zeDeviceGet(ds[i], &m, nullptr);
        std::vector<ze_device_handle_t> dd(m); zeDeviceGet(ds[i], &m, dd.data());
        for (uint32_t j = 0; j < m; ++j) {
            ze_device_properties_t p = { ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES };
            zeDeviceGetProperties(dd[j], &p);
            if (p.type == ZE_DEVICE_TYPE_GPU && p.vendorId == 0x8086 &&
                std::strstr(p.name, "Arc")) { g_zdrv = ds[i]; g_zdev = dd[j]; break; }
        }
    }
    if (!g_zdev) FAILMSG("no Intel Arc GPU visible to Level Zero in this process");
    ze_context_desc_t cd = { ZE_STRUCTURE_TYPE_CONTEXT_DESC };
    ze_result_t rc = zeContextCreate(g_zdrv, &cd, &g_zctx);
    if (rc != ZE_RESULT_SUCCESS || !g_zctx) FAILMSG("zeContextCreate: 0x%x", (unsigned)rc);
    std::fprintf(stderr, "[import] own ze context live (driver+Arc device found)\n");
    return 0;
}
static int import_handle(unsigned long long handle, unsigned long long bytes, int esz,
                         ze_external_memory_type_flags_t kind) {
    if (ensure_ze_world() != 0) return -1;
    if (!handle || !bytes || esz <= 0) FAILMSG("bad import request");
    ze_external_memory_import_win32_handle_t mi = { ZE_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMPORT_WIN32 };
    mi.flags = kind;
    mi.handle = (void*)(uintptr_t)handle;
    mi.name = nullptr;
    ze_device_mem_alloc_desc_t dad = { ZE_STRUCTURE_TYPE_DEVICE_MEM_ALLOC_DESC };
    dad.pNext = &mi; dad.ordinal = 0;
    void* p = nullptr;
    ze_result_t r = zeMemAllocDevice(g_zctx, &dad, bytes, 256, g_zdev, &p);
    if (r != ZE_RESULT_SUCCESS || !p) FAILMSG("zeMemAllocDevice import(kind 0x%x): 0x%x",
                                              (unsigned)kind, (unsigned)r);
    int id = g_nextbuf++;
    g_bufs[id] = { p, (size_t)bytes, (size_t)esz, true };
    return id;
}
int xmx_buf_import_win32(unsigned long long handle, unsigned long long bytes, int esz) {
    return import_handle(handle, bytes, esz, ZE_EXTERNAL_MEMORY_TYPE_FLAG_OPAQUE_WIN32);
}
// int xmx_buf_import(handle, bytes) -- the GAME's ABI name (notes/game-abi-80.txt, grabbed
// by nr_replay.c:263; the shipping libxmx.c:3318 imports the bridge's D3D12 resource).
// Ours takes the SAME D3D12_RESOURCE kind into our own ze context: section 18's probe
// measured D3D12-resource -> L0 import with two-way BIT-EXACT data in one process -- the
// fused path's exact shape (the bridge holds the game's D3D12 objects; we import them),
// and NOT the Vulkan-export direction section 59 killed. esz=2 (half): the plan's
// feature/head buffers are half-width, like the shipped import's buffers.
int xmx_buf_import(unsigned long long handle, unsigned long long bytes) {
    return import_handle(handle, bytes, 2, ZE_EXTERNAL_MEMORY_TYPE_FLAG_D3D12_RESOURCE);
}

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
    if (it->second.imported)
        zeMemFree(g_zctx, it->second.p);       // drop OUR reference; producer owns the memory
    else if (GQ)
        sycl::free(it->second.p, *GQ);
    g_bufs.erase(it); return 0;
}

int xmx_begin(void) { g_recording = true; g_cmds.clear(); return 0; }
int xmx_abort(void) { g_recording = false; g_cmds.clear(); return 0; }

// int xmx_graph_capture(void) -> id ; int xmx_graph_run(int id) -> passes ; destroy(id)
// Route (a) step 1 (section 64): the plan says which graph ran "as the number it had
// that once" (nr_replay.c:505-507 -- r->graph = the capture's return, run/destroy use
// it), so the slot NUMBER returned by capture is replayed verbatim; an ordinary
// sequential slot id matches the shipped convention (first capture -> 0). The frozen
// cmds run the SAME device buffers they captured pointers for, so operands written
// after capture are read fresh at replay -- exactly the shipped command-buffer
// semantics (ops frozen, memory live). The lambdas still carry the host pack/upload
// of today's recorders; the pack moves device-side when the chains themselves
// fuse -- step 1 only has to prove freeze/replay identity and the ordering.
static std::vector<std::vector<std::function<void()>>> g_graphs;
int xmx_graph_capture(void) {
    if (!g_recording) FAILMSG("not recording");
    g_graphs.push_back(std::move(g_cmds));
    g_cmds.clear();
    g_recording = false;
    return (int)g_graphs.size() - 1;
}
int xmx_graph_run(int id) {
    if (g_recording) FAILMSG("cannot replay during recording");
    if (id < 0 || id >= (int)g_graphs.size() || g_graphs[id].empty())
        FAILMSG("graph is not live");
    int passes = (int)g_graphs[id].size();
    try {
        for (auto& fn : g_graphs[id]) fn();     // same order, wait-per-kernel like submit
    } catch (const std::exception& e) { FAILMSG("graph_run: %s", e.what()); }
    return passes;
}
int xmx_graph_destroy(int id) {
    if (id < 0 || id >= (int)g_graphs.size()) return 0;
    g_graphs[id].clear();
    return 0;
}
int xmx_idle(void) {
    if (!GQ) FAILMSG("no device");
    try { GQ->wait(); } catch (const std::exception& e) { FAILMSG("idle: %s", e.what()); }
    return 0;
}

/* ---------------------------------------------------------------------------
 * route(a) step 3 (section 68): the MACHINERY face of the game ABI. nr_replay's
 * prepare() GRABs these names, and the shipped plan's first 2534 steps are all of
 * them -- buf/buf_ptr/begin/init/specialize. The inits register .spv pipelines in the
 * shipping library; we have ESIMD kernels compiled in, so each init is a one-time
 * registration (the shipped ones are idempotent exactly the same way: libxmx.c
 * `if (g.rquant) return 0`), and the spv PATHS are recorded for honesty but never
 * loaded. specialize keeps the shipped guard (mask 0..7, not during recording).
 * ------------------------------------------------------------------------- */
static int g_specialize = 0;
static unsigned g_init_seen = 0;         // bitset, one bit per init family
const char* xmx_device(void) { return GD ? GD->get_info<sycl::info::device::name>().c_str() : ""; }
// int xmx_buf_ptr(int id) -- the shipped entry hands the host a MAPPED pointer; the
// replayer never uses it (nr_replay.c:473-478: the blobs go in by xmx_buf_upload, "the
// same bytes, into the same buffer"), and our walk follows that precedent: return 0 and
// let the harness upload. Buffers here are unmapped device memory by design (P3).
int xmx_buf_ptr(int id) { (void)id; return 0; }
int xmx_sync(int on) { (void)on; return 0; }   // ours is synchronous per pass; nothing to gate

static int init_once(unsigned bit) {
    g_init_seen |= bit;
    return 0;   // one-time registration of a compiled-in kernel, like the shipped guard
}
int xmx_res_init(const char* a, const char* b, const char* c, const char* d, const char* e, const char* f) { (void)a;(void)b;(void)c;(void)d;(void)e;(void)f; return init_once(1u<<0); }
int xmx_rows_init(const char* path) { (void)path; return init_once(1u<<1); }
int xmx_staged32_init(const char* a, const char* b) { (void)a;(void)b; return init_once(1u<<2); }
int xmx_tiled32_init(const char* path) { (void)path; return init_once(1u<<3); }
int xmx_tiled8_init(const char* path) { (void)path; return init_once(1u<<4); }
int xmx_window_init(const char* path, unsigned merged) { (void)path; if (merged > 1) FAILMSG("invalid window attention output mode"); return init_once(1u<<5); }
int xmx_ffn_init(const char* path) { (void)path; return init_once(1u<<6); }
int xmx_int8_init(const char* path) { (void)path; return init_once(1u<<7); }
int xmx_int8_fused_init(const char* path) { (void)path; return init_once(1u<<8); }
int xmx_int8_residual_init(const char* path) { (void)path; return init_once(1u<<9); }
int xmx_quant_init(const char* path) { (void)path; return init_once(1u<<10); }
int xmx_global_attention_init(const char* path) { (void)path; return init_once(1u<<11); }
int xmx_window_block_init(const char* path) { (void)path; return init_once(1u<<12); }
int xmx_prepost_init(const char* a, const char* b) { (void)a;(void)b; return init_once(1u<<13); }
int xmx_specialize(unsigned mask) {
    if (g_recording) FAILMSG("cannot switch specialization during recording");
    if (mask > 7) FAILMSG("specialization mask must be in 0..7");
    g_specialize = (int)mask;
    return 0;
}
unsigned xmx_specialized_count(void) { return 0; }
unsigned xmx_specialization(void) { return (unsigned)g_specialize; }

// extmem/sem stubs (the walk calls none of them: the fence leg lives in nr_replay's
// direct ABI path, section 68's finding; the gate in step 4 drives the game-shaped
// two-import flow through the section-18 primitives -- these keep prepare() from
// failing at GRAB time so a real nr_replay can load my dll).
static int g_xsem = 0;
int xmx_sem_import(unsigned long long handle, int timeline) { (void)handle; (void)timeline; return ++g_xsem; }
int xmx_sem_import_fence(unsigned long long handle) { (void)handle; return ++g_xsem; }
unsigned long long xmx_sem_value(int id) { (void)id; return 0; }
int xmx_extmem_wait(int id, unsigned long long value) { (void)id; (void)value; return 0; }
int xmx_extmem_wait_clear(void) { return 0; }
int xmx_extmem_wait_pending(void) { return 0; }

/* prepare()-required recorder names the CURRENT plan does NOT walk (section 68's split:
   15 swap-in targets the plan DOES walk, vs these fused-path names nr_replay GRABs only
   because it shares one prepare() with the game's fused mode). NOT fakes: the moment the
   walk or a fused run calls one, it fails loudly with a named reason, so a green walk
   never hides a pass that would have been silently skipped. */
/* Two faces of the placeholders (section 64 step 3, the user's sequence option 1):
   GAME face (default): fail LOUD -- a swapped-in dll that hit an unimplemented pass
   refuses the frame instead of silently skipping it, so no image can ever lie.
   WALK face (NR_L0_PERMISSIVE=1, offline scoreboard only): count the call, skip it,
   keep walking -- the ruler then measures ABI/shape acceptance across all 5254 steps
   while the per-recorder numerics keep their own section-51 gates. The two faces are
   one getenv apart and the banner prints which is live, so a permissive run can never
   be mistaken for a game run. */
static int l0_permissive() {
    static int cached = -1;
    if (cached < 0) cached = getenv("NR_L0_PERMISSIVE") ? 1 : 0;
    return cached;
}
#define NOT_YET(name) do { \
    if (l0_permissive()) { static int warned = 0; if (!warned) { warned = 1; \
        std::fprintf(stderr, "[permissive] walk scoreboard mode: unimplemented passes are counted and SKIPPED -- offline ABI ruler only, never the game face\n"); } \
        g_skipped[name[4]] = (g_skipped[name[4]] + 1) % 100000; return 0; } \
    FAILMSG("%s not implemented on the Level-Zero engine (walk must not call it; fused-path leg, section 64 step 3)", name); return -1; } while(0)
static int g_skipped[256];
int xmx_rec_pre(int c,int m,int h,int f,int pl,unsigned px,unsigned ht,unsigned wd,unsigned pt,unsigned sh,unsigned sw,unsigned fl,int tb) { (void)c;(void)m;(void)h;(void)f;(void)pl;(void)px;(void)ht;(void)wd;(void)pt;(void)sh;(void)sw;(void)fl;(void)tb; NOT_YET("xmx_rec_pre"); }
int xmx_rec_post(int c,int hd,int h,int rs,int tb,int nl,unsigned px,unsigned ht,unsigned wd,unsigned pt,unsigned sh,unsigned sw) { (void)c;(void)hd;(void)h;(void)rs;(void)tb;(void)nl;(void)px;(void)ht;(void)wd;(void)pt;(void)sh;(void)sw; NOT_YET("xmx_rec_post"); }
int xmx_rec_gemm_qkv(int a,int w,int q,int k,int v,int sc,unsigned M,unsigned ch,unsigned hd,unsigned tk,unsigned vt) { (void)a;(void)w;(void)q;(void)k;(void)v;(void)sc;(void)M;(void)ch;(void)hd;(void)tk;(void)vt; NOT_YET("xmx_rec_gemm_qkv"); }
int xmx_rec_gemm_qkv_window(int im,int w,int q,int k,int v,int sc,unsigned M,unsigned ch,unsigned hd,unsigned tk,unsigned wd,unsigned ht,unsigned ac,unsigned pd,unsigned im2) { (void)im;(void)w;(void)q;(void)k;(void)v;(void)sc;(void)M;(void)ch;(void)hd;(void)tk;(void)wd;(void)ht;(void)ac;(void)pd;(void)im2; NOT_YET("xmx_rec_gemm_qkv_window"); }
int xmx_rec_gemm_residual(int a,int b,int c,int sk,int co,unsigned M,unsigned N,unsigned K,unsigned fl) { (void)a;(void)b;(void)c;(void)sk;(void)co;(void)M;(void)N;(void)K;(void)fl; NOT_YET("xmx_rec_gemm_residual"); }
int xmx_rec_gemm_window_residual(int a,int b,int c,int sk,int co,unsigned M,unsigned N,unsigned K,unsigned fl,unsigned ht,unsigned wd,unsigned ac,unsigned pd) { (void)a;(void)b;(void)c;(void)sk;(void)co;(void)M;(void)N;(void)K;(void)fl;(void)ht;(void)wd;(void)ac;(void)pd; NOT_YET("xmx_rec_gemm_window_residual"); }
int xmx_rec_gemm_int8_fused(int a,int b,int c,int as,int bs,unsigned M,unsigned N,unsigned K,unsigned fl) { (void)a;(void)b;(void)c;(void)as;(void)bs;(void)M;(void)N;(void)K;(void)fl; NOT_YET("xmx_rec_gemm_int8_fused"); }

/* swap-in TARGETS (section 68 A-list): names exist so prepare() GRABs them; every one
   fails loudly if reached. As each is implemented (a green chain gated + diffed), its
   stub is replaced by the real recorder -- the scoreboard is "the first target that still
   answers NOT_YET", which walks down the plan as we implement. */
int xmx_rec_ffn(int a, int expand, int projection, int out, int skip, int cosine, int M, int cin, int hidden, int groups, int flags) { (void)a; (void)expand; (void)projection; (void)out; (void)skip; (void)cosine; (void)M; (void)cin; (void)hidden; (void)groups; (void)flags; NOT_YET("xmx_rec_ffn"); }
int xmx_rec_ffn_merge(int source, int skip, int sincos, int expand, int projection, int out, int cosine, int height, int width, int source_width, int flags) { (void)source; (void)skip; (void)sincos; (void)expand; (void)projection; (void)out; (void)cosine; (void)height; (void)width; (void)source_width; (void)flags; NOT_YET("xmx_rec_ffn_merge"); }
int xmx_rec_ffn_stem(int features, int adapter, int expand, int projection, int out, int cosine, int M, int flags) { (void)features; (void)adapter; (void)expand; (void)projection; (void)out; (void)cosine; (void)M; (void)flags; NOT_YET("xmx_rec_ffn_stem"); }
int xmx_rec_gemm(int a, int b, int c, int M, int N, int K, int batch, int sa, int sb, int sc, int bt, int lda, int ldb, int ldc, int oa, int ob, int oc) { (void)a; (void)b; (void)c; (void)M; (void)N; (void)K; (void)batch; (void)sa; (void)sb; (void)sc; (void)bt; (void)lda; (void)ldb; (void)ldc; (void)oa; (void)ob; (void)oc; NOT_YET("xmx_rec_gemm"); }
// int xmx_rec_gemm_int8(int a, int b, int c, int a_scale, int b_scale,
//                       unsigned M, unsigned N, unsigned K, unsigned flags)
// route(a) swap-in #1 (sections 70-71, the user-approved two-pass plan): the plan's
// first GEMM family -- (A,B) int8 with B STORED TRANSPOSED (N x K, libxmx.c:2877), C
// the PUBLISHED answer: float32(acc) * a_scale[row] * b_scale[col] -> publish(epi) ->
// f16 (bit 0x1000 narrow) or f32, exactly gemm_staged_int8.comp's non-residual branch
// (:288-297). Pass 1 = the v8 fork (v1's proven loop, transposed pack_b, M padded to a
// whole BM block -- padded rows are garbage we never publish); pass 2 = the gated
// publish arithmetic (qr_publish, bit-exact) elementwise. The multiply chain is two
// cr_mul links, never a contracted fma (publish_kernel's standing rule).
// flags: bits 8-11 epilogue, 0x1000 narrow-half (xmxres._publish); both plan families
// set narrow: 4352=e4m3+half, 4864=gate->e4m3+half (section 71).
static inline int l0_ceil_bm(unsigned M) { return (int)(((M + 127u) / 128u) * 128u); }
int xmx_rec_gemm_int8(int a, int b, int c, int a_scale, int b_scale,
                      unsigned M, unsigned N, unsigned K, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (N % 64u) || (K % 32u))
        FAILMSG("gemm_int8 needs N%%64==0, K%%32==0 (our tile; shipped guard is N%%32/K%%64)");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        ias == g_bufs.end() || ibs == g_bufs.end()) FAILMSG("bad gemm_int8 operand");
    const int8_t* Araw = (const int8_t*)ia->second.p;
    const int8_t* Braw = (const int8_t*)ib->second.p;
    void* Cout = ic->second.p;
    const float* as = (const float*)ias->second.p;
    const float* bs = (const float*)ibs->second.p;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const int Mp = l0_ceil_bm(M);
    const size_t na = (size_t)Mp * K, nb = (size_t)N * K;
    g_cmds.push_back([=]() {
        std::vector<int8_t> hA((size_t)M * K), hApad(na, 0), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, (size_t)M * K).wait();
        std::memcpy(hApad.data(), hA.data(), (size_t)M * K);   // pad rows stay zero
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v8::pack_a(hApad.data(), hAp.data(), Mp, (int)K);
        s8v8::pack_b(hB.data(), hBp.data(), (int)N, (int)K);   // B arrives TRANSPOSED
        int8_t* dAp = (int8_t*)sycl::malloc_device(na, *GQ);
        int8_t* dBp = (int8_t*)sycl::malloc_device(nb, *GQ);
        int32_t* dC = (int32_t*)sycl::malloc_device((size_t)Mp * N * 4, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dBp, hBp.data(), nb).wait();
        s8v8::gemm(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K).wait();
        GQ->parallel_for(sycl::range((size_t)M * N),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / N), col = (unsigned)(i % N);
            float v = cr_mul(cr_mul((float)dC[(size_t)r * N + col], as[r]), bs[col]);
            if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, v));
            else        ((float*)Cout)[i] = qr_publish(epi, v);
        }).wait();
        sycl::free(dAp, *GQ); sycl::free(dBp, *GQ); sycl::free(dC, *GQ);
    });
    return 0;
}
// int xmx_rec_gemm_int8_batched(a,b,c,a_scale,b_scale,M,N,K,batch,sa,sb,sc,
//                               lda,ldb,ldc,scale_stride,flags)
// swap-in #2 (section 71 two-pass plan): batched = `batch` INDEPENDENT GROUPS, each a
// dense (M,K)x(N,K-transposed) product whose operands are COL SLICES of wider buffers.
// The group math is read straight from gemm_staged_int8.comp:132-147 and verified
// against the plan's six real variants (section 73):
//   A row r of group g : Araw + r*lda + g*sa   (lda==0 -> K; sa bytes, sa==0 broadcasts A)
//   B row n of group g : Braw + n*ldb + g*sb   (ldb==0 -> K; sb==0 shares the weights)
//   C row r of group g :  Cout + g*sc + r*ldc + col   (ldc==0 -> N, sc ELEMENTS)
//   a_scale index r    : as + g*scale_stride           (.comp roff, 0 = groups share row scales)
//   b_scale index col  : sb!=0 ? bs + g*N : bs         (.comp soff)
// Group slices are gathered DENSE on the host (this is the path gate; the stride gathers
// die when the producer owns the layout, section 9's single world), then each group runs
// v8's BN=64 loop in column blocks of 64 with a BN=32 tail (gemm32: v7's loop geometry,
// raw int32 store), then the gated elementwise publish lands at the ldc-strided slot.
int xmx_rec_gemm_int8_batched(int a, int b, int c, int a_scale, int b_scale,
                              unsigned M, unsigned N, unsigned K, unsigned batch,
                              unsigned sa, unsigned sb, unsigned sc,
                              unsigned lda, unsigned ldb, unsigned ldc,
                              unsigned scale_stride, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || !batch) FAILMSG("gemm_int8_batched needs M,N,K,batch nonzero");
    if ((N % 32u) || (K % 32u)) FAILMSG("gemm_int8_batched needs N%%32==0, K%%32==0");
    const unsigned lda_ = lda ? lda : K, ldb_ = ldb ? ldb : K, ldc_ = ldc ? ldc : N;
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        ias == g_bufs.end() || ibs == g_bufs.end()) FAILMSG("bad gemm_int8_batched operand");
    const int8_t* Araw = (const int8_t*)ia->second.p;
    const int8_t* Braw = (const int8_t*)ib->second.p;
    void* Cout = ic->second.p;
    const float* as = (const float*)ias->second.p;
    const float* bs = (const float*)ibs->second.p;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const int Mp = l0_ceil_bm(M);
    g_cmds.push_back([=]() {
        const size_t a_slice = (size_t)M * K, b_slice = (size_t)N * K;
        const unsigned lda_e = lda ? lda : K, ldb_e = ldb ? ldb : K;
        // Copy the WIDE buffers back whole (device->host via the queue -- std::memcpy on a
        // device pointer is the access violation the first batched gate run hit, my stride
        // fix's own bug), then the group slice-gather is plain HOST arithmetic.
        // EXACT max-touched sizes ((rows-1)*stride + advance + row), NOT rows*stride --
        // with lda>K the old form over-read the buffer by lda-K bytes (caught reading my
        // own gather back against the gate harness sizes).
        const size_t aw_b = (size_t)(M - 1) * lda_e + (size_t)(batch - 1) * sa + K;
        const size_t bw_b = (size_t)(N - 1) * ldb_e + (size_t)(batch - 1) * sb + K;
        std::vector<int8_t> hAw(aw_b), hBw(bw_b);
        GQ->memcpy(hAw.data(), Araw, aw_b).wait();
        GQ->memcpy(hBw.data(), Braw, bw_b).wait();
        for (unsigned g = 0; g < batch; ++g) {
            const size_t ce = (size_t)g * sc;                       // C advance (elements)
            // GATHER the group's COL-SLICED operands dense (the stride lesson of section
            // 73's first gate run: rows are lda bytes apart, the group advances sa BYTES):
            std::vector<int8_t> hA(a_slice), hB(b_slice);
            for (unsigned r = 0; r < M; ++r)
                std::memcpy(hA.data() + (size_t)r * K, hAw.data() + (size_t)r * lda_e + (size_t)g * sa, K);
            for (unsigned n = 0; n < N; ++n)
                std::memcpy(hB.data() + (size_t)n * K, hBw.data() + (size_t)n * ldb_e + (size_t)g * sb, K);
            std::vector<int8_t> hApad((size_t)Mp * K, 0), hAp((size_t)Mp * K), hBp(b_slice);
            std::memcpy(hApad.data(), hA.data(), a_slice);
            s8v8::pack_a(hApad.data(), hAp.data(), Mp, (int)K);
            // column blocks: 64 each plus a 32 tail if N%64
            int nb64 = (int)(N / 64u);
            unsigned nrem = N % 64u;
            float* gas = (float*)as + (size_t)g * scale_stride;   // roff (.comp:143)
            float* gbs = (sb != 0u) ? ((float*)bs + (size_t)g * N) : (float*)bs;  // soff (.comp:147)
            for (int blk = 0; blk <= ((nrem && nb64 >= 0) ? nb64 : nb64 - 1); ++blk) {
                unsigned c0 = (unsigned)blk * 64u;
                unsigned n64 = (nrem && blk == nb64) ? nrem : 64u;
                // dense (M,K)x(N,64-slice) at this group's slice, packed per block
                std::vector<int8_t> Bt((size_t)n64 * K), Bp((size_t)n64 * K);
                for (unsigned r = 0; r < n64; ++r)
                    std::memcpy(Bt.data() + (size_t)r * K, hB.data() + (size_t)(c0 + r) * K, K);
                if (n64 == 64u) s8v8::pack_b(Bt.data(), Bp.data(), (int)n64, (int)K);
                else            s8v8::pack_b32(Bt.data(), Bp.data(), (int)n64, (int)K);
                int8_t* dAp = (int8_t*)sycl::malloc_device((size_t)Mp * K, *GQ);
                int8_t* dBp = (int8_t*)sycl::malloc_device((size_t)n64 * K, *GQ);
                int32_t* dC = (int32_t*)sycl::malloc_device((size_t)Mp * n64 * 4, *GQ);
                GQ->memcpy(dAp, hAp.data(), (size_t)Mp * K).wait();
                GQ->memcpy(dBp, Bp.data(), (size_t)n64 * K).wait();
                if (n64 == 64u) s8v8::gemm(*GQ, dAp, dBp, dC, Mp, (int)n64, (int)K).wait();
                else            s8v8::gemm32(*GQ, dAp, dBp, dC, Mp, (int)n64, (int)K).wait();
                // publish this block into the ldc-strided output (only real M rows)
                GQ->parallel_for(sycl::range((size_t)M * n64),
                                 [=](sycl::item<1> it) {
                    size_t i = it.get_id(0);
                    unsigned r = (unsigned)(i / n64), col = (unsigned)(i % n64);
                    float v = cr_mul(cr_mul((float)dC[(size_t)r * n64 + col], gas[r]), gbs[c0 + col]);
                    size_t out = ce + (size_t)r * ldc_ + (c0 + col);
                    if (narrow) ((sycl::half*)Cout)[out] = sycl::half(qr_publish(epi, v));
                    else        ((float*)Cout)[out] = qr_publish(epi, v);
                }).wait();
                sycl::free(dAp, *GQ); sycl::free(dBp, *GQ); sycl::free(dC, *GQ);
            }
        }
    });
    return 0;
}
int xmx_rec_gemm_int8_qkv(int a, int b, int q, int k, int v, int a_scale, int b_scale, int qkv_scale, int M, int channels, int heads, int tokens, int flags) { (void)a; (void)b; (void)q; (void)k; (void)v; (void)a_scale; (void)b_scale; (void)qkv_scale; (void)M; (void)channels; (void)heads; (void)tokens; (void)flags; NOT_YET("xmx_rec_gemm_int8_qkv"); }
// int xmx_rec_gemm_int8_residual(int a, int b, int c, int a_scale, int b_scale,
//                                 int skip, int cosine, unsigned M, unsigned N,
//                                 unsigned K, unsigned flags)
// swap-in #3 (section 74). .comp:257-281 is the authority, read before writing either
// side (section 73's lesson: pin the shipping formula in the comment, golden and device
// both follow it):
//   at = r*N + c (non-window; the window variant is its own op, 0x80000 rejected here)
//   stage = f32(acc) * row_scale  * col_scale    (two f32 muls, .comp:279)
//   total = fma( skipped, cosine[c], stage )    -- ONE fused rounding (.comp:278), and
//           the comment says why: "Written as the fused multiply-add... contracted the
//           other way and missed by an ulp" is exactly the failure mode this fma is
//           immune to. Device: sycl::fma (HW FMA). Golden: f64-exact sum (f16x f32 <=
//           35 bits, + f32 term: exact iff exponent gap <= 18, asserted per element).
//   skip dtype: half iff 0x40000 (half_skip), else f32 (.comp:274-275). cosine: f32[N].
//   (The push-word aliasing -- skip riding the a_scale slot, cosine the b_scale slot,
//    real scales at .d/.residual_cos, libxmx.c:2985-2992 -- is a Vulkan detail: the ABI
//    hands us separate buffer ids, so we just read them.)
int xmx_rec_gemm_int8_residual(int a, int b, int c, int a_scale, int b_scale,
                               int skip, int cosine,
                               unsigned M, unsigned N, unsigned K, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (N % 64u) || (K % 32u))
        FAILMSG("gemm_int8_residual needs N%%64==0, K%%32==0 (our tile; shipped N%%32/K%%64)");
    if (flags & 0x80000u) FAILMSG("window variant belongs to xmx_rec_gemm_window_int8_residual");
    // 0x20000 (adding) is OR'd INSIDE the Vulkan wrapper (libxmx.c:2988 `flags | 0x20000`);
    // the plan/Python layer flags never carry it (266496 = 0x41100 has 0x40000+0x1000+epi1).
    // This op IS the adding variant, so there is nothing to require -- and nothing to copy
    // the wrapper bit into: the data semantics below always fuse skip*cosine.
    if (flags & 0x100000u) FAILMSG("the integer QKV and residual epilogues read the same two push words");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    auto isk = g_bufs.find(skip), ico = g_bufs.find(cosine);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        ias == g_bufs.end() || ibs == g_bufs.end() ||
        isk == g_bufs.end() || ico == g_bufs.end()) FAILMSG("bad gemm_int8_residual operand");
    const int8_t* Araw = (const int8_t*)ia->second.p;
    const int8_t* Braw = (const int8_t*)ib->second.p;   // TRANSPOSED (N x K), section 71
    void* Cout = ic->second.p;
    const float* as = (const float*)ias->second.p;
    const float* bs = (const float*)ibs->second.p;
    const void* skp = isk->second.p;
    const float* cp = (const float*)ico->second.p;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const bool half_skip = (flags & 0x40000u) != 0u;
    const int Mp = l0_ceil_bm(M);
    const size_t na = (size_t)Mp * K, nb = (size_t)N * K;
    g_cmds.push_back([=]() {
        std::vector<int8_t> hA((size_t)M * K), hApad(na, 0), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, (size_t)M * K).wait();
        std::memcpy(hApad.data(), hA.data(), (size_t)M * K);
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v8::pack_a(hApad.data(), hAp.data(), Mp, (int)K);
        s8v8::pack_b(hB.data(), hBp.data(), (int)N, (int)K);
        int8_t* dAp = (int8_t*)sycl::malloc_device(na, *GQ);
        int8_t* dBp = (int8_t*)sycl::malloc_device(nb, *GQ);
        int32_t* dC = (int32_t*)sycl::malloc_device((size_t)Mp * N * 4, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dBp, hBp.data(), nb).wait();
        s8v8::gemm(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K).wait();
        GQ->parallel_for(sycl::range((size_t)M * N),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / N), col = (unsigned)(i % N);
            float stage = cr_mul(cr_mul((float)dC[i], as[r]), bs[col]);
            float sk = half_skip ? (float)((const sycl::half*)skp)[i] : ((const float*)skp)[i];
            float total = sycl::fma(sk, cp[col], stage);
            if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
            else        ((float*)Cout)[i] = qr_publish(epi, total);
        }).wait();
        sycl::free(dAp, *GQ); sycl::free(dBp, *GQ); sycl::free(dC, *GQ);
    });
    return 0;
}
int xmx_rec_gemm_window_int8_residual(int a, int b, int c, int a_scale, int b_scale, int skip, int cosine, int M, int N, int K, int flags, int height, int width, int across, int pad) { (void)a; (void)b; (void)c; (void)a_scale; (void)b_scale; (void)skip; (void)cosine; (void)M; (void)N; (void)K; (void)flags; (void)height; (void)width; (void)across; (void)pad; NOT_YET("xmx_rec_gemm_window_int8_residual"); }
int xmx_rec_global_attention(int q, int k, int v, int merged, int rows, int tokens, int heads) { (void)q; (void)k; (void)v; (void)merged; (void)rows; (void)tokens; (void)heads; NOT_YET("xmx_rec_global_attention"); }
int xmx_rec_quant_window(int source, int packed, int scale, int M, int K, int height, int width, int across, int pad) { (void)source; (void)packed; (void)scale; (void)M; (void)K; (void)height; (void)width; (void)across; (void)pad; NOT_YET("xmx_rec_quant_window"); }
int xmx_rec_unary(int kind, int a, int b, int c, int d, int n, int channels, int p0, int batch, int sa, int sb, int sc, int k) { (void)kind; (void)a; (void)b; (void)c; (void)d; (void)n; (void)channels; (void)p0; (void)batch; (void)sa; (void)sb; (void)sc; (void)k; NOT_YET("xmx_rec_unary"); }
int xmx_rec_unary2(int kind, int a, int b, int c, int d, int second, int n, int channels, int p0, int batch, int sa, int sb, int sc, int k) { (void)kind; (void)a; (void)b; (void)c; (void)d; (void)second; (void)n; (void)channels; (void)p0; (void)batch; (void)sa; (void)sb; (void)sc; (void)k; NOT_YET("xmx_rec_unary2"); }
int xmx_rec_window_attention(int q, int k, int v, int bias, int out, int batches, int heads, int merged) { (void)q; (void)k; (void)v; (void)bias; (void)out; (void)batches; (void)heads; (void)merged; NOT_YET("xmx_rec_window_attention"); }
int xmx_rec_window_block(int image, int qkv, int projection, int target, int bias, int cosine, int scale, int pooled, int windows, int height, int width, int across, int pad, int flags) { (void)image; (void)qkv; (void)projection; (void)target; (void)bias; (void)cosine; (void)scale; (void)pooled; (void)windows; (void)height; (void)width; (void)across; (void)pad; (void)flags; NOT_YET("xmx_rec_window_block"); }

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

// int xmx_rec_gemm_s8rq32(int a, int b, int c8, int a_scale, int col_scale, int new_scale,
//                         unsigned M, unsigned N, unsigned K)
// v7's BN=32 fused-requant GEMM (route-B attnV/outproj, sections 50 point 3 / 52). N==32
// (head_dim) -- the shape xmx_rec_gemm_s8rq's v3 (N==64) cannot carry and v1 (N%64) rejects;
// building it instead of deferring to the megakernel is section 50's "don't lower the bar".
// FOLDS BOTH scales: fp = float(acc) * a_scale[row] * b_scale[col] (shipped left-to-right).
// attnV's A row scale = softmax_i8's probs ps_q along M (non-reduction); it does NOT cancel
// the way the S1 chain's does -- attended[q,ch] = ps_q*vs_ch*acc, and new_scale must carry
// ps_q for the downstream outproj to see the true amplitude (section 52's a_scale analysis;
// the int8 BYTES are invariant to ps_q, only new_scale scales -- proved in the gate).
int xmx_rec_gemm_s8rq32(int a, int b, int c8, int a_scale, int col_scale, int new_scale,
                        unsigned M, unsigned N, unsigned K) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (M % 128u) || (N != 32u) || (K % 32u))
        FAILMSG("gemm_s8rq32 needs M%%128==0, N==32, K%%32==0");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c8);
    auto ias = g_bufs.find(a_scale), ics = g_bufs.find(col_scale), ins = g_bufs.find(new_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        ias == g_bufs.end() || ics == g_bufs.end() || ins == g_bufs.end()) FAILMSG("bad gemm_s8rq32 operand");
    int8_t* Araw = (int8_t*)ia->second.p;
    int8_t* Braw = (int8_t*)ib->second.p;
    int8_t* C8 = (int8_t*)ic->second.p;
    float* as = (float*)ias->second.p;
    float* cs = (float*)ics->second.p;
    float* ns = (float*)ins->second.p;
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * K, nb = (size_t)K * N;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        GQ->memcpy(hA.data(), Araw, na).wait();
        GQ->memcpy(hB.data(), Braw, nb).wait();
        s8v7::pack_a(hA.data(), hAp.data(), (int)M, (int)K);
        s8v7::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        int8_t* dAp = sycl::malloc_device<int8_t>(na, *GQ);
        int8_t* dCp = sycl::malloc_device<int8_t>(nb, *GQ);
        GQ->memcpy(dAp, hAp.data(), na).wait();
        GQ->memcpy(dCp, hBp.data(), nb).wait();
        s8v7::gemm_s8rq32(*GQ, dAp, dCp, as, cs, C8, ns, (int)M, (int)N, (int)K).wait();
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

// int xmx_rec_cosine_norm_i8(int source, int out8, int scale, unsigned rows, unsigned vit,
//                            int qscale, unsigned heads)
// route-B block 1 (section 38): cosine-normalise -> register row-max -> requantize to
// int8 + per-row scale. The scores-GEMM seam's e4m3 publish + quantize_row both die here.
// qscale=0 for K (no learned scale); a real buffer for Q (scale after the norm, VIT_ROOT
// between when vit). rows = flattened (row,head) count, each row 32 channels.
int xmx_rec_cosine_norm_i8(int source, int out8, int scale, unsigned rows, unsigned vit,
                           int qscale, unsigned heads) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows) FAILMSG("cosine_norm_i8 needs rows>0");
    auto s = g_bufs.find(source), o = g_bufs.find(out8), c = g_bufs.find(scale);
    const float* qsp = nullptr;
    if (qscale) { auto q = g_bufs.find(qscale); if (q == g_bufs.end()) FAILMSG("bad cosine_norm_i8 qscale"); qsp = (const float*)q->second.p; }
    else if (heads) FAILMSG("heads without qscale");
    if (s == g_bufs.end() || o == g_bufs.end() || c == g_bufs.end()) FAILMSG("bad cosine_norm_i8 operand");
    const float* sp = (const float*)s->second.p;
    signed char* op = (signed char*)o->second.p;
    float* cp = (float*)c->second.p;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         ctree::cosine_norm_i8_kernel()(sp, op, cp, rows, vit, qsp, heads)).wait();
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

// int xmx_rec_softmax_i8(int acc, int q_scale, int k_scale, int bias, int out8, int scale,
//                        unsigned rows, unsigned cols)
// route-B block 2 (section 38): scores seam -- int32 accumulator + row/col scales + bias
// -> dequantise+bias (island-3/4 at island-1's entrance) -> the gated affine/bit-pair/
// sum/recip chain -> register row-max -> int8 probs + row scale (v3's requantize contract).
// acc is int32 (the v1 GEMM's C), q_scale float[rows], k_scale float[cols], bias f32
// rows x cols (pass a zero buffer when the head has no bias), out8 int8 rows x cols,
// scale float[rows]. cols even.
int xmx_rec_softmax_i8(int acc, int q_scale, int k_scale, int bias, int out8, int scale,
                       unsigned rows, unsigned cols) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !cols || (cols & 1u)) FAILMSG("softmax_i8 needs rows>0, even cols");
    auto ia = g_bufs.find(acc), iq = g_bufs.find(q_scale), ik = g_bufs.find(k_scale);
    auto ib = g_bufs.find(bias), io = g_bufs.find(out8), isc = g_bufs.find(scale);
    if (ia == g_bufs.end() || iq == g_bufs.end() || ik == g_bufs.end() ||
        ib == g_bufs.end() || io == g_bufs.end() || isc == g_bufs.end()) FAILMSG("bad softmax_i8 operand");
    const int32_t* ap = (const int32_t*)ia->second.p;
    const float* qp = (const float*)iq->second.p;
    const float* kp = (const float*)ik->second.p;
    const float* bp = (const float*)ib->second.p;
    signed char* op = (signed char*)io->second.p;
    float* scp = (float*)isc->second.p;
    g_cmds.push_back([=]() {
        // scratch holds each row's pre-requantize half values between the sum pass and the
        // row-max/requantize pass; every work-item touches only its own row, so no barrier.
        // (The megakernel form keeps them in registers; this is the correctness-first path
        // gate, same staged rhythm as the rest of the skeleton.)
        sycl::half* scratch = (sycl::half*)sycl::malloc_shared((size_t)rows * cols * 2, *GQ);
        GQ->parallel_for(sycl::range(rows),
                         smax::softmax_i8_kernel()(ap, qp, kp, bp, scratch, op, scp, rows, cols)).wait();
        sycl::free(scratch, *GQ);
    });
    return 0;
}

// int xmx_rec_requant_i8(int acc, int a_scale, int b_scale, int out8, int scale,
//                        unsigned rows, unsigned cols)
// route-B connective tissue (section 42): the v1 int32 GEMM's accumulator -> int8 + row
// scale, for the attention GEMMs whose N is not 64 (scores 640, attnV/outproj channels).
// v3's exact requantize contract (multiply-form inv=127/rmax, rint, clip +-127,
// scale=rmax/127) with the shipped left-to-right dequantise (acc*a_scale[row]*b_scale[col]).
int xmx_rec_requant_i8(int acc, int a_scale, int b_scale, int out8, int scale,
                       unsigned rows, unsigned cols) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !cols) FAILMSG("requant_i8 needs rows/cols");
    auto ia = g_bufs.find(acc), ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    auto io = g_bufs.find(out8), isc = g_bufs.find(scale);
    if (ia == g_bufs.end() || ias == g_bufs.end() || ibs == g_bufs.end() ||
        io == g_bufs.end() || isc == g_bufs.end()) FAILMSG("bad requant_i8 operand");
    const int32_t* ap = (const int32_t*)ia->second.p;
    const float* as = (const float*)ias->second.p;
    const float* bs = (const float*)ibs->second.p;
    signed char* op = (signed char*)io->second.p;
    float* scp = (float*)isc->second.p;
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         requant::requant_i8_kernel()(ap, as, bs, op, scp, rows, cols)).wait();
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

// int xmx_rec_gemm_qkv_v_i8(int a, int b, int v8, int v_scale, int a_scale, int b_scale,
//                           unsigned M, unsigned channels, unsigned heads, unsigned tokens)
// route-B block 3 (section 41): the V branch with COLUMN quantization -- int8 GEMM ->
// dequantise -> per-(window,channel) column max (SLM atomic-fmax, the transposed v3
// pattern) -> requantize -> int8 + column scale, scattered to (window,head,token,32).
// attnV reduces over tokens, so V's scale must be per-column (out of the sum), NOT
// per-token (which would sit inside it). v_scale is float[(M/tokens)*channels].
// M % 128 == 0, channels % 64 == 0, tokens == 64 (BM=128 = 2 windows of 64).
int xmx_rec_gemm_qkv_v_i8(int a, int b, int v8, int v_scale, int a_scale, int b_scale,
                          unsigned M, unsigned channels, unsigned heads, unsigned tokens) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !channels || !heads || !tokens || (M % 128u) || (channels % 64u) || (tokens != 64u))
        FAILMSG("gemm_qkv_v_i8 needs M%%128==0, channels%%64==0, tokens==64");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), iv = g_bufs.find(v8);
    auto ivs = g_bufs.find(v_scale), ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || iv == g_bufs.end() ||
        ivs == g_bufs.end() || ias == g_bufs.end() || ibs == g_bufs.end()) FAILMSG("bad gemm_qkv_v_i8 operand");
    int8_t* Araw = (int8_t*)ia->second.p;
    int8_t* Braw = (int8_t*)ib->second.p;
    signed char* V8 = (signed char*)iv->second.p;
    float* vs = (float*)ivs->second.p;
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
        s8v5::gemm_qkv_v_i8(*GQ, dAp, dBp, as, bs, V8, vs, (int)M, (int)channels,
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
