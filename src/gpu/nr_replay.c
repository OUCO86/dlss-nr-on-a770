/* nr_replay.c — the network, without the walk.
 *
 * The resident frame is built by walking the recovered graph in Python: for every pass
 * `nr_frame_resident` works out the shapes and calls one `xmx_rec_*` recorder. None of
 * that reasoning is needed twice, and none of it needs the host once it has happened —
 * which is what `tools/dump_plan.py` and the plan it writes are for.
 *
 * This walks the plan instead. It is the same library, the same shaders and the same
 * calls; only the walking has moved, from a Python that runs every frame to a table that
 * was filled in once. What that buys is what Mochi's nr_native_plan.cpp buys: no
 * interpreter, no per-frame shape arithmetic, and one `xmx_graph_run` per frame.
 *
 * The plan's blobs are the network's initial state — the weights, and the frame's input
 * as it was the moment the recording was made. Putting them back exactly is what makes
 * the first replayed frame comparable with the recorded one, bit for bit.
 */

#include <stdint.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <dlfcn.h>
#endif

#include "nr_plan.h"

/* Built as a library for the bridge, and as a program for the bench: the program is the
 * proof that the table replays, and it is the same code either way. */
#define NR_NET_BUILD
#include "nr_net.h"

/* The plan, compiled in. See tools/dump_plan.py: `emit_c` writes these. */
extern const struct nr_step nr_plan_steps[];
extern const unsigned nr_plan_step_count;
extern const struct nr_buffer nr_plan_buffers[];
extern const unsigned nr_plan_buffer_count;
extern const struct nr_blob nr_plan_blobs[];
extern const unsigned nr_plan_blob_count;
extern const char *const nr_plan_text[];
extern const char *const nr_plan_names[];
extern const char *const nr_plan_signatures[];
extern const unsigned nr_plan_extent[2];

/* ---- the library, found rather than linked ----------------------------------
 *
 * Not linked against, because the build that makes it is not this one: libxmx is built
 * by the project's own Makefile, and a replayer that had to be rebuilt alongside it
 * would not be able to run against a build already in the tree.
 */
static void *handle;

static int (*f_init)(const char *);
static int (*f_res_init)(const char *, const char *, const char *, const char *,
			 const char *, const char *);
static int (*f_rows_init)(const char *);
static int (*f_staged32_init)(const char *, const char *);
static int (*f_tiled32_init)(const char *);
static int (*f_window_init)(const char *, unsigned);
static int (*f_ffn_init)(const char *);
static int (*f_int8_init)(const char *);
static int (*f_int8_fused_init)(const char *);
static int (*f_int8_residual_init)(const char *);
static int (*f_quant_init)(const char *);
static int (*f_global_attention_init)(const char *);
static int (*f_window_block_init)(const char *);
static int (*f_specialize)(unsigned);

static int (*f_buf_create_kind)(unsigned long long, int);
static int (*f_buf_upload)(int, const void *, unsigned long long, unsigned long long);
static int (*f_buf_download)(int, void*, unsigned long long, unsigned long long);
static int (*f_buf_download)(int, void *, unsigned long long, unsigned long long);
static int (*f_buf_zero)(int);
static int (*f_buf_destroy)(int);

static int (*f_begin)(void);
static int (*f_abort)(void);
static int (*f_submit)(void);
static int (*f_graph_capture)(void);
static int (*f_graph_run)(int);
static int (*f_graph_destroy)(int);

static int (*f_rec_ffn_stem)(int, int, int, int, int, int, unsigned, unsigned);
static int (*f_rec_window_block)(int, int, int, int, int, int, int, int,
				 unsigned, unsigned, unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_ffn)(int, int, int, int, int, int,
			unsigned, unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_unary)(unsigned, int, int, int, int, unsigned, unsigned, float,
			  unsigned, unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm)(int, int, int, unsigned, unsigned, unsigned, unsigned, unsigned,
			 unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned,
			 unsigned, unsigned);
static int (*f_rec_gemm_residual)(int, int, int, int, int,
				  unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_qkv_window)(int, int, int, int, int, int,
				    unsigned, unsigned, unsigned, unsigned, unsigned,
				    unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_window_attention)(int, int, int, int, int, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_window_residual)(int, int, int, int, int,
					 unsigned, unsigned, unsigned, unsigned, unsigned,
					 unsigned, unsigned, unsigned);
static int (*f_rec_gemm_qkv)(int, int, int, int, int, int,
			     unsigned, unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_global_attention)(int, int, int, int, unsigned, unsigned, unsigned);
static int (*f_rec_unary2)(unsigned, int, int, int, int, int, unsigned, unsigned, float,
			   unsigned, unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_ffn_merge)(int, int, int, int, int, int, int,
			      unsigned, unsigned, unsigned, unsigned);
/* The integer path. The plan recorded with the game's switches on (dump_plan.py calls
 * game_settings.apply()) asks for these by name; without them the replayer fell
 * through to the default and refused a plan no float graph ever made. The signatures
 * are xmx_rec_quant / _quant_window / _gemm_int8 / _gemm_int8_batched /
 * _gemm_int8_residual / _gemm_window_int8_residual / _gemm_int8_qkv / _gemm_int8_fused
 * in libxmx.c, kept in the same argument order. */
static int (*f_rec_quant)(int, int, int, unsigned, unsigned);
static int (*f_rec_quant_window)(int, int, int, unsigned, unsigned,
				 unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_int8)(int, int, int, int, int,
			      unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_int8_batched)(int, int, int, int, int,
				      unsigned, unsigned, unsigned, unsigned,
				      unsigned, unsigned, unsigned, unsigned,
				      unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_int8_residual)(int, int, int, int, int, int, int,
				       unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_window_int8_residual)(int, int, int, int, int, int, int,
					      unsigned, unsigned, unsigned, unsigned,
					      unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_int8_qkv)(int, int, int, int, int, int, int, int,
				  unsigned, unsigned, unsigned, unsigned, unsigned);
static int (*f_rec_gemm_int8_fused)(int, int, int, int, int,
				    unsigned, unsigned, unsigned, unsigned);

static const char *(*f_error)(void);
/* The fused passes and the import they need: Mochi's Kind::Pre and Kind::Post,
 * which put the colour into the network and the network's answer back into the
 * game's own buffer, so that no pixel crosses to the host. */
static int (*f_buf_import)(unsigned long long, unsigned long long);
static int (*f_prepost_init)(const char *, const char *);
static int (*f_rec_pre)(int, int, int, int, int, unsigned, unsigned, unsigned,
			   unsigned, unsigned, unsigned, unsigned, int);
static int (*f_rec_post)(int, int, int, int, int, int, unsigned, unsigned, unsigned,
			   unsigned, unsigned, unsigned);
/* The game's own fence, imported, so the graph waits for the frame on the device
 * rather than the host waiting and then submitting. */
static int (*f_sem_import)(unsigned long long, int);
/* The game's fence is a shared D3D12 fence, which is a different object from the
 * opaque win32 handle the layer exports: xmx_sem_import_fence is the import for it.
 * Taken by name and not required, because a libxmx older than the call still runs
 * every path except this one. */
static int (*f_sem_import_fence)(unsigned long long);
static unsigned long long (*f_sem_value)(int);
static int (*f_extmem_wait)(int, unsigned long long);
/* The device the network runs on, given out so the host's own Vulkan side can be
 * built on it rather than beside it. */
static unsigned long long (*f_inst)(void);
static unsigned long long (*f_phys)(void);
static unsigned long long (*f_dev)(void);
static unsigned long long (*f_que)(void);
static unsigned (*f_fam)(void);
/* Only a probe waits: a frame is ordered by semaphores, and this would cost the
 * whole point of running beside the game. */
static int (*f_idle)(void);
/* libxmx already times every pass with timestamp queries and keeps the per-pass durations
 * (`xmx_profile`, `collect`, `prof_each`); nothing on this side ever asked for them, so
 * the three-frame cycle -- one frame in three taking 108ms against 62ms for the others --
 * could only be seen as a total. These are what it takes to see which passes. */
