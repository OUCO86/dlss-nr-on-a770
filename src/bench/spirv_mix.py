"""What a compiled shader is made of.

`XMX_PIPELINE_STATS` gives one number for a kernel's size, and that number alone
cannot say why the kernel is slow: 7000 instructions spent on arithmetic and
7000 spent moving bytes are the same count. This reads the SPIR-V the compiler
actually produced and counts the opcodes, which is enough to tell them apart.

    python src/bench/spirv_mix.py work/window_block.spv [more.spv ...]

It is a count of the intermediate form, not of what the driver emits: `OpExtInst`
(GLSL.std.450) and the cooperative-matrix ops still have to be lowered, and the
driver will schedule what is left. Use it to find where a kernel's bulk is, not
to predict cycles.
"""

import collections
import struct
import sys

NAMES = {
    2: "SourceContinued", 3: "Source", 4: "SourceExtension", 5: "Name",
    6: "MemberName", 7: "String", 8: "Line", 9: "Extension",
    10: "ExtInstImport", 11: "ExtInst", 12: "MemoryModel",
    14: "EntryPoint", 15: "ExecutionMode", 16: "Capability",
    17: "TypeVoid", 19: "TypeInt", 20: "TypeFloat", 21: "TypeVector",
    22: "TypeMatrix", 23: "TypeImage", 24: "TypeSampler", 26: "TypeArray",
    27: "TypeRuntimeArray", 28: "TypeStruct", 29: "TypePointer",
    30: "TypeFunction", 43: "ConstantTrue", 44: "ConstantFalse",
    45: "Constant", 46: "ConstantComposite", 48: "ConstantNull",
    54: "Function", 55: "FunctionParameter", 56: "FunctionEnd",
    57: "FunctionCall", 59: "Variable", 61: "Load", 62: "Store",
    65: "AccessChain", 71: "Decorate", 77: "CompositeConstruct",
    78: "CompositeExtract", 80: "CopyObject",
    109: "VectorExtractDynamic", 111: "VectorShuffle",
    113: "UConvert", 114: "SConvert", 115: "FConvert",
    116: "QuantizeToF16", 124: "Bitcast", 125: "SNegate", 126: "FNegate",
    127: "IAdd", 128: "FAdd", 129: "ISub", 130: "FSub", 131: "IMul",
    132: "FMul", 133: "UDiv", 134: "SDiv", 135: "FDiv", 136: "UMod",
    137: "SRem", 141: "VectorTimesScalar", 147: "Dot", 152: "Any",
    153: "All", 154: "IsNan", 167: "Select", 168: "IEqual",
    169: "INotEqual", 170: "UGreaterThan", 174: "ULessThan",
    175: "SLessThan", 176: "ULessThanEqual", 177: "SLessThanEqual",
    178: "FOrdEqual", 182: "FOrdLessThan", 184: "FOrdGreaterThan",
    186: "FOrdLessThanEqual", 188: "FOrdGreaterThanEqual",
    190: "ShiftRightLogical", 191: "ShiftRightArithmetic",
    192: "ShiftLeftLogical", 193: "BitwiseOr", 194: "BitwiseXor",
    195: "BitwiseAnd", 196: "Not", 197: "BitFieldInsert",
    199: "BitFieldUExtract", 200: "BitReverse", 201: "BitCount",
    224: "MemoryBarrier", 225: "ControlBarrier", 245: "Phi",
    246: "LoopMerge", 247: "SelectionMerge", 248: "Label", 249: "Branch",
    250: "BranchConditional", 253: "Return", 254: "ReturnValue",
    4446: "CoopMatLoad", 4447: "CoopMatStore", 4448: "CoopMatMulAdd",
}

# What each one is for, grouped the way the question is usually asked.
GROUPS = (
    ("arithmetic", (127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137,
                    141, 147, 125, 126)),
    ("bit manipulation", (190, 191, 192, 193, 194, 195, 196, 197, 199, 200,
                          201)),
    ("conversion", (113, 114, 115, 116, 124)),
    ("compare and select", (152, 153, 154, 167, 168, 169, 170, 174, 175,
                            176, 177, 178, 182, 184, 186, 188)),
    ("memory", (61, 62)),
    ("addressing", (65,)),
    ("vector plumbing", (77, 78, 80, 109, 111)),
    ("cooperative matrix", (4446, 4447, 4448)),
    ("control flow", (245, 246, 247, 248, 249, 250, 253, 254, 57)),
    ("barrier", (224, 225)),
)


def read(path):
    raw = open(path, "rb").read()
    words = struct.unpack("<%dI" % (len(raw) // 4), raw)
    if words[0] != 0x07230203:
        raise SystemExit(f"{path}: not a SPIR-V module")
    counts = collections.Counter()
    at = 5
    while at < len(words):
        op, size = words[at] & 0xFFFF, words[at] >> 16
        if not size:
            break
        counts[op] += 1
        at += size
    return counts


def main(paths):
    for path in paths:
        counts = read(path)
        total = sum(counts.values())
        print(f"=== {path}: {total} instructions ===")
        for op, how in counts.most_common(24):
            print("  %-20s %6d  %5.1f%%" % (NAMES.get(op, f"op{op}"), how,
                                            100.0 * how / total))
        seen = set()
        print("  -- by kind --")
        for name, ops in GROUPS:
            how = sum(counts[o] for o in ops)
            seen.update(ops)
            print("  %-20s %6d  %5.1f%%" % (name, how, 100.0 * how / total))
        other = total - sum(counts[o] for o in seen)
        print("  %-20s %6d  %5.1f%%" % ("declarations etc.", other,
                                        100.0 * other / total))
        print()


if __name__ == "__main__":
    main(sys.argv[1:])
