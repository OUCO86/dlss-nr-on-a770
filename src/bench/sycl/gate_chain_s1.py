#!/usr/bin/env python3
"""S1 chain gate (section 29: BUILD the healthy chain, do not benchmark the old one).

One transformer subgraph through the skeleton as a SINGLE begin/submit:
    fp16 activations --rec_quant--> int8+row_scale          (entry quantize, once)
    int8 --rec_gemm_s8rq--> int8+new_scale (row absmax fused in the producer epilogue)
    int8 --rec_gemm_s8rq--> int8+new_scale (SAME buffer read: zero intermediate quantize)

The structural point: pk2 is written by pass 2 and read by pass 3 inside ONE submit --
the downstream layer eats the upstream int8 output directly. The old chain pays a
quantize_row pass at every layer seam (276 of them, 3.09 ms); this chain pays ZERO,
because the producer owns the whole row and requantizes in its epilogue (v3, proven).
row_scale_A cancels inside the int8-straight-through world (v2's math, proven).

Gates are the SENIOR's bounded criteria, reused per segment, never a new golden:
  - entry quantize: vs int8_quant.quantise (scale<=1ulp, packed<=1, within-one)
  - each rq pass:   reconstruction (int8*new_scale) within-one of fp = acc*col_scale,
                    new_scale within 1ulp; the reference acc uses the DEVICE's int8
                    operand (downloaded), so pass 2's input identity is verified too.
"""
import ctypes, os, pathlib, sys
import numpy as np

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / "gpu"))
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[3] / "src" / "ref"))
import int8_quant
import nr_model as NM

for d in (os.getcwd(), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
          r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k32 = ctypes.windll.kernel32
_k32.SetErrorMode(0x8002)
for _dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    _p = pathlib.Path.cwd() / _dep
    if _p.exists():
        _k32.LoadLibraryExW(str(_p), 0, 0)

DLL = pathlib.Path.cwd() / "libxmx_sycl.dll"
if not DLL.exists():
    DLL = pathlib.Path(__file__).resolve().parent / "libxmx_sycl.dll"
lib = ctypes.CDLL(str(DLL))
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []), ("xmx_buf_create", [ctypes.c_ulonglong]),
    ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
    ("xmx_rec_quant", [ctypes.c_int] * 3 + [ctypes.c_uint] * 2),
    ("xmx_rec_gemm_s8rq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 3),
    ("xmx_rec_unary_i8", [ctypes.c_int] * 3 + [ctypes.c_uint] * 3),
):
    if hasattr(lib, nm):
        getattr(lib, nm).argtypes = at
        getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "xmx_init")

def within_one(got_i8, got_ns, fp, want_ns, label):
    """senior's bounded requantize criterion (same as gate_gemm_s8rq)."""
    step = got_i8.astype(np.float64) * got_ns.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - fp.astype(np.float64)) <= got_ns.astype(np.float64)[:, None] * limit
    sculp = int(np.abs(got_ns.view(np.int32) - want_ns.view(np.int32)).max())
    worst = float(np.max(np.abs(step - fp) / np.maximum(got_ns, 1e-30)[:, None]))
    ok(bool(within.all()) and sculp <= 1,
       f"{label}: within-one {bool(within.all())} (worst {worst:.5f} step), scale<=1ulp (max {sculp})")

