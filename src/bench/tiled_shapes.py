"""What the float16 products are, and which of them the integer path declines.

`src/bench/device_families.py` says the products are 46 % of the device and that the
float16 half of that is 8.49 ms across 130 passes. The question is what those 130 are.
Shapes come from the hooks, which read them off their own arguments — unlike the
milliseconds, which are out of step.

    python src/bench/tiled_shapes.py
"""
import collections
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(ROOT / "work"))
import xmxres
import nr_model
import nr_frame_resident as F
import traffic_audit as TA

for name in TA.HOOKS:
    if hasattr(xmxres.Runtime, name):
        TA.wrap(name)

real_prepare = F.ResidentFrame._prepare_scratch


def counted(self, capture):
    out = real_prepare(self, capture)
    TA.CALLS.clear()
    return out


F.ResidentFrame._prepare_scratch = counted

model = nr_model.NeuralRenderingModel.from_safetensors(
    ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
rt = xmxres.Runtime()
frame = F.ResidentFrame(rt, model.weights, 448, 768)
frame.run(np.zeros((448, 768, 16), np.float32))
calls = list(TA.CALLS)

print(f"{len(calls)} calls in one frame\n")
print(f"  {'kind':22s} {'cols(N)':>8s} {'inner(K)':>9s} {'n':>5s} {'rows':>10s}  int8 gate")
rows_by = collections.defaultdict(list)
for c in calls:
    if c["kind"] != "gemm":
        continue
    rows_by[(c["cols"], c["inner"])].append(c["rows"])
for (cols, inner), rows in sorted(rows_by.items(), key=lambda kv: -len(kv[1])):
    gate = "yes" if cols % 32 == 0 and inner % 64 == 0 else (
        "K%64" if cols % 32 == 0 else "N%32")
    print(f"  {'gemm':22s} {cols:8d} {inner:9d} {len(rows):5d} "
          f"{min(rows):10d}  {gate}")

print(f"\n  {sum(len(v) for v in rows_by.values())} float16 products, of which "
      f"{sum(len(v) for k, v in rows_by.items() if k[0] % 32 == 0 and k[1] % 64 == 0)} "
      f"have a shape the integer GEMM would accept")

other = collections.Counter(c["kind"] for c in calls)
print("\n  every kind, by how many passes it records:")
for kind, n in other.most_common():
    print(f"    {kind:22s} {n:5d}")
