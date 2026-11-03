#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""patch_testdefs.py -- add COMPILE-TIME default hooks to the in-tree switches so a test
artifact can ship with a shovel ON without env vars (the game process cannot set env).

Target: E:/DSH/dlss-nr-on-a770/src/bench/sycl/libxmx_sycl.cpp

Rules honoured (user discipline 2026-11-02):
  * shipped semantics unchanged: env var still WINS over the macro default;
  * every hook is #ifdef-guarded => a build WITHOUT the -D macros compiles the ORIGINAL
    code path verbatim (verified separately: no-macro build -> walk 1301 EXACT vs golden);
  * no kernel body touched, no runtime branch added inside a kernel (jun-gui 4/9).

Macros introduced (values are the shovel's own vocabulary):
  T_RES_BYTE_DEF   int   1=s8row 2=e4m3w 3=s8mid      (NR_RES_BYTE default)
  T_RES_GRAN_DEF   int   rows per pow2 scale          (NR_RES_GRAN default when mode on)
  T_RES_SITES_DEF  str   comma list of site families  (NR_RES_SITES default: residual/wres/batched)
  T_SKIP_CHAINS_DEF str  comma list of chain ids      (NR_SKIP_CHAINS default)

Usage:  python patch_testdefs.py [--dry] [--revert]
"""
import sys, io, os, hashlib

SRC = os.environ.get("T_SRC", r"E:/DSH/dlss-nr-on-a770/src/bench/sycl/libxmx_sycl.cpp")
for _a in sys.argv[1:]:
    if _a.startswith("--src="):
        SRC = _a.split("=", 1)[1]

# (find, replace) pairs. find must appear EXACTLY once.
EDITS = [
    # --- 1) NR_RES_BYTE default -------------------------------------------------
    ('''    static int m = [](){
        const char* s = getenv("NR_RES_BYTE");
        if (!s || !*s) return 0;
''',
     '''    static int m = [](){
        const char* s = getenv("NR_RES_BYTE");
        if (!s || !*s) {
#ifdef T_RES_BYTE_DEF
            return T_RES_BYTE_DEF;     // TEST BUILD: compile-time default (env still wins)
#else
            return 0;
#endif
        }
'''),
    # --- 2) NR_RES_GRAN default -------------------------------------------------
    ('''        if (s && *s) { int v = atoi(s); return (v > 0) ? (unsigned)v : 1u; }
        return rb_mode() == 2 ? 64u : 1u;
''',
     '''        if (s && *s) { int v = atoi(s); return (v > 0) ? (unsigned)v : 1u; }
#ifdef T_RES_GRAN_DEF
        if (rb_mode() > 0) return (unsigned)T_RES_GRAN_DEF;   // TEST BUILD default granularity
#endif
        return rb_mode() == 2 ? 64u : 1u;
'''),
    # --- 3) NR_RES_SITES default ------------------------------------------------
    ('''    static const char* sel = getenv("NR_RES_SITES");
    if (!sel || !*sel) return true;
''',
     '''    static const char* sel = getenv("NR_RES_SITES");
#ifdef T_RES_SITES_DEF
    if ((!sel || !*sel) && rb_mode() > 0) sel = T_RES_SITES_DEF;   // TEST BUILD: site families
#endif
    if (!sel || !*sel) return true;
'''),
    # --- 4) NR_SKIP_CHAINS default ----------------------------------------------
    ('''        std::vector<int> out;
        const char* s = getenv("NR_SKIP_CHAINS");
        if (s) {
''',
     '''        std::vector<int> out;
        const char* s = getenv("NR_SKIP_CHAINS");
#ifdef T_SKIP_CHAINS_DEF
        if (!s || !*s) s = T_SKIP_CHAINS_DEF;   // TEST BUILD: compile-time chain list
#endif
        if (s) {
'''),
    # --- 5) record-time evidence: the skip header prints the effective list ------
    ('''getenv("NR_SKIP_CHAINS") ? getenv("NR_SKIP_CHAINS") : "");''',
     '''getenv("NR_SKIP_CHAINS") ? getenv("NR_SKIP_CHAINS")
#ifdef T_SKIP_CHAINS_DEF
                 : T_SKIP_CHAINS_DEF);
#else
                 : "");
#endif'''),
    # --- 6) record-time evidence: res-byte census prints the effective site list --
    ('''getenv("NR_RES_SITES") ? getenv("NR_RES_SITES") : "*",''',
     '''getenv("NR_RES_SITES") ? getenv("NR_RES_SITES")
#ifdef T_RES_SITES_DEF
                                   : T_RES_SITES_DEF,
#else
                                   : "*",
#endif'''),
]


def main():
    args = sys.argv[1:]
    dry = "--dry" in args
    rev = "--revert" in args
    s = io.open(SRC, encoding="utf-8", newline="").read()
    orig = s
    print("before md8:", hashlib.md5(s.encode("utf-8")).hexdigest()[:8], "lines:", s.count("\n") + 1)
    if rev:
        for find, repl in EDITS:
            n = s.count(repl)
            if n != 1:
                print("REVERT ABORT: replacement text found %d times" % n)
                return 2
            s = s.replace(repl, find, 1)
    else:
        for i, (find, repl) in enumerate(EDITS, 1):
            n = s.count(find)
            if n != 1:
                print("ABORT edit %d: anchor found %d times (expected 1)" % (i, n))
                return 2
            if repl in s:
                print("ABORT edit %d: replacement already present (already patched?)" % i)
                return 2
            s = s.replace(find, repl, 1)
    if s == orig:
        print("no change"); return 0
    print("after  md8:", hashlib.md5(s.encode("utf-8")).hexdigest()[:8], "lines:", s.count("\n") + 1)
    if dry:
        print("dry run: nothing written"); return 0
    io.open(SRC, "w", encoding="utf-8", newline="").write(s)
    print("wrote", SRC)
    return 0


if __name__ == "__main__":
    sys.exit(main())