static int (*f_prof_on)(int);
static void (*f_prof_reset)(void);
static unsigned (*f_prof_n)(void);
static double (*f_prof_ms)(unsigned);
static unsigned (*f_prof_kind)(unsigned);
/* The submit's three costs, which the pass timings cannot see: a frame that is slow in
 * `vkQueueSubmit` has every one of its passes looking quick, and that is exactly what the
 * frame totals showed -- 62ms a frame with nothing above 2.6ms in any of the 417. */
static int (*f_time_on)(int);
static void (*f_time_reset)(void);
static void (*f_time_report)(double*, unsigned);
static const char *(*f_device)(void);

/* A game is a windowed process and its stderr goes nowhere, so a run that fails
 * inside the walk has been unreadable: the reason was printed and then lost. This
 * is the same text, written beside the plan as well, so that a frame that did not
 * come up can be read afterwards instead of guessed at. */
static FILE *diag = NULL;

static void diagf(const char *fmt, ...)
{
	va_list ap;
	if (diag) {
		va_start(ap, fmt);
		vfprintf(diag, fmt, ap);
		va_end(ap);
		fflush(diag);
	}
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
}

static double now_ms(void)
{
#ifdef _WIN32
	LARGE_INTEGER at, rate;
	QueryPerformanceCounter(&at);
	QueryPerformanceFrequency(&rate);
	return 1000.0 * (double)at.QuadPart / (double)rate.QuadPart;
#else
	struct timespec at;
	clock_gettime(CLOCK_MONOTONIC, &at);
	return 1000.0 * at.tv_sec + 1e-6 * at.tv_nsec;
#endif
}

static void *symbol(const char *name)
{
#ifdef _WIN32
	return (void *)(intptr_t)GetProcAddress((HMODULE)handle, name);
#else
	return dlsym(handle, name);
#endif
}

#define GRAB(field, name)                                                      \
	do {                                                                   \
		if (!(*(void **)&field = symbol(name))) {                      \
			diagf("libxmx has no %s\n", name);           \
			return -1;                                             \
		}                                                              \
	} while (0)

static int open_library(const char *path)
{
#ifdef _WIN32
	handle = (void *)LoadLibraryA(path);
#else
	handle = dlopen(path, RTLD_NOW);
#endif
	if (!handle) {
		diagf("cannot load %s\n", path);
		return -1;
	}
	GRAB(f_init, "xmx_init");
	GRAB(f_res_init, "xmx_res_init");
	GRAB(f_rows_init, "xmx_rows_init");
	GRAB(f_staged32_init, "xmx_staged32_init");
	GRAB(f_tiled32_init, "xmx_tiled32_init");
	GRAB(f_window_init, "xmx_window_init");
	GRAB(f_ffn_init, "xmx_ffn_init");
	GRAB(f_int8_init, "xmx_int8_init");
	GRAB(f_int8_fused_init, "xmx_int8_fused_init");
	GRAB(f_int8_residual_init, "xmx_int8_residual_init");
	GRAB(f_quant_init, "xmx_quant_init");
	GRAB(f_global_attention_init, "xmx_global_attention_init");
	GRAB(f_window_block_init, "xmx_window_block_init");
	GRAB(f_specialize, "xmx_specialize");
	GRAB(f_buf_create_kind, "xmx_buf_create_kind");
	GRAB(f_buf_import, "xmx_buf_import");
	GRAB(f_prepost_init, "xmx_prepost_init");
	GRAB(f_rec_pre, "xmx_rec_pre");
	GRAB(f_rec_post, "xmx_rec_post");
	GRAB(f_sem_import, "xmx_sem_import");
	*(void **)&f_sem_import_fence = symbol("xmx_sem_import_fence");
	*(void **)&f_inst = symbol("xmx_vk_instance");
	*(void **)&f_phys = symbol("xmx_vk_physical");
	*(void **)&f_dev = symbol("xmx_vk_device");
	*(void **)&f_que = symbol("xmx_vk_queue");
	*(void **)&f_fam = symbol("xmx_vk_family");
	*(void **)&f_idle = symbol("xmx_idle");
	*(void **)&f_prof_on = symbol("xmx_profile");
	*(void **)&f_prof_reset = symbol("xmx_profile_reset");
	*(void **)&f_prof_n = symbol("xmx_profile_each_count");
	*(void **)&f_prof_ms = symbol("xmx_profile_each_ms");
	*(void **)&f_prof_kind = symbol("xmx_profile_each_kind");
	*(void **)&f_time_on = symbol("xmx_time_submit");
	*(void **)&f_time_reset = symbol("xmx_time_reset");
	*(void **)&f_time_report = symbol("xmx_time_report");
	*(void **)&f_sem_value = symbol("xmx_sem_value");
	GRAB(f_extmem_wait, "xmx_extmem_wait");
	GRAB(f_buf_upload, "xmx_buf_upload");
	GRAB(f_buf_download, "xmx_buf_download");
	GRAB(f_buf_zero, "xmx_buf_zero");
	GRAB(f_buf_destroy, "xmx_buf_destroy");
	GRAB(f_begin, "xmx_begin");
	GRAB(f_abort, "xmx_abort");
	GRAB(f_submit, "xmx_submit");
	GRAB(f_graph_capture, "xmx_graph_capture");
	GRAB(f_graph_run, "xmx_graph_run");
	GRAB(f_graph_destroy, "xmx_graph_destroy");
	GRAB(f_rec_ffn_stem, "xmx_rec_ffn_stem");
	GRAB(f_rec_window_block, "xmx_rec_window_block");
	GRAB(f_rec_ffn, "xmx_rec_ffn");
	GRAB(f_rec_unary, "xmx_rec_unary");
	GRAB(f_rec_gemm, "xmx_rec_gemm");
	GRAB(f_rec_gemm_residual, "xmx_rec_gemm_residual");
	GRAB(f_rec_gemm_qkv_window, "xmx_rec_gemm_qkv_window");
	GRAB(f_rec_window_attention, "xmx_rec_window_attention");
	GRAB(f_rec_gemm_window_residual, "xmx_rec_gemm_window_residual");
	GRAB(f_rec_gemm_qkv, "xmx_rec_gemm_qkv");
	GRAB(f_rec_global_attention, "xmx_rec_global_attention");
	GRAB(f_rec_unary2, "xmx_rec_unary2");
	GRAB(f_rec_ffn_merge, "xmx_rec_ffn_merge");
	GRAB(f_rec_quant, "xmx_rec_quant");
	GRAB(f_rec_quant_window, "xmx_rec_quant_window");
	GRAB(f_rec_gemm_int8, "xmx_rec_gemm_int8");
	GRAB(f_rec_gemm_int8_batched, "xmx_rec_gemm_int8_batched");
	GRAB(f_rec_gemm_int8_residual, "xmx_rec_gemm_int8_residual");
	GRAB(f_rec_gemm_window_int8_residual, "xmx_rec_gemm_window_int8_residual");
	GRAB(f_rec_gemm_int8_qkv, "xmx_rec_gemm_int8_qkv");
	GRAB(f_rec_gemm_int8_fused, "xmx_rec_gemm_int8_fused");
	GRAB(f_error, "xmx_error");
	GRAB(f_device, "xmx_device");
	return 0;
}

/* A float is carried in the plan as the bits of a float. Neither side ever makes a
 * floating-point number of its own out of them, so no rounding happens on the way. */
static float as_float(long long carried)
{
	int bits = (int)(unsigned int)(carried & 0xFFFFFFFFu);
	float value;
	memcpy(&value, &bits, sizeof value);
	return value;
}

/* ---- one replay ------------------------------------------------------------ */

typedef struct {
	int *ids;                  /* the plan's buffer number -> the device's id */
	unsigned char *bytes;      /* the plan's own file, held for the blobs */
	unsigned long long size;
	int graph;                 /* what the last capture handed back */
	int failed;

	/* Which buffers are the frame's way in and its way out, found by their kind
	 * rather than by number: the plan numbers them in the order they were made and
	 * that order is not a promise. HOST_WRITE is the features, HOST_READ is the
	 * head — one of each, or the plan is not one this can run. */
	int features;
	int head;
	void *in;                  /* host side of the features */
	float *out;                /* host side of the head */
	char *why;

	/* The fused path: the game's own colour, motion and answer, imported by handle
	 * rather than copied, and the two passes that stand either side of the plan.
	 * Set by nr_net_fuse before the open, acted on while the plan is recorded. */
	int fused;
	int colour, motion, result, plan, table, history;
	int pre_done, post_done;
} replay;

