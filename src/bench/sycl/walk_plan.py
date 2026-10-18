#!/usr/bin/env python3
"""plan-walk harness v2 (route(a) step 3): feed the SHIPPING plan (5254 steps) to MY dll
through the game ABI. Semantics copied from nr_replay.c's prepare() exactly:
  * OP_BUF creates; r->ids[plan number] = the device id (the ONLY place the two numbering
    meet, nr_replay.c:523-528).
  * argument translation uses the plan's OWN signature strings (nr_plan_signatures in
    plan_960x544.c, parallel to the opcodes table): 's' = a saved buffer id -> translate
    through ids[]; 'i' = plain integer -> pass through UNTOUCHED (v1's "translate any
    small int" rule is the section-25 trap: flags/M would get eaten); 'f' = float bits,
    carried verbatim (as_float, nr_replay.c:382-389).
  * blobs go in "once the buffers exist and before anything has been read" -- i.e. right
    BEFORE the first GRAPH_RUN (nr_replay.c:808-812), not at creation.
  * a GRAPH_RUN runs "what the last capture handed back" (r->graph, :505).
  * the scratch recording (begin@2529 ... abort@3902) is walked with everything else:
    an abort throws the recording away, exactly like the shipping replayer's active flag.
Scoreboard = steps walked + first failing op. This is a WALK, not a game frame: it does
not import the game's D3D12 colour/motion (the fused leg is nr_replay's, step 4's gate
will run the game-shaped version through nr_net itself once the ABI face is complete).
"""
import ctypes, json, os, pathlib, re, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
WORK = ROOT / "work"
ONEAPI = ROOT.parent.parent / "oneapi"

for d in (str(ONEAPI), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k = ctypes.windll.kernel32; _k.SetErrorMode(0x8002)
os.chdir(str(ONEAPI))
for dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    p = pathlib.Path.cwd() / dep
    if p.exists(): _k.LoadLibraryExW(str(p), 0, 0)

LIB = ctypes.CDLL(str(ONEAPI / "libxmx_sycl.dll"))
LIB.xmx_error.restype = ctypes.c_char_p
LL = ctypes.c_longlong

plan = json.load(open(WORK / "plan_960x544.json", encoding="utf-8"))
opcodes, calls, buffers, blobs = plan["opcodes"], plan["calls"], plan["buffers"], plan["blobs"]

# the signature table lives in the .c; extract in order, align with opcodes
src = open(WORK / "plan_960x544.c", encoding="utf-8", errors="replace").read()
m = re.search(r"nr_plan_signatures\[\] = \{(.*?)\n\};", src, re.S)
sigs = re.findall(r'"([^"]*)"', m.group(1))
assert len(sigs) == len(opcodes), f"signature/opcode misalignment {len(sigs)} vs {len(opcodes)}"
m = re.search(r"nr_plan_opcodes\[\] = \{(.*?)\n\};", src, re.S)
if m:
    names = re.findall(r'"([^"]*)"', m.group(1))
    assert names == opcodes, "opcode name tables disagree between .json and .c"

blob_bytes = (WORK / "plan_960x544.bin").read_bytes()
print(f"extent {plan['extent']}: {len(calls)} steps, {len(buffers)} buffers, {len(blobs)} blobs, {len(blob_bytes)} bytes")

if LIB.xmx_init() != 0:
    print("init FAILED:", LIB.xmx_error().decode()); sys.exit(1)
print("my dll live, device:", LIB.xmx_device().decode(errors="replace"))

# argtypes: every arg as c_longlong (x64 convention: 32-bit ints read the low half of
# the same slot; pointers are 64-bit; the shipping replayer passes a long long[] too).
def bind(name):
    fn = getattr(LIB, name, None)
    if fn is None: return None
    fn.restype = ctypes.c_longlong
    fn.argtypes = [LL] * 18
    return fn

ids = {}
graph_slot = 0
walked = 0
first_fail = None
blob_bufs = {}          # buffer -> list of blob slices
for bi, b in enumerate(blobs):
    blob_bufs.setdefault(b["buffer"], []).append(b)
blobs_done = False

def upload_all_blobs():
    global blobs_done
    for b in blobs:
        bid = ids.get(b["buffer"])
        if bid is None:
            return f"blob {b['buffer']} before its buffer exists"
        mv = memoryview(blob_bytes)[b["at"]:b["at"] + b["length"]]
        rc = LIB.xmx_buf_upload(ctypes.c_int(bid), ctypes.c_void_p(mv.ctypes.data),
                                ctypes.c_ulonglong(b["offset"]), ctypes.c_ulonglong(b["length"]))
        if rc != 0:
            return f"upload buffer {b['buffer']} offset {b['offset']}: {LIB.xmx_error().decode(errors='replace')}"
    blobs_done = True
    return None

def err(): return LIB.xmx_error().decode(errors="replace")

for si, (op, args) in enumerate(calls):
    name = opcodes[op]
    sig = sigs[op]
    if name == "buf":
        r = LIB.xmx_buf_create_kind(ctypes.c_ulonglong(int(args[1])), ctypes.c_int(2))
        if r < 0: first_fail = (si, name, err()); break
        ids[args[0]] = r
        walked += 1
        continue
    if name == "xmx_up":                 # OP_UP: the blobs carry these (nr_replay.c:471)
        walked += 1
        continue
    if name == "xmx_buf_ptr":            # licensed no-op for a replayer (:473-478)
        walked += 1
        continue
    if name == "xmx_graph_run":
        if not blobs_done:
            e2 = upload_all_blobs()
            if e2: first_fail = (si, name, e2); break
        r = LIB.xmx_graph_run(ctypes.c_int(graph_slot))
        if r < 0: first_fail = (si, name, f"run({graph_slot}): {err()}"); break
        walked += 1
        continue
    if name == "xmx_graph_capture":
        r = LIB.xmx_graph_capture()
        if r < 0: first_fail = (si, name, err()); break
        graph_slot = r
        walked += 1
        continue
    fn = bind(name)
    if fn is None:
        first_fail = (si, name, "not exported by my dll")
        break
    ca = []
    for j, v in enumerate(args):
        c = sig[j] if j < len(sig) else "i"
        if c == "s":
            if v not in ids:
                first_fail = (si, name, f"arg{j} buffer {v} not created yet"); ca = None; break
            ca.append(LL(ids[v]))
        else:
            ca.append(LL(int(v)))
    if ca is None: break
    r = fn(*ca)
    if r < 0:
        first_fail = (si, name, err()); break
    walked += 1

print(f"\nwalked {walked}/{len(calls)} steps | buffers {len(ids)}/{len(buffers)} | blobs {'uploaded' if blobs_done else 'not reached'}")
if first_fail:
    print(f"first failure: step {first_fail[0]} op={first_fail[1]}  {first_fail[2]}")
    # where in the plan is that step: recording or scratch?
    pos = first_fail[0]
    phase = "scratch (pre-abort)" if pos < 3902 else ("recording (captured graph)" if pos < 5251 else "post-capture")
    print(f"phase: {phase}")
else:
    print("PLAN WALK COMPLETE: every step of the shipping plan ran on the Level-Zero engine")
