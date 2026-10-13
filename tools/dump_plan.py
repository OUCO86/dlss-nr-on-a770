#!/usr/bin/env python3
"""Record what the resident frame asks the device for, and write it out as a plan.

The network's shape is decided in Python: `nr_frame_resident` walks the recovered graph
and, for every pass, calls one `xmx_rec_*` recorder with the buffers and the extents it
worked out. Nothing about that walk needs the host once it has happened — the same
recorders exist in C, and the passes they record are the same passes.

So this records the walk instead of only running it: every recorder call is caught on its
way to `libxmx`, together with every buffer it creates and every byte it puts in one, and
the whole thing is written out as a plan a C replayer can walk on its own.

The plan is what Mochi's nr_native_plan.cpp holds as a static table. Ours is written by
running the Python once, here, instead of by hand — and that is the only reason the
Python ever has to run.

Two things the plan has to say that the calls alone do not:

  * What is in the buffers. On this card the weights are never *uploaded*: resizable BAR
    puts the card's memory where the host can address it, so `Buffer.view` hands back a
    pointer and NumPy writes straight through it. Nothing reaches `xmx_buf_upload`. The
    only trace a write leaves is `xmx_buf_ptr`, so every buffer the host asked for a
    pointer to is read back in one snapshot, taken after the weights are in and before
    the graph has been over them.

  * What each argument is. The recorders take a mix of ints, sizes and one float, and a
    C replayer has to know which is which. The signatures the runtime declares are that
    answer, so each argument is encoded by the type its own call site declared.
"""
from __future__ import annotations

import ctypes
import json
import pathlib
import struct
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))

# Every function that ends up as a pass in the graph begins with xmx_rec_. The rest are
# what put the buffers and the bytes in place for them, and what bounds a graph.
RECORDERS = tuple(sorted("""xmx_rec_copy xmx_rec_gemm xmx_rec_gemm_residual
xmx_rec_gemm_window_residual xmx_rec_gemm_window_residual_pool xmx_rec_gemm_qkv
xmx_rec_gemm_qkv_window xmx_rec_gemm_dual xmx_rec_unary xmx_rec_unary2 xmx_rec_qkv
xmx_rec_row xmx_rec_window_attention xmx_rec_window_block xmx_rec_global_attention
xmx_rec_quant xmx_rec_quant_window xmx_rec_gemm_int8 xmx_rec_gemm_int8_batched
xmx_rec_gemm_int8_residual xmx_rec_gemm_window_int8_residual xmx_rec_gemm_int8_qkv
xmx_rec_gemm_int8_fused xmx_rec_ffn xmx_rec_ffn_merge xmx_rec_ffn_stem
xmx_rec_history""".split()))

BOUNDS = ("xmx_res_init", "xmx_window_init", "xmx_ffn_init", "xmx_int8_init",
          "xmx_quant_init", "xmx_global_attention_init", "xmx_window_block_init",
          "xmx_int8_fused_init", "xmx_int8_residual_init", "xmx_tiled32_init",
          "xmx_tiled8_init", "xmx_staged32_init", "xmx_rows_init", "xmx_specialize",
          "xmx_abort",
          "xmx_begin", "xmx_submit", "xmx_sync", "xmx_graph_capture", "xmx_graph_run",
          "xmx_graph_destroy")

BUFFERS = ("xmx_buf_create", "xmx_buf_create_kind", "xmx_buf_create_exportable",
           "xmx_buf_upload", "xmx_buf_zero", "xmx_buf_destroy")

POINTERS = ("xmx_buf_ptr",)

# Two calls the plan says in its own words, because what they mean is not what the
# library was asked: which buffer was made, and where the bytes went in it.
SYNTHETIC = ("buf", "up")


class Trace:
    """Every call on its way to the device, in the order it was made."""

    def __init__(self):
        self.lib = None
        self.calls = []            # (name, [encoded args])
        self.buffers = {}          # device id -> the plan's own index
        self.sizes = {}            # device id -> bytes, as it was created
        self.kinds = {}            # device id -> kind, as it was created
        self.host_written = set()  # buffers the host has asked to write through
        self.order = []            # device ids, in the order they were created
        self.blobs = []            # (index, offset, bytes) to write out
        self.snapped = False
        self.opcodes = []          # every name the plan uses, in first-use order
        self.signatures = {}       # name -> what each argument is, one letter each
        self._opcode_ids = {}

    def opcode(self, name):
        if name not in self._opcode_ids:
            self._opcode_ids[name] = len(self.opcodes)
            self.opcodes.append(name)
        return self._opcode_ids[name]

    def index(self, device_id):
        if device_id not in self.buffers:
            self.buffers[device_id] = len(self.order)
            self.order.append(device_id)
        return self.buffers[device_id]