/* What nr_net_fuse was asked for. Kept outside a replay because it is set before
 * one exists: the open is what can act on it, and only while recording. */
static struct {
	int asked;
	unsigned long long colour, motion, result;
	unsigned long long colour_bytes, motion_bytes, result_bytes;
	unsigned pitch, source_h, source_w;
	float exposure, intensity, confidence;
	const void *plan;
	unsigned long long plan_bytes;
	const float *table;
	char folder[1024];
} fuse;

void nr_net_fuse(unsigned long long colour, unsigned long long motion,
		  unsigned long long result, unsigned long long colour_bytes,
		  unsigned long long motion_bytes, unsigned long long result_bytes,
		  unsigned pitch, unsigned source_h, unsigned source_w,
		  float exposure, float intensity, float confidence,
		  const void *plan, unsigned long long plan_bytes, const float *table)
{
	fuse.asked = 1;
	fuse.colour = colour;
	fuse.motion = motion;
	fuse.result = result;
	fuse.colour_bytes = colour_bytes;
	fuse.motion_bytes = motion_bytes;
	fuse.result_bytes = result_bytes;
	fuse.pitch = pitch;
	fuse.source_h = source_h;
	fuse.source_w = source_w;
	fuse.exposure = exposure;
	fuse.intensity = intensity;
	fuse.confidence = confidence;
	fuse.plan = plan;
	fuse.plan_bytes = plan_bytes;
	fuse.table = table;
}

/* The fence is the game's and the handle does not change, so it is imported once:/n * a semaphore imported again every frame is a semaphore leaked every frame. */
static int wait_id = -1;
static unsigned long long wait_handle;

int nr_net_wait(nr_net *n, unsigned long long handle, unsigned long long value)
{
	replay *r = (replay *)n;
	if (!r || !handle)
		return -1;
	/* The wrong handle type here is not a failure, it is a hang: an opaque import of
	 * a D3D12 fence waits for a counter that never moves, and the submit sits until
	 * the device is lost. So the import has to be the fence kind, and the counter has
	 * to already be past the value -- the game's queue signalled it before the slot
	 * was called, and a counter behind the value is a wait that cannot end. */
	if (!f_sem_import_fence)
		return r->why = "the library cannot import a D3D12 fence", -1;
	if (wait_id < 0 || wait_handle != handle) {
		wait_id = f_sem_import_fence(handle);
		wait_handle = handle;
		if (wait_id < 0)
			return r->why = "the game's fence would not import", -1;
	}
	if (f_sem_value && f_sem_value(wait_id) < value)
		return r->why = "the game's fence is behind the frame it is being waited on", -1;
	return f_extmem_wait(wait_id, value);
}

/* Whether the two fused passes really are in the recording. `nr_net_fuse` is a
 * request and not an answer: it is honoured while the plan is walked, and a walk that
 * could not honour it leaves a network without them. A host that assumed rather than
 * asked ran the fused path against a network that had never been fused -- its staging
 * skipped, its answer nowhere -- which is how a slot came to hang for a minute on
 * 2026-10-13. */
int nr_net_fused(nr_net *n)
{
	replay *r = (replay *)n;
	return (r && r->fused) ? 1 : 0;
}

static int upload_blobs(replay *r)
{
	for (unsigned i = 0; i < nr_plan_blob_count; i++) {
		const struct nr_blob *b = &nr_plan_blobs[i];
		if ((unsigned)b->buffer >= nr_plan_buffer_count)
			continue;
		if (b->at + b->length > r->size) {
			diagf("blob %u runs past the plan file\n", i);
			return -1;
		}
		if (f_buf_upload(r->ids[b->buffer], r->bytes + b->at,
				 b->offset, b->length) != 0) {
			diagf("upload into buffer %u: %s\n", b->buffer,
				f_error() ? f_error() : "");
			return -1;
		}
	}
	return 0;
}

