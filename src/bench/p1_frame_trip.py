#!/usr/bin/env python3
"""P1 frame-level quality scaffold: run ONE real frame through the real resident graph
twice -- (A) shipped coopmat int8 QKV, (B) my L0 int8 chain swapped in at the QKV seam via
host-bounce -- and diff the FINAL answer images. Paired, both real shipping pipelines;
unlike section 57's whole-net proxy the baseline IS the pixels the game shows today, so the
diff means exactly what it says.

SCAFFOLD BY CONSTRUCTION (the user's ruling 2026-10-17): the bounce costs a host round-trip
per QKV and exists to SEE the image, not to ship it. Once the diff is small and the user's
LOP eyes agree, this file and its kin get deleted and the work returns to the real
single-world path (dual-engine buffers, BN=128 fold, megakernel window batching).

Modelled on the two senior patterns, copied not invented:
  - src/bench/one_frame_trip.py  (drive the daemon on a real capture, collect answers)
  - src/bench/int8_bottleneck.py int8_rows: runtime.submit() -> host-round the buffer ->
    runtime.begin() to resume recording -- the bounce point.

    python3 src/bench/p1_frame_trip.py           # coop baseline -> work/p1_frame_coop.npz
    python3 src/bench/p1_frame_trip.py --l0      # my chain     -> work/p1_frame_l0.npz
    python3 src/bench/p1_frame_trip.py --diff    # the two answer sets -> damage table
"""
import ctypes, json, os, pathlib, struct, subprocess, sys, tempfile, threading, time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
ONER = ROOT.parent.parent
W, H = 1920, 1080
ANSWER = 4 * W * H

MODE = "coop"
MY = None
_L0 = {"hit": 0, "fellback": 0}