def install(lib, trace):
    """Wrap the calls we want, on the shared library every runtime holds.

    ctypes caches a resolved function on the library object, so putting ours there is
    what the runtime's own `self.lib.xmx_rec_...` finds. The original keeps its argtypes,
    which is both what turns the Python values into the C ones and what tells us how to
    write each argument out.
    """
    trace.lib = lib
    for group in (RECORDERS, BOUNDS, BUFFERS, POINTERS):
        for name in group:
            if not hasattr(lib, name):
                continue
            setattr(lib, name, _wrap(name, getattr(lib, name), trace))


def signature_of(argtypes):
    """What each argument is, as one letter each: i int, l long, f float, s a path.

    The replayer has to call these functions and it cannot guess which of its integers
    is really a float. The runtime's own declarations are the answer, and this is them
    in a form a generated table can carry.
    """
    if not argtypes:
        return "i"
    letters = []
    for declared in argtypes:
        if declared is ctypes.c_float:
            letters.append("f")
        elif declared is ctypes.c_char_p:
            letters.append("s")
        elif declared in (ctypes.c_ulonglong, ctypes.c_longlong):
            letters.append("l")
        else:
            letters.append("i")
    return "".join(letters)


def encode(args, signature):
    """One argument at a time, by the type its call site declared.

    A float is written as the bits of a float, not as a number: the replayer is handed
    the same 32 bits and passes them to the same C function, and no rounding happens on
    the way. A path stays a string — it is a name, not a number.
    """
    out = []
    for at, value in enumerate(args):
        declared = signature[at] if signature and at < len(signature) else None
        if declared is ctypes.c_float:
            out.append(struct.unpack("<i", struct.pack("<f", float(value)))[0])
        elif declared is ctypes.c_char_p:
            out.append(value.decode() if isinstance(value, bytes) else str(value))
        else:
            out.append(int(value))
    return out


def _wrap(name, original, trace):
    signature = getattr(original, "argtypes", None)
    trace.signatures[name] = signature_of(signature)

    def call(*args):
        # A buffer being made: the plan numbers it in the order it appeared, and the
        # replayer makes the same buffer at the same number.
        if name.startswith("xmx_buf_create"):
            made = original(*[_typed(a, signature, at) for at, a in enumerate(args)])
            if name == "xmx_buf_create":
                trace.sizes[made], trace.kinds[made] = int(args[0]), 0
            else:
                trace.sizes[made], trace.kinds[made] = int(args[0]), int(args[1])
            trace.calls.append(("buf", [trace.index(made), int(args[0]),
                                        trace.kinds[made]]))
            return made

        if name == "xmx_buf_upload":
            # Bytes on their way in through the front door. Copy them now: what `src`
            # points at belongs to a NumPy array the frame may drop as soon as this
            # returns.
            index = trace.index(int(args[0]))
            trace.blobs.append((index, int(args[2]),
                                ctypes.string_at(args[1], args[3]) if args[1] else b""))
            trace.calls.append(("up", [index, int(args[2]), int(args[3])]))

        if name == "xmx_buf_ptr":
            # The host is about to write through a mapped pointer. Which buffer it is, is
            # all this says; what it writes is read back in `snapshot`, once.
            trace.host_written.add(int(args[0]))

        if name == "xmx_graph_run" and not trace.snapped:
            trace.snapped = True
            snapshot(trace)

        result = original(*[_typed(a, signature, at) for at, a in enumerate(args)])
        trace.calls.append((name, encode(args, signature)))
        return result
    return call


def _typed(value, signature, at):
    """The value as ctypes wants it. A wrapped function gets plain Python values, and
    the original still expects the ones its argtypes name."""
    if signature and at < len(signature):
        declared = signature[at]
        if declared is ctypes.c_float:
            return ctypes.c_float(float(value))
        if declared is ctypes.c_char_p:
            return value.encode() if isinstance(value, str) else value
    return value


