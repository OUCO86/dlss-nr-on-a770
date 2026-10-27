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
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <level_zero/ze_api.h>
#include "quantize_row_kernel.hpp"
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "softmax_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_resident.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"
#include "window_block_v4.hpp"
#include "window_block_v4ph.hpp"
#include "ffn_fused_kernel.hpp"
#include "qkv_resident.hpp"
#include "ffn_chip_kernel.hpp"
#include "requant_kernel.hpp"
#include "gemm_s8_v1_kernel.hpp"
#include "gemm_s8_v3_kernel.hpp"
#include "gemm_s8_v5_kernel.hpp"
#include "gemm_s8_v7_kernel.hpp"
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_s8_v9_kernel.hpp"
#include "gemm_s8_v9b_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "gemm_f16_v3_kernel.hpp"
#include "pack_device.hpp"
#include "pre_kernel.hpp"
#include "post_kernel.hpp"
#include <cstring>
#include <cstdint>
#include <cstdio>
#include <set>
#include <chrono>
#include <algorithm>
#include <map>
#include <atomic>
#include <vector>
#include <unordered_map>
#include <stdexcept>
#include <string>
#include <functional>
#ifdef _WIN32
#define NOMINMAX
#include <d3d12.h>
#include <dxgi1_6.h>
// windows.h (pulled by d3d12.h) defines OUT/IN as empty SAL macros -- our recorders
// use `float* OUT` as a variable name, so undo the macro clash.
#undef OUT
#undef IN
#endif

static sycl::queue* GQ = nullptr;
static sycl::device* GD = nullptr;
static char GERR[256] = {0};
#define FAILMSG(...) do { std::snprintf(GERR, sizeof GERR, __VA_ARGS__); return -1; } while (0)

// buffer table: int handle -> {device ptr, bytes, dtype-size, imported}. An imported
// pointer (xmx_buf_import_win32) aliases a buffer owned by the OTHER engine -- freeing
// our import releases only our reference, the producer keeps the allocation alive.
struct Buf { void* p; size_t bytes; size_t esz; bool imported = false; };
static std::unordered_map<int, Buf> g_bufs;
static void mem_probe(int id, void* p, size_t bytes, const char* tag);  // fwd (ze world)
static int g_nextbuf = 1;

// recording
static bool g_recording = false;
static std::vector<std::function<void()>> g_cmds;
static std::vector<const char*> g_cmd_names;
static bool g_l0 = false;   // the chosen device is Level-Zero-backed (section 92): the
                            // fused pre/post kernels fault on the OpenCL Arc, so they
                            // refuse unless this is set (the small gates run fine on it).

// scratch pool (section 92): the per-pass sycl::malloc_device/sycl::free storm is the
// remaining steady-state cost -- 693 passes x ~4 allocs, each zeMalloc/zeFree ~1ms,
// ~2.7s of the 3.8s run. A size-bucketed pool hands the same device block back to the
// next pass that needs it; blocks are freed only when the pool is cleared (close).
// Pointer-keyed put: a free site does not know its size, so pool_get records the bucket
// it handed out and pool_put looks it up. Sequential graph execution (wait-per-kernel)
// means no two live scratch blocks collide; buffers stay out of circulation until
// destroy, which returns them to the pool.
static std::map<size_t, std::vector<void*>> g_pool;
static std::map<void*, size_t> g_pool_sz;
// section 92 derivation: FLOPs per GEMM family (2*M*N*K*batch), summed over the walk.
// Divided by the trustworthy per-closure GPU time this gives each family's ACTUAL TOPS,
// which compared against the senior's measured achievable (§8: 2.1 narrow-int32-store,
// 11.8-30.9 fused-store) localizes the bottleneck by arithmetic, not trial-and-error.
static std::map<std::string, double> g_flops;
static std::map<std::string, long> g_flops_calls;
// section 92: also record the DISTINCT shapes per family -- the v3 fused-requantize
// store applies only where N == BN == 64 (whole row in one workgroup, §24), so the
// shape histogram decides which families can take the 5.6x lever and which need a
// BN=128 variant or stay split.
static std::map<std::string, std::map<std::string, long>> g_shapes;
static std::map<std::string, std::map<unsigned, long>> g_epi;   // epilogue-kind histogram
static void flop_note(const char* fam, double m, double n, double k, double batch) {
    g_flops[fam] += 2.0 * m * n * k * batch;
    g_flops_calls[fam]++;
    char sb[96]; snprintf(sb, sizeof sb, "M=%.0f N=%.0f K=%.0f b=%.0f", m, n, k, batch);
    g_shapes[fam][sb]++;
}
static std::atomic<long> g_wb_v2{0}, g_wb_split{0};
static unsigned g_wbf3_poolhead = 0;   // section 100: one-shot proof the pool/head forms ride the fused leg
// section 100 D14: the preallocated probe target for stop=94 (33.4MB, allocated in
// xmx_init like the plan buffers, but NEVER registered in g_bufs and never read).
static void* g_probe33 = nullptr;
// section 100 D16 (stop=90): the fix candidate probe. The law the ladder pinned:
// writing a buffer allocated BEFORE recording (plan buffers at prepare, probe33 at
// init) costs +39ms in this engine; writing one allocated DURING recording (pool)
// is free; and moving bytes INTO an early buffer at run (D12 memcpy) pays the same
// tax. So: keep the data in a recording-time staging buffer and alias BOTH the
// writer (window_block target) and the reader (ffn_merge skip) to it -- the plan
// buffer leaves the hot path entirely. Probe aliases 1265 only (block 0's skip,
// the 33MB hand-off). Frame is garbage by design for OTHER reasons? NO -- the
// bytes flow writer->staging->reader, so 90 must be BIT-EXACT end to end; that is
// the probe's second judge.
static std::map<int, void*> g_alias;   // plan buf id -> recording-time staging
static void* pool_get(size_t n);       // fwd (defined below with the scratch pool)
// the alias swap: called at RECORD time (pool_get = recording-time allocation, the
// one placement the whole engine writes fast). Idempotent per plan id.
static void* alias_buf(int id, size_t bytes) {
    auto it = g_alias.find(id);
    if (it != g_alias.end()) return it->second;
    void* p = pool_get(bytes);
    g_alias[id] = p;
    return p;
}
// section 99: §29 rule 1 -- quantize folds into the producer GEMM's store loop. The
// fused producer registers the SOURCE buffer id of the quant pass it just absorbed;
// xmx_rec_quant sees the id and records a no-op (the plan's op stream is untouched --
// the bridge and plan stay frozen per the 10-18 order).
static std::map<int,int> g_fused_quant;   // quant-source cb -> a_scale buf (new_scale lives there)
// SECTION 100 P2 CONSUMER-SIDE FUSION (the user's "dissolve the kernel" direction):
// the census (plan_960x544.c, precise buffer-position parse) proved 448/448 quants have
// pk SINGLE-READER = the very next gemm (gap 2), f16 source ALIVE until that gemm
// (0 overwritten), zero in-place, and the quant's scale buf == the gemm's a_scale buf
// (432/448; the 16 that differ stay two-pass). So the gemm's pack_a reads the f16
// ACTIVATION, quantizes row-wise inline (the qr_kernel_rowthread arithmetic, fdiv_rn
// per element = numpy-exact), and writes the packed int8 -- the standalone quant
// launch AND its pk buffer disappear. bench_qfused: FUSED-PACK tile-diff 0 scale-diff
// 0 on every frame shape. Gate NR_Q_FUSE (default OFF until the three gates pass).
struct QuantFused { size_t qcmd; int src; int sc; unsigned M; unsigned K;
    bool gather = false; unsigned image_h = 0, image_w = 0, across = 0, pad = 0; };
static std::map<int,QuantFused> g_quant_pk;   // pk buf id -> the quant that wrote it
static bool qfuse_on() { static bool v = !getenv("NR_Q_FUSE") || atoi(getenv("NR_Q_FUSE")) != 0; return v; }
// called by a gemm recorder: if `a` is a fused-quant pk whose scale buf == this gemm's
// a_scale and whose M,K match, no-op the quant closure and return its info.
static bool qfuse_take(int a, int a_scale, unsigned M, unsigned K, QuantFused& out){
    if (!qfuse_on()) return false;
    auto it = g_quant_pk.find(a);
    if (it == g_quant_pk.end()) return false;
    if (it->second.sc != a_scale || it->second.M != M || it->second.K != K) return false;
    out = it->second;
    g_cmds[out.qcmd] = [](){};                 // the quant launch dissolves
    g_cmd_names[out.qcmd] = "quant(FUSED-pack)";
    g_quant_pk.erase(it);
    return true;
}
// batched variant: the wide-row batched shapes quantize the FULL lda-wide row and the
// gemm slices it by columns (sa==K per group). Pair when quant-K == lda_e (or == K for
// the shared-A form sa==0) and scale_stride==0 (row scales shared across groups --
// every frame case; the census 99c4034).
// P4b: the gather-window pairing (quant_window pk -> the next QKV's A).
static bool qfuse_take_gather(int a, int a_scale, unsigned M, unsigned C,
                              size_t my_cmd, QuantFused& out){
    if (!qfuse_on()) return false;
    auto it = g_quant_pk.find(a);
    if (it == g_quant_pk.end() || !it->second.gather) return false;
    if (it->second.sc != a_scale || it->second.M != M || it->second.K != C) return false;
    if (my_cmd - it->second.qcmd > 4) return false;
    out = it->second;
    g_cmds[out.qcmd] = [](){};
    g_cmd_names[out.qcmd] = "quant_window(FUSED-pack)";
    g_quant_pk.erase(it);
    return true;
}
static bool qfuse_take_b(int a, int a_scale, unsigned M, unsigned K, unsigned lda_e,
                         unsigned sa, unsigned scale_stride, size_t my_cmd, QuantFused& out){
    static bool qfuse_b = getenv("NR_Q_FUSE_B") != nullptr;   // A/B 00:45: end-to-end
    if (!qfuse_b) return false;                                // NEUTRAL (batched fused
    if (!qfuse_on() || scale_stride != 0u) return false;       // pack +8ms eats the
                                                        // quant -12; kept as a probe
    auto it = g_quant_pk.find(a);
    if (it == g_quant_pk.end()) return false;
    // the two frame forms (census 99c4034, guards per the user's reference):
    //   shared-A:   quant-K == gemm-K == lda, sa==0 (groups read the SAME rows)
    //   col-slice:  quant-K == lda (full wide row), sa == K (group g reads cols g*K..)
    const bool shared    = (it->second.K == K && K == lda_e && sa == 0u);
    const bool colslice  = (it->second.K == lda_e && sa == K);
    if (!shared && !colslice) return false;
    if (it->second.sc != a_scale || it->second.M != M) return false;
    if (my_cmd - it->second.qcmd > 4) return false;   // adjacency sanity: only INIT/BUF
    out = it->second;                                  // ops may sit in between
    g_cmds[out.qcmd] = [](){};
    g_cmd_names[out.qcmd] = "quant(FUSED-pack-b)";
    g_quant_pk.erase(it);
    return true;
}
// SECTION 99 v9b FOLD pairing (record-time registration, exec-time lookup): the
// batched recorder, when its v9b condition holds, records its own cmd index under the
// c buffer id; the ADJACENT quant recorder back-fills (packed,scale) into that slot.
// All recording precedes all execution, so the producer closure reads a complete slot.
struct FoldBind { int cbuf = -1; void* packed = nullptr; void* scale = nullptr; };
static size_t g_pending_fold_slot = SIZE_MAX;    // the LAST v9b producer's slot (adjacency)
static std::vector<FoldBind> g_fold_slot;         // producer cmd index -> quant buffers
// section 98: true while a command_graph is RECORDING this closure loop. Events returned
// by submissions during recording belong to the graph and CANNOT be .wait()ed (runtime
// throws). ev_sync() skips the wait in that case -- the memcpy is still recorded as a
// graph node, so the device-side copy happens at replay; host-readback branches (dumps,
// head/pooling legs) never execute during a game-walk recording anyway.
static bool g_graphrecording = false;
static void ev_sync(sycl::event e) { if (!g_graphrecording) e.wait(); }
static long g_pool_mallocs = 0;          // section 92: pool misses = driver malloc round-trips
static unsigned long long g_pool_malloc_bytes = 0;
static void* pool_get(size_t n) {
    size_t bucket = (n + 255) / 256 * 256;
    auto it = g_pool.lower_bound(bucket);
    if (it == g_pool.end() || it->second.empty()) {
        g_pool_mallocs++; g_pool_malloc_bytes += bucket;   // section 92: driver round-trip count
        void* p = sycl::malloc_device(bucket, *GQ);
        if (p) g_pool_sz[p] = bucket;
        if (p && bucket >= (16ull<<20)) mem_probe(-1, p, bucket, "POOL");  // D11 census
        return p;
    }
    void* p = it->second.back(); it->second.pop_back();
    g_pool_sz[p] = bucket;
    return p;
}
static void pool_put(void* p) {
    if (!p) return;
    auto it = g_pool_sz.find(p);
    // Only recycle pool-tracked blocks. Anything else (a g_wcache weight block, a real
    // buffer) is owned elsewhere -- buf_destroy frees buffers, wcache frees cache blocks.
    // Silently ignoring a non-pool pointer is what makes the cache conversion safe: a
    // call site that still passes a cache-owned dBp does not free it out from under the
    // next frame. (The old "free for real" fallback was a use-after-free for cache blocks.)
    if (it == g_pool_sz.end()) return;
    g_pool[it->second].push_back(p);
    g_pool_sz.erase(it);
}
static void pool_clear() {
    for (auto& kv : g_pool) for (void* p : kv.second) { sycl::free(p, *GQ); g_pool_sz.erase(p); }
    g_pool.clear(); g_pool_sz.clear();
}

// weight-pack cache (section 92): a weight buffer's PACKED form is identical every frame
// (weights never change after their one blob upload). The per-frame gather+pack of the
// weight operand is the "GPU busy doing waste" the user measured (stage timing: wt=489ms
// of pure re-packing). Cache the packed B keyed by (buffer id, a, b, c) -- for the direct
// families (a,b)=(N,K),c=0; for the batched families (a,b,c)=(column block c0, width n64,
// group g). First frame packs, later frames reuse. Ids are monotonic (g_nextbuf++) so a
// destroyed id is never reused; buf_upload to a live id (re-upload) and buf_destroy
// invalidate. The cached block is owned by the cache, NOT the pool -- call sites must not
// pool_put it (gemm only reads it, so cross-pass reuse is safe).
struct WKey { int id; int a; int b; int c;
              bool operator<(const WKey& o) const {
                  if (id != o.id) return id < o.id;
                  if (a != o.a) return a < o.a;
                  if (b != o.b) return b < o.b;
                  return c < o.c; } };
static std::map<WKey, void*> g_wcache;
static void wcache_invalidate(int id) {
    for (auto it = g_wcache.begin(); it != g_wcache.end(); )
        if (it->first.id == id) { if (GQ) sycl::free(it->second, *GQ); it = g_wcache.erase(it); }
        else ++it;
}
static void wcache_clear() {
    for (auto& kv : g_wcache) if (GQ) sycl::free(kv.second, *GQ);
    g_wcache.clear();
}
// cached weight pack: pack_b of a weight buffer is identical every frame, so pack once
// and reuse. Key = (buffer id, N, K, variant). The block is owned by g_wcache (gemm only
// reads it; call sites must NOT pool_put it). buf_upload/destroy invalidate.
static int8_t* cached_pack_b_i8(int bufid, const int8_t* B, int N, int K) {
    WKey wk{bufid, N, K, 0};
    auto it = g_wcache.find(wk);
    if (it != g_wcache.end()) return (int8_t*)it->second;
    int8_t* p = (int8_t*)sycl::malloc_device((size_t)N * K, *GQ);
    packdev::pack_b(*GQ, B, p, N, K);
    g_wcache[wk] = p;
    return p;
}
static sycl::half* cached_pack_b_f16(int bufid, const sycl::half* B, int K, int N) {
    WKey wk{bufid, K, N, 0};
    auto it = g_wcache.find(wk);
    if (it != g_wcache.end()) return (sycl::half*)it->second;
    sycl::half* p = (sycl::half*)sycl::malloc_device((size_t)K * N * 2, *GQ);
    packdev::pack_b16(*GQ, B, p, K, N);
    g_wcache[wk] = p;
    return p;
}
static sycl::half* cached_pack_b_f16_t(int bufid, const sycl::half* B, int K, int N) {
    WKey wk{bufid, K, N, 1};   // variant 1 = transposed layout
    auto it = g_wcache.find(wk);
    if (it != g_wcache.end()) return (sycl::half*)it->second;
    sycl::half* p = (sycl::half*)sycl::malloc_device((size_t)K * N * 2, *GQ);
    packdev::pack_b16_t(*GQ, B, p, K, N);
    g_wcache[wk] = p;
    return p;
}