static int step(replay *r, const struct nr_step *s)
{
	const long long *a = s->args;

	switch (s->op) {
	case OP_BUF:
		/* The plan numbers buffers in the order they were made; the device numbers
		 * them its own way, and this is the only place the two are brought
		 * together. */
		if ((unsigned)a[0] >= nr_plan_buffer_count)
			return -1;
		r->ids[a[0]] = f_buf_create_kind((unsigned long long)a[1], (int)a[2]);
		return r->ids[a[0]] < 0 ? -1 : 0;

	case OP_UP:
		return 0;          /* the blobs carry these, put back in one go */

	case OP_XMX_BUF_PTR:
		/* The host wrote through a mapped pointer. This replayer writes with
		 * `xmx_buf_upload` instead — the same bytes, into the same buffer — so
		 * there is nothing to do here. Keeping the row is what makes the plan a
		 * faithful record of what the Python did. */
		return 0;

	case OP_XMX_BUF_ZERO:
		return f_buf_zero(r->ids[a[0]]);

	case OP_XMX_BUF_DESTROY:
		f_buf_destroy(r->ids[a[0]]);
		r->ids[a[0]] = -1;
		return 0;

	case OP_XMX_BEGIN:
		return f_begin();

	case OP_XMX_ABORT:
		/* The scratch discovery's recording, thrown away. It is in the plan because
		 * the walk really made it, and because what follows — the recording that is
		 * kept — cannot begin until it is gone. */
		return f_abort();

	case OP_XMX_SUBMIT:
		return f_submit();

	case OP_XMX_GRAPH_CAPTURE:
		r->graph = f_graph_capture();
		return r->graph < 0 ? -1 : 0;

	case OP_XMX_GRAPH_RUN:
		/* The plan says which graph ran, as the number it had that once. This run
		 * has its own numbers, so what runs is what the last capture handed back. */
		return f_graph_run(r->graph) < 0 ? -1 : 0;

	case OP_XMX_GRAPH_DESTROY:
		return f_graph_destroy(r->graph);

	case OP_XMX_FFN_INIT:
		return f_ffn_init(nr_plan_text[s->text]);
	case OP_XMX_WINDOW_BLOCK_INIT:
		return f_window_block_init(nr_plan_text[s->text]);
	case OP_XMX_WINDOW_INIT:
		return f_window_init(nr_plan_text[s->text], (unsigned)a[1]);
	case OP_XMX_GLOBAL_ATTENTION_INIT:
		return f_global_attention_init(nr_plan_text[s->text]);
	case OP_XMX_INT8_INIT:
		return f_int8_init(nr_plan_text[s->text]);
	case OP_XMX_INT8_FUSED_INIT:
		return f_int8_fused_init(nr_plan_text[s->text]);
	case OP_XMX_INT8_RESIDUAL_INIT:
		return f_int8_residual_init(nr_plan_text[s->text]);
	case OP_XMX_QUANT_INIT:
		return f_quant_init(nr_plan_text[s->text]);

	case OP_XMX_REC_FFN_STEM:
		return f_rec_ffn_stem(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
				      r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
				      (unsigned)a[6], (unsigned)a[7]);
	case OP_XMX_REC_WINDOW_BLOCK:
		return f_rec_window_block(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					  r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
					  r->ids[a[6]], r->ids[a[7]],
					  (unsigned)a[8], (unsigned)a[9], (unsigned)a[10],
					  (unsigned)a[11], (unsigned)a[12], (unsigned)a[13]);
	case OP_XMX_REC_FFN:
		return f_rec_ffn(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]], r->ids[a[3]],
				 r->ids[a[4]], r->ids[a[5]], (unsigned)a[6], (unsigned)a[7],
				 (unsigned)a[8], (unsigned)a[9], (unsigned)a[10]);
	case OP_XMX_REC_UNARY:
		return f_rec_unary((unsigned)a[0], r->ids[a[1]], r->ids[a[2]],
				   r->ids[a[3]], r->ids[a[4]], (unsigned)a[5],
				   (unsigned)a[6], as_float(a[7]), (unsigned)a[8],
				   (unsigned)a[9], (unsigned)a[10], (unsigned)a[11],
				   (unsigned)a[12]);
	case OP_XMX_REC_GEMM:
		return f_rec_gemm(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
				  (unsigned)a[3], (unsigned)a[4], (unsigned)a[5],
				  (unsigned)a[6], (unsigned)a[7], (unsigned)a[8],
				  (unsigned)a[9], (unsigned)a[10], (unsigned)a[11],
				  (unsigned)a[12], (unsigned)a[13], (unsigned)a[14],
				  (unsigned)a[15], (unsigned)a[16]);
	case OP_XMX_REC_GEMM_RESIDUAL:
		return f_rec_gemm_residual(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					   r->ids[a[3]], r->ids[a[4]], (unsigned)a[5],
					   (unsigned)a[6], (unsigned)a[7], (unsigned)a[8]);
	case OP_XMX_REC_GEMM_QKV_WINDOW:
		return f_rec_gemm_qkv_window(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					     r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
					     (unsigned)a[6], (unsigned)a[7], (unsigned)a[8],
					     (unsigned)a[9], (unsigned)a[10],
					     (unsigned)a[11], (unsigned)a[12],
					     (unsigned)a[13], (unsigned)a[14]);
	case OP_XMX_REC_WINDOW_ATTENTION:
		return f_rec_window_attention(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					      r->ids[a[3]], r->ids[a[4]], (unsigned)a[5],
					      (unsigned)a[6], (unsigned)a[7]);
	case OP_XMX_REC_GEMM_WINDOW_RESIDUAL:
		return f_rec_gemm_window_residual(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
						  r->ids[a[3]], r->ids[a[4]],
						  (unsigned)a[5], (unsigned)a[6],
						  (unsigned)a[7], (unsigned)a[8],
						  (unsigned)a[9], (unsigned)a[10],
						  (unsigned)a[11], (unsigned)a[12]);
	case OP_XMX_REC_GEMM_QKV:
		return f_rec_gemm_qkv(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
				      r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
				      (unsigned)a[6], (unsigned)a[7], (unsigned)a[8],
				      (unsigned)a[9], (unsigned)a[10]);
	case OP_XMX_REC_GLOBAL_ATTENTION:
		return f_rec_global_attention(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					      r->ids[a[3]], (unsigned)a[4], (unsigned)a[5],
					      (unsigned)a[6]);
	case OP_XMX_REC_UNARY2:
		return f_rec_unary2((unsigned)a[0], r->ids[a[1]], r->ids[a[2]],
				    r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
				    (unsigned)a[6], (unsigned)a[7], as_float(a[8]),
				    (unsigned)a[9], (unsigned)a[10], (unsigned)a[11],
				    (unsigned)a[12], (unsigned)a[13]);
	case OP_XMX_REC_FFN_MERGE:
		return f_rec_ffn_merge(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
				       r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
				       r->ids[a[6]], (unsigned)a[7], (unsigned)a[8],
				       (unsigned)a[9], (unsigned)a[10]);
	case OP_XMX_REC_QUANT:
		return f_rec_quant(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
				   (unsigned)a[3], (unsigned)a[4]);
	case OP_XMX_REC_QUANT_WINDOW:
		return f_rec_quant_window(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					  (unsigned)a[3], (unsigned)a[4], (unsigned)a[5],
					  (unsigned)a[6], (unsigned)a[7], (unsigned)a[8]);
	case OP_XMX_REC_GEMM_INT8:
		return f_rec_gemm_int8(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
				       r->ids[a[3]], r->ids[a[4]], (unsigned)a[5],
				       (unsigned)a[6], (unsigned)a[7], (unsigned)a[8]);
	case OP_XMX_REC_GEMM_INT8_BATCHED:
		return f_rec_gemm_int8_batched(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					       r->ids[a[3]], r->ids[a[4]],
					       (unsigned)a[5], (unsigned)a[6],
					       (unsigned)a[7], (unsigned)a[8],
					       (unsigned)a[9], (unsigned)a[10],
					       (unsigned)a[11], (unsigned)a[12],
					       (unsigned)a[13], (unsigned)a[14],
					       (unsigned)a[15], (unsigned)a[16]);
	case OP_XMX_REC_GEMM_INT8_RESIDUAL:
		return f_rec_gemm_int8_residual(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
						r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
						r->ids[a[6]], (unsigned)a[7],
						(unsigned)a[8], (unsigned)a[9],
						(unsigned)a[10]);
	case OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL:
		return f_rec_gemm_window_int8_residual(r->ids[a[0]], r->ids[a[1]],
						r->ids[a[2]], r->ids[a[3]], r->ids[a[4]],
						r->ids[a[5]], r->ids[a[6]],
						(unsigned)a[7], (unsigned)a[8],
						(unsigned)a[9], (unsigned)a[10],
						(unsigned)a[11], (unsigned)a[12],
						(unsigned)a[13], (unsigned)a[14]);
	case OP_XMX_REC_GEMM_INT8_QKV:
		return f_rec_gemm_int8_qkv(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					   r->ids[a[3]], r->ids[a[4]], r->ids[a[5]],
					   r->ids[a[6]], r->ids[a[7]], (unsigned)a[8],
					   (unsigned)a[9], (unsigned)a[10],
					   (unsigned)a[11], (unsigned)a[12]);
	case OP_XMX_REC_GEMM_INT8_FUSED:
		return f_rec_gemm_int8_fused(r->ids[a[0]], r->ids[a[1]], r->ids[a[2]],
					     r->ids[a[3]], r->ids[a[4]], (unsigned)a[5],
					     (unsigned)a[6], (unsigned)a[7],
					     (unsigned)a[8]);
	default:
		diagf("the plan asks for %s, which this replayer does not "
			"know how to make\n", nr_plan_names[s->op]);
		return -1;
	}
}

/* Which buffers are the frame's way in and out, by kind rather than by number.
 * build() needs them before the walk is over, which is why this is not ends(). */
static void find_frame(replay *r)
{
	if (r->features >= 0 && r->head >= 0)
		return;
	for (unsigned i = 0; i < nr_plan_buffer_count; i++) {
		if (nr_plan_buffers[i].kind == 2 && r->features < 0)
			r->features = (int)i;
		else if (nr_plan_buffers[i].kind == 1 && r->head < 0)
			r->head = (int)i;
	}
}

/* The two fused passes, recorded around the plan rather than inside it.
 *
 * Pre goes in front of the first pass that would read the features, and Post in
 * front of the capture that ends the recording: between them the network reads the
 * colour where the game wrote it and writes the answer where the upscaler will read
 * it, which is what Mochi keeps Kind::Pre and Kind::Post in the plan for.
 *
 * The history is one buffer the Post both reads and writes. One invocation reads its
 * own pixel before it writes it, and invocations do not touch each other's, so the
 * frame's own prediction is the next frame's history without a copy or a swap. */
static int record_fused(replay *r, int pre)
{
	const unsigned height = nr_plan_extent[0], width = nr_plan_extent[1];
	diagf("record_fused: extent %ux%u = %llu pixels, pitch %u, source %ux%u\n",
	      height, width, (unsigned long long)height * (unsigned long long)width,
	      fuse.pitch, fuse.source_h, fuse.source_w);
	if (pre) {
		/* The table is the last argument, where `xmx_rec_pre` declares it. It was
		 * being passed sixth, right after the plan, which slid every argument along
		 * by one: the pass took the table's buffer id as its pixel count -- four --
		 * and the extent as the height, and so wrote four pixels of features and left
		 * the rest of the frame's input as whatever the memory held. */
		if (f_rec_pre(r->colour, r->motion, r->history, r->ids[r->features], r->plan,
			      height * width, height, width, fuse.pitch, fuse.source_h,
			      fuse.source_w, 0u, r->table) != 0)
			return r->why = (f_error && f_error() && *f_error()) ? f_error()
			                                                 : "the fused input would not record", -1;
		r->pre_done = 1;
	} else {
		if (f_rec_post(r->colour, r->ids[r->head], r->history, r->result, r->table,
			       r->history, fuse.source_h * fuse.source_w, height, width,
			       fuse.pitch, fuse.source_h, fuse.source_w) != 0)
			return r->why = (f_error && f_error() && *f_error()) ? f_error()
			                                                 : "the fused output would not record", -1;
		r->post_done = 1;
	}
	return 0;
}