def snapshot(trace):
    """Read back every buffer the host has written, once, before anything runs.

    The weights are what this is for: on this card they went in through a mapped pointer
    and left no other trace, so the only way to say what they are is to ask the device.
    It happens here because later the graph has been over them and a buffer that started
    as a weight holds an activation instead.
    """
    download = trace.lib.xmx_buf_download
    download.argtypes = [ctypes.c_int, ctypes.c_void_p,
                         ctypes.c_ulonglong, ctypes.c_ulonglong]
    for device_id in sorted(trace.host_written):
        count = trace.sizes.get(device_id, 0)
        if not count:
            continue
        into = ctypes.create_string_buffer(count)
        if download(ctypes.c_int(device_id), into, 0, count) != 0:
            continue
        trace.blobs.append((trace.index(device_id), 0, into.raw))


def write_plan(trace, height, width, stem):
    """The calls, the buffers and the bytes, in two files.

    JSON for the calls: a plan is read once and argued with at length, and being able to
    open it is worth more than the bytes a binary would save. The masses go beside it in
    one file, in the order the blobs are listed.
    """
    blobs, laid = [], []
    with open(str(stem) + ".bin", "wb") as sink:
        for index, offset, data in trace.blobs:
            laid.append({"buffer": index, "offset": offset,
                         "length": len(data), "at": sink.tell()})
            sink.write(data)
            blobs.append(len(data))

    # The frame's way in, on its own. The replayer is a library for a caller that fills
    # this itself, and the only way to know a filled-in frame comes out right is to run
    # the one the Python ran and ask for the same answer — so the input has to be
    # available on its own, not only inside the plan's own file.
    wanted = height * width * 16 * 2      # the features: sixteen channels, half each
    for index, offset, data in trace.blobs:
        if len(data) == wanted and offset == 0:
            with open(str(stem) + "_in.bin", "wb") as sink:
                sink.write(data)
            break

    plan = {
        "extent": [height, width],
        "opcodes": trace.opcodes,
        "buffers": [{"bytes": trace.sizes[i], "kind": trace.kinds.get(i, 0)}
                    for i in trace.order],
        "calls": [[trace.opcode(name), args] for name, args in trace.calls],
        "blobs": laid,
    }
    with open(str(stem) + ".json", "w") as sink:
        json.dump(plan, sink)
    emit_c(trace, height, width, stem, laid)
    return sum(blobs)


def enum_order():
    """The opcodes in the order nr_plan.h numbers them.

    The plan's own names are in the order the recording happened to meet them, which is
    not the order the enum has. The replayer indexes the names by the enum, so the table
    has to be written in the enum's order — a name looked up by the wrong number is worse
    than no name at all, because it points the reader at the wrong call.
    """
    body = (ROOT / "src" / "gpu" / "nr_plan.h").read_text(encoding="utf-8")
    body = body.split("enum nr_op {", 1)[1].split("};", 1)[0]
    names = []
    for line in body.splitlines():
        line = line.split("/*")[0].strip().rstrip(",")
        if not line.startswith("OP_"):
            continue
        names.append(line.split("=")[0].strip())
    return names