def load_my_dll():
    global MY
    for d in (str(ONER / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
              r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
        if os.path.isdir(d):
            try: os.add_dll_directory(d)
            except OSError: pass
    _k = ctypes.windll.kernel32
    _k.SetErrorMode(0x8002)
    for dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
        p = ONER / "oneapi" / dep
        if p.exists():
            _k.LoadLibraryExW(str(p), 0, 0)
    MY = ctypes.CDLL(str(ONER / "oneapi" / "libxmx_sycl.dll"))
    MY.xmx_error.restype = ctypes.c_char_p
    for nm, at in (
        ("xmx_init", []), ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
        ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
        ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
        ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
        ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
        ("xmx_rec_gemm_qkv_v_i8", [ctypes.c_int] * 6 + [ctypes.c_uint] * 4),
        ("xmx_rec_gemm_qkv_deq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 2),
        ("xmx_rec_cosine_norm_i8", [ctypes.c_int] * 3 + [ctypes.c_uint] * 2 + [ctypes.c_int, ctypes.c_uint]),
    ):
        getattr(MY, nm).argtypes = at
        getattr(MY, nm).restype = ctypes.c_int
    if MY.xmx_init() != 0:
        raise SystemExit("L0 init: " + MY.xmx_error().decode())


def install_l0_qkv(rt):
    """monkeypatch Runtime.gemm_int8_qkv: bounce the SAME resident int8 operands/scales to
    host, run my L0 six-pass QKV (section 46's chain, verbatim recorder calls), boundary-
    publish e4m3-f16, write into q16/key16/v16, resume recording. Only the seam form
    changes: coopmat->e4m3 vs requant-int8->boundary-publish. Blocks whose shape my chain's
    guard refuses (tokens != 64, rows % 128, vit) fall back to the shipped kernel, and the
    counters say which is which -- the scaffold measures only what it swaps."""
    import xmxres
    orig = rt.gemm_int8_qkv

    def bounce(a, b, q, k, v, a_scale, b_scale, qkv_scale, rows, channels, heads, tokens,
               *, vit=False):
        if vit or tokens != 64 or (rows % 128) or (channels % 64):
            _L0["fellback"] += 1
            return orig(a, b, q, k, v, a_scale, b_scale, qkv_scale, rows, channels, heads,
                        tokens, vit=vit)
        rt.submit()                       # the senior's int8_rows pattern: flush, round, resume
        a8 = xmxres.host_view(a, np.int8, shape=(rows, channels)).copy()
        wb = xmxres.host_view(b, np.int8, shape=(3 * channels, channels)).copy()
        asc = xmxres.host_view(a_scale, np.float32, shape=(rows,)).copy()
        bsc = xmxres.host_view(b_scale, np.float32, shape=(3 * channels,)).copy()
        qs = xmxres.host_view(qkv_scale, np.float32, shape=(heads,)).copy()
        wQ = np.ascontiguousarray(wb[0:channels].T)          # my chain: (K=in, N=out) slices
        wK = np.ascontiguousarray(wb[channels:2 * channels].T)
        wV = np.ascontiguousarray(wb[2 * channels:3 * channels].T)
        windows = rows // tokens
        mb = lambda n, kind: MY.xmx_buf_create_kind(n, kind)
        ma = mb(rows * channels, 1)
        mQ, mK, mV = mb(channels * channels, 1), mb(channels * channels, 1), mb(channels * channels, 1)
        mas = mb(rows * 4, 4)
        mQs, mKs, mVs = mb(channels * 4, 4), mb(channels * 4, 4), mb(channels * 4, 4)
        mqf, mkf = mb(rows * channels * 4, 4), mb(rows * channels * 4, 4)
        mq8, mk8, mv8 = mb(rows * channels, 1), mb(rows * channels, 1), mb(rows * channels, 1)
        mqs, mks = mb(rows * heads * 4, 4), mb(rows * heads * 4, 4)
        mvs = mb(windows * channels * 4, 4); mqkvs = mb(heads * 4, 4)
        def up(h, arr, n):
            assert MY.xmx_buf_upload(h, np.ascontiguousarray(arr).ctypes.data, 0, n) == 0, \
                MY.xmx_error().decode()
        up(ma, a8, rows * channels)
        up(mQ, wQ, channels * channels); up(mK, wK, channels * channels); up(mV, wV, channels * channels)
        up(mas, asc, rows * 4)
        up(mQs, bsc[0:channels], channels * 4); up(mKs, bsc[channels:2 * channels], channels * 4)
        up(mVs, bsc[2 * channels:3 * channels], channels * 4)
        up(mqkvs, qs, heads * 4)
        for h in (mqf, mkf, mq8, mk8, mv8, mqs, mks, mvs): MY.xmx_buf_zero(h)
        MY.xmx_begin()
        assert MY.xmx_rec_gemm_qkv_v_i8(ma, mV, mv8, mvs, mas, mVs, rows, channels, heads, tokens) == 0, MY.xmx_error().decode()
        assert MY.xmx_rec_gemm_qkv_deq(ma, mQ, mqf, mas, mQs, rows, channels) == 0, MY.xmx_error().decode()
        assert MY.xmx_rec_cosine_norm_i8(mqf, mq8, mqs, rows * heads, 0, mqkvs, heads) == 0, MY.xmx_error().decode()
        assert MY.xmx_rec_gemm_qkv_deq(ma, mK, mkf, mas, mKs, rows, channels) == 0, MY.xmx_error().decode()
        assert MY.xmx_rec_cosine_norm_i8(mkf, mk8, mks, rows * heads, 0, 0, 0) == 0, MY.xmx_error().decode()
        assert MY.xmx_submit() == 0, MY.xmx_error().decode()
        def dlf(h, n, dt):
            arr = np.zeros(n, dt); MY.xmx_buf_download(h, arr.ctypes.data, 0, arr.nbytes); return arr
        q8 = dlf(mq8, rows * channels, np.int8).reshape(rows * heads, 32)
        k8 = dlf(mk8, rows * channels, np.int8).reshape(rows * heads, 32)
        v8 = dlf(mv8, rows * channels, np.int8).reshape(rows, channels)
        qsc = dlf(mqs, rows * heads, np.float32)[:, None]
        ksc = dlf(mks, rows * heads, np.float32)[:, None]
        vsc = dlf(mvs, windows * channels, np.float32)
        for h in (ma, mQ, mK, mV, mas, mQs, mKs, mVs, mqf, mkf, mq8, mk8, mv8,
                  mqs, mks, mvs, mqkvs):
            MY.xmx_buf_destroy(h)
        import nr_model as NM
        qp = NM.e4m3(q8.astype(np.float32) * qsc).astype(np.float16).reshape(rows, channels)
        kp = NM.e4m3(k8.astype(np.float32) * ksc).astype(np.float16).reshape(rows, channels)
        vwin = np.repeat(vsc.reshape(windows, channels), tokens, axis=0).reshape(rows, channels)
        vp = NM.e4m3(v8.astype(np.float32) * vwin).astype(np.float16)
        # my Q/K come out linear (row, head*32+chan); the consumers read the shipped
        # (window,head,token,32) scatter -- vectorised inverse of qkv_epilogue's at():
        def scatter(grid):
            w_idx = np.arange(rows) // tokens
            t_idx = np.arange(rows) % tokens
            heads_idx = np.arange(channels) // 32
            chan_idx = np.arange(channels) % 32
            W, T, Hd = np.meshgrid(w_idx, t_idx, heads_idx, indexing="ij")
            Ch = np.tile(chan_idx, (rows, 1))
            at = ((W[..., None] * heads + Hd[..., None]) * tokens + T[..., None]) * 32 + Ch
            out = np.empty(rows * channels, np.float16)
            out[at.ravel()] = grid.ravel()
            return out
        xmxres.host_write(q, scatter(qp))
        xmxres.host_write(k, scatter(kp))
        xmxres.host_write(v, vp.reshape(rows * channels))
        _L0["hit"] += 1
        rt.begin()                        # resume recording the rest of the graph
    rt.gemm_int8_qkv = bounce
    # DIAGNOSTIC (the swapped=0 hunt): count the OTHER QKV door too, and print the
    # runtime's switch state -- the shipped comment (xmxres.py:840) warns the int8 flags
    # are only what set_int8 made them; if the weight objects predate it, qkv8 is None
    # and record_qkv_projection takes the gemm_qkv (fp16 epilogue) branch instead.
    orig_q = rt.gemm_qkv
    def count_q(*args, **kw):
        _L0["fellback"] += 1
        return orig_q(*args, **kw)
    rt.gemm_qkv = count_q
    print(f"  DIAG runtime switches: int8_project={getattr(rt, 'int8_project', None)} "
          f"int8_qkv={getattr(rt, 'int8_qkv', None)} qkv_epilogue={getattr(rt, 'qkv_epilogue', None)}",
          flush=True)


def child(source, frames, out, l0):
    for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
        sys.path.insert(0, str(ROOT / sub))
    os.environ["NR_EXTMEM"] = "1"; os.environ["NR_POSTPASS"] = "1"
    os.environ["NR_LAYER_PID"] = str(os.getpid()); os.environ["NR_EXTMEM_ANSWER"] = "0"
    # BOTH passes live-record per block. The replay mode replays a CACHED Vulkan command
    # graph and never calls the Python record functions, so (a) the monkeypatched bounce
    # would silently never fire (nr_resident.py:155's warning: a switch that "measured as
    # working while doing nothing at all in a real run") and (b) replay-coop vs block-l0
    # would fold block-vs-replay into the diff. Same mode both sides -> the diff isolates
    # the seam alone; the _L0 hit counter guards that the swap really ran.
    os.environ["NR_FRAME_MODE"] = "block"
    import live_rates, nr_daemon, nr_pipe, xmxres
    box = {}
    publish = nr_daemon._extmem_publish
    def watch(args, backend, *rest, **kw):
        got = publish(args, backend, *rest, **kw)
        box["sid"] = getattr(args, "extmem_sem", None); box["backend"] = backend
        if l0:
            load_my_dll()
            install_l0_qkv(backend.runtime)
            print("  >>> L0 QKV chain installed at the gemm_int8_qkv seam", flush=True)
        return got
    nr_daemon._extmem_publish = watch

    endpoint = rf"\\.\pipe\nr_p1_{os.getpid()}_{int(l0)}"
    payload = source.tobytes()

    def drive():
        for _ in range(3000):
            try: open(endpoint, "r+b", buffering=0).close(); break
            except OSError: time.sleep(0.005)
        mapping = nr_pipe.FrameMapping(endpoint, 1 << 22)
        def trip(data, want):
            last = None
            for _ in range(200):
                try:
                    with open(endpoint, "r+b", buffering=0) as pipe:
                        view = memoryview(data)
                        while view: view = view[pipe.write(view):]
                        got = bytearray()
                        while len(got) < want:
                            piece = pipe.read(want - len(got))
                            if not piece: raise RuntimeError(f"{len(got)} of {want}")
                            got += piece
                    return bytes(got)
                except OSError as e: last = e; time.sleep(0.02)
            raise RuntimeError(f"pipe never opened: {last!r}")
        header = struct.pack("<4I", live_rates.MAGIC, W, H, live_rates.FORMAT_B8G8R8A8)
        trip(header + payload, ANSWER)
        backend, sid = box["backend"], box.get("sid")
        raw = backend.extmem_view(ANSWER)
        lib = xmxres._load()
        answers = []
        for index in range(1, frames + 1):
            ctypes.memmove(raw.ctypes.data, payload, len(payload))
            if lib.xmx_sem_signal(int(sid), index) != 0: raise RuntimeError("sem_signal")
            slot = index % mapping.slots
            told = struct.unpack("<I", trip(struct.pack("<4I", nr_daemon.MAGIC_EXTMEM, W, H,
                        live_rates.FORMAT_B8G8R8A8) + struct.pack("<I", slot) +
                        struct.pack("<Q", index), 4))[0]
            if told & 0x80000000:
                at, count = struct.unpack_from("<II", mapping.answer(slot, 8), 0)
                buf = backend._extmem_answer
                whole = xmxres.host_view(buf, np.uint8, shape=(buf.nbytes,))
                answers.append(np.ascontiguousarray(whole[at:at + count]).copy())
            else:
                answers.append(np.frombuffer(mapping.answer(slot, told), np.uint8).copy())
        np.savez(out, **{f"answer_{i}": np.array(a, np.uint8) for i, a in enumerate(answers)},
                 swapped=np.array(_L0["hit"]), fellback=np.array(_L0["fellback"]))
        print(f"    L0 seam: swapped={_L0['hit']} fellback={_L0['fellback']}", flush=True)
    room = pathlib.Path(tempfile.mkdtemp(prefix="p1-frame-"))
    settings = room / "settings.json"
    played = ROOT / "work" / "nr_settings.json"
    settings.write_text(played.read_text() if played.exists()
                        else json.dumps({"render_scale": 0.4, "int8": 1}))
    threading.Thread(target=drive, daemon=True).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(1 << 22)]
    nr_daemon.main()


def damage(a, b):
    d = np.abs(a.astype(np.int32) - b.astype(np.int32)).max(axis=-1)
    return f"mean {d.mean():.4f} p99 {np.percentile(d, 99):.1f} max {d.max()} | " + \
        " ".join(f">{t}:{np.count_nonzero(d > t) * 100.0 / d.size:5.3f}%" for t in (1, 2, 4, 8))


def _collect(out, tag):
    """gather a child's answers into work/p1_frame_<tag>.npz, carrying the swap counters."""
    got = np.load(out)
    answers = sorted((k for k in got.files if k.startswith("answer_")),
                     key=lambda k: int(k.split("_")[-1]))
    frame = np.load(out).get("source")
    np.savez(ROOT / "work" / f"p1_frame_{tag}.npz",
             **{k: got[k] for k in answers},
             swapped=got["swapped"], fellback=got["fellback"])
    return int(got["swapped"]), int(got["fellback"])


def _diff_and_report(coop_sw, l0_sw, l0_fb):
    a = np.load(ROOT / "work" / "p1_frame_coop.npz")
    b = np.load(ROOT / "work" / "p1_frame_l0.npz")
    # THE guard (nr_resident.py:155 trap): a diff of two identical pipelines that never
    # swapped would read as "perfect, zero damage" -- a false GREEN. Require the L0 pass
    # to have actually swapped the QKV seam a nonzero number of times before trusting
    # any number below.
    assert l0_sw > 0, f"L0 pass swapped 0 QKV seams -- the diff is meaningless (fellback={l0_fb})"
    print(f"  swap fired: L0 QKV seams swapped={l0_sw} fellback={l0_fb} (coop baseline is pure shipped)")
    for idx in (1, 2):                       # frame 1 warms the temporal gate; settle after
        ca = a[f"answer_{idx}"].reshape(H, W, 4)
        cb = b[f"answer_{idx}"].reshape(H, W, 4)
        print(f"  frame {idx+1}: coop-vs-L0 seam diff {damage(ca, cb)}")


def main():
    if "--child" in sys.argv:
        i = sys.argv.index("--child")
        child(np.load(sys.argv[i + 1]), int(sys.argv[i + 2]), sys.argv[i + 3], "--l0" in sys.argv)
        return 0
    from read_capture import read
    frame = np.ascontiguousarray(read(str(ROOT / "work" / "capture.nrn"))["bgra"])
    counters = {}
    for l0 in (False, True):
        room = pathlib.Path(tempfile.mkdtemp(prefix="p1-")); payload = room / "frame.npy"
        np.save(payload, frame)
        out = room / "answers.npz"
        args = [sys.executable, str(pathlib.Path(__file__).resolve()), "--child",
                str(payload), "3", str(out)] + (["--l0"] if l0 else [])
        subprocess.run(args, check=False)
        if not out.exists():
            print(f"  no answers for l0={l0}"); return 1
        tag = "l0" if l0 else "coop"
        sw, fb = _collect(out, tag)
        counters[tag] = (sw, fb)
        print(f"  saved {tag}: swapped={sw} fellback={fb}")
    _diff_and_report(counters["coop"][0], counters["l0"][0], counters["l0"][1])
    return 0


if __name__ == "__main__":
    sys.exit(main())


if __name__ == "__main__":
    if "--diff" in sys.argv:
        sys.argv = [sys.argv[0], "--diff"]
    sys.exit(main())