/* The plan, the gate table and the history, once: they are state, not a frame. */
static int prepare_fused(replay *r)
{
	const unsigned height = nr_plan_extent[0], width = nr_plan_extent[1];
	char named[1024];
	snprintf(named, sizeof named, "%s\\nr_pre.spv", fuse.folder);
	char post[1024];
	snprintf(post, sizeof post, "%s\\nr_post.spv", fuse.folder);

	if ((r->colour = f_buf_import(fuse.colour, fuse.colour_bytes)) < 0)
		return r->why = "the colour would not import", -1;
	r->result = f_buf_import(fuse.result, fuse.result_bytes);
	if (r->result < 0)
		return r->why = "the answer's buffer would not import", -1;
	if (fuse.motion) {
		r->motion = f_buf_import(fuse.motion, fuse.motion_bytes);
		if (r->motion < 0)
			return r->why = "the motion would not import", -1;
	} else {
		/* No motion: a still reprojection, which is the identity, is still a buffer
		 * the shader has to read. */
		r->motion = f_buf_create_kind((unsigned long long)width * height * 2u * 4u, 0);
		if (r->motion < 0 || f_buf_zero(r->motion) != 0)
			return r->why = "the motion's stand-in would not come up", -1;
	}

	r->plan = f_buf_create_kind(fuse.plan_bytes, 0);
	if (r->plan < 0)
		return r->why = "the plan's buffer would not come up", -1;
	if (f_buf_upload(r->plan, fuse.plan, 0, fuse.plan_bytes) != 0)
		return r->why = "the plan would not go in", -1;

	/* The gate table and the three scalars the composition reads after it. */
	const unsigned long long table_bytes = (65536u + 4u) * 4ull;
	float *table = malloc((size_t)table_bytes);
	if (!table)
		return r->why = "out of memory for the gate table", -1;
	memcpy(table, fuse.table, 65536u * sizeof(float));
	table[65536u] = fuse.intensity;
	table[65537u] = fuse.confidence;
	table[65538u] = fuse.exposure;
	/* 65539: whether the history is this frame's own colour. It starts set, because
	 * there is no history behind the first frame. */
	table[65539u] = 1.0f;
	/* Host-visible, and the kind is the whole of the reason.
	 *
	 * This table is eight bytes of frame: the pre-exposure and whether the history is
	 * this frame's own colour, written before the graph runs and read twice by it --
	 * once by the input pass, once by the composition. Everything else about the frame
	 * crosses in a copy the device does on its own; these eight bytes were crossing as
	 * a staging transfer, which on a card without resizable BAR means a submit on the
	 * graph's own queue and a fence wait behind it (libxmx.c:1818 stage_copy, which
	 * memcpy's a mapped buffer and does not do any of that).
	 *
	 * It measured 81ms over 35 calls with a single call at 41ms, against a frame that is
	 * 63ms -- which is the forty-five milliseconds that made one frame in three cost
	 * 107 instead of 63, and that is the flicker.
	 *
	 * Kind 1 is the host-visible one: `unmapped = kind == 0 && g.unmapped` (libxmx.c:1321)
	 * is false for it, so the buffer is mapped and the write is a memcpy. It costs a
	 * cross of the bus for the few cache lines the shaders read, which is four bytes at
	 * a uniform index and nothing per pixel -- and it is the only way to hand the graph a
	 * value that changes every frame without putting a queue round trip in front of it. */
	r->table = f_buf_create_kind(table_bytes, 1);
	if (r->table < 0) {
		free(table);
		return r->why = "the gate table's buffer would not come up", -1;
	}
	if (f_buf_upload(r->table, table, 0, table_bytes) != 0) {
		free(table);
		return r->why = "the gate table would not go in", -1;
	}
	free(table);

	const unsigned long long history_bytes = (unsigned long long)width * height * 3u * 4u;
	r->history = f_buf_create_kind(history_bytes, 0);
	if (r->history < 0)
		return r->why = "the history's buffer would not come up", -1;
	if (f_buf_zero(r->history) != 0)
		return r->why = "the history would not start empty", -1;
	r->fused = 1;
	return 0;
}

static int build(replay *r)
{
	find_frame(r);
	/* The fused state is made before the walk and not at a step of it. The plan has no
	 * res_init in it -- the resident shaders are put in place by the open itself, in
	 * `prepare` -- so a wait for that step would be a wait that never ends, and a
	 * network that opened perfectly and quietly had no Pre and no Post in it. Nothing
	 * this makes needs a buffer the walk has yet to make. */
	if (fuse.asked && !r->fused && prepare_fused(r) != 0) {
		diagf("fused: %s\n", r->why ? r->why : "?");
		return -1;
	}
	/* Whether the plan is recording right now. A plan dumped from a walk that made a
	 * dry run begins twice and throws the first away, and only the second one is
	 * what a frame runs. */
	int active = 0;
	for (unsigned i = 0; i < nr_plan_step_count; i++) {
		const struct nr_step *s = &nr_plan_steps[i];
		/* The blobs are the state the recording was made from. They go in once the
		 * buffers exist and before anything has been over them — which is where
		 * the recording's own snapshot was taken. */
		if (s->op == OP_XMX_GRAPH_RUN && !r->failed) {
			if (upload_blobs(r) != 0)
				return -1;
			r->failed = 1;
		}
		/* `active` says the plan has reached a begin; the recording itself is opened by
		 * the call further down, on this same step. So the fused passes go in on the step
		 * after the begin, where there is a recording to record them into. */
		const int justBegan = (s->op == OP_XMX_BEGIN);
		if (justBegan)
			active = 1;
		else if (s->op == OP_XMX_ABORT || s->op == OP_XMX_GRAPH_CAPTURE)
			active = 0;
		/* An abort throws its recording away, and the fused input pass goes with it:
		 * it was recorded into a command buffer that is discarded. This plan records
		 * twice -- begin at step 1257, abort at 1798, begin at 1807, capture at 2311 --
		 * and only the second recording is the graph. So a pass recorded after the first
		 * begin is not in the graph at all, and the features stay whatever the memory
		 * held, which is what the noise on screen was. Forget it here and let the next
		 * begin record it again, into the recording that survives. */
		if (fuse.asked && r->fused && s->op == OP_XMX_ABORT)
			r->pre_done = 0;
		/* The fused input, in front of the first pass that would read the features:/n		 * by then every buffer the plan makes has been made, and none has been read. */
		/* As soon as the network starts recording, and not at some step of it. The
		 * test used to be `s->op >= OP_XMX_REC_COPY`, which is a comparison of enum
		 * values, and this plan has no OP_XMX_REC_COPY in it at all -- 2314 steps and
		 * zero of them -- while its number is above every pass in the plan. So the
		 * input pass was never recorded, the features stayed whatever the memory
		 * held, and the network answered on noise: a frame of colour noise, with the
		 * recording otherwise perfect. The input pass goes first for the plain reason
		 * that everything after it reads what it writes. */
		if (fuse.asked && r->fused && active && !justBegan && !r->pre_done)
		{
			/* The two fused pipelines are built here, inside the recording, because a
			 * pipeline is recorded into the command buffer that is open: building one
			 * before any recording existed gave `g.rpre` as null, and the input pass
			 * then refused to record itself -- which is what left the features as
			 * whatever the memory held. */
			char pre[1024], post[1024];
			snprintf(pre, sizeof pre, "%s\\nr_pre.spv", fuse.folder);
			snprintf(post, sizeof post, "%s\\nr_post.spv", fuse.folder);
			if (f_prepost_init(pre, post) != 0)
				return r->why = "the fused passes would not build", -1;
		}
		if (fuse.asked && r->fused && active && !justBegan && !r->pre_done
		    && r->ids[r->features] >= 0 && record_fused(r, 1) != 0)
			return -1;
		/* The fused output, in front of the capture that ends the recording. */
		if (fuse.asked && r->fused && s->op == OP_XMX_GRAPH_CAPTURE && !r->post_done
		    && record_fused(r, 0) != 0)
			return -1;
		if (step(r, s) != 0) {
			diagf("step %u (%s): %s\n", i, nr_plan_names[s->op],
				f_error() ? f_error() : "");
			return -1;
		}
		/* The imported buffers and the state the two passes read can only be made
		 * once the runtime is up, which is what this step of the plan is. */
	}
	/* A request the walk never honoured is not a network that quietly runs the old
	 * way: it is a fused host against a recording with no Pre and no Post in it, which
	 * is how a slot came to hang for a minute on 2026-10-13. Say so instead. */
	if (fuse.asked && !r->fused)
		return r->why = "the fused passes were asked for and never made", -1;
	/* Both of them, not just the state: an input pass that never went in leaves the
	 * network reading features nobody wrote, which is a black frame rather than a slow
	 * one, and it has to be said here where the reason still is. */
	if (fuse.asked && !r->pre_done)
		return r->why = "the fused input pass was never recorded", -1;
	if (fuse.asked && !r->post_done)
		return r->why = "the fused output pass was never recorded", -1;
	return 0;
}