def emit_c(trace, height, width, stem, laid):
    """The same plan as a static table, the way Mochi's nr_native_plan.cpp holds one.

    A plan is not data the replayer discovers at run time; it is what the build knows.
    Writing it as C means the replayer has nothing to parse, a diff between two extents
    is a diff anyone can read, and the passes are as inspectable as the Python that
    first walked them.
    """
    def constant(name):
        return "OP_" + name.upper()

    lines = ["/* generated by tools/dump_plan.py from a %dx%d recording — do not edit."
             % (width, height),
             " *",
             " * One row per call the resident frame made of libxmx: what the device was",
             " * asked to do, and with what. `nr_plan_signatures` says what each argument",
             " * is, because a row of integers does not. */",
             "",
             '#include "nr_plan.h"',
             ""]

    # Every path the recording named, in the order the steps name them. One entry per
    # path argument, not one per kind of call: `xmx_window_init` is called once per
    # window and each of those is a step of its own, so a table with one entry for the
    # lot would send every step after the first to read a path that is not there.
    texts = []
    for name, args in trace.calls:
        signature = trace.signatures.get(name, "ill")
        for at, letter in enumerate(signature):
            if letter == "s" and at < len(args):
                texts.append(str(args[at]))
    # Not static: the replayer reaches for these when a step names a shader.
    lines.append("const char *const nr_plan_text[] = {")
    lines.extend('    "%s",' % t.replace("\\", "\\\\").replace('"', '\\"')
                 for t in texts)
    lines.append("};")
    lines.append("")

    # Both tables are indexed by the enum, so both are written in the enum's order.
    order = enum_order()
    lines.append("const char *const nr_plan_names[] = {")
    for entry in order:
        # OP_XMX_WINDOW_INIT names the call xmx_window_init.
        lines.append('    "%s",' % entry[3:].lower())
    lines.append("};")
    lines.append("")
    lines.append("const char *const nr_plan_signatures[] = {")
    for entry in order:
        name = entry[3:].lower()
        lines.append('    "%s",' % trace.signatures.get(
            name, "ill" if name in ("buf", "up") else "i"))
    lines.append("};")
    lines.append("")

    lines.append("const struct nr_step nr_plan_steps[] = {")
    texts_seen = 0
    for name, args in trace.calls:
        signature = trace.signatures.get(name, "ill")
        cells, text = [], -1
        for at, value in enumerate(args):
            letter = signature[at] if at < len(signature) else "i"
            if letter == "s":
                text = texts_seen
                texts_seen += 1
                cells.append("0")
            elif letter == "f":
                # The bits of the float, as an integer: the replayer hands them back
                # without ever making a floating-point number of their own.
                cells.append("0x%x" % (value & 0xFFFFFFFF))
            else:
                cells.append(str(value))
        cells += ["0"] * (18 - len(cells)) if len(cells) < 18 else []
        lines.append("    { %s, %d, { %s }, %d },"
                     % (constant(name), len(args), ", ".join(cells), text))
    lines.append("};")
    lines.append("const unsigned nr_plan_step_count = %d;" % len(trace.calls))
    lines.append("")

    lines.append("const struct nr_buffer nr_plan_buffers[] = {")
    lines.extend('    { %dULL, %d },'
                 % (trace.sizes[i], trace.kinds.get(i, 0))
                 for i in trace.order)
    lines.append("};")
    lines.append("const unsigned nr_plan_buffer_count = %d;" % len(trace.order))
    lines.append("")

    lines.append("const struct nr_blob nr_plan_blobs[] = {")
    for blob in laid:
        lines.append("    { %d, %dULL, %dULL, %dULL },"
                     % (blob["buffer"], blob["offset"], blob["length"], blob["at"]))
    lines.append("};")
    lines.append("const unsigned nr_plan_blob_count = %d;" % len(laid))
    lines.append("")
    lines.append("const unsigned nr_plan_extent[2] = { %d, %d };" % (height, width))

    with open(str(stem) + ".c", "w") as sink:
        sink.write("\n".join(lines) + "\n")


def survey(trace):
    kinds = {}
    for name, _ in trace.calls:
        kinds[name] = kinds.get(name, 0) + 1
    return kinds


def main():
    height = int(sys.argv[1]) if len(sys.argv) > 1 else 448
    width = int(sys.argv[2]) if len(sys.argv) > 2 else 768
    stem = pathlib.Path(sys.argv[3]) if len(sys.argv) > 3 else \
        ROOT / "work" / ("plan_%dx%d" % (width, height))
    stem.parent.mkdir(parents=True, exist_ok=True)

    import numpy as np
    import xmxres
    import nr_model
    import nr_frame_resident as F

    trace = Trace()
    install(xmxres._load(), trace)

    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    rt = xmxres.Runtime()
    frame = F.ResidentFrame(rt, model.weights, height, width)
    rng = np.random.default_rng(11)
    features = (rng.standard_normal((height, width, 16)) * 0.3).astype(np.float32)
    head = frame.run(features)

    written = write_plan(trace, height, width, stem)
    passes = sum(count for name, count in survey(trace).items()
                 if name.startswith("xmx_rec_"))
    print("extent %dx%d  head sd %.4f  finite %s" % (width, height, head.std(),
                                                     bool(np.isfinite(head).all())))
    print("passes %d   calls %d   buffers %d   bytes written %.1f MB"
          % (passes, len(trace.calls), len(trace.order), written / 1e6))
    print("plan %s  reference head %s" % (stem, tuple(head.ravel()[:4])))


if __name__ == "__main__":
    main()