extern "C" {

const char* xmx_error(void) { return GERR; }

int xmx_init(void) {
    try {
        // The game's stderr goes nowhere, so the census of what SYCL sees goes to a
        // file beside this dll (the section-60 lesson, made readable in the field).
        FILE *cen = nullptr;
        HMODULE self = nullptr;
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                           GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           (LPCWSTR)&xmx_init, &self);
        {
            wchar_t wpath[1100] = {0};
            if (self) {
                GetModuleFileNameW(self, wpath, 1000);
                wchar_t *slash = wcsrchr(wpath, L'\\');
                if (slash) wcscpy(slash + 1, L"libxmx_sycl_census.txt");
                cen = _wfopen(wpath, L"w");
            }
        }
        auto say = [cen](const std::string& s) {
            std::fprintf(stderr, "%s\n", s.c_str());
            if (cen) { std::fprintf(cen, "%s\n", s.c_str()); std::fflush(cen); }
        };
        // DIAGNOSE + FIELD-FIX BEFORE the first enumeration: SYCL's adapter discovery is
        // lazy (the first get_devices() triggers ur_loader to scan for adapters), so the
        // census of what is already loaded, and the explicit load of the Level-Zero
        // adapter if it is missing, must happen FIRST -- after the first enumeration the
        // runtime has already cached its adapter list. ur_loader finds adapters by a
        // search that keys off the EXE dir / CWD; in the game those are the game folder,
        // not work/ where the adapter sits beside us -- so the adapter may never load
        // even though it is right here. GetModuleFileName(self) gives the exact folder
        // this dll was loaded from (work/) regardless of CWD.
        HMODULE ad = GetModuleHandleW(L"ur_adapter_level_zero.dll");
        {
            HMODULE s9 = GetModuleHandleW(L"sycl9.dll");
            wchar_t sp[1024] = {0};
            if (s9 && GetModuleFileNameW(s9, sp, 1000)) {
                char sa[1024]; WideCharToMultiByte(CP_UTF8, 0, sp, -1, sa, sizeof sa, nullptr, nullptr);
                say(std::string("[xmx_init] loaded sycl9.dll = ") + sa);
            } else
                say("[xmx_init] no sycl9.dll module handle found");
            wchar_t ap[1024] = {0};
            if (ad && GetModuleFileNameW(ad, ap, 1000)) {
                char aa[1024]; WideCharToMultiByte(CP_UTF8, 0, ap, -1, aa, sizeof aa, nullptr, nullptr);
                say(std::string("[xmx_init] ur_adapter_level_zero ALREADY loaded = ") + aa);
            } else
                say("[xmx_init] ur_adapter_level_zero NOT loaded yet");
            HMODULE ul = GetModuleHandleW(L"ur_loader.dll");
            wchar_t up[1024] = {0};
            if (ul && GetModuleFileNameW(ul, up, 1000)) {
                char ua[1024]; WideCharToMultiByte(CP_UTF8, 0, up, -1, ua, sizeof ua, nullptr, nullptr);
                say(std::string("[xmx_init] ur_loader loaded from = ") + ua);
            }
            wchar_t cwd[1024] = {0};
            if (GetCurrentDirectoryW(1000, cwd)) {
                char ca[1024]; WideCharToMultiByte(CP_UTF8, 0, cwd, -1, ca, sizeof ca, nullptr, nullptr);
                say(std::string("[xmx_init] process CWD = ") + ca);
            }
            wchar_t exe[1024] = {0};
            if (GetModuleFileNameW(nullptr, exe, 1000)) {
                char ea[1024]; WideCharToMultiByte(CP_UTF8, 0, exe, -1, ea, sizeof ea, nullptr, nullptr);
                say(std::string("[xmx_init] process EXE = ") + ea);
            }
        }
        // (No explicit adapter preload here: it broke the gates' own discovery. The game
        //  problem is solved by deploying the adapter beside the EXE -- swap_engine.bat
        //  does that -- and the census below proves it worked: chosen backend=2.)
        say("[xmx_init] enumerated GPUs:");
        for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
            say("   backend=" + std::to_string((int)d.get_backend()) +
                " name=" + d.get_info<sycl::info::device::name>());
        say(std::string("[xmx_init] SYCL_DEVICE_FILTER now = ") +
            (getenv("SYCL_DEVICE_FILTER") ? getenv("SYCL_DEVICE_FILTER") : "(unset)"));
        sycl::device dev;
        // Prefer the Level-Zero Arc. Fall back to the OpenCL Arc ONLY for the small
        // elementwise/GEMM gates, which run correctly on it (the section-60 reality: a
        // Python process sees only the opencl Arc). The FUSED pre/post kernels fault on
        // opencl (the 2026-10-20 GPUCrash), so xmx_rec_pre/xmx_rec_post refuse opencl
        // themselves (g_l0 flag below) -- the game, which has the adapter deployed beside
        // its exe (swap_engine.bat), gets backend=2 and runs fused; a game without it
        // declines cleanly instead of crashing.
        for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
            if (d.get_backend() == sycl::backend::ext_oneapi_level_zero &&
                d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
        if (dev.get_backend() != sycl::backend::ext_oneapi_level_zero)
            for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
                if (d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
        g_l0 = (dev.get_backend() == sycl::backend::ext_oneapi_level_zero);
        say(std::string("[xmx_init] chosen: backend=") + std::to_string((int)dev.get_backend()) +
            " name=" + dev.get_info<sycl::info::device::name>() +
            (g_l0 ? " (Level-Zero: fused allowed)" : " (OpenCL: fused pre/post will refuse)"));
        if (cen) fclose(cen);
        GD = new sycl::device(dev);
        // in-order queue (section 92): the pass closures chain pack->gemm->publish on
        // device; with an in-order queue the enqueue order IS the execution order, so the
        // GPU pipelines across passes and the scratch pool is safe to reuse without a
        // per-pass host .wait() (the ~2000 sync points were the low GPU utilisation the
        // user saw in-game). graph_run/submit wait once at the end.
        GQ = new sycl::queue(dev, sycl::property::queue::in_order{});
        // section 100 D14 probe: a PREALLOCATED standalone 33.4MB buffer (allocated
        // here, before prepare's OP_BUF steps, NEVER registered in g_bufs, never
        // read by anything). stop=94 writes all fused leg3 calls into it. vs stop=99
        // (plan buffer 1265, prepare-time + g_bufs) and stop=96 (pool buffer,
        // run-time, recycled): separates "plan-buffer registration" from "early big
        // allocation" as the cause of the 40ms async writer cost.
        {
            const char* wbs = getenv("NR_WB_STOP");
            int st = wbs ? atoi(wbs) : 99;
            if (st == 94 || st == 91) g_probe33 = sycl::malloc_device(34000000, *GQ);
        }
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
    // section 100 D16 (stop=90): THE fix candidate, minimal form. Plan buffer 1265
    // (the 33MB block0 -> ffn_merge skip hand-off) gets its POINTER from pool_get
    // instead of a fresh malloc_device -- i.e. recycled from the pool the engine
    // writes fast, allocated at the same prepare moment. Writer and reader both
    // address it through g_bufs, so one swap covers both sides; the byte stream
    // (writer->1265->reader) is untouched, so stop=90 MUST be bit-exact end to end
    // (buffer 1301 is the judge). If this is fast, the cure is "route hot hand-off
    // buffers through the pool" -- a recorder-layer change, plan/bridge frozen.
    void* p = nullptr;
    {
        static int st90 = getenv("NR_WB_STOP") ? atoi(getenv("NR_WB_STOP")) : 99;
        if (st90 == 90 && bytes == 33423360ull && kind == 0) p = pool_get(bytes);
    }
    if (!p) p = sycl::malloc_device<unsigned char>(bytes, *GQ);
    if (!p) FAILMSG("out of device memory");
    int id = g_nextbuf++;
    g_bufs[id] = { p, (size_t)bytes, (size_t)(kind == 0 ? 2 : kind) };
    mem_probe(id, p, bytes, "buf");   // section 100 D11 (defined with the ze world)
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
static int ensure_ze_world();   // forward (defined just below; static linkage)
// section 100 D11: the memory-type census behind the leg3 stop-ladder fact (writing
// the prepare-time plan target costs +38.5ms over writing a run-time pool buffer of
// the same size with the SAME kernel and SAME addresses; contig-vs-scatter is free).
// Suspect = the driver placed one in a HOST_VISIBLE/BAR region (the old "24.9MB to
// system memory = 4.91ms" hazard class). NR_MEM_PROBE=1 prints ze type for every
// >=16MB allocation (type: 1=HOST, 2=DEVICE, 3=SHARED per ze_api.h).
static void mem_probe(int id, void* p, size_t bytes, const char* tag) {
    if (!getenv("NR_MEM_PROBE") || bytes < (16ull<<20)) return;
    // the pointer came from SYCL's allocator -- query it with SYCL's OWN ze context
    // (the gate_coexist/gate_d3d_import lesson: under the level_zero filter
    // get_native<level_zero> on the queue context succeeds; our private ze context
    // would not recognize a foreign-allocated pointer).
    try {
        ze_context_handle_t zc = sycl::get_native<sycl::backend::ext_oneapi_level_zero>(
            GQ->get_context());
        if (!zc) return;
        ze_memory_allocation_properties_t prop = { ZE_STRUCTURE_TYPE_MEMORY_ALLOCATION_PROPERTIES };
        ze_device_handle_t mdev = nullptr;
        ze_result_t rc = zeMemGetAllocProperties(zc, p, &prop, &mdev);
        if (rc == ZE_RESULT_SUCCESS)
            std::printf("[mem-probe] %s id=%d bytes=%zu type=%u ptr=%p\n",
                        tag, id, bytes, (unsigned)prop.type, p);
        else
            std::printf("[mem-probe] %s id=%d bytes=%zu query rc=0x%x ptr=%p\n",
                        tag, id, bytes, (unsigned)rc, p);
    } catch (...) { }
}
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
    ev_sync(GQ->memcpy((char*)it->second.p + off, src, n));
    wcache_invalidate(id);   // a re-upload changes the bytes: drop any packed cache for it
    return 0;
}
int xmx_buf_download(int id, void* dst, unsigned long long off, unsigned long long n) {
    if (!GQ) FAILMSG("not initialised");
    auto it = g_bufs.find(id); if (it == g_bufs.end()) FAILMSG("no such buffer");
    ev_sync(GQ->memcpy(dst, (char*)it->second.p + off, n));
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
    wcache_invalidate(id);   // drop any packed cache keyed on this buffer
    if (it->second.imported)
        zeMemFree(g_zctx, it->second.p);       // drop OUR reference; producer owns the memory
    else if (GQ)
        sycl::free(it->second.p, *GQ);
    g_bufs.erase(it); return 0;
}

int xmx_begin(void) { g_recording = true; g_cmds.clear();
    // AUDIT FIX (10-27): the fold registries are RECORD-scoped (qcmd = an index into
    // g_cmds). A stale entry from a PREVIOUS recording -- scratch/probe recordings, or
    // a plan switch (768x448 <-> 960x544, different op streams) -- could dissolve the
    // WRONG closure in the new stream. Same-plan frames re-register identical keys so
    // this was invisible, but it is a real cross-recording hazard. Clear at both ends.
    g_quant_pk.clear(); g_fused_quant.clear();
    g_pending_fold_slot = SIZE_MAX; g_fold_slot.clear();
    return 0; }
int xmx_abort(void) { g_recording = false; g_cmds.clear();
    g_quant_pk.clear(); g_fused_quant.clear();
    g_pending_fold_slot = SIZE_MAX; g_fold_slot.clear();
    return 0; }

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
static std::vector<std::vector<const char*>> g_graph_names;
#ifdef _WIN32
static int fence_host_wait(void);   // defined in the fence block; graph_run calls it
#endif
int xmx_graph_capture(void) {
    if (!g_recording) FAILMSG("not recording");
    g_graphs.push_back(std::move(g_cmds)); g_graph_names.push_back(std::move(g_cmd_names));
    g_cmds.clear();
    g_quant_pk.clear(); g_fused_quant.clear();          // record-scoped registries die
    g_pending_fold_slot = SIZE_MAX; g_fold_slot.clear(); // with the stream (10-27 audit)
    g_recording = false;
    return (int)g_graphs.size() - 1;
}
int xmx_graph_run(int id) {
    if (g_recording) FAILMSG("cannot replay during recording");
    if (id < 0 || id >= (int)g_graphs.size() || g_graphs[id].empty())
        FAILMSG("graph is not live");
    int passes = (int)g_graphs[id].size();
    // The fence wait (section 90): the game calls nr_net_wait (which records the
    // pending fence via xmx_extmem_wait) then nr_net_run, same thread, in order
    // (NrPipeline.cpp:648/654). The shipped engine does a DEVICE-side wait (vkQueueSubmit
    // pWaitSemaphores); for our L0 engine an immediate-list wait lives on a DIFFERENT
    // queue than the SYCL kernels, so it would not order them. The correct, no-loss form
    // is a HOST-side wait here (fence_host_wait): block until the D3D12 fence reaches the
    // value BEFORE the kernels launch. The game's queue has already signalled it before
    // netWait is called (nr_replay.c:408), so this returns immediately in practice -- but
    // it is a real wait, so a late fence cannot let the kernels read half-written buffers.
#ifdef _WIN32
    if (fence_host_wait() != 0) return -1;
#endif
    try {
        // NR_RUN_TIMING=1: time every closure so the 89s/frame is attributed to families
        // instead of guessed at (the game's 120s RenderThread watchdog assert, 2026-10-20).
        static bool rtiming = getenv("NR_RUN_TIMING") != nullptr;
        if (rtiming) {
            std::vector<double> ms;
            ms.reserve(g_graphs[id].size());
            for (auto& fn : g_graphs[id]) {
                auto t0 = std::chrono::steady_clock::now();
                fn();
                GQ->wait();   // section 92: without this the closures submit async and the
                              // per-closure wall time is meaningless (GPU overlaps between
                              // closures -- the sum exceeded the whole run). Waiting makes
                              // each number the family's REAL GPU time. Diagnostic path only.
                ms.push_back(std::chrono::duration<double, std::milli>(
                    std::chrono::steady_clock::now() - t0).count());
            }
            std::vector<int> ord(ms.size());
            for (size_t i = 0; i < ord.size(); i++) ord[i] = (int)i;
            std::sort(ord.begin(), ord.end(), [&](int a, int b){ return ms[a] > ms[b]; });
            std::FILE *f = std::fopen("run_timing.txt", "w");
            double tot = 0; for (double m : ms) tot += m;
            std::printf("[run_timing] %zu passes, total %.0f ms; top 25:\n", ms.size(), tot);
            if (f) std::fprintf(f, "passes=%zu total=%.0fms\n", ms.size(), tot);
            for (int i = 0; i < 25 && i < (int)ord.size(); i++) {
                const char* nm = (id < (int)g_graph_names.size() && ord[i] < (int)g_graph_names[id].size())
                                 ? g_graph_names[id][ord[i]] : "?";
                std::printf("   pass %4d %-32s %8.1f ms\n", ord[i], nm, ms[ord[i]]);
                if (f) std::fprintf(f, "pass %d %s %.1f\n", ord[i], nm, ms[ord[i]]);
            }
            // per-op-name totals: which family owns the time
            std::map<std::string, double> byname;
            for (size_t i = 0; i < ms.size(); i++) {
                const char* nm = (id < (int)g_graph_names.size() && i < g_graph_names[id].size())
                                 ? g_graph_names[id][i] : "?";
                byname[nm] += ms[i];
            }
            std::vector<std::pair<std::string, double>> v(byname.begin(), byname.end());
            std::sort(v.begin(), v.end(), [](auto& a, auto& b){ return a.second > b.second; });
            std::printf("[run_timing] per-op totals:\n");
            if (f) std::fprintf(f, "per-op totals:\n");
            for (auto& kv : v) {
                std::printf("   %-32s %9.1f ms\n", kv.first.c_str(), kv.second);
                if (f) std::fprintf(f, "op %s %.1f\n", kv.first.c_str(), kv.second);
            }
            if (f) std::fclose(f);
            GQ->wait();   // the closures may enqueue without per-pass waits; drain before returning
            return passes;
        }
        // DISPATCH-OVERHEAD PROBE (section 97): split the CPU enqueue cost from the GPU
        // drain cost. If the enqueue loop alone is ~290ms, the engine is CPU-bound on the
        // 691 SYCL submits (coopmat pays this once via a single Vulkan command buffer).
        if (getenv("NR_SUBMIT_PROBE")) {
            // per-closure ENQUEUE time (GPU drain excluded): where does the 455ms go?
            std::vector<double> en; en.reserve(g_graphs[id].size());
            for (auto& fn : g_graphs[id]) {
                auto t0 = std::chrono::steady_clock::now();
                fn();
                en.push_back(std::chrono::duration<double,std::milli>(
                    std::chrono::steady_clock::now() - t0).count());
            }
            GQ->wait();
            double tot=0; for(double e:en) tot+=e;
            std::printf("[submit_probe] total enqueue=%.1f ms (%zu closures)\n", tot, en.size());
            std::vector<int> ord(en.size()); for(size_t i=0;i<en.size();++i) ord[i]=(int)i;
            std::sort(ord.begin(), ord.end(), [&](int a,int b){return en[a]>en[b];});
            std::map<std::string,double> byname;
            for(size_t i=0;i<en.size();++i){ const char* nm=(int)i<(int)g_graph_names[id].size()?g_graph_names[id][i]:"?"; byname[nm]+=en[i]; }
            std::vector<std::pair<std::string,double>> v(byname.begin(),byname.end());
            std::sort(v.begin(),v.end(),[](auto&a,auto&b){return a.second>b.second;});
            std::printf("[submit_probe] per-family ENQUEUE://n");
            for(auto&kv:v) std::printf("   %-34s %8.1f ms\n", kv.first.c_str(), kv.second);
            std::printf("[wb-route] TOTAL this run: v2-hits=%ld split-path-hits=%ld\n", g_wb_v2.load(), g_wb_split.load());
            std::fflush(stdout);
            return passes;
        }
        // SECTION 98: command_graph replay (the §2④ "one submit, no CPU handshake" mandate).
        // begin_recording wraps the closure loop ONCE per graph id; the in_order queue infers
        // the edges exactly as the plain path does. finalize() hoists JIT + graph build to a
        // one-time cost; every later frame is ONE ext_oneapi_graph submit. The closures' host
        // side effects (pool_get, cached_pack) run only during recording -- the captured device
        // ops replay with the pointers frozen at record time, which is safe because the scratch
        // pool hands out the SAME block sequence every run (§92 in-order proof). Guarded by
        // NR_CGRAPH=0 opt-out; falls back to the plain loop on any recording exception.
        static std::map<int, sycl::ext::oneapi::experimental::command_graph<
            sycl::ext::oneapi::experimental::graph_state::executable>> s_execgraphs;
        static std::set<int> s_graphtried;
        static std::set<int> s_warmed;   // run 1 = plain loop (warms pool/wcache/JIT)
        bool usecgraph = getenv("NR_CGRAPH") ? atoi(getenv("NR_CGRAPH")) != 0 : true;   // section 98: DEFAULT ON -- the DEVICE_LOST was the head-branch host-vector memcpy nodes (dangling at replay), fixed by device packs; full 691-closure graph replays 100.0000% bit-exact. NR_CGRAPH=0 = escape hatch.
        if (usecgraph && s_warmed.count(id)) {   // record only AFTER one plain run:
            // capture must see ZERO sycl::malloc_device (pool_get misses) -- allocations
            // during stream capture poison the L0 graph (DEVICE_LOST at replay, proven
            // 2026-10-24: recording on an empty pool crashed for BOTH v2 and split).
            auto eg = s_execgraphs.find(id);
            if (eg == s_execgraphs.end()) {
                if (!s_graphtried.count(id)) {
                    s_graphtried.insert(id);
                    try {
                        sycl::ext::oneapi::experimental::command_graph<
                            sycl::ext::oneapi::experimental::graph_state::modifiable> cg(*GQ);
                        cg.begin_recording(*GQ);
                        g_graphrecording = true;
                        int lim = getenv("NR_CGRAPH_LIMIT") ? atoi(getenv("NR_CGRAPH_LIMIT")) : (int)g_graphs[id].size();
                        for (int fi = 0; fi < lim && fi < (int)g_graphs[id].size(); ++fi) g_graphs[id][fi]();   // record: no GPU execution
                        g_graphrecording = false;
                        cg.end_recording(*GQ);
                        auto res = s_execgraphs.emplace(id, cg.finalize());
                        eg = res.first;
                        std::printf("[cgraph] recorded graph id=%d (%zu closures) last3=%s,%s,%s\n", id, g_graphs[id].size(),
                            g_graph_names[id].size()>=(size_t)lim&&lim>=3?g_graph_names[id][lim-3]:"?",
                            lim>=2&&lim-2<(int)g_graph_names[id].size()?g_graph_names[id][lim-2]:"?",
                            lim-1<(int)g_graph_names[id].size()?g_graph_names[id][lim-1]:"?");
                        std::fflush(stdout);
                    } catch (const std::exception& e) {
                        std::printf("[cgraph] RECORD FAILED id=%d: %.150s -- falling back to plain loop\n", id, e.what());
                        std::fflush(stdout);
                        usecgraph = false;
                        GQ->wait();
                    }
                }
            }
            if (usecgraph && eg != s_execgraphs.end()) {
                try {
                    GQ->ext_oneapi_graph(eg->second).wait();   // ONE submit for the whole plan
                } catch (const std::exception& e) {
                    std::printf("[cgraph] REPLAY THREW id=%d: %.200s -- disabling cgraph\n", id, e.what());
                    std::fflush(stdout);
                    s_execgraphs.erase(eg);
                    usecgraph = false;
                }
                if (getenv("NR_SUBMIT_PROBE")) { std::printf("[wb-route] TOTAL this run: v2-hits=%ld split-path-hits=%ld\n", g_wb_v2.load(), g_wb_split.load()); std::fflush(stdout); }
                return passes;
            }
        }
        for (auto& fn : g_graphs[id]) fn();     // in-order queue: enqueue order = execution order
        GQ->wait();                             // one host sync for the whole graph (was ~2000)
        s_warmed.insert(id);
        if (getenv("NR_SUBMIT_PROBE")) { std::printf("[wb-route] TOTAL this run: v2-hits=%ld split-path-hits=%ld\n", g_wb_v2.load(), g_wb_split.load()); std::fflush(stdout); }
    } catch (const std::exception& e) { FAILMSG("graph_run: %s", e.what()); }
    if (getenv("NR_POOL_STATS")) { std::printf("[pool] mallocs=%ld bytes=%llu MB\n",
        g_pool_mallocs, g_pool_malloc_bytes >> 20); std::fflush(stdout); }
    if (getenv("NR_FLOPS")) {
        std::printf("[flops] per-family GFLOP/frame (2*M*N*K summed):\n");
        for (auto& kv : g_flops)
            std::printf("   %-16s %8.3f GFLOP  calls=%ld\n", kv.first.c_str(),
                        kv.second / 1e9, g_flops_calls[kv.first]);
        std::fflush(stdout);
        if (getenv("NR_SHAPE_DUMP")) {
            std::printf("[shapes] distinct GEMM shapes per family (v3 fused-requant needs N==64):\n");
            for (auto& fam : g_shapes) {
                std::printf("   %s:\n", fam.first.c_str());
                for (auto& sh : fam.second)
                    std::printf("      %-34s x%ld%s\n", sh.first.c_str(), sh.second,
                                strstr(sh.first.c_str(), "N=64") ? "  <= v3-ready" : "");
            }
            for (auto& fam : g_epi) {
                std::printf("[epi] %s:", fam.first.c_str());
                for (auto& e : fam.second) std::printf(" epi%u=x%ld", e.first, e.second);
                std::printf("\n");
            }
            std::fflush(stdout);
        }
    }
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

// extmem/sem: the game's D3D12 fence, imported once (nr_replay.c:397 "a semaphore
// imported again every frame is a semaphore leaked every frame"). Option (a) -- the
// user's "no-loss" ruling: xmx_sem_value reads the REAL counter via D3D12
// GetCompletedValue, mirroring the shipped vkGetSemaphoreCounterValue (libxmx.c:3318's
// fence leg). The wait itself is the L0 external-semaphore (section 18 GATE A proved
// D3D12-fence -> ze import + wait blocks/signals correctly); the value query is the
// anti-hang precheck nr_net_wait does before it. A D3D12 device is opened just to
// OpenSharedHandle the game's fence -- section 66 proved a live D3D12 device coexists
// with our L0 engine (the game's actual condition).
#ifdef _WIN32
static ID3D12Device* g_d3d = nullptr;
struct XSem { ID3D12Fence* d3d; ze_external_semaphore_ext_handle_t l0; };
static XSem g_xsems[64];
static int xsem_slot() { for (int i = 0; i < 64; ++i) if (!g_xsems[i].d3d && !g_xsems[i].l0) return i; return -1; }
static int ensure_d3d() {
    if (g_d3d) return 0;
    IDXGIFactory1* fac = nullptr;
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&fac)))) FAILMSG("CreateDXGIFactory1");
    // any adapter works to OPEN a shared fence (the counter is adapter-independent);
    // prefer the Intel Arc so the device matches the L0 side's vendor (section 18's
    // EnumAdapters1 + vendor 0x8086 pick).
    for (UINT i = 0; i < 8 && !g_d3d; ++i) {
        IDXGIAdapter1* ad = nullptr;
        if (fac->EnumAdapters1(i, &ad) == DXGI_ERROR_NOT_FOUND) break;
        DXGI_ADAPTER_DESC1 dd = {}; ad->GetDesc1(&dd);
        if (dd.VendorId == 0x8086) {
            if (SUCCEEDED(D3D12CreateDevice(ad, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&g_d3d)))) { ad->Release(); break; }
        }
        ad->Release();
    }
    if (!g_d3d && FAILED(D3D12CreateDevice(nullptr, D3D_FEATURE_LEVEL_12_0, IID_PPV_ARGS(&g_d3d))))
        FAILMSG("D3D12CreateDevice (fence open)");
    fac->Release();
    return 0;
}
int xmx_sem_import_fence(unsigned long long handle);   // forward: xmx_sem_import delegates to it
int xmx_sem_import(unsigned long long handle, int timeline) { (void)timeline; return xmx_sem_import_fence(handle); }
int xmx_sem_import_fence(unsigned long long handle) {
    if (!handle) FAILMSG("no semaphore handle given");
    if (ensure_ze_world() != 0) return -1;
    if (ensure_d3d() != 0) return -1;
    int id = xsem_slot();
    if (id < 0) FAILMSG("out of external semaphore slots");
    ID3D12Fence* fence = nullptr;
    if (FAILED(g_d3d->OpenSharedHandle((HANDLE)(uintptr_t)handle, IID_PPV_ARGS(&fence))))
        FAILMSG("OpenSharedHandle (d3d12 fence)");
    ze_external_semaphore_win32_ext_desc_t win = { ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_WIN32_EXT_DESC };
    win.handle = (void*)(uintptr_t)handle;
    ze_external_semaphore_ext_desc_t ed = { ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_EXT_DESC };
    ed.flags = ZE_EXTERNAL_SEMAPHORE_EXT_FLAG_D3D12_FENCE;
    ed.pNext = &win;
    ze_external_semaphore_ext_handle_t xsem = nullptr;
    ze_result_t r = zeDeviceImportExternalSemaphoreExt(g_zdev, &ed, &xsem);
    if (r != ZE_RESULT_SUCCESS || !xsem) {
        fence->Release();
        FAILMSG("zeDeviceImportExternalSemaphoreExt: 0x%x", (unsigned)r);
    }
    g_xsems[id].d3d = fence; g_xsems[id].l0 = xsem;
    return id;
}
unsigned long long xmx_sem_value(int id) {
    if (id < 0 || id >= 64 || !g_xsems[id].d3d) return 0;
    return (unsigned long long)g_xsems[id].d3d->GetCompletedValue();   // the REAL counter (option a)
}
// the wait: nr_net_wait records (id,value); graph_run issues the L0 external-semaphore
// wait on an immediate command list BEFORE the kernels that read the imported buffers
// (section 18: external-semaphore wait/signal only live on an immediate list).
static int g_wait_id = -1; static unsigned long long g_wait_value = 0;
// the host-side fence wait graph_run calls before launching kernels (section 90): block
// until the imported D3D12 fence reaches the recorded value. The game's queue has already
// signalled it before netWait (nr_replay.c:408), so this returns immediately in practice.
static int fence_host_wait(void) {
    if (g_wait_id < 0 || g_wait_id >= 64 || !g_xsems[g_wait_id].d3d) return 0;
    ID3D12Fence* f = g_xsems[g_wait_id].d3d;
    if (f->GetCompletedValue() < g_wait_value) {
        static HANDLE ev = nullptr;
        if (!ev) ev = CreateEventEx(nullptr, nullptr, 0, EVENT_ALL_ACCESS);
        if (FAILED(f->SetEventOnCompletion(g_wait_value, ev)))
            FAILMSG("SetEventOnCompletion failed");
        if (WaitForSingleObject(ev, 5000) != WAIT_OBJECT_0)
            FAILMSG("the game's fence did not reach the frame value within 5s");
    }
    g_wait_id = -1; g_wait_value = 0;   // consumed for this run
    return 0;
}
int xmx_extmem_wait(int id, unsigned long long value) {
    if (id < 0 || id >= 64 || !g_xsems[id].l0) FAILMSG("external semaphore is not live");
    g_wait_id = id; g_wait_value = value;
    return 0;
}
int xmx_extmem_wait_clear(void) { g_wait_id = -1; g_wait_value = 0; return 0; }
int xmx_extmem_wait_pending(void) { return g_wait_id >= 0 ? 1 : 0; }
#else
static int g_xsem = 0;
int xmx_sem_import(unsigned long long handle, int timeline) { (void)handle; (void)timeline; return ++g_xsem; }
int xmx_sem_import_fence(unsigned long long handle) { (void)handle; return ++g_xsem; }
unsigned long long xmx_sem_value(int id) { (void)id; return 0; }
int xmx_extmem_wait(int id, unsigned long long value) { (void)id; (void)value; return 0; }
int xmx_extmem_wait_clear(void) { return 0; }
int xmx_extmem_wait_pending(void) { return 0; }
#endif

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
// int xmx_rec_pre(int colour, int motion, int history, int features, int plan,
//                 unsigned pixels, unsigned height, unsigned width,
//                 unsigned pitch, unsigned source_h, unsigned source_w, unsigned flags, int table)
// route(a) step 5 (section 90): the fused image INPUT, SYCL port of nr_pre.comp. The
// game runs the fused path (section 90's log evidence), so this must produce the sixteen
// feature channels from the game's own colour/motion/history exactly as nr_pre.comp does.
// All operands are buffer IDs (nr_replay.c:686 passes r->colour/r->motion/r->history/
// r->plan/r->table -- the imported game buffers + the host-built plan/table). The kernel
// (pre_kernel.hpp) is elementwise/geometry; the shadow gate (old dll's nr_pre.spv vs this,
// identical inputs, compare feature BYTES) is the authority (section 62) -- exp() in
// to_proxy is the one bit-exact risk.
int xmx_rec_pre(int colour, int motion, int history, int features, int plan,
                unsigned pixels, unsigned height, unsigned width,
                unsigned pitch, unsigned source_h, unsigned source_w, unsigned flags, int table) {
    if (!g_recording) FAILMSG("not recording");
    if (!g_l0) FAILMSG("xmx_rec_pre needs a Level-Zero device (the fused kernel faults on OpenCL; section 92)");
    if (!pixels || !height || !width) FAILMSG("invalid fused input extent");
    auto ic = g_bufs.find(colour), im = g_bufs.find(motion), ih = g_bufs.find(history);
    auto ift = g_bufs.find(features), ip = g_bufs.find(plan), itb = g_bufs.find(table);
    if (ic == g_bufs.end() || im == g_bufs.end() || ih == g_bufs.end() ||
        ift == g_bufs.end() || ip == g_bufs.end() || itb == g_bufs.end())
        FAILMSG("bad fused input operand");
    const unsigned* Col = (const unsigned*)ic->second.p;
    const float* Mot = (const float*)im->second.p;
    const float* His = (const float*)ih->second.p;
    sycl::half* Feat = (sycl::half*)ift->second.p;
    const float* Pl = (const float*)ip->second.p;
    const float* Tb = (const float*)itb->second.p;
    prepass::PreArgs A{ Col, Mot, His, Feat, Pl, Tb, pixels, height, width,
                        pitch, source_h, source_w, flags };
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range((size_t)pixels), prepass::pre_kernel(A));
    });
    return 0;
}
// int xmx_rec_post(int colour, int head, int history, int result, int table, int neural,
//                  unsigned pixels, unsigned height, unsigned width,
//                  unsigned pitch, unsigned source_h, unsigned source_w)
// route(a) step 5 (section 90): the fused image OUTPUT, SYCL port of nr_post.comp. The
// other half of nr_pre: compose the network's head back into the game's colour format.
// nr_replay.c:693 passes (colour, head, history, result, table, neural=history) -- the
// kept prediction writes back into the SAME history buffer the next frame reads (the
// per-work-item read-then-write of prev[network*3+ch] then neural[network*3+ch] is safe:
// same index, ordered within one item). m=pixels on the SOURCE extent, k=network height,
// batch=network width, sa=pitch, sb=source_h, sc=source_w (nr_post:115 width=pc.sc).
int xmx_rec_post(int colour, int head, int history, int result, int table, int neural,
                 unsigned pixels, unsigned height, unsigned width,
                 unsigned pitch, unsigned source_h, unsigned source_w) {
    if (!g_recording) FAILMSG("not recording");
    if (!g_l0) FAILMSG("xmx_rec_post needs a Level-Zero device (the fused kernel faults on OpenCL; section 92)");
    if (!pixels || !height || !width) FAILMSG("invalid fused output extent");
    auto ic = g_bufs.find(colour), ihd = g_bufs.find(head), ih = g_bufs.find(history);
    auto irs = g_bufs.find(result), itb = g_bufs.find(table), inl = g_bufs.find(neural);
    if (ic == g_bufs.end() || ihd == g_bufs.end() || ih == g_bufs.end() ||
        irs == g_bufs.end() || itb == g_bufs.end() || inl == g_bufs.end())
        FAILMSG("bad fused output operand");
    const unsigned* Col = (const unsigned*)ic->second.p;
    const float* Hd = (const float*)ihd->second.p;
    const float* His = (const float*)ih->second.p;
    unsigned* Res = (unsigned*)irs->second.p;
    const float* Tb = (const float*)itb->second.p;
    float* Neu = (float*)inl->second.p;
    postpass::PostArgs A{ Col, Hd, His, Res, Tb, Neu, pixels, height, width,
                          pitch, source_h, source_w };
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range((size_t)pixels), postpass::post_kernel(A));
    });
    return 0;
}
int xmx_rec_gemm_qkv(int a,int w,int q,int k,int v,int sc,unsigned M,unsigned ch,unsigned hd,unsigned tk,unsigned vt) { (void)a;(void)w;(void)q;(void)k;(void)v;(void)sc;(void)M;(void)ch;(void)hd;(void)tk;(void)vt; NOT_YET("xmx_rec_gemm_qkv"); }
// int xmx_rec_gemm_qkv_window(int image, int weight, int q, int k, int v, int scale,
//                             unsigned M, unsigned channels, unsigned heads, unsigned tokens,
//                             unsigned width, unsigned height, unsigned across, unsigned pad,
//                             unsigned image_mode)
// f16 gemm_qkv_window FOUNDATION (section 88 route; window_block's first leg). The f16
// twin of the green int8_qkv swap-in #4 (section 75) with the window gather + publish_image
// of gemm_staged.comp:222-243 (record_gemm_qkv + window_a, libxmx.c:2424/2437). Pinned
// before writing (section 73):
//   gather (host, the window_int8_residual pattern): row r -> window=r/tokens, token=r%tokens;
//     y=(window/across)*8+token/8 - (pad>>16), x=(window%across)*8+token%8 - (pad&0xffff);
//     OUT OF RANGE (y<0||x<0||y>=height||x>=width) -> the row's 32 channels are 0.0;
//     else at=(y*width+x)*channels + c, read image (half iff image_mode&1), and if
//     image_mode&2 (publish_image) e4m3 each value; the gathered A is HALF (the loader
//     stores float16_t(lo/hi) into buf_a).
//   gemm: A(M x channels) @ B(channels x 3*channels) -> f32 acc (M x 3C). B is (K,N)
//     row-major (record_gemm_qkv default, NOT transposed) -> f16v1::pack_b.
//   qkv_epilogue (qkv_epilogue.glsl:40-77, the f16 path QKV_READ(i)=float(stage[i)) --
//     NO dequantise scale multiply (that was the int8 path): per row, per head, the 32
//     columns of Q (part 0), K (part 1), V (part 2):
//       Q/K: h[i]=half_round(acc); recip=cosine_reciprocal(h) (vit: vit_reciprocal);
//            value=hmul(h,recip); Q also hmul(vit?hmul(value,VIT_ROOT):value, half_round(scale[head]));
//       V:   value = acc (no norm);
//       publish = e4m3(value) -> half, scatter at=((window*heads+head)*tokens+token)*32 + c%32.
// captured window_block uses heads==1, channels==32, tokens==64.
int xmx_rec_gemm_qkv_window(int image, int weight, int q, int k, int v, int scale,
                            unsigned M, unsigned channels, unsigned heads, unsigned tokens,
                            unsigned width, unsigned height, unsigned across, unsigned pad,
                            unsigned image_mode) {
    if (!g_recording) FAILMSG("not recording");
    if (!width || !height || !across || tokens != 64u || image_mode > 3u)
        FAILMSG("invalid window-gathered QKV projection (libxmx.c:2437)");
    if (!M || !channels || !heads || channels != heads * 32u || (M % tokens))
        FAILMSG("QKV needs channels==heads*32, tokens|M (libxmx.c record_gemm_qkv)");
    auto im = g_bufs.find(image), iw = g_bufs.find(weight);
    auto iq = g_bufs.find(q), ik = g_bufs.find(k), iv = g_bufs.find(v), is = g_bufs.find(scale);
    if (im == g_bufs.end() || iw == g_bufs.end() || iq == g_bufs.end() || ik == g_bufs.end() ||
        iv == g_bufs.end() || is == g_bufs.end()) FAILMSG("bad gemm_qkv_window operand");
    if (iq == ik || ik == iv || iq == iv) FAILMSG("QKV targets must be distinct");
    const sycl::half* Img = (const sycl::half*)im->second.p;   // image (half iff mode&1)
    const float* ImgF = (const float*)im->second.p;
    const sycl::half* Wraw = (const sycl::half*)iw->second.p;  // (channels x 3*channels) row-major
    sycl::half *Q = (sycl::half*)iq->second.p, *Kk = (sycl::half*)ik->second.p,
               *V = (sycl::half*)iv->second.p;
    const float* qs = (const float*)is->second.p;              // heads entries
    const bool image_half = (image_mode & 1u) != 0u;
    const bool image_publish = (image_mode & 2u) != 0u;
    const bool vit = false;                                    // window blocks are never vit
    const unsigned C = channels, NH = 3u * channels;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    const unsigned top = pad >> 16, left = pad & 0xffffu;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        // gather the image into a dense (M x C) half A (host; the window_int8_residual
        // pattern). The image is DEVICE memory: download it whole before the host gather
        // (the section-73 trap -- dereferencing a device pointer in host code crashes).
        const size_t img_elems = (size_t)height * width * C;
        std::vector<sycl::half> hImgH; std::vector<float> hImgF;
        if (image_half) { hImgH.resize(img_elems); ev_sync(GQ->memcpy(hImgH.data(), Img, img_elems * 2)); }
        else            { hImgF.resize(img_elems); ev_sync(GQ->memcpy(hImgF.data(), ImgF, img_elems * 4)); }
        std::vector<sycl::half> hA((size_t)M * C);
        for (unsigned r = 0; r < M; ++r) {
            unsigned window = r / tokens, token = r % tokens;
            int y = (int)((window / across) * 8u + token / 8u) - (int)top;
            int x = (int)((window % across) * 8u + token % 8u) - (int)left;
            if (y < 0 || x < 0 || y >= (int)height || x >= (int)width) {
                for (unsigned c = 0; c < C; ++c) hA[(size_t)r * C + c] = sycl::half(0.f);
                continue;
            }
            size_t at = ((size_t)y * width + x) * C;
            for (unsigned c = 0; c < C; ++c) {
                float val = image_half ? (float)hImgH[at + c] : hImgF[at + c];
                if (image_publish) val = qr_e4m3(val);
                hA[(size_t)r * C + c] = sycl::half(val);
            }
        }
        std::vector<sycl::half> hApad((size_t)Mp * C, sycl::half(0.f));
        std::memcpy(hApad.data(), hA.data(), (size_t)M * C * 2);
        std::vector<sycl::half> hB((size_t)C * NH), hAp((size_t)Mp * C), hBp((size_t)C * NH);
        ev_sync(GQ->memcpy(hB.data(), Wraw, (size_t)C * NH * 2));
        f16v1::pack_a(hApad.data(), hAp.data(), Mp, (int)C);
        f16v1::pack_b(hB.data(), hBp.data(), (int)C, (int)NH);
        sycl::half* dAp = (sycl::half*)pool_get((size_t)Mp * C * 2);
        sycl::half* dBp = (sycl::half*)pool_get((size_t)C * NH * 2);
        float* dC = (float*)pool_get((size_t)Mp * NH * 4);
        ev_sync(GQ->memcpy(dAp, hAp.data(), (size_t)Mp * C * 2));
        ev_sync(GQ->memcpy(dBp, hBp.data(), (size_t)C * NH * 2));
        f16v1::gemm(*GQ, dAp, dBp, dC, Mp, (int)NH, (int)C);
        // qkv_epilogue: in-place Q/K head norm on the f32 acc (QKV_READ = float(stage)),
        // then publish e4m3 -> half scatter. One device pass per (row, head) for the norm,
        // then the publish/scatter pass.
        GQ->parallel_for(sycl::range((size_t)M * heads), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / heads), head = (unsigned)(i % heads);
            float row32[32];
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = head * 32u + (unsigned)c2;
                row32[c2] = qr_half_round(dC[(size_t)r * NH + n]);
            }
            float recip = ctree::cosine_reciprocal(row32);
            float sc = qr_half_round(qs[head]);
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = head * 32u + (unsigned)c2;
                float val = qr_half_round(cr_mul(row32[c2], recip));
                val = qr_half_round(cr_mul(val, sc));                 // Q: * scale (no VIT_ROOT, not vit)
                dC[(size_t)r * NH + n] = val;
            }
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = C + head * 32u + (unsigned)c2;
                row32[c2] = qr_half_round(dC[(size_t)r * NH + n]);
            }
            float krec = ctree::cosine_reciprocal(row32);
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = C + head * 32u + (unsigned)c2;
                dC[(size_t)r * NH + n] = qr_half_round(cr_mul(row32[c2], krec));
            }
            // V: no norm, the raw acc value stays (QKV_READ returns it).
        });
        GQ->parallel_for(sycl::range((size_t)M * NH), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / NH), n = (unsigned)(i % NH);
            unsigned part = n / C, col = n % C, head = col / 32u;
            sycl::half out = sycl::half(qr_e4m3(dC[i]));              // publish = e4m3 only
            unsigned w = r / tokens, t = r % tokens;
            size_t at = (((size_t)w * heads + head) * tokens + t) * 32u + (col % 32u);
            if (part == 0u) Q[at] = out; else if (part == 1u) Kk[at] = out; else V[at] = out;
        });
        pool_put(dAp); pool_put(dBp); pool_put(dC);
    });
    return 0;
}
// int xmx_rec_gemm_residual(int a, int b, int c, int skip, int cosine,
//                           unsigned M, unsigned N, unsigned K, unsigned flags)
// f16 gemm_residual FOUNDATION (section 88, the f16 twin of the green int8 residual
// swap-in #3). libxmx.c:2365 pins the ABI: record_gemm(a,b,c,M,N,K, batch=1, dense,
// NO scales, flags|0x20000, skip, cosine). The ONLY difference from the int8 residual is
// that the f16 acc is already the true value -- there is no cr_mul(row)*cr_mul(col)
// dequantise step. residual_epilogue.glsl:18-23 (add_gemm_residual) + gemm_staged.comp:346
// pin the math, copied here BEFORE writing either side (section 73's discipline):
//   total = fma( skipped, cosine[c], acc )   ONE fused rounding (the .comp comment says
//           the contraction policy is what keeps it bit-identical to the two-pass path;
//           device = sycl::fma = HW FMA = correctly-rounded single rounding)
//   out   = publish(epi, total) -> f16 iff 0x1000 else f32
//   skipped = half iff 0x40000 else f32; cosine f32[N]; at = r*N+c (non-window; the
//           window variant is xmx_rec_gemm_window_residual, its own op).
// B is (K,N) row-major (record_gemm default transposed=0) -> f16v1::pack_b. M padded to
// the 16-row tile; padded rows never published. 0x20000 is OR'd inside the Vulkan
// wrapper (libxmx.c:2365), the plan-layer flags never carry it -- this op IS the adding
// variant, so there is nothing to require and nothing to copy (section 74's guard lesson).
int xmx_rec_gemm_residual(int a, int b, int c, int skip, int cosine,
                          unsigned M, unsigned N, unsigned K, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (N % 16u) || (K % 16u))
        FAILMSG("gemm_residual f16 needs N%%16==0, K%%16==0 (our tile)");
    if (flags & 0x80000u) FAILMSG("window residual belongs to xmx_rec_gemm_window_residual");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    auto isk = g_bufs.find(skip), ico = g_bufs.find(cosine);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        isk == g_bufs.end() || ico == g_bufs.end()) FAILMSG("bad gemm_residual operand");
    const sycl::half* Araw = (const sycl::half*)ia->second.p;
    const sycl::half* Braw = (const sycl::half*)ib->second.p;   // (K,N) row-major
    void* Cout = ic->second.p;
    const void* skp = isk->second.p;
    const float* cp = (const float*)ico->second.p;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const bool half_skip = (flags & 0x40000u) != 0u;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    const size_t na = (size_t)Mp * K, nb = (size_t)K * N;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        std::vector<sycl::half> hA((size_t)M * K), hApad(na, sycl::half(0.f)), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, (size_t)M * K * 2));
        std::memcpy(hApad.data(), hA.data(), (size_t)M * K * 2);
        ev_sync(GQ->memcpy(hB.data(), Braw, nb * 2));
        f16v1::pack_a(hApad.data(), hAp.data(), Mp, (int)K);
        f16v1::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        sycl::half* dAp = (sycl::half*)pool_get(na * 2);
        sycl::half* dBp = (sycl::half*)pool_get(nb * 2);
        float* dC = (float*)pool_get((size_t)Mp * N * 4);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na * 2));
        ev_sync(GQ->memcpy(dBp, hBp.data(), nb * 2));
        f16v1::gemm(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K);
        GQ->parallel_for(sycl::range((size_t)M * N),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned col = (unsigned)(i % N);
            float sk = half_skip ? (float)((const sycl::half*)skp)[i] : ((const float*)skp)[i];
            float total = sycl::fma(sk, cp[col], dC[i]);
            if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
            else        ((float*)Cout)[i] = qr_publish(epi, total);
        });
        pool_put(dAp); pool_put(dBp); pool_put(dC);
    });
    return 0;
}
// int xmx_rec_gemm_window_residual(int a, int b, int c, int skip, int cosine,
//                                  unsigned M, unsigned N, unsigned K, unsigned flags,
//                                  unsigned height, unsigned width, unsigned across,
//                                  unsigned pad)
// f16 gemm_window_residual FOUNDATION (section 88 route; window_block's third leg). The
// f16 twin of the green int8 window_int8_residual swap-in #5 (section 76): the SAME
// unpadded-image index map of residual_epilogue.glsl:4-15, but the acc is already the true
// value (no cr_mul(row)*cr_mul(col) dequantise step). libxmx.c:2377 pins the ABI:
// record_gemm(a,b,c,M,N,K, batch=1, dense, flags|0xa0000, skip, cosine, window) -- B is
// (K,N) row-major (record_gemm default, NOT transposed) -> f16v1::pack_b.
//   block position: r = window*64 + token (window-major over the 8x8 token grid);
//   map: y=(window/across)*8+token/8, x=(window%across)*8+token%8, top=pad>>16,
//     left=pad&0xffff; OUT OF RANGE (cropped padding) -> the element is skipped ENTIRELY
//     (.comp:258 continue before any read or write);
//   at = ((y-top)*width + x-left)*N + col reads the skip (IMAGE layout, height*width*N)
//     and writes C; cosine read at at%N = col (the map preserves %N).
//   total = fma( skipped, cosine[col], acc )  ONE fused rounding (residual_epilogue.glsl:22);
//   out = publish(epi, total) -> f16 iff 0x1000 else f32. skip half iff 0x40000.
// SIZE validation AT RUN TIME (the step-2588 lesson, section 76): the scratch recording's
// placeholder buffers are tiny and destroyed before the captured graph runs.
int xmx_rec_gemm_window_residual(int a, int b, int c, int skip, int cosine,
                                 unsigned M, unsigned N, unsigned K, unsigned flags,
                                 unsigned height, unsigned width, unsigned across,
                                 unsigned pad) {
    if (!g_recording) FAILMSG("not recording");
    if (!height || !width || !across) FAILMSG("invalid window residual");
    if (!M || !N || !K || (N % 16u) || (K % 16u) || (M % 64u))
        FAILMSG("gemm_window_residual f16 needs N%%16,K%%16,M%%64 (our tile)");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    auto isk = g_bufs.find(skip), ico = g_bufs.find(cosine);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        isk == g_bufs.end() || ico == g_bufs.end()) FAILMSG("bad gemm_window_residual operand");
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const bool half_skip = (flags & 0x40000u) != 0u;
    const size_t wsz = narrow ? 2u : 4u;
    const size_t img_elems = (size_t)height * width * N;
    const size_t blk_elems = (size_t)M * N;
    const size_t c_need = img_elems * wsz, k_need = img_elems * (half_skip ? 2u : 4u);
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    const size_t na = (size_t)Mp * K, nb = (size_t)K * N;
    const unsigned top = pad >> 16, left = pad & 0xffffu;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        auto sized = [&](int id, size_t bytes, const char* what) -> void* {
            auto it = g_bufs.find(id);
            if (it == g_bufs.end())
                throw std::runtime_error(std::string("window residual: ") + what + " not live at run");
            if (it->second.bytes < bytes)
                throw std::runtime_error(std::string("window residual: ") + what + " smaller than the image at run");
            return it->second.p;
        };
        sycl::half* Araw = (sycl::half*)sized(a, (size_t)M * K * 2, "A");
        sycl::half* Braw = (sycl::half*)sized(b, nb * 2, "B");
        void* Cout = sized(c, c_need, "C");
        const void* skp = sized(skip, k_need, "skip");
        const float* cp = (const float*)sized(cosine, (size_t)N * 4u, "cosine");
        std::vector<sycl::half> hA((size_t)M * K), hApad(na, sycl::half(0.f)), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, (size_t)M * K * 2));
        std::memcpy(hApad.data(), hA.data(), (size_t)M * K * 2);
        ev_sync(GQ->memcpy(hB.data(), Braw, nb * 2));
        f16v1::pack_a(hApad.data(), hAp.data(), Mp, (int)K);
        f16v1::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        sycl::half* dAp = (sycl::half*)pool_get(na * 2);
        sycl::half* dBp = (sycl::half*)pool_get(nb * 2);
        float* dC = (float*)pool_get((size_t)Mp * N * 4);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na * 2));
        ev_sync(GQ->memcpy(dBp, hBp.data(), nb * 2));
        f16v1::gemm(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K);
        GQ->parallel_for(sycl::range(blk_elems),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / N), col = (unsigned)(i % N);
            unsigned window = r / 64u, token = r % 64u;
            unsigned y = (window / across) * 8u + token / 8u;
            unsigned x = (window % across) * 8u + token % 8u;
            if (y < top || x < left || y - top >= height || x - left >= width) return;
            size_t out = ((size_t)(y - top) * width + (x - left)) * N + col;
            float sk = half_skip ? (float)((const sycl::half*)skp)[out] : ((const float*)skp)[out];
            float total = sycl::fma(sk, cp[col], dC[i]);
            if (narrow) ((sycl::half*)Cout)[out] = sycl::half(qr_publish(epi, total));
            else        ((float*)Cout)[out] = qr_publish(epi, total);
        });
        pool_put(dAp); pool_put(dBp); pool_put(dC);
    });
    return 0;
}
int xmx_rec_gemm_int8_fused(int a,int b,int c,int as,int bs,unsigned M,unsigned N,unsigned K,unsigned fl) { (void)a;(void)b;(void)c;(void)as;(void)bs;(void)M;(void)N;(void)K;(void)fl; NOT_YET("xmx_rec_gemm_int8_fused"); }

