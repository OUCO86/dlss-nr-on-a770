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
// #145 (军规 132, 2026-11-06): the launch census must not put statements or blocks around a launch
// call site. Measured on the shipped 口径 with ab.ps1 v3: libxmx_bis4 (pre-#121 source, rebuilt today
// with the same icx recipe) is +0.016 ms vs the artifact (3/5), while bis4 vs libxmx_bis5 (the 27-hunk
// #121 delta alone, same toolchain, same batch) is +4.950 ms, 0/8. Compiling the counters out
// (lcount20) and removing the id mirror + sixth vector (lcount21) both stay +4.8/+4.9 ms; all 170
// device kernels have identical GEN instruction counts and [hop-total] is byte-identical
// (3396 planes / 30,786,624,936 B); the serial NR_RUN_TIMING path shows the same +5 ms (109-110 vs
// 114-115). => host-side launch-helper inlining/layout, ~+7 us per launch over ~690 launches. The tick
// therefore lives at LAUNCH-HELPER ENTRY (declared here, before the kernel headers) and the per-closure
// pf is the delta lc_begin/lc_end take around each closure. No launch call site changes shape.
static bool g_lcount_on = false;      // NR_LCOUNT gate, set in xmx_begin
static int  g_lc_cur = -1;            // the closure currently executing (-1 = not counted)
static long g_lc_ticks = 0;           // helper entries charged to the current closure
static long g_lc_tick0 = 0;           // the reading when the current closure started
#define LC_TICK() do { if (g_lcount_on && g_lc_cur >= 0) ++g_lc_ticks; } while (0)
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
#include "wa_res_kernel.hpp"
#include "lfw_res_kernel.hpp"
#include "b6_res_kernel.hpp"
#include "lfw2_res_kernel.hpp"
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
#include "s6_ffn_block_kernel.hpp"   // S6-1a block-resident FFN chain (NR_S6_FFN; body verbatim from s6_ffn_block2.cpp:68-400)
// A5: the C=64 attention half fused (NR_ATT5_FUSE; body verbatim from s6b_att.cpp:87-617)
#include "att5_fused_kernel.hpp"
#include "pre_kernel.hpp"
#include "post_kernel.hpp"
#include <cstring>
#include <cmath>
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

// PGRAPH: GQ is a QSel proxy -- every '*GQ'/'GQ->' in a closure resolves the LIVE
// stream selection (g_curq) at EXEC time, so the scheduler retargets streams
// without touching a single closure body. Init assigns it once (operator=).
static sycl::queue* g_curq = nullptr;
struct QSel {
    sycl::queue* operator->() const { return g_curq; }
    sycl::queue& operator*() const { return *g_curq; }
    operator bool() const { return g_curq != nullptr; }
    QSel& operator=(sycl::queue* q) { g_curq = q; return *this; }
};
static QSel GQ;
static sycl::device* GD = nullptr;
static char GERR[256] = {0};
#define FAILMSG(...) do { std::snprintf(GERR, sizeof GERR, __VA_ARGS__); return -1; } while (0)

// buffer table: int handle -> {device ptr, bytes, dtype-size, imported}. An imported
// pointer (xmx_buf_import_win32) aliases a buffer owned by the OTHER engine -- freeing
// our import releases only our reference, the producer keeps the allocation alive.
struct Buf { void* p; size_t bytes; size_t esz; bool imported = false; int gen = 0; };   // WQFUSE: the xmx_begin generation at creation (0 = pre-first-begin = init/weights)
static std::unordered_map<int, Buf> g_bufs;
static void mem_probe(int id, void* p, size_t bytes, const char* tag);  // fwd (ze world)
static int g_nextbuf = 1;
static int g_gen = 0;   // WQFUSE: bumped by xmx_begin

// recording
static bool g_recording = false;
static std::vector<std::function<void()>> g_cmds;
static std::vector<const char*> g_cmd_names;

// ============================ PGRAPH (11-01, the 10ms+ blade) ======================
// The frame's 691 closures replay on ONE in_order stream: independent ops queue
// behind dependent ones and the DRAM idles (the 19.4ms latency泡: kernels run at
// 100-190 GB/s vs the 592-734 in-flight ceiling). PGRAPH = wave scheduling:
// each closure REGISTERED ITS TOUCH SET (buffer ids + pool scratch blocks); ops
// with disjoint touch sets run on TWO streams concurrently, waves separated by
// per-stream waits. UNREGISTERED ops carry the FULL-CONFLICT sentinel -> they
// always form their own wave (serial) -- over-approximation is the safety net:
// the scheduler can only LOSE parallelism, never reorder a real dependency.
// Judge = walk 1301 byte-EXACT (pure scheduling: numbers must not move AT ALL).
// Switch: NR_PGRAPH=0 off (the old loop), =1 on (2 streams). cgraph (single-
// submit replay) is bypassed on the PGRAPH path; the for-loop path is the host.
// touch tokens = DEVICE POINTERS (buffer pointers from ids + pool scratch blocks);
// same pointer in two closures = conflict (any direction); sentinel (void*)-1 =
// conflict-with-everything (unregistered op -> own wave). Pointer equality also
// closes the QFALIAS aliasing hole for free (same memory under two ids).
static std::vector<std::vector<void*>> g_cmds_touch;    // parallel to g_cmds (record time)
static std::vector<std::vector<void*>> g_cmds_poolblk;  // per-closure scratch blocks (planning run)
static std::vector<void*>* g_pg_curblk = nullptr;       // non-null ONLY during the planning run
static std::vector<void*> g_pg_pending;                 // ids resolved at record time
// ---- B step 1 (knife2b #106): the group label + the ID side of the touch registration. ----
// Instrumentation only: no closure is merged, reordered or dropped here. Four vectors must
// stay the same length and the same order (military rule 57 now covers a fourth one), and
// the [vec-align] line below proves it on every capture instead of trusting the code.
// g_pg_pending_ids is the id mirror of g_pg_pending (which holds POINTERS): the census needs
// ids, because a pointer cannot be traced back to a plane once two ids alias the same block
// (knife2b #93/#94). The pointers keep driving the scheduler; the ids are print-only.
static std::vector<int> g_cmds_group;                   // parallel to g_cmds; 0 = ungrouped
static int g_group_cur = 0;                             // assigned by a later cut, never here
static std::vector<int> g_pg_pending_ids;               // id mirror of g_pg_pending
static std::vector<std::vector<int>> g_pg_ids_snap;      // per-closure id snapshot (print-only)

// ================= LAUNCH-LEVEL + HOP CENSUS (knife2b #140) =========================
// Presence-gated by NR_LCOUNT: per closure it counts the device submissions the closure issues
// (parallel_for / memcpy / memset) and, from the ALREADY-RECORDED touch snapshots, how many planes
// and how many bytes it touches. "How many launches are left to remove, and in which recorder" stops
// being an inference (rules 104/123). Nothing about scheduling, order or device work changes:
// the counters only increment inside existing call statements, and only when NR_LCOUNT is set.
// INSERTION POLICY (deliberately narrow, so the instrument cannot break the code it measures):
// a counter is inserted only in front of a call that starts a COMPLETE statement (the line ends in
// ';' or '{') and whose previous statement is not an unbraced if/else head. Sites that fail that
// test are counted into g_lc_skipped and reported, so the census states its own blind spots.
struct LCount { int pf = 0, mc = 0, ms = 0; long long scr = 0; };   // scr = pool-scratch bytes handed to this closure at run
static std::vector<LCount> g_cmds_launch;      // parallel to g_cmds (rule 57: the fifth vector)
// #141 (layer-1 census): the SIXTH per-capture vector. The recorder pushes its own name on the
// line before pg_push, so snapshotting it here makes name<->numbers drift-proof. g_cmd_names keeps
// growing across recordings and is addressed through name_offset, which is one entry off when a
// closure is recorded exactly once (the fused pre: pre_done refuses the second recording).
static std::vector<const char*> g_cmds_name;
static long g_lc_skipped = 0;                  // launch sites the narrow policy refused to instrument
static std::vector<LCount>* g_lc_vec = nullptr;   // the counters of the graph currently replaying
#define LC_ADD(field, v) do { if (g_lcount_on && g_lc_vec && g_lc_cur >= 0 && (size_t)g_lc_cur < g_lc_vec->size()) \
                            (*g_lc_vec)[(size_t)g_lc_cur].field += (v); } while (0)
static int g_vit_run_cmd = -1;   // C31: the closure ordinal currently being enqueued (set by
                             // lc_begin, which BOTH the plain-loop and the record paths call)
static void lc_begin(int i) { g_vit_run_cmd = i; if (g_lcount_on) { g_lc_cur = i; g_lc_tick0 = g_lc_ticks; } }
static void lc_end() {
    if (g_lcount_on && g_lc_cur >= 0 && g_lc_vec && (size_t)g_lc_cur < g_lc_vec->size())
        (*g_lc_vec)[(size_t)g_lc_cur].pf = (int)(g_lc_ticks - g_lc_tick0);
    g_lc_cur = -1;
}
static void pg_note_ids(const std::initializer_list<int>& ids) {
    // Only ids that resolve to a live buffer are worth printing. Some call sites pass geometry
    // or flag words in the same initializer list; those leaked into the witness as huge fake ids
    // (134221248 = the pooling flag bit, etc.) whose value is not stable across processes, which
    // made an arm-to-arm touch diff look non-empty when it was empty. Mirror the pointer logic.
    for (int id : ids) {
        if (id < 0) continue;
        auto it = g_bufs.find(id);
        if (it != g_bufs.end() && it->second.p) g_pg_pending_ids.push_back(id);
    }
}
static void pgraph_ids(std::initializer_list<int> ids) {
    g_pg_pending.clear();
    g_pg_pending_ids.clear();
    pg_note_ids(ids);
    for (int id : ids) {
        if (id < 0) continue;
        auto it = g_bufs.find(id);
        if (it != g_bufs.end() && it->second.p) g_pg_pending.push_back(it->second.p);
    }
}
static void pgraph_extra(int id) {   // a recorder adds an out-of-band touched buffer
    if (id < 0) return;
    g_pg_pending_ids.push_back(id);
    auto it = g_bufs.find(id);
    if (it != g_bufs.end() && it->second.p) g_pg_pending.push_back(it->second.p);
}
static void pg_push(std::function<void()> f) {
    g_cmds.push_back(std::move(f));
    g_cmds_touch.push_back(g_pg_pending.empty()
        ? std::vector<void*>{ (void*)-1 } : std::move(g_pg_pending));
    g_cmds_group.push_back(g_group_cur);          // rule 57: the fourth vector
    g_pg_ids_snap.push_back(g_pg_pending_ids);
    g_cmds_launch.push_back(LCount());              // rule 57: the fifth vector, same length/order
    g_cmds_name.push_back(g_cmd_names.empty() ? "?" : g_cmd_names.back());   // #141: the sixth
    if (g_pg_curblk) g_cmds_poolblk.push_back(*g_pg_curblk);
    else g_cmds_poolblk.push_back(std::vector<void*>{});   // planning run not wired yet (#106)
    // NR_PG_TOUCHDUMP (knife2b #93): presence-gated record-time dump of every closure's touch
    // pointers, so "does anybody else read this plane?" becomes a lookup instead of an inference.
    // Host-print only: no device side effect, no extra op (military rules 4/9).
    if (getenv("NR_PG_TOUCHDUMP")) {
        size_t ci = g_cmds.size() - 1;
        const char* nm = ci < g_cmd_names.size() ? g_cmd_names[ci] : "?";   // names are const char*
        std::printf("[pgt] cmd=%zu name=%s touch=", ci, nm);
        for (void* q : g_cmds_touch[ci]) std::printf(" %p", q);
        std::printf(" | ids=");
        for (int id : g_pg_ids_snap[ci]) std::printf(" %d", id);
        std::printf("\n");
    }
    g_pg_pending.clear();
    g_pg_pending_ids.clear();   // #141: the id mirror must not leak into the NEXT closure's snapshot
}
static bool pgraph_conflict(const std::vector<void*>& a, const std::vector<void*>& b) {
    for (void* x : a) if (x == (void*)-1) return true;
    for (void* y : b) if (y == (void*)-1) return true;
    for (void* x : a) for (void* y : b) if (x == y) return true;
    return false;
}
// greedy: op i's wave >= 1 + max{ wave(j) : j<i AND conflict(i,j) }; join the
// earliest such wave whose members are all disjoint from i.
static std::vector<std::vector<int>> pgraph_plan(const std::vector<std::vector<void*>>& tt) {
    size_t n = tt.size();
    std::vector<std::vector<int>> waves;
    std::vector<int> wv(n, 0);
    for (size_t i = 0; i < n; ++i) {
        int wmin = 0;
        for (size_t j = 0; j < i; ++j)
            if (pgraph_conflict(tt[i], tt[j])) wmin = wv[j] + 1 > wmin ? wv[j] + 1 : wmin;
        size_t w = (size_t)wmin;
        for (; w < waves.size(); ++w) {
            bool ok = true;
            for (int j : waves[w]) if (pgraph_conflict(tt[i], tt[j])) { ok = false; break; }
            if (ok) break;
        }
        if (w == waves.size()) waves.push_back({});
        waves[w].push_back((int)i); wv[i] = (int)w;
    }
    return waves;
}
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
// PGRAPH: the scratch pool is SPLIT PER STREAM SLOT (max 4): a block allocated
// on slot s is only ever re-handed on slot s, so two ops on DIFFERENT streams
// can never share a scratch block -- no pool tokens needed in the plan, and the
// per-frame block sequence stays deterministic (each slot evolves identically).
static std::map<size_t, std::vector<void*>> g_pool[4];
static std::map<void*, std::pair<size_t,int>> g_pool_sz;   // ptr -> (bucket, slot)
static int g_pg_slot = 0;
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
    bool gather = false; unsigned image_h = 0, image_w = 0, across = 0, pad = 0;
    void *pkp = nullptr, *scp = nullptr; };   // QFALIAS: device pointers for engine aliasing
static std::map<int,QuantFused> g_quant_pk;   // pk buf id -> the quant that wrote it
// the P11 recip table: host-built from the reference chain, device-cached once.
static float* g_dbgbuf = nullptr;   // shared dbg buffer for the vit recip comparison
static const float* vit_recip_tab() {
    static float* tab = nullptr;
    if (!tab) {
        std::vector<float> h(65536);
        for (unsigned u = 0; u < 65536u; ++u) {
            sycl::half hh; unsigned short uu = (unsigned short)u;
            __builtin_memcpy(&hh, &uu, 2);        // BITS -> half (the earlier sycl::half(u)
                                                  // VALUE-converted: tab[0x4400] held
                                                  // 1/sqrt(17408), not 1/sqrt(4) -- the
                                                  // whole-table poison, gate-caught)
            float norm = (float)hh;
            // P11-FRAME fix (the frame-0% root cause): the comment "inf indices
            // never occur" was FALSE for the real frame -- the vit tree sums in
            // the HALF domain, and frame h values reach |h|~1360 (max|h|^2 =
            // 1.85e6 > 65504 -> the eh chain OVERFLOWS norm to +inf; 163k/196k
            // rows of the first vit call land on the inf index). The reference
            // chain's output there is fdiv_rn(1, sqrt(inf)) = 0; but the bare
            // host expression 1.0f/std::sqrt(inf) came out NaN through the
            // vectorized builder (icx's fast path for the inf input) -> the
            // table HELD NaN at 0x7C00 -> the lane kernel published
            // e4m3(NaN)=448 on entire rows -> whole-frame 0% match while the
            // band-3 gate domain (h<=3: norm never inf) stayed green. Explicit
            // non-finite guard: inf -> 0 (the reference's exact output); NaN
            // slots unreachable (finite h, positive squares, max-floor).
            if (!(norm > 0.0f) || !(norm < 3.402823466e+38f)) { h[u] = 0.0f; continue; }
            // THE FRAME-0% BUILDER BUG (bench_vitframe dbg: kernel recip=-nan(ind)
            // at the +inf norm index -- frame h~1360 -> half-tree norm overflows to
            // +inf; 163k/196k rows of the first vit call land there): the fused
            // expression 1.0f/std::sqrt(norm) gets RECOGNIZED by icx -O2's
            // vectorizer as an rsqrt pattern, whose approximation returns NaN for
            // inf input (scalar C++ would give 1/inf = 0 -- the printed host
            // tab[0x7C00] = -nan(ind) IS the tell). Split with a volatile barrier:
            // sqrt alone lowers to the correctly-rounded vsqrtps, the division
            // alone to IEEE vdivps; the 1/sqrt FUSION is what breaks. (Reference
            // chain at inf: fdiv_rn(1, sqrt(inf)) = 0 -- the guard above already
            // routes non-finite to 0; the volatile split protects the FINITE
            // entries from the same rsqrt-approx class of error.)
            float s = std::sqrt(norm);                       // host IEEE sqrt (vsqrtps, correctly rounded)
            volatile float vs = s;                           // pattern barrier: no 1/sqrt fusion possible
            float r = 1.0f / vs;                             // correctly-rounded IEEE division
            h[u] = (float)sycl::half(r);                     // qr_half_round
        }
        tab = (float*)sycl::malloc_device(65536u * 4u, *GQ);
         GQ->memcpy(tab, h.data(), 65536u * 4u).wait();
        if (getenv("NR_VITDBG")) { float chk[4] = {0,0,0,0};
             GQ->memcpy(chk, (const float*)tab + 0x4400u, 16).wait();
            printf("[vitdbg] tab=%p host[0x4400]=%.6g dev readback=%.6g %.6g (expect 0.5)\n",
                   (void*)tab, (double)h[0x4400], (double)chk[0], (double)chk[1]); }
    }
    return tab;
}
static bool qfuse_on() { static bool v = !getenv("NR_Q_FUSE") || atoi(getenv("NR_Q_FUSE")) != 0; return v; }

// B5-5b SLICE 1 (lfw = layer-fused qkv+window-attention): the qkv recorder (guard:
// non-vit, C==64, heads==2, tokens==64, M%64==0) stashes its packed operands in a
// process-static scratch and marks the stash; the NEXT window_attention recorder
// (same q/k/v buffer ids, merged, bias) consumes it with ONE lfw::launch_lfw kernel
// (qkv gemm + v5a tail + attention stages, planes 1274/75/76 never exist). If the
// pairing never completes, the stash is simply overwritten (no leak, no launch).
struct LfwStash {
    bool valid = false;        // set by a guarded qkv record
    bool confirmed = false;    // set when the NEXT wa record pairs with it
    int q = -1, k = -1, v = -1;   // the qkv TARGET buffer ids (wa's q/k/v must match)
    int a = -1, b = -1;           // qkv operand ids (b = weight for cached_pack_b_i8)
    const float *as = nullptr, *bs = nullptr, *qs = nullptr;   // qkv scale pointers
    const int8_t* Araw = nullptr; // qkv raw A (the non-fused pack form)
    const int8_t* Braw = nullptr; // qkv raw weight (the cache-fill pack_b at run time)
    bool fq = false; QuantFused qfq;   // the fused gather-pack form (image source)
    unsigned M = 0, Mp = 0, C = 64u, heads = 2u, tokens = 64u;
    size_t qcmd = 0;
};
static LfwStash g_lfw;
static int8_t* lfw_scratch_a = nullptr;   // device: max Mp*C int8 (~2.3MB, 4MB cap)
static bool lfw_on() { static bool v = getenv("NR_LFW_FUSE") != nullptr && atoi(getenv("NR_LFW_FUSE")) != 0; return v; }   // B5-5b SLICE1: bench_lfw 8/8 EXACT + walk 1301 EXACT, but FRAME A/B 3/4 slightly NEG (+0.5: 510 WG x NT16 serializes qkv+attn per WG vs the split chain's 768+1020 WG parallelism). NOT promoted; slice 2 = per-(window,head) WG at BN=32 (1020 WGs, disjoint plane slices) -- analysis banked in 6.15. Probe: NR_LFW_FUSE=1.

// B6-1 (the traffic-roof campaign §6.22-23): the SAME qkv stash, but the pairing
// EXTENDS two records further: wa (as before) -> quant(1277 -> pk, sc) -> wres
// (pk, W -> 1270, skip=1267, cosine; flags epi1/narrow/half_skip). When all four
// line up, the wa closure is REWRITTEN at wres-record time into ONE b6 launch
// (qkv + wa + attended-quant + outproj + residual-fold; 1277/pk/sc/1270-side
// round trips vanish), the quant closure no-ops, and the wres closure is never
// pushed. Escape: NR_B6=0 (default ON once bench_b6-driven promotion).
struct B6Stash {
    bool valid = false;          // set at wa-pair time (candidate)
    bool qmatched = false;       // set when the next quant matches
    size_t wacmd = 0, quantcmd = 0;
    const float* bias = nullptr;   // the wa's bias pointer (captured at wa-record)
    LfwStash S;                  // the qkv snapshot (operands/pack form)
    unsigned windows = 0;
    int out1277 = -1;            // the wa Out buffer id (the quant's source)
    int pkid = -1, scid = -1;    // the quant's packed/scale ids (the wres's a/a_scale)
};
static B6Stash g_b6;
static bool b6_on() { static bool v = getenv("NR_B6") != nullptr && atoi(getenv("NR_B6")) != 0; return v; }   // B6-1 VERDICT +1.08 (16-pair, 0/16 wins): DEFAULT OFF; NR_B6=1 = retest switch (the axis is frozen-for-retest, not dead -- see 6.25)   // B6-1 PROMOTED: bench_b6 12/12 EXACT (PKT/AS/ATT/planes/1270 both shapes)
// called by a gemm recorder: if `a` is a fused-quant pk whose scale buf == this gemm's
// a_scale and whose M,K match, no-op the quant closure and return its info.
static bool qfuse_take(int a, int a_scale, unsigned M, unsigned K, QuantFused& out){
    if (!qfuse_on()) return false;
    auto it = g_quant_pk.find(a);
    if (it == g_quant_pk.end()) { if (getenv("NR_QFUSE_DBG")) printf("[qf] take MISS pk=%d (M=%u K=%u): no registration\n", a, M, K); return false; }
    if (it->second.sc != a_scale || it->second.M != M || it->second.K != K) {
        if (getenv("NR_QFUSE_DBG")) printf("[qf] take MISMATCH pk=%d want(sc=%d M=%u K=%u) reg(sc=%d M=%u K=%u src=%d)\n",
            a, a_scale, M, K, it->second.sc, it->second.M, it->second.K, it->second.src);
        return false;
    }
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
    static bool qfuse_b = getenv("NR_Q_FUSE_B") != nullptr || getenv("NR_BG_FOLD") != nullptr;
    if (!qfuse_b) return false;                                // NEUTRAL (batched fused
    if (!qfuse_on() || scale_stride != 0u) return false;       // pack +8ms eats the
                                                        // quant -12; kept as a probe
    auto it = g_quant_pk.find(a);
    if (it == g_quant_pk.end()) {
        // QFALIAS: the engine hands the SAME device memory to the producer under
        // id `packed` and to the consumer under a DIFFERENT id `a` (pointer
        // census 12:3x: PKP(1305) == AP(1273)). Match on the POINTER.
        auto ai = g_bufs.find(a);
        if (ai == g_bufs.end()) return false;
        for (auto q = g_quant_pk.begin(); q != g_quant_pk.end(); ++q)
            if (q->second.pkp == ai->second.p) { it = q; break; }
        if (it == g_quant_pk.end()) return false;
    }
    // the two frame forms (census 99c4034, guards per the user's reference):
    //   shared-A:   quant-K == gemm-K == lda, sa==0 (groups read the SAME rows)
    //   col-slice:  quant-K == lda (full wide row), sa == K (group g reads cols g*K..)
    const bool shared    = (it->second.K == K && K == lda_e && sa == 0u);
    const bool colslice  = (it->second.K == lda_e && sa == K);
    if (!shared && !colslice) return false;
    if (it->second.M != M) return false;
    if (it->second.sc != a_scale) {   // QFALIAS: scale may ride a different id too
        auto si = g_bufs.find(a_scale);
        if (si == g_bufs.end() || it->second.scp != si->second.p) return false;
    }
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
// ---- B step 1 (knife2b #106): the pool-fetch SEQUENCE witness. -------------------------------
// Why this exists: the scratch pool hands out the SAME block sequence every run (the section 92
// in-order proof), and that sequence is part of engine correctness -- section 56b R6 proved that a
// fusion which merely HOLDS a block longer changes what later closures fetch and silently breaks
// the frame. So before any merge cut is even attempted, the sequence has to be printable and
// hashable, and two arms must be comparable. NR_POOLSEQ is presence-gated: unset, every hook below
// is a single branch on a false flag and nothing is printed or stored.
static bool g_poolseq_on = false;                       // set from getenv("NR_POOLSEQ") at capture
static int g_pool_cur_closure = -1;                     // stamped ONLY by the run loops, never by recorders
static std::vector<std::vector<std::pair<void*, size_t>>> g_pool_cur_list;   // per closure, in run order
static unsigned long long g_pool_hash = 146959810393466560ull;   // FNV-1a 64 over the CANONICAL sequence
// The hash must be comparable ACROSS PROCESSES, and a raw device pointer is not: the driver
// hands out different addresses every run (that is why the first two arms of #106 disagreed on
// the raw-pointer hash while 1301 stayed byte-identical). So each distinct pointer gets a
// first-seen ordinal and the hash covers (closure, kind, ordinal, bucket size) - the ORDER and
// the SIZES, which is what section 56b R6 is actually about.
static std::map<void*, unsigned long long> g_pool_ord;
static unsigned long long pool_ordinal(void* p) {
    auto it = g_pool_ord.find(p);
    if (it != g_pool_ord.end()) return it->second;
    unsigned long long v = g_pool_ord.size() + 1;
    g_pool_ord[p] = v;
    return v;
}
static void pool_seq_note(int kind, void* p, size_t n) {   // kind 0 = get, 1 = put
    if (g_pool_cur_closure < 0) return;
    unsigned long long ord = pool_ordinal(p);
    g_pool_hash ^= (unsigned long long)g_pool_cur_closure ^ ((unsigned long long)kind << 56) ^ (ord << 8);
    g_pool_hash *= 1099511628211ull;
    g_pool_hash ^= (unsigned long long)n;
    g_pool_hash *= 1099511628211ull;
    if (kind == 0) {
        if ((int)g_pool_cur_list.size() <= g_pool_cur_closure) g_pool_cur_list.resize(g_pool_cur_closure + 1);
        g_pool_cur_list[g_pool_cur_closure].push_back(std::make_pair(p, n));
        std::printf("[poolseq] op=%d get ptr=%p bytes=%zu\n", g_pool_cur_closure, p, n);
    } else {
        std::printf("[poolseq] op=%d put ptr=%p bytes=%zu\n", g_pool_cur_closure, p, n);
    }
    std::fflush(stdout);
}
static void pool_seq_begin(size_t nclosure) {
    g_poolseq_on = getenv("NR_POOLSEQ") != nullptr;
    if (!g_poolseq_on) return;
    g_pool_cur_list.clear(); g_pool_cur_list.resize(nclosure);
    g_pool_ord.clear();
    g_pool_hash = 146959810393466560ull;
}
static void pool_seq_end(int graph_id) {
    if (!g_poolseq_on) return;
    g_pool_cur_closure = -1;
    size_t gets = 0, maxb = 0;
    for (auto& v : g_pool_cur_list) { gets += v.size(); if (v.size() > maxb) maxb = v.size(); }
    std::printf("[poolseq-total] graph=%d closures=%zu gets=%zu maxperclosure=%zu hash=%016llx\n",
                graph_id, g_pool_cur_list.size(), gets, maxb, g_pool_hash);
    std::printf("[poolseq-canon] graph=%d seq=", graph_id);
    for (size_t i = 0; i < g_pool_cur_list.size(); ++i) std::printf("%zu,", g_pool_cur_list[i].size());
    std::printf("\n");
    for (size_t i = 0; i < g_pool_cur_list.size(); ++i)
        if (!g_pool_cur_list[i].empty())
            std::printf("[poolblk] op=%zu n=%zu bytes=%zu\n", i, g_pool_cur_list[i].size(),
                        [&]{ size_t s=0; for (auto& q : g_pool_cur_list[i]) s += q.second; return s; }());
    std::fflush(stdout);
}
static void* pool_get(size_t n) {
    size_t bucket = (n + 255) / 256 * 256;
    auto& pl = g_pool[g_pg_slot & 3];
    auto it = pl.lower_bound(bucket);
    if (it == pl.end() || it->second.empty()) {
        g_pool_mallocs++; g_pool_malloc_bytes += bucket;   // section 92: driver round-trip count
        void* p = sycl::malloc_device(bucket, *GQ);
        if (p) g_pool_sz[p] = { bucket, g_pg_slot & 3 };
        if (p && bucket >= (16ull<<20)) mem_probe(-1, p, bucket, "POOL");  // D11 census
        pool_seq_note(0, p, bucket);
        if (p) LC_ADD(scr, (long long)bucket);   // #141 hop census: scratch this closure holds
        return p;
    }
    void* p = it->second.back(); it->second.pop_back();
    g_pool_sz[p] = { bucket, g_pg_slot & 3 };
    pool_seq_note(0, p, bucket);
    LC_ADD(scr, (long long)bucket);   // #141 hop census: scratch this closure holds
    return p;
}

static void pool_put(void* p) {
    if (!p) return;
    auto it = g_pool_sz.find(p);
    // Only recycle pool-tracked blocks. Anything else (a g_wcache weight block, a real
    // buffer) is owned elsewhere -- buf_destroy frees buffers, wcache frees cache blocks.
    if (it == g_pool_sz.end()) return;
    pool_seq_note(1, p, it->second.first);
    g_pool[it->second.second][it->second.first].push_back(p);
    g_pool_sz.erase(it);
}
static void pool_clear() {
    for (int sl = 0; sl < 4; ++sl)
        for (auto& kv : g_pool[sl]) for (void* p : kv.second) { sycl::free(p, *GQ); g_pool_sz.erase(p); }
    for (int sl = 0; sl < 4; ++sl) g_pool[sl].clear();
    g_pool_sz.clear();
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
// ==================== S6-1a: block-resident FFN chain (NR_S6_FFN) ====================
// What this is: the frame's FFN closure is SIX recorder ops per block --
//   QUANT(1270->1272/1273)  ->  BATCHED expand (1272 x W -> 1274)  ->
//   QUANT(1274->1272/1273)  ->  BATCHED proj   (1272 x W -> 1275)  ->
//   QUANT(1275->1272/1273)  ->  RESIDUAL       (1272 x W -> 1267, skip=1270)
// (plan_960x544.c:5337/5340/5342/5345/5347/5349 for the C=64 M=32640 family and
// :4055/4057/4059/4061/4063/4065 for C=128 M=8160; the captured region is 5308..6643).
// The three pk/sc scratch round trips and the 1274/1275 planes are pure chain-internal
// traffic -- ffn2::fused keeps them in SLM, so ONE workgroup owning T tokens runs the
// whole closure and only the 1270 read / 1267 write survive.
//
// WIRING RULE (the user's, 2026-11-01): the pairing is done at RECORD time by a strict
// adjacency state machine over the three recorder sites. When a chain completes, the SIX
// closures are NOT dropped -- the first FIVE are replaced by no-ops and the residual's
// own closure executes the fused kernel. Partial no-oping is forbidden: the split legs
// read pk/dC scratch that the fused leg never writes, so a half-fused chain reads junk.
// passes therefore stays at 691 (the closure COUNT is unchanged; only bodies change),
// while the captured cgraph's NODE count drops (a no-op closure emits zero device ops).
//
// Switch: NR_S6_FFN -- PROMOTED TO DEFAULT ON on 2026-11-01 (user's go, after the
// stage-3 三关 + 帧夹逼). Escape hatch kept: NR_S6_FFN=0 (any atoi()==0 value) = the
// exact pre-S6 shipped path, bitwise unchanged -- every guard below is dead when
// s6_on() returns false, so the OFF side of the switch is the old code verbatim.
// WHY ON BY DEFAULT (the only price quoted here is the shipped in-process frame A/B):
// 48 pairs, mean -2.950 ms/frame, fused side faster on 48/48, 95% CI [-3.190, -2.710]
// (three 16-pair shots: -2.683 / -3.032 / -3.134) -- ledger: notes/s6-stage3.md 步骤 4.
// Gate/walk/determinism on the promoted default: notes/s6-promote.md (2026-11-01).
// Do NOT re-price this blade off off-path accounts (bench wall / RUN_TIMING serial
// totals) -- they are not the frame number and must not be cited as the shipping price.
// Military rules 4/9: no runtime diagnostic branch was added inside the kernel; the
// switch lives at closure level only. NR_S6_TRACE stays presence-gated (default OFF):
// it is a record-time host witness, it prints nothing on the device and adds no op.
//
// Families wired (the two the stage-2 bench proved byte-exact, E:/DSH/s6/stage2.md):
//   S1 C=64  HID=256 M=32640  x8  chains/frame   Shape<32,64,256,false,4,2>
//   S2 C=128 HID=512 M=8160   x12 chains/frame   Shape<16,128,512,false,4,2>
// NOT wired: the C=256 M=2040 family (its projection is xmx_rec_gemm f16, not
// xmx_rec_gemm_int8_batched, so the three-site pairing cannot see it) and C=512 M=640.
struct S6Chain {
    int stage = 0;                 // 0 idle | 1 Q1 | 2 expand | 3 Q2 | 4 proj | 5 Q3 (awaiting residual)
    size_t cq1 = 0, cb1 = 0, cq2 = 0, cb2 = 0, cq3 = 0;   // g_cmds indices of the five future no-ops
    int src = 0, pk = 0, sc = 0;   // op1 quant operands (recorder buffer ids)
    int be = 0, ce = 0, bse = 0;   // expand: weight id, hidden plane id, b_scale id
    int bp = 0, cp = 0, bsp = 0;   // proj:   weight id, out plane id,    b_scale id
    int ldb_e = 0; size_t sb_e = 0;   // expand B gather strides (the wide repack)
    int ldb_p = 0; size_t sb_p = 0;   // proj B gather strides
    int Np = 0, Kp = 0, batchp = 0;   // proj plan tuple (the diag pack's parameters)
    unsigned M = 0, C = 0, HID = 0;
    int fam = -1;                  // 0 = S1, 1 = S2
};
static S6Chain g_s6;
static long g_s6_fires = 0;      // cumulative chains fused (host-side counter, record time)
static long g_s6_fires_gen = 0;  // chains fused in the CURRENT recording
static bool s6_on() {
    // Default flipped OFF -> ON at the S6-1a promotion (2026-11-01). unset => fused;
    // NR_S6_FFN=0 => the escape hatch (exact pre-S6 shipped path). Read once per process.
    static bool v = getenv("NR_S6_FFN") ? (atoi(getenv("NR_S6_FFN")) != 0) : true;
    return v;
}
static void s6_reset() { g_s6 = S6Chain(); }
static int s6_family(unsigned C, unsigned HID) {
    if (C == 64u  && HID == 256u)  return 0;
    if (C == 128u && HID == 512u)  return 1;
    return -1;
}
// the plan's producer->quant adjacency (section 9: gap min 2 / max 4). In the CAPTURED
// region the six ops of a chain are CONSECUTIVE recorder steps (the OP_*_INIT / OP_BUF
// lines between them create no closure), so gap==1; the <=4 tolerance is the census bound.
static bool s6_gap(size_t a, size_t b) { return b > a && (b - a) <= 4u; }
// QUANT leg. A quant ALWAYS (re)arms a candidate -- the chain start is the block's input
// quant, and any other quant in between breaks the chain (conservative: fresh candidate).
static void s6_note_quant(size_t cmd, int source, int packed, int scale, unsigned M, unsigned K) {
    if (!s6_on()) return;
    S6Chain& g = g_s6;
    if (g.stage == 2 && source == g.ce && packed == g.pk && scale == g.sc &&
        M == g.M && K == g.HID && s6_gap(g.cb1, cmd)) { g.stage = 3; g.cq2 = cmd; return; }
    if (g.stage == 4 && source == g.cp && packed == g.pk && scale == g.sc &&
        M == g.M && K == g.C && s6_gap(g.cb2, cmd)) { g.stage = 5; g.cq3 = cmd; return; }
    S6Chain c; c.stage = 1; c.cq1 = cmd; c.src = source; c.pk = packed; c.sc = scale;
    c.M = M; c.C = K; g = c;
}
// BATCHED leg #1 = the FFN expand: N=128 wide groups, sa=0 (A broadcast), epi3, narrow,
// ldc = N*batch = HID, and the group weight slices are CONTIGUOUS along N (sb == N*ldb)
// -- exactly the condition that makes the wide pack of the whole HID one legal repack.
static void s6_take_expand(size_t cmd, int a, int b, int c, int a_scale, int b_scale,
                           unsigned M, unsigned N, unsigned K, unsigned batch,
                           unsigned sa, unsigned sb, unsigned sc_stride,
                           unsigned lda, unsigned ldb, unsigned ldc,
                           unsigned scale_stride, unsigned flags) {
    if (!s6_on()) return;
    S6Chain& g = g_s6;
    if (g.stage != 1 || !s6_gap(g.cq1, cmd)) return;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const unsigned ldb_ = ldb ? ldb : K;
    if (a != g.pk || a_scale != g.sc || M != g.M || K != g.C) return;
    if (N != 128u || batch < 2u) return;
    if (epi != 3u || !narrow) return;
    if (sa != 0u || scale_stride != 0u) return;
    if (ldb_ != K || sb != (size_t)N * K) return;
    if (sc_stride != N || ldc != N * batch) return;
    const int fam = s6_family(g.C, N * batch);
    if (fam < 0) return;
    g.stage = 2; g.cb1 = cmd; g.be = b; g.ce = c; g.bse = b_scale;
    g.HID = N * batch; g.fam = fam; g.ldb_e = (int)ldb_; g.sb_e = sb;
}
// BATCHED leg #2 = the FFN projection: the P8-b wide-merge form (N=32 groups, sa=K,
// lda=K*batch, sb=N*K, sc=N, ldc=N*batch, scale_stride=0, epi1, narrow) with
// N*batch == C and K*batch == HID. Same guards the shipped wide_ok branch uses.
static void s6_take_proj(size_t cmd, int a, int b, int c, int a_scale, int b_scale,
                         unsigned M, unsigned N, unsigned K, unsigned batch,
                         unsigned sa, unsigned sb, unsigned sc_stride,
                         unsigned lda, unsigned ldb, unsigned ldc,
                         unsigned scale_stride, unsigned flags) {
    if (!s6_on()) return;
    S6Chain& g = g_s6;
    if (g.stage != 3 || !s6_gap(g.cq2, cmd)) return;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const unsigned lda_ = lda ? lda : K, ldb_ = ldb ? ldb : K, ldc_ = ldc ? ldc : N;
    if (a != g.pk || a_scale != g.sc || M != g.M) return;
    if (N != 32u || (N * batch) != g.C || (K * batch) != g.HID) return;
    if (epi != 1u || !narrow) return;
    if (sa != K || lda_ != K * batch || sb != (size_t)N * K) return;
    if (sc_stride != N || ldc_ != N * batch || scale_stride != 0u) return;
    g.stage = 4; g.cb2 = cmd; g.bp = b; g.cp = c; g.bsp = b_scale;
    g.ldb_p = (int)ldb_; g.sb_p = sb; g.Np = (int)N; g.Kp = (int)K; g.batchp = (int)batch;
}
// the frozen operand set the fused closure needs (pointers resolved AT RECORD TIME, the
// same convention every other recorder closure in this file uses).
struct S6Fuse {
    int fam = -1;
    unsigned M = 0, C = 0, HID = 0;
    sycl::half* dIn = nullptr; sycl::half* dOut = nullptr;
    const int8_t* BexpRaw = nullptr; const float* bsExp = nullptr;
    const int8_t* BprojRaw = nullptr; const float* bsProj = nullptr;
    const int8_t* BresRaw = nullptr;  const float* bsRes = nullptr;
    const float* cos = nullptr;
    int be = 0, bp = 0, bres = 0;      // weight buffer ids (cache keys)
    int bse = 0, bsp = 0;              // expand/proj b_scale buffer ids
    int ldb_e = 0; size_t sb_e = 0;
    int ldb_p = 0; size_t sb_p = 0;
    int Np = 0, Kp = 0, batchp = 0;    // proj plan tuple (the diag pack's parameters)
};
// RESIDUAL leg = the chain's last op. On a match the five earlier closures become no-ops
// and THIS closure runs the fused kernel. Returns false (and resets the candidate) unless
// every field of the six-op tuple agrees.
static bool s6_take_residual(size_t cmd, int a, int b, int c, int a_scale, int b_scale,
                             int skip, int cosine, unsigned M, unsigned N, unsigned K,
                             unsigned flags, S6Fuse& out) {
    if (!s6_on()) return false;
    S6Chain g = g_s6; s6_reset();
    if (g.stage != 5 || !s6_gap(g.cq3, cmd)) return false;
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u;
    const bool half_skip = (flags & 0x40000u) != 0u;
    if (a != g.pk || a_scale != g.sc || M != g.M || N != g.C || K != g.C) return false;
    if (epi != 1u || !narrow || !half_skip) return false;
    if (skip != g.src) return false;
    if (g.fam < 0) return false;
    auto P = [&](int id) -> void* { auto it = g_bufs.find(id); return it == g_bufs.end() ? nullptr : it->second.p; };
    out.fam = g.fam; out.M = g.M; out.C = g.C; out.HID = g.HID;
    out.dIn = (sycl::half*)P(g.src); out.dOut = (sycl::half*)P(c);
    out.BexpRaw = (const int8_t*)P(g.be); out.bsExp = (const float*)P(g.bse);
    out.BprojRaw = (const int8_t*)P(g.bp); out.bsProj = (const float*)P(g.bsp);
    out.BresRaw = (const int8_t*)P(b);    out.bsRes = (const float*)P(b_scale);
    out.cos = (const float*)P(cosine);
    out.be = g.be; out.bp = g.bp; out.bres = b; out.bse = g.bse; out.bsp = g.bsp;
    out.ldb_e = g.ldb_e; out.sb_e = g.sb_e;
    out.ldb_p = g.ldb_p; out.sb_p = g.sb_p;
    out.Np = g.Np; out.Kp = g.Kp; out.batchp = g.batchp;
    if (!out.dIn || !out.dOut || !out.BexpRaw || !out.bsExp || !out.BprojRaw ||
        !out.bsProj || !out.BresRaw || !out.bsRes || !out.cos) return false;
    // THE RULE: all six or none. Five no-ops + one fused launch.
    g_cmds[g.cq1] = [](){}; g_cmds[g.cb1] = [](){}; g_cmds[g.cq2] = [](){};
    g_cmds[g.cb2] = [](){}; g_cmds[g.cq3] = [](){};
    ++g_s6_fires; ++g_s6_fires_gen;
    // RECORD-TIME host witness (env-gated, like the NR_*_TRACE family): prints nothing
    // on the device, adds no op to the stream, and lives at closure level -- the kernel
    // itself is untouched (military rules 4/9).
    if (getenv("NR_S6_TRACE"))
        std::printf("[s6-fire #%ld] fam=%d M=%u C=%u HID=%u cmds %zu..%zu  src=%d pk=%d sc=%d"
                    " -> out=%d skip=%d  w(e/p/r)=%d/%d/%d\n",
                    g_s6_fires, g.fam, g.M, g.C, g.HID, g.cq1, cmd,
                    g.src, g.pk, g.sc, c, skip, g.be, g.bp, b);
    return true;
}
// the fused chain's weight packs (cache-owned, same g_wcache convention as the split
// legs). Bexp = the wide (HID x K) pack of the batched expand weight; Bproj = the SAME
// block-diagonal wide pack the shipped P8-b branch uses (same WKey, so the two paths
// share one block); Bres = cached_pack_b_i8, exactly the residual's own pack.
static int8_t* s6_pack_bexp_wide(const S6Fuse& f) {
    WKey wk{ f.be, (int)f.HID, (int)f.C, 30001 };
    auto it = g_wcache.find(wk);
    if (it != g_wcache.end()) return (int8_t*)it->second;
    int8_t* p = (int8_t*)sycl::malloc_device((size_t)f.HID * f.C, *GQ);
     packdev::gather_pack_b_b(*GQ, f.BexpRaw, p, (int)f.HID, (int)f.C, f.ldb_e, 0, 1);
    g_wcache[wk] = p;
    return p;
}
static int8_t* s6_pack_bproj_wide(const S6Fuse& f) {
    WKey wk{ f.bp, f.Np, f.Kp, 10000 + f.batchp };   // identical key/layout as P8-b
    auto it = g_wcache.find(wk);
    if (it != g_wcache.end()) return (int8_t*)it->second;
    int8_t* p = (int8_t*)sycl::malloc_device((size_t)f.C * f.HID, *GQ);
     packdev::gather_pack_b_diag_b(*GQ, f.BprojRaw, p, f.Np, f.Kp, f.ldb_p,
                                  f.sb_p, f.batchp);
    g_wcache[wk] = p;
    return p;
}
static void s6_ffn_run(const S6Fuse& f) {
    ffn2::Args a;
    a.dIn = f.dIn; a.dOut = f.dOut;
    a.Bexp = s6_pack_bexp_wide(f); a.bsExp = f.bsExp;
    a.Bproj = s6_pack_bproj_wide(f); a.bsProj = f.bsProj;
    a.BprojH = nullptr;
    a.Bres = cached_pack_b_i8(f.bres, f.BresRaw, (int)f.C, (int)f.C);
    a.bsRes = f.bsRes; a.cos = f.cos;
    a.M = (int)f.M; a.NP = 0;
    a.dpk1 = nullptr; a.dsc1 = nullptr; a.dHid = nullptr; a.dpk2 = nullptr; a.dsc2 = nullptr;
    a.dOut1275 = nullptr; a.dpk3 = nullptr; a.dsc3 = nullptr;
    if (f.fam == 0) {
        using S = ffn2::Shape<32, 64, 256, false, 4, 2>;
        static_assert(S::T == 32 && S::SLM <= 32768u, "S6 S1 shape/slm drift");
        ffn2::fused<S, false, S::NPH>(*GQ, a);
    } else {
        using S = ffn2::Shape<16, 128, 512, false, 4, 2>;
        static_assert(S::T == 16 && S::SLM <= 32768u, "S6 S2 shape/slm drift");
        ffn2::fused<S, false, S::NPH>(*GQ, a);
    }
}

// ==================== A5: the C=64 attention half fused (NR_ATT5_FUSE) ====================
// What this is: the frame's attention closure is FIVE recorder ops per C=64 chain --
//   QUANT_WINDOW(1267 -> pk/sc) -> GEMM_INT8_QKV(pk x W81 -> Q,K,V) ->
//   WINDOW_ATTENTION(Q,K,V,bias -> 1277) -> QUANT(1277 -> pk2/sc2) ->
//   GEMM_WINDOW_INT8_RESIDUAL(pk2 x W79 -> 1270, skip=1267)
// (rt_per_closure.csv chain 48: 0.0021 + 0.2922 + 0.4266 + 0.0021 + 0.2592 = 0.982 ms).
// The pk/sc planes and the Q/K/V planes are single-read by the next op of the same chain (the
// census: all 104 quant_window pks are single-read by exactly the next QKV), so the whole block
// can live inside ONE launch: att5::fused keeps the gather-quant, the scores/probs and the PKT
// fold in SLM; only the 1267 read and the 1270 write survive.
//
// WIRING RULE (the S6-1a precedent, knife2b #75): the pairing happens at RECORD time through a
// strict adjacency state machine over the five recorder sites. When a chain completes, the
// closures are NOT dropped -- the first FOUR become no-ops and the window-residual's own closure
// runs the fused kernel. Partial no-oping is forbidden: the split legs read pk/QKV scratch the
// fused leg never writes, so a half-fused chain would read junk. The closure COUNT (and with it
// 'passes') is unchanged; only bodies change.
//
// SWITCH: NR_ATT5_FUSE -- DEFAULT 0 = the split path verbatim (bit-identical to today's shipped).
// NR_ATT5_FUSE=1 wires the eight C=64 chains only. Read once per process. Military rules 4/9: no
// branch was added inside the kernel -- the switch lives at closure level only.
// NR_ATT5_TRACE is a record-time host witness (prints nothing on the device, adds no op),
// presence-gated like the NR_*_TRACE family. It prints the matched closure indices AND both
// weight-cache four-tuples: a wrong WKey would silently feed a non-block-diagonal pre-packed B
// and could still pass the byte gates (knife2b #68).
//
// EVIDENCE (bench, byte-exact): port_e_chain.cpp -- 25 checkpoints diff=0 between this 2-launch
// composition and the 13-launch shipped chain; 6/6 processes GREEN; cross-process blob IDENTICAL
// (md5 7E963BF25B6F3E8B4608D8F185FB875E); LIVENESS proven; 0 bad / 2000 self-repetition
// relaunches of the DUMP=false form. PRICE (bench, min-of-15x5, 10 processes, 60 s apart):
// att half 5 legs 0.6435 -> 1 launch 0.4336; the composition 13 launches 1.4112 -> 2 launches
// 0.9421 (ratio 0.6676 => chain 1.525 -> ~1.02 ms, 8 chains ~-4.1 ms serial, frame ~-1.8 ms).
// NOT wired: the C=128 rung (att fused measured +51% slower there, SLM 41,984 B crosses the
// 32 KB cliff) and nothing outside the eight C=64 chains (0,1,2,3,48,49,50,51).
struct A5Chain {
    int stage = 0;                 // 0 idle | 1 QW | 2 QKV | 3 WA | 4 Q2 (awaiting the window residual)
    size_t c_qw = 0, c_qkv = 0, c_wa = 0, c_q2 = 0;   // g_cmds indices of the four future no-ops
    int src = 0, pk = 0, sc = 0;                     // 641 operands (recorder buffer ids)
    int wqkv = 0, bsqkv = 0, qkvsc = 0;              // 642: weight / b_scale / qkv_scale ids
    int q = 0, k = 0, v = 0;                         // 642 targets = the fused kernel's faces
    int bias = 0, att = 0;                           // 643: bias id, the 1277 plane id
    int pk2 = 0, sc2 = 0;                            // 644 operands
    unsigned M = 0, C = 0, heads = 0, tokens = 0, batches = 0;
    unsigned height = 0, width = 0, across = 0, pad = 0;
};
static A5Chain g_a5;
static long g_a5_fires = 0, g_a5_fires_gen = 0;
// The compile-time default of the A5 fusion (knife2b #95 / the parent's ②).
// Precedent: T_SKIP_CHAINS_DEF (tools/shipped_build.defs). The load-slot dll is built with
// /DT_ATT5_FUSE_DEF=1; any other build (bench, older variants) leaves it 0 = today's split
// path verbatim. The runtime escape hatch stays: NR_ATT5_FUSE=0 forces OFF, =1 forces ON,
// so both sides can still be A/B-ed in one artifact.
#ifndef T_ATT5_FUSE_DEF
#define T_ATT5_FUSE_DEF 0
#endif
static bool a5_on() {
    static bool v = getenv("NR_ATT5_FUSE") ? (atoi(getenv("NR_ATT5_FUSE")) != 0)
                                          : (T_ATT5_FUSE_DEF != 0);
    return v;
}
static void a5_reset() { g_a5 = A5Chain(); }
static bool a5_gap(size_t a, size_t b) { return b > a && (b - a) <= 4u; }
static int g_a5_dbg = 0;
static void a5_dbg(const char* where, size_t cmd, int stage, const char* why) {
    // the cap was 40 -- with 8 C64 chains x 5 legs x 2 recordings the reject map was cut off,
    // which is why only 2 of the 8 chains could even be discussed in knife2b #78.
    if (!getenv("NR_ATT5_TRACE") || g_a5_dbg >= 900) return;
    ++g_a5_dbg;
    printf("[a5-dbg] %-12s cmd=%zu stage=%d %s\n", where, cmd, stage, why ? why : "");
}

static void a5_note_qw(size_t cmd, int source, int packed, int scale, unsigned M, unsigned K,
                       unsigned height, unsigned width, unsigned across, unsigned pad) {
    if (!a5_on()) return;
    a5_reset();
    a5_dbg("qw", cmd, 0, "");
    // a5-geom: every quant_window the recorder sees, with its full geometry, so the eight C=64
    // chains can be counted and any rejected one traced to the exact field that disagreed.
    if (getenv("NR_ATT5_TRACE") && g_a5_dbg < 900) {
        ++g_a5_dbg;
        printf("[a5-geom] qw cmd=%zu src=%d pk=%d sc=%d M=%u K=%u ih=%u iw=%u across=%u pad=%u\n",
               cmd, source, packed, scale, M, K, height, width, across, pad);
    }
    // A5-HALO (knife2b #82-bu census): the C=64 tier is FOUR window geometries, two chains each --
    //   M=32640 across=30 pad=0        (top 0, left 0)
    //   M=33728 across=31 pad=4        (top 0, left 4)
    //   M=34560 across=30 pad=262144   (top 4, left 0)
    //   M=35712 across=31 pad=262148   (top 4, left 4)
    // all of them 8x8-token windows over the same 136x240 image, and att5::fused already takes
    // top/left/across as parameters (the same -pad_top/-pad_left gather as the shipped qr_kernel,
    // quantize_row_kernel.hpp:54-57) => widening is a PARAMETER job, no numerics change.
    const bool geom_ok = (K == 64u) && (M % 64u == 0u) && across && height && width &&
        (M == 32640u || M == 33728u || M == 34560u || M == 35712u);
    if (!geom_ok) { a5_dbg("qw-REJECT", cmd, 0, "M/K/geom"); return; }
    g_a5.stage = 1; g_a5.c_qw = cmd;
    g_a5.src = source; g_a5.pk = packed; g_a5.sc = scale;
    g_a5.M = M; g_a5.C = K; g_a5.height = height; g_a5.width = width;
    g_a5.across = across; g_a5.pad = pad;
}
static int vit_reuse_level(void);   // fwd (used by the C30 guard helpers below)

// ---- C30 (A) level 6: ONE submit, the reuse decision lives ON THE DEVICE. The criterion
// closure (already before the span) reduces max|delta| / sum|delta| across its items and
// writes a 4-byte flag into device memory; each guarded span kernel tests that flag at its
// entry and returns without writing (so its face keeps the previous frame's value -- the
// section 113.1 lifecycle). vg[0] = the per-frame flag, vg[1+closure] = 1 for closures inside
// the span (filled once at capture), so the same launch site used by window closures is
// untouched. The host never decides anything at this level.
static int* g_vit_vg = nullptr;       // device: [0]=flag, [1+i]=guardable(closure i)
static long long* g_vit_acc = nullptr;  // C31 device: [0]=max, [1]=sum, [2]=arrived (64-bit cells)
static int* g_vit_hf = nullptr;       // malloc_host mirror for the TRACE only (never decides)
// C31: the per-closure gate cell, with NO call-site churn: a header launcher asks for
// vit_gate(g_vit_run_cmd) at enqueue time and the kernel then tests gate[-1] (the frame
// flag) and *gate (this closure is inside the marked span). nullptr => shipped path.
const int* vit_gate(int cmd);
static int* vit_gbuf(void) {
    if (vit_reuse_level() < 6) return nullptr;
    if (!g_vit_vg) g_vit_vg = (int*)sycl::malloc_host(8400u * 4u, *GQ);   // C33: flag + marks + hit cells
    return g_vit_vg;
}
static long long* vit_accbuf(void) {   // C31: 64-bit cells -- the int32 sum overflowed and
                                       // produced NEGATIVE sums in the trace (unacceptable)
    if (!g_vit_acc) g_vit_acc = (long long*)sycl::malloc_device(4u * sizeof(long long), *GQ);
    return g_vit_acc;
}
static int* vit_hfbuf(void) {
    if (!g_vit_hf) g_vit_hf = (int*)sycl::malloc_host(4u * 4u, *GQ);
    return g_vit_hf;
}
const int* vit_gate(int cmd) {
    const int* vg = vit_gbuf();
    if (!vg || cmd < 0 || cmd > 4090) return nullptr;
    return vg + 1 + cmd;     // C33: gate[-1]=the frame flag, gate[4199]=this closure hit cell
}
// the guard, as the FIRST statement of a device kernel: skip this kernel entirely
#define VIT_GUARD(vg, cidx) do { if ((vg) && (vg)[0] && (vg)[1 + (cidx)]) return; } while (0)



static void a5_take_qkv(size_t cmd, int a, int b, int q, int k, int v, int a_scale, int b_scale,
                        int qkv_scale, unsigned M, unsigned channels, unsigned heads,
                        unsigned tokens, unsigned flags) {
    if (!a5_on()) return;
    if (g_a5.stage != 1 || !a5_gap(g_a5.c_qw, cmd)) { a5_dbg("qkv-REJECT", cmd, g_a5.stage, "stage/gap"); a5_reset(); return; }
    a5_dbg("qkv", cmd, g_a5.stage, "");
    if (a != g_a5.pk || a_scale != g_a5.sc || M != g_a5.M || channels != g_a5.C ||
        channels != heads * 32u || tokens != 64u || (flags & ~0x2000u)) { a5_dbg("qkv-REJECT", cmd, g_a5.stage, "tuple"); a5_reset(); return; }
    g_a5.stage = 2; g_a5.c_qkv = cmd;
    g_a5.wqkv = b; g_a5.bsqkv = b_scale; g_a5.qkvsc = qkv_scale;
    g_a5.q = q; g_a5.k = k; g_a5.v = v; g_a5.heads = heads; g_a5.tokens = tokens;
}
static void a5_take_wa(size_t cmd, int q, int k, int v, int bias, int out,
                       unsigned batches, unsigned heads, unsigned merged) {
    if (!a5_on()) return;
    if (g_a5.stage != 2 || !a5_gap(g_a5.c_qkv, cmd)) { a5_dbg("wa-REJECT", cmd, g_a5.stage, "stage/gap"); a5_reset(); return; }
    a5_dbg("wa", cmd, g_a5.stage, "");
    if (q != g_a5.q || k != g_a5.k || v != g_a5.v || heads != g_a5.heads || merged != 1u ||
        heads == 0u || batches % heads || batches / heads * g_a5.tokens != g_a5.M) { a5_dbg("wa-REJECT", cmd, g_a5.stage, "tuple"); a5_reset(); return; }
    g_a5.stage = 3; g_a5.c_wa = cmd; g_a5.bias = bias; g_a5.att = out; g_a5.batches = batches;
}
static void a5_note_quant(size_t cmd, int source, int packed, int scale, unsigned M, unsigned K) {
    if (!a5_on()) return;
    if (g_a5.stage != 3) return;
    if (!a5_gap(g_a5.c_wa, cmd) || source != g_a5.att ||
        M != g_a5.M || K != g_a5.C) { a5_dbg("q2-REJECT", cmd, g_a5.stage, "gap/src/M/K"); a5_reset(); return; }
    a5_dbg("q2", cmd, g_a5.stage, "");
    g_a5.stage = 4; g_a5.c_q2 = cmd; g_a5.pk2 = packed; g_a5.sc2 = scale;
}
struct A5Fuse {
    int wqkv = 0, wo = 0, bsqkv = 0, qkvsc = 0, bias = 0, bs2 = 0, cosine = 0;
    int src = 0, out = 0, q = 0, k = 0, v = 0;
    unsigned M = 0, C = 0, heads = 0, windows = 0, across = 0, top = 0, left = 0, ih = 0, iw = 0;
};
// the window-residual leg = the chain's last op. On a match the four earlier closures become
// no-ops and THIS closure runs att5::fused. Returns false unless every field of the tuple agrees.
static bool a5_take_wres(size_t cmd, int a, int b, int c, int a_scale, int b_scale, int skip,
                         int cosine, unsigned M, unsigned N, unsigned K, unsigned flags,
                         unsigned height, unsigned width, unsigned across, unsigned pad,
                         A5Fuse& outf) {
    if (!a5_on()) return false;
    A5Chain g = g_a5; a5_reset();
    a5_dbg("wres", cmd, g.stage, "");
    // A5-644-dissolved: the C=64 chain's 644 QUANT is not an xmx_rec_quant call at all -- the
    // plan records it as "quant(FUSED-pack)", i.e. the pk2/sc2 production is folded into the
    // consumer (the same P2 mechanism that makes 641 read "quant_window(FUSED-pack)"). The
    // fused attention kernel never reads pk2/sc2 (its P10 fold lives in SLM), so the chain may
    // legally complete from stage 3 as well; 1301 byte-identity is the judge of that claim.
    if (g.stage != 4 && g.stage != 3) { a5_dbg("wres-REJECT", cmd, g.stage, "stage"); return false; }
    const size_t prev = (g.stage == 4) ? g.c_q2 : g.c_wa;
    if (!a5_gap(prev, cmd)) { a5_dbg("wres-REJECT", cmd, g.stage, "gap"); return false; }
    const unsigned epi = (flags >> 8) & 0xFu;
    const bool narrow = (flags & 0x1000u) != 0u, half_skip = (flags & 0x40000u) != 0u;
    // from stage 3 the pk2/sc2 ids are unknown until this very op (the 644 QUANT is dissolved
    // into the consumer), so only stage 4 can require them to match.
    const bool needA = (g.stage == 4);
    if ((needA && (a != g.pk2 || a_scale != g.sc2)) || M != g.M || N != g.C || K != g.C ||
        epi != 1u || !narrow || !half_skip || skip != g.src ||
        height != g.height || width != g.width || across != g.across || pad != g.pad ||
        g.heads != 2u || g.batches == 0u) {
        if (getenv("NR_ATT5_TRACE") && g_a5_dbg < 40) {
            ++g_a5_dbg;
            printf("[a5-dbg] wres-TUPLE cmd=%zu a=%d pk2=%d as=%d sc2=%d M=%u N=%u K=%u epi=%u narrow=%d half=%d skip=%d src=%d ih=%u iw=%u ac=%u pad=%u heads=%u batches=%u\n",
                   cmd, a, g.pk2, a_scale, g.sc2, M, N, K, epi, (int)narrow, (int)half_skip,
                   skip, g.src, height, width, across, pad, g.heads, g.batches);
        }
        return false; }
    // THE RULE: all four or none.
    // A5-NOOP-GUARD: c_q2 is only a real index when the chain passed through a recordable 644
    // QUANT. From stage 3 it is still 0 -- no-oping g_cmds[0] would kill an unrelated closure.
    g_cmds[g.c_qw]  = [](){}; g_cmd_names[g.c_qw]  = "quant_window(A5-fused)";
    g_cmds[g.c_qkv] = [](){}; g_cmd_names[g.c_qkv] = "gemm_int8_qkv(A5-fused)";
    g_cmds[g.c_wa]  = [](){}; g_cmd_names[g.c_wa]  = "window_attention(A5-fused)";
    if (g.stage == 4 && g.c_q2) { g_cmds[g.c_q2] = [](){}; g_cmd_names[g.c_q2] = "quant(A5-fused)"; }
    if (g.stage == 3) { g.pk2 = a; g.sc2 = a_scale; }   // recorded for the witness only
    // A5-TOUCH: the fused closure also reads/writes the Q/K/V planes (they are its internal
    // faces now that 642/643 are no-ops), but 645's own pgraph_ids() never listed them. touch
    // tokens here are DEVICE POINTERS and "same pointer in two closures = conflict (any
    // direction)" (libxmx_sycl.cpp:118-143), so an unlisted plane lets the scheduler overlap
    // another closure that touches the same memory -- exactly the signature of the 82.6%
    // scattered numeric divergence on real plan data (knife2b #82/#83). pgraph_extra() exists
    // for out-of-band touched buffers.
    // ① A/B: NR_ATT5_TOUCH=0 drops the out-of-band declarations (everything else identical).
    // If the ON side still lands 1301 EXACT with them off, the declaration is not required;
    // if it goes MISMATCH (or the [skip-chains] counters move), it is a precondition of wiring.
    // (1) A/B RESULT, knife2b #87: declaring the Q/K/V + pk/sc planes with pgraph_extra() turned
    // out NOT to be required -- builds\libxmx_att5k.dll with NR_ATT5_TOUCH=0 still gave
    // 1301 = DD49827D EXACT with the same [skip-chains] counters (closures=691 names=1382
    // name_offset=691 chains_skipped=14 refused=0 closures_noop=168). So the declaration is
    // removed again: fewer implicit dependencies, and the byte-identity gate is the judge.
    // Caveat kept on the record: "not required here" is an observation about THIS plan, not a
    // proof that no other closure ever overlaps those planes -- if a future tier fires the
    // fusion, re-run the same A/B before trusting the overlap freedom.
    ++g_a5_fires; ++g_a5_fires_gen;
    outf = A5Fuse{ g.wqkv, b, g.bsqkv, g.qkvsc, g.bias, b_scale, cosine,
                   g.src, c, g.q, g.k, g.v,
                   g.M, g.C, g.heads, g.batches / g.heads, across,
                   pad >> 16, pad & 0xffffu, height, width };
    if (getenv("NR_ATT5_TRACE"))
        printf("[a5-fire] n=%ld M=%u C=%u heads=%u windows=%u across=%u pad=%u img=%ux%u"
               " noop=%zu/%zu/%zu/%zu fused@%zu WKeyQKV=(%d,%d,%d,0) WKeyPROJ=(%d,%d,%d,0)"
               " qkv=%d/%d/%d pk=%d/%d pk2=%d/%d 1267=%d 1270=%d 1277=%d bias=%d\n",
               g_a5_fires, g.M, g.C, g.heads, g.batches / g.heads, across, pad, height, width,
               g.c_qw, g.c_qkv, g.c_wa, g.c_q2, cmd,
               g.wqkv, (int)(3u * g.C), (int)g.C,
               b, (int)g.C, (int)g.C,
               g.q, g.k, g.v, g.pk, g.sc, g.pk2, g.sc2, g.src, c, g.att, g.bias);
    return true;
}
static void a5_att_run(const A5Fuse& f) {
    auto P = [&](int id, size_t bytes, const char* what) -> void* {
        auto it = g_bufs.find(id);
        if (it == g_bufs.end())
            throw std::runtime_error(std::string("a5: ") + what + " not live at run");
        if (it->second.bytes < bytes)
            throw std::runtime_error(std::string("a5: ") + what + " smaller than needed at run");
        return it->second.p;
    };
    const size_t pl = (size_t)f.M * f.C * 2u, img = (size_t)f.ih * f.iw * f.C * 2u;
    // a5-sizes: the RUN-TIME operand ledger (the record-time trace cannot see the real sizes --
    // the plan is first recorded with tiny placeholders, the step-2588 lesson). If 1267/1270 are
    // not `img` bytes, or Q/K/V are not `pl`, the matcher bound the wrong plan buffers.
    if (getenv("NR_ATT5_TRACE")) {
        auto SZ = [&](int id) -> size_t { auto it = g_bufs.find(id); return it == g_bufs.end() ? 0 : it->second.bytes; };
        // one line per operand: no format/argument miscount is possible this way
        printf("[a5-op] img_want=%zu plane_want=%zu\n", img, pl);
        printf("[a5-op] src1267 id=%d bytes=%zu ptr=%p\n", f.src, SZ(f.src), P(f.src, 1, "ptr-probe-src"));
        printf("[a5-op] out1270 id=%d bytes=%zu ptr=%p\n", f.out, SZ(f.out), P(f.out, img, "ptr-probe-out1270"));
        printf("[a5-op] faceQ id=%d bytes=%zu ptr=%p\n", f.q, SZ(f.q), P(f.q, pl, "ptr-probe-faceQ"));
        printf("[a5-op] faceK id=%d bytes=%zu ptr=%p\n", f.k, SZ(f.k), P(f.k, pl, "ptr-probe-faceK"));
        printf("[a5-op] faceV id=%d bytes=%zu ptr=%p\n", f.v, SZ(f.v), P(f.v, pl, "ptr-probe-faceV"));
        printf("[a5-op] bias id=%d bytes=%zu (want %zu)\n", f.bias, SZ(f.bias), (size_t)f.heads * 4096u * 4u);
        printf("[a5-op] qkv_scale id=%d bytes=%zu (want %zu)\n", f.qkvsc, SZ(f.qkvsc), (size_t)f.heads * 4u);
        printf("[a5-op] qkv_bscale id=%d bytes=%zu (want %zu)\n", f.bsqkv, SZ(f.bsqkv), (size_t)(3u * f.C) * 4u);
        printf("[a5-op] wres_bscale id=%d bytes=%zu (want %zu)\n", f.bs2, SZ(f.bs2), (size_t)f.C * 4u);
        printf("[a5-op] cosine id=%d bytes=%zu (want %zu)\n", f.cosine, SZ(f.cosine), (size_t)f.C * 4u);
        printf("[a5-op] W81 id=%d bytes=%zu (want %zu)\n", f.wqkv, SZ(f.wqkv), (size_t)(3u * f.C) * f.C);
        printf("[a5-op] W79 id=%d bytes=%zu (want %zu)\n", f.wo, SZ(f.wo), (size_t)f.C * f.C);
        fflush(stdout);
    }
    sycl::half* dImg = (sycl::half*)P(f.src, img, "1267");
    sycl::half* Out2 = (sycl::half*)P(f.out, img, "1270");
    sycl::half* Q  = (sycl::half*)P(f.q, pl, "Q");
    sycl::half* Kk = (sycl::half*)P(f.k, pl, "K");
    sycl::half* V  = (sycl::half*)P(f.v, pl, "V");
    const float* bias = (const float*)P(f.bias, (size_t)f.heads * 4096u * 4u, "bias");
    const float* qs  = (const float*)P(f.qkvsc, (size_t)f.heads * 4u, "qkv_scale");
    const float* bs  = (const float*)P(f.bsqkv, (size_t)(3u * f.C) * 4u, "qkv b_scale");
    const float* bs2 = (const float*)P(f.bs2, (size_t)f.C * 4u, "wres b_scale");
    const float* cp  = (const float*)P(f.cosine, (size_t)f.C * 4u, "cosine");
    int8_t* Wq = (int8_t*)P(f.wqkv, (size_t)(3u * f.C) * f.C, "W81 raw");
    int8_t* Wo = (int8_t*)P(f.wo, (size_t)f.C * f.C, "W79 raw");
    // the SAME cache keys the split legs use (knife2b #75 item 3: no new key; the trace prints the
    // four-tuples so a mixup with the FFN wide/diag keys cannot pass silently).
    const int8_t* dBp = cached_pack_b_i8(f.wqkv, Wq, (int)(3u * f.C), (int)f.C);
    const int8_t* dOp = cached_pack_b_i8(f.wo, Wo, (int)f.C, (int)f.C);
    att5::Outlets o;                 // DUMP=false: every outlet stays null and folds away
     att5::fused<64, 2, 5, false, false>(*GQ, dImg, dBp, bs, qs, bias, dOp, bs2, cp, Out2,
                                        Q, Kk, V, f.windows, f.across, f.top, f.left,
                                        f.ih, f.iw, o);   // C33: per-closure gate cell (was the bare flag base)
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
// ---- B step 3 (knife2b #110): scratch VERSIONING of the int8 packed face + row-scale plane ----
// What it is: the plan re-uses ONE physical buffer (runtime ids 1305 = 9,142,272 B packed face,
// 1306 = 142,848 B row scale; the plan-table twins are 1272/1273) for every quant producer and
// its consumer. That reuse is what pins the frame into a total chain: the engine's own greedy
// wave planner, replayed offline on the recorded touch sets, gives waves=691 / maxwidth=1 /
// critical path = the whole serial sum (s6/pe_b3_price.py), and these two ids hold 396 of the
// 690 consecutive links EACH. Versioning rotates the LOGICAL ids through a ring of K physical
// groups: same bytes, same values, same producer->consumer distance -- only which allocation a
// group lands in changes, so the dependency graph loosens for the later reorder/merge cuts.
// GATED: NR_SCRATCH_PRIV unset/0 => sp_advance() returns at its first line and the frame is
// bit-identical. NR_SCRATCH_PRIV_IDS overrides the id set; NR_SCRATCH_PRIV_K sets the ring
// depth (default 4 = the approved budget: 3 extra copies x (9,142,272 + 142,848) B = 26.6 MiB;
// slot 0 reuses today's buffer, so nothing leaks).
static bool sp_on() {
    static int v = -1;
    if (v < 0) { const char* e = getenv("NR_SCRATCH_PRIV"); v = (e && atoi(e) != 0) ? 1 : 0; }
    return v == 1;
}
// Versioning targets are chosen by ROLE = exact byte size, not by id: the plan buffers keep
// ids 1..1301 in BOTH recordings while each recording also creates ~12 runtime scratch
// buffers, and the chain-holding planes are runtime ids 1305 (9,142,272 B int8 packed
// face) and 1306 (142,848 B row scale) -- created only in the second recording. Keying
// off fixed ids therefore versioned the wrong 512-byte placeholders (extra_bytes=1536,
// touch graph unchanged -- caught by the declared-set check in s6/pe_b3_check.py).
// The sizes are unique across the whole [bufnew] census, so size-role matching is exact.
// NR_SCRATCH_PRIV_SIZES overrides the list.
static std::set<unsigned long long> sp_sizes() {
    static std::set<unsigned long long> s;
    if (!s.empty()) return s;
    const char* e = getenv("NR_SCRATCH_PRIV_SIZES");
    if (e && *e) { const char* p = e; while (p && *p) { unsigned long long v = strtoull(p, 0, 0); if (v) s.insert(v); p = strchr(p, ','); if (p) ++p; } }
    else { s.insert(9142272ull); s.insert(142848ull); }
    return s;
}
static std::set<int> g_sp_live;
static void sp_note_created(int id, unsigned long long bytes) {
    if (!sp_on()) return;
    if (sp_sizes().count(bytes)) g_sp_live.insert(id);
}
static std::map<int, std::vector<void*>> g_sp_ring;   // logical id -> physical ring
static std::map<int, size_t> g_sp_pos;
static size_t g_sp_extra_bytes = 0;
static void sp_advance() {
    if (!sp_on()) return;
    int K = getenv("NR_SCRATCH_PRIV_K") ? atoi(getenv("NR_SCRATCH_PRIV_K")) : 4;
    if (K < 1) K = 1;
    for (int id : g_sp_live) {
        auto it = g_bufs.find(id);
        if (it == g_bufs.end()) continue;
        std::vector<void*>& r = g_sp_ring[id];
        if (r.empty()) {
            r.push_back(it->second.p);                       // slot 0 = today's buffer, nothing leaks
            for (int kk = 1; kk < K; ++kk) {
                void* p = sycl::malloc_device(it->second.bytes, *GQ);
                if (!p) { std::printf("[scrpriv] REFUSED: malloc %zu B for id=%d\n", it->second.bytes, id); std::fflush(stdout); return; }
                r.push_back(p); g_sp_extra_bytes += it->second.bytes;
            }
        }
        size_t& s = g_sp_pos[id];
        s = (s + 1) % r.size();
        it->second.p = r[s];                                 // re-point the logical id for this group
    }
}

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
    g_bufs[id] = { p, (size_t)bytes, (size_t)(kind == 0 ? 2 : kind), false, g_gen };
    sp_note_created(id, bytes);   // B step 3: register versioning targets by role
    if (getenv("NR_BUFNEW")) {   // presence-gated, host print only (rules 4/9)
        // during_closure = how many closures have been pushed so far, i.e. which op was being
        // recorded when this buffer appeared. (An earlier draft indexed g_cmd_names with an
        // out-of-range expression -- caught by inspection before any run.)
        std::printf("[bufnew] id=%d bytes=%zu kind=%d recording=%d during_closure=%zu\n",
                    id, (size_t)bytes, kind, g_recording ? 1 : 0, g_cmds.size());
        std::fflush(stdout);
    }
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
    g_bufs[id] = { p, (size_t)bytes, (size_t)esz, true, g_gen };
    if (getenv("NR_BUFNEW")) { std::printf("[bufnew] id=%d bytes=%zu esz=%zu IMPORTED during_closure=%zu\n",
                            id, (size_t)bytes, (size_t)esz, g_cmds.size()); std::fflush(stdout); }
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

static void vit_reset(void);   // fwd: the C25 NR_VIT_REUSE record-scoped notes (block below)
int xmx_begin(void) { g_lcount_on = getenv("NR_LCOUNT") != nullptr; g_lc_cur = -1; g_lc_skipped = 0;
    ++g_gen; g_recording = true; g_cmds.clear();
    g_sp_live.clear();   // B step 3: the versioned ids are per recording
    // B step 1 (knife2b #106): the record-scoped side vectors start empty with the stream,
    // exactly like g_cmds. Clearing only at capture was wrong: the plan records TWICE (the
    // scratch recording, then OP_XMX_ABORT, then the kept recording) and the census runs at
    // capture time -- so at that moment the new vectors still held both recordings (1382) while
    // g_cmds held only the kept one (691). That is the same class of bug as section 85.
    g_cmds_group.clear(); g_cmds_poolblk.clear(); g_pg_ids_snap.clear(); g_cmds_launch.clear(); g_cmds_name.clear();
    // AUDIT FIX (10-27): the fold registries are RECORD-scoped (qcmd = an index into
    // g_cmds). A stale entry from a PREVIOUS recording -- scratch/probe recordings, or
    // a plan switch (768x448 <-> 960x544, different op streams) -- could dissolve the
    // WRONG closure in the new stream. Same-plan frames re-register identical keys so
    // this was invisible, but it is a real cross-recording hazard. Clear at both ends.
    g_quant_pk.clear(); g_fused_quant.clear();
    g_pending_fold_slot = SIZE_MAX; g_fold_slot.clear();
    s6_reset();   // S6: the chain candidate's cmd indices are RECORD-scoped
    vit_reset();  // C25: the ViT-chain notes are RECORD-scoped too (the plan records twice)
    return 0; }
int xmx_abort(void) { g_recording = false; g_cmds.clear(); g_cmds_touch.clear();
    g_cmds_group.clear(); g_cmds_poolblk.clear(); g_pg_ids_snap.clear(); g_cmds_launch.clear(); g_cmds_name.clear();
    g_quant_pk.clear(); g_fused_quant.clear();
    g_pending_fold_slot = SIZE_MAX; g_fold_slot.clear();
    s6_reset();
    vit_reset();   // C25 (rule: clear the record-scoped registries at BOTH ends)
    return 0; }

// ==================== NR_SKIP_CHAINS: whole-block-chain skip (2026-11-02, B2 跳块铲) ====
// What this is: a quality-for-speed blade on the SHIPPED engine. The frame's captured graph
// is 52 QUANT_WINDOW-anchored block chains (tools/chain_scan.py -> E:/DSH/s6/chain_map.csv;
// chain k = the k-th xmx_rec_quant_window closure in graph order, running to its terminating
// xmx_rec_gemm_int8_residual closure). NR_SKIP_CHAINS=<comma separated chain numbers> turns
// a whole chain into no-ops at CAPTURE time -- the same "all legs or none" rule S6-1a uses
// (libxmx_sycl.cpp:514-520): a half-skipped chain reads pk/dC scratch and a chain-internal
// skip face that its own skipped legs never wrote, so partial skip is forbidden.
//
// WHY A WHOLE-CHAIN NO-OP IS RESIDUAL-CONNECTED (the correctness point): every chain's
// terminal leg is c = A*B + skip with out=1267 (the one global residual face) and skip = a
// CHAIN-INTERNAL face (1270 / 1279 / 1281 / 1283 / 1288 / 1297, chosen by tier). Killing all
// closures of a chain leaves 1267 exactly as the previous surviving writer left it, and the
// next chain's QUANT_WINDOW + attention-residual legs read 1267 fresh. That is the identity
// block: the residual stream stays connected, no face goes stale, no pyramid tier is jumped.
//
// REFUSED chains (hard guard, printed not guessed): a chain that does NOT terminate at
// xmx_rec_gemm_int8_residual (k=51, the last decoder block -- its attention leg feeds the
// network head) or whose range contains an op outside the pure-block family set (the
// tier-transition chains k=3,9,17,25,33,41,47 carry the UNARY+GEMM patch-merge legs; no-oping
// one would leave the NEXT tier reading a face of the wrong geometry). The 8-bit census:
// 44 of 52 chains are skippable (C64 x6, C128 x10, C256 x14, C512 x14).
//
// Composition with S6-1a (NR_S6_FFN default ON): S6 rewrote five chain legs into no-ops at
// RECORD time and made the residual closure run the fused kernel. This pass runs at CAPTURE
// time, i.e. after S6, and kills whatever body the residual closure now carries -- so a
// skipped chain is dead in both forms, and the FFN fusion is not bypassed, it is subsumed.
//
// Military rules 4/9: the switch is closure-level only (bodies replaced before the device
// ops are recorded), it adds NO runtime branch inside any kernel, and with an empty/absent
// NR_SKIP_CHAINS the code path is not entered at all -- the shipped binary behaves verbatim.
// passes stays 691 (a no-op closure emits zero device ops; the closure COUNT is unchanged),
// and the captured cgraph's node count drops by the killed launches. NR_SKIP_MAP=1 prints the
// full 52-chain segmentation for cross-checking against chain_map.csv (host-side, record time).
static const std::vector<int>& skip_chain_set() {
    static std::vector<int> v = [](){
        std::vector<int> out;
        const char* s = getenv("NR_SKIP_CHAINS");
        if (s) {
            const char* p = s;
            while (*p) {
                char* e = nullptr;
                long n = strtol(p, &e, 10);
                if (e != p) { out.push_back((int)n); p = e; }
                else ++p;
            }
        }
        return out;
    }();
    return v;
}
static bool sc_is(const char* n, const char* w) { return n && strcmp(n, w) == 0; }
static bool sc_open(const char* n) { return sc_is(n, "xmx_rec_quant_window"); }
static bool sc_term(const char* n) { return sc_is(n, "xmx_rec_gemm_int8_residual"); }
static bool sc_head(const char* n) {
    return sc_is(n, "xmx_rec_ffn") || sc_is(n, "xmx_rec_ffn_stem") ||
           sc_is(n, "xmx_rec_ffn_merge") || sc_is(n, "xmx_rec_window_block") ||
           sc_is(n, "xmx_rec_unary2");
}
// the pure-block op families (chain_map.csv `pure` column): anything else inside a chain
// range means the chain carries a tier-transition leg -> not skippable.
static bool sc_pure(const char* n) {
    static const char* k[] = { "xmx_rec_quant_window", "xmx_rec_gemm_int8_qkv",
        "xmx_rec_window_attention", "xmx_rec_quant", "xmx_rec_gemm_window_int8_residual",
        "xmx_rec_gemm_int8_batched", "xmx_rec_gemm", "xmx_rec_gemm_int8",
        "xmx_rec_gemm_int8_residual" };
    for (const char* w : k) if (sc_is(n, w)) return true;
    return false;
}
static std::set<size_t> g_skipped_cmds;   // closure indices the skip pass no-op'd (knife 1 reads it)
static void skip_chains_apply(std::vector<std::function<void()>>& cmds,
                              const std::vector<const char*>& names, int graphid) {
    const std::vector<int>& want = skip_chain_set();
    const bool mapmode = getenv("NR_SKIP_MAP") != nullptr;
    if (want.empty() && !mapmode) return;
    // 军规 13 alignment: the plan records TWICE (scratch BEGIN@3922 -> ABORT@5295, then the
    // captured graph BEGIN@5308 -> GRAPH_CAPTURE@6644). xmx_abort drops g_cmds but NOT
    // g_cmd_names, so names can carry the aborted recording's prefix. The graph region is
    // the TAIL of the name list; slice it by offset and print the offset so the mapping is
    // auditable (both recordings are the same 691-op stream, so run_timing never noticed).
    if (names.size() < cmds.size()) {
        std::printf("[skip-chains] graph=%d REFUSED: cmds=%zu names=%zu (names shorter)\n",
                    graphid, cmds.size(), names.size());
        std::fflush(stdout);
        return;
    }
    const size_t off = names.size() - cmds.size();
    if (off && (off % cmds.size()) != 0) {
        std::printf("[skip-chains] graph=%d REFUSED: name offset %zu not a whole recording\n",
                    graphid, off);
        std::fflush(stdout);
        return;
    }
    auto nm = [&](size_t i) { return names[i + off]; };
    struct Ch { size_t a; size_t b; bool term; };
    std::vector<Ch> ch;
    const size_t n = cmds.size();
    for (size_t i = 0; i < n; ++i) {
        if (!sc_open(nm(i))) continue;
        Ch c{ i, n - 1, false };
        for (size_t j = i; j < n; ++j) {
            if (j > i && (sc_open(nm(j)) || sc_head(nm(j)))) { c.b = j - 1; break; }
            if (sc_term(nm(j))) { c.b = j; c.term = true; break; }
        }
        ch.push_back(c);
        i = c.b;
    }
    std::printf("[skip-chains] graph=%d closures=%zu names=%zu name_offset=%zu chains=%zu "
                "NR_SKIP_CHAINS='%s'\n", graphid, n, names.size(), off, ch.size(),
                getenv("NR_SKIP_CHAINS") ? getenv("NR_SKIP_CHAINS") : "");
    if (mapmode) {
        for (size_t k = 0; k < ch.size(); ++k) {
            int pure = 1;
            for (size_t i = ch[k].a; i <= ch[k].b; ++i) if (!sc_pure(nm(i))) { pure = 0; break; }
            std::printf("[skip-map] chain=%2zu closures %3zu..%3zu n=%2zu term=%d pure=%d\n",
                        k, ch[k].a, ch[k].b, ch[k].b - ch[k].a + 1, (int)ch[k].term, pure);
        }
    }
    size_t noops = 0, skipped = 0, refused = 0;
    for (int wk : want) {
        if (wk < 0 || (size_t)wk >= ch.size()) {
            std::printf("[skip-chains] chain=%d OUT OF RANGE (valid 0..%zu) -- ignored\n",
                        wk, ch.size() - 1);
            ++refused; continue;
        }
        const Ch& c = ch[wk];
        int pure = 1;
        for (size_t i = c.a; i <= c.b; ++i) if (!sc_pure(nm(i))) { pure = 0; break; }
        if (!c.term || !pure) {
            std::printf("[skip-chains] chain=%d REFUSED closures %zu..%zu (n=%zu term=%d pure=%d): "
                        "tier-transition / head-adjacent -- skipping would leave the next tier "
                        "or the head reading a stale face\n",
                        wk, c.a, c.b, c.b - c.a + 1, (int)c.term, pure);
            ++refused; continue;
        }
        for (size_t i = c.a; i <= c.b; ++i) { cmds[i] = [](){}; g_skipped_cmds.insert(i); ++noops; }
        ++skipped;
        std::printf("[skip-chains] chain=%d SKIPPED closures %zu..%zu (%zu no-ops): %s .. %s\n",
                    wk, c.a, c.b, c.b - c.a + 1, nm(c.a), nm(c.b));
    }
    std::printf("[skip-chains] graph=%d chains_skipped=%zu refused=%zu closures_noop=%zu "
                "passes=%zu (unchanged)\n", graphid, skipped, refused, noops, n);
    std::fflush(stdout);
}

// ==================== NR_VIT_REUSE (C25, 2026-11-09): adaptive ViT-chain reuse =========
// Quality-for-speed blade (rule 156: it CHANGES THE PICTURE; the user judges it on real
// hardware). When the ViT segment's input has not moved since the frame that last ran it,
// the 8 ViT attention chains do not have to run: the faces they write are PLAN faces
// (1275/1274/1276/1277/1285 -- created by OP_BUF in the kept recording, plan idx 4516-4534,
// never destroyed, never re-zeroed per frame: the only zero is OP_XMX_BUF_ZERO 1285 at 4517,
// at plan build), so NOT re-running the chain = re-reading last frame's values.
// Census (rule 189, tools/wb_c25_census.py + wb_c25_faces.py on plan_960x544.c):
//   chain = QUANT(1267->1286,1287) -> GEMM_INT8_QKV(1286,w -> 1275,1274,1276, flags 0x2000
//   vit) -> GLOBAL_ATTENTION(1275,1274,1276 -> 1277) -> QUANT(1277->1286,1287) [dissolved:
//   "quant(FUSED-pack)"] -> GEMM_INT8_RESIDUAL(1286,w -> 1285, skip=1267, flags 0x41100).
//   fused route: closures 318..385 (GA at 320,329,...,383) = 40 closures / 88 launches /
//   leg 8.000 ms of the 120.206 ms serial frame (tools/FRT_fused_leg2.txt, 11-09 04:03).
//   plain route: the same pattern at 317..384 (GA at 319,...,382), 691 closures.
// Why the residual stream stays legal (rule 183): the FFN closures (QUANT(1285->...) +
// GEMM_INT8 + RES writing 1267) are NOT in the skip set, so 1267 keeps being written every
// frame and the downstream window chains never read a face nobody wrote. The only face read
// stale is 1285 -- which IS the reuse. 1286/1287 are overwritten by the next surviving QUANT.
// Mechanism: the shipped dissolution machinery only, no branch inside any kernel:
//   * record time: vit_note_qkv / vit_note_quant remember the chain closure indices;
//   * capture time (xmx_graph_capture, after the skip and bmerge passes): a TWIN graph with
//     the SAME closure count is stored, the chain bodies replaced by g_cmds[i] = [](){}
//     (the :449/:467/:502/:1061-1064 mechanism; "closure count unchanged, only the body
//     changes" -- :676/:908);
//   * the criterion runs INSIDE the first chain's opening QUANT body (that closure survives
//     in the twin, so the verdict keeps being produced on skipped frames): one extra
//     parallel_for compares the face with a shadow and writes per-item mismatch counts into
//     SHARED memory. No readback node and no host sync: the shipped cgraph replay ends with
//     ext_oneapi_graph(...).wait() (:2542), so the host reads the counters after the frame
//     and picks master/twin for the NEXT frame (1-frame lag -- a static scene is static).
//   * NR_VIT_REUSE=0/unset OFF (shipped path verbatim); =1 criterion; =2 always skip
//     (the quality instrument); =3 criterion runs, never skips (prices the criterion).
// Guards: the twin is REFUSED if NR_BMERGE is live (a merged group could carry a skipped
// member's write) or if the name pattern does not match exactly (printed, not guessed).
// =====================================================================================
// C35: ONE engine-wide configuration table, read ONCE at init (never per frame, no queue
// op, no statement outside a parallel_for -- rules 132/149). Priority, highest first:
//   (1) environment variable   (our test legs; NR_VIT_PERIOD=4 etc.)
//   (2) config file  E:\\DSH\\out\\nr_ship.conf   (key = value, one per line,
//       '#' comments, CRLF and a UTF-8 BOM both tolerated)
//   (3) the built-in default in the table below.
// A missing file, a garbage value or an unknown key NEVER fails the engine: unknown keys are
// ignored with one line printed, out-of-range values are clamped into [min,max] and logged.
// Adding a knob later = add ONE row to the table (and read it through nr_cfg_*); nothing else.
// Deliberately NOT in the table: cgraph / skip-chains / cache paths -- those change capture or
// certification and stay env-only (rules 147/148/183).
// =====================================================================================
struct NrCfgKey { const char* name; const char* env; int is_float; double def, lo, hi; };
static const NrCfgKey g_nr_keys[] = {
    { "vit_reuse",        "NR_VIT_REUSE",        0,   1.0,   0.0,      1.0 },
    { "vit_mode",         "NR_VIT_MODE",         0,   1.0,   1.0,      3.0 },   // lmxx 1..3
    { "vit_period",       "NR_VIT_PERIOD",       0,  16.0,   1.0,     16.0 },   // lmxx hard cap
    { "vit_global",       "NR_VIT_GLOBAL",       1,   1.0,   0.0, 1000000.0 },
    { "vit_local",        "NR_VIT_LOCAL",        1,  50.0,   0.0, 1000000.0 },
    { "vit_image",        "NR_VIT_IMAGE",        1,   1.0,   0.0, 1000000.0 },
    { "vit_reset_gap_ms", "NR_VIT_RESET_GAP_MS", 0, 500.0,   1.0, 3600000.0 },
    { "vit_trace",        "NR_VIT_TRACE",        0,   1.0,   0.0,      1.0 },
    { "nr_fused_synth",   "NR_FUSED_SYNTH",      0,   0.0,   0.0,      1.0 },   // parsed + logged
    { "nr_run_timing",    "NR_RUN_TIMING",       0,   0.0,   0.0, 100000.0 },   // (no behaviour
};                                                                               //  change: the
static const int NR_NKEYS = (int)(sizeof(g_nr_keys) / sizeof(g_nr_keys[0]));     //  engine still
static double g_nr_val[NR_NKEYS];                                                //  reads env)
static int g_nr_clamped = 0;
static int nr_cfg_find(const char* name) {
    for (int i = 0; i < NR_NKEYS; ++i)
        if (std::strcmp(g_nr_keys[i].name, name) == 0) return i;
    return -1;
}
static void nr_cfg_load(void) {
    for (int i = 0; i < NR_NKEYS; ++i) g_nr_val[i] = g_nr_keys[i].def;
    FILE* fp = std::fopen("E:\\DSH\\out\\nr_ship.conf", "r");
    int nkeys = 0;
    if (fp) {
        char ln[512];
        if (!std::fgets(ln, sizeof ln, fp)) { /* empty file is fine */ }
        else {
            int at = 0; if ((unsigned char)ln[0] == 0xEF && (unsigned char)ln[1] == 0xBB && (unsigned char)ln[2] == 0xBF) at = 3;
            std::string s0(ln + at);
            for (;;) {
                size_t h = s0.find('#'); if (h != std::string::npos) s0 = s0.substr(0, h);
                size_t e = s0.find('=');
                if (e != std::string::npos) {
                    std::string k = s0.substr(0, e), val = s0.substr(e + 1);
                    auto trim = [](std::string& t) {
                        size_t a = t.find_first_not_of(" \t\r\n");
                        size_t b = t.find_last_not_of(" \t\r\n");
                        t = (a == std::string::npos) ? std::string() : t.substr(a, b - a + 1);
                    };
                    trim(k); trim(val);
                    int idx = nr_cfg_find(k.c_str());
                    if (idx < 0) std::printf("conf: unknown key %s (ignored)\n", k.c_str());
                    else {
                        double x = std::strtod(val.c_str(), nullptr);
                        if (val.empty()) { /* keep default */ }
                        else { g_nr_val[idx] = x; ++nkeys; }
                    }
                }
                if (!std::fgets(ln, sizeof ln, fp)) break;
                at = 0; s0 = std::string(ln);
            }
        }
        std::fclose(fp);
    }
    for (int i = 0; i < NR_NKEYS; ++i) {
        const char* z = g_nr_keys[i].env ? std::getenv(g_nr_keys[i].env) : nullptr;
        if (z && *z) { g_nr_val[i] = std::strtod(z, nullptr); }     // env wins over the file
        double& x = g_nr_val[i];
        const NrCfgKey& K = g_nr_keys[i];
        if (!(x == x) || x < K.lo || x > K.hi) {                    // NaN / out of range => clamp
            std::printf("conf clamped: %s = %g -> [%g, %g]\n", K.name, x, K.lo, K.hi);
            x = (x < K.lo) ? K.lo : K.hi; if (!(x == x)) x = K.def;
            ++g_nr_clamped;
        }
    }
    std::printf("conf loaded: %d keys, clamped: %d\n", nkeys, g_nr_clamped);
    std::printf("[vit-cfg] reuse=%d mode=%d period=%d reset_gap_ms=%d global=%g local=%g image=%g trace=%d\n",
                (int)g_nr_val[0], (int)g_nr_val[1], (int)g_nr_val[2], (int)g_nr_val[6],
                g_nr_val[3], g_nr_val[4], g_nr_val[5], (int)g_nr_val[7]);
    std::fflush(stdout);
}
static int nr_cfg_i(const char* name) {
    static int loaded = (nr_cfg_load(), 1); (void)loaded;
    int i = nr_cfg_find(name); return (i < 0) ? 0 : (int)g_nr_val[i];
}
static double nr_cfg_d(const char* name) {
    static int loaded = (nr_cfg_load(), 1); (void)loaded;
    int i = nr_cfg_find(name); return (i < 0) ? 0.0 : g_nr_val[i];
}
static int vit_period_value(void) { return nr_cfg_i("vit_period"); }
// period-mode state -- host side only, no device memory involved at all.
static unsigned long g_vit_pframe = 0;
static long long g_vit_prev_run_ms = 0;
static int g_vit_recap = 1;
static long long vit_now_ms(void) {
    return (long long)std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
}
// one line per frame: frame, mode, decision, period, idx_in_period, reset_reason, global, local,
// image. NR_VIT_TRACE=0 (env or conf) turns it off. Path: out\\nr_vit_trace.log.
static void vit_period_log(int mode, int decision, int period, unsigned long idx, const char* why) {
    if (!nr_cfg_i("vit_trace")) return;
    static FILE* fp = nullptr;
    static unsigned long frame = 0;
    if (!fp) {
        fp = std::fopen("E:\\DSH\\out\\nr_vit_trace.log", "a");
        if (!fp) return;
    }
    ++frame;
    std::fprintf(fp, "%lu,%d,%s,%d,%lu,%s,%g,%g,%g\n", frame, mode,
                 decision ? "twin" : "master", period, idx, why,
                 nr_cfg_d("vit_global"), nr_cfg_d("vit_local"), nr_cfg_d("vit_image"));
    std::fflush(fp);
}

static int vit_reuse_level() {
    static int v = nr_cfg_i("vit_reuse");   // C35: env > out/nr_ship.conf > built-in (1 = ON)
    return v;
}
static const int VIT_U4PER = 16;                    // uint4 words per criterion item
struct VitQNote { size_t cmd; int src; int packed, scale; unsigned M, K; };
struct VitQkvNote { size_t cmd; unsigned ch, heads, tokens; int src; unsigned M, K; };
struct VitChain { size_t qkv, from, to, qcmd; int srcid, scaleid; unsigned M, K; };
struct VitGemmNote { size_t cmd; int a, c; unsigned M, N, K; };      // S2: the ViT entry GEMM
struct VitUnaryNote { size_t cmd; int a, b, c, d; unsigned n; };     // S2: the patch-merge UNARY
static std::vector<VitQNote> g_vit_qnotes;          // record-scoped (cleared with the stream)
static std::vector<size_t>   g_vit_qkvs;            // record-scoped vit QKV closure indices
static std::vector<VitGemmNote>  g_vit_gemm;        // record-scoped GEMM notes
static std::vector<VitUnaryNote> g_vit_unary;       // record-scoped UNARY notes
static std::vector<VitChain> g_vit_chains;          // resolved at capture time
static std::vector<char> g_vit_kill;                // C27: per-closure "dissolve in the twin"
static size_t g_vit_span_from = 0, g_vit_span_to = 0;   // the dissolved span (S2)
static std::vector<std::function<void()>> g_vit_twincmds;
// ---- C29 (NR_VIT_REUSE=4): the SAME-FRAME split. The twin of C25-C28 had the right saving
// but the wrong semantics: its verdict is computed inside frame N-1 from 1271(N-1) vs
// 1271(N-2), so it can never certify the frame it gates. Level 4 splits the frame at the
// criterion closure: A = [0..criterion], Bm = the rest computed, Bt = the rest with the ViT
// segment dissolved. The host reads THIS frame's counters (malloc_host: a plain deref, no
// driver call) between the two submits, so produce and consume happen in the same frame.
static std::vector<std::function<void()>> g_vit_A, g_vit_Bm, g_vit_Bt;
static std::vector<const char*> g_vit_Anm, g_vit_Bmnm, g_vit_Btnm;
static std::vector<std::vector<void*>> g_vit_Atch, g_vit_Bmtch, g_vit_Bttch;
static bool    g_vit_splitready = false;
static int     g_vit_gA = -1, g_vit_gBm = -1, g_vit_gBt = -1;
static size_t  g_vit_hostcmd_stored = SIZE_MAX;
static int*    g_vit_mcnt = nullptr;                // per-item max |delta| in the 16-bit code field
static int*    g_vit_scnt = nullptr;                // per-item sum |delta| in the same units
static bool  g_vit_twinready = false;
static int   g_vit_master = -1, g_vit_twin = -1;
static void* g_vit_face = nullptr;                  // the compared plan face (frozen ptr)
static void* g_vit_flag = nullptr;                  // C28: attribution face the twin stamps
static int*    g_vit_tcnt = nullptr;                // C28: device counter of twin executions
static sycl::uint4* g_vit_shadow = nullptr;         // device: last frame's face
static void* g_vit_face2 = nullptr;                 // S2: the segment's OTHER input stream
static sycl::uint4* g_vit_shadow2 = nullptr;        //   (the residual plane the chains skip
static size_t  g_vit_items2 = 0;                    //    with) -- rule 192: judge ALL inputs
static int*    g_vit_dcnt = nullptr;                // shared: per-item mismatch words
static size_t  g_vit_items = 0;
static int     g_vit_skip_next = 0;                 // verdict for the next frame
static int     g_vit_ran_once = 0;                  // has a criterion verdict been produced?
static long    g_vit_lastdiff = -1;                 // the verdict's raw number
static long    g_vit_lastmax = 0, g_vit_lastsum = 0;  // C29: max / sum |delta| in code units
static int     g_vit_frames = 0, g_vit_skips = 0;   // bookkeeping for the print
static void vit_reset(void) {
    g_vit_qnotes.clear(); g_vit_qkvs.clear(); g_vit_gemm.clear(); g_vit_unary.clear();
}
// NR_VIT_REUSE_SET=chain|segment (default segment):
//   chain   = S1, dissolve the 8 attention chains only (the C25 blade, NOT certified);
//   segment = S2, dissolve the WHOLE ViT segment: the entry GEMM (the only writer of 1285
//             before the chains) through the last attention residual. Face-lifecycle
//             proof (tools/wb_c26_timeline.py, kept recording, plain indices):
//               1285: writers 312 + 321,330,...,384 ; readers 313..379 (all in-segment)
//                     + 385 (the exit GEMM, OUTSIDE the span) => skipping 312..384 leaves
//                     1285 = last frame's segment output and 385 reads exactly that.
//               1267: last in-segment writer = 379, next writer = 393, first reader after
//                     the span = 394 => the ViT's 1267 writes are DEAD by plan structure
//                     => NO shadow/restore needed (that was the open question of C25 112.1(2)).
//               1286/1287: every writer and reader is inside 313..383.
//               1271: written by UNARY 311 (n=98,304 halfs) and read by GEMM 312 => the
//                     criterion host is 311, OUTSIDE the span, so it keeps running on
//                     skipped frames and compares the segment's real input.
static const char* vit_reuse_set(void) {
    static const char* v = getenv("NR_VIT_REUSE_SET") ? getenv("NR_VIT_REUSE_SET") : "segment";
    return v;
}
static void vit_note_quant(size_t cmd, int source, int packed, int scale, unsigned M, unsigned K) {
    VitQNote n{ cmd, source, packed, scale, M, K };
    g_vit_qnotes.push_back(n);
}
static void vit_note_qkv(size_t cmd, unsigned channels, unsigned heads, unsigned tokens) {
    // only the GLOBAL-attention (ViT) chains: heads=32, tokens=192, C=1024 with the vit
    // flag -- the caller checks the flag. The window chains belong to NR_SKIP_CHAINS.
    g_vit_qkvs.push_back(cmd);
    (void)channels; (void)heads; (void)tokens;
}
static void vit_note_gemm(size_t cmd, int a, int c, unsigned M, unsigned N, unsigned K) {
    VitGemmNote n{ cmd, a, c, M, N, K };
    g_vit_gemm.push_back(n);
}
static void vit_note_unary(size_t cmd, int a, int b, int c, int d, unsigned n) {
    VitUnaryNote u{ cmd, a, b, c, d, n };
    g_vit_unary.push_back(u);
}
static const char* vit_nm(const std::vector<const char*>& names, size_t off, size_t i) {
    return i + off < names.size() ? names[i + off] : "?";
}
// capture time: resolve the chains, inject the criterion into the first chain's opening
// QUANT, and build the twin closure list with the chain bodies dissolved.
static void vit_reuse_apply(std::vector<std::function<void()>>& cmds,
                            const std::vector<const char*>& names, int graphid) {
    g_vit_twinready = false; g_vit_twincmds.clear(); g_vit_chains.clear();
    g_vit_master = -1; g_vit_twin = -1;
    g_vit_ran_once = 0; g_vit_skip_next = 0;
    const int lvl = vit_reuse_level();
    if (!lvl) return;
    if (getenv("NR_BMERGE") && atoi(getenv("NR_BMERGE")) >= 1) {
        std::printf("[vit-reuse] graph=%d REFUSED: NR_BMERGE is live (a merged group could "
                    "carry a skipped member's write)\n", graphid);
        std::fflush(stdout); return;
    }
    if (names.size() < cmds.size()) {
        std::printf("[vit-reuse] graph=%d REFUSED: cmds=%zu names=%zu\n", graphid,
                    cmds.size(), names.size());
        std::fflush(stdout); return;
    }
    const size_t off = names.size() - cmds.size();
    // NOTE (unlike the skip-chains pass, which demands a WHOLE recording): the fused route's
    // name list is one entry short in the first recording (the fused pre refuses its second
    // recording, :168-169), so off is not a multiple of cmds.size() there. The mapping that
    // matters -- names[i+off] for the kept recording -- is exact, and every chain is
    // re-verified by its name pattern below: a wrong offset cannot survive that check.
    for (size_t q : g_vit_qkvs) {
        if (q < 1 || q + 5 > cmds.size()) {
            std::printf("[vit-reuse] graph=%d REFUSED: qkv cmd=%zu out of span (closures=%zu)\n",
                        graphid, q, cmds.size());
            g_vit_chains.clear(); return;
        }
        if (strcmp(vit_nm(names, off, q), "xmx_rec_gemm_int8_qkv") ||
            strcmp(vit_nm(names, off, q - 1), "xmx_rec_quant") ||
            strcmp(vit_nm(names, off, q + 1), "xmx_rec_global_attention")) {
            std::printf("[vit-reuse] graph=%d REFUSED: pattern at cmd=%zu is [%s,%s,%s,%s]\n",
                        graphid, q, vit_nm(names, off, q - 1), vit_nm(names, off, q),
                        vit_nm(names, off, q + 1), vit_nm(names, off, q + 2));
            g_vit_chains.clear(); return;
        }
        {
            size_t e = q + 2;
            while (e < cmds.size() && e <= q + 5 &&
                   strcmp(vit_nm(names, off, e), "xmx_rec_gemm_int8_residual")) ++e;
            if (e > q + 5) {
                std::printf("[vit-reuse] graph=%d REFUSED: no terminating residual at cmd=%zu\n",
                            graphid, q);
                g_vit_chains.clear(); return;
            }
            // the opening QUANT of this chain: its source face is the chain's input
            VitChain c{ q, 0, e, q - 1, -1, -1, 0, 0 };
            bool found = false;
            for (const VitQNote& n : g_vit_qnotes)
                if (n.cmd == q - 1) { c.srcid = n.src; c.scaleid = n.scale; c.M = n.M; c.K = n.K; found = true; break; }
            if (!found) {
                std::printf("[vit-reuse] graph=%d REFUSED: opening QUANT of cmd=%zu not noted\n",
                            graphid, q);
                g_vit_chains.clear(); return;
            }
            g_vit_chains.push_back(c);
        }
    }
    if (g_vit_chains.empty()) {
        std::printf("[vit-reuse] graph=%d REFUSED: no vit chains found (qkv notes=%zu)\n",
                    graphid, g_vit_qkvs.size());
        std::fflush(stdout); return;
    }
    // order the chains by cmd.
    std::sort(g_vit_chains.begin(), g_vit_chains.end(),
              [](const VitChain& a, const VitChain& b) { return a.qkv < b.qkv; });
    const bool segmode = (strcmp(vit_reuse_set(), "chain") != 0);
    const VitChain C0 = g_vit_chains[0];
    size_t host_cmd = C0.qcmd;                  // the closure that hosts the criterion
    int    faceid   = C0.srcid;                 // the plan face to compare
    size_t halfs    = (size_t)C0.M * (size_t)C0.K;
    g_vit_span_from = g_vit_chains.front().qkv;
    g_vit_span_to   = g_vit_chains.back().to;
    if (!segmode) {
        // S1: per-chain spans; the FIRST chain keeps its opening QUANT (the criterion host).
        for (size_t i = 0; i < g_vit_chains.size(); ++i) {
            VitChain& c = g_vit_chains[i];
            c.from = i ? c.qcmd : c.qkv;
        }
    } else {
        // S2: the span = the ViT ENTRY GEMM .. the last chain's residual (plain 312..384 /
        // fused 313..385, 73 closures, serial leg 13.940 ms). The criterion moves to the
        // surviving producer of the entry GEMM's source face (the patch-merge UNARY that
        // writes 1271 with n=98,304 halfs), because the entry GEMM itself is dissolved.
        const size_t q1 = g_vit_chains.front().qkv;
        size_t gcmd = SIZE_MAX; int gsrc = -1;
        for (const VitGemmNote& n : g_vit_gemm) {
            if (n.cmd >= q1) continue;
            bool read_by_segment_quant = false;
            for (const VitQNote& q : g_vit_qnotes)
                if (q.cmd < q1 && q.cmd + 16 >= q1 && q.src == n.c) { read_by_segment_quant = true; break; }
            if (!read_by_segment_quant) continue;
            if (gcmd == SIZE_MAX || n.cmd > gcmd) { gcmd = n.cmd; gsrc = n.a; }
        }
        if (gcmd == SIZE_MAX) {
            std::printf("[vit-reuse] graph=%d REFUSED: no ViT entry GEMM found (no noted GEMM "
                        "before cmd=%zu whose output a segment QUANT reads). gemm_notes=%zu "
                        "quant_notes=%zu chains=%zu", graphid, q1, g_vit_gemm.size(),
                        g_vit_qnotes.size(), g_vit_chains.size());
            for (size_t z = 0; z < g_vit_gemm.size(); ++z)
                if (g_vit_gemm[z].cmd + 24 >= q1 && g_vit_gemm[z].cmd <= q1)
                    std::printf(" | g%zu cmd=%zu a=%d c=%d M=%u N=%u K=%u", z, g_vit_gemm[z].cmd,
                                g_vit_gemm[z].a, g_vit_gemm[z].c, g_vit_gemm[z].M, g_vit_gemm[z].N,
                                g_vit_gemm[z].K);
            for (size_t z = 0; z < g_vit_qnotes.size(); ++z)
                if (g_vit_qnotes[z].cmd + 24 >= q1 && g_vit_qnotes[z].cmd <= q1 + 4)
                    std::printf(" | q%zu cmd=%zu src=%d M=%u K=%u", z, g_vit_qnotes[z].cmd,
                                g_vit_qnotes[z].src, g_vit_qnotes[z].M, g_vit_qnotes[z].K);
            for (size_t z = 0; z < g_vit_unary.size(); ++z)
                if (g_vit_unary[z].cmd + 8 >= q1 && g_vit_unary[z].cmd <= q1)
                    std::printf(" | u%zu cmd=%zu a=%d b=%d c=%d d=%d n=%u", z, g_vit_unary[z].cmd,
                                g_vit_unary[z].a, g_vit_unary[z].b, g_vit_unary[z].c,
                                g_vit_unary[z].d, g_vit_unary[z].n);
            std::printf(" | unary_notes=%zu\n", g_vit_unary.size());
            std::fflush(stdout); g_vit_chains.clear(); return;
        }
        size_t ucmd = SIZE_MAX; unsigned un = 0;
        for (const VitUnaryNote& u : g_vit_unary) {
            if (u.cmd >= gcmd) continue;
            if (u.a != gsrc && u.b != gsrc && u.c != gsrc && u.d != gsrc) continue;
            if (ucmd == SIZE_MAX || u.cmd > ucmd) { ucmd = u.cmd; un = u.n; }
        }
        if (ucmd == SIZE_MAX || !un) {
            std::printf("[vit-reuse] graph=%d REFUSED: no surviving producer of the entry GEMM's "
                        "source face id=%d => the criterion would have nowhere to live\n",
                        graphid, gsrc);
            std::fflush(stdout); g_vit_chains.clear(); return;
        }
        g_vit_span_from = gcmd; g_vit_span_to = g_vit_chains.back().to;
        host_cmd = ucmd; faceid = gsrc; halfs = (size_t)un;
        if (host_cmd >= g_vit_span_from) {
            std::printf("[vit-reuse] graph=%d REFUSED: criterion host cmd=%zu sits inside the "
                        "dissolved span %zu..%zu\n", graphid, host_cmd, g_vit_span_from,
                        g_vit_span_to);
            std::fflush(stdout); g_vit_chains.clear(); return;
        }
    }
    // ---- the criterion: compare the segment's INPUT face with the shadow ----
    auto bit = g_bufs.find(faceid);
    if (bit == g_bufs.end() || !bit->second.p || !halfs) {
        std::printf("[vit-reuse] graph=%d REFUSED: criterion face id=%d unresolved (p=%p halfs=%zu)\n",
                    graphid, faceid, bit == g_bufs.end() ? nullptr : bit->second.p, halfs);
        std::fflush(stdout); g_vit_chains.clear(); return;
    }
    if ((halfs * 2u) % (16u * (size_t)VIT_U4PER)) {
        std::printf("[vit-reuse] graph=%d REFUSED: face %zu halfs is not a whole number of "
                    "criterion chunks\n", graphid, halfs);
        std::fflush(stdout); g_vit_chains.clear(); return;
    }
    g_vit_items = halfs * 2u / (16u * (size_t)VIT_U4PER);
    g_vit_face = bit->second.p;
    // S2 second input stream: the segment's chains also read the residual plane (their
    // opening QUANT's source, and the residual `skip` operand) -- a frame in which the
    // patch-merge face is bit-identical but the residual plane moved MUST NOT be reused
    // (rule 192: the judge/criterion covers EVERY input face). In chain mode the opening
    // QUANT's own face IS the criterion face, so there is no second stream.
    g_vit_face2 = nullptr; g_vit_items2 = 0; g_vit_flag = nullptr;
    size_t halfs2 = 0;
    if (segmode) {
        // C28 attribution face: the chain's scale plane (768 B in this plan) -- every writer
        // and reader of it sits INSIDE the dissolved span, so in a reused frame the twin's
        // stamp is the only thing there, and a master frame overwrites it with real quant
        // data. The face dump then proves the frame attribution by itself (no host print).
        auto bf = g_bufs.find(C0.scaleid);
        if (bf != g_bufs.end() && bf->second.p && bf->second.bytes >= 16 && bf->second.bytes <= 65536u)
            g_vit_flag = bf->second.p;
        auto b2 = g_bufs.find(C0.srcid);
        if (b2 != g_bufs.end() && b2->second.p && C0.M && C0.K) {
            halfs2 = (size_t)C0.M * (size_t)C0.K;
            if ((halfs2 * 2u) % (16u * (size_t)VIT_U4PER) == 0) {
                g_vit_items2 = halfs2 * 2u / (16u * (size_t)VIT_U4PER);
                g_vit_face2 = b2->second.p;
            }
        }
        if (!g_vit_face2) {
            std::printf("[vit-reuse] graph=%d REFUSED: the segment's second input face "
                        "id=%d (%ux%u) is unresolved -- reusing on one face alone would be "
                        "unsafe (rule 192)\n", graphid, C0.srcid, C0.M, C0.K);
            std::fflush(stdout); g_vit_chains.clear(); return;
        }
    }
    if (!g_vit_shadow) g_vit_shadow = (sycl::uint4*)sycl::malloc_device(halfs * 2u, *GQ);
    if (g_vit_items2 && !g_vit_shadow2)
        g_vit_shadow2 = (sycl::uint4*)sycl::malloc_device(halfs2 * 2u, *GQ);
    auto vkind_host = [&](void) { return lvl == 4 || lvl == 5 || (getenv("NR_VIT_VREAD") && strcmp(getenv("NR_VIT_VREAD"), "host") == 0); };
    auto vkind_shr  = [&](void) { return lvl != 4 && getenv("NR_VIT_VREAD") && strcmp(getenv("NR_VIT_VREAD"), "shr") == 0; };
    if (!g_vit_dcnt)   g_vit_dcnt   = vkind_shr()
        ? (int*)sycl::malloc_shared((g_vit_items + g_vit_items2) * 4u, *GQ)
        : vkind_host()
        ? (int*)sycl::malloc_host((g_vit_items + g_vit_items2) * 4u, *GQ)
        : (int*)sycl::malloc_device((g_vit_items + g_vit_items2) * 4u, *GQ);
    // C29: the magnitude arrays live in the SAME memory kind as the word counters.
    if (!g_vit_mcnt) g_vit_mcnt = vkind_shr() ? (int*)sycl::malloc_shared((g_vit_items + g_vit_items2) * 4u, *GQ)
                             : vkind_host() ? (int*)sycl::malloc_host((g_vit_items + g_vit_items2) * 4u, *GQ)
                             : (int*)sycl::malloc_device((g_vit_items + g_vit_items2) * 4u, *GQ);
    if (!g_vit_scnt) g_vit_scnt = vkind_shr() ? (int*)sycl::malloc_shared((g_vit_items + g_vit_items2) * 4u, *GQ)
                             : vkind_host() ? (int*)sycl::malloc_host((g_vit_items + g_vit_items2) * 4u, *GQ)
                             : (int*)sycl::malloc_device((g_vit_items + g_vit_items2) * 4u, *GQ);
    if (!g_vit_shadow || !g_vit_dcnt || (g_vit_items2 && !g_vit_shadow2)) {
        std::printf("[vit-reuse] graph=%d REFUSED: criterion buffers did not allocate\n", graphid);
        std::fflush(stdout); g_vit_chains.clear(); return;
    }
    GQ->memset(g_vit_shadow, 0xFF, halfs * 2u).wait();
    if (g_vit_items2) GQ->memset(g_vit_shadow2, 0xFF, halfs2 * 2u).wait();
    GQ->memset(g_vit_dcnt, 0, (g_vit_items + g_vit_items2) * 4u).wait();
    GQ->memset(g_vit_mcnt, 0, (g_vit_items + g_vit_items2) * 4u).wait();
    GQ->memset(g_vit_scnt, 0, (g_vit_items + g_vit_items2) * 4u).wait();
    std::function<void()> twin_host_body;           // C28: the twin's stamped criterion body
    size_t twin_host_cmd = SIZE_MAX;
    {
        void* f = g_vit_face; sycl::uint4* sh = g_vit_shadow; int* dc = g_vit_dcnt;
        int* mc = g_vit_mcnt; int* sc = g_vit_scnt;
        void* f2 = g_vit_face2; sycl::uint4* sh2 = g_vit_shadow2; int* dc2 = dc + g_vit_items;
        void* fl = g_vit_flag;
        if (fl && !g_vit_tcnt) g_vit_tcnt = (int*)sycl::malloc_device(4u, *GQ);
        if (fl && g_vit_tcnt) GQ->memset(g_vit_tcnt, 0, 4u).wait();
        int* tc = g_vit_tcnt;
        // C30 (A) level 6: the device-side verdict plumbing
        long long* acc = (lvl >= 6) ? vit_accbuf() : nullptr;
        int* vgl = (lvl >= 6) ? vit_gbuf() : nullptr;
        int* hf  = (lvl >= 6) ? vit_hfbuf() : nullptr;
        const long thmax = getenv("NR_VIT_REUSE_THMAX") ? atol(getenv("NR_VIT_REUSE_THMAX")) : 0;
        const size_t sp_lo = g_vit_span_from, sp_hi = g_vit_span_to;   // C33: cells to re-arm
        const int nostamp = getenv("NR_VIT_NOSTAMP") ? 1 : 0;   // C33: host-side, captured
        const long thsum = getenv("NR_VIT_REUSE_THSUM") ? atol(getenv("NR_VIT_REUSE_THSUM")) : 0;
        const size_t items = g_vit_items, items2 = g_vit_items2;
        auto old = std::move(cmds[host_cmd]);
        // C28: the criterion body comes from a factory so the MASTER copy and the TWIN copy
        // carry a different stamp. The twin stamps its identity (16 magic bytes) into
        // g_vit_flag -- a plan face whose EVERY writer and reader lies inside the dissolved
        // span (the chain's 768 B scale face): in a master frame the span overwrites it with
        // real quant data, in a twin frame the magic survives into the face dump. The dump
        // then PROVES which graph ran, so host prints are no longer used for frame
        // attribution (the C27 "off by one frame" wrinkle).
        auto make_crit = [&](int stamp) {
            return [old, f, sh, dc, items, f2, sh2, dc2, items2, fl, tc, mc, sc, acc, vgl, hf, thmax, thsum, sp_lo, sp_hi, nostamp, stamp]() {
                old();
                GQ->parallel_for(sycl::range(items), [f, sh, dc, mc, sc, fl, tc, acc, vgl, sp_lo, sp_hi, nostamp, stamp](sycl::item<1> it) {
                    constexpr int PER = 16;
                    const sycl::uint4* a = (const sycl::uint4*)f;
                    size_t b = it.get_id(0) * PER;
                    int d = 0, mx = 0; long sm = 0;
                    for (int i = 0; i < PER; ++i) {
                        sycl::uint4 x = a[b + i], y = sh[b + i];
                        // C29 magnitude form of the criterion: the per-half |delta| in the
                        // 16-bit code field (max and sum), computed BEFORE the shadow is
                        // written -- the first build folded the copy into the updated
                        // memory and measured |x-x| = 0 (caught by face evidence, 2026-11-09).
                        // The word-count alone was proven to be a cliff (0 or 85-95% of the
                        // words), so it cannot carry a perceptual threshold (see 115.4).
                        {
                            const unsigned int* w = (const unsigned int*)&y;
                            for (int q = 0; q < 4; ++q) {
                                for (int hh = 0; hh < 2; ++hh) {
                                    unsigned int o = (unsigned int)x[q], p = w[q];
                                    unsigned int u = (hh ? (o >> 16) : (o & 0xFFFFu));
                                    unsigned int v = (hh ? (p >> 16) : (p & 0xFFFFu));
                                    unsigned int dd = (u > v) ? (u - v) : (v - u);
                                    if ((int)dd > mx) mx = (int)dd;
                                    sm += (long)dd;
                                }
                            }
                        }
                        if (x[0] != y[0] || x[1] != y[1] || x[2] != y[2] || x[3] != y[3]) {
                            ++d; sh[b + i] = x;
                        }
                    }
                    dc[it.get_id(0)] = d;
                    if (mc) mc[it.get_id(0)] = mx;
                    if (sc) sc[it.get_id(0)] = (int)(sm > 0x7FFFFFF0 ? 0x7FFFFFF0 : sm);
                    if (acc && vgl) {   // fold face 1 into the same-frame accumulators
                        sycl::atomic_ref<long long, sycl::memory_order::relaxed,
                                         sycl::memory_scope::device,
                                         sycl::access::address_space::global_space> amax(acc[0]);
                        sycl::atomic_ref<long long, sycl::memory_order::relaxed,
                                         sycl::memory_scope::device,
                                         sycl::access::address_space::global_space> asum(acc[1]);
                        amax.fetch_max(mx);
                        asum.fetch_add((long long)sm);
                    }
                    if (stamp == 1 && it.get_id(0) == 0 && fl) {
                        unsigned e = tc ? (unsigned)(*tc) + 1u : 0u;
                        if (tc) *tc = (int)e;
                        *(sycl::uint4*)fl = sycl::uint4(sycl::uint(0xC28A571Du), sycl::uint(0x51E771C8u),
                                                        e, sycl::uint(0x00000001u));
                    }
                });
                if (items2)
                    GQ->parallel_for(sycl::range(items2), [f2, sh2, dc2, mc, sc, items, items2, acc, vgl, hf, fl, thmax, thsum, sp_lo, sp_hi, nostamp, stamp](sycl::item<1> it) {
                        constexpr int PER = 16;
                        const sycl::uint4* a = (const sycl::uint4*)f2;
                        size_t b = it.get_id(0) * PER;
                        int d = 0, mx = 0; long sm = 0;
                        for (int i = 0; i < PER; ++i) {
                            sycl::uint4 x = a[b + i], y = sh2[b + i];
                            {
                                const unsigned int* w = (const unsigned int*)&y;
                                for (int q = 0; q < 4; ++q) {
                                    for (int hh = 0; hh < 2; ++hh) {
                                        unsigned int o = (unsigned int)x[q], p = w[q];
                                        unsigned int u = (hh ? (o >> 16) : (o & 0xFFFFu));
                                        unsigned int v = (hh ? (p >> 16) : (p & 0xFFFFu));
                                        unsigned int dd = (u > v) ? (u - v) : (v - u);
                                        if ((int)dd > mx) mx = (int)dd;
                                        sm += (long)dd;
                                    }
                                }
                            }
                            if (x[0] != y[0] || x[1] != y[1] || x[2] != y[2] || x[3] != y[3]) {
                                ++d; sh2[b + i] = x;
                            }
                        }
                        size_t k = it.get_id(0) + items;
                        dc2[it.get_id(0)] = d;
                        if (mc) mc[k] = mx;
                        if (sc) sc[k] = (int)(sm > 0x7FFFFFF0 ? 0x7FFFFFF0 : sm);
                        // C30 (A): the DEVICE-SIDE same-frame verdict. Every item folds its own
                        // max/sum in; the last one to arrive turns the accumulators into the
                        // flag the span kernels test at their entry. No host involvement.
                        if (acc && vgl) {
                            sycl::atomic_ref<long long, sycl::memory_order::relaxed,
                                             sycl::memory_scope::device,
                                             sycl::access::address_space::global_space> amax(acc[0]);
                            sycl::atomic_ref<long long, sycl::memory_order::relaxed,
                                             sycl::memory_scope::device,
                                             sycl::access::address_space::global_space> asum(acc[1]);
                            sycl::atomic_ref<long long, sycl::memory_order::relaxed,
                                             sycl::memory_scope::device,
                                             sycl::access::address_space::global_space> adone(acc[2]);
                            amax.fetch_max(mx);
                            asum.fetch_add((int)(sm > 0x3E800 ? 0x3E800 : sm));
                            long long seen_ll = adone.fetch_add(1); int seen = (int)seen_ll;
                            if (seen == (int)items2 - 1) {          // last item of the frame
                                long long gmax = acc[0], gsum = acc[1];
                                int dec = ((long)gmax <= thmax && (long)gsum <= thsum) ? 1 : 0;
                                vgl[0] = dec;
                                // C33: per-closure self-attestation WITHOUT touching any business
                                // face: the criterion re-arms the span cells to 1, a guarded kernel that
                                // early-outs writes 2 into its own cell, and the host counts them after
                                // the frame (a plain read of malloc_host cells, no driver call).
                                for (int i = (int)sp_lo; i <= (int)sp_hi; ++i) { vgl[1 + i] = dec; vgl[4200 + i] = 0; }
                                vgl[8399] = (vgl[8399] + 1) & 0x7FFFFFFF;   // frame sequence
                                // C32 (step 2): level-6 FACE SELF-ATTESTATION -- the DEVICE writes
                                // {magic, magic, THIS frame decision, 3} into plan face 1287.
                                if (stamp == 3 && fl && !nostamp) {   // C33: NR_VIT_NOSTAMP kills the face write
                                    unsigned* sp = (unsigned*)fl;
                                    sp[0] = 0xC29B6A5Eu; sp[1] = 0x7A51E771u;
                                    sp[2] = (unsigned)dec; sp[3] = 3u;
                                }
                                if (hf) { hf[0] = dec; hf[1] = (int)(gmax > 0x7FFFFFFF ? 0x7FFFFFFF : gmax); hf[2] = (int)(gsum > 0x7FFFFFFF ? 0x7FFFFFFF : gsum); hf[3] = seen + 1; }
                                acc[0] = 0; acc[1] = 0; acc[2] = 0;  // ready for the next frame
                            }
                        }
                    });
            };
        };
        if (lvl >= 1 && lvl <= 3 && vit_period_value() >= 1) {
            // C35: the period decision needs no verdict, so no criterion node is installed:
            // master and twin differ ONLY by the dissolved span (a closed set, all-or-none).
            // C37 THE FIX: the body above was MOVED OUT of cmds[host_cmd] when the wrapper was
            // prepared (line 2235), so skipping the install left an EMPTY std::function in the
            // master -> the plan's first xmx_graph_run died with std::bad_function_call
            // ("closure 312 EMPTY in graph 0", found by the probe). Put the shipped body back.
            cmds[host_cmd] = std::move(old);
        } else {
            cmds[host_cmd] = make_crit(lvl >= 6 ? 3 : 0);
            twin_host_body = make_crit(1);
            twin_host_cmd = host_cmd;
        }
    }
    // ---- the twin closure list: SAME count, the selected SPAN dissolved. C27 adds the
    // bisect sets (entry / attn / ffn) so the "which half moves `result`" question can be
    // answered without touching anything else in the mechanism. ----
    const char* setname = vit_reuse_set();
    auto in_chain = [&](size_t i) -> bool {
        for (const VitChain& c : g_vit_chains)
            if (i >= c.qcmd && i <= c.to) return true;
        return false;
    };
    g_vit_kill.assign(cmds.size(), 0);
    size_t noops = 0;
    if (!segmode) {                                   // chain: the C25 S1 set
        for (const VitChain& c : g_vit_chains)
            for (size_t i = c.from; i <= c.to; ++i)
                if (!g_vit_kill[i]) { g_vit_kill[i] = 1; ++noops; }
    } else if (strcmp(setname, "entry") == 0) {       // S-a: only the ViT entry GEMM
        g_vit_kill[g_vit_span_from] = 1; noops = 1;
    } else if (strcmp(setname, "attn") == 0) {        // S-b: only the 8 attention chains
        for (const VitChain& c : g_vit_chains)
            for (size_t i = c.qcmd; i <= c.to; ++i)
                if (!g_vit_kill[i]) { g_vit_kill[i] = 1; ++noops; }
    } else if (strcmp(setname, "ffn") == 0) {         // S-c: only the 8 FFN sub-blocks
        for (size_t i = g_vit_span_from + 1; i <= g_vit_span_to; ++i)
            if (!in_chain(i)) { g_vit_kill[i] = 1; ++noops; }
    } else {                                          // S-d: the whole segment (C26)
        for (size_t i = g_vit_span_from; i <= g_vit_span_to; ++i)
            if (!g_vit_kill[i]) { g_vit_kill[i] = 1; ++noops; }
    }
    if (g_vit_kill[host_cmd]) {
        std::printf("[vit-reuse] graph=%d REFUSED: set=%s would dissolve the criterion host "
                    "cmd=%zu -- the verdict would stop being produced\n", graphid, setname,
                    host_cmd);
        std::fflush(stdout); g_vit_chains.clear(); return;
    }
    // ---- C29 level 4: the same-frame SPLIT (A = [0..criterion], Bm = the rest computed,
    // Bt = the rest with the segment dissolved). The decision is taken by the host BETWEEN
    // the two submits from THIS frame's own counters, so it certifies the frame it gates.
    if (lvl == 4) {
        if (host_cmd + 1 != g_vit_span_from) {
            std::printf("[vit-reuse] graph=%d REFUSED (level 4 split): the segment must start "
                        "right after the criterion host (host=%zu span=%zu..%zu)\n", graphid,
                        host_cmd, g_vit_span_from, g_vit_span_to);
            std::fflush(stdout); g_vit_chains.clear(); return;
        }
        g_vit_A.assign(cmds.begin(), cmds.begin() + (host_cmd + 1));
        g_vit_Bm.assign(cmds.begin() + (host_cmd + 1), cmds.end());
        g_vit_Bt = g_vit_Bm;
        for (size_t i = g_vit_span_from; i <= g_vit_span_to; ++i)
            g_vit_Bt[i - (host_cmd + 1)] = [](){};
        // face self-attestation (rule 196): Bt's first closure stamps the attribution face
        // (plan 1287 -- every writer and reader of it is inside the dissolved span). In the
        // computed path the span overwrites that face with real quant data; in the dissolved
        // path the stamp survives into the face dump, so the dump says which B ran -- with a
        // device-side execution counter that numbers the reuses.
        void* fl2 = g_vit_flag; int* tc2 = g_vit_tcnt;
        if (fl2)
            g_vit_Bt[0] = [fl2, tc2]() {
                GQ->parallel_for(sycl::range((size_t)1), [fl2, tc2](sycl::item<1> it) {
                    if (it.get_id(0) != 0 || !fl2) return;
                    unsigned e = tc2 ? (unsigned)(*tc2) + 1u : 0u;
                    if (tc2) *tc2 = (int)e;
                    *(sycl::uint4*)fl2 = sycl::uint4(sycl::uint(0xC28A571Du), sycl::uint(0x51E771C8u),
                                                     e, sycl::uint(0x00000002u));
                });
            };
        g_vit_hostcmd_stored = host_cmd;
        g_vit_splitready = true;
        std::printf("[vit-reuse] graph=%d SPLIT ready: A=0..%zu  B=%zu..%zu (Bt dissolves %zu..%zu)\n",
                    graphid, host_cmd, host_cmd + 1, cmds.size() - 1, g_vit_span_from, g_vit_span_to);
    }
    // C30 (A) level 6: allocate + clear the device flag and accumulators HERE (never inside
    // the cgraph record pass -- section 92 forbids sycl::malloc_device while recording), then
    // mark the span closures as guardable with ONE memcpy at capture time.
    if (lvl >= 6) {
        int* vg = vit_gbuf(); long long* acc0 = vit_accbuf(); int* hf0 = vit_hfbuf();
        if (!vg || !acc0 || !hf0) {
            std::printf("[vit-reuse] graph=%d REFUSED: level 6 buffers did not allocate\n", graphid);
            std::fflush(stdout); g_vit_chains.clear(); return;
        }
        GQ->memset(vg, 0, 8400u * 4u).wait();
        GQ->memset(acc0, 0, 4u * sizeof(long long)).wait();
        static int marks[8400];
        for (int i = 0; i < 8400; ++i) marks[i] = 0;
        size_t lo6 = g_vit_span_from, hi6 = g_vit_span_to;
        if (hi6 < 4090u) for (size_t i = lo6; i <= hi6; ++i) marks[1 + i] = 1;
        GQ->memcpy(vg + 1, marks + 1, 4199u * 4u).wait();
        g_vit_twinready = false;      // level 6 never dissolves anything: ONE submit, and the
                                      // kernels that read the flag simply return (no empty node,
                                      // no second graph, no host decision)
        std::printf("[vit-reuse] graph=%d LEVEL6 armed: single submit + device flag; marked span %zu..%zu (%zu closures)\n",
                    graphid, lo6, hi6, hi6 >= lo6 ? hi6 - lo6 + 1 : 0);
        std::fflush(stdout);
    }
    g_vit_twincmds = cmds;
    for (size_t i = 0; i < g_vit_kill.size(); ++i)
        if (g_vit_kill[i]) g_vit_twincmds[i] = [](){};
    // C28: the twin's criterion copy carries stamp=1 (it marks the attribution face), the
    // master's carries stamp=0. Same work, same nodes, one captured constant apart -- so a
    // face dump can tell the two graphs apart without trusting any host print.
    if (twin_host_cmd != SIZE_MAX && twin_host_cmd < g_vit_twincmds.size() && !g_vit_kill[twin_host_cmd])
        g_vit_twincmds[twin_host_cmd] = twin_host_body;
    if (lvl != 5) g_vit_twinready = true;   // C30 level 5 = TELEMETRY ONLY: nothing dissolved,
                                            // nothing skipped -- the picture is REUSE=0 by law
    std::printf("[vit-reuse] graph=%d level=%d set=%s chains=%zu span=%zu..%zu noop=%zu "
                "criterion cmd=%zu face=%p halfs=%zu items=%zu face2=%p items2=%zu flag=%p vread=%s\n",
                graphid, lvl, setname, g_vit_chains.size(),
                g_vit_span_from, g_vit_span_to, noops, host_cmd, g_vit_face, halfs, g_vit_items,
                g_vit_face2, g_vit_items2, g_vit_flag,
                getenv("NR_VIT_VREAD") ? getenv("NR_VIT_VREAD") : "dev");
    std::fflush(stdout);
}
// the per-frame verdict: shared-memory counters, read AFTER the frame's graph wait (the
// shipped replay already waits: ext_oneapi_graph(...).wait()), so no extra submit and no
// extra sync point is added to the frame.
static void vit_verdict_update(void) {
    const int lvl = vit_reuse_level();
    // C27 DIAGNOSTIC ONLY (attribution of the run-1 divergence): NR_VIT_DELAY=<microseconds>
    // inserts a pure host pause at this point in the inter-frame gap -- no queue op, no
    // memory read -- and NR_VIT_NOREAD=1 suppresses the counter read entirely. If a bare
    // pause reproduces the same divergence, the frame is TIMING-sensitive (an intra-frame
    // order hazard in the shipped graph), and no property of the reuse or of the read is
    // implicated.
    {
        static int delay_us = getenv("NR_VIT_DELAY") ? atoi(getenv("NR_VIT_DELAY")) : 0;
        if (delay_us > 0) {
            auto t0 = std::chrono::steady_clock::now();
            while ((int)std::chrono::duration_cast<std::chrono::microseconds>(
                       std::chrono::steady_clock::now() - t0).count() < delay_us) {}
        }
    }
    static int noread = getenv("NR_VIT_NOREAD") ? 1 : 0;
    if (noread) { g_vit_lastdiff = -3; return; }   // keeps skip_next as-is (0 at start)
    if (!lvl || g_vit_twin < 0) { g_vit_skip_next = 0; return; }
    if (lvl == 2) { g_vit_skip_next = 1; return; }   // force skip (the quality instrument)
    if (lvl == 3) { g_vit_skip_next = 0; return; }   // never skip (prices the criterion)
    // the FIRST frame must run the segment: the shadow was seeded at capture time and no
    // criterion verdict exists yet.
    if (!g_vit_ran_once) { g_vit_skip_next = 0; g_vit_lastdiff = -2; return; }
    long tot = 0;
    // C27 attribution: the counters are now DEVICE memory and come over by an explicit
    // memcpy, instead of the host dereferencing malloc_shared pages (the shipped replay
    // already host-syncs at this point -- ext_oneapi_graph(...).wait() -- so this adds no
    // new sync KIND, only a 9 KB copy). Reason: with the shared-USM dereference the frame
    // trajectory diverged from the never-read control (REUSE=3) at run 1, i.e. BEFORE any
    // skip and identically for every skip set (entry/attn/ffn/segment) -- so the read
    // itself, not the reuse, was the perturbation. NR_VIT_VREAD=shr restores the old path.
    static int vread_dev = (getenv("NR_VIT_VREAD") && strcmp(getenv("NR_VIT_VREAD"), "shr") == 0) ? 0
                         : (getenv("NR_VIT_VREAD") && strcmp(getenv("NR_VIT_VREAD"), "host") == 0) ? 0 : 1;
    const size_t n = g_vit_items + g_vit_items2;
    static int* hs = nullptr;
    if (vread_dev) {
        if (!hs) hs = (int*)malloc(n * 4u);
        if (hs) {
            GQ->memcpy(hs, g_vit_dcnt, n * 4u).wait();
            for (size_t i = 0; i < n; ++i) tot += hs[i];
        }
    } else {
        for (size_t i = 0; i < n; ++i) tot += g_vit_dcnt[i];
    }
    g_vit_lastdiff = tot;
    static int th = getenv("NR_VIT_REUSE_TH") ? atoi(getenv("NR_VIT_REUSE_TH")) : 0;
    g_vit_skip_next = (tot <= (long)th) ? 1 : 0;
}
// C30 事二(2): TELEMETRY (NR_VIT_TRACE=<path>, default OFF). One appended line per frame:
//   frame, words_diff, max|delta|, sum|delta|, verdict
// verdict = 1 means a SAME-FRAME reuse would have fired at NR_VIT_REUSE_THMAX/THSUM. Nothing
// else changes: no dissolution, no skip, no extra queue op, and when the variable is unset no
// file is even opened. This is how the trigger rate gets collected from real play, not from a
// synthetic sweep (the input side was proven cliff-like in 116.3).
static void vit_trace(void) {
    static const char* path = getenv("NR_VIT_TRACE");
    if (!path || !*path) return;
    static FILE* fp = nullptr;
    static long thmax = getenv("NR_VIT_REUSE_THMAX") ? atol(getenv("NR_VIT_REUSE_THMAX")) : 0;
    static long thsum = getenv("NR_VIT_REUSE_THSUM") ? atol(getenv("NR_VIT_REUSE_THSUM")) : 0;
    static unsigned long frame = 0;
    if (!fp) {
        fp = fopen(path, "a");
        if (!fp) { std::printf("[vit-trace] CANNOT OPEN %s\n", path); std::fflush(stdout); return; }
        std::printf("[vit-trace] appending to %s (thmax=%ld thsum=%ld)\n", path, thmax, thsum);
        std::fflush(stdout);
    }
    ++frame;
    int verdict = (g_vit_lastmax <= thmax && g_vit_lastsum <= thsum) ? 1 : 0;
    std::fprintf(fp, "%lu,%ld,%ld,%ld,%d\n", frame, g_vit_lastdiff, g_vit_lastmax, g_vit_lastsum, verdict);
    std::fflush(fp);
}
// C29 level 4 verdict: reduce THIS frame's counters on the host (malloc_host arrays: a plain
// dereference, no driver call, no queue op -- C28 proved the read itself is neutral) and
// gate on the MAGNITUDE pair (max |delta| and sum |delta| in the 16-bit code field), with
// the old word-count threshold kept as a third, optional gate.
static void vit_verdict_update4(void) {
    const size_t n = g_vit_items + g_vit_items2;
    long words = 0, mx = 0, sm = 0;
    if (g_vit_dcnt && g_vit_mcnt && g_vit_scnt) {
        for (size_t i = 0; i < n; ++i) {
            words += g_vit_dcnt[i];
            if ((long)g_vit_mcnt[i] > mx) mx = g_vit_mcnt[i];
            sm += (long)g_vit_scnt[i];
        }
    }
    static long thmax = getenv("NR_VIT_REUSE_THMAX") ? atol(getenv("NR_VIT_REUSE_THMAX")) : 0;
    static long thsum = getenv("NR_VIT_REUSE_THSUM") ? atol(getenv("NR_VIT_REUSE_THSUM")) : 0;
    static long thw   = getenv("NR_VIT_REUSE_TH") ? atol(getenv("NR_VIT_REUSE_TH")) : -1;  // -1 = not used
    g_vit_lastdiff = words; g_vit_lastmax = mx; g_vit_lastsum = sm;
    g_vit_skip_next = (mx <= thmax && sm <= thsum && (thw < 0 || words <= thw)) ? 1 : 0;
    vit_trace();          // C30: the telemetry line (no-op unless NR_VIT_TRACE is set)
}
// C33: how many marked span closures actually took the early-out THIS frame, and the frame
// sequence the criterion advanced -- both read out of malloc_host cells the kernels themselves
// wrote (self-attestation without touching a business face).
static void vit_earlyout_count(int *nearly, int *seq) {
    if (!g_vit_vg) { *nearly = -1; *seq = -1; return; }
    int hits = 0;
    for (size_t i = g_vit_span_from; i <= g_vit_span_to; ++i)
        if (g_vit_vg[4200 + i] == 2) ++hits;
    *nearly = hits; *seq = g_vit_vg[8399];
}
static void vit_frame_note(int id) {
    { int n_early = -1, n_seq = -1; vit_earlyout_count(&n_early, &n_seq);
      std::printf("[vit-reuse] SELFATT frames=%d flag=%d earlyout=%d/%d seq=%d\n",
                  g_vit_frames + 1, g_vit_skip_next, n_early,
                  (int)(g_vit_span_to >= g_vit_span_from ? g_vit_span_to - g_vit_span_from + 1 : 0),
                  n_seq); std::fflush(stdout); }   // presence-gated print of the reuse ledger
    g_vit_frames++;
    if (g_vit_skip_next) g_vit_skips++;   // level 4 reuses via g_vit_gBt, not the twin id
    static int every = getenv("NR_VITDBG") ? 1 : 60;
    // (the modulo test must not be used with every=1: frames % 1 is always 0)
    if (every <= 1 || (g_vit_frames - 1) % every == 0) {
        std::printf("[vit-reuse] frames=%d skipped=%d lastdiff=%ld lastmax=%ld lastsum=%ld items=%zu "
                    "th=%s/%s/%s -> %s\n",
                    g_vit_frames, g_vit_skips, g_vit_lastdiff, g_vit_lastmax, g_vit_lastsum,
                    g_vit_items,
                    getenv("NR_VIT_REUSE_TH") ? getenv("NR_VIT_REUSE_TH") : "0",
                    getenv("NR_VIT_REUSE_THMAX") ? getenv("NR_VIT_REUSE_THMAX") : "0",
                    getenv("NR_VIT_REUSE_THSUM") ? getenv("NR_VIT_REUSE_THSUM") : "0",
                    g_vit_skip_next ? "TWIN" : "MASTER");
        std::fflush(stdout);
    }
}
// ==================== KNIFE 1: NR_BMERGE -- same-shape residual legs merged into ONE launch ====
// notes/shape-merge-plan.md 7.1 knife 1, A3 slice (xmx_rec_gemm_int8_residual: 16 sites of
// 2040x256x256 + 12 sites of 8160x128x128, all ALIVE on the load slot per tools/shapes_alive.csv).
// The batch dim is a GRID dim: per-element reduction order is untouched, so the merged launch must
// be bit-identical to the b separate ones (the twin kernel body is a verbatim copy of gemm_b_res;
// only the group index and the pointer sources differ -- gemm_s8_v8_kernel.hpp S8ResDesc).
// Default side (NR_BMERGE unset/0): the stash below is never taken and bmerge_apply returns at
// once -- the shipped closure bodies are never rewritten.
static int bmerge_level() {
    static int v = getenv("NR_BMERGE") ? atoi(getenv("NR_BMERGE")) : 0;
    return v;
}
struct BmResSite {
    const int8_t *Araw, *Braw; void* Cout; const float *as, *bs; const void* skp; const float* cp;
    const sycl::half* a16r; bool fused_r; int b_id;
    int id_a, id_c, id_skip, id_cos;        // plan buffer ids: the dependency probe
    int M, Mp, N, K; unsigned flags; bool narrow, half_skip; unsigned epi; size_t na;
    size_t cmd;
};
static std::vector<BmResSite> g_bm_res_sites;
struct BmResGroup {
    std::vector<s8v8::S8ResDesc> slots;
    std::vector<int8_t*> held;
    std::vector<int8_t*> face;           // dedicated A faces, one per member (never pooled)
    std::vector<sycl::half*> scratch;    // NR_BMERGE_SCRATCH discard outputs
    s8v8::S8ResDesc* dtab = nullptr;      // dedicated device table, uploaded once at capture
    int n;
};
static std::vector<BmResGroup*> g_bm_groups;      // alive for the life of the process (cgraph-safe)
// C61d: ONE predicate decides the BK=64 gir path, and EVERY A producer plus the gemm entry
// call it -- a plane can never be packed in one order and read in another (that mixed-layout
// signature is exactly what the plain-1301 82.6% whole-face diff showed in C61c).
// Kept deliberately identical to the C61c condition (K % 64 == 0 && K <= 512) so coverage does
// not silently change between the two shovels.
static bool gir_bk64_ok(unsigned K) { return (K % 64u) == 0u && K <= 512u; }
// C82: the BN=128/NT=64/BK=64 tile gate for the int8 gemm legs of the C512 tier.
// NR_C512_BAND defaults to 0 -> the shipped path stays byte-identical. The shape gate
// (N%128==0, K%64==0) makes legs that fail it (e.g. gemm_int8_batched at N=64) fall back
// to the shipped BN=64 form -- per-leg judgement, not a blanket switch.
// C89: the BN=128/NT=64/BK=64 publish tile for the LIVE wres leg. Default OFF -> the
// shipped path stays byte-identical. The gate is pinned to the live shape measured in
// 184.5b/185.3 (M=768, N=512, K=512, epi=3, narrow=true) -- never a broad N%128 test,
// which C82 proved can change the numbers.
// C91: band-internal quantization scales (the numeric knife). Default OFF -> the shipped
// path is byte-identical. Rule 216: the shape gate below comes from the engine's own live
// arguments (plan chains 25/33), not from a bench form.
static bool band_scale_on() {
    static int v = getenv("NR_BAND_SCALE") ? atoi(getenv("NR_BAND_SCALE")) : 0;
    return v != 0;
}
static bool wres_pub128_on() {
    static int v = getenv("NR_WRES_PUB128") ? atoi(getenv("NR_WRES_PUB128")) : 0;
    return v != 0;
}
static bool c512_band_on() {
    static int v = getenv("NR_C512_BAND") ? atoi(getenv("NR_C512_BAND")) : 0;
    return v != 0;
}

static void bmerge_apply(std::vector<std::function<void()>>& cmds) {
    if (bmerge_level() < 1 || g_bm_res_sites.size() < 2) { g_bm_res_sites.clear(); return; }
    // group by (M,N,K,flags) with a linear scan (no map/tuple/array: keep the include set untouched)
    struct BmKey { long long m,n,k,f; bool operator==(const BmKey& o) const {
                       return m==o.m && n==o.n && k==o.k && f==o.f; } };
    std::vector<std::vector<size_t>> groups;
    std::vector<BmKey> keys;
    for (size_t i = 0; i < g_bm_res_sites.size(); ++i) {
        BmResSite& s = g_bm_res_sites[i];
        BmKey k{ s.M, s.N, s.K, (long long)s.flags };
        size_t gi = groups.size();
        for (size_t j = 0; j < keys.size(); ++j) if (keys[j] == k) { gi = j; break; }
        if (gi == groups.size()) { keys.push_back(k); groups.push_back({}); }
        groups[gi].push_back(i);
    }
    size_t merged = 0, ngrp = 0, refused_dep = 0, refused_skip = 0;
    for (auto& gv0 : groups) {
        // drop members whose closure the skip pass killed: their bodies never run
        std::vector<size_t> gv;
        for (size_t idx : gv0) if (!g_skipped_cmds.count(g_bm_res_sites[idx].cmd)) gv.push_back(idx);
        if (gv.size() != gv0.size()) refused_skip += gv0.size() - gv.size();
        static int bmax = getenv("NR_BMERGE_MAX") ? atoi(getenv("NR_BMERGE_MAX")) : 16;
        if (bmax < 2) bmax = 2;
        for (size_t p = 0; p + 1 < gv.size(); p += (size_t)bmax) {
            size_t take = gv.size() - p; if (take > (size_t)bmax) take = (size_t)bmax;
            if (take < 2) break;
            // dependency guard over the whole cmd span this merged launch would cover
            size_t first = g_bm_res_sites[gv[p]].cmd, last = g_bm_res_sites[gv[p + take - 1]].cmd;
            std::vector<void*> outs;
            for (size_t k = 0; k < take; ++k) outs.push_back(g_bm_res_sites[gv[p + k]].Cout);
            // DEFECT found by bisect (2026-11-03 13:2x): the twin kernel is byte-exact in the probe
            // (s6/BMERGE_twin_F2/F3.log: diff=0 at b=1,2,4,8) and the DEFAULT side walks are exact,
            // but the merged side is wrong EVEN WITH NR_CGRAPH=0 => the rewrite itself reorders a
            // read. Guarding only the outputs is not enough: a member's INPUT face (its A plane, its
            // skip / cosine planes, its a_scale / b_scale arrays, the fused-quant raw image) may be
            // rewritten by a closure that sits between that member's pack and the merged launch, and
            // the merged launch would then read the LATER value. Protect every member's inputs from
            // the member's own closure index up to the merged launch (last).
            std::vector<std::vector<void*>> ins(take);
            for (size_t k = 0; k < take; ++k) {
                const BmResSite& m = g_bm_res_sites[gv[p + k]];
                void* v[] = { (void*)m.Araw, (void*)m.Braw, (void*)m.skp, (void*)m.cp,
                              (void*)m.as, (void*)m.bs, (void*)m.a16r };
                for (void* x : v) if (x) ins[k].push_back(x);
            }
            bool unsafe = false;
            // INTRA-group dependency: if one member reads a face another member of the SAME group
            // writes (the residual's skip plane IS the previous chain's residual output -- measured
            // 2026-11-03 13:1x: 32 such collisions among the 96 residual sites), then one merged
            // launch cannot preserve the read-before-write order. Refuse the group.
            for (size_t x = 0; x < take && !unsafe; ++x) {
                const BmResSite& mx = g_bm_res_sites[gv[p + x]];
                void* ins[] = { (void*)mx.Araw, (void*)mx.Braw, (void*)mx.skp, (void*)mx.cp,
                                (void*)mx.as, (void*)mx.bs, (void*)mx.a16r };
                for (size_t y = 0; y < take && !unsafe; ++y) {
                    if (y == x) continue;
                    void* oc = g_bm_res_sites[gv[p + y]].Cout;
                    for (void* ip : ins) if (ip && ip == oc) { unsafe = true; break; }
                }
            }
            for (size_t ci = first + 1; ci < last && !unsafe; ++ci) {
                bool member = false;
                for (size_t k = 0; k < take; ++k) if (g_bm_res_sites[gv[p + k]].cmd == ci) { member = true; break; }
                if (member || ci >= g_cmds_touch.size()) continue;
                const std::vector<void*>& tt = g_cmds_touch[ci];
                // an UNREGISTERED closure (touch = {(void*)-1}, see pgraph_ids/pg_push) can read
                // anything, so it must be treated as a conflict: deferring a write past it is not
                // provably safe (the 2-member merge was already non-exact: 2026-11-03 13:3x).
                if (tt.size() == 1 && tt[0] == (void*)-1) { unsafe = true; break; }
                for (size_t k = 0; k < take && !unsafe; ++k) {
                    if (g_bm_res_sites[gv[p + k]].cmd >= ci) continue;   // not yet produced
                    for (void* tp : tt)
                        for (void* ip : ins[k]) if (tp == ip) { unsafe = true; break; }
                }
                if (unsafe) break;
                for (void* tp : tt)
                    for (void* op : outs) if (tp == op) { unsafe = true; break; }
            }
            if (unsafe) { ++refused_dep; continue; }
            BmResGroup* gr = new BmResGroup();
            gr->n = (int)take; gr->slots.resize(take); gr->face.assign(take, nullptr);
            // ALL device objects for the group are created here (rewrite time), outside any
            // captured closure body -- see the note above.
            bool poolfaces0 = getenv("NR_BMERGE_POOLFACES") && atoi(getenv("NR_BMERGE_POOLFACES"));
            if (!poolfaces0)
                for (size_t k = 0; k < take; ++k)
                    gr->face[k] = (int8_t*)sycl::malloc_device(g_bm_res_sites[gv[p + k]].na, *GQ);
            gr->dtab = (s8v8::S8ResDesc*)sycl::malloc_device(
                sizeof(s8v8::S8ResDesc) * (size_t)take, *GQ);
            if (getenv("NR_BMERGE_SCRATCH") && atoi(getenv("NR_BMERGE_SCRATCH"))) {
                size_t ob = (size_t)g_bm_res_sites[gv[p]].Mp * (size_t)g_bm_res_sites[gv[p]].N * 2;
                gr->scratch.resize(take, nullptr);
                for (size_t k = 0; k < take; ++k)
                    gr->scratch[k] = (sycl::half*)sycl::malloc_device(ob, *GQ);
            }
            g_bm_groups.push_back(gr); ++ngrp;
            for (size_t k = 0; k < take; ++k) {
                BmResSite s = g_bm_res_sites[gv[p + k]];
                cmds[s.cmd] = [s, gr, k]() {
                    // dedicated face, NOT from the scratch pool: holding pool blocks would shift
                    // the pool's allocation sequence for every other closure (the engine's alias /
                    // fold-slot machinery depends on that sequence), which is the leading suspect
                    // for the merged side still being non-exact at MAX=2.
                    // NR_BMERGE_POOLFACES=1: take the A face from the scratch pool exactly like the
                    // shipped body does (and return it at the end of this member). This is the
                    // control for the finding that KEEP+SCRATCH was still corrupt: if the graph is
                    // EXACT here, then the only thing my rewrite broke was the POOL ALLOCATION
                    // SEQUENCE (faces held alive / allocated outside the pool), i.e. the engine's
                    // correctness depends on eager face recycling.
                    static int poolfaces = getenv("NR_BMERGE_POOLFACES") ? atoi(getenv("NR_BMERGE_POOLFACES")) : 0;
                    bool put_back_now = false;
                    int8_t* dAp = nullptr;
                    if (poolfaces) { dAp = (int8_t*)pool_get(s.na); put_back_now = true; }
                    else dAp = gr->face[k];          // allocated at rewrite time, NOT here
                    // C61d NOTE: deliberately NOT switched to the BK=64 order -- the merged
                    // launch consumes this plane with s8v8::gemm_b_res_batch, which is still a
                    // BK=32 kernel (not ported in this shovel).  Switching the packer here while
                    // the batch reader stayed BK=32 is exactly the mixed-layout bug that made
                    // plain-1301 diverge by 82.6% of its bytes.  If bmerge is ever ported, both
                    // sides must switch together via gir_bk64_ok().
                    if (s.fused_r) packdev::pack_a_fused(*GQ, s.a16r, dAp, (float*)s.as, s.M, s.Mp, s.K);
                    else           packdev::pack_a(*GQ, s.Araw, dAp, s.M, s.Mp, s.K);
                    int8_t* dBp = cached_pack_b_i8(s.b_id, s.Braw, s.N, s.K);
                    // NR_BMERGE_SCRATCH=1: the merged launch writes a DISCARD buffer instead of the
                    // member's real C face. Together with NR_BMERGE_KEEP=1 (every member also runs
                    // its own shipped gemm at its own position) this separates "the merged launch
                    // produces different values" from "the rewrite itself breaks the graph".
                    static int scr = getenv("NR_BMERGE_SCRATCH") ? atoi(getenv("NR_BMERGE_SCRATCH")) : 0;
                    if (scr && !gr->scratch.empty()) gr->slots[k] = s8v8::S8ResDesc{ dAp, dBp,
                                          (void*)gr->scratch[k], s.as, s.bs, s.skp, s.cp };
                    else gr->slots[k] = s8v8::S8ResDesc{ dAp, dBp, s.Cout, s.as, s.bs, s.skp, s.cp };
                    gr->held.push_back(dAp);
                    // NR_BMERGE_KEEP=1 = the decisive bisect switch (2026-11-03 13:2x): every member
                    // ALSO runs its own shipped gemm at its own position, and the merged launch is
                    // still emitted afterwards. If the 1301 face is then EXACT, the twin launch and
                    // the plumbing are fine and ONLY the deferral of the write is unsafe (chain k+1
                    // reads chain k's residual output, so moving that write later poisons the image).
                    static int keep = getenv("NR_BMERGE_KEEP") ? atoi(getenv("NR_BMERGE_KEEP")) : 0;
                    if (keep)s8v8::gemm_b_res(*GQ, dAp, dBp, s.Cout, s.as, s.bs, s.skp, s.cp,
                                         s.M, s.Mp, s.N, s.K, s.narrow, s.half_skip, s.epi);
                    if (put_back_now) pool_put(dAp);
                    if ((int)gr->held.size() < gr->n) return;      // gemm deferred to the last member
                    // The descriptor table must NOT come from the scratch pool: a pool block is
                    // handed to other closures after pool_put, and their recorded writes then
                    // clobber the table between replays (measured: the merged side produced four
                    // different 1301 md5s across four processes, while the twin kernel itself is
                    // byte-exact in the probe -- s6/BMERGE_twin_F*.log). A dedicated allocation,
                    // uploaded once at capture and never recycled, is stable across replays.
                    s8v8::S8ResDesc* dtab = gr->dtab;   // allocated at rewrite time
                     s8v8::gemm_b_res_batch(*GQ, dtab, s.M, s.Mp, s.N, s.K, gr->n,
                                           s.narrow, s.half_skip, s.epi);
                    // faces stay allocated (dedicated, reused by the same group every pass)
                };
                merged++;
            }
        }
    }
    std::printf("[bmerge] sites=%zu groups=%zu closures_rewritten=%zu level=%d "
                "gemm_launches %zu -> %zu refused_dep=%zu dropped_skipped=%zu\n",
                g_bm_res_sites.size(), ngrp, merged, bmerge_level(), merged, ngrp,
                refused_dep, refused_skip);
    if (getenv("NR_BMERGE_DBG")) {
        for (auto& s2 : g_bm_res_sites)
            std::printf("[bmerge-site] cmd=%zu M=%d N=%d K=%d a=%d w=%d c=%d skip=%d cos=%d\n",
                        s2.cmd, s2.M, s2.N, s2.K, s2.id_a, s2.b_id, s2.id_c, s2.id_skip, s2.id_cos);
    }
    std::fflush(stdout);
    g_bm_res_sites.clear();
}

// ==================== NR_RES_BYTE: the byte-GRID probe (2026-11-02, 字节网格铲) =========
// The open fact DS-takeover §32 named: can the residual / one-phase-intermediate planes live
// on a ONE-BYTE grid without breaking the picture? RES8 (10-31) never measured that -- its
// "17 dB" came from a throwaway 120-layer chain simulation whose script is NOT in-tree
// (grep: only the retelling survives), and the two in-tree RES8 instruments
// (src/bench/sycl/bench_res8.cpp = timing only; bench_res8cmp.cpp:75 = 10log10(sum ref^2 /
// sum err^2), a RELATIVE power SNR on synthetic data, 35.4 dB) never touched the 1301 face.
// So the 17 dB-vs-40 dB "death" mixed calibers -- exactly the trap §33 caught.
//
// This probe measures the grid's VALUES on the real chain: one extra closure per writer site
// quantizes the plane it just wrote to (int8 | e4m3) + a POWER-OF-TWO scale at a chosen
// granularity, and stores the DECODED value back into the f16 plane (quantize-dequantize).
// With pow2 scales the decoded value is EXACTLY representable in f16 (int8: 8 significant
// bits, e4m3: 4 -- both inside f16's 11), so every downstream reader sees precisely the
// numbers a real byte plane + its decode leg would hand it. The quality verdict transfers;
// the traffic verdict does NOT come from this probe (it is a separate, already-measured fact:
// bench_res8 write 0.555->0.417 / read 0.606->0.402 ms/touch, but folded into the gemm
// epilogue the byte form measured 0.49-0.76x = SLOWER, commit 6c0a295 -- because those gemms
// run 10-19x from their DRAM roof).
//
// Layer rule kept (军规 4/9): the switch is at the closure/plan layer and is read ONCE into a
// static at record time; the shipped kernels' bodies are untouched, no runtime branch inside
// any of them. Unset (default) => this code is never entered => shipped path verbatim.
//   NR_RES_BYTE=s8row : the accumulating residual planes -> int8 + per-ROW pow2 scale
//                       (writers: xmx_rec_gemm_int8_residual -> 1267,
//                        xmx_rec_gemm_window_int8_residual -> 1270)
//   NR_RES_BYTE=e4m3w : same planes -> the SHIPPED e4m3 grid (qr_e4m3 = +-448 sat_cast clamp
//                       + round-half-even, publish_kernel.hpp:24 -- the lmxx 0.10 black-block
//                       cure we already had) + per-WINDOW pow2 scale
//   NR_RES_BYTE=s8mid : only the one-phase FFN intermediates (xmx_rec_gemm_int8_batched
//                       outputs = 1274/1275, planes that get requantized anyway) -> int8 + scale
//   NR_RES_GRAN=<rows>: rows sharing ONE scale = the experiment variable (default 1 for
//                       s8row/s8mid, 64 for e4m3w = one 8x8 token window)
static int rb_mode() {
    static int m = [](){
        const char* s = getenv("NR_RES_BYTE");
        if (!s || !*s) return 0;
        if (!strcmp(s, "s8row")) return 1;
        if (!strcmp(s, "e4m3w")) return 2;
        if (!strcmp(s, "s8mid")) return 3;
        return -1;                       // unknown spelling -> loud, never silent
    }();
    return m;
}
static unsigned rb_gran() {
    static unsigned g = [](){
        const char* s = getenv("NR_RES_GRAN");
        if (s && *s) { int v = atoi(s); return (v > 0) ? (unsigned)v : 1u; }
        return rb_mode() == 2 ? 64u : 1u;
    }();
    return g;
}
static int rb_sites = 0;                 // record-time census (BOTH recordings count)
// NR_RES_SITES=<comma list> restricts which writer families get snapped (residual / wres /
// batched). The 2026-11-02 plane census needs this to separate the two verdicts: buffer 1270
// (window residual) sits 0.00% OFF the e4m3 grid while 1267 (the accumulating residual) sits
// 98.4% off it -- without site selection one number would have covered both and lied.
static bool rb_site_ok(const char* site) {
    static const char* sel = getenv("NR_RES_SITES");
    if (!sel || !*sel) return true;
    const size_t L = strlen(site);
    for (const char* p = sel; *p; ) {
        if (!strncmp(p, site, L) && (p[L] == ',' || p[L] == '\0')) return true;
        while (*p && *p != ',') ++p;
        while (*p == ',') ++p;
    }
    return false;
}
static long long rb_elems = 0;
static int rb_refused = 0, rb_scratch_skip = 0;
// NR_RES_LIVE=1 = the LIVENESS WITNESS: after the snap the plane is multiplied by 0.5. If a
// site's plane is on the live path to buffer 1301 the face MUST change; if the snap alone left
// the face bit-EXACT and the witness changes it, the snap was a genuine no-op ON A LIVE PLANE.
// If neither changes the face, the SITE IS DEAD -- which is NOT the same finding, and the
// 2026-11-02 s8mid round needed exactly this distinction.
static float rb_live() {
    static float v = getenv("NR_RES_LIVE") ? 0.5f : 1.0f;
    return v;
}
static const char* rb_mode_name() {
    static const char* n[] = { "(off)", "s8row", "e4m3w", "s8mid", "(REFUSED:unknown spelling)" };
    const int m = rb_mode();
    return n[(m >= 1 && m <= 3) ? m : (m == 0 ? 0 : 4)];
}
// MODE 1 = int8 + pow2 scale; MODE 2 = e4m3 grid + pow2 scale (the +-448 clamp lives in
// qr_e4m3). Coverage = rows x cols CONTIGUOUS from the plane base, exactly how the recorder
// hands the plane out (`void* Cout = ic->second.p`): every tier writes ITS pyramid slice from
// the same base at its own row width (the C=64 tier's 32640x64 and the C=1024 tier's 256x1024
// are the same memory seen at different widths), so rows is capped by the buffer's bytes.
// Re-snapping an already-snapped value is IDEMPOTENT on both grids (pow2 scale ratios keep
// every significant bit; rint() of an exact integer is itself; qr_e4m3 is exact on an
// e4m3x pow2 value) => overlapping slice coverage cannot double-count the damage.
// (this file's recorders live inside extern "C", and a template needs C++ linkage -- the
// probe kernel is therefore wrapped; it is NOT a shipped op, nothing outside this shovel sees it)
extern "C++" {
template <int MODE>
static void rb_qdq(sycl::half* p, unsigned rows, unsigned cols, unsigned gran, float post) {
    const unsigned groups = (rows + gran - 1u) / gran;
     GQ->parallel_for(sycl::range<1>(groups), [=](sycl::item<1> it) {
        const unsigned r0 = (unsigned)it.get_id(0) * gran;
        const unsigned r1 = (r0 + gran < rows) ? r0 + gran : rows;
        // one scale per (gran rows x cols) window
        float peak = 0.f;
        for (unsigned r = r0; r < r1; ++r) {
            sycl::half* row = p + (size_t)r * cols;
            for (unsigned c = 0; c < cols; ++c) {
                float v = (float)row[c]; v = v < 0.f ? -v : v;
                if (v > peak) peak = v;
            }
        }
        // pow2 scale = 2^ceil(log2(peak/FULL)) -- the RES8 form VERBATIM
        // (gemm_s8_v8_kernel.hpp:830, host twin bench_res8cmp.cpp:48-49), bit-trick so no
        // libdevice ilogb/ldexp enters a device kernel.
        float sc = 1.f;
        if (peak > 0.f) {
            const float t = peak / (MODE == 1 ? 127.f : 448.f);
            const uint32_t bb = sycl::bit_cast<uint32_t>(t);
            int e = (int)((bb >> 23) & 0xFFu) - 127;
            if ((bb & 0x7FFFFFu) != 0u) ++e;                // ceil, not floor
            sc = sycl::bit_cast<float>((uint32_t)(e + 127) << 23);
        }
        const float inv = 1.f / sc;                          // pow2 -> the divide is exact
        for (unsigned r = r0; r < r1; ++r) {
            sycl::half* row = p + (size_t)r * cols;
            for (unsigned c = 0; c < cols; ++c) {
                float v = (float)row[c] * inv;               // pow2 -> no fdiv noise
                if (MODE == 1) {
                    v = sycl::rint(v);
                    v = v < -127.f ? -127.f : (v > 127.f ? 127.f : v);
                } else {
                    v = qr_e4m3(v);                          // +-448 clamp + round-even
                }
                row[c] = (sycl::half)(v * sc * post);       // decode back, exact in f16
            }
        }
    });
}
} // extern "C++" (the probe template)
// push the probe closure immediately AFTER the writer closure (record time; the frozen graph
// runs closures in push order, so this lands between the writer and every reader of the plane)
static void rb_push(int cbuf, unsigned rows, unsigned cols, const char* site) {
    const int m = rb_mode();
    if (m <= 0) return;                                    // default: never entered
    const bool want_mid = (m == 3);
    const bool is_batched = (strcmp(site, "batched") == 0);
    if (want_mid != is_batched) return;                    // s8row/e4m3w = residual planes only
    if (!rb_site_ok(site)) return;                         // NR_RES_SITES family filter
    auto it = g_bufs.find(cbuf);
    if (it == g_bufs.end() || !it->second.p) return;
    if (it->second.esz != 2) {                             // not an f16 plane -> wrong geometry
        std::printf("[res-byte] %s buf=%d esz=%zu REFUSED (not an f16 plane)\n",
                    site, cbuf, it->second.esz);
        return;
    }
    const size_t bytes = it->second.bytes;
    // The plan's FIRST recording (the scratch the dump made, begin@3922 -> abort@5295) recreates
    // the same buffer ids as TINY placeholders (buf 1268 = 256 B there, 66,846,720 B in the
    // captured recording) -- those closures never run (xmx_abort clears g_cmds), so a placeholder
    // is counted, not printed 160 times. The captured recording gets the real geometry.
    if (bytes < 4096) { ++rb_scratch_skip; return; }
    const size_t maxrows = bytes / ((size_t)cols * 2u);
    if (rows > maxrows) rows = (unsigned)maxrows;           // 军规 10: never touch beyond the alloc
    if (rows == 0) {
        static std::vector<std::string> seen;
        const std::string key = std::string(site) + ":" + std::to_string(cbuf) + ":" + std::to_string(cols);
        if (std::find(seen.begin(), seen.end(), key) == seen.end()) {
            seen.push_back(key);
            std::printf("[res-byte] %s buf=%d cols=%u bytes=%zu REFUSED (no whole row fits)\n",
                        site, cbuf, cols, bytes);
        }
        ++rb_refused; return;
    }
    const unsigned gran = rb_gran();
    const int mode = m;
    const float post = rb_live();
    sycl::half* p = (sycl::half*)it->second.p;
    g_cmd_names.push_back("res_qdq");
    pgraph_extra(cbuf);                                    // touches exactly this plane
    pg_push([=]() {
        if (mode == 1) rb_qdq<1>(p, rows, cols, gran, post);
        else           rb_qdq<2>(p, rows, cols, gran, post);
    });
    ++rb_sites; rb_elems += (long long)rows * cols;
    if (rb_sites <= 14)
        std::printf("[res-byte] push site=%s buf=%d rows=%u cols=%u bytes=%zu gran=%u\n",
                    site, cbuf, rows, cols, bytes, gran);
}
// ==================== NR_BG_FOLD: the take_b fold's form gate + census ====================
// The fold mechanism itself is the shipped qfuse_take_b (consumer reads the producer's f16
// plane and emits fragment-order int8 + scale; the QUANT closure is no-op'd WHOLE -- 全动或全
// 不动, 31). What was wrong with it is the FORM gate: `lda<=512 && sa==0` left every
// col-slice site (sa==K, the frame's majority) on pack_a_fused_b, which re-reads the whole
// lda-wide row for the peak ONCE PER GROUP -- the historical +25ms disease the b1 comment
// names (pack_device.hpp:550-557). b1 (single read) already supports those shapes with
// COMPILE-TIME select offsets (pack_device.hpp:604-607); the gate just never let them in.
static long g_bfold_sites = 0, g_bfold_b1 = 0, g_bfold_b = 0;
static bool bg_b1_ok(unsigned K, unsigned lda, unsigned sa, unsigned batch) {
    if (!K || (K % 32u) || batch == 0u) return false;
    // b1 loads the row as ONE block of lda halfs and only ever dispatches lda in
    // {64,128,256,512} (the else branch reads a full 512) -- anything else is out of range.
    if (lda != 64u && lda != 128u && lda != 256u && lda != 512u) return false;
    const unsigned kb_n = K / 32u;
    if (sa == 0u) return K <= lda;                       // shared-A: the row IS the gemm row
    if (kb_n == 1u && (sa == 64u || sa == 128u) &&
        (batch - 1u) * sa + K <= lda) return true;        // col-slice, constexpr offsets only
    return false;
}
static void rb_report(int graphid) {
    // the fold census prints even when NR_RES_BYTE is off (they are independent shovels)
    if (getenv("NR_BG_FOLD") || getenv("NR_Q_FUSE_B"))
        std::printf("[bg-fold] graph=%d folded_consumers=%d  b1_single_read=%d  b_per_group=%d "
                    "live_witness=%d\n", graphid, (int)g_bfold_sites, (int)g_bfold_b1,
                    (int)g_bfold_b, getenv("NR_BG_FOLD_LIVE") ? 1 : 0);
    const int m = rb_mode();
    if (m == 0) return;
    std::printf("[res-byte] graph=%d mode=%s gran=%u live=%g sites='%s' sites_pushed=%d elems=%lld "
                "refused=%d scratch_placeholders=%d (record-time census: BOTH recordings push, "
                "only the captured graph runs)\n",
                graphid, rb_mode_name(), rb_gran(), rb_live(),
                getenv("NR_RES_SITES") ? getenv("NR_RES_SITES") : "*",
                rb_sites, rb_elems, rb_refused, rb_scratch_skip);
    if (m < 0) std::printf("[res-byte] NR_RES_BYTE='%s' UNKNOWN -- nothing applied\n",
                           getenv("NR_RES_BYTE"));
    std::fflush(stdout);
}

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
static std::vector<std::vector<std::vector<void*>>> g_graph_touch;   // PGRAPH: per-graph touch sets
static std::vector<std::vector<LCount>> g_graph_launch;              // #140: per-graph launch census
static std::vector<std::vector<std::vector<int>>> g_graph_ids;       // #140: per-graph id snapshots
static std::vector<std::vector<const char*>> g_graph_name;           // #141: per-graph aligned names
#ifdef _WIN32
static int fence_host_wait(void);   // defined in the fence block; graph_run calls it
#endif
// B step 1 (knife2b #106): the family census + legality REPORT. It reads the frozen
// record-time vectors and prints what a future merge cut would find; it changes nothing:
// no closure is reordered, merged or dropped, and the whole function is behind
// NR_GROUP_TRACE (unset => never entered). Legality here means "is this family already
// adjacent in record order, and how far apart are its members" -- the two facts the
// reorder question (Q1/Q2/Q3 in #106) turns on. The dependency blockers themselves come
// from the [pgt] id dump, because a touch overlap between a member and an intervening
// closure is exactly what a reorder must not break (section 56b R4/R6/R9).
static void group_census_report(int graph_idx) {
    if (!getenv("NR_GROUP_TRACE")) return;
    size_t n = g_cmds.size();
    std::printf("[vec-align] graph=%d cmds=%zu touch=%zu group=%zu poolblk=%zu idsnap=%zu launch=%zu name=%zu || names=%zu name_offset=%zu",
                graph_idx, n, g_cmds_touch.size(), g_cmds_group.size(),
                g_cmds_poolblk.size(), g_pg_ids_snap.size(), g_cmds_launch.size(), g_cmds_name.size(), g_cmd_names.size(),
                g_cmd_names.size() >= n ? g_cmd_names.size() - n : 0);
    // the FIVE per-capture vectors must be the same length (rule 57); g_cmd_names is the
// shipped exception on purpose (it accumulates both recordings; name_offset points at this one)
    bool ok = (n == g_cmds_touch.size() && n == g_cmds_group.size()
             && n == g_cmds_poolblk.size() && n == g_pg_ids_snap.size()
             && n == g_cmds_launch.size() && n == g_cmds_name.size());
    std::printf(" -> %s\n", ok ? "ALIGNED" : "REFUSED: record-time vectors are NOT the same length");
    if (!ok) { std::fflush(stdout); return; }
    std::map<std::string, std::vector<size_t>> fam;
    for (size_t i = 0; i < n; ++i) fam[std::string(g_cmd_names[i])].push_back(i);
    for (auto& kv : fam) {
        const std::vector<size_t>& v = kv.second;
        int adj = 0, mingap = 1 << 30, sumgap = 0, pairs = 0;
        for (size_t k = 0; k + 1 < v.size(); ++k) {
            int gap = (int)(v[k + 1] - v[k]);
            if (gap == 1) ++adj;
            if (gap < mingap) mingap = gap;
            sumgap += gap; ++pairs;
        }
        size_t conflicts = 0, sentinels = 0;
        for (size_t a = 0; a < v.size(); ++a) {
            const std::vector<void*>& ta = g_cmds_touch[v[a]];
            if (ta.size() == 1 && ta[0] == (void*)-1) ++sentinels;
            for (size_t b = 0; b < n; ++b)
                if (b != v[a] && pgraph_conflict(ta, g_cmds_touch[b])) ++conflicts;
        }
        std::printf("[grp] family=%s members=%zu adjacent_pairs=%d min_gap=%d avg_gap=%.2f touch_conflicts=%zu sentinel_members=%zu group=%d",
                    kv.first.c_str(), v.size(), adj,
                    v.size() > 1 ? mingap : -1,
                    pairs ? (double)sumgap / (double)pairs : 0.0, conflicts, sentinels,
                    v.empty() ? 0 : g_cmds_group[v[0]]);
        std::printf(" idx=");
        for (size_t k = 0; k < v.size() && k < 16; ++k) std::printf(" %zu", v[k]);
        std::printf(v.size() > 16 ? " ..." : "");
        std::printf("\n");
    }
    std::fflush(stdout);
}
// ---- B step 2 (i): the minimal REORDER mechanism (knife2b #108). ---------------------------
// Knife 1 died in section 56b because a MERGE silently changed what other closures read (R4:
// a member input rewritten between pack and the merged launch; R6: holding a pool block changes
// later closures' fetch sequence; R9: the rewrite itself is a graph change). The census (#106)
// then proved no merge-relevant family is adjacent, so any merge needs a reorder first.
// This is the smallest possible reorder: move ONE closure from index FROM to index TO, atomically
// across every record-parallel vector (rule 57 keeps holding, and [vec-align] proves it).
// NR_BMERGE_ORDER is presence-gated: unset => the function returns before touching anything.
// Spec: comma-separated "<from>><to>", e.g. "569>571,236>238".
static std::vector<std::pair<int,int>> g_order_moves;   // what was actually applied
static void bmerge_order_apply() {
    g_order_moves.clear();
    const char* spec = getenv("NR_BMERGE_ORDER");
    if (!spec || !*spec) return;
    size_t n = g_cmds.size();
    size_t noff = g_cmd_names.size() >= n ? g_cmd_names.size() - n : 0;   // names keep both recordings
    const char* p = spec;
    while (*p) {
        while (*p == ' ' || *p == ',') ++p;
        if (!*p) break;
        int from = atoi(p);
        const char* q = strchr(p, '>');
        if (!q) break;
        int to = atoi(q + 1);
        p = q + 1; while (*p && *p != ',') ++p;
        if (from < 0 || to < 0 || (size_t)from >= n || (size_t)to >= n || from == to) continue;
        auto move_at = [&](auto& vec, size_t off) {
            auto it = vec.begin() + (long)(off + (size_t)from);
            auto v = *it;
            vec.erase(it);
            vec.insert(vec.begin() + (long)(off + (size_t)to), v);
        };
        move_at(g_cmds, 0); move_at(g_cmds_touch, 0); move_at(g_cmds_group, 0);
        move_at(g_cmds_poolblk, 0); move_at(g_pg_ids_snap, 0); move_at(g_cmd_names, noff);
        move_at(g_cmds_launch, 0);
        move_at(g_cmds_name, 0);   // #141: the sixth vector moves with the rest
        g_order_moves.push_back(std::make_pair(from, to));
    }
}
static void bmerge_order_report() {
    if (g_order_moves.empty()) return;
    std::printf("[border] moves=%zu", g_order_moves.size());
    for (auto& mv : g_order_moves) std::printf(" %d>%d", mv.first, mv.second);
    std::printf("\n");
    for (auto& mv : g_order_moves) {
        int lo = mv.first < mv.second ? mv.first : mv.second;
        int hi = mv.first < mv.second ? mv.second : mv.first;
        std::printf("[border-span] %d..%d names=", lo, hi);
        size_t noff2 = g_cmd_names.size() >= g_cmds.size() ? g_cmd_names.size() - g_cmds.size() : 0;
        for (int i = lo; i <= hi; ++i) std::printf(" %s", g_cmd_names[noff2 + (size_t)i]);
        std::printf("\n");
    }
    std::fflush(stdout);
}
// The [pgt] dump above is printed inside pg_push, i.e. at RECORD time -- a reorder applied at
// capture time is invisible to it. This dump runs on the frozen vectors, after the reorder, so
// the declared-set check (s6/k1_declare.md) can actually see the permutation. Presence-gated.
static std::map<void*, size_t> g_ptr_ord;   // canonical pointer ordinals (rule 64)
static void launch_hop_dump(int gid) {
    if (!getenv("NR_LCOUNT")) return;
    if (gid < 0 || gid >= (int)g_graphs.size()) return;
    size_t n = g_graphs[gid].size();
    const std::vector<LCount>* L = ((size_t)gid < g_graph_launch.size() && g_graph_launch[gid].size() == n)
                                   ? &g_graph_launch[gid] : nullptr;
    const std::vector<std::vector<int>>* S = ((size_t)gid < g_graph_ids.size() && g_graph_ids[gid].size() == n)
                                             ? &g_graph_ids[gid] : nullptr;
    const std::vector<const char*>* N = ((size_t)gid < g_graph_name.size() && g_graph_name[gid].size() == n)
                                        ? &g_graph_name[gid] : nullptr;
    size_t noff = (g_cmd_names.size() >= n) ? g_cmd_names.size() - n : 0;
    if (!L || !S || !N)
        std::printf("[lcount] VECTOR-DESYNC graph=%d launch=%zu ids=%zu closures=%zu\n", gid,
                    (size_t)gid < g_graph_launch.size() ? g_graph_launch[gid].size() : 0, n,
                    (size_t)gid < g_graph_ids.size() ? g_graph_ids[gid].size() : 0);
    long long tp = 0, tm = 0, ts = 0, thopN = 0, tnoop = 0, tscr = 0; unsigned long long thopB = 0;
    for (size_t i = 0; i < n; ++i) {
        int pfx = L ? (*L)[i].pf : 0, mcx = L ? (*L)[i].mc : 0, msx = L ? (*L)[i].ms : 0;
        long long scx = L ? (*L)[i].scr : 0; tscr += scx;
        size_t planes = S ? (*S)[i].size() : 0;
        unsigned long long bytes = 0;
        if (S) for (int bid : (*S)[i]) { auto it = g_bufs.find(bid); if (it != g_bufs.end()) bytes += it->second.bytes; }
        tp += pfx; tm += mcx; ts += msx; thopN += (long long)planes; thopB += bytes;
        int noop = g_skipped_cmds.count(i) ? 1 : 0; tnoop += noop;
        const char* lbl = ((size_t)gid < g_graph_names.size() && noff + i < g_graph_names[gid].size())
                          ? g_graph_names[gid][noff + i] : "?";
        std::printf("[lcount] cmd=%zu name=%s lbl=%s noop=%d pf=%d mc=%d ms=%d | [hop] planes=%zu bytes=%llu scr=%lld", i,
                    (N ? (*N)[i] : "?"), lbl,
                    noop, pfx, mcx, msx, planes, bytes, scx);
        if (S) { std::printf(" ids="); for (int bid : (*S)[i]) std::printf(" %d", bid); }
        std::printf("\n");
    }
    // The per-id sizes, so the hop census can be split by class offline (tooth 2). Without this the
    // log only carries per-closure byte SUMS and the classes cannot be reconciled.
    std::printf("[bufsizes] count=%zu", g_bufs.size());
    for (auto& kv : g_bufs) std::printf(" %d:%llu:%d:%d", kv.first, (unsigned long long)kv.second.bytes, kv.second.imported ? 1 : 0, kv.second.gen);
    std::printf("\n");
    std::printf("[lcount-total] closures=%zu noop=%lld live=%lld pf=%lld mc=%lld ms=%lld skipped_sites=%ld | [hop-total] planes=%lld bytes=%llu scr=%lld\n",
                n, tnoop, (long long)n - tnoop, tp, tm, ts, g_lc_skipped, thopN, thopB, tscr);
    std::fflush(stdout);
}

static void pgraph_final_dump() {
    g_ptr_ord.clear();
    if (!getenv("NR_PG_FINAL")) return;
    size_t n = g_cmds.size();
    size_t noff = g_cmd_names.size() >= n ? g_cmd_names.size() - n : 0;
    for (size_t i = 0; i < n; ++i) {
        std::printf("[pgt-final] cmd=%zu name=%s ids=", i, g_cmd_names[noff + i]);
        for (int id : g_pg_ids_snap[i]) std::printf(" %d", id);
        // ... and the POINTERS, as canonical first-seen ordinals. Scratch versioning re-points a
        // logical id to a different allocation, so the id list alone cannot show it: the engine's
        // conflict test (pgraph_conflict) compares void*, and military rule 64 says compare
        // sequences by ordinal, never by raw address. ptrs= is what the wave planner sees.
        std::printf(" || ptrs=");
        for (void* p : g_cmds_touch[i]) {
            auto o = g_ptr_ord.find(p);
            if (o == g_ptr_ord.end()) { o = g_ptr_ord.emplace(p, g_ptr_ord.size() + 1).first; }
            std::printf(" %llu", (unsigned long long)o->second);
        }
        std::printf("\n");
    }
    std::fflush(stdout);
}
int xmx_graph_capture(void) {
    if (!g_recording) FAILMSG("not recording");
    // NR_SKIP_CHAINS: whole-chain no-ops, applied to the frozen closure list BEFORE the
    // graph is stored (default empty => this function is never entered; see the block above).
    skip_chains_apply(g_cmds, g_cmd_names, (int)g_graphs.size());
    bmerge_apply(g_cmds);      // KNIFE 1: runs AFTER the skip pass, so skipped legs cannot merge
    vit_reuse_apply(g_cmds, g_cmd_names, (int)g_graphs.size());   // C25: twin list (OFF = no-op)
    bmerge_order_apply();      // B step 2 (i): presence-gated REORDER (NR_BMERGE_ORDER), default off
    bmerge_order_report();     // what it moved, so the declared-set check has something to read
    pgraph_final_dump();       // the FROZEN touch sets, i.e. after any reorder -- [pgt] cannot show it
    rb_report((int)g_graphs.size());      // NR_RES_BYTE census (no-op when the switch is unset)
    group_census_report((int)g_graphs.size());   // B step 1: report-only (NR_GROUP_TRACE)
    if (sp_on()) { std::printf("[scrpriv] versioned_ids=%zu extra_bytes=%zu (%.1f MiB)\n",
                    g_sp_live.size(), g_sp_extra_bytes, (double)g_sp_extra_bytes / 1048576.0); std::fflush(stdout); }
    g_graphs.push_back(std::move(g_cmds)); g_graph_names.push_back(std::move(g_cmd_names));
    g_graph_touch.push_back(std::move(g_cmds_touch)); g_cmds_touch.clear();
    g_graph_launch.push_back(std::move(g_cmds_launch)); g_cmds_launch.clear();   // #140
    g_graph_ids.push_back(std::move(g_pg_ids_snap)); g_pg_ids_snap.clear();      // #140
    g_graph_name.push_back(std::move(g_cmds_name)); g_cmds_name.clear();        // #141
    g_cmds.clear();
    // B step 1 (knife2b #106): the record-time side vectors are PER-CAPTURE, exactly like
    // g_cmds/g_cmds_touch. g_cmd_names is the odd one out on purpose - it keeps growing across
    // recordings and the skip pass addresses it through name_offset (the [skip-chains] header
    // prints closures=691 names=1382 name_offset=691). Forgetting to reset the new vectors is
    // exactly how section 85 got us: a bookkeeping desync looks like a numerics bug.
    g_cmds_group.clear(); g_cmds_poolblk.clear(); g_pg_ids_snap.clear(); g_cmds_launch.clear(); g_cmds_name.clear();
    g_quant_pk.clear(); g_fused_quant.clear();          // record-scoped registries die
    g_pending_fold_slot = SIZE_MAX; g_fold_slot.clear(); // with the stream (10-27 audit)
    s6_reset();                                          // S6 chain candidate: ditto
    g_recording = false;
    // C25 NR_VIT_REUSE: the twin (the same closure COUNT, the 8 ViT attention chains
    // dissolved) is stored as an EXTRA graph id so xmx_graph_run needs nothing but the
    // id swap. Default OFF => g_vit_twinready is false and this block never runs.
    g_vit_master = (int)g_graphs.size() - 1;
    g_vit_twin = -1;
    if (g_vit_twinready && g_vit_twincmds.size() == g_graphs[g_vit_master].size()) {
        std::vector<std::function<void()>> twin = std::move(g_vit_twincmds);
        g_graphs.push_back(std::move(twin));
        g_graph_names.push_back(g_graph_names.back());     // same names, same length
        g_graph_touch.push_back(g_graph_touch.back());     // the A touch sets (conservative)
        std::vector<LCount> lc = g_graph_launch.back();
        for (LCount& e : lc) e = LCount();                 // the twin counts separately
        g_graph_launch.push_back(std::move(lc));
        g_graph_ids.push_back(g_graph_ids.back());
        g_graph_name.push_back(g_graph_name.back());
        g_vit_twin = (int)g_graphs.size() - 1;
        std::printf("[vit-reuse] graph=%d TWIN stored as graph=%d (closures=%zu, master=%d)\n",
                    g_vit_master, g_vit_twin, g_graphs[g_vit_twin].size(), g_vit_master);
        std::fflush(stdout);
    } else if (vit_reuse_level()) {
        std::printf("[vit-reuse] graph=%d NO TWIN (twinready=%d)\n", g_vit_master,
                    (int)g_vit_twinready);
        std::fflush(stdout);
    }
    // C29 level 4: store the three split graphs (A / Bm / Bt) as extra ids. The plan only
    // ever names the MASTER; xmx_graph_run does the split itself.
    if (g_vit_splitready && vit_reuse_level() == 4 && g_vit_master >= 0 &&
        g_vit_A.size() + g_vit_Bm.size() == g_graphs[g_vit_master].size()) {
        const size_t hc = g_vit_hostcmd_stored;
        auto push_slice = [&](std::vector<std::function<void()>>& lst, size_t from, size_t to) {
            g_graphs.push_back(std::move(lst));
            const std::vector<const char*>& nm = g_graph_names[g_vit_master];
            g_graph_names.push_back(std::vector<const char*>(nm.begin() + from, nm.begin() + to));
            const std::vector<std::vector<void*>>& tt = g_graph_touch[g_vit_master];
            g_graph_touch.push_back(std::vector<std::vector<void*>>(tt.begin() + from, tt.begin() + to));
            g_graph_launch.push_back(std::vector<LCount>(to - from));
            if (g_graph_ids.size() == (size_t)g_vit_master + 1) {
                const std::vector<std::vector<int>>& idv = g_graph_ids[g_vit_master];
                if (idv.size() == g_graphs[g_vit_master].size())
                    g_graph_ids.push_back(std::vector<std::vector<int>>(idv.begin() + from, idv.begin() + to));
                else g_graph_ids.push_back(std::vector<std::vector<int>>());
            } else g_graph_ids.push_back(std::vector<std::vector<int>>());
            if (g_graph_name.size() == (size_t)g_vit_master + 1) {
                const std::vector<const char*>& an = g_graph_name[g_vit_master];
                if (an.size() == g_graphs[g_vit_master].size())
                    g_graph_name.push_back(std::vector<const char*>(an.begin() + from, an.begin() + to));
                else g_graph_name.push_back(std::vector<const char*>());
            } else g_graph_name.push_back(std::vector<const char*>());
            return (int)g_graphs.size() - 1;
        };
        g_vit_gA  = push_slice(g_vit_A,  0,           hc + 1);
        g_vit_gBm = push_slice(g_vit_Bm, hc + 1,      g_graphs[g_vit_master].size());
        g_vit_gBt = push_slice(g_vit_Bt, hc + 1,      g_graphs[g_vit_master].size());
        std::printf("[vit-reuse] SPLIT stored: A=%d (0..%zu) Bm=%d Bt=%d (closures=%zu, master=%d)\n",
                    g_vit_gA, hc, g_vit_gBm, g_vit_gBt, g_graphs[g_vit_master].size(), g_vit_master);
        std::fflush(stdout);
    }
    g_vit_twincmds.clear(); g_vit_twinready = false;
    g_vit_recap = 1; g_vit_pframe = 0;   // C35: geometry / mode / plan change => compute now
    return g_vit_master;   // the plan's graph id stays the MASTER; the twin and the split
                           // graphs are reached only by xmx_graph_run's own selection
}
static int xmx_graph_run_one(int id);   // fwd: the shipped single-graph replay path
// C29: the public entry. Level 4 (NR_VIT_REUSE=4) runs the frame as TWO submits -- A up to
// and including the criterion closure, then Bm (segment computed) or Bt (segment dissolved)
// chosen from THIS frame's counters -- so the reuse decision certifies the frame it applies
// to. Every other level (and the shipped default 0) is the single existing path.
int xmx_graph_run(int id) {
    if (vit_reuse_level() == 4 && g_vit_splitready && g_vit_gA >= 0 && id == g_vit_master) {
        int pa = xmx_graph_run_one(g_vit_gA);
        if (pa < 0) return pa;
        vit_verdict_update4();
        int pb = xmx_graph_run_one(g_vit_skip_next ? g_vit_gBt : g_vit_gBm);
        vit_frame_note(g_vit_skip_next ? g_vit_gBt : g_vit_gBm);
        g_vit_ran_once = 1;
        if (pb < 0) return pb;
        return pa + pb;
    }
    int rv = xmx_graph_run_one(id);
    // C30 (A) level 6: the decision was taken ON THE DEVICE inside this very frame (the
    // criterion node runs before the span, the span kernels read the flag at their entry).
    // The host only mirrors it, after the frame, for NR_VIT_TRACE -- a plain read of
    // malloc_host memory, no driver call, and it never selects a graph.
    if (vit_reuse_level() == 6 && rv >= 0 && id == g_vit_master && g_vit_hf) {
        g_vit_lastmax = g_vit_hf[1]; g_vit_lastsum = g_vit_hf[2];
        g_vit_skip_next = g_vit_hf[0];
        g_vit_frames++;
        vit_frame_note(id);   // C34: the ONE-LINE wiring -- level 6 never reached the note, so
                              // SELFATT (flag / earlyout=k/73 / seq from the malloc_host mirror)
                              // never printed. No business face is touched by this readout.
        vit_trace();
        g_vit_skip_next = 0;
    }
    return rv;
}
static int xmx_graph_run_one(int id) {
    if (g_recording) FAILMSG("cannot replay during recording");
    if (id < 0 || id >= (int)g_graphs.size() || g_graphs[id].empty())
        FAILMSG("graph is not live");
    // C25 NR_VIT_REUSE: the per-frame master/twin pick. The verdict comes from the
    // criterion that ran INSIDE the previous frame's graph (shared counters, already
    // valid because the replay waits). OFF => this block is never entered.
    const int vit_lvl_now = vit_reuse_level();
    if (vit_lvl_now >= 1 && vit_lvl_now <= 3 && g_vit_twin >= 0 && (id == g_vit_master || id == g_vit_twin)) {
        if (vit_period_value() >= 1) {
            // C35: fixed-period reuse (lmxx mode 3). The reset conditions, all host-side:
            //   * a fresh capture => the plan / geometry / fused mode / buffer set changed, so the
            //     next frame MUST compute (this also covers the "mode switch" reset);
            //   * a gap longer than vit_reset_gap_ms (the idle case);
            //   * the first frame: the counter starts at 0 and 0 % period == 0 => master, so the
            //     segment is always computed once (the rule we verified with the 0xFF shadow).
            // history/seed CONTENT changes are not observable without a device read, which this
            // design deliberately avoids: the period IS the loss knob the user tunes.
            const char* why = "period";
            long long now = vit_now_ms();
            if (g_vit_recap) { g_vit_pframe = 0; g_vit_recap = 0; why = "recapture"; }
            else if (g_vit_prev_run_ms && now - g_vit_prev_run_ms > (long long)nr_cfg_i("vit_reset_gap_ms")) {
                g_vit_pframe = 0; why = "gap";
            }
            g_vit_prev_run_ms = now;
            const int per = vit_period_value();
            const unsigned long idx = g_vit_pframe % (unsigned long)per;
            g_vit_skip_next = idx ? 1 : 0;
            if (g_vit_skip_next) why = "reuse";
            vit_period_log(nr_cfg_i("vit_mode"), g_vit_skip_next, per, idx, why);
            std::printf("[vit-reuse] PERIOD frame=%lu decision=%s period=%d idx=%lu reset=%s\n",
                        g_vit_pframe, g_vit_skip_next ? "twin" : "master", per, idx, why);
            std::fflush(stdout);
            ++g_vit_pframe;
        } else {
            vit_verdict_update();
        }
        id = g_vit_skip_next ? g_vit_twin : g_vit_master;
        vit_frame_note(id);
        g_vit_ran_once = 1;   // this frame's graph carries the criterion (chain 1's QUANT
                              // survives in the twin too), so a verdict will exist
    } else if (vit_reuse_level() == 5 && id == g_vit_master) {
        // C30 事二(2): TELEMETRY build -- the criterion node runs (it lives in the surviving
        // closure before the span), the magnitude verdict is computed from THIS frame's
        // counters, NR_VIT_TRACE gets its line, and NOTHING is dissolved or skipped.
        vit_verdict_update4();
        g_vit_skip_next = 0;
        vit_frame_note(id);
        g_vit_ran_once = 1;
    }
    int passes = (int)g_graphs[id].size();
    g_lc_vec = ((size_t)id < g_graph_launch.size() && g_graph_launch[id].size() == g_graphs[id].size())
               ? &g_graph_launch[id] : nullptr;
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
            std::vector<long> pfs;                       // (甲) #153: launches charged per closure (helper entries)
            ms.reserve(g_graphs[id].size());
            int lci = 0;
            for (auto& fn : g_graphs[id]) {
                // (甲) #153: this diagnostic pass now CHARGES the closure, so the same line that
                // carries the closure's GPU ms also carries its launch count (helper entries).
                // #141's "not counted" applied to the record pass; here counting is what makes
                // "price per launch = ms / pf" a reading instead of a guess. Cost: one closure
                // bracket per pass (691/frame), NOT a statement at any launch site (军规 132).
                lc_begin(lci);
                auto t0 = std::chrono::steady_clock::now();
                fn();
                long pfnow = g_lc_ticks - g_lc_tick0;
                lc_end();
                pfs.push_back(pfnow);
                lci++;
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
            // KNIFE2 STEP-0 instrument (2026-11-02, 军规 40): family prices apportioned by
            // FLOPs are ranking-only (6 negative violation rows = apportionment artifacts).
            // Dump EVERY closure's second-pass GPU ms so merged-site prices become measured.
            // Diagnostic path only (NR_RUN_TIMING gated); default replay is untouched.
            if (f) {
                for (size_t i = 0; i < ms.size(); i++) {
                    const char* nm2 = (id < (int)g_graph_names.size() && i < (int)g_graph_names[id].size())
                                      ? g_graph_names[id][i] : "?";
                    std::fprintf(f, "rtcsv %zu %s %.4f pf=%ld\n", i, nm2, ms[i], i < pfs.size() ? pfs[i] : -1L);
                }
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
            launch_hop_dump(id); // the census is filled by the run itself: print at the replay exit
    return passes;
        }
        // DISPATCH-OVERHEAD PROBE (section 97): split the CPU enqueue cost from the GPU
        // drain cost. If the enqueue loop alone is ~290ms, the engine is CPU-bound on the
        // 691 SYCL submits (coopmat pays this once via a single Vulkan command buffer).
        if (getenv("NR_SUBMIT_PROBE")) {
            // per-closure ENQUEUE time (GPU drain excluded): where does the 455ms go?
// LAUNCH-MAP FIX (knife2b #118): the first enqueue loop is polluted by cold JIT /
// first-touch costs, which made the family totals halve between runs and destroyed the
// comparison (four arms all moved, including families the switch cannot touch). Warm the
// loop once WITHOUT timing, then measure. Diagnostic path only -- the shipping replay
// (cgraph) is untouched.
            for (auto& fn : g_graphs[id]) fn();   // warm-up pass: deliberately not counted
            GQ->wait();
            std::vector<double> en; en.reserve(g_graphs[id].size());
            int lce = 0;
            for (auto& fn : g_graphs[id]) {
                lc_begin(-1);   // submit probe: not counted
                auto t0 = std::chrono::steady_clock::now();
                fn();
                lc_end();
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
            launch_hop_dump(id); // the census is filled by the run itself: print at the replay exit
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
        static int pgk0 = getenv("NR_PGRAPH") ? atoi(getenv("NR_PGRAPH")) : 0;   // PGRAPH: wave mode bypasses cgraph
        bool usecgraph = pgk0 >= 2 ? false : (getenv("NR_CGRAPH") ? atoi(getenv("NR_CGRAPH")) != 0 : true);   // section 98: DEFAULT ON -- the DEVICE_LOST was the head-branch host-vector memcpy nodes (dangling at replay), fixed by device packs; full 691-closure graph replays 100.0000% bit-exact. NR_CGRAPH=0 = escape hatch.
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
                        pool_seq_begin(g_graphs[id].size());   // NR_POOLSEQ only; otherwise a no-op
                        for (int fi = 0; fi < lim && fi < (int)g_graphs[id].size(); ++fi) {
                            if (g_poolseq_on) g_pool_cur_closure = fi;
                            if (!g_graphs[id][fi]) FAILMSG("closure %zu EMPTY in graph %d (record pass)", fi, id);   // C37 probe
            lc_begin(fi); g_graphs[id][fi](); lc_end();   // record: no GPU execution
                        }
                        pool_seq_end(id);
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
                launch_hop_dump(id); // the census is filled by the run itself: print at the replay exit
    return passes;
            }
        }
        // PGRAPH wave executor (NR_PGRAPH=2/4): after the warm run, replay the
        // closures WAVE-PARALLEL on K in_order streams. Streams share one context;
        // the scratch pool is split per slot so blocks never cross streams; the
        // touch set (buffer pointers from the record-time id registrations) drives
        // the wave plan. Any op whose plan index mapping is off -> plain fallback.
        static int pgk = getenv("NR_PGRAPH") ? atoi(getenv("NR_PGRAPH")) : 0;
        static std::map<int, std::vector<std::vector<int>>> s_pgwaves;
        if (pgk >= 2 && s_warmed.count(id) && id < (int)g_graph_touch.size() &&
            g_graph_touch[id].size() == g_graphs[id].size()) {
            if (getenv("NR_PG_DBG")) { for (int t = 0; t < 8 && t < (int)g_graph_touch[id].size(); ++t) { auto& v = g_graph_touch[id][t]; std::printf("[pgdbg] op%d %-34s touch=%zu sent=%d\n", t, g_graph_names[id].size()>(size_t)t?g_graph_names[id][t]:"?", v.size(), (v.size()==1&&v[0]==(void*)-1)); } std::fflush(stdout); }
            auto pw = s_pgwaves.find(id);
            if (pw == s_pgwaves.end())
                pw = s_pgwaves.emplace(id, pgraph_plan(g_graph_touch[id])).first;
            static sycl::queue* pgq[4] = { nullptr, nullptr, nullptr, nullptr };
            if (!pgq[0])
                for (int t = 0; t < 4; ++t)
                    pgq[t] = new sycl::queue(*GD, sycl::property::queue::in_order{});
            // DEVICE-side wave edges: each wave's ops wait() the PREVIOUS wave's
            // events on their own stream (enqueue dependency, no host round-trip --
            // the host-wait version cost 691 syncs = the 156ms disaster).
            sycl::queue* mainq = g_curq;
            std::vector<sycl::event> prev;
            for (auto& wv : pw->second) {
                std::vector<sycl::event> cur;
                int t = 0;
                for (int i : wv) {
                    g_pg_slot = t % pgk;
                    sycl::queue* qq = pgq[g_pg_slot & 3]; g_curq = qq;
                    if (!prev.empty()) qq->submit([&](sycl::handler& hh){ hh.depends_on(prev); hh.single_task([]{}); });   // device-side edge
                    g_graphs[id][i]();
                    cur.push_back(qq->single_task([]{}));      // marker event (in_order: after all prior work here)
                    ++t;
                }
                prev = std::move(cur);
            }
            g_curq = mainq; g_pg_slot = 0;
            for (int u = 0; u < 4; ++u) pgq[u]->wait();   // ONE host sync per frame
            if (getenv("NR_PG_STATS")) {
                size_t mx = 0, sum = 0;
                for (auto& wv : pw->second) { mx = wv.size() > mx ? wv.size() : mx; sum += wv.size(); }
                size_t sent = 0, tot = 0; for (auto& t : g_graph_touch[id]) { if (t.size()==1 && t[0]==(void*)-1) sent++; tot += t.size(); }
                std::printf("[pgraph] id=%d closures=%zu waves=%zu maxwidth=%zu avg=%.2f sentinel=%zu avgtouch=%.2f\n",
                            id, (size_t)g_graphs[id].size(), pw->second.size(), mx,
                            sent, (double)tot / (g_graphs[id].empty()?1:g_graphs[id].size()),
                            (double)sum / (pw->second.empty() ? 1 : pw->second.size()));
                std::fflush(stdout);
            }
            s_warmed.insert(id);
            if (getenv("NR_SUBMIT_PROBE")) { std::printf("[wb-route] TOTAL this run: v2-hits=%ld split-path-hits=%ld\n", g_wb_v2.load(), g_wb_split.load()); std::fflush(stdout); }
            launch_hop_dump(id); // the census is filled by the run itself: print at the replay exit
    return passes;
        }
        pool_seq_begin(g_graphs[id].size());   // NR_POOLSEQ only; the WARM run sequence too
        for (size_t fi = 0; fi < g_graphs[id].size(); ++fi) {
            if (g_poolseq_on) g_pool_cur_closure = (int)fi;
            if (!g_graphs[id][fi]) FAILMSG("closure %zu EMPTY in graph %d (warm pass)", fi, id);   // C37 probe
            lc_begin(-1); g_graphs[id][fi](); lc_end();     // warm in-order pass: not counted
        }
        GQ->wait();                             // one host sync for the whole graph (was ~2000)
        pool_seq_end(id);
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
    launch_hop_dump(id); // the census is filled by the run itself: print at the replay exit
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
    // #141: pre/post resolve their operands at RECORD time (no pgraph_ids call), so before this
    // fix their [hop] id string was the previous recording's leftovers. pg_note_ids feeds the
    // PRINT-ONLY mirror; g_cmds_touch keeps the full-conflict sentinel, so the wave scheduler,
    // the graph and the numbers are untouched.
    pg_note_ids({ colour, motion, history, features, plan, table });
    prepass::PreArgs A{ Col, Mot, His, Feat, Pl, Tb, pixels, height, width,
                        pitch, source_h, source_w, flags };
    g_cmd_names.push_back(__func__);
    pg_push([=]() {
                // #141 layer 1: explicit work-group size (0 = the shipped basic parallel_for). The guard
        // inside pre_at (pixel >= A.m) is what makes the rounded-up global range safe; the body,
        // its order and every value are untouched -- only the partition is fixed by construction.
        static int pre_nt = getenv("NR_PRE_NT") ? atoi(getenv("NR_PRE_NT")) : 0;
        // #142 (2026-11-06): engine-paired A/B in the SAME batch says an explicit NT=32 nd_range is
        // +9.6% WORSE for pre (pass0 4.7/4.7/4.7 ms -> 5.1/5.2/5.1 ms, 3/3 pairs, byte-identical).
        // The probe's region-bracket arm measured -5% for the same change: OPPOSITE SIGN. Rule now:
        // promotion is decided by in-engine same-batch pairing; the probe localizes only.
        // Default 0 = the shipped basic parallel_for. NR_PRE_NT=<n> still forces an nd_range.
        if (pre_nt > 0) {
            const size_t gr = ((size_t)pixels + (size_t)pre_nt - 1) / (size_t)pre_nt * (size_t)pre_nt;
            GQ->parallel_for(sycl::nd_range(sycl::range(gr), sycl::range((size_t)pre_nt)),
                             [A](sycl::nd_item<1> it) {
                unsigned p = (unsigned)it.get_global_id(0);
                if (p >= A.m) return;
                prepass::pre_at(A, p);
            });
        } else
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
    pg_note_ids({ colour, head, history, result, table, neural });   // #141: same print mirror
    postpass::PostArgs A{ Col, Hd, His, Res, Tb, Neu, pixels, height, width,
                          pitch, source_h, source_w };
    g_cmd_names.push_back(__func__);
    pg_push([=]() {
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
namespace gemm_qkv_windowloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_gemm_qkv_window (no pragma, no division)
int xmx_rec_gemm_qkv_window(int image, int weight, int q, int k, int v, int scale,
                            unsigned M, unsigned channels, unsigned heads, unsigned tokens,
                            unsigned width, unsigned height, unsigned across, unsigned pad,
                            unsigned image_mode) {
    using gemm_qkv_windowloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using gemm_qkv_windowloc::cr_add;
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
    pg_push([=]() {
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
         const int* vit_g_3878 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
         GQ->parallel_for(sycl::range((size_t)M * heads), [=](sycl::item<1> it) {
                 if (vit_g_3878 && vit_g_3878[-1] && *vit_g_3878) { ((int*)vit_g_3878)[4199] = 2; return; }   // C32: reuse => touch nothing
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
namespace gemm_residualloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_gemm_residual (no pragma, no division)
int xmx_rec_gemm_residual(int a, int b, int c, int skip, int cosine,
                          unsigned M, unsigned N, unsigned K, unsigned flags) {
    using gemm_residualloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using gemm_residualloc::cr_add;
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
    pg_push([=]() {
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
    pg_push([=]() {
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
// P8-k (section 100, KEPT per the user's ruling 15:36): the ffn residual tail
//  total = fma(skip[i], cp[i%32], dC2[i]); publish(epi); write  -- was a
// per-element SCALAR parallel_for over M*32. The ESIMD row-parallel form: one
// work-item owns a full 32-channel row = 128B block_load x2 + cp + block_store.
// MEASURED: NEUTRAL at the frame level (A/B 4/8, mean -0.09 noise band; the
// NR_STEM_STOP=2 tail cost is 8.87 vec vs 8.81 scalar = WIDTH-INSENSITIVE) --
// the tail is bound by the 67MBx3 global round-trip (DRAM latency), not by
// access width. KEPT ANYWAY: strictly better instruction economics, bit-identical
// (qr_publish(0,.) is the identity, narrow=false, and sk*cv+c2 auto-contracts to
// ONE fused-rounding FMA in an ESIMD kernel = sycl::fma's single rounding
// lane-for-lane -- the gemm_b_res golden semantics), zero downside; the mask
// (the 67MB intermediates) is exactly what the B1 megakernel removes, after
// which the wide form pays. NR_FFN_TAILV=0 = escape hatch; epi!=0/narrow stay
// on the scalar chain (the plain-ffn f32-skip gate lesson is untouched).
// P8-o: the chip LW=16 variant (32KB SLM = 2 WG/SM) behind NR_CHIP_LW16=1.
// Isolated it is slightly SLOWER (1.36 vs 1.21 at M=522240, diff 0); the frame
// A/B tests the occupancy hypothesis (the P8-n verdict said the chip's frame
// cost is its latency chain at 1 WG/SM -- more resident WGs might hide it).
#define CHIP_LW_DISPATCH(call32, call16) do { \
    static bool lw16 = getenv("NR_CHIP_LW16") ? (atoi(getenv("NR_CHIP_LW16")) != 0) : true; \
    if (lw16) call16 ; else call32 ; \
} while(0)
static inline void ffn_tail_res(sycl::queue& q, const float* dSkip, const float* dC2,
                                const float* cp, void* Cout, unsigned M,
                                bool narrow, unsigned epi) {
    static bool tv = !getenv("NR_FFN_TAILV") || atoi(getenv("NR_FFN_TAILV")) != 0;
    if (tv && epi == 0u && !narrow) {
        float* Cf = (float*)Cout;
        q.parallel_for(sycl::range(M), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            namespace esimd = sycl::ext::intel::esimd;
            unsigned row = (unsigned)it.get_id(0);
            size_t base = (size_t)row * 32u;
            esimd::simd<float,32> sk = esimd::block_load<float,32>(dSkip + base, esimd::overaligned_tag<16>{});
            esimd::simd<float,32> c2 = esimd::block_load<float,32>(dC2 + base, esimd::overaligned_tag<16>{});
            esimd::simd<float,32> cv = esimd::block_load<float,32>(cp, esimd::overaligned_tag<16>{});
            esimd::simd<float,32> total = sk * cv + c2;
            esimd::block_store<float,32>(Cf + base, total, esimd::overaligned_tag<16>{});
        });
        return;
    }
    q.parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
        size_t i = it.get_id(0);
        unsigned col = (unsigned)(i % 32u);
        float total = sycl::fma(dSkip[i], cp[col], dC2[i]);
        if (narrow) ((sycl::half*)Cout)[i] = sycl::half(qr_publish(epi, total));
        else        ((float*)Cout)[i] = qr_publish(epi, total);
    });
}
namespace ffnloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_ffn (no pragma, no division)
int xmx_rec_ffn(int a, int expand, int projection, int out, int skip, int cosine,
                unsigned M, unsigned cin, unsigned hidden, unsigned groups, unsigned flags) {
    using ffnloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using ffnloc::cr_add;
    if (!g_recording) FAILMSG("not recording");
    static int fst = getenv("NR_F_STOP") ? atoi(getenv("NR_F_STOP")) : 0;
    if (fst == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }   // P8-k ledger: ffn split pricing (time-only)
    pgraph_ids({a,expand,projection,out,skip,cosine});   // PGRAPH touch-set (conservative: every operand id)
    static int fstop = getenv("NR_F_STOP") ? atoi(getenv("NR_F_STOP")) : 0;
    if (fstop == 9) { g_cmd_names.push_back(__func__); pg_push([](){}); return 0; }   // P7 floor ledger (time-only)
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
    pg_push([=]() {
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
            // B5-3 (2026-10-29, the user's "eliminate every dC round-trip"): the
            // residual + publish tail FOLDS into the chip store (P8-l mechanism, now
            // with the section-75 straight-line FMA shape fix -- the 131/8192 gate red
            // was the phi-reassignment muladd lowering, see ffn_chip_kernel.hpp).
            // dC2 NEVER EXISTS on this path; epi==0 && !narrow is the guard here so
            // qr_publish is the identity and the fold matches the tail by construction.
            static bool chipres_m = !getenv("NR_FFN_CHIPRES") || atoi(getenv("NR_FFN_CHIPRES")) != 0;
            if (chipres_m) {
                static bool fjoin = !getenv("NR_FFN_JOIN") || atoi(getenv("NR_FFN_JOIN")) != 0;
                static bool ff3 = !getenv("NR_FF3") || atoi(getenv("NR_FF3")) != 0;
                static bool chipcs = !getenv("NR_CHIP_CS") || atoi(getenv("NR_CHIP_CS")) != 0;   // ffn-20 CS2 colsplit pair-WG (bench 9/9 EXACT, -10%)
                static bool ff9 = !getenv("NR_FF9") || atoi(getenv("NR_FF9")) != 0;
                if (chipcs) {
                    static bool lw16c = getenv("NR_CHIP_LW16") ? (atoi(getenv("NR_CHIP_LW16")) != 0) : true;
                    if (lw16c) ffnc::launch_ffn_chip_cs2<16,false>(*GQ, Araw, dEp, dPp, (float*)Cout, (int)M, Mp, skp, cp, half_skip, ff3, ff9);
                    else       ffnc::launch_ffn_chip_cs2<32,false>(*GQ, Araw, dEp, dPp, (float*)Cout, (int)M, Mp, skp, cp, half_skip, ff3, ff9);
                } else
                 CHIP_LW_DISPATCH(ffnc::launch_ffn_chip<32>(*GQ, Araw, dEp, dPp, (float*)Cout, (int)M, Mp, skp, cp, half_skip, fjoin, ff3, ff9),
                                 ffnc::launch_ffn_chip<16>(*GQ, Araw, dEp, dPp, (float*)Cout, (int)M, Mp, skp, cp, half_skip, fjoin, ff3, ff9));
                return;
            }
            float* dC2 = (float*)pool_get((size_t)Mp * cin * 4);
             CHIP_LW_DISPATCH(ffnc::launch_ffn_chip<32>(*GQ, Araw, dEp, dPp, dC2, (int)M, Mp), ffnc::launch_ffn_chip<16>(*GQ, Araw, dEp, dPp, dC2, (int)M, Mp));
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
namespace ffn_mergeloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_ffn_merge (no pragma, no division)
int xmx_rec_ffn_merge(int source, int skip, int sincos, int expand, int projection,
                      int out, int cosine, unsigned height, unsigned width,
                      unsigned source_width, unsigned flags) {
    using ffn_mergeloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using ffn_mergeloc::cr_add;
    if (!g_recording) FAILMSG("not recording");
    static int fst = getenv("NR_FM_STOP") ? atoi(getenv("NR_FM_STOP")) : 0;
    if (fst == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }   // P8-k ledger: ffn split pricing (time-only)
    pgraph_ids({source,skip,sincos,expand,projection,out,cosine});   // PGRAPH touch-set (conservative: every operand id)
    static int fstop = getenv("NR_F_STOP") ? atoi(getenv("NR_F_STOP")) : 0;
    if (fstop == 9) { g_cmd_names.push_back(__func__); pg_push([](){}); return 0; }   // P7 floor ledger (time-only)
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
        pg_push([](){});
        return 0;
    }
    pg_push([=]() {
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
        static int mstop1 = getenv("NR_MERGE_STOP") ? atoi(getenv("NR_MERGE_STOP")) : 0;
        if (mstop1 == 1) { pool_put(dMerged); pool_put(dM16); return; }   // P8-n ledger: pass A only
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
        // P8-l: the residual-fused chip store -- dC2 (Mp*32 f32 = 67MB at M=522240)
        // NEVER touches global; the separate ffn_tail_res pass vanishes. Guards:
        // epi==0 && !narrow (already merge_chip), f32 skip (dMerged) -- the P3c
        // half-skip/epi!=0 lesson zone stays on the split chain. NR_FFN_CHIPRES=0 =
        // escape hatch to the (already-vectorized, P8-k) tail form.
        static bool chipres = !getenv("NR_FFN_CHIPRES") || atoi(getenv("NR_FFN_CHIPRES")) != 0;
        if (merge_chip && chipres) {
            sycl::half* dPp2 = cached_pack_b_f16(projection, Praw, 128, 32);
            static bool fjoinm = !getenv("NR_FFN_JOIN") || atoi(getenv("NR_FFN_JOIN")) != 0;
            static bool ff3m = !getenv("NR_FF3") || atoi(getenv("NR_FF3")) != 0;
            static bool ff9m = !getenv("NR_FF9") || atoi(getenv("NR_FF9")) != 0;
            static bool chipcsm = !getenv("NR_CHIP_CS") || atoi(getenv("NR_CHIP_CS")) != 0;
            if (chipcsm) {
                static bool lw16m = getenv("NR_CHIP_LW16") ? (atoi(getenv("NR_CHIP_LW16")) != 0) : true;
                if (lw16m) ffnc::launch_ffn_chip_cs2<16,false>(*GQ, dM16, dB2, dPp2, (float*)Cout, (int)M, Mp, dMerged, cp, false, ff3m, ff9m);
                else       ffnc::launch_ffn_chip_cs2<32,false>(*GQ, dM16, dB2, dPp2, (float*)Cout, (int)M, Mp, dMerged, cp, false, ff3m, ff9m);
            } else
             CHIP_LW_DISPATCH(ffnc::launch_ffn_chip<32>(*GQ, dM16, dB2, dPp2, (float*)Cout, (int)M, Mp, dMerged, cp, false, fjoinm, ff3m, ff9m), ffnc::launch_ffn_chip<16>(*GQ, dM16, dB2, dPp2, (float*)Cout, (int)M, Mp, dMerged, cp, false, fjoinm, ff3m, ff9m));
            pool_put(dM16);   // dA2 was never packed on this path; dB2/dPp2 cache-owned
            pool_put(dMerged);
            return;
        }
        if (merge_chip) {
            sycl::half* dPp2 = cached_pack_b_f16(projection, Praw, 128, 32);
            float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
             ffnc::launch_ffn_chip<32>(*GQ, dM16, dB2, dPp2, dC2, (int)M, Mp);
            pool_put(dM16);   // dA2 was never packed on this path; dB2/dPp2 cache-owned
            ffn_tail_res(*GQ, dMerged, dC2, cp, Cout, M, narrow, epi);
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
            ffn_tail_res(*GQ, dMerged, dC2, cp, Cout, M, narrow, epi);
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
        ffn_tail_res(*GQ, dMerged, dC2, cp, Cout, M, narrow, epi);
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
    static int fst = getenv("NR_FS_STOP") ? atoi(getenv("NR_FS_STOP")) : 0;
    if (fst == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }   // P8-k ledger: ffn split pricing (time-only)
    pgraph_ids({features,adapter,expand,projection,out,cosine});   // PGRAPH touch-set (conservative: every operand id)
    static int fstop = getenv("NR_F_STOP") ? atoi(getenv("NR_F_STOP")) : 0;
    if (fstop == 9) { g_cmd_names.push_back(__func__); pg_push([](){}); return 0; }   // P7 floor ledger (time-only)
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
    pg_push([=]() {
        // fully device-resident (section 92): all three legs pack on device and the
        // hidden16/hidden intermediates stay on device between them -- the old path
        // downloaded Fraw/Arw/Eraw/Praw AND both intermediates to host and re-uploaded
        // packed operands (the 324ms). dS stays the raw f32 stem (pass C's residual).
        sycl::half* dA = (sycl::half*)pool_get((size_t)Mp * 16 * 2);
         packdev::pack_a16(*GQ, Fraw, dA, (int)M, Mp, 16);
        sycl::half* dB = cached_pack_b_f16(adapter, Arw, 16, 32);   // weight
        // P8-n / B1 brick 1: the STEM MEGAKERNEL -- one launch, the adapter gemm
        // in-pass, the 16x32 f32 tile + its e4m3 A-map + the hidden stage all in
        // per-thread SLM (4KB x LW16 = 64KB): dS and dH16 NEVER EXIST in global.
        // bench_stem_mega: diff 0 / 16.7M EXACT vs the shipped dual+chip-res chain.
        // Guards: the stem_chip shape conditions (chip path ON, epi 0, !narrow);
        // dS/dH16 are not even allocated on this path. NR_FFN_MEGA=0 = escape.
        {
            // P8-n VERDICT (the 17:2x frame A/B): the mega is bit-exact (43 green +
            // end-to-end 100%%x2 + bench diff 0/16.7M) but the FRAME is its judge:
            // A/B 6/10 mean -0.22, and the stem's in-frame marginal did NOT drop
            // (chain 9.5 vs mega 9.8 per 2 calls) -- the 3.4ms "round-trip penalty"
            // theory is FALSIFIED: the chain's in-frame cost is NOT the dS/dH16
            // re-read (the mega removes those buffers entirely and pays the same).
            // => the stem's frame cost is the kernel's own latency chain at 64KB
            // SLM (1 WG/SM occupancy) plus the mandatory 67MB f32 Cout write.
            // DEFAULT OFF (a NEGATIVE mean is not "neutral-without-negative" -- the
            // user's ruling keeps no-downside changes; this one has a measured
            // -0.22 downside). The kernel STAYS as B1 brick-1: the SLM tile map,
            // the constant-offset A-map stores and the bit-exact chain are proven
            // assets for the window_block megakernel (where the win is the scr
            // round-trip, a DIFFERENT mechanism). NR_FFN_MEGA=1 = opt-in witness.
            static bool mega = getenv("NR_FFN_MEGA") && atoi(getenv("NR_FFN_MEGA")) != 0;
            static bool ffntile3m = !getenv("NR_FFN_TILE") || atoi(getenv("NR_FFN_TILE")) != 0;
            static bool ffchip3m = !getenv("NR_FFN_CHIP") || atoi(getenv("NR_FFN_CHIP")) != 0;
            if (mega && ffntile3m && ffchip3m && !narrow && epi == 0u) {
                sycl::half* dEp3 = cached_pack_b_f16(expand, Eraw, 32, 128);        // weight (cached = idempotent)
                sycl::half* dPp3 = cached_pack_b_f16(projection, Praw, 128, 32);    // weight
                { static int mwlw = getenv("SM_LW") ? atoi(getenv("SM_LW")) : 16;
                  if (mwlw == 4)      ffnc::stem_mega<4>(*GQ, dA, dB, dEp3, dPp3, cp, (float*)Cout, (int)M, Mp);
                  else if (mwlw == 8) ffnc::stem_mega<8>(*GQ, dA, dB, dEp3, dPp3, cp, (float*)Cout, (int)M, Mp);
                  else                ffnc::stem_mega<16>(*GQ, dA, dB, dEp3, dPp3, cp, (float*)Cout, (int)M, Mp); }
                pool_put(dA);   // dB/dEp3/dPp3 cache-owned weights
                return;
            }
        }
        float* dS = (float*)pool_get((size_t)Mp * 32 * 4);
        sycl::half* dH16 = (sycl::half*)pool_get((size_t)M * 32 * 2);
        // P8-m (section 100): DUAL STORE -- the adapter gemm writes the raw f32 dS
        // AND dH16 = half(e4m3(dS)) in one pass; the separate publish parallel_for
        // (67MB f32 re-read + 33MB write at M=522240) vanishes. Bit-identical by
        // the chain: pub_vec_v8(1u) == pub_esimd(1u) (bench_pubvec, section 99)
        // == qr_e4m3 (the PUBLISH gate). dH16 is bounded by M (the guard matches
        // the publish loop's range; the chip's A load only reads rows < M).
        // NR_FFN_DUAL=0 = escape hatch to gemm + the publish loop.
        static bool dual = !getenv("NR_FFN_DUAL") || atoi(getenv("NR_FFN_DUAL")) != 0;
        if (dual) {
             f16v1::gemm_dual_pub(*GQ, dA, dB, dS, dH16, (int)M, Mp, 32, 16);
            pool_put(dA);   // dB is cache-owned (weight)
            static int sstop1 = getenv("NR_STEM_STOP") ? atoi(getenv("NR_STEM_STOP")) : 0;
            if (sstop1 == 1) { pool_put(dH16); pool_put(dS); return; }   // P8-n ledger: pass A only
        } else {
         f16v1::gemm(*GQ, dA, dB, dS, Mp, 32, 16);
        pool_put(dA);   // dB is cache-owned (weight)
        // publish = E4M3 only, on device; dH16 stays for pass B's pack_a.
         GQ->parallel_for(sycl::range((size_t)M * 32), [=](sycl::item<1> it) {
            size_t i = it.get_id(0);
            dH16[i] = sycl::half(qr_e4m3(dS[i]));
        });
        }
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
            static bool chipres3 = !getenv("NR_FFN_CHIPRES") || atoi(getenv("NR_FFN_CHIPRES")) != 0;   // P8-l (see the merge site)
            if (chipres3) {
                static bool chipcss = !getenv("NR_CHIP_CS") || atoi(getenv("NR_CHIP_CS")) != 0;
                if (chipcss) {
                    static bool lw16s = getenv("NR_CHIP_LW16") ? (atoi(getenv("NR_CHIP_LW16")) != 0) : true;
                    if (lw16s)ffnc::launch_ffn_chip_cs2<16,false>(*GQ, dH16, dB2, dPp3, (float*)Cout, (int)M, Mp, dS, cp);
                    else       {  ffnc::launch_ffn_chip_cs2<32,false>(*GQ, dH16, dB2, dPp3, (float*)Cout, (int)M, Mp, dS, cp); }
                } else
                 CHIP_LW_DISPATCH(ffnc::launch_ffn_chip<32>(*GQ, dH16, dB2, dPp3, (float*)Cout, (int)M, Mp, dS, cp), ffnc::launch_ffn_chip<16>(*GQ, dH16, dB2, dPp3, (float*)Cout, (int)M, Mp, dS, cp));
                pool_put(dH16); pool_put(dA2); pool_put(dS);   // dC2 never allocated
                return;
            }
            float* dC2 = (float*)pool_get((size_t)Mp * 32 * 4);
             ffnc::launch_ffn_chip<32>(*GQ, dH16, dB2, dPp3, dC2, (int)M, Mp);
            static int sstop = getenv("NR_STEM_STOP") ? atoi(getenv("NR_STEM_STOP")) : 0;
            if (sstop == 2) { pool_put(dH16); pool_put(dA2); pool_put(dC2); pool_put(dS); return; }  // skip the residual tail
            pool_put(dH16); pool_put(dA2);   // dB2/dPp3 cache-owned
            ffn_tail_res(*GQ, dS, dC2, cp, Cout, M, narrow, epi);
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
            ffn_tail_res(*GQ, dS, dC2, cp, Cout, M, narrow, epi);
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
        ffn_tail_res(*GQ, dS, dC2, cp, Cout, M, narrow, epi);
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
    if (vit_reuse_level())            // C26: note the GEMM (the ViT entry probe looks here)
        vit_note_gemm(g_cmds.size(), a, c, M, N, K);
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
    int Mp = (int)(((M + 15u) / 16u) * 16u);   // P12a: re-padded to a 64-multiple on the v2 path below
    g_cmd_names.push_back(__func__);
    pgraph_ids({a,b,c});   // PGRAPH touch-set (conservative: every operand id)
        flop_note("f16_gemm",M,N,K,batch?batch:1);
    pg_push([=]() {
        const size_t nb = (batch ? batch : 1u);
        // R8a shape-merge (section 92): batch is the grid's z dimension in ONE dispatch
        // (the shipped engine: vkCmdDispatch(..., batch); gl_WorkGroupID.z). The old
        // recorder's host loop turned one big op into `batch` small under-filled gemms.
        // pack-A once (all groups), pack-B once (whole weight, cached), gemm_b once,
        // publish once. Bounds identical to the gate's aw_b/bw_b (section-73 lesson).
        // P12a (section 100): the f16 gemm family still ran f16v1::gemm_b (one 16x16
        // tile per GLOBAL load, 8 FLOP/byte = memory-bound) while the SLM-tiled v2
        // (4x reuse) was PROMOTED for window_attention in section 99. Same lever,
        // one variable: v2 needs Mp a multiple of BM=64 -> re-pad Mp here (garbage
        // pad rows are written but never published: the publish loop bounds r<M).
        // N%64==0 -> BN=64, else N%32==0 -> BN=32 (the frame's N are 32/64/128/256/
        // 512/1024). LW = NT = (BM/TS)*(BN/TS) = 8 or 16 (the safe lines). Gate
        // NR_G_V2 (default ON once the three gates pass; =0 = the v1 escape).
        static bool gv2 = getenv("NR_G_V2") && atoi(getenv("NR_G_V2")) != 0;   // P12a NEUTRAL (3-pair A/B noise band): the family's N are mostly 32/64; v2's tile reuse pays on the window shapes, not these. OFF by measurement.
        const bool v2_ok = gv2 && (M > 0u) && ((N % 32u) == 0u) && ((K % 16u) == 0u);
        int Mp2 = v2_ok ? (int)(((M + 63u) / 64u) * 64u) : Mp;
        sycl::half* dAp = (sycl::half*)pool_get(nb * (size_t)Mp2 * K * 2);
        float* dC = nullptr;   // B5-2: allocated ONLY on the split escape path now
        static int gst2 = getenv("NR_G_STOP") ? atoi(getenv("NR_G_STOP")) : 0;
        if (gst2 != 2)   // stop1/stop3 run the pack; stop2 = floor only
         packdev::gather_pack_a16_b(*GQ, Araw, dAp, (int)M, Mp2, (int)K, (int)lda_e, sa, oa, (int)nb);
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
        static int gst = getenv("NR_G_STOP") ? atoi(getenv("NR_G_STOP")) : 0;   // ladder: 1 = pack only, 2 = floor, 3 = pack+gemm (publish skipped)
        // P12b (section 100): the gemm family's publish pass (9.4ms on the ladder --
        // the dC f32 write+read + one launch) folds into the gemm store (gemm_b_pub_f16:
        // the publish loop's map VERBATIM, vector pub proven, epi2 on the scalar form).
        // Guards: ldc==N (the frame's every call; the compact N=16/ldc=4 form stays on
        // the split path), gst==0. Escape NR_G_FOLD=0.
        // B5-2 (2026-10-29, the user's "eliminate the dC round-trip, no exceptions"):
        // the fold is now the DEFAULT -- the P12b "NEUTRAL" verdict was measured against
        // the OLD frame (and the frame ledger now says this family is the biggest
        // remaining round-trip payer at 84 calls); the round-trip itself is what the
        // order targets. dC is NOT ALLOCATED on the fold path at all (zero new cost:
        // the fold REMOVES the dC write + read + the publish launch). compact (2 calls,
        // N=16/ldc=4 head form) stays split -- its dC is 8KB, allocated lazily below.
        static bool gfold = !getenv("NR_G_FOLD") || atoi(getenv("NR_G_FOLD")) != 0;
        // BLADE-5 (2026-10-29 census): the old guard `ldc_e == N` excluded the 96
        // batched-shape calls (ldc=1024/2088960 != N=32/...) -- but gemm_b_pub_f16
        // ALREADY indexes its store with ldc (base = ob + row*ldc + tc*TS, the
        // publish pass's map VERBATIM). G_STOP=3 priced the stranded publish tail
        // at 14ms/frame. Guard relaxed to !compact (the compact head keeps its own
        // column-cull semantics); the kernel is the same code path.
        if (gfold && gst == 0 && !compact) {
             f16v1::gemm_b_pub_f16(*GQ, dAp, dBp, Cout, (int)M, Mp2, (int)N, (int)K, (int)nb,
                                  epi, narrow, oc, sc, ldc_e, lda_e);
            pool_put(dAp);   // dC never existed on this path
            return;
        }
        if (!dC) dC = (float*)pool_get(nb * (size_t)Mp2 * N * 4);   // split/compact path only
        if (gst != 1 && gst != 2) {
        if (v2_ok && (N % 64u) == 0u)      f16v2::gemm_b2<64>(*GQ, dAp, dBp, dC, Mp2, (int)N, (int)K, (int)nb);
        else if (v2_ok)                    f16v2::gemm_b2<32>(*GQ, dAp, dBp, dC, Mp2, (int)N, (int)K, (int)nb);
        else                               f16v1::gemm_b(*GQ, dAp, dBp, dC, Mp2, (int)N, (int)K, (int)nb);
        static int gst3 = getenv("NR_G_STOP") ? atoi(getenv("NR_G_STOP")) : 0;   // 3 = skip the publish pass (gemm only): the fold-value probe
        const int* vit_g_4773 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
        if (gst3 < 3)GQ->parallel_for(sycl::range(nb * (size_t)M * N),
                         [=](sycl::item<1> it) {
                if (vit_g_4773 && vit_g_4773[-1] && *vit_g_4773) { ((int*)vit_g_4773)[4199] = 2; return; }   // C32: reuse => touch nothing
            size_t i = it.get_id(0);
            size_t mn = (size_t)M * N;
            unsigned g = (unsigned)(i / mn); size_t rem = i % mn;
            unsigned r = (unsigned)(rem / N), col = (unsigned)(rem % N);
            if (compact && col >= 4u) return;   // the compact head keeps four columns
            float value = qr_publish(epi, dC[g * (size_t)Mp2 * N + (size_t)r * N + col]);
            size_t out = oc + g * sc + (size_t)r * ldc_e + col;
            if (narrow) ((sycl::half*)Cout)[out] = sycl::half(value);
            else        ((float*)Cout)[out] = value;
        });
        }
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
    static int istop = getenv("NR_I8_STOP") ? atoi(getenv("NR_I8_STOP")) : 0;
    if (istop == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }   // leg map 10:0x: time-only pricing probe (the family never had one)
    pgraph_ids({a,b,c,a_scale,b_scale});   // PGRAPH touch-set (conservative: every operand id)
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
    pg_push([=]() {
        // device pack (section 92 phase-2): the operands stay on device -- the host
        // round-trip (download -> CPU pack -> upload) was the whole 89s/frame, and the
        // gather is bit-exact vs the host pack (PACK_DEVICE gate).
        int8_t* dAp = (int8_t*)pool_get(na);
        // C82b: narrow the gate to the EXACT shape the bench form was validated on (N=512, K=512,
        // M a multiple of 128). The broader N%128/K%64 gate also caught other tiers' legs
        // whose operands were never validated in this tile family -- that is what turned the
        // four gates red with the switch ON (1301 fused 4D6D3667 / plain 17D0575C).
const bool band = c512_band_on() && N == 512u && K == 512u && (M % 128u) == 0u;
        if (getenv("NR_C512_BAND_DBG"))
            std::printf("[gir-band] band=%d on=%d M=%u N=%u K=%u Mp=%d epi=%u narrow=%d flags=%u\n",
                        (int)band, c512_band_on() ? 1 : 0, M, N, K, Mp, epi, (int)narrow, flags);
        // pack_b is BK-independent (kk32 blocks), so dBp is shared by both tile families.
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)N, (int)K);   // weight: pack once, reuse
        if (band) {
            // the A pack switches TOGETHER with the kernel (BK=64 order) -- the pairing rule
            // the C70/BK64 knife pinned with gir_bk64_ok().
            if (fused) packdev::pack_a_fused64(*GQ, a16, dAp, (float*)as, (int)M, Mp, (int)K);
            else       packdev::pack_a64(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        } else if (fused) packdev::pack_a_fused(*GQ, a16, dAp, (float*)as, (int)M, Mp, (int)K);
        else packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        // DERIVED (section 92): pure publish (dequant + qr_publish, no residual fma) and
        // N%64==0 is a hard requirement -- exactly gemm_b_pub's shape (batch=1, dense ldc=N,
        // scale_stride/col_stride 0). Kills the int32 dC scratch + the separate publish pass.
        if (band)
             s8v8d::gemm_var<128, 64, 64, 2, 1, true>(*GQ, dAp, dBp, nullptr, Cout, as, bs,
                     (int)M, Mp, (int)N, (int)K, 1, (size_t)Mp * N, (unsigned)N, 0u, 0u, narrow, epi);
        else
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
// #148 family order-2 (2026-11-06 19:0x, parent-nominated): gemm_int8_batched -- 4 cr_mul/cr_add sites
// in this recorder's body, 64 legs/frame. Same template as qkv1: a private namespace + block-scope
// using-declarations, NO new pragma (the region opened by the smax cut already covers this file), and
// division is never touched (军规 136; this recorder has 0 cr_div sites -- tools/cr_family_plan.csv).
namespace batloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}
int xmx_rec_gemm_int8_batched(int a, int b, int c, int a_scale, int b_scale,
                              unsigned M, unsigned N, unsigned K, unsigned batch,
                              unsigned sa, unsigned sb, unsigned sc,
                              unsigned lda, unsigned ldb, unsigned ldc,
                              unsigned scale_stride, unsigned flags) {
    using batloc::cr_mul;
    using batloc::cr_add;
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
    // S6-1a (NR_S6_FFN): the FFN expand / projection legs of a chain. No-op unless the
    // env switch is on AND the tuple matches a chain already armed by an adjacent QUANT.
    // The closure pushed below is the one the state machine may later replace with a
    // no-op -- the plan's op stream and the passes count stay intact.
    s6_take_expand(g_cmds.size(), a, b, c, a_scale, b_scale, M, N, K, batch,
                   sa, sb, sc, lda, ldb, ldc, scale_stride, flags);
    s6_take_proj(g_cmds.size(), a, b, c, a_scale, b_scale, M, N, K, batch,
                 sa, sb, sc, lda, ldb, ldc, scale_stride, flags);
    g_cmd_names.push_back(__func__);
    pgraph_ids({a,b,c,a_scale,b_scale});   // PGRAPH touch-set (conservative: every operand id)
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
    if (getenv("NR_Q_STATS")) { auto it0 = g_bufs.find(a);
        printf("[gemmB-REC] a=%d AP=%p a_scale=%d M=%u K=%u lda=%u sa=%u ss=%u\n", a, it0==g_bufs.end()?(void*)0:it0->second.p, a_scale, M, K, lda_, sa, scale_stride); }
    const bool fused_b = !v9b_will && qfuse_take_b(a, a_scale, M, K, lda_, sa, scale_stride, g_cmds.size(), qfb);
    sycl::half* a16b = fused_b ? (sycl::half*)g_bufs[qfb.src].p : nullptr;
    // NR_BG_FOLD: which fused-pack FORM this consumer will use, decided at RECORD time
    // (auditable + printable), and only shapes the b1 kernel can serve with COMPILE-TIME
    // slice offsets get b1; anything else keeps the per-group form (never a silent wrong read).
    const bool b1_form = fused_b && bg_b1_ok(K, lda_, sa, batch);
    if (fused_b) { ++g_bfold_sites; if (b1_form) ++g_bfold_b1; else ++g_bfold_b; }
    pg_push([=]() {
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
        static int bstop2 = getenv("NR_B_STOP") ? atoi(getenv("NR_B_STOP")) : 0;
        // P8-b (section 100): the N=32 batched family is BLOCK-DIAGONAL WIDE-MERGE
        // legal in the plan (census: sc=N, ldc=N*batch, sa=K, lda=K*batch, sb=N*K,
        // scale_stride=0, epi1, narrow -- the group A slices are ROW-INTERLEAVED
        // (lda=Kw, sa=K): the RAW A already IS the wide row; the wide C row is
        // exactly the ldc layout; the B is block-diagonal; b_scale raw = batch*N
        // floats concatenated = the wide bs array). ONE wide gemm (M, Nw=N*batch,
        // Kw=K*batch) at BN=64 with the fused epi1 pub -- bench_n32: byte diff 0
        // vs the split chain on BOTH frame shapes, 0.511->0.138 / 0.280->0.103
        // ms/call and 2 launches -> 1. v9b's death (BM=32) does NOT apply: BM
        // stays 128, only N widens. dAp pool size batch*Mp*K == Mp*Kw exactly.
        // Guards re-verify the plan form; NR_B_WIDE=0 = escape hatch.
        static bool wmerge = !getenv("NR_B_WIDE") || atoi(getenv("NR_B_WIDE")) != 0;
        const bool wide_ok = wmerge && !fused_b && N == 32u && batch >= 2u && (N * batch) <= 128u
            && sc == N && ldc_ == (unsigned)(N * (size_t)batch) && sa == (size_t)K
            && lda_e == (unsigned)(K * (size_t)batch) && sb == (size_t)(N * K)
            && scale_stride == 0u && (epi == 0u || epi == 1u || epi == 4u) && narrow
            && (K % 32u) == 0u;
        if (wide_ok) {
            const unsigned Nw = N * batch, Kw = K * batch;
            if (bstop2 < 2) {
                if (getenv("NR_BPACK_TRACE")) printf("[bwide] M=%u Nw=%u Kw=%u\n", M, Nw, Kw);
                 packdev::gather_pack_a_b_v(*GQ, Araw, dAp, (int)M, Mp, (int)Kw, (int)Kw, 0, 1);
            }
            if (bstop2 >= 1) { pool_put(dAp); return; }
            WKey wkW{ b, (int)N, (int)K, 10000 + (int)batch };   // diag-layout cache key
            auto wcW = g_wcache.find(wkW);
            int8_t* dBpW;
            if (wcW != g_wcache.end()) dBpW = (int8_t*)wcW->second;
            else {
                dBpW = (int8_t*)sycl::malloc_device((size_t)Nw * Kw, *GQ);
                 packdev::gather_pack_b_diag_b(*GQ, Braw, dBpW, (int)N, (int)K, (int)ldb_e, sb, (int)batch);
                g_wcache[wkW] = dBpW;
            }
             s8v8::gemm_b_pub(*GQ, dAp, dBpW, Cout, as, bs, (int)M, Mp, (int)Nw, (int)Kw,
                             1, (size_t)0, Nw, 0u, 0u, narrow, epi);
            pool_put(dAp);
            return;
        }
        if (bstop2 < 2) {
        static long bfp = 0, bgp = 0;   // P8 census: fused vs scalar-gather pack_a hits
        if (fused_b) { bfp++;
            static int qfmode = getenv("NR_QF_B1") ? atoi(getenv("NR_QF_B1")) : 1;
            if (qfmode == 2) { /* TIME-ONLY attribution: skip the fused pack entirely
                (output WRONG by design) -> isolates the pack kernel's cost from
                the quant-dissolve bookkeeping */ }
            else if (qfmode == 1 && b1_form)packdev::pack_a_fused_b1(*GQ, a16b, dAp, (float*)ias->second.p, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch);
            else
                {  packdev::pack_a_fused_b(*GQ, a16b, dAp, (float*)ias->second.p, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch); }
            // NR_BG_FOLD_LIVE=1 = the liveness witness the fold needs: scale the a_scale array
            // the fused pack just wrote by 0.5. If the fold path is really what feeds the
            // frame, 1301 MUST move; if it stays EXACT the fold is a dud, not a win.
            if (qfmode != 2 && getenv("NR_BG_FOLD_LIVE")) {
                float* sc_p = (float*)ias->second.p;
                 const int* vit_g_5000 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                 GQ->parallel_for(sycl::range((size_t)M), [=](sycl::item<1> i) {
                         if (vit_g_5000 && vit_g_5000[-1] && *vit_g_5000) { ((int*)vit_g_5000)[4199] = 2; return; }   // C32: reuse => touch nothing
                    sc_p[i.get_id(0)] = sc_p[i.get_id(0)] * 0.5f; });
            } }
        else { bgp++; if (getenv("NR_BPACK_TRACE") && bgp <= 8) printf("[bpack] gather M=%u N=%u K=%u b=%u sa=%u lda=%u\n", M, N, K, batch, (unsigned)sa, lda_e);
            // P8-a: the 128-bit vector gather when the strides are 16-aligned (the
            // frame: lda=K mult32, sa in {0,128,256} -- and the operand buffers are
            // 64B device allocs). NR_BPACK_VEC=0 = escape hatch to the scalar form.
            static bool bvec = !getenv("NR_BPACK_VEC") || atoi(getenv("NR_BPACK_VEC")) != 0;
            if (bvec && (lda_e % 16u) == 0u && (sa % 16u) == 0u)packdev::gather_pack_a_b_v(*GQ, Araw, dAp, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch);
            else
                {  packdev::gather_pack_a_b(*GQ, Araw, dAp, (int)M, Mp, (int)K, (int)lda_e, sa, (int)batch); } }
        if (getenv("NR_BPACK_STATS")) { static int once=0; if(++once==144) printf("[bpack] fused_hits=%ld gather_hits=%ld\n", bfp, bgp); }
        }
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
                if (ldc_ == 256u)s8v9b::gemm_b_rq9b<256,true>(*GQ, dAp9b, dBp9b, (sycl::half*)fb.packed, (float*)fb.scale, as, bs, (int)M, Mp32, (int)K, epi);
                else
                    {  s8v9b::gemm_b_rq9b<512,true>(*GQ, dAp9b, dBp9b, (sycl::half*)fb.packed, (float*)fb.scale, as, bs, (int)M, Mp32, (int)K, epi); }
            } else if (ldc_ == 256u)s8v9b::gemm_b_rq9b<256,false>(*GQ, dAp9b, dBp9b, (sycl::half*)Cout, ns9b, as, bs, (int)M, Mp32, (int)K, epi);
            else
                {  s8v9b::gemm_b_rq9b<512,false>(*GQ, dAp9b, dBp9b, (sycl::half*)Cout, ns9b, as, bs, (int)M, Mp32, (int)K, epi); }
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
            static int bstop = getenv("NR_B_STOP") ? atoi(getenv("NR_B_STOP")) : 0;   // section 100 ledger probe (time-only): 1 = pack only, 2 = pack skipped too
            if (bstop >= 1) { pool_put(dAp); return; }
            if (pubslm && N == 128u)s8v8::gemm_b_pub_slm<false>(*GQ, dAp, dBp, Cout, as, bs, (int)M, Mp, (int)N, (int)K,
                                 (int)batch, sc, ldc_, scale_stride, (sb != 0u) ? N : 0u, narrow, epi);
            else
                {  s8v8::gemm_b_pub(*GQ, dAp, dBp, Cout, as, bs, (int)M, Mp, (int)N, (int)K,
                             (int)batch, sc, ldc_, scale_stride, (sb != 0u) ? N : 0u, narrow, epi); }
            pool_put(dAp);   // dBp is cache-owned (the whole batched weight)
            return;
        }
        // KNIFE C (2026-11-01): fold the N=32 batched sites' publish into the gemm, the way
        // the branch above already does for the N%64==0 (BN64) family. Those 20 calls/frame
        // (plan captured graph: M=32640 N=32 K=128 b=2 x8, M=8160 N=32 K=128 b=4 x12) today
        // pay gemm32_b + a SEPARATE scalar publish parallel_for below; measured at the
        // frame's own strides that pass is 0.3929 / 0.2055 ms per call = 31.9 / 30.5 GB/s =
        // 5.7% / 5.4% of the 560 GB/s roof, i.e. 4.2x / 3.0x the GEMM it follows. The fused
        // kernel (s8v8::gemm32_b_pub, moved verbatim from the byte-exact bench form in
        // src/bench/sycl/gemm32_tile.cpp) prices 0.0701 / 0.0447 ms/call IN THE BENCH. Against the
        // branch the frame actually runs (wide-merge, 0.1185 / 0.1001) that is -1.05 ms/frame
        // SERIAL; the frame A/B over 48 pairs measured -0.466 ms (see the reachability note).
        // Evidence + protocol: src/bench/sycl/gemm32_tile_run.txt (STEP 0 / STEP 1 rows).
        // NOT REACHABLE FOR THE FRAME AS IT STANDS (probe-verified 2026-11-01): the branch
        // above this one at :2478-2503 (P8-b wide-merge, DEFAULT ON, escape NR_B_WIDE=0)
        // already catches all 20 N=32 batched calls in the captured graph (plan tuples put
        // through wide_ok: 20/20) and returns. A temporary closure-level probe print in a
        // rebuilt dll fired ZERO times with NR_G32_PUB=1 during a full replay -- proof, not
        // inference. This branch therefore only serves the NR_B_WIDE=0 escape path, plus it
        // is an S6 brick (BN32 geometry finally has a fused-store twin). DEFAULT OFF, and NO
        // frame saving is booked to it. Escape: NR_G32_PUB=0 = the split path.
        // NOTE the early return: on this path dC is NEVER allocated, so the publish closure
        // below must not run (it would read pool garbage). No runtime diagnostic branch was
        // added inside the kernel (military rules 4/9) -- the switch is closure-level only.
        static bool g32pub = getenv("NR_G32_PUB") ? atoi(getenv("NR_G32_PUB")) != 0 : false;
        if (g32pub && (N % 32u) == 0u && (epi == 0u || epi == 1u || epi == 3u || epi == 4u)) {
             s8v8::gemm32_b_pub(*GQ, dAp, dBp, Cout, as, bs, (int)M, Mp, (int)N, (int)K,
                               (int)batch, sc, ldc_, scale_stride, (sb != 0u) ? N : 0u, narrow, epi);
            pool_put(dAp);   // dBp is cache-owned (the whole batched weight); dC never existed
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
    // NR_RES_BYTE grid probe on the one-phase FFN intermediates (1274/1275). The plane row is
    // contiguous ONLY in the frame's own geometry (sc==N, ldc==N*batch: group g lands at
    // columns g*N of the same token row -- :3282 `out = g*sc + r*ldc_ + col`). Anything else
    // would QDQ the wrong elements -> REFUSE loudly (never silently mis-quantize).
    if (rb_mode() == 3) {
        if (sc == N && ldc_r == N * batch) rb_push(c, (unsigned)Mp, ldc_r, "batched");
        else std::printf("[res-byte] batched buf=%d REFUSED: sc=%u N=%u ldc=%u batch=%u "
                         "(row not contiguous -- s8mid geometry not priced)\n",
                         c, sc, N, ldc_r, batch);
    }
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
namespace qkvloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}
int xmx_rec_gemm_int8_qkv(int a, int b, int q, int k, int v, int a_scale, int b_scale,
                          int qkv_scale, unsigned M, unsigned channels, unsigned heads,
                          unsigned tokens, unsigned flags) {
    // #148 (phase B, family #1 = qkv, 2026-11-06 18:0x): FUNCTION-SCOPE shadows so only this recorder's
    // kernels see the plain spellings -- the global cr_mul/cr_add (publish_kernel.hpp) stays as today for
    // every other consumer (the pub1/pbe4/pbgate bisect proved the red point is elsewhere; s6/layer1.md 28d).
    // The equivalence matrix (tools/rn_equiv_matrix.csv) cleared * and + for every operand class including
    // subnormals; division is NOT cleared (0/0 differs) => cr_div is deliberately left alone (军规 136).
    // These recorder bodies already sit inside the unterminated contract(off) region opened by the smax cut
    // (softmax_kernel.hpp is included at line 38, the recorders come after it), so no call site changes its
    // contraction state -- which makes this build the parent's requested `pbc` experiment as well.
    using qkvloc::cr_mul;    // shadows resolved by name lookup: only this recorder's kernels see them
    using qkvloc::cr_add;
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
    a5_take_qkv(g_cmds.size(), a, b, q, k, v, a_scale, b_scale, qkv_scale,
              M, channels, heads, tokens, flags);   // A5
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
    pgraph_ids({a,b,q,k,v,a_scale,b_scale,qkv_scale});   // PGRAPH touch-set (conservative: every operand id)
    if (vit_reuse_level() && (flags & 0x2000u))          // C25: note the ViT (global-attention) chains
        vit_note_qkv(g_cmds.size(), channels, heads, tokens);
        flop_note("int8_qkv",M,3u*channels,channels,1);
        if (getenv("NR_SHAPE_DUMP")) { static long qv=0,qnv=0; if(flags&0x2000u) qv++; else qnv++;
            std::printf("[qkv-vit] vit=%ld nonvit=%ld (running)\n", qv, qnv); }
    // B5-5b SLICE 1 (lfw, record-time pairing like the P2 take mechanism): a guarded
    // qkv STASHES its record info; if the NEXT window_attention (same q/k/v ids,
    // merged, bias, batches == M/64*heads) consumes it, the qkv closure is REPLACED
    // by a no-op and the wa closure runs pack + lfw::launch_lfw as ONE kernel --
    // planes 1274/1275/1276 and the wa launch AND the qkv gemm/tail launches all
    // dissolve into one resident launch. Unpaired stashes are harmless (the qkv
    // closure runs as-is).
    const bool lfw_guard = (lfw_on() || b6_on()) && !vit && C == 64u && heads == 2u && tokens == 64u && (M % 64u) == 0u
        && !(getenv("NR_QKV_STOP") && atoi(getenv("NR_QKV_STOP")) != 0);
    size_t myqcmd = g_cmds.size();
    if (lfw_guard) { g_lfw = LfwStash{}; g_lfw.valid = true; g_lfw.q = q; g_lfw.k = k; g_lfw.v = v;
        g_lfw.a = a; g_lfw.b = b; g_lfw.as = as; g_lfw.bs = bs; g_lfw.qs = qs;
        g_lfw.Araw = Araw; g_lfw.Braw = Braw; g_lfw.fq = fused_q; g_lfw.qfq = qfq;
        g_lfw.M = M; g_lfw.Mp = Mp; g_lfw.C = C; g_lfw.heads = heads; g_lfw.tokens = tokens; g_lfw.qcmd = myqcmd;
        if (getenv("NR_LFW_DBG")) std::printf("[lfw] guard STASH q=%d k=%d v=%d M=%u\n", q, k, v, M); }
    pg_push([=]() {
        // device pack (section 92): Araw/Braw already on device -- pack in place.
        int8_t* dAp = (int8_t*)pool_get(na);
        // B5-1: on the folded QKV path dC NEVER EXISTS (no pool_get at all -- the
        // user's "no new extra cost": not even a pool slot); the split escape
        // (NR_QKV_RES=0) allocates it as before.
        int32_t* dC = nullptr;
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
                {  packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)C); }
        }
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)NH, (int)C);   // weight: pack once
        // P5 (section 100): the resident QKV epilogue -- deq+butterfly+e4m3+scatter
        // ON the gemm's SLM-staged accumulator tile; dC (int32 Mp x 3C) AND the
        // 21ms norm_scatter tail both vanish. NON-VIT + C%64==0 only (the frame:
        // C=64/128); vit's 16 calls keep the scalar split (different tree).
        // B5-1 FINAL (2026-10-29, the user's 'eliminate the 114 dC round-trips,
        // NO EXCEPTIONS'): the fold is now the DEFAULT and covers BOTH trees --
        // non-vit runs the PROMOTED v5a vector chain (cosine_recip_vec/mulh/
        // e4m3_vec, the exact shape the green v4full QKV phase-2 runs), vit runs
        // the tree-isomorphic vit_recip_vec + the P11 host recip tab. The P5
        // falsification was about the SCALAR butterfly (14ms compute) and the
        // dpas-serialization; both roots are answered (v5a vector chain + the
        // kernel's phase-split shape: all dpas staged, ONE barrier, then tails).
        // dC is NOT ALLOCATED on this path at all. Escape NR_QKV_RES=0 = split.
        static bool qres_on = !getenv("NR_QKV_RES") || atoi(getenv("NR_QKV_RES")) != 0;
        const bool qres_ok = qres_on && (C % 64u) == 0u && NH == 3u * C && heads == C / 32u && tokens > 0u;
        if (qkvstop < 2) {
            if (qres_ok)qres::gemm_qkv_res(*GQ, dAp, dBp, Q, Kk, V, as, bs, qs, (int)M, Mp, (int)C, (int)NH, (int)heads, (int)tokens, vit, vit_recip_tab());
            else {
                dC = (int32_t*)pool_get((size_t)Mp * NH * 4);   // split path ONLY
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
                const int* vit_g_5372 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                if (qres_v2 == 3)GQ->parallel_for(sycl::range((size_t)M * heads), [=](sycl::item<1> it) {
                        if (vit_g_5372 && vit_g_5372[-1] && *vit_g_5372) { ((int*)vit_g_5372)[4199] = 2; return; }   // C32: reuse => touch nothing
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
                else if (qres_v2 == 2)wbmega::qkv_norm_scatter_v2(*GQ, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens);
                else
                    {  wbmega::qkv_norm_scatter_esimd(*GQ, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens); }
            }
        } else if (!getenv("NR_QKV_VITES") || atoi(getenv("NR_QKV_VITES")) != 0) {   // P11 PROMOTED (this window): the 449-root-cause CLOSED by bench_vitcmp's clean device comparison -- norm/recip/hq were ALL bit-exact vs the scalar reference; the flips were the TRIPLE-NESTED eh_mul(eh_mul(eh_mul(...))) chain being rewritten in-kernel (skipped intermediate half-round, RZ-direction half-ULP). The STEPPED named-temp form (t1=hq*recip, t2=t1*VIT_ROOT, t3=t2*sc) is 0/6144 EXACT in the bench. LESSON (blueprint P1 family): every proven eh chain step needs its OWN named temp adjacent to the use -- nesting is NOT safe in ESIMD, same class as the phi/scope FMA-contraction trap. Default ON, escape NR_QKV_VITES=0.
            // P11 (section 100): the VIT tail on the v1 lane structure (merged
            // single pass, 4 virtual lanes, the vit tree's within-lane E step +
            // the same SLM F cross-step). Gate NR_QKV_VITES (default ON = probe;
            // the GEMM_INT8_QKV gate family includes the 16 vit shapes).
            { float* dbg = nullptr;
              // P11-CLOSE dbg: single-writer layout (rh*4+l)*16 -- needs M*heads*64 floats.
              if (getenv("NR_VITDBG")) { dbg = (float*)sycl::malloc_device((size_t)M * heads * 4u * 64u, *GQ);
                  static float* dbg_prev = nullptr;
                  if (dbg_prev) sycl::free(dbg_prev, *GQ);
                  dbg_prev = dbg; }
               wbmega::qkv_norm_scatter_vit_esimd(*GQ, dC, Q, Kk, V, as, bs, qs, M, heads, C, NH, tokens, vit_recip_tab(), dbg);
              // NR_VITDUMP (P11 frame-0%-hunt): the FIRST vit call's full inputs
              // (dC Mp*NH int32, as, bs, qs) + the lane kernel's outputs (Q/K/V
              // M*C halfs) to vitdump.bin, for the bench to replay on REAL frame
              // data. Run with NR_CGRAPH=0 -- the host-vector memcpys here are a
              // diagnostic path, not graph-safe.
              if (getenv("NR_VITDUMP")) { static bool vdumped = false;
                  if (!vdumped) { vdumped = true;
                      std::vector<int32_t> iC((size_t)Mp*NH);
                      std::vector<float> ias(M), ibs(NH), iqs(heads);
                      std::vector<sycl::half> oQ((size_t)M*C), oK((size_t)M*C), oV((size_t)M*C);
                       GQ->memcpy(iC.data(), dC, iC.size()*4).wait();
                       GQ->memcpy(ias.data(), as, (size_t)M*4).wait();
                       GQ->memcpy(ibs.data(), bs, (size_t)NH*4).wait();
                       GQ->memcpy(iqs.data(), qs, (size_t)heads*4).wait();
                       GQ->memcpy(oQ.data(), Q, (size_t)M*C*2).wait();
                       GQ->memcpy(oK.data(), Kk, (size_t)M*C*2).wait();
                       GQ->memcpy(oV.data(), V, (size_t)M*C*2).wait();
                      FILE* f = fopen("vitdump.bin", "wb");
                      unsigned hdr[5] = {M, C, heads, tokens, NH};
                      fwrite(hdr, 4, 5, f);
                      fwrite(iC.data(), 4, iC.size(), f); fwrite(ias.data(), 4, M, f);
                      fwrite(ibs.data(), 4, NH, f); fwrite(iqs.data(), 4, heads, f);
                      fwrite(oQ.data(), 2, (size_t)M*C, f); fwrite(oK.data(), 2, (size_t)M*C, f);
                      fwrite(oV.data(), 2, (size_t)M*C, f); fclose(f);
                      printf("[vitdump] M=%u C=%u heads=%u tokens=%u NH=%u -> vitdump.bin\n", M, C, heads, tokens, NH); } }
              if (dbg) { std::vector<float> hv((size_t)M * heads * 4u * 64u);
                   GQ->memcpy(hv.data(), dbg, hv.size()*4).wait();
                  for (unsigned i = 0; i < 8u && i < M*heads; ++i)
                      printf("[vitdbg-LANE] rh=%u recipQ=%.9g recipK=%.9g hq0(l0)=%.6g hq0(l1)=%.6g\n", i, hv[(i*4u+0u)*64u+1u], hv[(i*4u+0u)*64u+3u], hv[(i*4u+0u)*64u+4u], hv[(i*4u+1u)*64u+4u]); } }
        } else if (getenv("NR_QKV_VIT1") && atoi(getenv("NR_QKV_VIT1")) != 0) {
        // P7 probe: the VIT path merged to ONE pass (the non-vit merge was the
        // section-92 win; vit kept two passes + dC float-bits write-back). This
        // form: one item per (row,head): Q/K/V deq + vit_reciprocal tree +
        // VIT_ROOT/scale + e4m3 + scatter, all in registers -- dC write-back
        // AND the stage-3 pass vanish. Arithmetic VERBATIM from the two passes
        // below (qr_half_round/cr_mul/ctree::vit_reciprocal/VIT_ROOT order kept).
         const int* vit_g_5448 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
         GQ->parallel_for(sycl::range((size_t)M * heads),
                         [=](sycl::item<1> it) {
                 if (vit_g_5448 && vit_g_5448[-1] && *vit_g_5448) { ((int*)vit_g_5448)[4199] = 2; return; }   // C32: reuse => touch nothing
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
        float* vdbg = getenv("NR_VITDBG") ? (float*)sycl::malloc_device((size_t)M * heads * 16u, *GQ) : nullptr;
         const int* vit_g_5484 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
         GQ->parallel_for(sycl::range((size_t)M * heads),
                         [=](sycl::item<1> it) {
                 if (vit_g_5484 && vit_g_5484[-1] && *vit_g_5484) { ((int*)vit_g_5484)[4199] = 2; return; }   // C32: reuse => touch nothing
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
            if (vdbg) { vdbg[(size_t)i * 16u + 0u] = 12345.0f;   // marker: scalar path
                        vdbg[(size_t)i * 16u + 2u] = recip;
                        for (int q2 = 0; q2 < 8; ++q2) vdbg[(size_t)i * 16u + 4u + q2] = row32[q2 * 4]; }  // hq-parity slots
            for (int c2 = 0; c2 < 32; ++c2) {
                unsigned n = head * 32u + (unsigned)c2;
                float h = row32[c2];
                float val = qr_half_round(cr_mul(h, recip));
                if (vit) val = qr_half_round(cr_mul(val, ctree::VIT_ROOT));
                val = qr_half_round(cr_mul(val, sc));
                if (vdbg && c2 < 2) vdbg[(size_t)i * 16u + 12u + c2] = val;   // the FINAL pre-e4m3 value
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
        if (vdbg) {
            std::vector<float> hv((size_t)M * heads * 16u);
             GQ->memcpy(hv.data(), vdbg, hv.size()*4).wait();
            for (unsigned i2 = 0; i2 < 8u && i2 < hv.size()/4u; ++i2)
                printf("[vitdbg-SCALAR] rh=%u recipQ=%.9g recipK=%.9g\n", i2, hv[i2*4+2], hv[i2*4+3]);
            sycl::free(vdbg, *GQ); }
        }   // end else (vit scalar stage2 + stage3)
        qkv_done:;
        if (!qres_ok) dC = (int32_t*)nullptr;   // (kept for the split path below)
        pool_put(dAp); pool_put(dBp); if (dC) pool_put(dC);
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
    pgraph_ids({a,b,c,a_scale,b_scale,skip,cosine});   // PGRAPH touch-set (conservative: every operand id)
        flop_note("int8_residual",M,N,K,1);
    QuantFused qfr; const bool fused_r = qfuse_take(a, a_scale, M, K, qfr);
    sycl::half* a16r = fused_r ? (sycl::half*)g_bufs[qfr.src].p : nullptr;
    if (fused_r) pgraph_extra(qfr.src);   // PGRAPH: the fused gather reads the RAW plane
    // S6-1a (NR_S6_FFN): this is the chain's LAST leg. On a full six-op adjacency match
    // the FIVE earlier closures of the chain are replaced by no-ops (inside
    // s6_take_residual -- all six or none, never a partial no-op) and THIS closure runs
    // the fused block-resident kernel instead of the split pack+gemm. The switch is
    // closure-level only; the kernel body carries no runtime diagnostic branch.
    S6Fuse s6f;
    const bool s6fire = s6_take_residual(g_cmds.size(), a, b, c, a_scale, b_scale,
                                         skip, cosine, M, N, K, flags, s6f);
    if (s6fire) {
        pgraph_extra(s6f.be); pgraph_extra(s6f.bp);      // the two extra weight reads
        pgraph_extra(s6f.bse); pgraph_extra(s6f.bsp);    // and the two scale arrays
        pg_push([s6f]() { s6_ffn_run(s6f); });
        rb_push(c, (unsigned)Mp, N, "residual");               // NR_RES_BYTE grid probe
        return 0;
    }
    // KNIFE 1 (NR_BMERGE): remember this residual leg's full context so bmerge_apply (capture
    // time, after the skip pass) can fold same-shape legs into one batched launch. Skipped /
    // S6-fused / rb8 bodies never reach here, and a skipped closure never runs its body, so a
    // dead leg can never join a group.
    if (bmerge_level() >= 1 && !s6fire && (N % 64u) == 0u && (K % 32u) == 0u)
        g_bm_res_sites.push_back(BmResSite{ Araw, Braw, Cout, as, bs, skp, cp, a16r, fused_r,
                                            b, a, c, skip, cosine, (int)M, Mp, (int)N, (int)K, flags, narrow,
                                            half_skip, epi, na, g_cmds.size() });
    pg_push([=]() {
        // device pack (section 92): Araw/Braw are already on device -- pack in place,
        // no download/upload round-trip (same conversion as gemm_int8, packdev gate).
        int8_t* dAp = (int8_t*)pool_get(na);
        static int rstop = getenv("NR_RES_STOP") ? atoi(getenv("NR_RES_STOP")) : 0;   // section 100 ledger (time-only): 1 = pack only, 2 = no pack either
        // C61g: SINGLE DECISION POINT. The predicate is evaluated ONCE per leg and cached in
        // gkb64 (declared OUTSIDE the rstop block so both the packer and the reader see it);
        // the packer below and the reader further below both branch on that one boolean, so a
        // plane can never be packed in one order and read in another.  NR_GKB64_DBG=1 dumps the
        // decision tuple per gir leg -- construction-level evidence the four gates cannot give.
        const bool gkb64 = gir_bk64_ok((unsigned)K);
        static int gkdbg = getenv("NR_GKB64_DBG") ? atoi(getenv("NR_GKB64_DBG")) : 0;
        if (gkdbg) fprintf(stderr, "[gkb64] M=%d Mp=%d N=%d K=%u fused_r=%d -> %s\n",
                           (int)M, (int)Mp, (int)N, (unsigned)K, (int)fused_r,
                           gkb64 ? "BK64 (pack_a64/fused64 + s8v8b)" : "BK32 (shipped pair)");
        if (rstop < 2) {
        if (gkb64) {
            // C61d: the same predicate the gemm entry below uses -- packer and reader switch
            // together by construction.
            if (fused_r) packdev::pack_a_fused64(*GQ, a16r, dAp, (float*)as, (int)M, Mp, (int)K);
            else         packdev::pack_a64(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        } else if (fused_r) packdev::pack_a_fused(*GQ, a16r, dAp, (float*)as, (int)M, Mp, (int)K);
        else packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)K);
        }
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)N, (int)K);   // weight: pack once
        if (rstop >= 1) { pool_put(dAp); return; }
        // DERIVED (section 92): same lever as batched -- fuse the publish into the gemm
        // store, killing the int32 dC scratch + the separate publish pass. The residual
        // epilogue's sycl::fma(skip,cos,stage) maps to ESIMD's auto-contracted sk*cp+stage
        // (one fused rounding, the gate_esimd lesson used correctly). N%64==0 is already a
        // hard requirement of this op, so every call qualifies. GEMM_INT8_RESIDUAL judges.
        // C61b (2026-11-12): BK=64 operand form for the gemm_int8_residual family ONLY.
        // Every gir shape in the ledger has K % 64 == 0 ({64,128,256,512,1024,4096}), and the
        // guard keeps the old entry reachable (198④: the new file must not leave two live paths
        // by accident -- here the fallback is deliberate and single, for shapes BK=64 cannot
        // divide). Bit-exactness argument: int32 dpas accumulation is exact + associative over
        // K and the operand bytes are the same packed planes; bench_s8v8_tile priced this form
        // at 11 variants x 5 shapes x 3 processes with ALL diff=0.
        if (gkb64)
             s8v8b::gemm_b_res(*GQ, dAp, dBp, Cout, as, bs, skp, cp, (int)M, Mp, (int)N, (int)K,
                             narrow, half_skip, epi);
        else
             s8v8::gemm_b_res(*GQ, dAp, dBp, Cout, as, bs, skp, cp, (int)M, Mp, (int)N, (int)K,
                             narrow, half_skip, epi);
        pool_put(dAp);   // dBp is cache-owned (the weight)
    });
    rb_push(c, (unsigned)Mp, N, "residual");               // NR_RES_BYTE grid probe
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
    pgraph_ids({a,b,c,a_scale,b_scale,skip,cosine});   // PGRAPH touch-set (conservative: every operand id)
        flop_note("win_int8_res",M,N,K,1);
    A5Fuse a5f;
    const bool a5fire = a5_take_wres(g_cmds.size(), a, b, c, a_scale, b_scale, skip, cosine,
                                     M, N, K, flags, height, width, across, pad, a5f);
    if (a5fire) {
        // A5-NAMEFIX: the recorder ALREADY pushed this closure's name (the pgraph_ids/flop_note
        // lines above). Pushing a second one desynchronised g_cmd_names from g_cmds by +1 per
        // fire: with 4 fires the skip machinery saw "name offset 695 not a whole recording" and
        // REFUSED -- so the ON side silently stopped skipping 14 chains (its 1301 came out
        // byte-identical to bk.1301.pre-skip-1a.bin, and the run time went +4.4 ms). knife2b #85.
        // A5-FOLDRESCUE (knife2b #92/#95): the split 645 dissolves its own producing QUANT (644)
        // through the shipped mechanism qfuse_take() (@362-376: it rewrites that closure to a no-op
        // and renames it "quant(FUSED-pack)"). This branch used to return BEFORE that call, so 644
        // fell back to a real quantize: +0.104 ms/chain x 7 chains = +0.73 ms serial, fingerprint =
        // rtcsv xmx_rec_quant rows 80 -> 87. Reusing the shipped mechanism is strictly better than
        // the g_fused_quant idea (that would memcpy f16 bytes into SHARED scratch 1273/1274).
        QuantFused qfw5;
        qfuse_take(a, a_scale, M, K, qfw5);
        pg_push([a5f]() { a5_att_run(a5f); });
        return 0;   // the window-residual closure itself became the fused launch
    }
    // B6-1 completion: the fused chain's LAST leg. When the quant leg matched and
    // THIS wres consumes exactly that pk/a_scale pair with the expected image map
    // (M/N/K + adjacency), rewrite: the wa closure (at g_b6.wacmd) becomes ONE
    // b6::launch_b6 (qkv+wa+quant+outproj+fold), the quant closure no-ops, and
    // THIS wres closure is never pushed. The qkv closure was already no-op'd by
    // the wa-pair mechanism. Escape NR_B6=0.
    static int wrstop0 = getenv("NR_WRES_STOP") ? atoi(getenv("NR_WRES_STOP")) : 0;
    if (b6_on() && g_b6.valid && g_b6.qmatched && g_cmds.size() > g_b6.quantcmd &&
        g_cmds.size() - g_b6.quantcmd <= 3 &&
        a == g_b6.pkid && a_scale == g_b6.scid && M == g_b6.S.M && N == 64u && K == 64u &&
        epi == 1u && narrow && half_skip && skip >= 0 && cosine >= 0 && wrstop0 == 0 &&
        !(getenv("NR_WA_STOP") && atoi(getenv("NR_WA_STOP")) != 0)) {
        B6Stash B = g_b6; g_b6 = B6Stash{};
        const size_t na = (size_t)B.S.Mp * B.S.C;
        const float* biasp2 = B.bias;
        const unsigned acrossu = across, topu = pad >> 16, leftu = pad & 0xffffu;
        const unsigned ihu = height, iwu = width;
        // rewrite the wa closure -> the b6 launch:
        g_cmds[B.wacmd] = [=]() {
            auto sized = [&](int id, size_t bytes, const char* what) -> void* {
                auto it = g_bufs.find(id);
                if (it == g_bufs.end() || it->second.bytes < bytes)
                    throw std::runtime_error(std::string("b6: ") + what + " not live/smaller at run");
                return it->second.p;
            };
            int8_t* dAp = (int8_t*)pool_get(na);
            if (B.S.fq) {
                auto itsrc = g_bufs.find(B.S.qfq.src);
                if (itsrc == g_bufs.end()) throw std::runtime_error("b6 fused-gather: image src not live");
                 packdev::pack_a_fused_gather(*GQ, (const sycl::half*)itsrc->second.p, dAp,
                    (float*)B.S.as, (int)B.S.M, (int)B.S.Mp, (int)B.S.C, B.S.qfq.image_h, B.S.qfq.image_w, B.S.qfq.across, B.S.qfq.pad);
            } else
                {  packdev::pack_a(*GQ, B.S.Araw, dAp, (int)B.S.M, (int)B.S.Mp, (int)B.S.C); }
            int8_t* dBp = cached_pack_b_i8(B.S.b, B.S.Braw, (int)(3u * B.S.C), (int)B.S.C);
            // the outproj weight: cached pack_b of the wres's B (transposed N x K
            // raw -> the pack_b map the gemm consumes; cached_pack_b_i8 keys on
            // (bufid,N,K) -- the wres weight id b):
            int8_t* dOp = cached_pack_b_i8(b, (const int8_t*)g_bufs.find(b)->second.p, (int)N, (int)K);
            b6::launch_b6(*GQ, dAp, dBp, B.S.as, B.S.bs, B.S.qs, biasp2, B.windows,
                (sycl::half*)g_bufs.find(B.S.q)->second.p, (sycl::half*)g_bufs.find(B.S.k)->second.p,
                (sycl::half*)g_bufs.find(B.S.v)->second.p,
                dOp, (const float*)g_bufs.find(b_scale)->second.p,
                (const float*)g_bufs.find(cosine)->second.p,
                (const sycl::half*)g_bufs.find(skip)->second.p,
                (sycl::half*)g_bufs.find(c)->second.p,
                acrossu, topu, leftu, ihu, iwu);
            pool_put(dAp);
        };
        g_cmd_names[B.wacmd] = "window_attention(B6-1 fused)";
        g_cmds[B.quantcmd] = [](){};
        g_cmd_names[B.quantcmd] = "quant(B6-fused)";
        flop_note("win_int8_res",M,N,K,1);   // the wres gemm still counts in the flop ledger
        return 0;   // the wres closure is NEVER pushed
    }
    QuantFused qfw; const bool fused_w = qfuse_take(a, a_scale, M, K, qfw);
    const int srcid_w = fused_w ? qfw.src : 0;
    pg_push([=]() {
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
        // C90: pinned to the LIVE shapes only (plan chains 25 and 33: M=768, N=512, K=512).
        // The epi/narrow terms that were here came from the bench form, not from these legs --
        // with them the gate matched nothing (90/90 wres lines printed p128=0). The copied
        // window tail already handles epi=0/narrow=false and epi=1/narrow=true.
        const bool p128 = wres_pub128_on()
                          && ((M == 768u  && N == 512u && K == 512u)      // the live C512 chains (C90)
                              || (M == 960u  && N == 512u && K == 512u)    // same family, other chain
                              || (M == 2560u && N == 256u && K == 256u)    // bench-gated bad=0, -20.8%
                              || (M == 8640u && N == 128u && K == 128u)    // bench-gated bad=0,  -8.2%
                              || (M == 9216u && N == 128u && K == 128u));  // bench-gated bad=0,  -7.4%
        // N=64 (34560x64x64) is deliberately excluded above: BN=128 needs N >= BN.
        // C92: the band pair -- producer (the fused packer's row max per 128 columns) and
        // consumer (the publish tail's as[row*nband + band]) switch TOGETHER. Requires the
        // fused path, because on the split path the standalone QUANT writes the scales.
        const bool band_w = band_scale_on() && fused_w && M == 768u && N == 512u && K == 512u;
        if (getenv("NR_WRES_DBG"))
            std::printf("[wres-pub128] p128=%d M=%u N=%u K=%u Mp=%d epi=%u narrow=%d half_skip=%d flags=%u\n",
                        (int)p128, M, N, K, Mp, (unsigned)((flags >> 8) & 0xFu),
                        (int)((flags & 0x1000u) != 0u), (int)((flags & 0x40000u) != 0u), flags);
        static int wrstop = getenv("NR_WRES_STOP") ? atoi(getenv("NR_WRES_STOP")) : 0;   // section 100 ledger (time-only)
        if (wrstop < 2) {
        if (fused_w) {   // P2: the closure captured (fused_w, srcid_w) by value at
            sycl::half* a16w = (sycl::half*)sized(srcid_w, (size_t)M * K * 2u, "A(f16 fused)");
            // the A pack switches TOGETHER with the kernel (BK=64 order) -- the pairing rule
            // pinned by the C70/C82 knife (gir_bk64_ok).
            if (band_w) packdev::pack_a_fused_band128(*GQ, a16w, dAp, (float*)as, (int)M, Mp, (int)K);
            else if (p128) packdev::pack_a_fused64(*GQ, a16w, dAp, (float*)as, (int)M, Mp, (int)K);
            else      packdev::pack_a_fused(*GQ, a16w, dAp, (float*)as, (int)M, Mp, (int)K);
        } else if (p128) { packdev::pack_a64(*GQ, Araw, dAp, (int)M, Mp, (int)K); }
        else
        {  packdev::pack_a(*GQ, Araw, dAp, (int)M, Mp, (int)K); }
        }
        int8_t* dBp = cached_pack_b_i8(b, Braw, (int)N, (int)K);   // weight: pack once
        if (wrstop >= 1) { pool_put(dAp); return; }
        // DERIVED (section 92): same fused-publish lever as int8_residual/batched. The
        // window variant maps the gemm row (window*64+token) to the image slot with the
        // same bounds cull the split pass did, and reads skip at that slot. N%64==0 is a
        // hard requirement of this op. WINDOW_INT8_RESIDUAL gate is the judge.
         // C91: this leg reads the (pk,sc) pair the mid-chain QUANT produced. When that quant
         // was band-scaled (band_w), the row scale becomes per-band -- and the fused-pack path
         // (fused_w) is excluded, because there the quant closure is a no-op and the row max is
         // taken inside the packer (whole-row) -- that path keeps the shipped scales.
         if (getenv("NR_BAND_DBG"))
             std::printf("[band-wres] band_w=%d fused_w=%d p128=%d M=%u N=%u K=%u nband=%u\n",
                         (int)band_w, (int)fused_w, (int)p128, M, N, K, band_w ? 4u : 1u);
         if (p128)
              s8v8t::gemm_b_res_window_128(*GQ, dAp, dBp, Cout, as, bs, skp, cp, (int)M, Mp, (int)N, (int)K,
                                narrow, half_skip, epi, across, top, left, height, width, band_w ? 4u : 1u);
         else
              s8v8::gemm_b_res_window(*GQ, dAp, dBp, Cout, as, bs, skp, cp, (int)M, Mp, (int)N, (int)K,
                                narrow, half_skip, epi, across, top, left, height, width, band_w ? 4u : 1u);
        pool_put(dAp);   // dBp is cache-owned (the weight)
    });
    rb_push(c, M, N, "wres");                             // NR_RES_BYTE grid probe (1270 plane)
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
namespace global_attentionloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_global_attention (no pragma, no division)
int xmx_rec_global_attention(int q, int k, int v, int merged, unsigned rows,
                             unsigned tokens, unsigned heads) {
    using global_attentionloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using global_attentionloc::cr_add;
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
    if (getenv("NR_Q_STATS")) printf("[ga-REC] rows=%u tokens=%u heads=%u\n", rows, tokens, heads);
    g_cmd_names.push_back(__func__);
    pgraph_ids({q,k,v,merged});   // PGRAPH touch-set (conservative: every operand id)
    pg_push([=]() {
        float* dScores = (float*)pool_get(sc * 4);
        sycl::half* dProbs = nullptr;   // B5-4: split-escape only (allocated below)
        float* dRecip = (float*)pool_get((size_t)heads * rows * 4);
        // B5-4: dCtx moved to the split branch below (never allocated on the fold path).
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
        if (gat && (rows % 16u) == 0u && Mp == (int)rows)smax::launch_vit_softmax_tiled(*GQ, sycl::range((size_t)heads * rows), dScores, dAp, dRecip, heads * rows, tokens, rows); else {
            dProbs = (sycl::half*)pool_get(sc * 2);   // split escape only
             smax::launch_vit_softmax_kernel(*GQ, sycl::range((size_t)heads * rows), dScores, dProbs, dRecip, heads * rows, tokens, rows);
            // attnV leg: P(rows x rows) @ V(rows x 32) -> rows x 32. V stored (rows,32)=(K,N).
             packdev::pack_a16_b(*GQ, dProbs, dAp, (int)rows, Mp, (int)rows, (int)heads);
        }
         packdev::pack_b16_b(*GQ, V, dBv, (int)rows, 32, (int)heads);
        // P9-twin (section 100): attnV + merge_heads_scale FOLDED (gemm_b_merge_scale):
        // half_round -> *recip -> half_round -> e4m3 lands ON the accumulator and
        // scatters straight into the merged (rows, heads*32) half layout -- dCtx
        // (heads x rows x 32 f32) AND the merge launch both vanish. The recip chain
        // is the merge pass's EXACT op order (each stage its own ESIMD instruction,
        // no contraction). Guard: Mp==rows (the recorder pads Mp=ceil16(rows);
        // in-frame rows%16==0). Escape NR_GA_MERGE=0.
        // B5-4 (2026-10-29, the user's "eliminate EVERY dC round-trip"): the fold is
        // now the DEFAULT. The P9-twin "NEUTRAL" was a timing call on the old frame;
        // the order is structural -- dCtx's write+read must not exist. dCtx is NOT
        // ALLOCATED on the fold path (zero new buffers, one launch fewer).
        static bool gam = !getenv("NR_GA_MERGE") || atoi(getenv("NR_GA_MERGE")) != 0;
        float* dCtx = nullptr;
        pool_put(dAq); pool_put(dBk); pool_put(dAp); pool_put(dBv);
        if (gam && Mp == (int)rows && (rows % 16u) == 0u)f16v1::gemm_b_merge_scale(*GQ, dAp, dBv, (sycl::half*)M, dRecip, Mp, 32, (int)rows, (int)heads); else {
        dCtx = (float*)pool_get(cx * 4);   // split path only
         f16v1::gemm_b(*GQ, dAp, dBv, dCtx, Mp, 32, (int)rows, (int)heads);
        // merge_heads_scale: (1,rows,heads*32) with scale=reciprocal (heads*rows), e4m3, half
         const int* vit_g_5923 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
         GQ->parallel_for(sycl::range((size_t)rows * CH), [=](sycl::item<1> it) {
                 if (vit_g_5923 && vit_g_5923[-1] && *vit_g_5923) { ((int*)vit_g_5923)[4199] = 2; return; }   // C32: reuse => touch nothing
            unsigned index = (unsigned)it.get_id(0);
            unsigned c = index % CH, token = index / CH;
            size_t at = (size_t)(c / 32u) * rows + token;   // window=0: at=(0*heads + c/32)*rows + token
            float value = qr_half_round(cr_mul(qr_half_round(dCtx[at * 32u + (c % 32u)]), dRecip[at]));
            ((sycl::half*)M)[index] = sycl::half(qr_e4m3(value));
        });
        }   // P9-twin gate
        pool_put(dScores); pool_put(dProbs); pool_put(dRecip); if (dCtx) pool_put(dCtx);
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
    sp_advance();   // B step 3 (see the helper above)
    if (!g_recording) FAILMSG("not recording");
    static int qwstop = getenv("NR_QW_STOP") ? atoi(getenv("NR_QW_STOP")) : 0;
    if (qwstop == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }
    pgraph_ids({source,packed,scale});   // PGRAPH touch-set (conservative: every operand id)
    a5_note_qw(g_cmds.size(), source, packed, scale, M, K, height, width, across, pad);  // A5
    if (!M || !K || (K % 64u)) FAILMSG("a gathered quantiser needs K a multiple of 64");
    if (!across || !height || !width) FAILMSG("a gathered quantiser needs the image extent and windows per row");
    auto s = g_bufs.find(source), p2 = g_bufs.find(packed), c = g_bufs.find(scale);
    if (s == g_bufs.end() || p2 == g_bufs.end() || c == g_bufs.end()) FAILMSG("bad quant_window operand");
    sycl::half* a = (sycl::half*)s->second.p;
    sycl::uint2* pk = (sycl::uint2*)p2->second.p;
    float* sc = (float*)c->second.p;
    g_cmd_names.push_back(__func__);
    pg_push([=]() {
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
namespace unaryloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_unary (no pragma, no division)
// C104 (knife: unary kind 21 UPSAMPLE_ADD): one item handles a 2x2 block of TARGET pixels, so
// the source-pixel value (A) and the per-channel D vector are loaded ONCE for four outputs.
// The per-output arithmetic is unchanged (same order, same s8v8::e4m3_vec_v8), so the output is
// byte-identical to the live arm -- PROVEN in the bench: bad=0 on all three real shapes, 3 cold
// processes, at -84.5% / -87.9% / -89.4% per launch (tmp\c104\c104_up.cpp).
static inline sycl::event up_2x2(sycl::queue& q, const void* A, const void* B, void* C, const float* D,
                           unsigned N, unsigned CH, unsigned target, unsigned source,
                           const int* vgate) {
    unsigned rows = N / (target * CH);
    size_t blocks = (size_t)(target / 2u) * (rows / 2u);
    return q.parallel_for(sycl::range(blocks * (CH / 16u)), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        // the C32 reuse gate, verbatim as the live arm has it -- without this the REUSE=1 path
        // would recompute planes the shipped path deliberately skips.
        if (vgate && vgate[-1] && *vgate) { ((int*)vgate)[4199] = 2; return; }
        namespace esimd = sycl::ext::intel::esimd;
        size_t id = it.get_id(0);
        unsigned cc = (unsigned)((id % (CH / 16u)) * 16u);
        unsigned rest = (unsigned)(id / (CH / 16u));
        unsigned bx = rest % (target / 2u), by = rest / (target / 2u);
        unsigned x0 = 2u * bx, y0 = 2u * by;
        size_t srcbase = ((size_t)(y0 / 2u) * source + (x0 / 2u)) * CH + cc;
        esimd::simd<float,16> av = esimd::block_load<float,16>((const float*)A + srcbase, esimd::overaligned_tag<16>{});
        esimd::simd<float,16> dv = esimd::block_load<float,16>(D + cc, esimd::overaligned_tag<16>{});
        #pragma unroll
        for (int dy = 0; dy < 2; ++dy) {
            #pragma unroll
            for (int dx = 0; dx < 2; ++dx) {
                size_t index = ((size_t)(y0 + dy) * target + (x0 + dx)) * CH + cc;
                esimd::simd<sycl::half,16> bv = esimd::block_load<sycl::half,16>(
                    (const sycl::half*)B + index, esimd::overaligned_tag<16>{});
                esimd::simd<float,16> merged = av + esimd::convert<float>(bv) * dv;
                esimd::simd<sycl::half,16> o = esimd::convert<sycl::half>(s8v8::e4m3_vec_v8<16>(merged));
                esimd::block_store<sycl::half,16>((sycl::half*)C + index, o, esimd::overaligned_tag<16>{});
            }
        }
    });
}

int xmx_rec_unary(unsigned kind, int a, int b, int c, int d, unsigned n,
                  unsigned channels, float p0, unsigned batch, unsigned sa,
                  unsigned sb, unsigned sc, unsigned k) {
    using unaryloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using unaryloc::cr_add;
    if (!g_recording) FAILMSG("not recording");
    static int ustop = getenv("NR_U_STOP") ? atoi(getenv("NR_U_STOP")) : 0;
    if (ustop == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }
    pgraph_ids({a,b,c,d});   // PGRAPH touch-set (conservative: every operand id)
    if (vit_reuse_level())   // C26: note the UNARY (the S2 criterion host looks here: it is
        vit_note_unary(g_cmds.size(), a, b, c, d, n);   // the producer of the entry GEMM's face
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
        // BLADE U-1 (the unary leg map 10:4x: U_STOP=9 = -7.5ms measured; this
        // branch alone = 18.5M elements/frame): the shipping form is ONE SCALAR
        // thread per element (f32 load, software qr_e4m3, 2B store) = the frame's
        // biggest elementwise and the blade-4 pattern at its purest. Vector twin:
        // e4m3_vec_v8 = bench_e4m3vec-proven bit-identical to qr_e4m3 (0/4096).
        // SIMD16 block form (64B loads / 32B stores per thread). Guards: N%16==0
        // (every frame N: 98304..4177920 all mult of 16), !a_half (the f32-read
        // contract). Escape NR_UNARY_VEC=0. Judges: UNARY_KINDS gate + 1301.
        static bool uvec = !getenv("NR_UNARY_VEC") || atoi(getenv("NR_UNARY_VEC")) != 0;
        if (uvec && (N % 16u) == 0u && !a_half) {
            pg_push([=]() {
                 const int* vit_g_6024 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                 GQ->parallel_for(sycl::range((size_t)N / 16u), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                         if (vit_g_6024 && vit_g_6024[-1] && *vit_g_6024) { ((int*)vit_g_6024)[4199] = 2; return; }   // C32: reuse => touch nothing
                    namespace esimd = sycl::ext::intel::esimd;
                    size_t i = (size_t)it.get_id(0) * 16u;
                    esimd::simd<float,16> v = esimd::block_load<float,16>(
                        (const float*)A + i, esimd::overaligned_tag<16>{});
                    esimd::simd<sycl::half,16> o = esimd::convert<sycl::half>(s8v8::e4m3_vec_v8<16>(v));
                    esimd::block_store<sycl::half,16>((sycl::half*)C + i, o, esimd::overaligned_tag<16>{});
                });
            });
            return 0;
        }
        pg_push([=]() {
             const int* vit_g_6036 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
             GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                     if (vit_g_6036 && vit_g_6036[-1] && *vit_g_6036) { ((int*)vit_g_6036)[4199] = 2; return; }   // C32: reuse => touch nothing
                size_t i = it.get_id(0);
                ((sycl::half*)C)[i] = sycl::half(qr_e4m3(((const float*)A)[i]));
            });
        });
    } else if (sub == 12u) {   // POOL2: 2x2 average NHWC, column-first order (.comp:529-531)
        g_cmd_names.push_back(__func__);
        // BLADE U-3 (3.9M elems/frame): channel-contiguous blocks again -- the
        // four loads (base, +ch, +width*ch, +(width+1)*ch) are 16-contiguous per
        // pixel, and the cr_add tree ((a+b)+c)+d keeps its EXACT per-lane order
        // (esimd + = separate fadd instrs, §92 normalize_esimd proof; NO fma
        // contraction in ESIMD). cr_mul(total,0.25f): 0.25 is a power of two =
        // EXACT at any width (no rounding at all, the multiply-by-quarter is a
        // significand shift); then e4m3_vec_v8 (epi==1 frame form). Guards:
        // !a_half && narrow && epi==1 && CH%16==0 && N%16==0.
        static bool uvec3 = !getenv("NR_UNARY_VEC") || atoi(getenv("NR_UNARY_VEC")) != 0;
        if (uvec3 && !a_half && narrow && epi == 1u && (CH % 16u) == 0u && (N % 16u) == 0u) {
            pg_push([=]() {
                 const int* vit_g_6054 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                 GQ->parallel_for(sycl::range((size_t)N / 16u), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                         if (vit_g_6054 && vit_g_6054[-1] && *vit_g_6054) { ((int*)vit_g_6054)[4199] = 2; return; }   // C32: reuse => touch nothing
                    namespace esimd = sycl::ext::intel::esimd;
                    size_t index = (size_t)it.get_id(0) * 16u;
                    unsigned ch = CH, width = SB;
                    unsigned cc = (unsigned)(index % ch), rest = (unsigned)(index / ch);
                    unsigned x = rest % (width / 2u), y = rest / (width / 2u);
                    size_t base = ((size_t)(2u * y) * width + 2u * x) * ch + cc;
                    esimd::simd<float,16> t = esimd::block_load<float,16>((const float*)A + base, esimd::overaligned_tag<16>{});
                    t = t + esimd::block_load<float,16>((const float*)A + base + (size_t)width * ch, esimd::overaligned_tag<16>{});
                    t = t + esimd::block_load<float,16>((const float*)A + base + ch, esimd::overaligned_tag<16>{});
                    t = t + esimd::block_load<float,16>((const float*)A + base + (size_t)(width + 1u) * ch, esimd::overaligned_tag<16>{});
                    t = t * esimd::simd<float,16>(0.25f);
                    esimd::simd<sycl::half,16> o = esimd::convert<sycl::half>(s8v8::e4m3_vec_v8<16>(t));
                    esimd::block_store<sycl::half,16>((sycl::half*)C + index, o, esimd::overaligned_tag<16>{});
                });
            });
            return 0;
        }
        pg_push([=]() {
             const int* vit_g_6073 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
             GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                     if (vit_g_6073 && vit_g_6073[-1] && *vit_g_6073) { ((int*)vit_g_6073)[4199] = 2; return; }   // C32: reuse => touch nothing
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
        // BLADE U-2 (the unary leg map): 0x15 = 8.0M elems/frame; the frame's
        // calls are ALL epi=1 (e4m3 only), narrow, b_half, CH in {64,128,256,512}
        // -- and the element order is CHANNEL-CONTIGUOUS (index%ch), so a 16-wide
        // block never crosses a pixel: aval (nearest-source, contiguous 16),
        // bval (contiguous 16), D[cc] (contiguous 16) all vectorize; the
        // cr_add/cr_mul twins are the v3d-promoted wbv2::cradd_simd/crmul_simd
        // (fmul_rn/fadd_rn = IEEE rn = the same bits esimd mul/add lower to --
        // the §92 normalize_esimd proof), e4m3_vec_v8 = bench_e4m3vec proven.
        // Guards: !a_half && b_half && narrow && CH%16==0 && N%16==0 && epi==1.
        // Escape NR_UNARY_VEC=0 (shared with U-1). UNARY_KINDS gate judges.
        static bool uvec2 = !getenv("NR_UNARY_VEC") || atoi(getenv("NR_UNARY_VEC")) != 0;
        // C104: the 2x2 form. Default OFF (NR_UP_2X2 unset) -> the shipped arm below is untouched
        // (rule 217: the default path must be the original expression, and here it literally is:
        // the new arm is an additional branch in front of it, never a modified common path).
        // Shape gate pinned to the engine's own DBG arguments (rule 216): rows and target must
        // both be even so a 2x2 block never crosses the image edge.
        // STAGED (C105 promotion, 2026-11-13): default ON; escape hatch NR_UP_2X2=0 restores the
        // old arm verbatim. Faces are byte-identical ON vs OFF (C104 four-gate ladder: fused
        // 254C02B7/CACD2029/4D90CCA5 + plain DD49827D EXACT both sides, 8/8 legs on the new form).
        static bool up2 = !getenv("NR_UP_2X2") || atoi(getenv("NR_UP_2X2")) != 0;
        const unsigned u_rows = (SA && CH) ? (N / (SA * CH)) : 0u;
        const bool up2_ok = up2 && !a_half && b_half && narrow && epi == 1u
                            && (CH % 16u) == 0u && (N % 16u) == 0u
                            && (SA % 2u) == 0u && (u_rows % 2u) == 0u && (SB * 2u >= SA);
        if (getenv("NR_U_DBG"))
            std::printf("[up2x2] sub=%u up2=%d up2_ok=%d n=%u CH=%u SA=%u SB=%u rows=%u\n",
                        sub, (int)up2, (int)up2_ok, N, CH, SA, SB, u_rows);
        if (up2_ok) {
            pg_push([=]() {
                 const int* vit_g_up2 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                 up_2x2(*GQ, A, B, C, D, N, CH, SA, SB, vit_g_up2);
            });
            return 0;
        }
        if (uvec2 && !a_half && b_half && narrow && epi == 1u && (CH % 16u) == 0u && (N % 16u) == 0u) {
            pg_push([=]() {
                 const int* vit_g_6101 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                 GQ->parallel_for(sycl::range((size_t)N / 16u), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                         if (vit_g_6101 && vit_g_6101[-1] && *vit_g_6101) { ((int*)vit_g_6101)[4199] = 2; return; }   // C32: reuse => touch nothing
                    namespace esimd = sycl::ext::intel::esimd;
                    size_t index = (size_t)it.get_id(0) * 16u;
                    unsigned ch = CH, target = SA, source = SB;
                    unsigned cc = (unsigned)(index % ch), rest = (unsigned)(index / ch);
                    unsigned x = rest % target, y = rest / target;
                    esimd::simd<sycl::half,16> bv = esimd::block_load<sycl::half,16>(
                        (const sycl::half*)B + index, esimd::overaligned_tag<16>{});
                    esimd::simd<float,16> av = esimd::block_load<float,16>(
                        (const float*)A + ((size_t)(y / 2u) * source + (x / 2u)) * ch + cc,
                        esimd::overaligned_tag<16>{});
                    esimd::simd<float,16> dv = esimd::block_load<float,16>(D + cc, esimd::overaligned_tag<16>{});
                    esimd::simd<float,16> merged = av + esimd::convert<float>(bv) * dv;
                    esimd::simd<sycl::half,16> o = esimd::convert<sycl::half>(s8v8::e4m3_vec_v8<16>(merged));
                    esimd::block_store<sycl::half,16>((sycl::half*)C + index, o, esimd::overaligned_tag<16>{});
                });
            });
            return 0;
        }
        pg_push([=]() {
             const int* vit_g_6121 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
             GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                     if (vit_g_6121 && vit_g_6121[-1] && *vit_g_6121) { ((int*)vit_g_6121)[4199] = 2; return; }   // C32: reuse => touch nothing
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
        // BLADE U-4 (2.1M elems/frame): channel-contiguous 16-blocks again --
        // the in-bounds test depends on (y,x) only, CONSTANT across a 16-channel
        // run (CH%16==0 -> no pixel crossing). Frame calls: epi=0 (identity),
        // narrow=false (f32 out), a_half=false. Guards enforce exactly that.
        static bool uvec4 = getenv("NR_UNARY_VEC2") != nullptr && atoi(getenv("NR_UNARY_VEC2")) != 0;   // U-4 VERDICT 16-pair: 6w/10l mean +0.42 = NEGATIVE -> default OFF (asset kept)
        if (uvec4 && !a_half && !narrow && epi == 0u && (CH % 16u) == 0u && (N % 16u) == 0u) {
            pg_push([=]() {
                 const int* vit_g_6143 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
                 GQ->parallel_for(sycl::range((size_t)N / 16u), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                         if (vit_g_6143 && vit_g_6143[-1] && *vit_g_6143) { ((int*)vit_g_6143)[4199] = 2; return; }   // C32: reuse => touch nothing
                    namespace esimd = sycl::ext::intel::esimd;
                    size_t index = (size_t)it.get_id(0) * 16u;
                    unsigned ch = CH, height = SA, width = SB, padded = SC;
                    unsigned cc = (unsigned)(index % ch), rest = (unsigned)(index / ch);
                    unsigned x = rest % padded, y = rest / padded;
                    esimd::simd<float,16> v(0.0f);
                    if (y < height && x < width)
                        v = esimd::block_load<float,16>((const float*)A + ((size_t)y * width + x) * ch + cc,
                                                       esimd::overaligned_tag<16>{});
                    esimd::block_store<float,16>((float*)C + index, v, esimd::overaligned_tag<16>{});
                });
            });
            return 0;
        }
        pg_push([=]() {
             const int* vit_g_6159 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
             GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                     if (vit_g_6159 && vit_g_6159[-1] && *vit_g_6159) { ((int*)vit_g_6159)[4199] = 2; return; }   // C32: reuse => touch nothing
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
    pg_push([=]() {
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
    pg_push([=]() {
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
namespace merge_heads_scaleloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_merge_heads_scale (no pragma, no division)
int xmx_rec_merge_heads_scale(int source, int dst, int scale, unsigned windows,
                              unsigned tokens, unsigned channels, unsigned heads,
                              unsigned epilogue, unsigned narrow) {
    using merge_heads_scaleloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using merge_heads_scaleloc::cr_add;
    if (!g_recording) FAILMSG("not recording");
    if (!windows || !tokens || !channels || !heads || (channels % 32u)) FAILMSG("bad merge_heads_scale dims");
    auto s = g_bufs.find(source), d = g_bufs.find(dst), sc = g_bufs.find(scale);
    if (s == g_bufs.end() || d == g_bufs.end() || sc == g_bufs.end()) FAILMSG("bad merge_heads_scale operand");
    const float* sp = (const float*)s->second.p;
    void* dp = d->second.p;
    const float* scp = (const float*)sc->second.p;
    const unsigned n = windows * tokens * channels;
    g_cmd_names.push_back(__func__);
    pg_push([=]() {
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
namespace unary2loc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_unary2 (no pragma, no division)
int xmx_rec_unary2(unsigned kind, int a, int b, int c, int d, int second, unsigned n,
                   unsigned channels, float p0, unsigned batch, unsigned sa,
                   unsigned sb, unsigned sc, unsigned k) {
    using unary2loc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using unary2loc::cr_add;
    if (!g_recording) FAILMSG("not recording");
    static int ustop = getenv("NR_U_STOP") ? atoi(getenv("NR_U_STOP")) : 0;
    if (ustop == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }
    pgraph_ids({a,b,c,d,second});   // PGRAPH touch-set (conservative: every operand id)
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
    pg_push([=]() {
         const int* vit_g_6313 = vit_gate(g_vit_run_cmd);   // C32 gate for THIS closure
         GQ->parallel_for(sycl::range((size_t)N), [=](sycl::item<1> it) {
                 if (vit_g_6313 && vit_g_6313[-1] && *vit_g_6313) { ((int*)vit_g_6313)[4199] = 2; return; }   // C32: reuse => touch nothing
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
    pgraph_ids({q,k,v,bias,out});   // PGRAPH touch-set (conservative: every operand id)
    a5_take_wa(g_cmds.size(), q, k, v, bias, out, batches, heads, merged);   // A5
        flop_note("winattn_scores",64u,64u,32u,batches); flop_note("winattn_attnv",64u,32u,64u,batches);
    // B5-5b SLICE 1 pairing (P2 take mechanism, record-time): a STASHED guarded qkv
    // whose target ids == this wa's q/k/v ids, same heads, windows*64 == qkv M, bias
    // present, adjacency (<=4 cmd gap: init records sit between) -> the qkv closure
    // no-ops and THIS closure becomes pack + ONE lfw::launch_lfw (qkv gemm + v5a
    // tail + attention stages resident; planes 1274/75/76 never exist, the wa
    // operand gathers and both gemm launches collapse into one kernel).
    size_t mywacmd = g_cmds.size();
    const bool lfw_pair = (lfw_on() || b6_on()) && g_lfw.valid && !g_lfw.confirmed &&
        q == g_lfw.q && k == g_lfw.k && v == g_lfw.v && heads == g_lfw.heads &&
        64u == g_lfw.tokens && windows * 64u == g_lfw.M && Bp != nullptr &&
        (mywacmd - g_lfw.qcmd) <= 4 &&
        !(getenv("NR_WA_STOP") && atoi(getenv("NR_WA_STOP")) != 0);
    if (lfw_pair && b6_on()) {
        // B6 candidate: store; NOTHING rewritten yet (if the quant/wres legs do
        // not match, the shipped chain runs untouched -- the rewrite happens at
        // wres-record time when all four records are confirmed).
        if (getenv("NR_LFW_DBG")) std::printf("[b6] CAND windows=%u M=%u wacmd=%zu\n", windows, g_lfw.M, mywacmd);
        g_b6 = B6Stash{}; g_b6.valid = true; g_b6.S = g_lfw; g_b6.windows = windows;
        g_b6.wacmd = mywacmd; g_b6.out1277 = out; g_b6.bias = Bp;
        g_lfw.confirmed = true;   // keep the qkv stash from double-pairing
    } else if (lfw_pair) {
        if (getenv("NR_LFW_DBG")) std::printf("[lfw] PAIRED windows=%u M=%u qcmd=%zu wacmd=%zu\n", windows, g_lfw.M, g_lfw.qcmd, mywacmd);
        g_lfw.confirmed = true;
        g_cmds[g_lfw.qcmd] = [](){};
        g_cmd_names[g_lfw.qcmd] = "int8_qkv(LFW-fused)";
        LfwStash S = g_lfw;
        const size_t na = (size_t)S.Mp * S.C;
        sycl::half* OutH = (sycl::half*)Out;
        const float* biasp = Bp;
        pg_push([=]() {
            int8_t* dAp = (int8_t*)pool_get(na);
            if (S.fq) {
                auto itsrc = g_bufs.find(S.qfq.src);
                if (itsrc == g_bufs.end()) throw std::runtime_error("lfw fused-gather: image src not live");
                 packdev::pack_a_fused_gather(*GQ, (const sycl::half*)itsrc->second.p, dAp,
                    (float*)S.as, (int)S.M, (int)S.Mp, (int)S.C, S.qfq.image_h, S.qfq.image_w, S.qfq.across, S.qfq.pad);
            } else
                {  packdev::pack_a(*GQ, S.Araw, dAp, (int)S.M, (int)S.Mp, (int)S.C); }
            // the qkv closure no-ops under the pair, so the weight-cache fill moves
            // HERE (Braw from the stash; cached_pack_b_i8 packs once, reuses after).
            int8_t* dBp = cached_pack_b_i8(S.b, S.Braw, (int)(3u * S.C), (int)S.C);
            lfw2::launch_lfw2(*GQ, dAp, dBp, OutH, S.as, S.bs, S.qs, biasp, windows, heads,
                              (sycl::half*)Q, (sycl::half*)Kk, (sycl::half*)V);
            pool_put(dAp);
        });
        return 0;
    }
    pg_push([=]() {
        // NR_WA_STOP=9 (section 100 P7 game-path ledger, time-only DIAGNOSTIC: the
        // frame output is garbage here by design -- same convention as NR_QKV_STOP
        // etc.): skip the whole window_attention resident/split chain to price the
        // family on the cgraph (game) path. NOT for deployment correctness.
        static int wastop = getenv("NR_WA_STOP") ? atoi(getenv("NR_WA_STOP")) : 0;
        if (wastop == 9) return;
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
        // P10b take-2: the resident kernel gathers the Q/K dpas tiles from the RAW
        // operands itself (the K side's pack_b16_t_b INTERLEAVED map is now byte-dump
        // PROVEN identical to the packed dBk; take-1 used the A map for K and the
        // 39-gate chain went RED -- the gate caught it, its job). The two pack
        // launches vanish on this path; the decision is hoisted ABOVE the packs
        // (the P9 lesson: never let a gate skip an operand producer it needs).
        static bool wares = !getenv("NR_WA_RES") || atoi(getenv("NR_WA_RES")) != 0;
        const bool wa_raw = wares && merged && Bp;
        if (!wa_raw) {
             packdev::pack_a16_b(*GQ, Q, dAq, 64, 64, 32, (int)batches);
             packdev::pack_b16_t_b(*GQ, Kk, dBk, 32, 64, (int)batches);
        }
        // section 99: v2 workgroup-SLM-tiled f16 gemm (v1 = one 16x16 tile per GLOBAL
        // load, 8 FLOP/byte = memory-bound; v2 stages BM=64 x BK=16 blocks in SLM with
        // 4x reuse). Mp=64 is a multiple of BM. NR_F16V1=1 = escape hatch.
        // P10 (section 100): the whole scores->softmax->attnV->merge MIDDLE of this
        // chain folds into ONE resident WG-per-batch kernel (wa_res_kernel.hpp;
        // bench_wa_res 9.2x at the frame shape, EXACT). dScores (16KB/batch f32),
        // dProbs and dAp (8KB/batch halfs) NEVER touch global; 2 of the 4 middle
        // launches vanish. The operand packs (dAq/dBk/dBv) stay -- they are the
        // promoted pack passes. Guards: merged==1, bias present (the frame's every
        // call has one; the null-bias case keeps the split chain). Escape NR_WA_RES=0.
        if (wa_raw) {
            static bool rawv2 = !getenv("NR_WA_RAWV") || atoi(getenv("NR_WA_RAWV")) != 0;   // P10c PROMOTED: every A/B pair beats RAW-QK by 0.8-1.2ms (the V pack launch + dBv round-trip gone); escape NR_WA_RAWV=0.
            if (!rawv2)packdev::pack_b16_b(*GQ, V, dBv, 64, 32, (int)batches);   // the span below is
                                                                       // skipped -- pack V FIRST (unless P10c RAW-V)
             wares::launch_wa_res(*GQ, Q, Kk, V, dBv, Bp, (sycl::half*)Out, batches, heads, rawv2);
            pool_put(dAq); pool_put(dBk); pool_put(dAp); pool_put(dBv);
            pool_put(dScores); pool_put(dProbs); pool_put(dCtx);
            return;
        }
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
        {  GQ->parallel_for(sycl::range((size_t)batches*64u),
                         smax::softmax_kernel()(dScores, dProbs, batches*64u, 64u, Bp, heads)); }
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
namespace gemm_window_residual_poolloc {
static inline float cr_mul(float x, float y) { return x * y; }
static inline float cr_add(float x, float y) { return x + y; }
}   // #148 com2: plain-operator shadows for xmx_rec_gemm_window_residual_pool (no pragma, no division)
int xmx_rec_gemm_window_residual_pool(int a, int b, int skip_out, int skip, int cosine,
                                      int pooled, unsigned M, unsigned N, unsigned K,
                                      unsigned flags, unsigned height, unsigned width,
                                      unsigned across, unsigned pad) {
    using gemm_window_residual_poolloc::cr_mul;   // #148 com2: only this recorder's kernels see the shadows
    using gemm_window_residual_poolloc::cr_add;
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
    pg_push([=]() {
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
    pgraph_ids({image,qkv,projection,target,bias,cosine,scale,pooled});   // PGRAPH touch-set (conservative: every operand id)
        flop_note("wb_qkv",windows*64u,96u,32u,1); flop_note("wb_scores",windows*64u,64u,32u,1); flop_note("wb_attnv",windows*64u,32u,64u,1); flop_note("wb_proj",windows*64u,32u,32u,1);
    pg_push([=]() {
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
            if (dKV) {
                // (A)-step1 工装 #153: the v4full stage ladder (stop_stage 5/6/8/9/10/11/12) writes its
                // witness into dKV but nothing brought it home. This download runs ONLY when NR_V2_STOP is
                // set, i.e. the kernel already stopped early -- no arithmetic changes on any shipping path.
                static bool s_stagedone = false;
                if (!s_stagedone) {
                    s_stagedone = true;
                    std::vector<sycl::half> hst((size_t)windows * 4096u);
                    ev_sync(GQ->memcpy(hst.data(), dKV, hst.size() * 2));
                    char nm[64]; std::snprintf(nm, sizeof nm, "wb_stage_%u.bin", st);
                    FILE *fp = std::fopen(nm, "wb");
                    if (fp) { std::fwrite(hst.data(), 2, hst.size(), fp); std::fclose(fp); }
                    std::printf("[dump] wbv4 stage=%u halves=%zu (windows=%u)\n", st, hst.size(), windows);
                }
                pool_put(dKV);
            }
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
            static int phstop = getenv("NR_WB_PH_STOP") ? atoi(getenv("NR_WB_PH_STOP")) : 0;   // P7 floor ledger: the v4ph (pool/head giants) route priced separately
            if (phstop == 9) return;
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
            if (getenv("NR_V2_FILL") && st != 0xFFFFu)GQ->parallel_for(sycl::range((size_t)windows * wbv2::WSL), [=](sycl::item<1> it){
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
        {  GQ->parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) {
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
        }); }
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
        {  GQ->parallel_for(sycl::range((size_t)windows*64u),
                         smax::softmax_kernel()(dScores, dProbs, windows*64u, 64u, Bp, 1u)); }
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
            {  GQ->parallel_for(sycl::range((size_t)rows), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
                namespace esimd = sycl::ext::intel::esimd;
                unsigned token = (unsigned)it.get_id(0);
                esimd::simd<float,32> v = esimd::block_load<float,32>(
                    dCtx + (size_t)token * 32u, esimd::overaligned_tag<16>{});
                esimd::block_store<sycl::half,32>(dAttended + (size_t)token * 32u,
                    esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(v)), esimd::overaligned_tag<16>{});
            }); }
        } else
        {  GQ->parallel_for(sycl::range((size_t)rows * C), [=](sycl::item<1> it) {   // merge, heads==1
            unsigned index = (unsigned)it.get_id(0);
            unsigned c = index % C, token = index / C;
            dAttended[index] = sycl::half(qr_e4m3(dCtx[(size_t)token * 32u + c]));
        }); }
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
        {  GQ->parallel_for(sycl::range(blk_elems), [=](sycl::item<1> it) {
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
        }); }
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
    sp_advance();   // B step 3: one ring step per producer group (no-op when off)
    if (!g_recording) FAILMSG("not recording");
    // NR_Q_STOP=9 (section 100 P7 floor ledger, time-only DIAGNOSTIC -- the frame
    // output is garbage by design here, same convention as the NR_*_STOP family;
    // NOT for deployment). The fused-pack quants are already no-ops; this prices
    // the SURVIVING split quants on the cgraph (game) path.
    static int qstop = getenv("NR_Q_STOP") ? atoi(getenv("NR_Q_STOP")) : 0;
    if (qstop == 9) { g_cmd_names.push_back(__func__);pg_push([](){}); return 0; }
    pgraph_ids({source,packed,scale});   // PGRAPH touch-set (conservative: every operand id)
    if (vit_reuse_level())               // C25: remember the opening QUANT of a ViT chain
        vit_note_quant(g_cmds.size(), source, packed, scale, M, K);
    if (!M || !K || K % 16u) FAILMSG("quant needs K a multiple of 16");
    auto s = g_bufs.find(source), p = g_bufs.find(packed), c = g_bufs.find(scale);
    if (s == g_bufs.end() || p == g_bufs.end() || c == g_bufs.end()) FAILMSG("bad quant operand");
    sycl::half* a = (sycl::half*)s->second.p;
    sycl::uint2* pk = (sycl::uint2*)p->second.p;
    float* sc = (float*)c->second.p;
    // B6-1 leg 2: the fused wa-candidate's expected quant (source == the wa Out id,
    // M/K match, adjacency) -> record ids; the wres record completes the pairing.
    if (g_b6.valid && !g_b6.qmatched && source == g_b6.out1277 &&
        M == g_b6.S.M && K == 64u && g_cmds.size() > g_b6.wacmd &&
        g_cmds.size() - g_b6.wacmd <= 3) {
        g_b6.qmatched = true; g_b6.quantcmd = g_cmds.size(); g_b6.pkid = packed; g_b6.scid = scale;
        if (getenv("NR_LFW_DBG")) std::printf("[b6] QUANT matched cmd=%zu\n", g_b6.quantcmd);
    }
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
            pg_push([](){});
            return 0;
        }
        if (foldon && g_pending_fold_slot != SIZE_MAX &&
            g_fold_slot[g_pending_fold_slot].cbuf == source &&
            g_cmds.size() == g_pending_fold_slot + 1)
            g_pending_fold_slot = SIZE_MAX;   // adjacent but NOT in-place: cancel the
                                              // pending fold, this pair keeps the split chain
    }
    // P8-i ledger split (section 100): NR_Q_STOP=8 skips the REAL ESIMD quantize
    // kernels only; =9 skips everything (memcpy no-ops too). The 0/8/9 triple
    // prices the two halves of the surviving-quant 12.0ms line.
    static int qstop8 = getenv("NR_Q_STOP") ? atoi(getenv("NR_Q_STOP")) : 0;
    auto fq = g_fused_quant.find(source);
    if (fq != g_fused_quant.end()) {   // section 99: the producer already wrote int8 + new_scale
        int asbuf = fq->second;
        if (qstop8 == 9) { pg_push([](){}); return 0; }   // (the entry guard already did 9; belt: skip the memcpy too)
        pg_push([=]() {
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
        if (qstop8 == 8) { g_cmd_names.push_back(__func__); pg_push([](){}); return 0; }  // P8-i ledger: skip the REAL quantize kernel
        // P8 census (section 100): who are the SURVIVING real quantizes (not the
        // fused-memcpy no-ops above)? NR_Q_STATS prints one line per live quant.
        if (getenv("NR_Q_STATS")) { static long qn=0; ++qn;
            if (qn<=100000) printf("[quant-live] #%ld M=%u K=%u src=%d pk=%d\n", qn, M, K, source, packed); }
        size_t mycmd = g_cmds.size();
        // WQFUSE (2026-10-30 16:5x, the user's "the comment says WHY -- then TAKE
        // the win" ruling hit the real prize): the census PROVED the 160 surviving
        // quantizes are WEIGHT quants -- src in {1271,1280,1282,1292,1295,1298,
        // 1303,1307} are all created BEFORE the first xmx_begin (gen 0 = init-era
        // planes the engine uploads once), and pk=1305 has ZERO recorder-op
        // readers (the consumers are init-family kernels that ran at init, when
        // the plain warm-up run already filled 1305). The frame graph therefore
        // re-quantizes the SAME bytes into a scratch NOTHING IN THE GRAPH READS
        // -- 160 launches of pure dead weight per frame. Guard = all three
        // buffers created at gen 0; capture-time the closure no-ops (the warm-up
        // plain run already executed it). The walk's 1301 + every gate is the
        // judge; NR_WQFUSE=0 = escape. NOT the qfuse_take axis (that mechanism
        // stays for the activation quants -- the 1272 family, all dissolved).
        static bool wqf = getenv("NR_WQFUSE") != nullptr && atoi(getenv("NR_WQFUSE")) != 0;   // WQ-CACHE v4: the id-key ABA FIX is CORRECT and stays, but the NR_WQVERIFY probe KILLED the premise: all 160 CACHE-DIFF ~97% STALE -- these src planes are REWRITTEN EVERY FRAME by the init family (xmx_int8_init records sit inside every frame in the plan census). The ecc000e -2.65 win was FAST-BUT-WRONG (voided, honest). The SAFE next shape (banked): producer-side fusion -- make the init-family recorders qfuse-consume the quant, or quantize INSIDE whatever writes 1271/1307; the round trips are still there, the cache premise was not.   // WQFUSE v1 VERDICT: 1301 MISMATCH -- pk is PER-FRAME fresh (init kernels read THIS frame's pk); skip unsafe as wired. Mechanism kept for the pointer-stable variant.
        auto genof = [&](int id) { auto it = g_bufs.find(id); return it == g_bufs.end() ? -1 : it->second.gen; };
        const bool wq_static = wqf && genof(source) >= 0 && genof(packed) >= 0 && genof(source) <= genof(packed);   // census: NO recorder op ever WRITES these 8 src planes (1271/1280/1282/1292/1295/1298/1303/1307 = engine-init content, frame-invariant)
        pg_push([=]() {
            // WQ-CACHE (the user's 17:2x scheme, built on the census facts): the
            // 160 weight quants re-quantize frame-invariant src planes. MISS (first
            // plain execution of a (src,M,K) key): run the quant for real, then
            // snapshot pk+sc into a persistent device cache. HIT (every later
            // frame AND every capture pass): memcpy cache -> pk/sc. Correct BY
            // CONSTRUCTION (the cache content = a real executed quant's output);
            // the recorded graph carries the memcpy nodes, so pk is refilled
            // every replay regardless of pointer stability.
            if (getenv("NR_Q_STATS")) printf("[quant-EXEC] M=%u K=%u src=%d pk=%d SCALE=%d PKP=%p SRCP=%p cmd=%zu\n", M, K, source, packed, scale, (void*)pk, (void*)a, mycmd);
            if (wq_static) {
                static std::unordered_map<uint64_t, std::pair<int8_t*, float*>> wqc;
                // WQ-CACHE v4 KEY FIX (the ABA root cause found by the 18:3x
                // decisive test: ecc000e ON = 1301 MISMATCH => the old win was
                // fast-but-wrong; the POINTER key aliased: sycl::malloc_device
                // RECYCLES addresses across recordings (140/150 SAME-PTR census),
                // so a src id's plane could FREE and a NEW plane could get the
                // SAME address -> false hit -> stale content. THE SAFE KEY =
                // (source buffer id, pk id, M, K): ids are monotonic (g_nextbuf++)
                // and NEVER reused, and the frame-invariance premise is per-id
                // (src id 1271 = the same init plane for the whole process).
                uint64_t kk = ((uint64_t)(uint32_t)source << 40) ^ ((uint64_t)(uint32_t)packed << 20) ^ ((uint64_t)M << 8) ^ (uint64_t)K;
                auto wc = wqc.find(kk);
                if (wc != wqc.end()) {
                    if (getenv("NR_WQVERIFY")) {   // run the REAL quant into a temp, diff vs cache content
                        int8_t* ref = (int8_t*)sycl::malloc_device((size_t)M * K, *GQ);
                        float* refs = (float*)sycl::malloc_device((size_t)M * 4u, *GQ);
                        qr_launch_esimd(*GQ, *GD, a, (sycl::uint2*)ref, refs, M, K);
                        GQ->wait();
                        std::vector<int8_t> ha((size_t)M*K), hb((size_t)M*K);
                         GQ->memcpy(ha.data(), ref, (size_t)M*K); GQ->memcpy(hb.data(), wc->second.first, (size_t)M*K); GQ->wait();
                        size_t bad=0; for(size_t i=0;i<ha.size();++i) if(ha[i]!=hb[i]) ++bad;
                        printf("[wq-verify] src=%d pk=%d M=%u K=%u CACHE-DIFF %zu/%zu %s\n", source, packed, M, K, bad, ha.size(), bad?"STALE":"ok");
                        sycl::free(ref,*GQ); sycl::free(refs,*GQ);
                    }
                     GQ->memcpy(pk, wc->second.first, (size_t)M * K);
                     GQ->memcpy(sc, wc->second.second, (size_t)M * 4u);
                    return;
                }
                qr_launch_esimd(*GQ, *GD, a, pk, sc, M, K);
                if (!g_graphrecording) {   // snapshot only from REAL executions
                    int8_t* cbuf = (int8_t*)sycl::malloc_device((size_t)M * K, *GQ);
                    float* csbuf = (float*)sycl::malloc_device((size_t)M * 4u, *GQ);
                     GQ->memcpy(cbuf, pk, (size_t)M * K);
                     GQ->memcpy(csbuf, sc, (size_t)M * 4u);
                    GQ->wait();
                    wqc[kk] = { cbuf, csbuf };
                }
                return;
            }
            qr_launch_esimd(*GQ, *GD, a, pk, sc, M, K);
        });
        // S6-1a (NR_S6_FFN): a REAL quantize closure can arm / advance an FFN chain.
        // The dissolved ones (g_fused_quant memcpy legs, NR_Q_STOP branches) never get
        // here -- a chain containing one simply never completes (conservative).
        s6_note_quant(g_cmds.size() - 1, source, packed, scale, M, K);
        if (qfuse_on())   // register for a downstream gemm to dissolve us (P2 fusion)
            { QuantFused qf2{ g_cmds.size()-1, source, scale, M, K };
              qf2.pkp = (void*)pk; qf2.scp = (void*)sc;
              g_quant_pk[packed] = qf2; }   // QFALIAS: + device pointers (the engine ALIASES
                                            // pk/scale under DIFFERENT ids: the pointer census
                                            // PROVED gemmB's a=1273 AP == quant pk=1305 PKP
                                            // (FFFFB80225800000) and a_scale=1274 aliases the
                                            // quant's scale buf 1306 -- id-lookup misses, the
                                            // POINTER is the real wire.)
        return 0;
    }
    s6_note_quant(g_cmds.size(), source, packed, scale, M, K);   // S6-1a (see above)
    a5_note_quant(g_cmds.size(), source, packed, scale, M, K);   // A5
    pg_push([=]() {
         {
        // C91 (knife B step 1): band-internal scales. Default OFF -> byte-identical shipped
        // path. The gate is pinned to the LIVE shape of the mid-chain QUANT in plan chains
        // 25/33 (src 1277 -> pk 1272, sc 1273, M=768, K=512) -- rule 216: the gate must come
        // from the engine's real arguments, never from a bench form. nband = K/128.
        const bool band = band_scale_on() && M == 768u && K == 512u;
        if (getenv("NR_BAND_DBG"))
            std::printf("[band-quant] band=%d M=%u K=%u nband=%u src=%d pk=%d sc=%d\n",
                        (int)band, M, K, K / 128u, source, packed, scale);
        if (band) qr_launch(*GQ, *GD, qr_kernel(), a, pk, sc, M * 4u, 128u, 0u, 0u, 0u, 0u, 0u, nullptr, nullptr);
        else      qr_launch(*GQ, *GD, qr_kernel(), a, pk, sc, M, K, 0u, 0u, 0u, 0u, 0u, nullptr, nullptr);
    }
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    static int ustop = getenv("NR_U_STOP") ? atoi(getenv("NR_U_STOP")) : 0;
    if (ustop == 9) { g_cmd_names.push_back(__func__); pg_push([](){}); return 0; }
    if (!count || (count & 3u)) FAILMSG("unary32 count must be a multiple of 4");
    auto s = g_bufs.find(source), d = g_bufs.find(dst);
    if (s == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad unary operand");
    sycl::float4* sp = (sycl::float4*)s->second.p;
    sycl::float4* dp = (sycl::float4*)d->second.p;
    unsigned n4 = count / 4u;
    g_cmd_names.push_back(__func__);
    pg_push([=]() {
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
    static int ustop = getenv("NR_U_STOP") ? atoi(getenv("NR_U_STOP")) : 0;
    if (ustop == 9) { g_cmd_names.push_back(__func__); pg_push([](){}); return 0; }
    if (!count || !cols || (count % cols)) FAILMSG("unary_i8 needs count a multiple of cols");
    auto s = g_bufs.find(source), c = g_bufs.find(scale), d = g_bufs.find(dst);
    if (s == g_bufs.end() || c == g_bufs.end() || d == g_bufs.end()) FAILMSG("bad unary_i8 operand");
    const signed char* sp = (const signed char*)s->second.p;
    const float* scp = (const float*)c->second.p;
    float* dp = (float*)d->second.p;
    g_cmd_names.push_back(__func__);
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
    pg_push([=]() {
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
