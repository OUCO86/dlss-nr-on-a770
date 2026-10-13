/* nr_net.h — the network, as a library.
 *
 * What `nr_replay.c` proved is that the whole of the resident frame can be built and
 * run without the Python that walked it: the walk is a table, the table is compiled in,
 * and one `xmx_graph_run` is a frame. This is that, packaged — the four calls a caller
 * needs and nothing of the plan, the shaders or the library that made it.
 *
 * The shapes are not arguments because they are the plan's, not the caller's: the plan
 * was recorded at one extent and the graph cannot be asked for another. Ask for the
 * extent, then honour it.
 *
 * Everything here is host memory in, host memory out. The device work is inside; where
 * the bytes come from and where they go is the caller's, which is what lets the bridge
 * feed it from a texture and take the answer back to one.
 */

#ifndef NR_NET_H
#define NR_NET_H

#ifdef __cplusplus
extern "C" {
#endif

/* __declspec is how a symbol leaves a DLL on Windows; anywhere else everything is
 * already visible. */
#ifdef _WIN32
#ifdef NR_NET_BUILD
#define NR_NET_API __declspec(dllexport)
#else
#define NR_NET_API __declspec(dllimport)
#endif
#else
#define NR_NET_API
#endif

typedef struct nr_net nr_net;

/* Open the device, put the resident shaders in place, build every buffer, put the
 * weights back and capture the graph. Slow, and once — a frame is `nr_net_run`.
 *
 * `library` is libxmx, `folder` holds the .spv files and the plan's blob file,
 * `blobs` is that file (NULL to take it from `folder` and the plan's own extent).
 * NULL is a question, not a failure: it asks for the description of the last one.
 */
/* The frame's own buffers, imported by handle, so that the network reads the colour
 * where the game put it and writes the answer where the upscaler will read it.
 *
 * Mochi keeps `Pre` and `Post` in the plan beside the network's own layers —
 * `refs/DLSSNR-AMD/core/nr_native_plan.cpp`, Kind::Pre and Kind::Post — and that is
 * what lets a frame reach the network without the host ever seeing a pixel. Saying this
 * before `nr_net_open` puts those two passes at either end of the recording: after it a
 * run is colour in and colour out, and `nr_net_features` and `nr_net_head` are not used.
 *
 * `plan` is what nr_pre.comp reads, laid out in that order: (height * width * 3)
 * floats of noise, 5 controls, `height` row indices, `width` column indices, the last
 * two as they sit in 32 bits. `table` is the 65536-entry gate table; the intensity, the
 * confidence and the exposure are the three floats the composition reads after it.
 * `pitch` is the colour's row in 32-bit words, which is how R11G11B10 is walked.
 */
NR_NET_API void nr_net_fuse(unsigned long long colour, unsigned long long motion,
			    unsigned long long result, unsigned long long colour_bytes,
			    unsigned long long motion_bytes, unsigned long long result_bytes,
			    unsigned pitch, unsigned source_h, unsigned source_w,
			    float exposure, float intensity, float confidence,
			    const void *plan, unsigned long long plan_bytes,
			    const float *table);

/* The device, before there is a network.
 *
 * The host's own Vulkan side -- the hand-over -- is built on the device the network
 * runs on, because the reference keeps one Vulkan device and one queue for both
 * halves of the bridge (`ta_MochizukiNrRuntime.cpp`: "The network runs on a Vulkan
 * device of its own ... a Vulkan submit waits on it, runs the network and writes the
 * result into a third shared buffer"). Two devices of our own, each importing the
 * same shared resource, do not share a queue to be ordered on and do not agree about
 * what that memory holds.
 *
 * `nr_net_boot` brings the device up on its own, and the five below hand it over.
 * Null when it is not up. An open after a boot reuses it and builds only the network. */
NR_NET_API nr_net *nr_net_boot(const char *library, const char *folder);
NR_NET_API unsigned long long nr_net_instance(nr_net *);
NR_NET_API unsigned long long nr_net_physical(nr_net *);
NR_NET_API unsigned long long nr_net_device(nr_net *);
NR_NET_API unsigned long long nr_net_queue(nr_net *);
NR_NET_API unsigned nr_net_family(nr_net *);

/* Nothing left in flight on the network's queue. A probe's way of knowing an answer
 * is there before it reads one back; a frame must not call it. */
/* This frame's pre-exposure, put where the two fused passes read it. Call before the
 * frame is run: the game's pre-exposure moves between frames, and the pass that
 * divides by it has to divide by this frame's. */
/* A window out of the answer, as mean, lowest and highest, into three floats. A
 * diagnostic: a fused frame does not come back to the host, and without this the only
 * thing that can be said about a running network is that it runs. */
NR_NET_API int nr_net_probe(nr_net *, int which, float *out);
/* The network's input: 16 channels x (mean, low, high), into 48 floats. Diagnostic. */
NR_NET_API int nr_net_probe_features(nr_net *, float *out);
/* Runs the input pass by itself, outside the graph. Diagnostic. */
NR_NET_API int nr_net_pre_alone(nr_net *);   /* 0 = the colour in, 1 = the answer */

NR_NET_API int nr_net_exposure(nr_net *, float, int fresh);

/* Whether the model's edit is applied, as the number the composition blends by. Zero
 * is the frame's own colour, exactly: `nr_post.comp` computes `rgb + blend *
 * (predicted - rgb)`, so zero is the input rather than a lookalike.
 *
 * The network runs either way. This is the reference's `apply_model`, whose own note
 * is that turning it off "shows the clean upscaler frame while the pass keeps running"
 * (`ta_DlssNr_Menu.cpp`) -- so a frozen frame can be toggled and compared with the
 * same cost on both sides. Seeded at 1.0 by `nr_net_fuse`.
 *
 * Safe to ask for on a running frame: one host-visible float, no synchronisation. */
NR_NET_API int nr_net_intensity(nr_net *, float);

/* Per-pass GPU timing, which libxmx already keeps (`xmx_profile`) and nothing asked for.
 * On: every recorded pass gains a timestamp query -- a command-buffer write, not a
 * synchronisation point -- so it costs a little and measures the frame that would have run.
 * Off again by `nr_net_profile(n, 0)`.
 *
 * `nr_net_profile_each` then gives every timed pass's kind (libxmx's own PK_* numbers,
 * `family * 32 + subkind` above PK_COPY=7) and its milliseconds, in recording order,
 * `cap` at a time and returning how many it filled. `nr_net_profile_reset` clears. */
NR_NET_API int nr_net_profile(nr_net *, int on);
NR_NET_API unsigned nr_net_profile_each(nr_net *, unsigned *kinds, double *ms, unsigned cap);
NR_NET_API void nr_net_profile_reset(nr_net *);

/* The submit's three costs, which the pass timings cannot see: the CPU handing the work
 * over, the CPU waiting for it, and the read-back. `nr_net_time_submit(n, 1)` turns the
 * counting on; `nr_net_time_report(n, out, 12)` reads it back into twelve
 * numbers -- frames, submit total, submit max, wait total, wait max, collect total,
 * collect max, the mean of the three, and then the staging transfers' total, slowest,
 * call count -- and clears the span, so one report is one span.
 *
 * The staging transfers are the frame's exposure and the diagnostics' reads. A buffer
 * the card will not let the host map goes through a copy on the same queue the game is
 * waiting on, behind a fence wait, and that is a cost the submit's three do not
 * include.
 *
 * Off until asked: three clock reads a frame, which is not what a game should pay for a
 * diagnostic. */
NR_NET_API int nr_net_time_submit(nr_net *, int on);
NR_NET_API int nr_net_time_report(nr_net *, double *out, unsigned cap);

NR_NET_API int nr_net_idle(nr_net *);

NR_NET_API nr_net *nr_net_open(const char *library, const char *folder,
			       const char *blobs);
NR_NET_API const char *nr_net_error(nr_net *);
NR_NET_API void nr_net_close(nr_net *);

/* The extent the plan was recorded at, (height, width). */
NR_NET_API void nr_net_extent(nr_net *, unsigned *height, unsigned *width);

/* The network's input: (height, width, 16) halves, laid out by `nr_features_half`.
 *
 * A host buffer, not the device's: on a discrete card under this driver the features
 * built straight into the graph's mapped half buffer come back through the graph as
 * NaN, every frame, while the same features built on the host and copied in are right
 * (`nr_daemon.py:1406`). So they are built here and uploaded by `nr_net_run`.
 *
 * Sixteen channels, half each, because that is what the graph's first GEMM reads.
 */
NR_NET_API void *nr_net_features(nr_net *);
NR_NET_API unsigned long long nr_net_features_bytes(nr_net *);

/* The network's output: (height, width, 4) floats, read back after the run. */
NR_NET_API const float *nr_net_head(nr_net *);
NR_NET_API unsigned long long nr_net_head_bytes(nr_net *);

/* One frame: the features go in, the graph runs, the head comes back. Blocks until the
 * device says it has finished, which is the whole of the network's cost — see the notes
 * for what that is on this card. */
NR_NET_API int nr_net_run(nr_net *);

/* Wait for the game's own fence at `value` before the graph runs.
 *
 * The colour is the game's buffer, imported rather than copied, so the graph has to be
 * told when the frame is in it -- and told on the device, which is what this is: a
 * semaphore wait inside the submit, not a host wait before one. The handle is the shared
 * handle of the D3D12 fence the game signals; it is imported once and waited on after.
 */
NR_NET_API int nr_net_wait(nr_net *, unsigned long long handle, unsigned long long value);

/* Whether the recording really carries the two fused passes. Zero until the open has
 * walked the plan, so it is the answer where nr_net_fuse was only the request. */
NR_NET_API int nr_net_fused(nr_net *);

#ifdef __cplusplus
}
#endif

#endif