/* swap-in TARGETS (section 68 A-list): names exist so prepare() GRABs them; every one
   fails loudly if reached. As each is implemented (a green chain gated + diffed), its
   stub is replaced by the real recorder -- the scoreboard is "the first target that still
   answers NOT_YET", which walks down the plan as we implement. */
// int xmx_rec_ffn(int a, int expand, int projection, int out, int skip, int cosine,
//                 unsigned M, unsigned cin, unsigned hidden, unsigned groups, unsigned flags)
// swap-in #12 (section 88 route): the fused feed-forward, composed from the two green f16
// legs. ffn_fused.comp's own header says it is "Bit-identical to the two GEMMs by
// construction", and test_ffn_fused.py:65-69 is the shipping witness for exactly that
// decomposition (pinned here BEFORE writing, section 73's discipline):
//   pass 1 (expand):  gemm(a, expand -> hidden16, M, N=hidden, K=cin, batch=1, dense,
//                          epilogue=EPI_GATE_E4M3(3), narrow=True)   -- hidden is ALWAYS
//                          the gated e4m3 half (the ffn structure, not the caller's flags)
//   pass 2 (project): gemm_residual(hidden16, projection -> out, skip, cosine,
//                          M, N=cin, K=hidden, epilogue=epi, narrow, skip_half)
// where epi=(flags>>8)&0xF, narrow=flags&0x1000, half_skip=flags&0x40000 (libxmx.c:3115
// mask 0x41f00; residual=skip>=0||cosine>=0 -> the 0x20000 the wrapper ORs). captured ffn
// is ALL groups==1, cin==32, hidden==128 (the narrow staged blocks): 8 calls, M=130560,
// flags in {0x40000 half-skip, 0x0 f32-skip}, both epi=0 f32-out. The branched (groups>1,
// no residual) path is NOT in the captured graph -- rejected loudly so the game face never
// silently mis-runs it (section 70's fail-loud rule).
// Composition = one g_cmds push (one plan step -> +1 pass), two device GEMMs with a host
// round-trip of hidden16 between them (the window_attention/global_attention pattern,
// section 85/86): the expand publishes hidden16 on device, we download it, pack it as the
// projection's A, and the projection adds the residual in its epilogue. The host round-trip
// is the offline/gate form; folding it is the megakernel stage's job (section 85's note).
int xmx_rec_ffn(int a, int expand, int projection, int out, int skip, int cosine,
                unsigned M, unsigned cin, unsigned hidden, unsigned groups, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || (M % 16u) || !cin || (cin % 16u) || !hidden || (hidden % 32u))
        FAILMSG("ffn needs M%%16, cin%%16, hidden%%32 (libxmx.c:3118)");
    if (flags & ~0x41f00u) FAILMSG("ffn takes an epilogue, a half output and a half skip only");
    if (groups != 1u || cin != 32u)
        FAILMSG("the captured ffn is the narrow groups==1 cin==32 path only (branched not in plan)");
    const bool residual = (skip >= 0) || (cosine >= 0);
    if (residual && (skip < 0 || cosine < 0)) FAILMSG("ffn residual needs both skip and cosine");
    if (!residual && (flags & 0x40000u)) FAILMSG("a half skip without a residual");
    auto ia = g_bufs.find(a), ib = g_bufs.find(expand), ip = g_bufs.find(projection),
         ic = g_bufs.find(out);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ip == g_bufs.end() || ic == g_bufs.end())
        FAILMSG("bad ffn operand");
    const sycl::half* Araw = (const sycl::half*)ia->second.p;
    const sycl::half* Eraw = (const sycl::half*)ib->second.p;   // expand (cin x hidden) row-major
    const sycl::half* Praw = (const sycl::half*)ip->second.p;   // projection (hidden x cin) row-major
    void* Cout = ic->second.p;
    const void* skp = residual ? g_bufs.find(skip)->second.p : nullptr;
    const float* cp = residual ? (const float*)g_bufs.find(cosine)->second.p : nullptr;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const bool half_skip = (flags & 0x40000u) != 0u;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    g_cmd_names.push_back(__func__);
        flop_note("ffn",M,hidden,cin,1); flop_note("ffn",M,cin,hidden,1);
        flop_note("ffn_stem",M,32u,128u,1);
    g_cmds.push_back([=]() {
        // fully device-resident (section 92): both legs pack on device (packdev), the
        // hidden16 stays on device between them -- the old path downloaded Araw/Eraw and
        // the hidden16 to host and re-uploaded packed operands (the 519ms). in-order
        // queue: every read kernel is enqueued before the pool_put that recycles its
        // buffer, so cross-pass scratch reuse is safe; one wait at the end of the pass.
        sycl::half* dAp = (sycl::half*)pool_get((size_t)Mp * cin * 2);
        packdev::pack_a16(*GQ, Araw, dAp, (int)M, Mp, (int)cin);
        sycl::half* dEp = cached_pack_b_f16(expand, Eraw, (int)cin, (int)hidden);   // weight
        // P3 (section 100): the expand's published halves ARE the projection's pack_a16
        // A tile -- (tr,tc) of the expand == (tr,kc=tc) of the projection, same 16x16
        // geometry, same pub_esimd(3) values, pad rows explicit zero. gemm_pub_pa16
        // writes the TILE directly: dH (M x hidden halfs, 33MB/call) + the pack_a16
        // pass (read 33 + write 33) vanish per call. Gate NR_FFN_TILE (default ON;
        // =0 restores the two-pass dH form).
        static bool ffntile = !getenv("NR_FFN_TILE") || atoi(getenv("NR_FFN_TILE")) != 0;
        // P3c v3d (section 100): the ffn_fused CHIP kernel -- ONE launch, hidden
        // NEVER leaves the chip, and it eats the RAW f16 A (pack_a16 vanishes too).
        // bench_ffnchip: 4.4x vs the promoted tile-chain split, BIT-EXACT. Guards:
        // cin==32, hidden==128, f32-out (narrow==false, epi==0 -- the captured ffn
        // flags are exactly this), residual skip half or f32. Escape NR_FFN_CHIP=0.
        static bool ffchip = !getenv("NR_FFN_CHIP") || atoi(getenv("NR_FFN_CHIP")) != 0;
        if (ffntile && ffchip && hidden == 128u && cin == 32u && !narrow && epi == 0u) {
            sycl::half* dPp = cached_pack_b_f16(projection, Praw, (int)hidden, (int)cin);
            float* dC2 = (float*)pool_get((size_t)Mp * cin * 4);
            ffnc::launch_ffn_chip(*GQ, Araw, dEp, dPp, dC2, (int)M, Mp);
            // the residual + publish tail stays SPLIT (the gate's f32-skip 131/8192
            // caught the in-kernel contracted fma -- sycl::fma is the authority,
            // section 92's gemm_res lesson, third time proven).
            GQ->parallel_for(sycl::range((size_t)M * cin), [=](sycl::item<1> it) {
                size_t i2 = it.get_id(0);
                unsigned col = (unsigned)(i2 % cin);
                float total = dC2[i2];
                if (residual) {
                    float sk = half_skip ? (float)((const sycl::half*)skp)[i2] : ((const float*)skp)[i2];
                    total = sycl::fma(sk, cp[col], total);
                }
                ((float*)Cout)[i2] = qr_publish(epi, total);
            });
            pool_put(dC2);
            return;
        }
        if (ffntile) {
            sycl::half* dHp = (sycl::half*)pool_get((size_t)Mp * hidden * 2);
            f16v1::gemm_pub_pa16(*GQ, dAp, dEp, dHp, (int)M, Mp, (int)hidden, (int)cin, 3u);
            pool_put(dAp);   // dEp is cache-owned (weight)
            sycl::half* dPp = cached_pack_b_f16(projection, Praw, (int)hidden, (int)cin);   // weight
            float* dC2 = (float*)pool_get((size_t)Mp * cin * 4);
            f16v1::gemm(*GQ, dHp, dPp, dC2, Mp, (int)cin, (int)hidden);
            pool_put(dHp);
            GQ->parallel_for(sycl::range((size_t)M * cin), [=](sycl::item<1> it) {
                size_t i = it.get_id(0);
                unsigned col = (unsigned)(i % cin);
                float total = dC2[i];
                if (residual) {
                    float sk = half_skip ? (float)((const sycl::half*)skp)[i] : ((const float*)skp)[i];
                    total = sycl::fma(sk, cp[col], total);
                }
                if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
                else        ((float*)Cout)[i] = qr_publish(epi, total);
            });
            pool_put(dC2);   // dPp is cache-owned (weight)
            return;
        }
        sycl::half* dH = (sycl::half*)pool_get((size_t)M * hidden * 2);
        // DERIVED (section 92): fuse publish(3) (gate_activation + e4m3) into the gemm
        // store -- kills the dC1 float scratch + the separate publish pass. pub_esimd(3u)
        // is the same gate+e4m3 chain proven bit-exact by the batched epi3 win.
        f16v1::gemm_pub(*GQ, dAp, dEp, dH, (int)M, Mp, (int)hidden, (int)cin, 3u);
        pool_put(dAp);   // dEp is cache-owned (weight)
        // ---- pass 2: projection gemm_residual(hidden16, projection -> out) ----
        sycl::half* dHp = (sycl::half*)pool_get((size_t)Mp * hidden * 2);
        float* dC2 = (float*)pool_get((size_t)Mp * cin * 4);
        packdev::pack_a16(*GQ, dH, dHp, (int)M, Mp, (int)hidden);   // dH on device
        sycl::half* dPp = cached_pack_b_f16(projection, Praw, (int)hidden, (int)cin);   // weight
        f16v1::gemm(*GQ, dHp, dPp, dC2, Mp, (int)cin, (int)hidden);
        GQ->parallel_for(sycl::range((size_t)M * cin), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned col = (unsigned)(i % cin);
            float total = dC2[i];
            if (residual) {
                float sk = half_skip ? (float)((const sycl::half*)skp)[i] : ((const float*)skp)[i];
                total = sycl::fma(sk, cp[col], total);
            }
            if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
            else        ((float*)Cout)[i] = qr_publish(epi, total);
        });
        pool_put(dHp); pool_put(dC2); pool_put(dH);   // dPp is cache-owned (weight)
    });
    return 0;
}
// int xmx_rec_ffn_merge(int source, int skip, int sincos, int expand, int projection,
//                       int out, int cosine, unsigned height, unsigned width,
//                       unsigned source_width, unsigned flags)
// swap-in #14 (section 88 route): block 70's feed-forward with its input made in the same
// pass (ffn_fused.comp flag 0x1000000, libxmx.c:3157). test_glue.py:317-322 is the
// shipping witness: ffn_merge == upsample_merge THEN the plain fused feed-forward reading
// both of its outputs. The merge (ffn_fused.comp merged4:132-138 / resident.comp UPSAMPLE_
// MERGE:542-560, verified line-for-line identical) is pin-before-write (section 73):
//   above = ((y/2)*source_width + x/2)*32 + c   (x=pixel%width, y=pixel/width; source is the
//           level above at half the extent, HALF)
//   scaled = cr_mul( f32(source[above]), sin[c] )        precise, rounded on its own
//   merged = fma( f32(skip[pixel*32+c]), cos[c], scaled )  the RESIDUAL pass's fused add
//           (skip is the full-resolution skip, HALF; sincos holds sin then cos, f32[64])
//   the RAW f32 merged is the feed-forward's residual skip (mask 0x1f00 has no 0x40000 ->
//           FloatBuf read, section-88's same reasoning as the stem); its e4m3-published half
//           copy is the expand GEMM's input.
// Then pass B (expand: gemm(merged16, expand->f32)->publish(3)->half) and pass C
// (projection: gemm(hidden, projection->f32)+fma(raw merged, cosine[col], proj)->publish)
// are the ffn structure's two legs, identical to xmx_rec_ffn_stem's B/C (section 88).
// captured ffn_merge: 1 call, height=544 width=960 source_width=480, flags=0 (f32-out).
int xmx_rec_ffn_merge(int source, int skip, int sincos, int expand, int projection,
                      int out, int cosine, unsigned height, unsigned width,
                      unsigned source_width, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    const unsigned M = height * width;
    if (!M || (M % 16u) || (height % 2u) || (width % 2u) || source_width < width / 2u)
        FAILMSG("the merged feed-forward needs an even extent in 16-row blocks (libxmx.c:3161)");
    if (flags & ~0x1f00u) FAILMSG("the merged feed-forward takes an epilogue and a half output only");
    auto isrc = g_bufs.find(source), isk = g_bufs.find(skip), isc = g_bufs.find(sincos),
         iex = g_bufs.find(expand), ipr = g_bufs.find(projection), ic = g_bufs.find(out),
         ico = g_bufs.find(cosine);
    if (isrc == g_bufs.end() || isk == g_bufs.end() || isc == g_bufs.end() ||
        iex == g_bufs.end() || ipr == g_bufs.end() || ic == g_bufs.end() || ico == g_bufs.end())
        FAILMSG("bad ffn_merge operand");
    const sycl::half* Src = (const sycl::half*)isrc->second.p;   // level above (half)
    const sycl::half* Skp = (const sycl::half*)isk->second.p;    // full-resolution skip (half)
    // section 100 D15 (stop=91): the READER aliased to the same preallocated probe
    // buffer the writer (stop=91 leg3) writes -- the full hand-off moves OFF plan
    // buffer 1265. Ledger probe only (frame garbage by design).
    {
        static const char* wbs = getenv("NR_WB_STOP");
        if (wbs && atoi(wbs) == 91 && g_probe33) Skp = (const sycl::half*)g_probe33;
    }
    const float* SC = (const float*)isc->second.p;               // sin then cos, f32[64]
    const sycl::half* Eraw = (const sycl::half*)iex->second.p;   // expand (32 x 128)
    const sycl::half* Praw = (const sycl::half*)ipr->second.p;   // projection (128 x 32)
    void* Cout = ic->second.p;
    const float* cp = (const float*)ico->second.p;               // cosine f32[32]
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    g_cmd_names.push_back(__func__);
    // section 100 D13 probe (NR_SKIP_FFN_MERGE=1, diagnostic ledger only -- the
    // frame is garbage by design): the writer leg3 costs 40ms in the async graph
    // ONLY when it writes plan buffer 1265, and per-closure sync says the kernel
    // itself is ~4ms either way. 1265's only reader is THIS pass's Skp (ffn_merge).
    // Skipping the reader tests the writer<->reader interaction hypothesis head-on.
    if (getenv("NR_SKIP_FFN_MERGE")) {
        g_cmds.push_back([](){});
        return 0;
    }
    g_cmds.push_back([=]() {
        // ---- pass A: merged4 on device -> dMerged f32 (the skip) + e4m3-half -> host ----
        float* dMerged = (float*)pool_get((size_t)M * 32 * 4);   // raw, kept for pass C
        sycl::half* dM16 = (sycl::half*)pool_get((size_t)M * 32 * 2);
        GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned c = (unsigned)(i % 32u), pixel = (unsigned)(i / 32u);
            unsigned x = pixel % width, y = pixel / width;
            size_t above = ((size_t)(y / 2u) * source_width + (x / 2u)) * 32u + c;
            float scaled = cr_mul((float)Src[above], SC[c]);              // precise, own rounding
            float merged = sycl::fma((float)Skp[i], SC[32u + c], scaled); // fused residual add
            dMerged[i] = merged;
            dM16[i] = sycl::half(qr_e4m3(merged));                        // published = GEMM input
        });
        // fully device-resident (section 92): dM16 stays on device for pass B's pack_a16 --
        // the old path downloaded it and re-uploaded a packed operand (the 256ms).
        // ---- pass B: expand gemm(merged16, expand -> f32), publish(3) -> half hidden ----
        // P3f: the chip path eats dM16 RAW -> skip the dA2 pack entirely.
        static bool mchip_probe = !getenv("NR_FFN_CHIP") || atoi(getenv("NR_FFN_CHIP")) != 0;
        static bool mtile_probe = !getenv("NR_FFN_TILE") || atoi(getenv("NR_FFN_TILE")) != 0;
        const bool skip_pack = mchip_probe && mtile_probe && !narrow && epi == 0u;
        sycl::half* dA2 = skip_pack ? nullptr : (sycl::half*)pool_get((size_t)Mp * 32 * 2);
        if (!skip_pack) packdev::pack_a16(*GQ, dM16, dA2, (int)M, Mp, 32);   // dM16 on device
        sycl::half* dB2 = cached_pack_b_f16(expand, Eraw, 32, 128);   // weight
        // DERIVED (section 92): fuse publish(3) into the gemm store (dC1 was dead after
        // this pass). pass C's residual fma stays split (the gemm_res 13-mismatch lesson).
        // P3b (section 100): the hidden16 goes STRAIGHT into pass C's A tile
        // (gemm_pub_pa16, the proven ffn lever): dHid + its pack_a16 pass vanish.
        static bool ffntile2 = !getenv("NR_FFN_TILE") || atoi(getenv("NR_FFN_TILE")) != 0;
        // P3f: the chip kernel on merge's B->C legs (dM16 = the raw merged row-major
        // M x 32 half = the chip's dA contract; the dA2 pack skips on this path).
        static bool ffchip2 = !getenv("NR_FFN_CHIP") || atoi(getenv("NR_FFN_CHIP")) != 0;
        const bool merge_chip = ffntile2 && ffchip2 && !narrow && epi == 0u;
        if (merge_chip) {
            sycl::half* dPp2 = cached_pack_b_f16(projection, Praw, 128, 32);
            float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
            ffnc::launch_ffn_chip(*GQ, dM16, dB2, dPp2, dC2, (int)M, Mp);
            pool_put(dM16);   // dA2 was never packed on this path; dB2/dPp2 cache-owned
            GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
                size_t i2 = it.get_id(0);
                unsigned col = (unsigned)(i2 % 32u);
                float total = sycl::fma(dMerged[i2], cp[col], dC2[i2]);   // raw merged f32 skip
                if (narrow) ((sycl::half*)Cout)[i2] = sycl::half(qr_publish(epi, total));
                else        ((float*)Cout)[i2] = qr_publish(epi, total);
            });
            pool_put(dC2);
            pool_put(dMerged);
            return;
        }
        if (ffntile2) {
            sycl::half* dA3 = (sycl::half*)pool_get((size_t)Mp * 128 * 2);
            f16v1::gemm_pub_pa16(*GQ, dA2, dB2, dA3, (int)M, Mp, 128, 32, 3u);
            pool_put(dM16); pool_put(dA2);   // dB2 cache-owned
            float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
            sycl::half* dB3 = cached_pack_b_f16(projection, Praw, 128, 32);   // weight
            f16v1::gemm(*GQ, dA3, dB3, dC2, Mp, 32, 128);
            pool_put(dA3);
            GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
                size_t i = it.get_id(0);
                unsigned col = (unsigned)(i % 32u);
                float total = sycl::fma(dMerged[i], cp[col], dC2[i]);     // skip = raw merged f32
                if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
                else        ((float*)Cout)[i] = qr_publish(epi, total);
            });
            pool_put(dC2);   // dB3 is cache-owned (weight)
            pool_put(dMerged);
            return;
        }
        sycl::half* dHid = (sycl::half*)pool_get((size_t)M * 128 * 2);
        f16v1::gemm_pub(*GQ, dA2, dB2, dHid, (int)M, Mp, 128, 32, 3u);
        pool_put(dM16); pool_put(dA2);   // dB2 is cache-owned (weight)
        // ---- pass C: projection gemm(hidden, projection -> f32) + raw-merged residual ----
        sycl::half* dA3 = (sycl::half*)pool_get((size_t)Mp * 128 * 2);
        float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
        packdev::pack_a16(*GQ, dHid, dA3, (int)M, Mp, 128);   // dHid on device
        sycl::half* dB3 = cached_pack_b_f16(projection, Praw, 128, 32);   // weight
        f16v1::gemm(*GQ, dA3, dB3, dC2, Mp, 32, 128);
        pool_put(dHid);
        GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned col = (unsigned)(i % 32u);
            float total = sycl::fma(dMerged[i], cp[col], dC2[i]);     // skip = raw merged f32
            if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
            else        ((float*)Cout)[i] = qr_publish(epi, total);
        });
        pool_put(dA3); pool_put(dC2);   // dB3 is cache-owned (weight)
        pool_put(dMerged);
    });
    return 0;
}
// int xmx_rec_ffn_stem(int features, int adapter, int expand, int projection, int out,
//                      int cosine, unsigned M, unsigned flags)
// swap-in #13 (section 88 route): block 0's feed-forward with its input made in the same
// pass (ffn_fused.comp flag 0x2000000, libxmx.c:3191). The stem GEMM's ONE K step is made
// once into the A fragments, published, and made AGAIN raw where the residual needs it
// (ffn_fused.comp:46-50: "the stem, the 16 feature channels times the adapter, which the
// stem GEMM wrote as float32 and published for the same two readers"). Decomposition,
// pinned from the .comp before writing (section 73's discipline), test_glue.py's
// `ffn_fused_stem` against `gemm_dual` + the fused feed-forward is the shipping witness:
//   pass A (stem):    gemm(features, adapter -> dStem f32, M, 32, 16)
//                     hidden16 = e4m3(dStem) as half          -- the .comp stem branch is
//                     `stem[e] = e4m3(stem[e])` then narrow: publish = E4M3 ONLY (epi=1),
//                     NOT the gate. dStem (the RAW f32, before e4m3) is kept: it is the
//                     residual's skip.
//   pass B (expand):  gemm(hidden16, expand -> f32, M, 128, 32) -> publish(3)=gate->e4m3
//                     -> half hidden (the ffn structure's always-gated hidden, section 88)
//   pass C (project): gemm(hidden, projection -> dProj f32, M, 32, 128)
//                     total = fma( dStem[i], cosine[col], dProj[i] )   -- skip is the RAW
//                     stem in FLOAT32: libxmx.c:3191's mask is 0x1f00 (no 0x40000), so
//                     add_gemm_residual reads pc.d as FloatBuf (residual_epilogue.glsl:20).
//                     out = publish(epi, total) -> f16 iff 0x1000 else f32.
// captured ffn_stem (section 88's plan dump): 1 call, M=522240, flags=0 (epi=0, f32-out).
// It is the FIRST recorder in the captured graph (step 2534) -- the game face's hard gate.
// Composition = one g_cmds push (one plan step -> +1 pass); three device GEMMs with host
// round-trips of the two intermediates (the ffn/window_attention pattern, section 85/88).
int xmx_rec_ffn_stem(int features, int adapter, int expand, int projection, int out,
                     int cosine, unsigned M, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || (M % 16u)) FAILMSG("the stem feed-forward needs 16-row blocks (libxmx.c:3195)");
    if (flags & ~0x1f00u) FAILMSG("the stem feed-forward takes an epilogue and a half output only");
    auto ift = g_bufs.find(features), iad = g_bufs.find(adapter), iex = g_bufs.find(expand),
         ipr = g_bufs.find(projection), ic = g_bufs.find(out), ico = g_bufs.find(cosine);
    if (ift == g_bufs.end() || iad == g_bufs.end() || iex == g_bufs.end() ||
        ipr == g_bufs.end() || ic == g_bufs.end() || ico == g_bufs.end())
        FAILMSG("bad ffn_stem operand");
    const sycl::half* Fraw = (const sycl::half*)ift->second.p;   // features (M x 16)
    const sycl::half* Arw  = (const sycl::half*)iad->second.p;   // adapter (16 x 32)
    const sycl::half* Eraw = (const sycl::half*)iex->second.p;   // expand (32 x 128)
    const sycl::half* Praw = (const sycl::half*)ipr->second.p;   // projection (128 x 32)
    void* Cout = ic->second.p;
    const float* cp = (const float*)ico->second.p;               // cosine f32[32]
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        // fully device-resident (section 92): all three legs pack on device and the
        // hidden16/hidden intermediates stay on device between them -- the old path
        // downloaded Fraw/Arw/Eraw/Praw AND both intermediates to host and re-uploaded
        // packed operands (the 324ms). dS stays the raw f32 stem (pass C's residual).
        sycl::half* dA = (sycl::half*)pool_get((size_t)Mp * 16 * 2);
        float* dS = (float*)pool_get((size_t)Mp * 32 * 4);
        sycl::half* dH16 = (sycl::half*)pool_get((size_t)M * 32 * 2);
        packdev::pack_a16(*GQ, Fraw, dA, (int)M, Mp, 16);
        sycl::half* dB = cached_pack_b_f16(adapter, Arw, 16, 32);   // weight
        f16v1::gemm(*GQ, dA, dB, dS, Mp, 32, 16);
        pool_put(dA);   // dB is cache-owned (weight)
        // publish = E4M3 only, on device; dH16 stays for pass B's pack_a.
        GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            dH16[i] = sycl::half(qr_e4m3(dS[i]));
        });
        // ---- pass B: expand gemm(hidden16, expand -> f32), publish(3) -> half hidden ----
        // P3e: the chip kernel eats dH16 RAW (row-major M x 32 half = its dA contract),
        // so the dA2 pack_a16 pass is only needed by the tile-chain fallback -- skip it
        // entirely on the chip path (one launch + Mp*32*2 scratch gone per stem call).
        static bool ffntile3 = !getenv("NR_FFN_TILE") || atoi(getenv("NR_FFN_TILE")) != 0;
        static bool ffchip3 = !getenv("NR_FFN_CHIP") || atoi(getenv("NR_FFN_CHIP")) != 0;
        const bool stem_chip = ffntile3 && ffchip3 && !narrow && epi == 0u;
        sycl::half* dA2 = stem_chip ? nullptr : (sycl::half*)pool_get((size_t)Mp * 32 * 2);
        if (!stem_chip) packdev::pack_a16(*GQ, dH16, dA2, (int)M, Mp, 32);
        sycl::half* dB2 = cached_pack_b_f16(expand, Eraw, 32, 128);   // weight
        // DERIVED (section 92): fuse publish(3) into the gemm store (dC1 was dead after
        // this pass). pass A's dS is NOT fused -- pass C re-reads it as the residual skip.
        // P3b (section 100): hidden16 straight into pass C's A tile (gemm_pub_pa16):
        // dHid (M x 128 halfs) + its pack_a16 pass vanish. Same gate NR_FFN_TILE.
        if (stem_chip) {
            sycl::half* dPp3 = cached_pack_b_f16(projection, Praw, 128, 32);
            float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
            ffnc::launch_ffn_chip(*GQ, dH16, dB2, dPp3, dC2, (int)M, Mp);
            pool_put(dH16); pool_put(dA2);   // dB2/dPp3 cache-owned
            GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
                size_t i2 = it.get_id(0);
                unsigned col = (unsigned)(i2 % 32u);
                float total = sycl::fma(dS[i2], cp[col], dC2[i2]);   // skip = RAW f32 stem
                if (narrow) ((sycl::half*)Cout)[i2] = sycl::half(qr_publish(epi, total));
                else        ((float*)Cout)[i2] = qr_publish(epi, total);
            });
            pool_put(dC2);
            pool_put(dS);
            return;
        }
        if (ffntile3) {
            sycl::half* dA3 = (sycl::half*)pool_get((size_t)Mp * 128 * 2);
            f16v1::gemm_pub_pa16(*GQ, dA2, dB2, dA3, (int)M, Mp, 128, 32, 3u);
            pool_put(dH16); pool_put(dA2);   // dB2 is cache-owned (weight)
            float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
            sycl::half* dB3 = cached_pack_b_f16(projection, Praw, 128, 32);   // weight
            f16v1::gemm(*GQ, dA3, dB3, dC2, Mp, 32, 128);
            pool_put(dA3);
            GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
                size_t i = it.get_id(0);
                unsigned col = (unsigned)(i % 32u);
                float total = sycl::fma(dS[i], cp[col], dC2[i]);   // skip = RAW f32 stem (device)
                if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
                else        ((float*)Cout)[i] = qr_publish(epi, total);
            });
            pool_put(dC2);   // dB3 is cache-owned (weight)
            pool_put(dS);
            return;
        }
        sycl::half* dHid = (sycl::half*)pool_get((size_t)M * 128 * 2);
        f16v1::gemm_pub(*GQ, dA2, dB2, dHid, (int)M, Mp, 128, 32, 3u);
        pool_put(dH16); pool_put(dA2);   // dB2 is cache-owned (weight)
        // ---- pass C: projection gemm(hidden, projection -> f32) + raw-stem residual ----
        sycl::half* dA3 = (sycl::half*)pool_get((size_t)Mp * 128 * 2);
        float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
        packdev::pack_a16(*GQ, dHid, dA3, (int)M, Mp, 128);   // dHid on device
        sycl::half* dB3 = cached_pack_b_f16(projection, Praw, 128, 32);   // weight
        // pass C stays SPLIT (section 93): gemm_res fusion gave ZERO speed (462->464,
        // noise) because pass C is not publish-bound (its publish was already fused in
        // pass B), AND it cannot bit-match: sycl::fma is unsupported in an ESIMD kernel
        // (compile error) and ESIMD's sk*cos+acc differs from the device sycl::fma by
        // 1 ULP at e4m3 boundaries (bench_res: 3/4177920). bench_fma/bench_res kept as
        // the isolation instruments that proved this.
        f16v1::gemm(*GQ, dA3, dB3, dC2, Mp, 32, 128);
        pool_put(dHid);
        GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned col = (unsigned)(i % 32u);
            float total = sycl::fma(dS[i], cp[col], dC2[i]);   // skip = RAW f32 stem (device)
            if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
            else        ((float*)Cout)[i] = qr_publish(epi, total);
        });
        pool_put(dA3); pool_put(dC2);   // dB3 is cache-owned (weight)
        pool_put(dS);
    });
    return 0;
}
// int xmx_rec_gemm(int a, int b, int c, unsigned M, unsigned N, unsigned K,
//                  unsigned batch, unsigned sa, unsigned sb, unsigned sc, unsigned bt,
//                  unsigned lda, unsigned ldb, unsigned ldc,
//                  unsigned oa, unsigned ob, unsigned oc)
// swap-in #8 (section 82): the plain fp16 GEMM, the LAST undisputed family (42 captured
// calls). Math pinned from gemm_staged.comp:14-18 + the epilogue tail BEFORE writing:
//   per group g: A[r][k] = Araw[oa + g*sa + r*lda + k] (lda==0 -> K)
//                B[k][j] = Braw[ob + g*sb + k*ldb + j] (ldb==0 -> N; transposed bit 0
//                  in EVERY captured call, so B is (K,N) row-major -- matches f16v1 pack_b)
//                C[r][j] = Cout[oc + g*sc + r*ldc + j] (ldc==0 -> N)
//   out = publish(epi, acc) -> sycl::half iff 0x1000 else f32 (epi = bt>>8 & 0xF; captured bt
//         in {4352=epi1+narrow, 4608=epi2+narrow, 0=f32}). No scales, no residual (the
//         plain xmx_rec_gemm passes skip=cosine=-1).
// The f16v1 tile (section 81/81.5) computes acc = A@B in f32; M is padded to 16 (the
// tile side) and padded rows are never published. Host-gather per group (the section-73
// stride lesson: copy the WIDE buffers back device->host once, then plain host slicing).
int xmx_rec_gemm(int a, int b, int c, unsigned M, unsigned N, unsigned K,
                 unsigned batch, unsigned sa, unsigned sb, unsigned sc, unsigned bt,
                 unsigned lda, unsigned ldb, unsigned ldc,
                 unsigned oa, unsigned ob, unsigned oc) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !N || !K || (N % 16u) || (K % 16u))
        FAILMSG("gemm f16 needs N%%16==0, K%%16==0 (our tile)");
    const bool transposed = (bt & 1u) != 0u;   // scores leg: B stored (N,K), ldb->K
    if (bt & 0x800000u) FAILMSG("pooled window residual belongs to the window_block family");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end()) FAILMSG("bad gemm operand");
    const sycl::half* Araw = (const sycl::half*)ia->second.p;
    const sycl::half* Braw = (const sycl::half*)ib->second.p;
    void* Cout = ic->second.p;
    const unsigned epi = (bt >> 8) & 0xFu;
    const bool narrow = (bt & 0x1000u) != 0u;
    // 0x10000 = the compact head store (xmxres.gemm compact_output, xmxres.py:1791-1800):
    // store only the first four of sixteen columns. The shipping guard (libxmx.c:2287-2291)
    // pins it to N=16, ldc=4, plain FP32, no epilogue -- same guard here, then the publish
    // loop skips columns 4..15 (the scatter is exactly the compact head's four).
    const bool compact = (bt & 0x10000u) != 0u;
    if (compact && (N != 16u || ldc != 4u || epi || narrow))
        FAILMSG("compact head requires N=16, ldc=4 and plain FP32 output (libxmx.c:2290)");
    const unsigned lda_e = lda ? lda : K, ldb_e = ldb ? ldb : (transposed ? K : N), ldc_e = ldc ? ldc : N;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    g_cmd_names.push_back(__func__);
        flop_note("f16_gemm",M,N,K,batch?batch:1);
    g_cmds.push_back([=]() {
        const size_t nb = (batch ? batch : 1u);
        // R8a shape-merge (section 92): batch is the grid's z dimension in ONE dispatch
        // (the shipped engine: vkCmdDispatch(..., batch); gl_WorkGroupID.z). The old
        // recorder's host loop turned one big op into `batch` small under-filled gemms.
        // pack-A once (all groups), pack-B once (whole weight, cached), gemm_b once,
        // publish once. Bounds identical to the gate's aw_b/bw_b (section-73 lesson).
        sycl::half* dAp = (sycl::half*)pool_get(nb * (size_t)Mp * K * 2);
        float* dC = (float*)pool_get(nb * (size_t)Mp * N * 4);
        packdev::gather_pack_a16_b(*GQ, Araw, dAp, (int)M, Mp, (int)K, (int)lda_e, sa, oa, (int)nb);
        WKey wk{ b, (int)N, (int)K, (int)(nb * 2 + (transposed ? 1 : 0)) };
        auto wc = g_wcache.find(wk);
        sycl::half* dBp;
        if (wc != g_wcache.end()) {
            dBp = (sycl::half*)wc->second;
        } else {
            dBp = (sycl::half*)sycl::malloc_device(nb * (size_t)K * N * 2, *GQ);
            if (transposed) packdev::gather_pack_b16_t_b(*GQ, Braw, dBp, (int)K, (int)N, (int)ldb_e, sb, ob, (int)nb);
            else            packdev::gather_pack_b16_b(*GQ, Braw, dBp, (int)K, (int)N, (int)ldb_e, sb, ob, (int)nb);
            g_wcache[wk] = dBp;
        }
        f16v1::gemm_b(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K, (int)nb);
        GQ->parallel_for(sycl::range(nb * (size_t)M * N),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            size_t mn = (size_t)M * N;
            unsigned g = (unsigned)(i / mn); size_t rem = i % mn;
            unsigned r = (unsigned)(rem / N), col = (unsigned)(rem % N);
            if (compact && col >= 4u) return;   // the compact head keeps four columns
            float value = qr_publish(epi, dC[g * (size_t)Mp * N + (size_t)r * N + col]);
            size_t out = oc + g * sc + (size_t)r * ldc_e + col;
            if (narrow) ((sycl::half*)Cout)[out] = sycl::half(value);
            else        ((float*)Cout)[out] = value;
        });
        pool_put(dAp); pool_put(dC);   // dBp is cache-owned (the whole batched weight)
    });
    return 0;
}
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
    g_cmd_names.push_back(__func__);
        flop_note("int8",M,N,K,1);
    QuantFused qf; const bool fused = qfuse_take(a, a_scale, M, K, qf);
    sycl::half* a16 = fused ? (sycl::half*)g_bufs[qf.src].p : nullptr;
    g_cmds.push_back([=]() {
        // device pack (section 92 phase-2): the operands stay on device -- the host
        // round-trip (download -> CPU pack -> upload) was the whole 89s/frame, and the
        // gather is bit-exact vs the host pack (PACK_DEVICE gate).
        int8_t* dAp = (int8_t*)pool_get(na);
        if (fused) packdev::pack_a_fused(*GQ, a16, dAp, (float*)as, (int)M, Mp, (int)K);
        else packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)N, (int)K);   // weight: pack once, reuse
        // DERIVED (section 92): pure publish (dequant + qr_publish, no residual fma) and
        // N%64==0 is a hard requirement -- exactly gemm_b_pub's shape (batch=1, dense ldc=N,
        // scale_stride/col_stride 0). Kills the int32 dC scratch + the separate publish pass.
        s8v8::gemm_b_pub(*GQ, dAp, dBp, Cout, as, bs, (int)M, Mp, (int)N, (int)K,
                         1, (size_t)M * N, N, 0u, 0u, narrow, epi);
        pool_put(dAp);   // dBp is cache-owned (cached_pack_b_i8), not pooled
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
    g_cmd_names.push_back(__func__);
        flop_note("batched",M,N,K,batch);
        g_epi["batched"][(flags >> 8) & 0xFu]++;
        if (getenv("NR_SHAPE_DUMP")) { char eb[128]; snprintf(eb,sizeof eb,"batched M=%u N=%u K=%u b=%u epi%u",M,N,K,batch,(flags>>8)&0xFu); g_shapes["epishape"][eb]++; }
    // v9b fires? decide at RECORD time so the slot index is exact (the closure below is
    // the cmd at index g_cmds.size(); the adjacent quant back-fills this slot).
    // section 100 FIX: the DEFAULT WAS true -- contradicting the section-99 verdict
    // written right below ("v9b DEFAULT OFF after the same-heat A/B: the wide-N merge
    // is CORRECT but SLOWER than v8's batched gemm_b_pub"). The same-heat A/B re-run
    // today: v9b-ON 240.2-243.2 vs v9b-OFF 225.0-227.5 = EVERY PAIR by ~16ms. The
    // 40 frame calls (32640x128x64b2 x16 + 8160x128x128b4 x24) run 0.53-0.80ms in
    // v9b vs 0.11-0.21 through v8 gemm_b_pub_slm -- and the v9b default was MASKING
    // C2 (those calls never reached pub_slm). NR_V9B=1 re-enables the witness.
    static bool v9bon_r = getenv("NR_V9B") ? atoi(getenv("NR_V9B")) != 0 : false;
    const unsigned ldc_r = ldc ? ldc : N;
    static int v9b_rec_calls = 0;
    const bool v9b_first_r = getenv("NR_V9B_FIRST") != nullptr;
    static int v9b_max = getenv("NR_V9B_MAX") ? atoi(getenv("NR_V9B_MAX")) : 1000000;
    const bool v9b_will = v9bon_r && (v9b_rec_calls < v9b_max) &&
        sa == 0u && N == 128u && ldc_r == N * batch &&
        (ldc_r == 256u || ldc_r == 512u) &&
        (((flags >> 8) & 0xFu) == 3u) && ((flags & 0x1000u) != 0u) && (K % 32u) == 0u;
    size_t v9b_slot = 0;
    if (v9b_will) { ++v9b_rec_calls; v9b_slot = g_cmds.size(); g_pending_fold_slot = v9b_slot; g_fold_slot.resize(v9b_slot + 1); g_fold_slot[v9b_slot].cbuf = c; }
    // P2 batched fusion decision at RECORD time (the take no-ops the quant closure):
    QuantFused qfb;
    const bool fused_b = !v9b_will && qfuse_take_b(a, a_scale, M, K, lda_, sa, scale_stride, g_cmds.size(), qfb);
    sycl::half* a16b = fused_b ? (sycl::half*)g_bufs[qfb.src].p : nullptr;
    g_cmds.push_back([=]() {
        const unsigned lda_e = lda ? lda : K, ldb_e = ldb ? ldb : K;
        // R8a shape-merge (section 92): ONE dispatch per stage for the whole op -- the
        // batch is the grid's z dimension, exactly how the shipped engine does it
        // (libxmx.c:2334 vkCmdDispatch(..., batch); gemm_staged.comp:115 gl_WorkGroupID.z).
        // The old recorder translated the plan's batch PARAMETER into a HOST loop of
        // `batch` small gemm dispatches (M=640 batch=8 = 8x160-thread launches, 4% fill)
        // -- that was my defect, not the design's. Now: gather+pack A for all groups in
        // one kernel, pack B (weight, cached whole) in one kernel, gemm_b/gemm32_b in ONE
        // launch, publish in one launch. Bounds identical to the gate's aw_b/bw_b.
        int8_t* dAp = (int8_t*)pool_get((size_t)batch * Mp * K);
        if (fused_b) packdev::pack_a_fused_b(*GQ, a16b, dAp, (float*)ias->second.p, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch);
        else packdev::gather_pack_a_b(*GQ, Araw, dAp, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch);
        // the whole batched B is one weight: pack once (all groups), cache, reuse.
        WKey wk{ b, (int)N, (int)K, (int)batch };
        auto wc = g_wcache.find(wk);
        int8_t* dBp;
        if (wc != g_wcache.end()) {
            dBp = (int8_t*)wc->second;
        } else {
            dBp = (int8_t*)sycl::malloc_device((size_t)batch * N * K, *GQ);
            packdev::gather_pack_b_b(*GQ, Braw, dBp, (int)N, (int)K, (int)ldb_e, sb, (int)batch);
            g_wcache[wk] = dBp;
        }
        // DERIVED + CORRECTED (section 92): gemm_b_pub replaces BOTH the gemm AND the
        // publish kernel. bench_batched at the real shape: gemm_b_pub 0.568ms vs split
        // (gemm_b 0.198 + publish 1.485 = 1.683ms) = 3x FASTER. BUT gate_esimd (epi2/3) is
        // NOT bit-exact: the compiler contracts `ac*-0.0559 + 0.447` into an FMA, skipping
        // the product's intermediate rounding that qr_gate_activation's fmul_rn forces.
        // (normalize_esimd was safe only because its h[i]*h[i] is exact in f32.) The gate
        // missed this because its epi3 cases use N=32 (split path). So fuse ONLY epi 0/1/4
        // (e4m3/half, no mul-add chain -> no contraction risk); epi 2/3 keep split.
        // v9 fused-quant producer (section 99): N==128 (BN=128 wide producer, senior v2
        // geometry) + epi 1/3 (e4m3 / gate+e4m3 -- the two the frame's N=128 rows use) +
        // narrow output: the GEMM writes int8 + new_scale DIRECTLY, and the following
        // xmx_rec_quant over this buffer becomes a no-op (g_fused_quant). bench_v9 gate =
        // BIT-EXACT vs the split chain (gemm_b_pub + quantize_row) on all five frame-real
        // N=128 shapes, both epi. Strides verified against the plan call:
        //   A row stride lda, group stride sa (bytes); C8 row stride ldc_, group stride
        //   sc*2 (the half buffer's byte stride -> int8 element stride); as row-stride
        //   scale_stride, ns written to the SAME scale buffer with the SAME stride;
        //   bs col-stride N (sb!=0) or 0.
        // BLOCKED by plan structure (section 99 finding): every frame N=128 batched call
        // is multi-group INTERLEAVED (sc=128 < ldc=256) and its quant row-max SPANS BOTH
        // groups' 256 columns (verified from the plan call: quant [1274,1272,1273,32640,256]
        // reads c as flat 32640x256 = 2 groups interleaved). A per-workgroup fused
        // requantize cannot see the other group's columns -> the fold is invalid for these
        // shapes. gate P1-broadcast-2blocks went RED exactly this way. The v9 kernel +
        // bench_v9 BIT-EXACT gate stay as the building block for single-group N=128 shapes.
        if (false && N == 128u && (K % 32u) == 0u && (epi == 1u || epi == 3u) && narrow) {
            int8_t* dAp9 = (int8_t*)pool_get((size_t)batch * Mp * K);
            s8v9::pack_a9(*GQ, Araw, dAp9, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch);
            WKey wk9{ b, (int)N, (int)K, 1000 + (int)batch };   // v9 layout (row-major B), distinct key
            auto wc9 = g_wcache.find(wk9);
            int8_t* dBp9;
            if (wc9 != g_wcache.end()) dBp9 = (int8_t*)wc9->second;
            else {
                dBp9 = (int8_t*)sycl::malloc_device((size_t)batch * K * N, *GQ);
                s8v9::pack_b9(*GQ, Braw, dBp9, (int)K, (int)N, (int)ldb_e, sb, (int)batch);
                g_wcache[wk9] = dBp9;
            }
            s8v9::gemm_b_rq(*GQ, dAp9, dBp9, (int8_t*)Cout, (float*)as,
                            as, bs, (int)M, Mp, (int)N, (int)K, (int)batch,
                            sc, ldc_, scale_stride, (sb != 0u) ? N : 0u, epi);
            pool_put(dAp9);
            g_fused_quant[c] = a_scale;
            return;
        }
        // SECTION 99 v9b: the sa=0 batched->quant fold (40 pairs). sa=0 => every group
        // shares the SAME A rows => the batched op is ONE wide GEMM with BN=ldc=N*batch
        // (the b transposed weight blocks concatenated, bs concatenated float[ldc] =
        // col_stride N exactly). ldc=N*batch => the quant row spans all groups
        // CONTIGUOUSLY (c layout r*ldc+n) => one workgroup owns the whole row => the
        // requantize folds and the following xmx_rec_quant becomes a device memcpy.
        // Opt-in NR_V9B=1. SHELVED (section 99): end-to-end 0% after three fix rounds
        // (w-index, fold-removal, scalar-pub bisect); the win measured only ~6ms
        // (251 vs 257) -- cost/benefit says stop here, the bug hunt does not pay for
        // 6ms. Kernel + packs stay in-tree as a starting point if wide-N ever matters.
        // v9b DEFAULT OFF after the same-heat A/B (section 99): the wide-N merge is
        // CORRECT (end-to-end 100% with and without FOLD) but SLOWER than v8's
        // batched gemm_b_pub (275-278 vs 271-272). Why: v9b runs BM=32/NT=32 =
        // 16 accs/thread (P1's ">8 accs" penalty zone); v8 runs BM=128/NT=64 =
        // 8 accs/thread. The width-sweep's wide-N win needs the WIDE BM too, which
        // BM=32 cannot give inside 64KB SLM at ldc=512. NR_V9B=1 = opt-in witness.
        static int v9b_calls = 0;
        const bool v9b_first_only = getenv("NR_V9B_FIRST") != nullptr;
        if (v9bon_r && (!v9b_first_only || v9b_calls == 0) &&
            sa == 0u && N == 128u && ldc_ == (unsigned)(N * batch) &&
            (ldc_ == 256u || ldc_ == 512u) &&   // ONLY the instantiated BN widths:
            // the trace caught M=2040 b=8 ldc=1024 sneaking past the old guard and
            // running the BN=512 template = half-row writes = frame 0%. BN=1024 would
            // need 2x(32x1024)=64KB B alone > the 64KB SLM cap -- out of scope.
            epi == 3u && narrow && (K % 32u) == 0u) {   // int8 batched B is ALWAYS (N x K) transposed
            int Mp32 = (int)(((M + 31u) / 32u) * 32u);
            int8_t* dAp9b = (int8_t*)pool_get((size_t)Mp32 * K);
            s8v9b::pack_a9b(*GQ, Araw, dAp9b, (int)M, Mp32, (int)K, (int)lda_e);
            WKey wk9b{ b, (int)N, (int)K, 2000 + (int)batch };   // concatenated (K x ldc) layout
            auto wc9b = g_wcache.find(wk9b);
            int8_t* dBp9b;
            if (wc9b != g_wcache.end()) dBp9b = (int8_t*)wc9b->second;
            else {
                dBp9b = (int8_t*)sycl::malloc_device((size_t)K * ldc_, *GQ);
                s8v9b::pack_b9b(*GQ, Braw, dBp9b, (int)K, (int)N, (int)ldc_, (int)ldb_e, sb, (int)batch);
                g_wcache[wk9b] = dBp9b;
            }
            float* ns9b = (float*)ias->second.p;   // a_scale (scale_stride=0: shared)
            if (getenv("NR_PACK_DUMP")) { static bool pdone=false; if(!pdone){pdone=true;
                std::vector<int8_t> h9(2048), h8(2048);
                GQ->memcpy(h9.data(), dAp9b, 2048).wait();
                GQ->memcpy(h8.data(), dAp, 2048).wait();
                int d9=0,d8=0; for(int i=0;i<2048;++i) if(h9[i]!=h8[i]){d9++; if(d9<4)printf("[A9b] i=%d 9b=%d v8=%d\n",i,(int)h9[i],(int)h8[i]);}
                printf("[A9b] first-2KB diff=%d (Mp32=%d Mp=%d K=%d)\n",d9,Mp32,Mp,K);
                GQ->memcpy(h9.data(), dBp9b, 2048).wait();
                GQ->memcpy(h8.data(), dBp, 2048).wait();
                int e9=0; for(int i=0;i<2048;++i) if(h9[i]!=h8[i]){e9++; if(e9<4)printf("[B9b] i=%d 9b=%d v8=%d\n",i,(int)h9[i],(int)h8[i]);}
                printf("[B9b] first-2KB diff=%d\n",e9); } }
            ++v9b_calls;
            if (getenv("NR_V9B_TRACE")) printf("[v9b call %d] M=%u N=%u K=%u b=%u sa=%u sb=%u lda=%u ldb=%u ldc=%u a_scale=%d b_scale=%d a=%d b=%d c=%d\n",
                v9b_calls,M,N,K,batch,sa,sb,lda_,ldb_,ldc_,a_scale,b_scale,a,b,c);
            FoldBind fb = g_fold_slot[v9b_slot];
            if (getenv("NR_V9B_TRACE")) { static int tc9=0; ++tc9; if(tc9>=15&&tc9<=25){
                printf("[v9b pair %d] M=%u K=%u b=%u ldc=%u c=%d a=%d a_scale=%d b_scale=%d -> pk=%p sc=%p (sc==as? %d, a==pk? %d)\n",
                    tc9,M,K,batch,ldc_,c,a,a_scale,b_scale,fb.packed,fb.scale,
                    (void*)fb.scale==(void*)ias->second.p, (size_t)fb.packed==(size_t)ia->second.p); } }
            if (getenv("NR_V9B_TRACE_OLD")) { static int tc9o=0; if(tc9o<3){tc9o++;
                printf("[v9b exec] slot=%u bound=%d packed=%p scale=%p ldc=%u M=%u\n",
                    (unsigned)v9b_slot, fb.packed!=nullptr, fb.packed, fb.scale, ldc_, M); } }
            if (getenv("NR_PK_DUMP") && fb.packed) { static int pd9=0; if(pd9<1){pd9++;
                GQ->wait();
                std::vector<int8_t> hp(512); GQ->memcpy(hp.data(), fb.packed, 512).wait();
                std::vector<float> hsc(8); GQ->memcpy(hsc.data(), fb.scale, 32).wait();
                printf("[pk9b] r0c0-15:"); for(int i=0;i<16;++i) printf(" %d",(int)hp[i]);
                printf("  r1c0-7:"); for(int i=256;i<264;++i) printf(" %d",(int)hp[i]);
                printf("  sc0-7:"); for(int i=0;i<8;++i) printf(" %.6g",hsc[i]); printf("\n"); } }
            if (fb.packed) {   // FOLD: int8+scale straight into the quant's buffers
                if (ldc_ == 256u)
                    s8v9b::gemm_b_rq9b<256,true>(*GQ, dAp9b, dBp9b, (sycl::half*)fb.packed, (float*)fb.scale, as, bs, (int)M, Mp32, (int)K, epi);
                else
                    s8v9b::gemm_b_rq9b<512,true>(*GQ, dAp9b, dBp9b, (sycl::half*)fb.packed, (float*)fb.scale, as, bs, (int)M, Mp32, (int)K, epi);
            } else if (ldc_ == 256u)
                s8v9b::gemm_b_rq9b<256,false>(*GQ, dAp9b, dBp9b, (sycl::half*)Cout, ns9b, as, bs, (int)M, Mp32, (int)K, epi);
            else
                s8v9b::gemm_b_rq9b<512,false>(*GQ, dAp9b, dBp9b, (sycl::half*)Cout, ns9b, as, bs, (int)M, Mp32, (int)K, epi);
            pool_put(dAp9b);
            return;
        }
        if ((N % 64u) == 0u && (epi == 0u || epi == 1u || epi == 3u || epi == 4u)) {
            // section 100 C2: the N=128 batched family rides the senior's acc-via-SLM
            // tail (bench_batched: BIT-EXACT diff 0, 0.148->0.112 / 0.227->0.210 /
            // 0.196->0.150 at the frame's three N=128 shapes). N=64 keeps the register
            // tail -- the 32KB stage costs occupancy there (0.033->0.074, the v9c
            // lesson). NR_PUB_SLM=0 reverts the whole family to gemm_b_pub.
            static bool pubslm = getenv("NR_PUB_SLM") ? atoi(getenv("NR_PUB_SLM")) != 0 : true;
            if (pubslm && N == 128u)
                s8v8::gemm_b_pub_slm<false>(*GQ, dAp, dBp, Cout, as, bs, (int)M, Mp, (int)N, (int)K,
                                 (int)batch, sc, ldc_, scale_stride, (sb != 0u) ? N : 0u, narrow, epi);
            else
                s8v8::gemm_b_pub(*GQ, dAp, dBp, Cout, as, bs, (int)M, Mp, (int)N, (int)K,
                             (int)batch, sc, ldc_, scale_stride, (sb != 0u) ? N : 0u, narrow, epi);
            pool_put(dAp);   // dBp is cache-owned (the whole batched weight)
            return;
        }
        int32_t* dC = (int32_t*)pool_get((size_t)batch * Mp * N * 4);
        if ((N % 64u) == 0u) s8v8::gemm_b(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K, (int)batch);
        else                 s8v8::gemm32_b(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K, (int)batch);
        // publish: one launch over all groups (dequant scales indexed per group).
        GQ->parallel_for(sycl::range((size_t)batch * M * N), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned mn = M * N;
            unsigned g = (unsigned)(i / mn); size_t rem = i % mn;
            unsigned r = (unsigned)(rem / N), col = (unsigned)(rem % N);
            float* gas = (float*)as + (size_t)g * scale_stride;                       // roff (.comp:143)
            float* gbs = (sb != 0u) ? ((float*)bs + (size_t)g * N) : (float*)bs;      // soff (.comp:147)
            float v = cr_mul(cr_mul((float)dC[(size_t)g * Mp * N + (size_t)r * N + col], gas[r]), gbs[col]);
            size_t out = (size_t)g * sc + (size_t)r * ldc_ + col;
            if (narrow) ((sycl::half*)Cout)[out] = sycl::half(qr_publish(epi, v));
            else        ((float*)Cout)[out] = qr_publish(epi, v);
        });
        pool_put(dAp); pool_put(dC);   // dBp is cache-owned (the whole batched weight)
    });
    return 0;
}
// int xmx_rec_gemm_int8_qkv(int a, int b, int q, int k, int v, int a_scale, int b_scale,
//                           int qkv_scale, unsigned M, unsigned channels, unsigned heads,
//                           unsigned tokens, unsigned flags)
// swap-in #4 (section 75). The .comp+qkv_epilogue.glsl math pinned BEFORE writing either
// side (sections 73/74 lessons):
//   N = 3*channels; weight B = int8 (3*channels x channels) TRANSPOSED, same family as
//   plain gemm_int8 (xmxres.py:1350: b 3*channels*channels bytes); K dim = channels.
//   col -> part = col/channels (0 Q, 1 K, 2 V), head = (col%channels)/32 (epilogue:39).
//   Q/K: h[i]=half_round(deq)  -> reciprocal (cosine_tree; 0x2000 = the vit tree) ->
//        value=hmul(h,recip), Q additionally hmul(vit?VIT_ROOT:1?) then hmul(scale[head])
//        (epilogue:52-54; VIT_ROOT between norm and learned scale, exactly as
//        cosine_norm_kernel already does it -- reused VERBATIM math) -> written back over
//        the stage as half-valued floats ("exact in either type", epilogue:60).
//   publish: out = half(e4m3(QKV_READ)) for ALL of Q,K,V; scatter
//        at = ((window*heads + head)*tokens + token)*32 + c   (window=r/tokens).
//   V: no normalisation at all (epilogue:50 part>=2 skips the loop).
// This recorder COMPOSES the already-green pieces (the epilogue header: "bit-identical
// to the three passes BY CONSTRUCTION", and test_gemm_qkv.py is the shipping witness):
// v8 GEMM (transposed pack_b, padded M) -> dC int32; one inline kernel does deq + the
// in-place Q/K head-normalisation exactly in the epilogue's order; a second inline
// kernel publishes (qr_e4m3) and scatters to the three half targets. Three device
// launches inside ONE g_cmds push (passes stays +1 per plan call).
int xmx_rec_gemm_int8_qkv(int a, int b, int q, int k, int v, int a_scale, int b_scale,
                          int qkv_scale, unsigned M, unsigned channels, unsigned heads,
                          unsigned tokens, unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !channels || (channels % 64u) || !heads || !tokens ||
        channels != heads * 32u || (M % tokens) || (flags & ~0x2000u))
        FAILMSG("integer QKV needs channels%%64==0, channels==heads*32, tokens|M, "
                "flags only 0x2000 (vit) -- shipped guard libxmx.c int8_qkv");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b);
    auto iq = g_bufs.find(q), ik = g_bufs.find(k), iv = g_bufs.find(v);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale), iqs = g_bufs.find(qkv_scale);
    if (ia == g_bufs.end() || ib == g_bufs.end() || iq == g_bufs.end() || ik == g_bufs.end() ||
        iv == g_bufs.end() || ias == g_bufs.end() || ibs == g_bufs.end() || iqs == g_bufs.end())
        FAILMSG("bad gemm_int8_qkv operand");
    if (iq == ik || ik == iv || iq == iv) FAILMSG("QKV targets must be distinct");
    const int8_t* Araw = (const int8_t*)ia->second.p;
    const int8_t* Braw = (const int8_t*)ib->second.p;          // TRANSPOSED (3C x C)
    sycl::half *Q = (sycl::half*)iq->second.p, *Kk = (sycl::half*)ik->second.p,
               *V = (sycl::half*)iv->second.p;
    const float* as = (const float*)ias->second.p;
    const float* bs = (const float*)ibs->second.p;             // 3*channels entries
    const float* qs = (const float*)iqs->second.p;             // heads entries
    const bool vit = (flags & 0x2000u) != 0u;
    const unsigned C = channels, NH = 3u * channels;
    const int Mp = l0_ceil_bm(M);
    // P4b (section 100): a REGISTERED GATHER quant_window feeding this QKV (the
    // census: all 104 quant_window pks are single-read by exactly the next QKV,
    // M==qM, C==qK, a_scale==q_scale) -> dissolve its launch; THIS pack reads the
    // image f16 directly (pack_a_fused_gather: the shipped map + qr arithmetic
    // VERBATIM, outside rows zero/scale 1.0). Probe gate NR_QW_FUSE (default ON
    // once the three gates pass).
    static bool qwf = getenv("NR_QW_FUSE") ? atoi(getenv("NR_QW_FUSE")) != 0 : true;
    QuantFused qfq;
    const bool fused_q = qwf && qfuse_take_gather(a, a_scale, M, C, g_cmds.size(), qfq);
    const size_t na = (size_t)Mp * C, nb = (size_t)NH * C;
    g_cmd_names.push_back(__func__);
        flop_note("int8_qkv",M,3u*channels,channels,1);
        if (getenv("NR_SHAPE_DUMP")) { static long qv=0,qnv=0; if(flags&0x2000u) qv++; else qnv++;
            std::printf("[qkv-vit] vit=%ld nonvit=%ld (running)\n", qv, qnv); }
    g_cmds.push_back([=]() {
        // device pack (section 92): Araw/Braw already on device -- pack in place.
        int8_t* dAp = (int8_t*)pool_get(na);
        int32_t* dC = (int32_t*)pool_get((size_t)Mp * NH * 4);
        // section 100 QKV-internal ledger (NR_QKV_STOP=N, launch-guard form, time
        // ledger only -- the frame is garbage here by design): 1 = skip norm_scatter
        // (pack+gemm only), 2 = skip gemm too (pack only), 3 = skip pack too (floor).
        // qkv family = 32.5ms/30 calls; this splits pack vs gemm vs the dC-reading
        // epilogue pass so the fold (senior's 0x100000 qkv_epilogue IN the gemm
        // store) targets the right segment.
        static int qkvstop = getenv("NR_QKV_STOP") ? atoi(getenv("NR_QKV_STOP")) : 0;
        if (qkvstop < 3) {
            if (fused_q) {
                auto itsrc = g_bufs.find(qfq.src);
                if (itsrc == g_bufs.end()) throw std::runtime_error("qkv fused-gather: image src not live");
                packdev::pack_a_fused_gather(*GQ, (const sycl::half*)itsrc->second.p, dAp,
                    (float*)as, (int)M, Mp, (int)C, qfq.image_h, qfq.image_w, qfq.across, qfq.pad);
            } else
                packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)C);
        }
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)NH, (int)C);   // weight: pack once
        // P5 (section 100): the resident QKV epilogue -- deq+butterfly+e4m3+scatter
        // ON the gemm's SLM-staged accumulator tile; dC (int32 Mp x 3C) AND the
        // 21ms norm_scatter tail both vanish. NON-VIT + C%64==0 only (the frame:
        // C=64/128); vit's 16 calls keep the scalar split (different tree).
        static bool qres_on = getenv("NR_QKV_RES") && atoi(getenv("NR_QKV_RES")) != 0;   // P5 FALSIFIED (11:3x): correct (100%% x2, p5a/p5b) but 1-3ms SLOWER than split (182-185 vs 180-182): the tail is 14ms of BUTTERFLY COMPUTE, not the dC round-trip (0.06ms) -- folding into the gemm moves the cost and serializes it with the dpas loop. Kernel stays in-tree as witness.
        const bool qres_ok = qres_on && !vit && (C % 64u) == 0u && NH == 3u * C && heads == C / 32u && tokens > 0u;
        if (qkvstop < 2) {
            if (qres_ok)
                qres::gemm_qkv_res(*GQ, dAp, dBp, Q, Kk, V, as, bs, qs, (int)M, Mp, (int)C, (int)NH, (int)heads, (int)tokens);
            else {
                s8v8::gemm(*GQ, dAp, dBp, dC, Mp, (int)NH, (int)C);
            }
        }
        if (qres_ok) goto qkv_done;
        // stage 2: deq + in-place Q/K head norm (the epilogue's order; V deqt only).
        // DERIVED (section 92): the non-vit normalize is the same scalar cosine chain that
        // the 4-lane ESIMD butterfly just made 4.3x faster in window_block; qkv_norm_esimd
        // applies it here (deq + Q/K norm, V deq-only) for the 104/120 non-vit calls; the
        // 16 vit calls keep the scalar path (vit_reciprocal has a different reduce tree).
        if (!vit) {
            // DERIVED (section 92): merge stage-2 normalise + stage-3 e4m3/scatter into ONE
            // kernel -- no dC float-bits round-trip, one fewer launch. Non-vit only.
            if (qkvstop < 1) {
                static int qres_v2 = getenv("NR_QKV_RESV2") ? atoi(getenv("NR_QKV_RESV2")) : 0;   // P6 v2 FALSIFIED (ESIMD arrays spill: 186-187 vs 178-180); 3 = v3 scalar-contiguous probe
                if (qres_v2 == 3)
                    GQ->parallel_for(sycl::range((size_t)M * heads), [=](sycl::item<1> it) {
                        unsigned rh = (unsigned)it.get_id(0);
                        unsigned r = rh / heads, head = rh % heads;
                        const float rs = as[r];
                        unsigned col0 = head * 32u;
                        float hq[32], hk[32], hv[32];
                        for (int i = 0; i < 32; ++i) {
                            unsigned n = col0 + (unsigned)i;
                            hq[i] = wbmega::eh_round((float)((dC[(size_t)r * NH + n] * rs) * bs[n]));
                            unsigned nk = C + n, nv = 2u * C + n;
                            hk[i] = wbmega::eh_round((float)((dC[(size_t)r * NH + nk] * rs) * bs[nk]));
                            hv[i] = (float)((dC[(size_t)r * NH + nv] * rs) * bs[nv]);
                        }
                        float rq = ctree::cosine_reciprocal(hq);
                        float rk = ctree::cosine_reciprocal(hk);
                        float sc = wbmega::eh_round(qs[head]);
                        unsigned w = r / tokens, t = r % tokens;
                        size_t at = (((size_t)w * heads + head) * tokens + t) * 32u;
                        for (int i = 0; i < 32; ++i) {
                            Q[at + i] = sycl::half(qr_e4m3_scalar(wbmega::eh_mul(wbmega::eh_mul(hq[i], rq), sc)));
                            Kk[at + i] = sycl::half(qr_e4m3_scalar(wbmega::eh_mul(hk[i], rk)));
                            V[at + i] = sycl::half(qr_e4m3_scalar(hv[i]));
                        }
                    });
                else if (qres_v2 == 2)
                    wbmega::qkv_norm_scatter_v2(*GQ, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens);
                else
                    wbmega::qkv_norm_scatter_esimd(*GQ, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens);
            }
        } else if (getenv("NR_QKV_VIT1") && atoi(getenv("NR_QKV_VIT1")) != 0) {
        // P7 probe: the VIT path merged to ONE pass (the non-vit merge was the
        // section-92 win; vit kept two passes + dC float-bits write-back). This
        // form: one item per (row,head): Q/K/V deq + vit_reciprocal tree +
        // VIT_ROOT/scale + e4m3 + scatter, all in registers -- dC write-back
        // AND the stage-3 pass vanish. Arithmetic VERBATIM from the two passes
        // below (qr_half_round/cr_mul/ctree::vit_reciprocal/VIT_ROOT order kept).
        GQ->parallel_for(sycl::range((size_t)M * heads),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / heads), head = (unsigned)(i % heads);
            float row32[32];
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = head * 32u + (unsigned)c2;
                row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
            }
            float recip = ctree::vit_reciprocal(row32);
            float sc = qr_half_round(qs[head]);
            unsigned w = r / tokens, t = r % tokens;
            size_t at = (((size_t)w * heads + head) * tokens + t) * 32u;
            for (int c2 = 0; c2 < 32; ++c2) {
                float val = qr_half_round(cr_mul(row32[c2], recip));
                val = qr_half_round(cr_mul(val, ctree::VIT_ROOT));
                val = qr_half_round(cr_mul(val, sc));
                Q[at + c2] = sycl::half(qr_e4m3(val));
            }
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = C + head * 32u + (unsigned)c2;
                row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
            }
            float krec = ctree::vit_reciprocal(row32);
            for (int c2 = 0; c2 < 32; ++c2) {
                float val = qr_half_round(cr_mul(row32[c2], krec));
                Kk[at + c2] = sycl::half(qr_e4m3(val));
            }
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = 2u * C + head * 32u + (unsigned)c2;
                float val = cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]);
                V[at + c2] = sycl::half(qr_e4m3(val));
            }
        });
        } else {
        GQ->parallel_for(sycl::range((size_t)M * heads),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / heads), head = (unsigned)(i % heads);
            float row32[32];
            // Q segment
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = head * 32u + (unsigned)c2;
                row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
                dC[(size_t)r * NH + n] = (int32_t)0; // marker unused; value goes back below
            }
            float recip = vit ? ctree::vit_reciprocal(row32) : ctree::cosine_reciprocal(row32);
            float sc = qr_half_round(qs[head]);
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = head * 32u + (unsigned)c2;
                float h = row32[c2];
                float val = qr_half_round(cr_mul(h, recip));
                if (vit) val = qr_half_round(cr_mul(val, ctree::VIT_ROOT));
                val = qr_half_round(cr_mul(val, sc));
                dC[(size_t)r * NH + n] = sycl::bit_cast<int32_t>(val);
            }
            // K segment (same tree, scale = 1.0 -> the GLSL's part==1 scale path: no mult)
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = C + head * 32u + (unsigned)c2;
                row32[c2] = qr_half_round(cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]));
            }
            float krec = vit ? ctree::vit_reciprocal(row32) : ctree::cosine_reciprocal(row32);
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = C + head * 32u + (unsigned)c2;
                float val = qr_half_round(cr_mul(row32[c2], krec));
                dC[(size_t)r * NH + n] = sycl::bit_cast<int32_t>(val);
            }
            // V segment: deq only, store float bits back (QKV_STAGE semantics)
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = 2u * C + head * 32u + (unsigned)c2;
                float val = cr_mul(cr_mul((float)dC[(size_t)r * NH + n], as[r]), bs[n]);
                dC[(size_t)r * NH + n] = sycl::bit_cast<int32_t>(val);
            }
        });
        // stage 3 (vit path only): publish e4m3 -> half, scatter (w,h,t,32).
        GQ->parallel_for(sycl::range((size_t)M * NH),
                         [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / NH), n = (unsigned)(i % NH);
            unsigned part = n / C, col = n % C, head = col / 32u;
            float val = sycl::bit_cast<float>(dC[i]);
            sycl::half out = sycl::half(qr_e4m3(val));          // epilogue publish = e4m3 only
            unsigned w = r / tokens, t = r % tokens;
            size_t at = (((size_t)w * heads + head) * tokens + t) * 32u + (col % 32u);
            if (part == 0u) Q[at] = out; else if (part == 1u) Kk[at] = out; else V[at] = out;
        });
        }   // end else (vit scalar stage2 + stage3)
        qkv_done:;
        pool_put(dAp); pool_put(dBp); pool_put(dC);
    });
    return 0;
}
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
    g_cmd_names.push_back(__func__);
        flop_note("int8_residual",M,N,K,1);
    QuantFused qfr; const bool fused_r = qfuse_take(a, a_scale, M, K, qfr);
    sycl::half* a16r = fused_r ? (sycl::half*)g_bufs[qfr.src].p : nullptr;
    g_cmds.push_back([=]() {
        // device pack (section 92): Araw/Braw are already on device -- pack in place,
        // no download/upload round-trip (same conversion as gemm_int8, packdev gate).
        int8_t* dAp = (int8_t*)pool_get(na);
        if (fused_r) packdev::pack_a_fused(*GQ, a16r, dAp, (float*)as, (int)M, Mp, (int)K);
        else packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)N, (int)K);   // weight: pack once
        // DERIVED (section 92): same lever as batched -- fuse the publish into the gemm
        // store, killing the int32 dC scratch + the separate publish pass. The residual
        // epilogue's sycl::fma(skip,cos,stage) maps to ESIMD's auto-contracted sk*cp+stage
        // (one fused rounding, the gate_esimd lesson used correctly). N%64==0 is already a
        // hard requirement of this op, so every call qualifies. GEMM_INT8_RESIDUAL judges.
        s8v8::gemm_b_res(*GQ, dAp, dBp, Cout, as, bs, skp, cp, (int)M, Mp, (int)N, (int)K,
                         narrow, half_skip, epi);
        pool_put(dAp);   // dBp is cache-owned (the weight)
    });
    return 0;
}
// int xmx_rec_gemm_window_int8_residual(a,b,c,a_scale,b_scale,skip,cosine,
//        M,N,K,flags, height,width,across,pad)
// swap-in #5 (section 76). = the plain int8 residual's math PLUS the unpadded-image
// index map of residual_epilogue.glsl:4-15, read through .comp:257-261 CAREFULLY:
//   block position: r = window*64 + token (window-major over the 8x8 token grid),
//     stage uses dC[r*N+c], a_scale[r], b_scale[c];
//   map: y = (window/across)*8 + token/8, x = (window%across)*8 + token%8,
//     top = pad>>16, left = pad & 0xffff; OUT OF RANGE (cropped padding) -> the element
//     is skipped ENTIRELY (.comp:258 `continue` before any read or write);
//   residual_output_index is `inout`: after the map, at = ((y-top)*width + x-left)*N + c
//     and it is the REMAPPED index that reads the skip buffer (.comp:261-262, so the
//     skip branch lives in IMAGE layout, size height*width*N -- "the skip lives where
//     the answer goes") while cosine is read at at % n = c (the map preserves %n).
// Output C is the image buffer: needs height*width*N elements -- CHECKED against the
// buffer table (fail loud, section 70's face).
// plan-layer flags carry no 0x20000/0x80000 (the wrapper ORs them, libxmx.c:2988 --
// the section 74 guard-layer lesson, applied from the start this time): the plan uses
// 0x41100 (half-out) and 0x40100 (f32-out), both half-skip (0x40000).
int xmx_rec_gemm_window_int8_residual(int a, int b, int c, int a_scale, int b_scale,
                                      int skip, int cosine,
                                      unsigned M, unsigned N, unsigned K, unsigned flags,
                                      unsigned height, unsigned width, unsigned across,
                                      unsigned pad) {
    if (!g_recording) FAILMSG("not recording");
    if (!height || !width || !across) FAILMSG("invalid window residual");
    if (!M || !N || !K || (N % 64u) || (K % 32u) || (M % 64u))
        FAILMSG("window_int8_residual needs N%%64==0,K%%32==0,M%%64==0 (our tile)");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), ic = g_bufs.find(c);
    auto ias = g_bufs.find(a_scale), ibs = g_bufs.find(b_scale);
    auto isk = g_bufs.find(skip), ico = g_bufs.find(cosine);
    if (ia == g_bufs.end() || ib == g_bufs.end() || ic == g_bufs.end() ||
        ias == g_bufs.end() || ibs == g_bufs.end() ||
        isk == g_bufs.end() || ico == g_bufs.end()) FAILMSG("bad window_int8_residual operand");
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const bool half_skip = (flags & 0x40000u) != 0u;
    const size_t wsz = narrow ? 2u : 4u;
    const size_t img_elems = (size_t)height * width * N;
    const size_t blk_elems = (size_t)M * N;
    const size_t c_need = img_elems * wsz, k_need = img_elems * (half_skip ? 2u : 4u);
    const int c_id = c, k_id = skip, co_id = cosine;
    // SIZE validation happens AT RUN TIME, not at capture (the step-2588 lesson, section
    // 76): the plan's FIRST recording (the scratch the dump made, begin@2529..abort@3902)
    // recreates the same plan indices as TINY placeholders -- buf 1267 is 256 B there and
    // 66,846,720 B in the captured recording (step 3916). The shipping guard checks only
    // that the addresses are live (libxmx.c record_gemm_int8_residual: `skip < 0 || cosine
    // < 0`), never the bytes -- capture-then-abort never touches memory, so a size check
    // at capture time is STRICTER than shipping and trips the walk's scratch leg. The
    // scratch commands never run here either (abort clears g_cmds), so the honest place
    // for the image-bounds check is inside the run closure: the captured graph executes it
    // for real, the discarded scratch never does.
    int8_t* Araw = (int8_t*)ia->second.p;      // re-looked at run time (see above)
    int8_t* Braw = (int8_t*)ib->second.p;      // TRANSPOSED (N x K)
    void* Cout = ic->second.p;
    const float* as = (const float*)ias->second.p;
    const float* bs = (const float*)ibs->second.p;
    const void* skp = isk->second.p;
    const float* cp = (const float*)ico->second.p;
    const int Mp = l0_ceil_bm(M);
    const size_t na = (size_t)Mp * K, nb = (size_t)N * K;
    const unsigned top = pad >> 16, left = pad & 0xffffu;
    g_cmd_names.push_back(__func__);
        flop_note("win_int8_res",M,N,K,1);
    QuantFused qfw; const bool fused_w = qfuse_take(a, a_scale, M, K, qfw);
    const int srcid_w = fused_w ? qfw.src : 0;
    g_cmds.push_back([=]() {
        // RUN-TIME fresh lookups shadowing the capture-time pointers (see the lesson
        // above): sizes are checked HERE because the scratch recording's placeholder
        // buffers are destroyed before the captured graph runs. Throwing is loud:
        // xmx_submit/xmx_graph_run catch and fail the whole frame (section 70's face).
        auto sized = [&](int id, size_t bytes, const char* what) -> void* {
            auto it = g_bufs.find(id);
            if (it == g_bufs.end())
                throw std::runtime_error(std::string("window residual: ") + what + " not live at run");
            if (it->second.bytes < bytes)
                throw std::runtime_error(std::string("window residual: ") + what + " smaller than the image at run");
            return it->second.p;
        };
        // A is read for its REAL M*K bytes only -- the padded rows live in our OWN host
        // vector (hApad), never the caller's buffer, so demanding Mp*K here was my bug
        // (W3 M=960 -> Mp=1024: false "A smaller than" at run).
        int8_t*  Araw  = (int8_t*)sized(a,       (size_t)M * K, "A");
        int8_t*  Braw  = (int8_t*)sized(b,       nb,          "B");
        void*    Cout  = sized(c,        c_need,     "C");
        const float* as = (const float*)sized(a_scale, (size_t)M * 4u, "a_scale");
        const float* bs = (const float*)sized(b_scale, (size_t)N * 4u, "b_scale");
        const void*  skp = sized(skip,   k_need,     "skip");
        const float* cp  = (const float*)sized(cosine, (size_t)N * 4u, "cosine");
        // device pack (section 92): Araw/Braw already on device -- pack in place.
        int8_t* dAp = (int8_t*)pool_get(na);
        if (fused_w) {   // P2: the closure captured (fused_w, srcid_w) by value at
            sycl::half* a16w = (sycl::half*)sized(srcid_w, (size_t)M * K * 2u, "A(f16 fused)");
            packdev::pack_a_fused(*GQ, a16w, dAp, (float*)as, (int)M, Mp, (int)K);
        } else
        packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)N, (int)K);   // weight: pack once
        // DERIVED (section 92): same fused-publish lever as int8_residual/batched. The
        // window variant maps the gemm row (window*64+token) to the image slot with the
        // same bounds cull the split pass did, and reads skip at that slot. N%64==0 is a
        // hard requirement of this op. WINDOW_INT8_RESIDUAL gate is the judge.
        s8v8::gemm_b_res_window(*GQ, dAp, dBp, Cout, as, bs, skp, cp, (int)M, Mp, (int)N, (int)K,
                                narrow, half_skip, epi, across, top, left, height, width);
        pool_put(dAp);   // dBp is cache-owned (the weight)
    });
    return 0;
}
// int xmx_rec_global_attention(int q, int k, int v, int merged, unsigned rows,
//                              unsigned tokens, unsigned heads)
// swap-in #10 (section 86): the bottleneck block's attention, COMPOSED from the four
// gated legs -- the shipping global_attention.comp does it in one coopmat kernel, and
// test_global_attention.py:62-68 proves it is bit-identical (up to the GEMMs' own
// rounding) to: gemm(q,k,scores,transpose_b,batch=heads) -> vit_softmax(scores,probs,
// reciprocal,heads*rows,tokens,stride=rows) -> gemm(probs,v,ctx,batch=heads) ->
// merge_heads(ctx,merged,1,rows,heads*32,heads,EPI_E4M3,narrow,scale=reciprocal).
// We reproduce THAT four-pass contract. Q/K/V are (heads,rows,32) half (the QKV
// epilogue's output); merged is (rows, heads*32) half. rows is a multiple of 16 and
// within the tokens' 64-block (the shipped guard); the tile pads rows to 16.
int xmx_rec_global_attention(int q, int k, int v, int merged, unsigned rows,
                             unsigned tokens, unsigned heads) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || (rows % 16u) || !tokens || tokens > rows || !heads ||
        ((rows + 63u) / 64u) != ((tokens + 63u) / 64u))
        FAILMSG("global attention needs rows%%16==0 within the tokens' 64-block");
    auto iq = g_bufs.find(q), ik = g_bufs.find(k), iv = g_bufs.find(v), im = g_bufs.find(merged);
    if (iq == g_bufs.end() || ik == g_bufs.end() || iv == g_bufs.end() || im == g_bufs.end())
        FAILMSG("bad global attention operand");
    const sycl::half* Q = (const sycl::half*)iq->second.p;
    const sycl::half* Kk = (const sycl::half*)ik->second.p;
    const sycl::half* V = (const sycl::half*)iv->second.p;
    void* M = im->second.p;
    const unsigned CH = heads * 32u;
    const size_t sc = (size_t)heads * rows * rows;   // scores & probs
    const size_t cx = (size_t)heads * rows * 32u;    // ctx
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        float* dScores = (float*)pool_get(sc * 4);
        sycl::half* dProbs = (sycl::half*)pool_get(sc * 2);
        float* dRecip = (float*)pool_get((size_t)heads * rows * 4);
        float* dCtx = (float*)pool_get(cx * 4);
        const int Mp = (int)(((rows + 15u) / 16u) * 16u);   // rows%16==0 (guard) => Mp==rows
        // batched device pack + batched gemm (section 92): Q/Kk/V are contiguous per head
        // on device (h*rows*32), dScores at h*rows*rows, dCtx at h*rows*32 -- the same
        // shape window_attention had, so one batched pack + one batched gemm per leg
        // replaces the per-head host loop (the 460ms pathology). Bit-exact by construction.
        sycl::half* dAq = (sycl::half*)pool_get((size_t)heads * Mp * 32u * 2);
        sycl::half* dBk = (sycl::half*)pool_get((size_t)heads * 32u * rows * 2);
        sycl::half* dAp = (sycl::half*)pool_get((size_t)heads * Mp * rows * 2);
        sycl::half* dBv = (sycl::half*)pool_get((size_t)heads * rows * 32u * 2);
        // scores leg: Q(rows x 32) @ K^T(32 x rows) -> rows x rows. K stored (rows,32)=(N,K).
        packdev::pack_a16_b(*GQ, Q, dAq, (int)rows, Mp, 32, (int)heads);
        packdev::pack_b16_t_b(*GQ, Kk, dBk, 32, (int)rows, (int)heads);
        f16v1::gemm_b(*GQ, dAq, dBk, dScores, Mp, (int)rows, 32, (int)heads);
        // vit_softmax over heads*rows rows, tokens cols, stride=rows -- one launch.
        // P4 (section 100): the softmax STORE lands straight in attnV's pack_a16_b
        // A-tile layout (vit_softmax_tiled -- same values, same lever as P3a's
        // gemm_pub_pa16): dProbs (heads x rows x rows halfs = the frame's biggest
        // scratch, 33MB/call at rows=2040) AND the pack_a16_b pass both vanish.
        // Gate NR_GA_TILE (default ON once the three gates pass; =0 escape hatch).
        static bool gat = !getenv("NR_GA_TILE") || atoi(getenv("NR_GA_TILE")) != 0;
        if (gat && (rows % 16u) == 0u && Mp == (int)rows) {
            GQ->parallel_for(sycl::range((size_t)heads * rows),
                             smax::vit_softmax_tiled()(dScores, dAp, dRecip, heads * rows, tokens, rows));
        } else {
            GQ->parallel_for(sycl::range((size_t)heads * rows),
                             smax::vit_softmax_kernel()(dScores, dProbs, dRecip, heads * rows, tokens, rows));
            // attnV leg: P(rows x rows) @ V(rows x 32) -> rows x 32. V stored (rows,32)=(K,N).
            packdev::pack_a16_b(*GQ, dProbs, dAp, (int)rows, Mp, (int)rows, (int)heads);
        }
        packdev::pack_b16_b(*GQ, V, dBv, (int)rows, 32, (int)heads);
        f16v1::gemm_b(*GQ, dAp, dBv, dCtx, Mp, 32, (int)rows, (int)heads);
        pool_put(dAq); pool_put(dBk); pool_put(dAp); pool_put(dBv);
        // merge_heads_scale: (1,rows,heads*32) with scale=reciprocal (heads*rows), e4m3, half
        GQ->parallel_for(sycl::range((size_t)rows * CH), [=](sycl::item<1> it) {
            unsigned index = (unsigned)it.get_id(0);
            unsigned c = index % CH, token = index / CH;
            size_t at = (size_t)(c / 32u) * rows + token;   // window=0: at=(0*heads + c/32)*rows + token
            float value = qr_half_round(cr_mul(qr_half_round(dCtx[at * 32u + (c % 32u)]), dRecip[at]));
            ((sycl::half*)M)[index] = sycl::half(qr_e4m3(value));
        });
        pool_put(dScores); pool_put(dProbs); pool_put(dRecip); pool_put(dCtx);
    });
    return 0;
}
// int xmx_rec_quant_window(int source, int packed, int scale, unsigned M, unsigned K,
//                          unsigned height, unsigned width, unsigned across, unsigned pad)
// swap-in #6 (section 77): the SAME proven qr_kernel the plain xmx_rec_quant runs, with
// the 0x400000 gather flag and the four geometry words -- the kernel already carries the
// shipped branch (quantize_row.comp:195-208: token=held%64, window=held/64, y/x from
// across and pad, OUTSIDE -> zero row and scale 1.0, base=(y*width+x)*words in IMAGE
// layout), and the standalone probe proved the gather path 0-differ vs numpy. Guard per
// the shipped one (libxmx.c: K % 64 for the gathered form -- a token's words must be
// whole and 16-byte aligned however the image rows lie).
int xmx_rec_quant_window(int source, int packed, int scale, unsigned M, unsigned K,
                         unsigned height, unsigned width, unsigned across, unsigned pad) {
    if (!g_recording) FAILMSG("not recording");
    if (!M || !K || (K % 64u)) FAILMSG("a gathered quantiser needs K a multiple of 64");
    if (!across || !height || !width) FAILMSG("a gathered quantiser needs the image extent and windows per row");
    auto s = g_bufs.find(source), p2 = g_bufs.find(packed), c = g_bufs.find(scale);
    if (s == g_bufs.end() || p2 == g_bufs.end() || c == g_bufs.end()) FAILMSG("bad quant_window operand");
    sycl::half* a = (sycl::half*)s->second.p;
    sycl::uint2* pk = (sycl::uint2*)p2->second.p;
    float* sc = (float*)c->second.p;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        qr_launch(*GQ, *GD, qr_kernel(), a, pk, sc, M, K, 0x400000u,
                  height, width, across, pad, nullptr, nullptr);
    });
    if (qfuse_on())   // P4b: register the GATHERED pk for a downstream QKV take
        g_quant_pk[packed] = QuantFused{ g_cmds.size()-1, source, scale, M, K,
                                         true, height, width, across, pad };
    return 0;
}
// int xmx_rec_unary(unsigned kind, int a, int b, int c, int d, unsigned n,
//                   unsigned channels, float p0, unsigned batch, unsigned sa,
//                   unsigned sb, unsigned sc, unsigned k)
// swap-in #7 (section 79). The captured graph's 16 unary calls are FOUR elementwise /
// geometric kinds (resident.comp:44-55 enum): E4M3_HALF(18)x5, POOL2(12)x5,
// UPSAMPLE_ADD(21)x4, PAD_END(16)x2 -- NOT the section-71 coopmat-fused family (I
// mis-grouped unary there; corrected). All read the generic load_a/load_b/store
// (resident.comp:79-93): a/b narrow iff flags bit 15/16, store applies the epilogue
// (bits 8-11) then writes half iff bit 12. qr_publish is the already-gated rounding
// chain. kind = flags & 0xFF; the plan carries the FULL flags word in arg0 (e.g. 4364
// = 0x110C = POOL2 | narrow | b-half), so `kind` here is really the whole flags.
int xmx_rec_unary(unsigned kind, int a, int b, int c, int d, unsigned n,
                  unsigned channels, float p0, unsigned batch, unsigned sa,
                  unsigned sb, unsigned sc, unsigned k) {
    if (!g_recording) FAILMSG("not recording");
    const unsigned flags = kind;                 // the plan's arg0 IS the flags word
    const unsigned sub = flags & 0xFFu;
    auto ia = g_bufs.find(a), ic = g_bufs.find(c);
    if (ia == g_bufs.end() || ic == g_bufs.end()) FAILMSG("bad unary operand (a/c)");
    const void* A = ia->second.p; void* C = ic->second.p;
    const void* B = nullptr; if (b >= 0) { auto it = g_bufs.find(b); if (it != g_bufs.end()) B = it->second.p; }
    const float* D = nullptr; if (d >= 0) { auto it = g_bufs.find(d); if (it != g_bufs.end()) D = (const float*)it->second.p; }
    const bool a_half = (flags & 0x8000u) != 0u, b_half = (flags & 0x10000u) != 0u;
    const bool narrow = (flags & 0x1000u) != 0u;
    const unsigned epi = (flags >> 8) & 0xFu;
    const unsigned N = n, CH = channels;
    const unsigned SA = sa, SB = sb, SC = sc, KK = k, P0bits = 0; (void)P0bits;
    const float P0 = p0; (void)P0; (void)batch; (void)sub;
    // each branch is ONE device kernel with the load/store logic INLINE (a host helper
    // lambda captured by reference is not a legal kernel parameter -- the first cut's
    // compile error); scalars/pointers are captured by value.
    if (sub == 18u) {   // E4M3_HALF: value=a.f32; e4m3; write half (no gate, no epilogue)
        g_cmd_names.push_back(__func__);
        g_cmds.push_back([=]() {
            GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                size_t i = it.get_id(0);
                ((sycl::half*)C)[i] = sycl::half(qr_e4m3(((const float*)A)[i]));
            });
        });
    } else if (sub == 12u) {   // POOL2: 2x2 average NHWC, column-first order (.comp:529-531)
        g_cmd_names.push_back(__func__);
        g_cmds.push_back([=]() {
            GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                size_t index = it.get_id(0);
                unsigned ch = CH, width = SB;
                unsigned cc = (unsigned)(index % ch), rest = (unsigned)(index / ch);
                unsigned x = rest % (width / 2u), y = rest / (width / 2u);
                size_t base = ((size_t)(2u * y) * width + 2u * x) * ch + cc;
                auto ld = [&](size_t j) -> float { return a_half ? (float)((const sycl::half*)A)[j] : ((const float*)A)[j]; };
                float total = cr_add(cr_add(cr_add(ld(base), ld(base + (size_t)width * ch)),
                                            ld(base + ch)), ld(base + (size_t)(width + 1u) * ch));
                float value = qr_publish(epi, cr_mul(total, 0.25f));
                if (narrow) ((sycl::half*)C)[index] = sycl::half(value); else ((float*)C)[index] = value;
            });
        });
    } else if (sub == 21u) {   // UPSAMPLE_ADD: a[nearest2x] + (b*sine[c]), publish
        g_cmd_names.push_back(__func__);
        g_cmds.push_back([=]() {
            GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                size_t index = it.get_id(0);
                unsigned ch = CH, target = SA, source = SB;
                unsigned cc = (unsigned)(index % ch), rest = (unsigned)(index / ch);
                unsigned x = rest % target, y = rest / target;
                float bval = b_half ? (float)((const sycl::half*)B)[index] : ((const float*)B)[index];
                float aval = a_half ? (float)((const sycl::half*)A)[((size_t)(y / 2u) * source + (x / 2u)) * ch + cc]
                                    : ((const float*)A)[((size_t)(y / 2u) * source + (x / 2u)) * ch + cc];
                float merged = cr_add(aval, cr_mul(bval, D[cc]));
                float value = qr_publish(epi, merged);
                if (narrow) ((sycl::half*)C)[index] = sycl::half(value); else ((float*)C)[index] = value;
            });
        });
    } else if (sub == 16u) {   // PAD_END: extend with zeros
        g_cmd_names.push_back(__func__);
        g_cmds.push_back([=]() {
            GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                size_t index = it.get_id(0);
                unsigned ch = CH, height = SA, width = SB, padded = SC;
                unsigned cc = (unsigned)(index % ch), rest = (unsigned)(index / ch);
                unsigned x = rest % padded, y = rest / padded;
                float value = (y < height && x < width)
                    ? (a_half ? (float)((const sycl::half*)A)[((size_t)y * width + x) * ch + cc]
                              : ((const float*)A)[((size_t)y * width + x) * ch + cc])
                    : 0.0f;
                value = qr_publish(epi, value);
                if (narrow) ((sycl::half*)C)[index] = sycl::half(value); else ((float*)C)[index] = value;
            });
        });
    } else {
        FAILMSG("unary kind not implemented on Level-Zero (section 79 covers 12/16/18/21)");
    }
    return 0;
}
// int xmx_rec_merge_heads(int source, int dst, unsigned windows, unsigned tokens,
//                         unsigned channels, unsigned heads, unsigned epilogue,
//                         unsigned narrow)
// merge_heads foundation (section 84): resident.comp:626-641 MERGE_HEADS, the 4th leg of
// window_attention's four-pass golden (test_window_attention.py:55). (windows,heads,
// tokens,32) -> (windows,tokens,C): for output index (c, rest): token=rest%tokens,
// window=rest/tokens, at=(window*heads + c/32)*tokens + token, value=load_a(at*32 + c%32),
// then store (publish(epi) + narrow iff bit12). No 0x20000 scale leg (window_attention
// uses the plain merge; the ViT's vit_softmax normalisation is global_attention's path).
// int xmx_rec_vit_softmax(int source, int dst, int reciprocal, unsigned rows,
//                         unsigned tokens, unsigned stride)
// the ViT softmax leg (section 86): attention.comp:221-241 `vit_softmax` verbatim --
// weights published UNNORMALISED (e4m3(vit_weight)) into dst, and the row's reciprocal
// (half_round(1/total), total = the vendor's half-add tree) into `reciprocal` for
// merge_heads(scale=...) to apply. stride defaults to tokens. The global_attention
// recorder composes it; gated standalone against the .comp transcription (the .comp IS
// the authority, section 34/76 discipline -- nr_model.vit_attend is within-one only).
int xmx_rec_vit_softmax(int source, int dst, int reciprocal, unsigned rows,
                        unsigned tokens, unsigned stride) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !tokens || (stride && stride < tokens)) FAILMSG("bad vit_softmax dims");
    if (stride == 0u) stride = tokens;
    auto s = g_bufs.find(source), d = g_bufs.find(dst), rc = g_bufs.find(reciprocal);
    if (s == g_bufs.end() || d == g_bufs.end() || rc == g_bufs.end()) FAILMSG("bad vit_softmax operand");
    const float* sp = (const float*)s->second.p;
    sycl::half* dp = (sycl::half*)d->second.p;
    float* rp = (float*)rc->second.p;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range((size_t)rows),
                         smax::vit_softmax_kernel()(sp, dp, rp, rows, tokens, stride));
    });
    return 0;
}
int xmx_rec_merge_heads(int source, int dst, unsigned windows, unsigned tokens,
                        unsigned channels, unsigned heads, unsigned epilogue,
                        unsigned narrow) {
    if (!g_recording) FAILMSG("not recording");
    if (!windows || !tokens || !channels || !heads || (channels % 32u)) FAILMSG("bad merge_heads dims");
    auto s = g_bufs.find(source), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad merge_heads operand");
    const float* sp = (const float*)s->second.p;
    void* dp = d->second.p;
    const unsigned n = windows * tokens * channels;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range((size_t)n), [=](sycl::item<1> it) {
            unsigned index = (unsigned)it.get_id(0);
            unsigned c = index % channels, rest = index / channels;
            unsigned token = rest % tokens, window = rest / tokens;
            size_t at = ((size_t)window * heads + c / 32u) * tokens + token;
            float value = qr_publish(epilogue, sp[at * 32u + (c % 32u)]);
            if (narrow) ((sycl::half*)dp)[index] = sycl::half(value);
            else        ((float*)dp)[index] = value;
        });
    });
    return 0;
}
// int xmx_rec_merge_heads_scale(int source, int dst, int scale, unsigned windows,
//                                unsigned tokens, unsigned channels, unsigned heads,
//                                unsigned epilogue, unsigned narrow)
// the 0x20000 leg (resident.comp:635-639): value = half_round(half_round(load_a) *
// scale[at]) -- the ViT's normalisation deferred to the merge (vit_softmax wrote the
// per-row reciprocal). scale is float[windows*heads*tokens] indexed by `at`.
int xmx_rec_merge_heads_scale(int source, int dst, int scale, unsigned windows,
                              unsigned tokens, unsigned channels, unsigned heads,
                              unsigned epilogue, unsigned narrow) {
    if (!g_recording) FAILMSG("not recording");
    if (!windows || !tokens || !channels || !heads || (channels % 32u)) FAILMSG("bad merge_heads_scale dims");
    auto s = g_bufs.find(source), d = g_bufs.find(dst), sc = g_bufs.find(scale);
    if (s == g_bufs.end() || d == g_bufs.end() || sc == g_bufs.end()) FAILMSG("bad merge_heads_scale operand");
    const float* sp = (const float*)s->second.p;
    void* dp = d->second.p;
    const float* scp = (const float*)sc->second.p;
    const unsigned n = windows * tokens * channels;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range((size_t)n), [=](sycl::item<1> it) {
            unsigned index = (unsigned)it.get_id(0);
            unsigned c = index % channels, rest = index / channels;
            unsigned token = rest % tokens, window = rest / tokens;
            size_t at = ((size_t)window * heads + c / 32u) * tokens + token;
            float value = qr_half_round(cr_mul(qr_half_round(sp[at * 32u + (c % 32u)]), scp[at]));
            value = qr_publish(epilogue, value);
            if (narrow) ((sycl::half*)dp)[index] = sycl::half(value);
            else        ((float*)dp)[index] = value;
        });
    });
    return 0;
}
// int xmx_rec_unary2(unsigned kind, int a, int b, int c, int d, int second, unsigned n,
//                    unsigned channels, float p0, unsigned batch, unsigned sa,
//                    unsigned sb, unsigned sc, unsigned k)
// swap-in #11 (section 87): the captured graph's single unary2 call is kind 0x10015 =
// UPSAMPLE_ADD(21) + epi1 + narrow + b-half, WITH a second output. resident.comp:598-600:
//   merged = load_a(nearest2x) + load_b(index)*sine[c]   (two non-fused precise steps)
//   store(index, merged)                                 (publish(epi) + narrow)
//   if (second) HalfBuf(second).v[index] = float16_t(e4m3(merged))   -- the RAW published
//     skip the block 70 head reads, e4m3 only (no gate), always half.
// Same gather/publish as the unary UPSAMPLE_ADD branch, plus the second store.
int xmx_rec_unary2(unsigned kind, int a, int b, int c, int d, int second, unsigned n,
                   unsigned channels, float p0, unsigned batch, unsigned sa,
                   unsigned sb, unsigned sc, unsigned k) {
    if (!g_recording) FAILMSG("not recording");
    const unsigned flags = kind;
    const unsigned sub = flags & 0xFFu;
    if (sub != 21u) FAILMSG("unary2: only UPSAMPLE_ADD(21) is in the captured graph (section 87)");
    if (second < 0) FAILMSG("a two-output pass needs its second output");
    auto ia = g_bufs.find(a), ic = g_bufs.find(c), i2 = g_bufs.find(second);
    if (ia == g_bufs.end() || ic == g_bufs.end() || i2 == g_bufs.end()) FAILMSG("bad unary2 operand");
    const sycl::half* A = (const sycl::half*)ia->second.p;
    void* C = ic->second.p;
    sycl::half* S = (sycl::half*)i2->second.p;
    const sycl::half* B = nullptr; if (b >= 0) { auto it = g_bufs.find(b); if (it != g_bufs.end()) B = (const sycl::half*)it->second.p; }
    const float* D = nullptr; if (d >= 0) { auto it = g_bufs.find(d); if (it != g_bufs.end()) D = (const float*)it->second.p; }
    const bool a_half = (flags & 0x8000u) != 0u, b_half = (flags & 0x10000u) != 0u;
    const bool narrow = (flags & 0x1000u) != 0u;
    const unsigned epi = (flags >> 8) & 0xFu;
    const unsigned N = n, CH = channels, SA = sa, SB = sb;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
            unsigned index = (unsigned)it.get_id(0);
            unsigned cc = index % CH, rest = index / CH;
            unsigned x = rest % SA, y = rest / SA;
            float bval = b_half ? (float)((const sycl::half*)B)[index] : ((const float*)B)[index];
            size_t asrc = ((size_t)(y / 2u) * SB + (x / 2u)) * CH + cc;
            float aval = a_half ? (float)((const sycl::half*)A)[asrc] : ((const float*)A)[asrc];
            float merged = cr_add(aval, cr_mul(bval, D[cc]));
            float value = qr_publish(epi, merged);
            if (narrow) ((sycl::half*)C)[index] = sycl::half(value);
            else        ((float*)C)[index] = value;
            S[index] = sycl::half(qr_e4m3(merged));   // the second: e4m3 only, always half
        });
    });
    return 0;
}
// // SECTION 99: ESIMD vectorized softmax leg (split path). The scalar smax::softmax_kernel
// runs one work-item per ROW with 64 sequential per-element scalar ops (NR_WB_STOP
// alternating delta = 60ms for 20 calls = 3ms/call). The vector form is the v2 P4
// recipe VERBATIM (bench_p4vec2.cpp stage-by-stage bit-exact 0/16384 vs the shipped
// softmax_kernel; the m0 spelling keeps hl*scale EXACT in f32 and rounds ONCE after
// +bias -- the §92 FMA-contraction trap; total stays the golden's SEQUENTIAL f32 sum).
// Generalized here: boff = ((r/64)%heads)*4096 + (r%64)*64 (heads==1 in window_block,
// heads>1 in window_attention), and probs store ROW-MAJOR half (the split layout)
// instead of the pa16 pack map.
static inline bool smaxplain2() { static bool v = getenv("NR_SMAX_PLAIN") != nullptr; return v; }
static inline void smax_esimd(sycl::queue& q, const float* dScores, sycl::half* dProbs,
                              unsigned rows, const float* Bias, unsigned heads)
{
    q.parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        unsigned r = (unsigned)it.get_id(0);
        const float* row = dScores + (size_t)r * 64u;
        size_t boff = Bias ? ((size_t)((r / 64u) % (heads ? heads : 1u)) * 4096u
                            + (size_t)(r % 64u) * 64u) : 0;
        esimd::simd<float,32> s0(row), s1(row+32);
        esimd::simd<float,32> b0(0.f), b1(0.f);
        if (Bias) { b0 = esimd::simd<float,32>(Bias+boff); b1 = esimd::simd<float,32>(Bias+boff+32); }
        esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<sycl::half>(s0 + b0));
        esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<sycl::half>(s1 + b1));
        esimd::simd<float,32> a0 = esimd::convert<float>(esimd::convert<sycl::half>(
            hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
        esimd::simd<float,32> a1 = esimd::convert<float>(esimd::convert<sycl::half>(
            hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
        a0 = (esimd::min)((esimd::max)(a0, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
        a1 = (esimd::min)((esimd::max)(a1, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
        esimd::simd<sycl::half,16> he0=esimd::convert<sycl::half>(a0.template select<16,2>(0).read());
        esimd::simd<sycl::half,16> ho0=esimd::convert<sycl::half>(a0.template select<16,2>(1).read());
        esimd::simd<sycl::half,16> he1=esimd::convert<sycl::half>(a1.template select<16,2>(0).read());
        esimd::simd<sycl::half,16> ho1=esimd::convert<sycl::half>(a1.template select<16,2>(1).read());
        esimd::simd<uint16_t,16> e0; e0=he0.bit_cast_view<uint16_t>();
        esimd::simd<uint16_t,16> o0; o0=ho0.bit_cast_view<uint16_t>();
        esimd::simd<uint16_t,16> e1; e1=he1.bit_cast_view<uint16_t>();
        esimd::simd<uint16_t,16> o1; o1=ho1.bit_cast_view<uint16_t>();
        esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
        esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
        esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
        esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
        esimd::simd<sycl::half,32> w0; w0=t0.bit_cast_view<sycl::half>();
        esimd::simd<sycl::half,32> w1; w1=t1.bit_cast_view<sycl::half>();
        esimd::simd<float,32> f0 = esimd::convert<float>(w0);
        esimd::simd<float,32> f1 = esimd::convert<float>(w1);
        float total = 0.0f;
        for (unsigned cc = 0; cc < 32u; ++cc) total += f0[cc];
        for (unsigned cc = 0; cc < 32u; ++cc) total += f1[cc];   // golden's sequential f32 sum 0..63
        float trh = wbmega::eh_round(total);
        float recip = wbmega::eh_round(wbv2::ef_div(1.0f, trh));   // ESIMD hw div
        esimd::simd<sycl::half,32> oh0 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w0), recip)));
        esimd::simd<sycl::half,32> oh1 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w1), recip)));
        oh0.copy_to(dProbs + (size_t)r * 64u);
        oh1.copy_to(dProbs + (size_t)r * 64u + 32u);
    });
}
// P4c (section 100): smax_esimd with the STORE landing straight in attnV's pack_a16_b
// A-tile (the promoted P4a lever, zero parallelism change: one item per row, the SAME
// vector math VERBATIM). Geometry: rows = batches*64, Mp=K=64 -> per batch block
// per = 4*4*2*128 = 4096 halfs; dest = bb*4096 + ((tr*4+kc)*2+strip)*128 + il*16 + k16
// with tr=(srow/16), strip=(srow%16)/8, il=srow%8, srow=r%64, bb=r/64. oh0 = cols
// 0..31 (kc 0,1), oh1 = cols 32..63 (kc 2,3) -- each 16-col piece is one +k16 run.
static inline void smax_esimd_tiled(sycl::queue& q, const float* dScores, sycl::half* dAp,
                                    unsigned rows, const float* Bias, unsigned heads)
{
    q.parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        unsigned r = (unsigned)it.get_id(0);
        const float* row = dScores + (size_t)r * 64u;
        size_t boff = Bias ? ((size_t)((r / 64u) % (heads ? heads : 1u)) * 4096u
                            + (size_t)(r % 64u) * 64u) : 0;
        esimd::simd<float,32> s0(row), s1(row+32);
        esimd::simd<float,32> b0(0.f), b1(0.f);
        if (Bias) { b0 = esimd::simd<float,32>(Bias+boff); b1 = esimd::simd<float,32>(Bias+boff+32); }
        esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<sycl::half>(s0 + b0));
        esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<sycl::half>(s1 + b1));
        esimd::simd<float,32> a0 = esimd::convert<float>(esimd::convert<sycl::half>(
            hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
        esimd::simd<float,32> a1 = esimd::convert<float>(esimd::convert<sycl::half>(
            hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
        a0 = (esimd::min)((esimd::max)(a0, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
        a1 = (esimd::min)((esimd::max)(a1, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
        esimd::simd<sycl::half,16> he0=esimd::convert<sycl::half>(a0.template select<16,2>(0).read());
        esimd::simd<sycl::half,16> ho0=esimd::convert<sycl::half>(a0.template select<16,2>(1).read());
        esimd::simd<sycl::half,16> he1=esimd::convert<sycl::half>(a1.template select<16,2>(0).read());
        esimd::simd<sycl::half,16> ho1=esimd::convert<sycl::half>(a1.template select<16,2>(1).read());
        esimd::simd<uint16_t,16> e0; e0=he0.bit_cast_view<uint16_t>();
        esimd::simd<uint16_t,16> o0; o0=ho0.bit_cast_view<uint16_t>();
        esimd::simd<uint16_t,16> e1; e1=he1.bit_cast_view<uint16_t>();
        esimd::simd<uint16_t,16> o1; o1=ho1.bit_cast_view<uint16_t>();
        esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
        esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
        esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
        esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
        esimd::simd<sycl::half,32> w0; w0=t0.bit_cast_view<sycl::half>();
        esimd::simd<sycl::half,32> w1; w1=t1.bit_cast_view<sycl::half>();
        esimd::simd<float,32> f0 = esimd::convert<float>(w0);
        esimd::simd<float,32> f1 = esimd::convert<float>(w1);
        float total = 0.0f;
        for (unsigned cc = 0; cc < 32u; ++cc) total += f0[cc];
        for (unsigned cc = 0; cc < 32u; ++cc) total += f1[cc];   // golden's sequential f32 sum 0..63
        float trh = wbmega::eh_round(total);
        float recip = wbmega::eh_round(wbv2::ef_div(1.0f, trh));   // ESIMD hw div
        esimd::simd<sycl::half,32> oh0 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w0), recip)));
        esimd::simd<sycl::half,32> oh1 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w1), recip)));
        // TILE STORE (the only diff vs smax_esimd): split each 32-half run into two
        // 16-half k16 runs at (kc, kc+1).
        unsigned bb = r / 64u, srow = r % 64u;
        unsigned tr = srow / 16u, strip = (srow % 16u) / 8u, il = srow % 8u;
        sycl::half* base = dAp + (size_t)bb * 4096u + ((size_t)(tr * 4u + 0u) * 2u + strip) * 128u + il * 16u;
        esimd::simd<sycl::half,16> q0 = oh0.template select<16,1>(0);
        esimd::simd<sycl::half,16> q1 = oh0.template select<16,1>(16);
        esimd::simd<sycl::half,16> q2 = oh1.template select<16,1>(0);
        esimd::simd<sycl::half,16> q3 = oh1.template select<16,1>(16);
        q0.copy_to(base);
        q1.copy_to(base + 256u);          // kc=1: block stride 2*128 = 256 halfs
        q2.copy_to(base + 512u);          // kc=2
        q3.copy_to(base + 768u);          // kc=3
    });
}
// int xmx_rec_window_attention(int q, int k, int v, int bias, int out,
//                              unsigned batches, unsigned heads, unsigned merged)
// swap-in #9 (section 85): the fused window attention, COMPOSED from the four gated
// foundations (sections 82/83/84) -- the shipping window_attention.comp does all four in
// one coopmat kernel with shared memory, and test_window_attention.py proves that fused
// kernel is bit-identical to the four-pass sequence rt.gemm(q,k,scores,transpose_b) ->
// rt.softmax(scores,probs,narrow,bias,heads) -> rt.gemm(probs,v,ctx) ->
// rt.merge_heads(ctx,out,EPI_E4M3,narrow). We reproduce THAT four-pass contract (the
// byte contract the fused kernel is defined by), one g_cmds push = the whole attention
// (passes +1 per captured call).
//   q,k,v: (batches, 64, 32) half, batches = windows*heads (the QKV epilogue's output).
//   bias: (heads, 64, 64) f32, or -1 (no bias).
//   out: merged=1 -> (windows, 64, heads*32) half (merge_heads); merged=0 -> the f32
//        attnV context (batches, 64, 32).
//   scores (batches,64,64) f32, probs (batches,64,64) half, ctx (batches,64,32) f32 are
//   device scratch allocated in the closure.
int xmx_rec_window_attention(int q, int k, int v, int bias, int out,
                             unsigned batches, unsigned heads, unsigned merged) {
    if (!g_recording) FAILMSG("not recording");
    if (!batches || !heads || (batches % heads)) FAILMSG("window attention needs heads | batches");
    if (merged > 1) FAILMSG("invalid window attention output mode");
    auto iq = g_bufs.find(q), ik = g_bufs.find(k), iv = g_bufs.find(v), io = g_bufs.find(out);
    if (iq == g_bufs.end() || ik == g_bufs.end() || iv == g_bufs.end() || io == g_bufs.end())
        FAILMSG("bad window attention operand");
    const sycl::half* Q = (const sycl::half*)iq->second.p;
    const sycl::half* Kk = (const sycl::half*)ik->second.p;
    const sycl::half* V = (const sycl::half*)iv->second.p;
    void* Out = io->second.p;
    const float* Bp = nullptr;
    if (bias >= 0) { auto it = g_bufs.find(bias); if (it == g_bufs.end()) FAILMSG("bad bias"); Bp = (const float*)it->second.p; }
    const unsigned windows = batches / heads;
    const size_t sc_elems = (size_t)batches * 64u * 64u;   // scores & probs
    const size_t ctx_elems = (size_t)batches * 64u * 32u;  // attnV context
    g_cmd_names.push_back(__func__);
        flop_note("winattn_scores",64u,64u,32u,batches); flop_note("winattn_attnv",64u,32u,64u,batches);
    g_cmds.push_back([=]() {
        // device pack + batched gemm (section 92): the per-batch host loop (4 sync
        // memcpys + 4 malloc/free + 2 launches PER batch, batches up to 2040) was the
        // 34s pathology. Q/K/V are already contiguous per batch on device, so one
        // batched pack + one batched gemm covers every window; the dpas sequence per
        // tile is identical to the loop's, so it is bit-exact by construction.
        float* dScores = (float*)pool_get(sc_elems * 4);
        sycl::half* dProbs = (sycl::half*)pool_get(sc_elems * 2);
        float* dCtx = (float*)pool_get(ctx_elems * 4);
        sycl::half* dAq = (sycl::half*)pool_get((size_t)batches * 64u * 32u * 2);
        sycl::half* dBk = (sycl::half*)pool_get((size_t)batches * 32u * 64u * 2);
        sycl::half* dAp = (sycl::half*)pool_get((size_t)batches * 64u * 64u * 2);
        sycl::half* dBv = (sycl::half*)pool_get((size_t)batches * 64u * 32u * 2);
        // scores leg: Q(64x32) @ K^T(32x64) -> 64x64. K stored (64 tokens,32 ch) = (N,K).
        packdev::pack_a16_b(*GQ, Q, dAq, 64, 64, 32, (int)batches);
        packdev::pack_b16_t_b(*GQ, Kk, dBk, 32, 64, (int)batches);
        // section 99: v2 workgroup-SLM-tiled f16 gemm (v1 = one 16x16 tile per GLOBAL
        // load, 8 FLOP/byte = memory-bound; v2 stages BM=64 x BK=16 blocks in SLM with
        // 4x reuse). Mp=64 is a multiple of BM. NR_F16V1=1 = escape hatch.
        if (getenv("NR_F16V1")) f16v1::gemm_b(*GQ, dAq, dBk, dScores, 64, 64, 32, (int)batches);
        else                    f16v2::gemm_b2<64>(*GQ, dAq, dBk, dScores, 64, 64, 32, (int)batches);
        // softmax over (batches*64) rows of 64, with bias (heads,64,64) -- one launch.
        static bool smaxplain = getenv("NR_SMAX_PLAIN") != nullptr;   // escape hatch
        static bool wat = !getenv("NR_WA_TILE") || atoi(getenv("NR_WA_TILE")) != 0;   // P4c
        if (wat && !smaxplain) {
            // the softmax STORE lands in attnV's A tile (pack_a16_b map) directly:
            // dProbs (batches x 64 x 64 halfs) + its pack pass vanish. One item per
            // row, the SAME vector math VERBATIM (the promoted P4a lever).
            smax_esimd_tiled(*GQ, dScores, dAp, batches*64u, Bp, heads);
        }
        else if (!smaxplain) smax_esimd(*GQ, dScores, dProbs, batches*64u, Bp, heads);
        else
        GQ->parallel_for(sycl::range((size_t)batches*64u),
                         smax::softmax_kernel()(dScores, dProbs, batches*64u, 64u, Bp, heads));
        // attnV leg: P(64x64) @ V(64x32) -> 64x32. V stored (64 tokens,32 ch) = (K,N).
        if (!wat || smaxplain) packdev::pack_a16_b(*GQ, dProbs, dAp, 64, 64, 64, (int)batches);
        packdev::pack_b16_b(*GQ, V, dBv, 64, 32, (int)batches);
        // P9 (section 100): attnV + merge_heads FOLDED (gemm_b2_merge): the e4m3
        // publish lands ON the accumulator and scatters straight into the merged
        // (windows,64,heads*32) half layout -- dCtx (16.7MB/call f32 write+read)
        // AND the merge launch both vanish. Same lever as the promoted
        // gemm_pub_pa16; e4m3 via the bench_pubvec-proven vector form.
        // Gate NR_WA_MERGE (default ON once the three gates pass). merged=1 only.
        static bool wam = !getenv("NR_WA_MERGE") || atoi(getenv("NR_WA_MERGE")) != 0;
        if (wam && merged) {
            f16v2::gemm_b2_merge(*GQ, dAp, dBv, (sycl::half*)Out, 64, 32, 64, (int)batches, (int)heads);
        } else {
        if (getenv("NR_F16V1")) f16v1::gemm_b(*GQ, dAp, dBv, dCtx, 64, 32, 64, (int)batches);
        else                    f16v2::gemm_b2<32>(*GQ, dAp, dBv, dCtx, 64, 32, 64, (int)batches);
        if (merged) {
            // merge_heads: (windows,heads,64,32) -> (windows,64,heads*32), publish e4m3, half
            const unsigned CH = heads * 32u;
            GQ->parallel_for(sycl::range((size_t)windows*64u*CH), [=](sycl::item<1> it) {
                unsigned index = (unsigned)it.get_id(0);
                unsigned c = index % CH, rest = index / CH;
                unsigned token = rest % 64u, window = rest / 64u;
                size_t at = ((size_t)window * heads + c / 32u) * 64u + token;
                ((sycl::half*)Out)[index] = sycl::half(qr_e4m3(dCtx[at * 32u + (c % 32u)]));
            });
        } else {
            ev_sync(GQ->memcpy(Out, dCtx, ctx_elems * 4));
        }
        }   // P9 fold gate
        pool_put(dScores); pool_put(dProbs); pool_put(dCtx);
        pool_put(dAq); pool_put(dBk); pool_put(dAp); pool_put(dBv);
    });
    return 0;
}
// int xmx_rec_gemm_window_residual_pool(int a, int b, int skip_out, int skip, int cosine,
//        int pooled, unsigned M, unsigned N, unsigned K, unsigned flags,
//        unsigned height, unsigned width, unsigned across, unsigned pad)
// f16 gemm_window_residual_pool FOUNDATION (section 88 route; window_block's POOL form's
// third leg). libxmx.c:2393: record_gemm(a,b,skip_out,M,N,K,1,...,flags|0x8a0000,skip,
// cosine,window,...,pooled). = the window_residual map + TWO published outputs made in the
// epilogue (gemm_staged.comp:346-390, pinned before writing -- section 73):
//   skip_out (the c target) = e4m3(total) as half;  total = fma(skip, cosine[col], acc);
//   pooled = e4m3(0.25 * the four taps summed in order (token, token+8, token+1, token+9))
//            at the half-resolution image index (the window's 16 pooled pixels).
// pool needs even extents and pads (xmxres gemm_residual_pool guard).
int xmx_rec_gemm_window_residual_pool(int a, int b, int skip_out, int skip, int cosine,
                                      int pooled, unsigned M, unsigned N, unsigned K,
                                      unsigned flags, unsigned height, unsigned width,
                                      unsigned across, unsigned pad) {
    if (!g_recording) FAILMSG("not recording");
    if (!height || !width || !across) FAILMSG("invalid pooled window residual");
    if (!M || !N || !K || (N % 16u) || (K % 16u) || (M % 64u))
        FAILMSG("gemm_window_residual_pool f16 needs N%%16,K%%16,M%%64");
    if ((height % 2u) || (width % 2u) || ((pad >> 16) % 2u) || ((pad & 0xffffu) % 2u))
        FAILMSG("a pooled window residual needs even extents and pads");
    auto ia = g_bufs.find(a), ib = g_bufs.find(b), iso = g_bufs.find(skip_out);
    auto isk = g_bufs.find(skip), ico = g_bufs.find(cosine), ipd = g_bufs.find(pooled);
    if (ia == g_bufs.end() || ib == g_bufs.end() || iso == g_bufs.end() ||
        isk == g_bufs.end() || ico == g_bufs.end() || ipd == g_bufs.end())
        FAILMSG("bad gemm_window_residual_pool operand");
    const bool half_skip = (flags & 0x40000u) != 0u;
    const size_t img_elems = (size_t)height * width * N;
    const size_t blk_elems = (size_t)M * N;
    const int Mp = (int)(((M + 15u) / 16u) * 16u);
    const size_t na = (size_t)Mp * K, nb = (size_t)K * N;
    const unsigned top = pad >> 16, left = pad & 0xffffu;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        auto sized = [&](int id, size_t bytes, const char* what) -> void* {
            auto it = g_bufs.find(id);
            if (it == g_bufs.end()) throw std::runtime_error(std::string("pooled residual: ") + what + " not live at run");
            if (it->second.bytes < bytes) throw std::runtime_error(std::string("pooled residual: ") + what + " smaller at run");
            return it->second.p;
        };
        sycl::half* Araw = (sycl::half*)sized(a, (size_t)M * K * 2, "A");
        sycl::half* Braw = (sycl::half*)sized(b, nb * 2, "B");
        sycl::half* SkipOut = (sycl::half*)sized(skip_out, img_elems * 2, "skip_out");
        const void* skp = sized(skip, img_elems * (half_skip ? 2u : 4u), "skip");
        const float* cp = (const float*)sized(cosine, (size_t)N * 4u, "cosine");
        sycl::half* Pl = (sycl::half*)sized(pooled, (img_elems / 4u) * 2, "pooled");
        std::vector<sycl::half> hA((size_t)M * K), hApad(na, sycl::half(0.f)), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, (size_t)M * K * 2));
        std::memcpy(hApad.data(), hA.data(), (size_t)M * K * 2);
        ev_sync(GQ->memcpy(hB.data(), Braw, nb * 2));
        f16v1::pack_a(hApad.data(), hAp.data(), Mp, (int)K);
        f16v1::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        sycl::half* dAp = (sycl::half*)pool_get(na * 2);
        sycl::half* dBp = (sycl::half*)pool_get(nb * 2);
        float* dC = (float*)pool_get((size_t)Mp * N * 4);
        float* dStage = (float*)pool_get((size_t)M * N * 4);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na * 2));
        ev_sync(GQ->memcpy(dBp, hBp.data(), nb * 2));
        f16v1::gemm(*GQ, dAp, dBp, dC, Mp, (int)N, (int)K);
        GQ->parallel_for(sycl::range(blk_elems), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / N), col = (unsigned)(i % N);
            unsigned window = r / 64u, token = r % 64u;
            unsigned y = (window / across) * 8u + token / 8u;
            unsigned x = (window % across) * 8u + token % 8u;
            if (y < top || x < left || y - top >= height || x - left >= width) return;
            size_t out = ((size_t)(y - top) * width + (x - left)) * N + col;
            float sk = half_skip ? (float)((const sycl::half*)skp)[out] : ((const float*)skp)[out];
            float total = sycl::fma(sk, cp[col], dC[i]);
            SkipOut[out] = sycl::half(qr_e4m3(total));
            dStage[i] = total;
        });
        GQ->parallel_for(sycl::range((size_t)(M / 64u) * 16u * N), [=](sycl::item<1> it) {
            size_t e = it.get_id(0);
            unsigned pixel = (unsigned)((e / N) % 16u), c = (unsigned)(e % N);   // pixel WITHIN the window (the flat range spans windows -- the .comp's e is per-workgroup <16*BN)
            unsigned window = (unsigned)(e / (16u * N));
            unsigned token = (pixel / 4u) * 16u + (pixel % 4u) * 2u;
            unsigned y = (window / across) * 8u + token / 8u;
            unsigned x = (window % across) * 8u + token % 8u;
            if (y < top || x < left || y - top >= height || x - left >= width) return;
            size_t base = (size_t)window * 64u * N;
            float total = cr_add(cr_add(cr_add(dStage[base + (size_t)token * N + c],
                                               dStage[base + (size_t)(token + 8u) * N + c]),
                                        dStage[base + (size_t)(token + 1u) * N + c]),
                                 dStage[base + (size_t)(token + 9u) * N + c]);
            size_t out = ((size_t)((y - top) / 2u) * (width / 2u) + ((x - left) / 2u)) * N + c;
            Pl[out] = sycl::half(qr_e4m3(cr_mul(total, 0.25f)));
        });
        pool_put(dAp); pool_put(dBp); pool_put(dC); pool_put(dStage);
    });
    return 0;
}
// // SECTION 99: ESIMD vectorized LEG-3 residual (split window_block). The scalar leg ran
// 32 per-row element ops with masked-SIMD divergence (NR_WB_STOP delta = 71.6ms for
// 20 calls = 3.6ms/call at ~1.5GB/s). Vector form: ONE work-item per 32-channel row --
// 128B dC3 load, 64B image-half load, 32-wide FMA (a*b+c lowers to ONE HW fma in an
// ESIMD kernel, == sycl::fma: the gate-proven mega-residual equivalence, wbv2 header
// note), wbv2::e4m3_vec<32> (bit-exact vs qr_e4m3_scalar, bench_e4m3vec 0/4096),
// 64B half store. epi 0/1/4 covered (epi=4 narrow == direct convert<half>: the
// half->float->half round-trip is exact); epi 2/3 (gate) and pooling/head keep the
// scalar leg. All addresses are 32*C-aligned (C=32) -> tag<16> everywhere.
static inline bool wb_leg3_esimd_ok(unsigned epi, bool pooling, bool head) {
    return !pooling && !head && (epi == 0u || epi == 1u || epi == 4u);
}
static inline void wb_leg3_esimd(sycl::queue& q, const sycl::half* ImgH, const float* ImgF,
    bool image_half, const float* cp, const float* dC3, void* Tgt,
    bool narrow, unsigned epi, unsigned rows, unsigned height, unsigned width,
    unsigned across, unsigned top, unsigned left, unsigned C)
{
    q.parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        unsigned r = (unsigned)it.get_id(0);
        unsigned window = r / 64u, token = r % 64u;
        unsigned y = (window / across) * 8u + token / 8u;
        unsigned x = (window % across) * 8u + token % 8u;
        if (y < top || x < left || y - top >= height || x - left >= width) return;
        size_t out = ((size_t)(y - top) * width + (x - left)) * C;
        esimd::simd<float,32> c3 = esimd::block_load<float,32>(
            dC3 + (size_t)r * C, esimd::overaligned_tag<16>{});
        esimd::simd<float,32> sk;
        if (image_half) sk = esimd::convert<float>(esimd::block_load<sycl::half,32>(
            ImgH + out, esimd::overaligned_tag<16>{}));
        else            sk = esimd::block_load<float,32>(
            ImgF + out, esimd::overaligned_tag<16>{});
        esimd::simd<float,32> cv = esimd::block_load<float,32>(
            cp, esimd::overaligned_tag<16>{});
        esimd::simd<float,32> total = sk * cv + c3;          // ONE HW FMA per lane
        esimd::simd<float,32> pub = (epi == 1u) ? wbv2::e4m3_vec<32>(total) : total;
        if (narrow) esimd::block_store<sycl::half,32>((sycl::half*)Tgt + out,
            esimd::convert<sycl::half>(pub), esimd::overaligned_tag<16>{});
        else        esimd::block_store<float,32>((float*)Tgt + out, pub,
            esimd::overaligned_tag<16>{});
    });
}
// int xmx_rec_window_block(int image, int qkv, int projection, int target, int bias,
//                          int cosine, int scale, int pooled, unsigned windows,
//                          unsigned height, unsigned width, unsigned across, unsigned pad,
//                          unsigned flags)
// swap-in #15 (section 88 route): a 32-channel window block's attention half, composed
// from the three legs window_block.comp replaces. window_block.comp's header is explicit:
// "Three passes did this: the QKV projection, gathering the window's rows from the image
// and normalising Q and K in its epilogue; window attention; and the output projection
// with the residual ... the output is the three passes', bit for bit" (test_window_block.py
// is the shipping witness, :208-216 the decomposition). Pinned before writing (section 73):
//   leg1 = gemm_qkv_window(image, qkv -> q,k,v, rows=windows*64, C=32, heads=1, tokens=64,
//          width,height,across,pad, image_mode = (image_half?1:0)|2)   [publish_image ALWAYS:
//          the image is the projection's input and is rounded to e4m3 on the way in]
//   leg2 = window_attention(q,k,v, bias, attended, batches=windows, heads=1, merged=1)
//   leg3 = gemm_window_residual(attended, projection, image, cosine -> target,
//          rows, 32, 32, flags, height,width,across,pad)   [skip = the image itself]
// captured window_block (section 88's plan dump): 10 calls, ALL heads==1 C==32 tokens==64;
// plain flags in {0x1100 epi1+narrow, 0x0 f32-out}, image_half = flags&0x8000. The pool
// (0x800000, block 0) and head (0x1000000, block 70) forms need their own extra legs
// (gemm_window_residual_pool / the compact head GEMM) -- rejected fail-loud until built.
// Composition = ONE g_cmds push (one plan step -> +1 pass); the three legs run back to
// back on device scratch (q/k/v/attended never leave as plan buffers -- the fused kernel
// keeps them in shared, section 9's megakernel job).
int xmx_rec_window_block(int image, int qkv, int projection, int target, int bias,
                         int cosine, int scale, int pooled, unsigned windows,
                         unsigned height, unsigned width, unsigned across, unsigned pad,
                         unsigned flags) {
    if (!g_recording) FAILMSG("not recording");
    if (!windows || !height || !width || !across || windows % across)
        FAILMSG("invalid window block geometry (libxmx.c:2637)");
    const bool pooling = (flags & 0x800000u) != 0u;
    const bool head = (flags & 0x1000000u) != 0u;   // block 70: its output feeds the compact head GEMM, never stored as the image
    auto im = g_bufs.find(image), iq = g_bufs.find(qkv), ipr = g_bufs.find(projection),
         itg = g_bufs.find(target), ib = g_bufs.find(bias), ico = g_bufs.find(cosine),
         isc = g_bufs.find(scale);
    if (im == g_bufs.end() || iq == g_bufs.end() || ipr == g_bufs.end() || itg == g_bufs.end() ||
        ib == g_bufs.end() || ico == g_bufs.end() || isc == g_bufs.end())
        FAILMSG("bad window_block operand");
    sycl::half* Pl = nullptr;
    if (pooling) {
        if ((height % 2u) || (width % 2u) || ((pad >> 16) % 2u) || ((pad & 0xffffu) % 2u))
            FAILMSG("a pooled window block needs even extents and pads (libxmx.c:2648)");
        auto it = g_bufs.find(pooled);
        if (it == g_bufs.end()) FAILMSG("bad window_block pooled operand");
        Pl = (sycl::half*)it->second.p;
    }
    const bool image_half = (flags & 0x8000u) != 0u;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const unsigned C = 32u, heads = 1u, tokens = 64u, NH = 3u * C;
    const unsigned rows = windows * tokens;
    const int Mp = (int)(((rows + 15u) / 16u) * 16u);
    const unsigned top = pad >> 16, left = pad & 0xffffu;
    const size_t wsz = (narrow || pooling) ? 2u : 4u;   // the pool's target is half by definition
    const size_t img_elems = (size_t)height * width * C;
    const size_t blk_elems = (size_t)rows * C;
    const size_t c_need = head ? (size_t)height * width * 4u * 4u : img_elems * wsz;   // head: compact float32 target (pixels x 4)
    const size_t k_need = img_elems * (image_half ? 2u : 4u);
    const int image_id = image, target_id = target;
    g_cmd_names.push_back(__func__);
        flop_note("wb_qkv",windows*64u,96u,32u,1); flop_note("wb_scores",windows*64u,64u,32u,1); flop_note("wb_attnv",windows*64u,32u,64u,1); flop_note("wb_proj",windows*64u,32u,32u,1);
    g_cmds.push_back([=]() {
        auto sized = [&](int id, size_t bytes, const char* what) -> void* {
            auto it = g_bufs.find(id);
            if (it == g_bufs.end()) throw std::runtime_error(std::string("window block: ") + what + " not live at run");
            if (it->second.bytes < bytes) throw std::runtime_error(std::string("window block: ") + what + " smaller than needed at run");
            return it->second.p;
        };
        const sycl::half* ImgH = (const sycl::half*)sized(image, img_elems * (image_half ? 2u : 4u), "image");
        const float* ImgF = (const float*)ImgH;
        const sycl::half* Wraw = (const sycl::half*)sized(qkv, (size_t)C * NH * 2, "qkv");
        const sycl::half* Praw = (const sycl::half*)sized(projection, (size_t)C * C * 2, "projection");
        void* Tgt = sized(target, c_need, "target");
        const float* Bp = (const float*)sized(bias, (size_t)64u * 64u * 4, "bias");
        const float* cp = (const float*)sized(cosine, (size_t)C * 4, "cosine");
        const float* qs = (const float*)sized(scale, 4, "scale");
        const sycl::half* HeadW = head ? (const sycl::half*)sized(pooled, (size_t)C * 16u * 2, "head weights") : nullptr;
        // ---- OPT-IN full resident megakernel (section 92, option B) ----
        // launch_full does all 7 stages (gather+QKV+normalize+scores+softmax+attnV+
        // outproj+residual+publish) in ONE dispatch, one subgroup per window, Q/K/V/scores/
        // probs/context never leaving SLM. This is the only construction that removes BOTH
        // remaining walls (strided publish + gate-activation fusion). The bisect proved the
        // single-subgroup-owns-a-window shape sidesteps the ESIMD multi-subgroup crash.
        // Gated behind NR_FULL_MEGA because it is UNTESTED on a healthy device (the bisect
        // crashes polluted the GPU); the 712ms split path below stays the default. Only the
        // plain (non-pooling, non-head) form is covered; others fall through to split.
        // ---- OPT-IN resident megakernel (section 93, the DESIGN path) ----
        // launch_resident is the standard-SYCL transcription of window_block.comp: ONE
        // workgroup (256 thr / 8 subgroups) per 8x8 window, all 7 stages in one dispatch,
        // Q/K/V/probs/context never leave SLM. This is the structure the coopmat chain's
        // ~45ms rests on (its gemm ceiling is only 24.8 TOPS -- the fusion, not the算力).
        // bench_jmf proved the keystone (joint_matrix+local_accessor+group_barrier, cross-
        // subgroup 0/4096 wrong); bench_jmt proved the throughput gate. Uses the EXACT
        // cr_*/qr_* primitives the split passes use (already 100% bit-exact vs the golden).
        // ---- wbv2: fused window_block as ONE ESIMD workgroup, dpas tiles + per-window
        // GLOBAL scratch + group_barrier (section 96/97). NOW THE DEFAULT (section 97):
        // proven 100.0000% bit-exact end-to-end on the RECORDED walk (real captured frame,
        // buffer 1301) AND wins ~26ms async vs split (434 vs 460). Escape hatch:
        // NR_WB_SPLIT=1 forces the old split path. The joint-resident (NR_RESIDENT_WB) and
        // mega (NR_FULL_MEGA) oracle paths must still win when explicitly requested, so v2
        // only takes over when none of those opt-ins is set.
        // SECTION 99 DEMOTION (the user's violation audit): the v2 fusion makes every
        // window gemm an M=64 INDEPENDENT dispatch = the R8a small-M wall the plan forbids.
        // The split path tiles the SAME math as ONE wide gemm over rows=windows*64=130560
        // (M>=8160 = the healthy form, width-sweep 1.3-3.5x). v2 stays proven (NR_WB_V2=1,
        // 100% bit-exact) as the ESIMD+dpas mechanism witness for shapes that cannot go
        // wide; it is NOT the shipping route. Default = split wide-M.
        // SECTION 99 v3: v2's fused window_block with the per-window scratch in SLM
        // (45KB lifetime-aliased map, 64KB IGC cap proven by bench_slm128) -- the §2
        // rule-2 GLOBAL round-trip is GONE. NR_WB_V3=1; same stage-dump judges as v2.
        // section 100 P1 v4: the senior's stage discipline on our untouched operator
        // (bench_v4full 9662c40: seven regions bit-exact vs v3, FULL 2.12x). PROMOTED
        // to the default for the plain form (same-heat A/B 3 rounds: v4 wins EVERY
        // pair by 6-11ms; end-to-end 100.0000%% x2). Escape hatches: NR_WB_V3=1 /
        // NR_WB_SPLIT=1 restore v3 / the split chain. pool/head keep their fused legs.
        if (!getenv("NR_WB_SPLIT") && !getenv("NR_WB_V3") && !getenv("NR_RESIDENT_WB")
            && !getenv("NR_FULL_MEGA") && !pooling && !head) {
            g_wb_v2++;
            unsigned st = getenv("NR_V2_STOP") ? (unsigned)atoi(getenv("NR_V2_STOP")) : 0u;
            if (st == 65531u) return;
            if (st == 65530u) return;
            sycl::half* dWq = cached_pack_b_f16(qkv, Wraw, (int)C, (int)NH);
            sycl::half* dWp = cached_pack_b_f16(projection, Praw, (int)C, (int)C);
            sycl::half* dKV = nullptr;
            if (st && st < 0xFF00u) dKV = (sycl::half*)pool_get((size_t)windows * 4096u * 2);
            wbv4::launch_v4full(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                                dWq, dWp, narrow ? (sycl::half*)Tgt : nullptr,
                                narrow ? nullptr : (float*)Tgt, Bp, cp, qs,
                                windows, height, width, across, top, left, epi, narrow, st, dKV);
            if (dKV) pool_put(dKV);
            return;
        }
        // section 100 P1 v4ph route (POOL): separate kernel, the senior's fold outlet.
        // HEAD stays on the A2 legs (the resident-head open item: on-chip P6 outproj
        // is f32-EXACT vs the non-fused f16v1 wide-M (0/16.7M), but the A2 FUSED leg3
        // (f16v3 gemm_resid_pub) is the shipping comparison -- its total witness vs the
        // v4ph total witness localizes the 4-Tgt-slot ULP question. NR_DUMP_PL rides
        // both sides' witnesses.)
        static bool v4pool_on = getenv("NR_WB_V4_NO_POOL") ? atoi(getenv("NR_WB_V4_NO_POOL")) == 0 : true;
        static bool v4head_on = getenv("NR_WB_V4_NO_HEAD") ? atoi(getenv("NR_WB_V4_NO_HEAD")) == 0 : true;
        if ((v4pool_on || (v4head_on && head)) && (pooling || head) && !(pooling && head)
            && !getenv("NR_WB_SPLIT") && !getenv("NR_WB_V3")
            && !getenv("NR_RESIDENT_WB") && !getenv("NR_FULL_MEGA")) {
            g_wb_v2++;
            unsigned st = getenv("NR_V2_STOP") ? (unsigned)atoi(getenv("NR_V2_STOP")) : 0u;
            if (st == 65531u || st == 65530u) return;
            sycl::half* dWq = cached_pack_b_f16(qkv, Wraw, (int)C, (int)NH);
            sycl::half* dWp = cached_pack_b_f16(projection, Praw, (int)C, (int)C);
            sycl::half* dWh = head ? cached_pack_b_f16(pooled, HeadW, (int)C, 16) : nullptr;
            sycl::half* dKV = nullptr;
            if (st && st < 0xFF00u) dKV = (sycl::half*)pool_get((size_t)windows * 4096u * 2);
            float* dTD = (getenv("NR_DUMP_PL")) ? (float*)pool_get((size_t)windows * 64u * C * 4) : nullptr;
            if (dTD) GQ->memset(dTD, 0, (size_t)windows * 64u * C * 4);
            size_t pfsz = (st == 9u) ? (size_t)windows * 2048u : (st == 13u ? (size_t)windows * 64u * 96u : 0u);
            float* dPF = (pfsz && getenv("NR_DUMP_PROJF")) ? (float*)pool_get(pfsz * 4) : nullptr;
            if (dPF) GQ->memset(dPF, 0, pfsz * 4);
            wbv4ph::launch_v4ph(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                                dWq, dWp, (sycl::half*)Tgt,
                                narrow ? nullptr : (float*)Tgt, Bp, cp, qs,
                                windows, height, width, across, top, left, epi, narrow, st, dKV,
                                pooling, head, Pl, dWh, nullptr, dPF, dTD);
            if (dPF) {
                std::vector<float> h(pfsz);
                GQ->memcpy(h.data(), dPF, h.size() * 4).wait();
                static int pf_n = 0; ++pf_n;
                char fn[64]; snprintf(fn, sizeof fn, "projf_v4ph_%d.bin", pf_n);
                FILE* fp = fopen(fn, "wb"); fwrite(h.data(), 4, h.size(), fp); fclose(fp);
                printf("[dump] projf v4ph #%d %zu floats\n", pf_n, h.size());
                pool_put(dPF);
            }
            if (dTD) {
                std::vector<float> h((size_t)windows * 64u * C);
                GQ->memcpy(h.data(), dTD, h.size() * 4).wait();
                static int td_n = 0; ++td_n;
                char fn[64]; snprintf(fn, sizeof fn, "total_v4ph_%d.bin", td_n);
                FILE* fp = fopen(fn, "wb"); fwrite(h.data(), 4, h.size(), fp); fclose(fp);
                printf("[dump] total v4ph #%d %zu floats\n", td_n, h.size());
                std::vector<sycl::half> ht((size_t)height * width * C);
                GQ->memcpy(ht.data(), (sycl::half*)Tgt, ht.size() * 2).wait();
                snprintf(fn, sizeof fn, "tgt_v4ph_%d.bin", td_n);
                fp = fopen(fn, "wb"); fwrite(ht.data(), 2, ht.size(), fp); fclose(fp);
                printf("[dump] Tgt v4ph #%d %zu halves\n", td_n, ht.size());
                pool_put(dTD);
            }
            if (dKV) pool_put(dKV);
            return;
        }
        if (getenv("NR_WB_V3") && !getenv("NR_RESIDENT_WB") && !getenv("NR_FULL_MEGA")
            && !pooling && !head) {
            g_wb_v2++;
            unsigned st = getenv("NR_V2_STOP") ? (unsigned)atoi(getenv("NR_V2_STOP")) : 0u;
            if (st == 65531u) return;
            if (st == 65530u) { static bool once3=false; if(!once3){once3=true; printf("[wb-flags] epi=%u narrow=%d pooling=%d head=%d\n", epi, (int)narrow, (int)pooling, (int)head);} return; }
            sycl::half* dWq = cached_pack_b_f16(qkv, Wraw, (int)C, (int)NH);
            sycl::half* dWp = cached_pack_b_f16(projection, Praw, (int)C, (int)C);
            sycl::half* dKV = nullptr;
            if (st && st < 0xFF00u) { dKV = (sycl::half*)pool_get((size_t)windows * 4096u * 2);
                      GQ->parallel_for(sycl::range((size_t)windows*4096u), [=](sycl::item<1> it){ dKV[(size_t)it.get_id(0)]=sycl::half(0.f); }); }
            if (st == 65532u) return;   // floor probe: no launch
            wbv3::launch_v3(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                            dWq, dWp, narrow ? (sycl::half*)Tgt : nullptr,
                            narrow ? nullptr : (float*)Tgt, Bp, cp, qs,
                            windows, height, width, across, top, left, epi, narrow, st, dKV);
            if (dKV) pool_put(dKV);
            return;
        }
        if (getenv("NR_WB_V2") && !getenv("NR_RESIDENT_WB") && !getenv("NR_FULL_MEGA")
            && !pooling && !head) {
            g_wb_v2++;
            unsigned st = getenv("NR_V2_STOP") ? (unsigned)atoi(getenv("NR_V2_STOP")) : 0u;
            if (st == 65531u) return;   // ABSOLUTE floor: closure does NOTHING (no pack, no pool, no launch)
            if (st == 65530u) { static bool once=false; if(!once){once=true; printf("[wb-flags] epi=%u narrow=%d pooling=%d head=%d\n", epi, (int)narrow, (int)pooling, (int)head);} return; }
            static bool s_v2brk = getenv("NR_V2_BREAKDOWN") != nullptr;
            auto bT0 = std::chrono::steady_clock::now();
            sycl::half* dWq = cached_pack_b_f16(qkv, Wraw, (int)C, (int)NH);
            sycl::half* dWp = cached_pack_b_f16(projection, Praw, (int)C, (int)C);
            auto bT1 = std::chrono::steady_clock::now();
            sycl::half* dWS = (st == 0xFFFFu) ? nullptr
                            : (sycl::half*)pool_get((size_t)windows * wbv2::WSL * 2);
            auto bT2 = std::chrono::steady_clock::now();
            // NO zero-fill by default (section 97): every phase writes its slice before
            // anyone reads it -- verified: NR_V2_FILL=0 keeps the fused 4-run check at
            // 100.0000% bit-exact AND saves ~10ms/walk; NR_V2_FILL=1 restores the
            // deterministic fresh-zero behavior for debugging.
            if (getenv("NR_V2_FILL") && st != 0xFFFFu)
                GQ->parallel_for(sycl::range((size_t)windows * wbv2::WSL), [=](sycl::item<1> it){
                    dWS[(size_t)it.get_id(0)] = sycl::half(0.f); });
            sycl::half* dKV = nullptr;
            if (st && st < 0xFF00u) { dKV = (sycl::half*)pool_get((size_t)windows * 4096u * 2);
                      GQ->parallel_for(sycl::range((size_t)windows*4096u), [=](sycl::item<1> it){ dKV[(size_t)it.get_id(0)]=sycl::half(0.f); }); }
            if (st == 65532u) { if (dWS) pool_put(dWS); return; }   // floor probe: NO launch at all
            wbv2::launch_v2(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                            dWq, dWp, narrow ? (sycl::half*)Tgt : nullptr,
                            narrow ? nullptr : (float*)Tgt, Bp, cp, qs, dWS,
                            windows, height, width, across, top, left, epi, narrow, st, dKV);
            auto bT3 = std::chrono::steady_clock::now();
            if (s_v2brk) {
                static double accP=0,accG=0,accL=0; static int cnt=0;
                double dp=std::chrono::duration<double,std::milli>(bT1-bT0).count();
                double dg=std::chrono::duration<double,std::milli>(bT2-bT1).count();
                double dl=std::chrono::duration<double,std::milli>(bT3-bT2).count();
                accP+=dp; accG+=dg; accL+=dl; ++cnt;
                if (cnt<=3 || cnt%20==0) std::printf("[v2brk #%d] pack=%.2f pool=%.2f launch=%.2f ms\n",cnt,dp,dg,dl);
                std::fflush(stdout);
            }
            if (st && st < 0xFF00u) {
                static bool s_v2done = false;
                if (!s_v2done) {
                    s_v2done = true;
                    GQ->wait();
                    std::vector<sycl::half> hkv((size_t)windows * 4096u);
                    ev_sync(GQ->memcpy(hkv.data(), dKV, hkv.size() * 2));
                    FILE* fp = fopen("v2_dump.bin", "wb");
                    fwrite(hkv.data(), 2, hkv.size(), fp); fclose(fp);
                    printf("[dump] v2 flat %zu (stop=%u)\n", hkv.size(), st);
                }
                pool_put(dKV);
            }
            if (dWS) pool_put(dWS);
            return;
        }
        g_wb_split++;
        if (g_wb_v2+g_wb_split == 55 || (g_wb_v2+g_wb_split)%40==1)
            std::printf("[wb-route] v2-hits=%ld split-path-hits=%ld\n", g_wb_v2.load(), g_wb_split.load());
        // Needs the RAW row-major weights (Wraw 32x96, Praw 32x32), not packed. Plain form
        // only (non-pooling, non-head). Gated behind NR_RESIDENT_WB; the fused 4-run check
        // against the coopmat golden is the judge.
        if (getenv("NR_RESIDENT_WB") && !pooling && !head) {
            if (getenv("NR_RESIDENT_STOP")) {
                static bool s_rdone = false;
                if (s_rdone) return;
                s_rdone = true;
                unsigned st = (unsigned)atoi(getenv("NR_RESIDENT_STOP"));
                sycl::half* dKV = (sycl::half*)pool_get((size_t)windows * 4096u * 2);
                wbres::launch_resident(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                                       Wraw, Praw, Tgt, Bp, cp, qs,
                                       windows, height, width, across, top, left, epi, narrow, st, dKV);
                GQ->wait();
                std::vector<sycl::half> hkv((size_t)windows * 4096u);
                ev_sync(GQ->memcpy(hkv.data(), dKV, hkv.size() * 2));
                FILE* fp = fopen("resident_dump.bin", "wb");
                fwrite(hkv.data(), 2, hkv.size(), fp); fclose(fp);
                printf("[dump] resident flat %zu (stop=%u)\n", hkv.size(), st);
                pool_put(dKV);
                return;
            }
            wbres::launch_resident(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                                   Wraw, Praw, Tgt, Bp, cp, qs,
                                   windows, height, width, across, top, left, epi, narrow);
            return;
        }
        if (getenv("NR_FULL_MEGA") && !pooling && !head) {
            sycl::half* dWq = cached_pack_b_f16(qkv, Wraw, (int)C, (int)NH);
            sycl::half* dWp = cached_pack_b_f16(projection, Praw, (int)C, (int)C);
            if (getenv("NR_MEGA_STOP")) {   // stage-localization for the mega kernel (same dump shape as the joint resident: window*4096 stride, flat file)
                static bool s_mdone = false;
                if (s_mdone) return;
                s_mdone = true;
                unsigned st = (unsigned)atoi(getenv("NR_MEGA_STOP"));
                sycl::half* dKV = (sycl::half*)pool_get((size_t)windows * 4096u * 2);
                wbmega::launch_full(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                                    dWq, dWp, narrow ? (sycl::half*)Tgt : nullptr,
                                    narrow ? nullptr : (float*)Tgt, Bp, cp, qs,
                                    windows, height, width, across, top, left, epi, narrow, st, dKV);
                GQ->wait();
                std::vector<sycl::half> hkv((size_t)windows * 4096u);
                ev_sync(GQ->memcpy(hkv.data(), dKV, hkv.size() * 2));
                FILE* fp = fopen("mega_dump.bin", "wb");
                fwrite(hkv.data(), 2, hkv.size(), fp); fclose(fp);
                printf("[dump] mega flat %zu (stop=%u)\n", hkv.size(), st);
                pool_put(dKV);
                return;
            }
            wbmega::launch_full(*GQ, image_half ? (const void*)ImgH : (const void*)ImgF, image_half,
                                dWq, dWp, narrow ? (sycl::half*)Tgt : nullptr,
                                narrow ? nullptr : (float*)Tgt, Bp, cp, qs,
                                windows, height, width, across, top, left, epi, narrow);
            return;
        }
        // NR_WB_STOP=N (section 99 leg attribution, launch-guard form): the pool
        // get/put sequence stays IDENTICAL to the full path (no early returns --
        // early returns changed pool state and made LATER closures miss the pool,
        // which is what inflated the old deltas). Only the launches are guarded.
        static const unsigned wbstop = getenv("NR_WB_STOP") ? (unsigned)atoi(getenv("NR_WB_STOP")) : 99u;
        static bool wbplaingather = getenv("NR_WB_PLAINLEG") != nullptr;   // gather/merge/leg3 vector switch
        // ---- LEG 1: gather + gemm + qkv_epilogue -> dQ,dK,dV (device scratch) ----
        // NOTE (section 92): a fused megakernel for this LEG (window_block_mega.hpp,
        // proven bit-exact by gate_mega.cpp) was tried and is NOT faster -- the split
        // f16v1::gemm tiles Mp x 96 across many workgroups (high occupancy) while the
        // one-subgroup-per-row mega underfills. Kept the split path; the mega file stays
        // as groundwork for a FULL window_block fusion (LEG1+2+3 in one workgroup, the
        // shipped g.rblock shape) which is the only version that can win.
        sycl::half* dA = (sycl::half*)pool_get((size_t)rows * C * 2);
        if (wbstop > 0u) {
        if (!wbplaingather && C == 32u) {
            // section 99: 32-wide ESIMD gather (image row + dA row both contiguous;
            // e4m3_vec<32> bit-exact vs qr_e4m3 scalar, bench_e4m3vec 0/4096).
            GQ->parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                namespace esimd = sycl::ext::intel::esimd;
                unsigned r = (unsigned)it.get_id(0);
                unsigned window = r / tokens, token = r % tokens;
                int y = (int)((window / across) * 8u + token / 8u) - (int)top;
                int x = (int)((window % across) * 8u + token % 8u) - (int)left;
                esimd::simd<sycl::half,32> out;
                if (y < 0 || x < 0 || y >= (int)height || x >= (int)width) {
                    out = esimd::simd<sycl::half,32>(sycl::half(0.f));
                } else {
                    size_t at = ((size_t)y * width + x) * C;
                    esimd::simd<float,32> v;
                    if (image_half) v = esimd::convert<float>(esimd::block_load<sycl::half,32>(
                        (const sycl::half*)ImgH + at, esimd::overaligned_tag<16>{}));
                    else v = esimd::block_load<float,32>((const float*)ImgF + at,
                        esimd::overaligned_tag<16>{});
                    out = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(v));
                }
                esimd::block_store<sycl::half,32>(dA + (size_t)r * C, out, esimd::overaligned_tag<16>{});
            });
        } else
        GQ->parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            unsigned window = r / tokens, token = r % tokens;
            int y = (int)((window / across) * 8u + token / 8u) - (int)top;
            int x = (int)((window % across) * 8u + token % 8u) - (int)left;
            if (y < 0 || x < 0 || y >= (int)height || x >= (int)width) {
                for (unsigned c = 0; c < C; ++c) dA[(size_t)r * C + c] = sycl::half(0.f);
                return;
            }
            size_t at = ((size_t)y * width + x) * C;
            for (unsigned c = 0; c < C; ++c) {
                float val = image_half ? (float)ImgH[at + c] : ImgF[at + c];
                val = qr_e4m3(val);                                   // publish_image always
                dA[(size_t)r * C + c] = sycl::half(val);
            }
        });
        }
        sycl::half* dAp = (sycl::half*)pool_get((size_t)Mp * C * 2);
        float* dCq = (float*)pool_get((size_t)Mp * NH * 4);
        if (wbstop > 1u) packdev::pack_a16(*GQ, dA, dAp, (int)rows, Mp, (int)C);
        if (getenv("NR_DUMP_AP")) {   // pack_a16 output for comparison vs v2 AQO
            static bool s_apdone = false;
            if (!s_apdone && !pooling && !head) {
                s_apdone = true;
                std::vector<sycl::half> hap((size_t)Mp * C);
                ev_sync(GQ->memcpy(hap.data(), dAp, hap.size() * 2));
                FILE* fp = fopen("split_ap.bin", "wb");
                fwrite(hap.data(), 2, hap.size(), fp); fclose(fp);
                printf("[dump] split dAp %zu (Mp=%u C=%u)\n", hap.size(), Mp, C);
            }
        }
        sycl::half* dBp = cached_pack_b_f16(qkv, Wraw, (int)C, (int)NH);   // weight: pack once
        if (wbstop > 2u) f16v1::gemm(*GQ, dAp, dBp, dCq, Mp, (int)NH, (int)C);
        if (getenv("NR_DUMP_RAW")) {   // dump split RAW gemm acc (dCq) BEFORE normalize, to compare vs resident stop=2
            static bool s_rawdone = false;
            if (!s_rawdone && !pooling && !head) {
                s_rawdone = true;
                std::vector<float> hraw((size_t)rows * NH);
                ev_sync(GQ->memcpy(hraw.data(), dCq, hraw.size() * 4));
                FILE* fp = fopen("split_raw.bin", "wb");
                fwrite(hraw.data(), 4, hraw.size(), fp); fclose(fp);
                printf("[dump] split raw dCq %zu (rows=%u NH=%u)\n", hraw.size(), rows, NH);
            }
        }
        pool_put(dA);
        pool_put(dAp);
        sycl::half* dQ = (sycl::half*)pool_get((size_t)rows * C * 2);
        sycl::half* dK = (sycl::half*)pool_get((size_t)rows * C * 2);
        sycl::half* dV = (sycl::half*)pool_get((size_t)rows * C * 2);
        // DERIVED + MEASURED (section 92): the scalar one-work-item-per-row epilogue ran
        // 4.03ms/call at the real shape (134400 rows x ~150-op serial chain, 0.4% of
        // A770). wbmega::normalize_esimd is the .comp's 4-lane butterfly (all lanes
        // active, log-depth reduce through SLM -- ESIMD has no shuffle) at 0.94ms: 4.3x
        // faster AND bit-exact (bench_wb 4300800/4300800 vs the scalar epilogue). This is
        // the first change the FLOPs/TOPS derivation pointed at that actually pays.
        if (wbstop > 3u) wbmega::normalize_esimd(*GQ, dCq, dQ, dK, dV, qs, rows, NH, C);
        pool_put(dCq);
        if (getenv("NR_DUMP_KV")) {   // stage-localization: dump split K/V for comparison vs resident
            static bool s_done = false;
            if (!s_done && !pooling && !head) {
            s_done = true;
            std::vector<sycl::half> hk((size_t)rows * C), hv((size_t)rows * C), hq((size_t)rows * C);
            ev_sync(GQ->memcpy(hk.data(), dK, hk.size() * 2));
            ev_sync(GQ->memcpy(hv.data(), dV, hv.size() * 2));
            ev_sync(GQ->memcpy(hq.data(), dQ, hq.size() * 2));
            FILE* fp = fopen("split_kv.bin", "wb");
            fwrite(hk.data(), 2, hk.size(), fp); fwrite(hv.data(), 2, hv.size(), fp); fclose(fp);
            FILE* fq = fopen("split_q.bin", "wb");
            fwrite(hq.data(), 2, hq.size(), fq); fclose(fq);
            printf("[dump] split K/V/Q %zu elems each (windows=%u)\n", hk.size(), windows);
            }
        }
        // ---- LEG 2: window attention (heads==1) -> dAttended (windows,64,32) half ----
        float* dScores = (float*)pool_get((size_t)windows * 64u * 64u * 4);
        sycl::half* dProbs = (sycl::half*)pool_get((size_t)windows * 64u * 64u * 2);
        float* dCtx = (float*)pool_get((size_t)windows * 64u * 32u * 4);
        // batched device pack + batched gemm (section 92): the per-window host loop was
        // the same pathology window_attention had (4 sync memcpys + 4 malloc/free + 2
        // launches per window). dQ/dK/dV are already contiguous per window on device.
        sycl::half* dAq = (sycl::half*)pool_get((size_t)windows * 64u * 32u * 2);
        sycl::half* dBk = (sycl::half*)pool_get((size_t)windows * 32u * 64u * 2);
        sycl::half* dAp2 = (sycl::half*)pool_get((size_t)windows * 64u * 64u * 2);
        sycl::half* dBv = (sycl::half*)pool_get((size_t)windows * 64u * 32u * 2);
        if (wbstop > 4u) {
        packdev::pack_a16_b(*GQ, dQ, dAq, 64, 64, 32, (int)windows);
        packdev::pack_b16_t_b(*GQ, dK, dBk, 32, 64, (int)windows);
        f16v1::gemm_b(*GQ, dAq, dBk, dScores, 64, 64, 32, (int)windows);
        }
        if (getenv("NR_DUMP_SCORES")) {   // dump split scores (Q.K^T, no bias) for comparison vs resident stop=5
            static bool s_sdone = false;
            if (!s_sdone && !pooling && !head) {
                s_sdone = true;
                std::vector<float> hs((size_t)windows * 64u * 64u);
                ev_sync(GQ->memcpy(hs.data(), dScores, hs.size() * 4));
                FILE* fp = fopen("split_scores.bin", "wb");
                fwrite(hs.data(), 4, hs.size(), fp); fclose(fp);
                printf("[dump] split scores %zu (windows=%u)\n", hs.size(), windows);
            }
        }
        if (wbstop > 5u) {
        if (!smaxplain2()) smax_esimd(*GQ, dScores, dProbs, windows*64u, Bp, 1u);
        else
        GQ->parallel_for(sycl::range((size_t)windows*64u),
                         smax::softmax_kernel()(dScores, dProbs, windows*64u, 64u, Bp, 1u));
        }
        if (getenv("NR_DUMP_PROBS")) {   // dump split softmax probs (e4m3 halves) vs mega SCR
            static bool s_pdone = false;
            if (!s_pdone && !pooling && !head) {
                s_pdone = true;
                std::vector<sycl::half> hp((size_t)windows*64u*64u);
                ev_sync(GQ->memcpy(hp.data(), dProbs, hp.size()*2));
                FILE* fp=fopen("split_probs.bin","wb"); fwrite(hp.data(),2,hp.size(),fp); fclose(fp);
                printf("[dump] split probs %zu\n", hp.size());
            }
        }
        if (wbstop > 6u) {
        packdev::pack_a16_b(*GQ, dProbs, dAp2, 64, 64, 64, (int)windows);
        packdev::pack_b16_b(*GQ, dV, dBv, 64, 32, (int)windows);
        f16v1::gemm_b(*GQ, dAp2, dBv, dCtx, 64, 32, 64, (int)windows);
        }
        if (getenv("NR_DUMP_CTX")) {   // dump split attnV context for comparison vs resident stop=8
            static bool s_cdone = false;
            if (!s_cdone && !pooling && !head) {
                s_cdone = true;
                std::vector<float> hc((size_t)windows * 64u * 32u);
                ev_sync(GQ->memcpy(hc.data(), dCtx, hc.size() * 4));
                FILE* fp = fopen("split_ctx.bin", "wb");
                fwrite(hc.data(), 4, hc.size(), fp); fclose(fp);
                printf("[dump] split ctx %zu (windows=%u)\n", hc.size(), windows);
            }
        }
        pool_put(dAq); pool_put(dBk); pool_put(dAp2); pool_put(dBv);
        pool_put(dScores); pool_put(dProbs);
        sycl::half* dAttended = (sycl::half*)pool_get((size_t)rows * C * 2);
        if (wbstop > 7u)
        if (!wbplaingather && C == 32u) {   // section 99: 32-wide merge (both sides contiguous)
            GQ->parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                namespace esimd = sycl::ext::intel::esimd;
                unsigned token = (unsigned)it.get_id(0);
                esimd::simd<float,32> v = esimd::block_load<float,32>(
                    dCtx + (size_t)token * 32u, esimd::overaligned_tag<16>{});
                esimd::block_store<sycl::half,32>(dAttended + (size_t)token * 32u,
                    esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(v)), esimd::overaligned_tag<16>{});
            });
        } else
        GQ->parallel_for(sycl::range((size_t)rows * C), [=](sycl::item<1> it) {   // merge, heads==1
            unsigned index = (unsigned)it.get_id(0);
            unsigned c = index % C, token = index / C;
            dAttended[index] = sycl::half(qr_e4m3(dCtx[(size_t)token * 32u + c]));
        });
        if (getenv("NR_DUMP_ATT")) {   // dump split attended (e4m3 of ctx) for comparison vs resident stop=7
            static bool s_adone = false;
            if (!s_adone && !pooling && !head) {
                s_adone = true;
                std::vector<sycl::half> ha((size_t)rows * C);
                ev_sync(GQ->memcpy(ha.data(), dAttended, ha.size() * 2));
                FILE* fp = fopen("split_att.bin", "wb");
                fwrite(ha.data(), 2, ha.size(), fp); fclose(fp);
                printf("[dump] split attended %zu (windows=%u)\n", ha.size(), windows);
            }
        }
        pool_put(dCtx); pool_put(dQ); pool_put(dK); pool_put(dV);
        // ---- LEG 3: window residual (attended, projection, image, cosine -> target) ----
        // device pack (section 92): dAttended and Praw are already on device -- pack them
        // in place, no download/upload round-trip (the host pack was the remaining cost).
        sycl::half* dAp3 = (sycl::half*)pool_get((size_t)Mp * C * 2);
        float* dC3 = (float*)pool_get((size_t)Mp * C * 4);
        sycl::half* dBp3 = cached_pack_b_f16(projection, Praw, (int)C, (int)C);   // weight: pack once (host cache, no launch)
        // SECTION 99 LEG-3 FUSION: outproj gemm + residual + publish in ONE kernel
        // (f16v3::gemm_resid_pub) -- the 16.7MB dC3 f32 scratch and the separate
        // residual launch both disappear. NR_WB_FUSE=0 escapes to the two-pass path.
        // SECTION 100 A1: the POOL and HEAD forms ride the SAME fused kernel with
        // their proven outlets (the scalar leg's stores reproduced bit-for-bit):
        //   head: dOut16 = half(total) == narrow epi=0 outlet; Tgt stays with leg4.
        //   pool: target = half(e4m3(total)) (pool_outlet), Stage = the raw total at
        //     the BLOCK index r*C+c == the scalar leg's dStage write; the independent
        //     pool pass reads it unchanged. The all-or-none crop guarantee (even
        //     extents/pads, libxmx.c:2648 -- the guard we already enforce) means
        //     every tap the pool reads was written by leg3: the fused Stage write
        //     sits under the SAME per-token guard as the scalar one.
        static bool wbfuse = getenv("NR_WB_FUSE") ? atoi(getenv("NR_WB_FUSE")) != 0 : true;
        static bool wbphfuse = getenv("NR_WB_FUSE_PH") ? atoi(getenv("NR_WB_FUSE_PH")) != 0 : true;  // A/B + revert hatch for the A1 inclusion
        const bool fused3 = wbfuse && C == 32u && wbstop > 8u &&
                            (pooling || head ? wbphfuse : true) &&
                            !(pooling && head) &&
                            (pooling || head || epi == 0u || epi == 1u || epi == 4u);
        // A2: the fused pool path closes the pool IN the kernel -- no Stage buffer at
        // all; the scalar path keeps the dStage + independent pool pass contract.
        float* dStage = (pooling && !fused3) ? (float*)pool_get((size_t)rows * C * 4) : nullptr;
        sycl::half* dOut16 = head ? (sycl::half*)pool_get(img_elems * 2) : nullptr;
        float* dStgW = (pooling && getenv("NR_DUMP_PL"))
                     ? (float*)pool_get((size_t)rows * C * 4) : nullptr;   // the raw-total
        if (fused3) {
            if ((pooling || head) && g_wbf3_poolhead < 8u) {
                g_wbf3_poolhead++;
                std::printf("[wb-fuse3] %s form on the fused leg (epi=%u image_half=%d)\n",
                            pooling ? "pool" : "head", epi, (int)image_half);
            }
            // section 100 D1 (engine-internal bisect of the 43.5ms leg3):
            //   NR_WB_STOP=85 -> pack_a16 only (gemm_resid_pub skipped)
            //   NR_WB_STOP=86 -> neither (leg3 empty inside the fused route)
            // pub cost = (99 - 85), pack cost = (85 - 86). launch-guard form: the
            // pool/head/leg4 tails still run on whatever dOut16/dStage hold (garbage
            // values, no frame judge -- this stop exists for the TIME ledger only).
            if (wbstop == 86u) { /* leg3 empty */ }
            else {
            packdev::pack_a16(*GQ, dAttended, dAp3, (int)rows, Mp, (int)C);
            if (wbstop != 85u) {
            if (wbstop == 87u) {
                // section 100 D2 probe: the fused kernel with tail=false -- every
                // accumulator row stored RAW as f32 into dC3 (the old scratch, right
                // size), no image read / FMA / e4m3. (99-87) = the GEMM body + pack +
                // the f32 store; (87-85) isolates the tail arithmetic + image read.
                // Diagnostic stop only -- the frame head is garbage by design here.
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3, nullptr, dC3, false,
                    cp, nullptr, dC3, false,
                    (int)rows, Mp, (int)C, height, width, across, top, left, 0u,
                    nullptr, false, nullptr, false);
            }
            else if (wbstop == 98u) {
                // section 100 D7 probe: the FULL tail (image read + FMA + e4m3 +
                // publish arithmetic) but the store goes CONTIGUOUS into dC3 (f32)
                // instead of the scattered image slot. (98-87) = pure arithmetic +
                // image read; (99-98) = the scatter store's price alone.
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, nullptr, dC3, false,
                    (int)rows, Mp, (int)C, height, width, across, top, left, epi,
                    nullptr, false, nullptr, true, false, 0, true);
            }
            else if (wbstop == 97u) {
                // section 100 D8 probe (one variable vs 98): CONTIGUOUS half stores
                // into an IMAGE-SIZED scratch (height*width*32 half, the same 33MB
                // footprint class as the real target) instead of the 16.7MB dC3.
                // If 97 ~ 98 -> the price is the SCATTER pattern; if 97 ~ 99 -> it
                // is writing a cold image-sized buffer, pattern irrelevant.
                sycl::half* dBig = (sycl::half*)pool_get((size_t)height * width * C * 2);
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, dBig, nullptr, true,
                    (int)rows, Mp, (int)C, height, width, across, top, left, epi,
                    nullptr, false, nullptr, true, false, 0, true);
                pool_put(dBig);
            }
            else if (wbstop == 95u) {
                // section 100 D10 probe (completes the 2x2): CONTIGUOUS stores into
                // the REAL plan target (same buffer as stop=99, same full tail), the
                // only variable vs 99 is the address ORDER and vs 98 the buffer
                // IDENTITY. {scatter,contig} x {pool,plan}: three cells measured --
                // scatter->pool 189.3, contig->pool 189.3, scatter->plan 228.5. If
                // contig->plan ~ 189 -> the cost is the scatter ORDER hitting THIS
                // buffer (interleave with its other readers?); if ~228 -> the buffer
                // itself makes every write slow regardless of order.
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, narrow ? (sycl::half*)Tgt : nullptr, narrow ? nullptr : (float*)Tgt,
                    narrow, (int)rows, Mp, (int)C, height, width, across, top, left, epi,
                    nullptr, false, nullptr, true, false, 0, true);
            }
            else if (wbstop == 96u) {
                // section 100 D9 probe (one variable vs 99 AND vs 97): the REAL
                // scatter index (at = image slot) but into a device-local pool
                // buffer sized like the image. vs 99: only the TARGET BUFFER
                // changes (plan buffer -> pool); vs 97: only the ADDRESS PATTERN
                // changes (contig -> scatter). If 96 ~ 97 -> the plan target buffer
                // has a property the pool lacks (host-visible?); if 96 ~ 99 -> the
                // scatter pattern itself is the cost.
                sycl::half* dBig = (sycl::half*)pool_get((size_t)height * width * C * 2);
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, dBig, nullptr, true,
                    (int)rows, Mp, (int)C, height, width, across, top, left, epi);
                pool_put(dBig);
            }
            else if ((wbstop == 94u || wbstop == 91u) && g_probe33) {                // section 100 D14/D15: the fused leg3 writes the PREALLOCATED
                // standalone buffer (init-time, never in g_bufs). 94: writer side
                // only (ffn_merge still reads the untouched plan buffer) -- the
                // discriminator "early allocation + unregistered" vs 96's "run-time
                // pool". 91: BOTH sides aliased (ffn_merge's Skp points at the same
                // probe buffer; 1265 leaves the frame entirely) -- the fix candidate:
                // if the 40ms is a property of the hand-off THROUGH 1265, aliasing
                // writer+reader to one buffer kills it while keeping the byte stream
                // (frame garbage by design -- ledger probe only).
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, narrow ? (sycl::half*)g_probe33 : nullptr,
                    narrow ? nullptr : (float*)g_probe33,
                    narrow, (int)rows, Mp, (int)C, height, width, across, top, left, epi);
            }
            else if (head)
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, dOut16, nullptr, true,
                    (int)rows, Mp, (int)C, height, width, across, top, left, 0u);
            else if (pooling)
                f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                    image_half ? (const sycl::half*)ImgH : nullptr,
                    image_half ? nullptr : ImgF, image_half,
                    cp, (sycl::half*)Tgt, nullptr, true,
                    (int)rows, Mp, (int)C, height, width, across, top, left, 0u,
                    dStgW, true, Pl);   // A2 pool; NR_DUMP_PL rides the Stage witness
            else {
                // section 100 D12 (the 40ms fix): the sync-closure ledger says the
                // leg3 kernel itself costs the SAME whether it writes the plan
                // target or a pool buffer (63 vs 60ms per-closure) -- the 38.5ms
                // async gap is the driver's cache DRAIN between our writer and the
                // downstream FFN_MERGE reader of the same plan buffer. Cure: write
                // a POOL staging buffer (no downstream reader -> no drain), then ONE
                // device->device memcpy into the target -- the DMA copy op is the
                // driver's coherence path and does not pay the compute-to-compute
                // flush. Health check: all-device, zero CPU, raw f16/f32 bytes, no
                // quantization -- a 33MB staging costs ~0.2ms at 300GB/s against
                // the 38.5 it removes. NR_LEG3_STG=0 reverts.
                // the 33MB staging + memcpy is a PURE EXTRA cost: the same-heat A/B
                // says it is speed-NEUTRAL (228 both ways), and the sync-closure
                // ledger shows writing the plan target is NOT slow per-closure (99 vs
                // 96 = 63 vs 60) -- 96's async "win" was the illusion of a target with
                // no downstream reader. Default OFF (kept as the mechanism witness).
                static bool leg3stg = getenv("NR_LEG3_STG") ? atoi(getenv("NR_LEG3_STG")) != 0 : false;
                if (leg3stg) {
                    const size_t wsz2 = narrow ? 2u : 4u;
                    sycl::half* dStg = (sycl::half*)pool_get(img_elems * wsz2);
                    // the crop-skipped slots keep the target's original value in the
                    // direct form -- and the plan target is written ONLY by this pass
                    // (the plan census: 1265 has one writer), so those slots are the
                    // zero the create left behind. Zero the staging to match exactly.
                    GQ->memset(dStg, 0, img_elems * wsz2);
                    f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                        image_half ? (const sycl::half*)ImgH : nullptr,
                        image_half ? nullptr : ImgF, image_half,
                        cp, narrow ? dStg : nullptr, narrow ? nullptr : (float*)dStg,
                        narrow, (int)rows, Mp, (int)C, height, width, across, top, left, epi);
                    GQ->memcpy(Tgt, dStg, img_elems * wsz2);
                    pool_put(dStg);
                } else
                    f16v3::gemm_resid_pub(*GQ, dAp3, dBp3,
                        image_half ? (const sycl::half*)ImgH : nullptr,
                        image_half ? nullptr : ImgF, image_half,
                        cp, narrow ? (sycl::half*)Tgt : nullptr, narrow ? nullptr : (float*)Tgt,
                        narrow, (int)rows, Mp, (int)C, height, width, across, top, left, epi);
            }
            }   // wbstop != 85u
            }   // wbstop != 86u
        } else if (wbstop > 8u) {
        packdev::pack_a16(*GQ, dAttended, dAp3, (int)rows, Mp, (int)C);
        f16v1::gemm(*GQ, dAp3, dBp3, dC3, Mp, (int)C, (int)C);
        }
        if (getenv("NR_DUMP_C3")) {   // dump split outproj dC3 for comparison vs resident stop=9
            static bool s_d3done = false;
            if (!s_d3done && !head && (!pooling || getenv("NR_DUMP_C3_POOL"))) {
                s_d3done = true;
                std::vector<float> h3((size_t)rows * C);
                ev_sync(GQ->memcpy(h3.data(), dC3, h3.size() * 4));
                FILE* fp = fopen("split_c3.bin", "wb");
                fwrite(h3.data(), 4, h3.size(), fp); fclose(fp);
                printf("[dump] split c3 %zu (windows=%u)\n", h3.size(), windows);
            }
        }
        if (wbstop > 9u && !fused3) {
        static bool wbplainleg = getenv("NR_WB_PLAINLEG") != nullptr;   // escape hatch
        if (!wbplainleg && wb_leg3_esimd_ok(epi, pooling, head)) {
            wb_leg3_esimd(*GQ, image_half ? (const sycl::half*)ImgH : nullptr,
                          image_half ? nullptr : ImgF, image_half,
                          cp, dC3, Tgt, narrow, epi, rows, height, width,
                          across, top, left, C);
        } else
        GQ->parallel_for(sycl::range(blk_elems), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            unsigned r = (unsigned)(i / C), col = (unsigned)(i % C);
            unsigned window = r / 64u, token = r % 64u;
            unsigned y = (window / across) * 8u + token / 8u;
            unsigned x = (window % across) * 8u + token % 8u;
            if (y < top || x < left || y - top >= height || x - left >= width) return;
            size_t out = ((size_t)(y - top) * width + (x - left)) * C + col;
            float sk = image_half ? (float)ImgH[out] : ImgF[out];
            float total = sycl::fma(sk, cp[col], dC3[i]);
            if (head) {
                // the head form's leg3 output is the raw total as half (epi=0, narrow --
                // test_window_block.py:148-150 gemm_residual narrow=True), fed to leg4.
                dOut16[out] = sycl::half(total);
            } else if (pooling) {
                // skip_out (target) = e4m3(total) as half; the raw total goes to the stage
                // for the pool (gemm_staged.comp:346-353).
                ((sycl::half*)Tgt)[out] = sycl::half(qr_e4m3(total));
                dStage[i] = total;
            } else if (narrow) ((sycl::half*)Tgt)[out] = sycl::half(qr_publish(epi, total));
            else               ((float*)Tgt)[out] = qr_publish(epi, total);
        });
        }
        if (pooling && !fused3) {
            // the 2x2 pool (gemm_staged.comp:371-390): taps (token,token+8,token+1,token+9)
            // summed in that order (precise), *0.25, e4m3 -> half, into pooled at the
            // half-resolution image index. token = (pixel/4)*16 + (pixel%4)*2 over the
            // window's 16 pooled pixels.
            GQ->parallel_for(sycl::range((size_t)windows * 16u * C), [=](sycl::item<1> it) {
                size_t e = it.get_id(0);
                unsigned pixel = (unsigned)((e / C) % 16u), c = (unsigned)(e % C);   // pixel WITHIN the window (flat range spans windows)
                unsigned window = (unsigned)(e / (16u * C));
                unsigned token = (pixel / 4u) * 16u + (pixel % 4u) * 2u;
                unsigned y = (window / across) * 8u + token / 8u;
                unsigned x = (window % across) * 8u + token % 8u;
                if (y < top || x < left || y - top >= height || x - left >= width) return;
                size_t base = (size_t)window * 64u * C;
                float total = cr_add(cr_add(cr_add(dStage[base + (size_t)token * C + c],
                                                   dStage[base + (size_t)(token + 8u) * C + c]),
                                            dStage[base + (size_t)(token + 1u) * C + c]),
                                     dStage[base + (size_t)(token + 9u) * C + c]);
                size_t out = ((size_t)((y - top) / 2u) * (width / 2u) + ((x - left) / 2u)) * C + c;
                Pl[out] = sycl::half(qr_e4m3(cr_mul(total, 0.25f)));
            });
            pool_put(dStage);
        }
        if (head) {
            // LEG 4: the compact head GEMM (test_window_block.py:151-152). out16 (pixels x
            // 32 half) @ head weights (32 x 16 half) -> f32; store only the first four
            // columns (compact_output, xmxres gemm leading=(0,0,4)) into the float32 target.
            // SECTION 98: converted to DEVICE packs (packdev::pack_a16 pads rows >= pixels
            // with zero exactly like the old host hOpad memset; cached_pack_b_f16 == the
            // device twin of f16v1::pack_b, the same pair the split LEG1 uses at :2645).
            // The old host download->pack->upload round-trip recorded memcpy nodes with
            // HOST-vector pointers (hO/hOp/hW/hWp, dead after recording) -> dangling at
            // replay -> UR_RESULT_ERROR_DEVICE_LOST (the K=691 crash, localized by the
            // NR_CGRAPH_LIMIT bisect: 690 closures replay fine, the head closure poisons).
            const unsigned pixels = height * width;
            const int MpH = (int)(((pixels + 15u) / 16u) * 16u);
            sycl::half* dA4 = (sycl::half*)pool_get((size_t)MpH * C * 2);
            sycl::half* dB4 = cached_pack_b_f16(pooled, HeadW, (int)C, 16);   // weight: pack once
            float* dH4 = (float*)pool_get((size_t)MpH * 16u * 4);
            packdev::pack_a16(*GQ, dOut16, dA4, (int)pixels, MpH, (int)C);
            f16v1::gemm(*GQ, dA4, dB4, dH4, MpH, 16, (int)C);
            GQ->parallel_for(sycl::range((size_t)pixels * 4u), [=](sycl::item<1> it) {
                size_t i = it.get_id(0);
                unsigned pixel = (unsigned)(i / 4u), c = (unsigned)(i % 4u);
                ((float*)Tgt)[i] = dH4[(size_t)pixel * 16u + c];   // compact: first four columns
            });
            pool_put(dA4); pool_put(dH4);   // dB4 is cache-owned (the head weight)
            pool_put(dOut16);
        }
        if (dStgW) {
            std::vector<float> h((size_t)rows * C);
            GQ->memcpy(h.data(), dStgW, h.size() * 4).wait();
            static int tw = 0; ++tw;
            char fn[64]; snprintf(fn, sizeof fn, "total_A2_%d.bin", tw);
            FILE* fp = fopen(fn, "wb"); fwrite(h.data(), 4, h.size(), fp); fclose(fp);
            printf("[dump] total A2 #%d %zu floats\n", tw, h.size());
            pool_put(dStgW);
        }
        if (pooling && getenv("NR_DUMP_PL")) {   // the A2 published-skip Tgt (1265)
            std::vector<sycl::half> ht((size_t)height * width * C);
            GQ->memcpy(ht.data(), (sycl::half*)Tgt, ht.size() * 2).wait();
            static int ta = 0; ++ta;
            char fn[64]; snprintf(fn, sizeof fn, "tgt_A2_%d.bin", ta);
            FILE* fp = fopen(fn, "wb"); fwrite(ht.data(), 2, ht.size(), fp); fclose(fp);
            printf("[dump] Tgt A2 #%d %zu halves\n", ta, ht.size());
        }
        pool_put(dAp3); pool_put(dBp3); pool_put(dC3); pool_put(dAttended);
    });
    return 0;
}

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
    g_cmd_names.push_back(__func__);
    // v9b FOLD: the ADJACENT producer registered a slot for this source buffer ->
    // bind (packed,scale) into it; this quant becomes a no-op (producer writes int8+scale).
    {
        static bool foldon = getenv("NR_V9B_FOLD") != nullptr;   // FOLD gate: default OFF
        if (foldon && g_pending_fold_slot != SIZE_MAX &&
            !g_fold_slot[g_pending_fold_slot].packed &&
            g_fold_slot[g_pending_fold_slot].cbuf == source &&
            g_cmds.size() == g_pending_fold_slot + 1 &&
            p->second.p == s->second.p && c->second.p == g_bufs.find(scale)->second.p) {
            // IN-PLACE quant only (packed buffer == source, scale == a_scale): the
            // producer writes the exact buffer the downstream reads. The trace caught
            // pair 21 = a NON-in-place quant (separate packed/scale scratch buffers);
            // folding it wrote a recycled pool buffer -> frame 0%. Non-in-place pairs
            // keep the split chain (correct, just not folded).
            g_fold_slot[g_pending_fold_slot] = FoldBind{ source, (void*)pk, (void*)sc };
            g_pending_fold_slot = SIZE_MAX;
            g_cmd_names.push_back(__func__);
            g_cmds.push_back([](){});
            return 0;
        }
        if (foldon && g_pending_fold_slot != SIZE_MAX &&
            g_fold_slot[g_pending_fold_slot].cbuf == source &&
            g_cmds.size() == g_pending_fold_slot + 1)
            g_pending_fold_slot = SIZE_MAX;   // adjacent but NOT in-place: cancel the
                                              // pending fold, this pair keeps the split chain
    }
    auto fq = g_fused_quant.find(source);
    if (fq != g_fused_quant.end()) {   // section 99: the producer already wrote int8 + new_scale
        int asbuf = fq->second;
        g_cmds.push_back([=]() {
            GQ->memcpy(pk, (const int8_t*)a, (size_t)M * K);          // device int8 copy
            if (asbuf != scale)                                       // scales landed in a_scale's buf
                GQ->memcpy(sc, (const float*)g_bufs[asbuf].p, (size_t)M * 4);
        });
        return 0;
    }
    // section 99: ESIMD HW-fdiv quantize is the DEFAULT (gate ALL OK + end-to-end
    // 100.0000% + walk 463->351ms). NR_QR_PLAIN=1 = escape hatch to the old kernel.
    static bool qrplain = getenv("NR_QR_PLAIN") != nullptr;
    if (!qrplain && (K % 16u) == 0u) {
        g_cmds.push_back([=]() {
            qr_launch_esimd(*GQ, *GD, a, pk, sc, M, K);
        });
        if (qfuse_on())   // register for a downstream gemm to dissolve us (P2 fusion)
            g_quant_pk[packed] = QuantFused{ g_cmds.size()-1, source, scale, M, K };
        return 0;
    }
    g_cmds.push_back([=]() {
        qr_launch(*GQ, *GD, qr_kernel(), a, pk, sc, M, K, 0u, 0u, 0u, 0u, 0u, nullptr, nullptr);
        if (getenv("NR_PK_DUMP")) { static int pdSP=0; if(pdSP<1){pdSP++;
            GQ->wait();
            std::vector<int8_t> hp(512); GQ->memcpy(hp.data(), pk, 512).wait();
            std::vector<float> hsc(8); GQ->memcpy(hsc.data(), sc, 32).wait();
            printf("[pkSP] r0c0-15:"); for(int i=0;i<16;++i) printf(" %d",(int)hp[i]);
            printf("  r1c0-7:"); for(int i=256;i<264;++i) printf(" %d",(int)hp[i]);
            printf("  sc0-7:"); for(int i=0;i<8;++i) printf(" %.6g",hsc[i]); printf("\n"); } }
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * K, nb = (size_t)K * N;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, na));
        ev_sync(GQ->memcpy(hB.data(), Braw, nb));
        s8v1::pack_a(hA.data(), hAp.data(), (int)M, (int)K);
        s8v1::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        int8_t* dAp = (int8_t*)pool_get(na);
        int8_t* dCp = (int8_t*)pool_get(nb);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na));
        ev_sync(GQ->memcpy(dCp, hBp.data(), nb));
        s8v1::gemm_s8(*GQ, dAp, dCp, C32, (int)M, (int)N, (int)K);
        pool_put(dAp); pool_put(dCp);
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * K, nb = (size_t)K * N;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, na));
        ev_sync(GQ->memcpy(hB.data(), Braw, nb));
        s8v3::pack_a(hA.data(), hAp.data(), (int)M, (int)K);
        s8v3::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        int8_t* dAp = (int8_t*)pool_get(na);
        int8_t* dCp = (int8_t*)pool_get(nb);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na));
        ev_sync(GQ->memcpy(dCp, hBp.data(), nb));
        s8v3::gemm_s8(*GQ, dAp, dCp, cs, C8, ns, (int)M, (int)N, (int)K);
        pool_put(dAp); pool_put(dCp);
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * K, nb = (size_t)K * N;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, na));
        ev_sync(GQ->memcpy(hB.data(), Braw, nb));
        s8v7::pack_a(hA.data(), hAp.data(), (int)M, (int)K);
        s8v7::pack_b(hB.data(), hBp.data(), (int)K, (int)N);
        int8_t* dAp = (int8_t*)pool_get(na);
        int8_t* dCp = (int8_t*)pool_get(nb);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na));
        ev_sync(GQ->memcpy(dCp, hBp.data(), nb));
        s8v7::gemm_s8rq32(*GQ, dAp, dCp, as, cs, C8, ns, (int)M, (int)N, (int)K);
        pool_put(dAp); pool_put(dCp);
    });
    return 0;
}