static int read_plan_file(replay *r, const char *path)
{
	FILE *in = fopen(path, "rb");
	if (!in) {
		diagf("cannot open %s\n", path);
		return -1;
	}
	fseek(in, 0, SEEK_END);
	r->size = (unsigned long long)ftell(in);
	fseek(in, 0, SEEK_SET);
	r->bytes = malloc((size_t)r->size);
	if (!r->bytes || fread(r->bytes, 1, (size_t)r->size, in) != r->size) {
		diagf("cannot read %s\n", path);
		return -1;
	}
	fclose(in);
	return 0;
}

/* Two halves, because the host needs one of them before the other can exist.
 *
 * `runtime_up` is the device and the shaders: the same whatever extent is being run,
 * and -- since the reference keeps one Vulkan device for both halves of the bridge
 * (`ta_MochizukiNrRuntime.cpp`: "The network runs on a Vulkan device of its own") --
 * the thing the host's own Vulkan side has to be built on. So it can be asked for on
 * its own, before any network is built: `nr_net_boot`.
 *
 * `plan_up` is the network's shape, and needs the extent, so it comes after. */
static int runtime_up(replay* r, const char* library, const char* folder)
{
	/* libxmx was built by the project's own Makefile and carries its runtime with it
	 * (libgomp, libwinpthread), which sits beside it in `work`. A program that lives
	 * anywhere else has to say where to look, or LoadLibrary finds the DLL and not
	 * what the DLL needs. */
#ifdef _WIN32
	SetDllDirectoryA(folder);
#endif

	r->ids = malloc(nr_plan_buffer_count * sizeof *r->ids);
	if (!r->ids)
		return r->why = "out of memory for the buffers", -1;
	for (unsigned i = 0; i < nr_plan_buffer_count; i++)
		r->ids[i] = -1;
	r->features = -1;
	r->head = -1;

	if (open_library(library) != 0)
		return r->why = "cannot load the library", -1;
	/* Where the two fused shaders sit: beside the library, as the plan's own file
	 * does. nr_net_fuse is called before an open and so has no folder to give. */
	snprintf(fuse.folder, sizeof fuse.folder, "%s", folder);
	if (!diag) {
		char log[1024];
		snprintf(log, sizeof log, "%s\\nr_net.log", folder);
		diag = fopen(log, "w");
	}

	char gemm[1024], res[6][1024];
	snprintf(gemm, sizeof gemm, "%s\\gemm_coopmat.spv", folder);
	const char* names[] = { "gemm_resident.spv", "resident.spv", "attention.spv",
				"history.spv", "gemm_tiled.spv", "gemm_staged.spv" };
	for (unsigned i = 0; i < 6; i++)
		snprintf(res[i], sizeof res[i], "%s\\%s", folder, names[i]);

	/* The rest of the shader set, in the order the runtime loads it. `res_init` fills
	 * five of the seventeen pipeline slots; the others are these, and a pass whose
	 * slot is empty is a pass that cannot be recorded \u2014 which is what "cannot open
	 * spv" means, and why it arrives halfway down the plan rather than here. */
	char more[4][1024];
	snprintf(more[0], sizeof more[0], "%s\\gemm_staged32.spv", folder);
	snprintf(more[1], sizeof more[1], "%s\\gemm_staged32_deep.spv", folder);
	snprintf(more[2], sizeof more[2], "%s\\attention_rows.spv", folder);
	snprintf(more[3], sizeof more[3], "%s\\gemm_tiled32.spv", folder);

	if (f_init(gemm) != 0
	    || f_res_init(res[0], res[1], res[2], res[3], res[4], res[5]) != 0
	    || f_staged32_init(more[0], more[1]) != 0
	    || f_rows_init(more[2]) != 0)
		return r->why = "cannot open the device", -1;

	FILE* probe = fopen(more[3], "rb");
	if (probe) {
		fclose(probe);
		if (f_tiled32_init(more[3]) != 0)
			diagf("tiled32: %s\n", f_error() ? f_error() : "");
	}
	return 0;
}

static int plan_up(replay* r, const char* folder, const char* blobs)
{
	char named[1024];
	if (!blobs) {
		/* Named the way the plan names itself. A fixed default was a trap: the
		 * 768x448 and 960x544 runs differ by 6 MB, and reading the wrong file
		 * fails far from the cause, as `blob 628 runs past the plan file`
		 * from a table that is entirely correct. */
		snprintf(named, sizeof named, "%s\\plan_%ux%u.bin", folder,
			 nr_plan_extent[1], nr_plan_extent[0]);
		blobs = named;
	}
	if (read_plan_file(r, blobs) != 0)
		return r->why = "cannot read the plan's bytes", -1;
	return 0;
}

static int prepare(replay* r, const char* library, const char* folder,
		   const char* blobs)
{
	if (runtime_up(r, library, folder) != 0)
		return -1;
	return plan_up(r, folder, blobs);
}

/* The device, before there is a network. The hand-over has to be built on it: two
 * Vulkan devices of our own, each importing the same shared resource and each with
 * its own queue, is a pair the memory between them is not visible across. */
static replay* booted = NULL;

nr_net* nr_net_boot(const char* library, const char* folder)
{
	if (booted)
		return (nr_net*)booted;

	replay* r = calloc(1, sizeof *r);
	if (!r)
		return NULL;
	if (!library)
		library = "libxmx.dll";
	if (!folder)
		folder = ".";
	if (runtime_up(r, library, folder) != 0)
		return (nr_net*)r;
	booted = r;
	r->why = NULL;
	return (nr_net*)r;
}

unsigned long long nr_net_instance(nr_net* n) { (void)n; return f_inst ? f_inst() : 0ull; }
unsigned long long nr_net_physical(nr_net* n) { (void)n; return f_phys ? f_phys() : 0ull; }
unsigned long long nr_net_device(nr_net* n) { (void)n; return f_dev ? f_dev() : 0ull; }
unsigned long long nr_net_queue(nr_net* n) { (void)n; return f_que ? f_que() : 0ull; }
unsigned nr_net_family(nr_net* n) { (void)n; return f_fam ? f_fam() : 0u; }

/* This frame's exposure, written into the table both fused passes read it from.
 *
 * The pre-exposure the game scaled its colour by is the frame's own, and it moves:
 * this game hands anywhere from a quarter of it to all of it between two frames. A
 * divisor baked into the recording when the network was opened is the first frame's
 * divisor forever, and every frame after it is over- or under-exposed by however far
 * the game has moved since. The reference reads the game's exposure in the shader for
 * the same reason (`native_codec_decode.hlsl`, `EffectivePaperWhite`).
 *
 * Four bytes, before the frame is run. */
/* A window out of the answer, as mean, lowest and highest.
 *
 * Not for the frame: a fused frame never comes back to the host, which is the point
 * of it, and which is also why a fused path with something wrong in it can only be
 * argued about. This reads a slice and says what is in it, so that "the network is
 * running" and "the network is running and answering with a picture" are two different
 * claims. The caller's own cost is four bytes of output and a megabyte it never sees. */
