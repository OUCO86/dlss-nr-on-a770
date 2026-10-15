#!/usr/bin/env python3
"""spv-memops.py -- load/store WIDTH x STORAGE CLASS in a compute SPIR-V.

The question (2026-10-15, after the e4m3 lesson): the frame is instruction-issue
bound (seniors: Load+Store = 27 % of instructions, 2.5x the arithmetic; the fill
experiment shows no idle issue slots). The lever is fewer memory INSTRUCTIONS for
the same bytes -- vectorization. But that only pays on GLOBAL accesses: a shared
(WORKGROUP) LDS is cheap, a 4-byte global load is a half-empty 16-byte transaction,
and a FUNCTION-class OpLoad/OpStore is a register move the driver keeps in the GRF
(unless it spills -- that is the "Scratch Memory Size" the pipeline stats report).
So this splits every OpLoad/OpStore by (storage class, width) and counts the
cooperative-matrix ops, which are their own opcodes (4453-4456), not OpExtInst.

    python src/bench/spv-memops.py [spv ...]
"""
import sys
import struct

OP_TYPE_INT, OP_TYPE_FLOAT = 21, 22
OP_TYPE_VECTOR, OP_TYPE_POINTER = 23, 32
OP_TYPE_STRUCTURE = 31
# KHR cooperative-matrix opcodes (SPIR-V 1.6 / VK_KHR_cooperative_matrix):
OP_TYPE_COOPMAT = 4453
OP_CM_LOAD, OP_CM_STORE, OP_CM_MULADD, OP_CM_LENGTH = 4454, 4455, 4456, 4457
OP_VARIABLE, OP_FUNCTION_PARAMETER = 59, 55
OP_LOAD, OP_STORE = 61, 62
OP_ACCESS_CHAIN, OP_PTR_ACCESS_CHAIN = 65, 66

# SpvStorageClass -> short name. Function(7) = register (or spill), Workgroup(4) =
# shared, and the buffer_reference pointers are PhysicalStorageBuffer (5347, seen as
# 5349 by some toolchains) -- those are the ones that hit DRAM.
SC = {0: "UniformConstant", 4: "SHARED", 6: "Private", 7: "register",
      8: "Generic", 9: "PushConst", 12: "STORAGEBUF", 5347: "GLOBAL", 5349: "GLOBAL"}

def parse(path):
    data = open(path, "rb").read()
    assert struct.unpack_from("<I", data, 0)[0] == 0x07230203, f"{path}: not SPIR-V"
    words = struct.unpack(f"<{len(data)//4}I", data)
    i, n = 5, len(words)
    types, vartype, insts = {}, {}, []
    while i < n:
        head = words[i]
        wc, op = head >> 16, head & 0xFFFF
        if wc == 0:
            break
        w = words[i:i + wc]
        insts.append((op, w))
        if op in (OP_TYPE_INT, OP_TYPE_FLOAT):
            types[w[1]] = ("i" if op == OP_TYPE_INT else "f", w[2])
        elif op == OP_TYPE_VECTOR:
            types[w[1]] = ("vec", w[3], w[2])           # (count, elem type id)
        elif op == OP_TYPE_POINTER:
            types[w[1]] = ("ptr", w[2], w[3])           # (storage class, base type id)
        elif op == OP_TYPE_STRUCTURE:
            types[w[1]] = ("struct",)
        elif op == OP_TYPE_COOPMAT:
            types[w[1]] = ("cm", w[3], w[4], w[5])      # (scope,M,N)
        if op in (OP_VARIABLE, OP_FUNCTION_PARAMETER, OP_ACCESS_CHAIN,
                  OP_PTR_ACCESS_CHAIN, OP_LOAD) and wc >= 3:
            vartype[w[2]] = w[1]
        i += wc

    def width_of(tid):
        t = types.get(tid)
        if not t:
            return None
        if t[0] in ("i", "f"):
            return t[1] // 8
        if t[0] == "vec":
            b = width_of(t[2])
            return None if b is None else b * t[1]
        return None

    def pointee(value_id):
        pt = types.get(vartype.get(value_id))
        if not pt or pt[0] != "ptr":
            return None
        sc = SC.get(pt[1], f"sc{pt[1]}")
        base = pt[2]
        if types.get(base, ("?",))[0] == "cm":
            cm = types[base]
            return sc, f"cm{cm[1]}x{cm[2]}"
        return sc, f"{width_of(base)}B"

    counts = {}
    def bump(k):
        counts[k] = counts.get(k, 0) + 1
    for op, w in insts:
        if op == OP_LOAD:
            pt = pointee(w[3])                          # OpLoad: w[3]=pointer
            bump(f"load {pt[0]} {pt[1]}" if pt else "load ?")
        elif op == OP_STORE:
            pt = pointee(w[1])                          # OpStore: w[1]=pointer
            bump(f"store {pt[0]} {pt[1]}" if pt else "store ?")
        elif op == OP_CM_LOAD:
            bump("coopmat-load")
        elif op == OP_CM_STORE:
            bump("coopmat-store")
        elif op == OP_CM_MULADD:
            bump("coopmat-mma")
    return counts

def main():
    paths = sys.argv[1:] or ["work/window_block.spv", "work/ffn_fused.spv",
                             "work/gemm_staged_int8.spv", "work/quantize_row.spv",
                             "work/window_attention.spv", "work/attention.spv"]
    for path in paths:
        try:
            counts = parse(path)
        except (OSError, AssertionError) as e:
            print(f"{path}: {e}")
            continue
        print(f"\n{path}")
        for k in sorted(counts, key=lambda k: -counts[k]):
            print(f"  {counts[k]:6d}  {k}")
        g = sum(v for k, v in counts.items() if "GLOBAL" in k or "STORAGEBUF" in k)
        s = sum(v for k, v in counts.items() if "SHARED" in k)
        r = sum(v for k, v in counts.items() if "register" in k)
        print(f"  => GLOBAL {g} | SHARED {s} | register-move {r} | "
              f"coopmat {counts.get('coopmat-load',0)}L/{counts.get('coopmat-store',0)}S"
              f"/{counts.get('coopmat-mma',0)}M")

if __name__ == "__main__":
    main()