int xmx_submit(void) {
    if (!g_recording) FAILMSG("not recording");
    try {
        for (auto& fn : g_cmds) fn();   // in-order queue: enqueue order = execution order
        GQ->wait();                     // one host sync for the whole recording
    } catch (const std::exception& e) { g_cmds.clear(); g_cmd_names.clear(); g_recording = false; FAILMSG("submit: %s", e.what()); }
    g_cmds.clear(); g_cmd_names.clear(); g_recording = false;
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(n4), unary_kernel()(sp, dp, n4, epilogue));
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(count), unary_i8_kernel()(sp, scp, dp, count, cols, epilogue));
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         ctree::cosine_norm_kernel()(sp, dp, rows, vit, nullptr, 0));
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         ctree::cosine_norm_kernel()(sp, dp, rows, vit, scp, heads));
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         ctree::cosine_norm_i8_kernel()(sp, op, cp, rows, vit, qsp, heads));
    });
    return 0;
}

// int xmx_rec_softmax(int source, int dst, unsigned rows, unsigned cols)
// island-1: the vendor's half bit-affine softmax, f32 logits (rows x cols, cols even) ->
// e4m3 probability halves. Bit-exact gate vs nr_model.vendor_approximate_softmax (:211).
// int xmx_rec_softmax(int source, int dst, unsigned rows, unsigned cols)
// int xmx_rec_softmax_bias(int source, int dst, int bias, unsigned rows, unsigned cols,
//                          unsigned heads)
// The island-1 softmax (my translation, NOT a game ABI name -- the game routes softmax
// through xmx_rec_row). The bias variant adds attention.comp:223 `prepared` (logit +=
// bias[boff] before the bit-affine's half_round) with bias_offset (:240) for scores
// (windows*heads, n, n) and bias (heads, n, n). window_attention's recorder composes it.
int xmx_rec_softmax(int source, int dst, unsigned rows, unsigned cols) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !cols || (cols & 1u)) FAILMSG("softmax needs rows>0, even cols");
    auto s = g_bufs.find(source), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad softmax operand");
    const float* sp = (const float*)s->second.p;
    sycl::half* dp = (sycl::half*)d->second.p;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows), smax::softmax_kernel()(sp, dp, rows, cols, nullptr, 0));
    });
    return 0;
}
int xmx_rec_softmax_bias(int source, int dst, int bias, unsigned rows, unsigned cols,
                         unsigned heads) {
    if (!g_recording) FAILMSG("not recording");
    if (!rows || !cols || (cols & 1u) || !heads || (rows % heads)) FAILMSG("softmax_bias needs rows%%heads==0, even cols, heads>0");
    auto s = g_bufs.find(source), d = g_bufs.find(dst), b = g_bufs.find(bias);
    if (s == g_bufs.end() || d == g_bufs.end() || b == g_bufs.end()) FAILMSG("bad softmax_bias operand");
    const float* sp = (const float*)s->second.p;
    sycl::half* dp = (sycl::half*)d->second.p;
    const float* bp = (const float*)b->second.p;
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows), smax::softmax_kernel()(sp, dp, rows, cols, bp, heads));
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        // scratch holds each row's pre-requantize half values between the sum pass and the
        // row-max/requantize pass; every work-item touches only its own row, so no barrier.
        // (The megakernel form keeps them in registers; this is the correctness-first path
        // gate, same staged rhythm as the rest of the skeleton.)
        sycl::half* scratch = (sycl::half*)sycl::malloc_shared((size_t)rows * cols * 2, *GQ);
        GQ->parallel_for(sycl::range(rows),
                         smax::softmax_i8_kernel()(ap, qp, kp, bp, scratch, op, scp, rows, cols));
        pool_put(scratch);
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(rows),
                         requant::requant_i8_kernel()(ap, as, bs, op, scp, rows, cols));
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * channels, nb = (size_t)channels * channels;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, na));
        ev_sync(GQ->memcpy(hB.data(), Braw, nb));
        s8v5::pack_a(hA.data(), hAp.data(), (int)M, (int)channels);
        s8v5::pack_b(hB.data(), hBp.data(), (int)channels, (int)channels);
        int8_t* dAp = (int8_t*)pool_get(na);
        int8_t* dBp = (int8_t*)pool_get(nb);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na));
        ev_sync(GQ->memcpy(dBp, hBp.data(), nb));
        s8v5::gemm_qkv_v(*GQ, dAp, dBp, as, bs, V, (int)M, (int)channels,
                         (int)heads, (int)tokens).wait();
        pool_put(dAp); pool_put(dBp);
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * channels, nb = (size_t)channels * channels;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, na));
        ev_sync(GQ->memcpy(hB.data(), Braw, nb));
        s8v5::pack_a(hA.data(), hAp.data(), (int)M, (int)channels);
        s8v5::pack_b(hB.data(), hBp.data(), (int)channels, (int)channels);
        int8_t* dAp = (int8_t*)pool_get(na);
        int8_t* dBp = (int8_t*)pool_get(nb);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na));
        ev_sync(GQ->memcpy(dBp, hBp.data(), nb));
        s8v5::gemm_qkv_v_i8(*GQ, dAp, dBp, as, bs, V8, vs, (int)M, (int)channels,
                            (int)heads, (int)tokens).wait();
        pool_put(dAp); pool_put(dBp);
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        size_t na = (size_t)M * channels, nb = (size_t)channels * channels;
        std::vector<int8_t> hA(na), hB(nb), hAp(na), hBp(nb);
        ev_sync(GQ->memcpy(hA.data(), Araw, na));
        ev_sync(GQ->memcpy(hB.data(), Braw, nb));
        s8v5::pack_a(hA.data(), hAp.data(), (int)M, (int)channels);
        s8v5::pack_b(hB.data(), hBp.data(), (int)channels, (int)channels);
        int8_t* dAp = (int8_t*)pool_get(na);
        int8_t* dBp = (int8_t*)pool_get(nb);
        ev_sync(GQ->memcpy(dAp, hAp.data(), na));
        ev_sync(GQ->memcpy(dBp, hBp.data(), nb));
        s8v5::gemm_qkv_deq(*GQ, dAp, dBp, as, bs, OUT, (int)M, (int)channels);
        pool_put(dAp); pool_put(dBp);
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
    g_cmd_names.push_back(__func__);
    g_cmds.push_back([=]() {
        GQ->parallel_for(sycl::range(n), qkv_scatter_kernel()(sp, dp, rows, heads, tokens));
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