int nr_net_probe(nr_net* n, int which, float* out)
{
	if (!n || !out || !f_buf_download)
		return -1;
	replay *r = (replay *)n;
	const int id = which == 0 ? r->colour : r->result;
	if (id < 0)
		return -1;

	static const unsigned long long window = 1ull << 20;
	const unsigned long long words = window / 4ull;
	const unsigned long long total = (unsigned long long)nr_plan_extent[0] * nr_plan_extent[1];
	const unsigned long long from = (total > words ? (total - words) / 2ull : 0ull);
	uint32_t *raw = (uint32_t *)malloc((size_t)window);
	if (!raw)
		return -1;
	const int bad = f_buf_download(id, raw, from * 4ull, window);
	if (bad) {
		free(raw);
		return bad;
	}

	/* R11G11B10's red: five exponent bits above six mantissa bits, (64 + m) * 2^(e - 21). */
	double sum = 0.0;
	float low = 1e30f, high = -1e30f;
	for (unsigned long long i = 0; i < words; i++) {
		const unsigned v = raw[i] & 0x7FFu;
		const unsigned e = (v >> 6u) & 0x1Fu, m = v & 0x3Fu;
		const float value = e == 0u ? 0.0f : (float)(64u + m) * (float)ldexp(1.0, (int)e - 21);
		sum += value;
		if (value < low) low = value;
		if (value > high) high = value;
	}
	/* The bytes themselves, written where they can be read: a mean says a number is
	 * plausible, and this says what is actually there. Sixty-four words of it is enough
	 * to tell a picture from a random number, and it costs nothing the frame does not
	 * already pay. */
	for (int i = 0; i < 16; i++)
		diagf("probe %s[%d]: 0x%08X 0x%08X 0x%08X 0x%08X\n", which == 0 ? "colour" : "answer",
		      i, raw[i * 4 + 0], raw[i * 4 + 1], raw[i * 4 + 2], raw[i * 4 + 3]);
	diagf("probe %s: mean %.4f low %.4f high %.4f\n", which == 0 ? "colour" : "answer",
	      (float)(sum / (double)words), low, high);

	free(raw);
	out[0] = (float)(sum / (double)words);
	out[1] = low;
	out[2] = high;
	return 0;
}

int nr_net_exposure(nr_net* n, float value, int fresh)
{
	replay *r = (replay *)n;
	if (!r || r->table < 0)
		return -1;
	float pair[2] = { value, fresh ? 1.0f : 0.0f };
	return f_buf_upload(r->table, pair, 65538u * 4ull, sizeof pair);
}

/* Whether the model's edit is applied to the picture, as a number the composition
 * blends by. Zero is the picture the network read, unchanged.
 *
 * The reference calls the switch `apply_model` and is explicit about what it is not:
 * turning it off does not stop the pass, it only stops its answer being used, so a
 * frozen frame can be toggled and compared and the frame cost stays the same on both
 * sides (`ta_DlssNr_Menu.cpp`, "Off shows the clean upscaler frame while the pass
 * keeps running"). That is why this is a value in the frame's own table rather than a
 * branch around the run: the network runs either way, and only the blend moves.
 *
 * `nr_post.comp` reads it at 65536 and computes `rgb + blend * (predicted - rgb)`, so
 * zero is exactly the input colour -- not an approximation of it, which is what makes
 * it a clean A/B. `nr_net_fuse` seeds it at 1.0.
 *
 * Same shape and the same buffer as `nr_net_exposure` above: a host-visible write of
 * one float, no synchronisation, so it can be asked for on a running frame. */
int nr_net_intensity(nr_net* n, float value)
{
	replay *r = (replay *)n;
	if (!r || r->table < 0)
		return -1;
	return f_buf_upload(r->table, &value, 65536u * 4ull, sizeof value);
}

/* Start the per-pass timing. Free when it is off: libxmx's own comment says a stamp is a
 * command-buffer write and not a synchronisation point, so the frame it measures is the
 * frame that would have run. It costs one query per pass -- 417 of them -- which is not
 * nothing, so it is asked for and not assumed. */
int nr_net_profile(nr_net* n, int on)
{
	(void)n;
	if (!f_prof_on)
		return -1;
	if (!f_prof_on) {
		diagf("profile: this build of the library has no xmx_profile\n");
		return -1;
	}
	const int bad = f_prof_on(on ? 1 : 0);
	diagf("profile: xmx_profile(%d) said %d (%s)\n", on ? 1 : 0, bad,
	      (f_error && f_error() && *f_error()) ? f_error() : "no reason given");
	if (bad)
		return bad;
	return 0;
}

/* Every timed pass, in recording order: its kind and its milliseconds.
 *
 * The totals libxmx keeps answer "which family is slow"; this answers "which passes", and
 * that is the question a frame total cannot: three hundred cheap passes and one expensive
 * one look identical from the outside. Sorting is left to the caller, which has somewhere
 * to print it; there are 417 of them and no order worth imposing.
 *
 * `kinds` may be null if only the times are wanted. Returns how many were filled, which is
 * capped at `cap`. */
unsigned nr_net_profile_each(nr_net* n, unsigned* kinds, double* ms, unsigned cap)
{
	(void)n;
	if (!f_prof_n || !f_prof_ms || !f_prof_kind)
		return 0;
	const unsigned have = f_prof_n();
	const unsigned take = have < cap ? have : cap;
	for (unsigned i = 0; i < take; i++) {
		if (kinds) kinds[i] = f_prof_kind(i);
		if (ms) ms[i] = f_prof_ms(i);
	}
	return take;
}

void nr_net_profile_reset(nr_net* n)
{
	(void)n;
	if (f_prof_reset)
		f_prof_reset();
}

/* The three costs of one frame's submit, in the order they happen: the CPU handing the
 * work over, the CPU waiting for it, and the read-back afterwards. Four numbers in
 * `out`: submit, wait, collect, and the frames they cover.
 *
 * The pass timings are the device's own and cannot answer this -- a frame slow in the
 * submit looks entirely healthy in them -- so they are the other half of the same
 * question and both are asked for at once when this is on. */
int nr_net_time_submit(nr_net* n, int on)
{
	(void)n;
	if (!f_time_on)
		return -1;
	return f_time_on(on ? 1 : 0);
}

int nr_net_time_report(nr_net* n, double* out, unsigned cap)
{
	(void)n;
	if (!f_time_report || !f_time_reset || !out || cap < 8)
		return -1;
	/* Twelve: the submit's three costs, then the staging transfers' total, slowest,
	 * calls, and the room for one more the library keeps for itself. */
	if (cap < 12u)
		return -1;
	double v[12] = {};
	f_time_report(v, 12);
	for (unsigned i = 0; i < 12u; i++)
		out[i] = v[i];
	/* Cleared after the read, so a report covers the frames since the last one and two
	 * reports are not the same span counted twice. */
	f_time_reset();
	return (int)v[0];
}

int nr_net_idle(nr_net* n)
{
	if (!f_idle)
		return -1;
	const int bad = f_idle();
	if (bad) {
		const char *text = f_error ? f_error() : "";
		diagf("idle: the queue would not settle (%d): %s\n", bad, text ? text : "");
		if (n) {
			replay *r = (replay *)n;
			if (!r->why)
				r->why = text && *text ? text : "the queue would not settle";
		}
	}
	return bad;
}
/* Which buffer is the frame's way in, and which its way out. Found by kind rather than
 * by number: the plan numbers buffers in the order they were made, and nothing says
 * which of them the host writes. HOST_WRITE is the features and HOST_READ is the head —
 * one of each, or this is not a plan that can be run as a frame. */
static int ends(replay *r)
{
	for (unsigned i = 0; i < nr_plan_buffer_count; i++) {
		if (nr_plan_buffers[i].kind == 2 && r->features < 0)
			r->features = (int)i;
		else if (nr_plan_buffers[i].kind == 1 && r->head < 0)
			r->head = (int)i;
	}
	if (r->features < 0 || r->head < 0)
		return r->why = "the plan has no frame in or out", -1;

	r->in = malloc((size_t)nr_plan_buffers[r->features].bytes);
	r->out = malloc((size_t)nr_plan_buffers[r->head].bytes);
	if (!r->in || !r->out)
		return r->why = "out of memory for the frame", -1;
	memset(r->in, 0, (size_t)nr_plan_buffers[r->features].bytes);
	memset(r->out, 0, (size_t)nr_plan_buffers[r->head].bytes);
	return 0;
}

/* ---- the library ---------------------------------------------------------- */