def run_chain(M, K1, N, label):
    global fails
    assert N == 64 and M % 128 == 0 and K1 % 32 == 0
    rng = np.random.default_rng(42 + M + K1)
    vals = rng.uniform(-1, 1, (M, K1)).astype(np.float16).astype(np.float32)
    half = vals.astype(np.float16)
    # chain shape: (M,K1) --w1--> (M,N=64) --w2--> (M,64). rec_gemm_s8rq(a[M,K], b[K,N']).
    w1 = rng.integers(-127, 128, size=(K1, N), dtype=np.int8)
    w2 = rng.integers(-127, 128, size=(N, 64), dtype=np.int8)
    cs1 = (0.001 * (np.arange(N) % 37 + 1)).astype(np.float32)
    cs2 = (0.002 * (np.arange(64) % 29 + 1)).astype(np.float32)

    hsrc = lib.xmx_buf_create(M * K1 * 2)
    hpk1 = lib.xmx_buf_create_kind(M * K1, 1)
    hsc1 = lib.xmx_buf_create_kind(M * 4, 4)
    hw1  = lib.xmx_buf_create(K1 * N)
    hw2  = lib.xmx_buf_create(N * 64)
    hpk2 = lib.xmx_buf_create_kind(M * N, 1)
    hns2 = lib.xmx_buf_create_kind(M * 4, 4)
    hcs1 = lib.xmx_buf_create_kind(N * 4, 4)
    hpk3 = lib.xmx_buf_create_kind(M * 64, 1)
    hns3 = lib.xmx_buf_create_kind(M * 4, 4)
    hcs2 = lib.xmx_buf_create_kind(64 * 4, 4)
    hpub4 = lib.xmx_buf_create_kind(M * 64 * 4, 4)   # chain tail: float32 publish (half)
    hpub3 = lib.xmx_buf_create_kind(M * 64 * 4, 4)   # chain tail: float32 publish (gate+e4m3)
    ok(min(hsrc, hpk1, hsc1, hw1, hw2, hpk2, hns2, hcs1, hpk3, hns3, hcs2, hpub4, hpub3) > 0,
       f"{label}: 13 buffers")

    lib.xmx_buf_upload(hsrc, half.ctypes.data, 0, M * K1 * 2)
    lib.xmx_buf_upload(hw1, w1.ctypes.data, 0, K1 * N)
    lib.xmx_buf_upload(hw2, w2.ctypes.data, 0, N * 64)
    lib.xmx_buf_upload(hcs1, cs1.ctypes.data, 0, N * 4)
    lib.xmx_buf_upload(hcs2, cs2.ctypes.data, 0, 64 * 4)
    for h in (hpk1, hsc1, hpk2, hns2, hpk3, hns3, hpub4, hpub3): lib.xmx_buf_zero(h)

    # ONE submit carries the whole chain: quant -> rq GEMM -> rq GEMM -> publish tail
    # (4 passes where the old chain needs 6: quant, gemm, quant, gemm, dequant, publish --
    # the seam quantizes AND the dequant/publish round-trip are gone: the tail reads the
    # producer's int8+scale and does island-3 (scale multiply) + island-4 (rounding) once).
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    ok(lib.xmx_rec_quant(hsrc, hpk1, hsc1, M, K1) == 0, f"{label}: rec_quant")
    ok(lib.xmx_rec_gemm_s8rq(hpk1, hw1, hpk2, hcs1, hns2, M, N, K1) == 0, f"{label}: rq pass 2")
    ok(lib.xmx_rec_gemm_s8rq(hpk2, hw2, hpk3, hcs2, hns3, M, 64, N) == 0, f"{label}: rq pass 3 (reads pk2)")
    ok(lib.xmx_rec_unary_i8(hpk3, hns3, hpub4, M * 64, 64, 4) == 0, f"{label}: publish tail epi=4 (reads pk3)")
    ok(lib.xmx_rec_unary_i8(hpk3, hns3, hpub3, M * 64, 64, 3) == 0, f"{label}: publish tail epi=3 (reads pk3)")
    rc = lib.xmx_submit()
    ok(rc == 0, f"{label}: submit (whole chain, 5 passes)" +
       ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors='replace')))

    # downloads
    pk1 = np.zeros(M * K1, np.int8); lib.xmx_buf_download(hpk1, pk1.ctypes.data, 0, M * K1)
    sc1 = np.zeros(M, np.float32);   lib.xmx_buf_download(hsc1, sc1.ctypes.data, 0, M * 4)
    pk2 = np.zeros(M * N, np.int8);  lib.xmx_buf_download(hpk2, pk2.ctypes.data, 0, M * N)
    ns2 = np.zeros(M, np.float32);   lib.xmx_buf_download(hns2, ns2.ctypes.data, 0, M * 4)
    pk3 = np.zeros(M * 64, np.int8); lib.xmx_buf_download(hpk3, pk3.ctypes.data, 0, M * 64)
    ns3 = np.zeros(M, np.float32);   lib.xmx_buf_download(hns3, ns3.ctypes.data, 0, M * 4)
    pub4 = np.zeros(M * 64, np.float32); lib.xmx_buf_download(hpub4, pub4.ctypes.data, 0, M * 64 * 4)
    pub3 = np.zeros(M * 64, np.float32); lib.xmx_buf_download(hpub3, pub3.ctypes.data, 0, M * 64 * 4)

    # gate 1: entry quantize vs the shipped numpy contract (senior's bounded criterion)
    wp, ws = int8_quant.quantise(vals, 1)
    gp, gs = pk1.reshape(M, K1), sc1
    ulps = np.abs(gs.view(np.int32) - ws.view(np.int32))
    d = np.abs(gp.astype(np.int32) - wp.astype(np.int32))
    step = gp.astype(np.float64) * gs.astype(np.float64)[:, None]
    within = np.abs(step - vals.astype(np.float64)) <= gs.astype(np.float64)[:, None] * (0.5 + 2.0 ** -16)
    ok(int(ulps.max()) <= 1 and int(d.max()) <= 1 and bool(within.all()),
       f"{label} q0: scale<=1ulp(max {int(ulps.max())}), packed<=1(max {int(d.max())}), within-one {bool(within.all())}")

    # gate 2: rq pass 2 -- reference acc uses the DEVICE's pk1 (input identity proven by
    # gate 1 matching; here the acc is built from the SAME int8 bytes the kernel read).
    f32 = np.float32
    acc1 = pk1.reshape(M, K1).astype(np.int32) @ w1.astype(np.int32)
    fp1 = (acc1.astype(f32) * cs1.astype(f32)[None, :])
    rmax1 = np.max(np.abs(fp1), axis=1)
    wns2 = (rmax1 / f32(127.0)).astype(f32)
    within_one(pk2.reshape(M, N), ns2, fp1, wns2, f"{label} rq2 {M}x{N}x{K1}")

    # gate 3: rq pass 3 -- reads pk2 (the device's own int8 output of pass 2, no host
    # re-quantize anywhere in between: that is the chain).
    acc2 = pk2.reshape(M, N).astype(np.int32) @ w2.astype(np.int32)
    fp2 = (acc2.astype(f32) * cs2.astype(f32)[None, :])
    rmax2 = np.max(np.abs(fp2), axis=1)
    wns3 = (rmax2 / f32(127.0)).astype(f32)
    within_one(pk3.reshape(M, 64), ns3, fp2, wns3, f"{label} rq3 {M}x64x{N}")

    # gate 4: publish tail -- dequant(island-3) + rounding(island-4) of the DEVICE's own
    # pk3+ns3. The senior's contract for publish is BIT-EXACT (gate_unary.py: np.array_equal
    # vs nr_model), so the golden is int8_quant.dequantise's exact formula (packed.astype(
    # float32) * scale, row-broadcast) piped through nr_model's rounding points -- no new
    # golden, both halves are shipped authority already gated separately.
    deq = (pk3.reshape(M, 64).astype(f32) * ns3.astype(f32)[:, None]).ravel()
    want4 = NM._half_rounded(deq)
    want3 = NM.e4m3(NM.quadratic_gate_activation(deq))
    ok(np.array_equal(pub4, want4),
       f"{label} tail epi=4(half): BIT-EXACT vs dequantise+_half_rounded ({int((pub4 != want4).sum())} differ)")
    ok(np.array_equal(pub3, want3),
       f"{label} tail epi=3(gate+e4m3): BIT-EXACT vs dequantise+gate+e4m3 ({int((pub3 != want3).sum())} differ)")

    # structural count: the old chain for two GEMM layers + a published output =
    # 2 gemm + 3 quantize + 1 dequant/publish round-trip; this chain = 2 gemm + 1 entry
    # quantize + 1 fused tail (5 passes). The seam quantizes AND the half round-trip are
    # gone -- producer owns the row, tail reads int8+scale directly (islands 3+4, one pass).
    for h in (hsrc, hpk1, hsc1, hw1, hw2, hpk2, hns2, hcs1, hpk3, hns3, hcs2, hpub4, hpub3):
        lib.xmx_buf_destroy(h)

# M=8192: v3's M%128 constraint; R8a-legal big M. K1=64 entry, two N=64 rq layers.
run_chain(8192, 64, 64, "chain-l2")
# deep entry K=128 (stem-ish), still one chain
run_chain(8192, 128, 64, "chain-deepK")
# scores form: K=32 single-step (section 8's "attn scores N=64 K=32"; v2 expand precedent
# says K=32 is hardware-native -- one TK=32 MMA. v3's bench never tested K=32; this is the
# numeric gate for it: kb_n=1, the double-buffered loop runs exactly one iteration.)
run_chain(8192, 32, 64, "chain-K32")

print(f"\nCHAIN_S1 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
