/* nr_plan.h — the shape a recorded plan has, whichever extent it was recorded at.
 *
 * `tools/dump_plan.py` walks the network once, in Python, and writes out every call the
 * walk made of libxmx. This is the shape those calls are written in. What it lets a
 * program do is run the network without the walk: no NumPy, no shape arithmetic, no
 * Python at all — a row at a time, in the order they were recorded.
 *
 * The opcodes are one enum for every recorder the library has, not just the ones the
 * recording happened to use, so a plan recorded with a different set of fusions still
 * names things this header knows.
 */
#ifndef NR_PLAN_H
#define NR_PLAN_H

/* How many arguments one call can carry. The widest recorder takes seventeen
 * (`xmx_rec_gemm`: three buffers, three extents, and eleven strides and flags). */
#define NR_PLAN_ARGS 18

enum nr_op {
	OP_BUF = 0,                 /* a buffer was created: (index, bytes, kind) */
	OP_UP,                      /* bytes went into a buffer: (index, offset, length) */

	OP_XMX_INIT,
	OP_XMX_RES_INIT,
	OP_XMX_ROWS_INIT,
	OP_XMX_STAGED32_INIT,
	OP_XMX_TILED32_INIT,
	OP_XMX_TILED8_INIT,
	OP_XMX_WINDOW_INIT,
	OP_XMX_FFN_INIT,
	OP_XMX_INT8_INIT,
	OP_XMX_INT8_FUSED_INIT,
	OP_XMX_INT8_RESIDUAL_INIT,
	OP_XMX_QUANT_INIT,
	OP_XMX_GLOBAL_ATTENTION_INIT,
	OP_XMX_WINDOW_BLOCK_INIT,
	OP_XMX_SPECIALIZE,

	OP_XMX_BUF_PTR,             /* the host asked to write through a mapped pointer */
	OP_XMX_BUF_ZERO,
	OP_XMX_BUF_DESTROY,
	OP_XMX_BEGIN,
	OP_XMX_ABORT,             /* a recording thrown away: the scratch discovery's */
	OP_XMX_SUBMIT,
	OP_XMX_SYNC,
	OP_XMX_GRAPH_CAPTURE,
	OP_XMX_GRAPH_RUN,
	OP_XMX_GRAPH_DESTROY,

	OP_XMX_REC_COPY,
	OP_XMX_REC_GEMM,
	OP_XMX_REC_GEMM_RESIDUAL,
	OP_XMX_REC_GEMM_WINDOW_RESIDUAL,
	OP_XMX_REC_GEMM_WINDOW_RESIDUAL_POOL,
	OP_XMX_REC_GEMM_QKV,
	OP_XMX_REC_GEMM_QKV_WINDOW,
	OP_XMX_REC_GEMM_DUAL,
	OP_XMX_REC_UNARY,
	OP_XMX_REC_UNARY2,
	OP_XMX_REC_QKV,
	OP_XMX_REC_ROW,
	OP_XMX_REC_WINDOW_ATTENTION,
	OP_XMX_REC_WINDOW_BLOCK,
	OP_XMX_REC_GLOBAL_ATTENTION,
	OP_XMX_REC_QUANT,
	OP_XMX_REC_QUANT_WINDOW,
	OP_XMX_REC_GEMM_INT8,
	OP_XMX_REC_GEMM_INT8_BATCHED,
	OP_XMX_REC_GEMM_INT8_RESIDUAL,
	OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL,
	OP_XMX_REC_GEMM_INT8_QKV,
	OP_XMX_REC_GEMM_INT8_FUSED,
	OP_XMX_REC_FFN,
	OP_XMX_REC_FFN_MERGE,
	OP_XMX_REC_FFN_STEM,
	OP_XMX_REC_HISTORY,

	OP_COUNT
};

/* One recorded call. `args` holds its arguments in the order they were passed, and
 * `nr_plan_signatures` says what each one is — see `signature_of` in the dumper.
 * `text` is which entry of `nr_plan_text` holds this call's path, or -1: a path is a
 * name, not a number, and it cannot be carried in `args`. */
struct nr_step {
	int op;
	int nargs;
	long long args[NR_PLAN_ARGS];
	int text;
};

/* A buffer, as it was created. `kind` is libxmx's: 0 a graph buffer, 1 one the host
 * reads, 2 one the host writes. It is how a replayer finds the network's input and
 * output without being told their names. */
struct nr_buffer {
	unsigned long long bytes;
	int kind;
};

/* Where a run of bytes belongs, and where it lies in the plan's own file. */
struct nr_blob {
	int buffer;
	unsigned long long offset;
	unsigned long long length;
	unsigned long long at;
};

#endif