nr_net *nr_net_open(const char *library, const char *folder, const char *blobs)
{
	/* The runtime may already be up: the host boots it before it builds its own
	 * Vulkan side, because the reference keeps one device for both halves. Then
	 * only the network's shape is still missing. */
	replay *r = booted;
	if (r != NULL) {
		if (plan_up(r, folder, blobs) != 0)
			return (nr_net *)r;
	} else {
		r = calloc(1, sizeof *r);
		if (!r)
			return NULL;
		if (!library)
			library = "libxmx.dll";
		if (!folder)
			folder = ".";
		/* A failure still hands something back: `nr_net_error` is where the caller
		 * learns what it was. Only a successful open clears the reason. */
		if (prepare(r, library, folder, blobs) != 0)
			return (nr_net *)r;
	}
	/* The per-pass timing has to be on before the walk, not after it. A timestamp is
	 * written into the command buffer as it is recorded, and `graph_capture` copies the
	 * count into the graph once, when the walk ends (libxmx.c:3391): the figure every
	 * frame later replays is the one its recording carries. Turning it on here, after an
	 * open, therefore measures nothing at all -- `collect` is handed zero stamps and
	 * answers nothing, which is what "0 timed" was.
	 *
	 * It costs one query per pass on the recorded buffer, and never on the frames, which
	 * are replays of it. A pass is a timestamp, not a wait, so the frame it measures is
	 * the frame that would have run -- libxmx's own words, above xmx_profile. */
	if (f_prof_on && f_prof_on(1) != 0)
		diagf("profile: the device would not time its passes: %s\n",
		      f_error && f_error() && *f_error() ? f_error() : "no reason given");

	if (build(r) != 0) {
		if (!r->why)
			r->why = "the walk failed";
		return (nr_net *)r;
	}
	if (ends(r) != 0)
		return (nr_net *)r;
	r->why = NULL;
	return (nr_net *)r;
}

const char *nr_net_error(nr_net *n)
{
	replay *r = (replay *)n;
	if (!r)
		return "no network";
	if (r->why)
		return r->why;
	/* The library's own description, which is empty when nothing has gone wrong — an
	 * empty string is not an error, and treating it as one hides the real state. */
	const char *why = f_error ? f_error() : NULL;
	return (why && *why) ? why : NULL;
}

void nr_net_close(nr_net *n)
{
	replay *r = (replay *)n;
	if (!r)
		return;
	if (r == booted)
		booted = NULL;
	if (r->graph >= 0 && f_graph_destroy)
		f_graph_destroy(r->graph);
	for (unsigned i = 0; i < nr_plan_buffer_count; i++)
		if (r->ids && r->ids[i] >= 0 && f_buf_destroy)
			f_buf_destroy(r->ids[i]);
	free(r->ids);
	free(r->bytes);
	free(r->in);
	free(r->out);
	free(r);
}

void nr_net_extent(nr_net *n, unsigned *height, unsigned *width)
{
	if (height)
		*height = nr_plan_extent[0];
	if (width)
		*width = nr_plan_extent[1];
}

void *nr_net_features(nr_net *n)
{
	replay *r = (replay *)n;
	return r ? r->in : NULL;
}

/* The input pass on its own, submitted outside the graph.
 *
 * One question this answers and the graph cannot: whether the pass writes the features at
 * all. The graph runs it inside 2314 steps and the features come out as whatever the
 * memory held, which is the same answer whether the pass is missing from the recording,
 * broken, or writing somewhere else -- and the three want three different fixes. Here it is
 * recorded, submitted and waited on by itself, so if the features change, the pass is sound
 * and the graph is what loses it.
 */
int nr_net_pre_alone(nr_net *n)
{
	replay *r = (replay *)n;
	if (!r || !f_begin || !f_submit)
		return -1;
	if (f_begin() != 0)
		return r->why = (f_error && f_error() && *f_error()) ? f_error() : "a lone recording would not open", -1;
	if (record_fused(r, 1) != 0) {
		r->pre_done = 0;
		return -1;
	}
	r->pre_done = 1;
	if (f_submit() < 0)
		return r->why = (f_error && f_error() && *f_error()) ? f_error() : "a lone recording would not submit", -1;
	if (f_idle && f_idle() != 0)
		return r->why = "the lone recording would not settle", -1;
	return 0;
}

unsigned long long nr_net_features_bytes(nr_net *n)
{
	replay *r = (replay *)n;
	return (r && r->features >= 0) ? nr_plan_buffers[r->features].bytes : 0;
}

const float *nr_net_head(nr_net *n)
{
	replay *r = (replay *)n;
	return r ? r->out : NULL;
}

unsigned long long nr_net_head_bytes(nr_net *n)
{
	replay *r = (replay *)n;
	return (r && r->head >= 0) ? nr_plan_buffers[r->head].bytes : 0;
}

int nr_net_run(nr_net *n)
{
	replay *r = (replay *)n;
	if (!r || r->why || r->features < 0 || r->head < 0)
		return -1;

	/* The fused path: Pre read the colour where the game wrote it and Post writes
	 * the answer where the upscaler will read it, so there is nothing to copy in
	 * and nothing to bring back. */
	if (r->fused)
		return f_graph_run(r->graph) < 0 ? (r->why = "the graph would not run", -1) : 0;

	/* The features were built on the host and go in by copy. On a discrete card under
	 * this driver writing them into the graph's own mapped half buffer instead comes
	 * back out of the graph as NaN, every frame (nr_daemon.py:1406) — so this copy is
	 * not the optimisation it looks like an opportunity to skip. */
	if (f_buf_upload(r->ids[r->features], r->in, 0,
			 nr_plan_buffers[r->features].bytes) != 0)
		return r->why = "the features would not go in", -1;

	if (f_graph_run(r->graph) < 0)
		return r->why = "the graph would not run", -1;

	if (f_buf_download(r->ids[r->head], r->out, 0,
			   nr_plan_buffers[r->head].bytes) != 0)
		return r->why = "the head would not come back", -1;
	return 0;
}

#ifdef NR_REPLAY_STANDALONE
int main(int argc, char **argv)
{
	const char *library = argc > 1 ? argv[1]
		: "E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work\\libxmx.dll";
	const char *folder = argc > 3 ? argv[3]
		: "E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work";
	const char *blobs = argc > 2 ? argv[2] : NULL;

	replay r = { 0 };
	if (prepare(&r, library, folder, blobs) != 0) {
		diagf("%s\n", r.why ? r.why : "?");
		return 1;
	}
	printf("device %s\n", f_device() ? f_device() : "?");
	printf("extent %ux%u: %u steps, %u buffers, %u blobs\n",
	       nr_plan_extent[1], nr_plan_extent[0], nr_plan_step_count,
	       nr_plan_buffer_count, nr_plan_blob_count);

	/* Wall time, not CPU time: a run ends when the device says it has, and the wait is
	 * a fence — the thread sleeps through most of it, which `clock` would not count. */
	double began = now_ms();
	if (build(&r) != 0)
		return 1;
	printf("build %.0f ms\n", now_ms() - began);

	/* The number that decides how this can be used: one run of the graph, with
	 * nothing else waiting. Whatever it is, it is the whole of the network's cost on
	 * this card — there is no host work left to hide it behind. */
	int passes = 0;
	for (int i = 0; i < 4; i++) {
		double at = now_ms();
		passes = f_graph_run(r.graph);
		printf("run %d: %.2f ms (%d passes)\n", i, now_ms() - at, passes);
	}
	if (passes < 0)
		return 1;

	/* What came out. Every buffer the host was meant to read, so the answer can be
	 * found without knowing its name. */
	for (unsigned i = 0; i < nr_plan_buffer_count; i++) {
		if (nr_plan_buffers[i].kind != 1)
			continue;
		if (r.ids[i] < 0 || nr_plan_buffers[i].bytes < 16)
			continue;
		float head[4];
		unsigned long long take = sizeof head < nr_plan_buffers[i].bytes
			? sizeof head : nr_plan_buffers[i].bytes;
		if (f_buf_download(r.ids[i], head, 0, take) != 0)
			continue;
		printf("read buffer %u: %.8f %.8f %.8f %.8f\n", i, head[0], head[1],
		       head[2], head[3]);
	}
	return 0;
}
#endif
