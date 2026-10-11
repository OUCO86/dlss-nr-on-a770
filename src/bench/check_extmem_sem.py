#!/usr/bin/env python3
"""Does a submit really wait on a semaphore that came from another process?

The second gate in notes/phase2-extmem-design.md section 5. Sharing a buffer is not
enough on its own: the frame's bytes are written by the layer's CPU, which is not in
any queue, so the only thing that puts those writes before the daemon's first pass is
a semaphore the layer signals. If the wait is dropped somewhere between
`xmx_sem_import` and `vkQueueSubmit`, nothing here fails — the frame just silently
reads bytes that have not arrived yet. So this test does not check that a submit
succeeds; it checks that a submit is *slow*.

  1. spawn `extmem_xproc.exe semhost <our pid>`, which exports a semaphore, duplicates
     it into this process, and signals it only after a delay we choose;
  2. import it through libxmx the way the daemon would and ask for the next submit to
     wait on it;
  3. time that submit. It cannot return before the delay is up. Then time a submit
     with no wait at all, which must return at once.

    python src/bench/check_extmem_sem.py [delay-ms]

Exits non-zero if the waited submit was not held back, or if anything failed.
"""
import os
import pathlib
import subprocess
import sys
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))

import xmxres  # noqa: E402

EXE = ROOT / "work" / "extmem_xproc.exe"
M, N, K = 256, 256, 256


def say_host(proc, command):
    """Send `command` to a semhost and return everything it printed."""
    proc.stdin.write(command + "\n")
    proc.stdin.flush()
    out, _ = proc.communicate(timeout=120)
    print("--- semhost ---")
    print(out.rstrip())
    print("---------------")
    return out


def driver_self_test(delay_ms):
    """Stage one: does a wait hold a submit back at all, before any process boundary?

    If this fails, the cross-process result cannot be read as a Phase 2 problem —
    the card would be ignoring waits in its own process too.
    """
    proc = subprocess.Popen([str(EXE), "semhost", str(os.getpid())],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, bufsize=1)
    try:
        out = say_host(proc, f"waittest {delay_ms}")
        return proc.returncode, out
    finally:
        if proc.poll() is None:
            proc.kill()


def main():
    delay_ms = int(sys.argv[1]) if len(sys.argv) > 1 else 1500
    if not EXE.exists():
        print(f"missing {EXE} — build it with tools\\build_extmem_xproc.bat")
        return 1

    print("[1] does a waited submit wait, in one process?")
    code, out = driver_self_test(delay_ms)
    if code:
        print("\nFAILED: the driver ignored a wait inside one process. Nothing about "
              "Phase 2 can work until that is understood.")
        return 1
    print("    yes — the first batch ran after the second, so waits are real\n")

    print("[2] does a wait survive coming from another process?")
    rt = xmxres.Runtime()
    if not rt.extmem_available():
        print("this libxmx.dll cannot import a semaphore — rebuild with "
              "tools\\build_msvc.bat")
        return 1

    a = rt.buffer(M * K, np.float16)
    w = rt.buffer(K * N, np.float16)
    c = rt.buffer(M * N, np.float32)

    def submit():
        rt.begin()
        rt.gemm(a, w, c, M, N, K)
        started = time.perf_counter()
        rt.submit()
        return time.perf_counter() - started

    plain_before = submit()   # warms the pipeline and gives a baseline

    # The host signals only after `delay_ms`; it is a child of this process, so it can
    # hand its handle back to us by duplication, exactly the way the layer will.
    proc = subprocess.Popen([str(EXE), "semhost", str(os.getpid())],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, bufsize=1)
    try:
        # the host says which device it picked before it offers the handle
        banner = ""
        for _ in range(20):
            banner = proc.stdout.readline().strip()
            if banner.startswith("S ") or not banner:
                break
            print(f"  semhost: {banner}")
        if not banner.startswith("S "):
            print(f"semhost did not offer a handle: {banner!r}")
            return 1
        handle = int(banner[2:], 16)
        print(f"semhost duplicated a semaphore into this process as {handle:#x}")

        proc.stdin.write(f"signal-after {delay_ms}\n")
        proc.stdin.flush()

        sid = rt.import_semaphore(handle)
        print(f"imported as semaphore {sid}; asking the next submit to wait on it")
        proc.stdin.write(f"signal-after {delay_ms}\n")
        proc.stdin.flush()

        # Twice in a row, because an imported semaphore that arrives already signalled
        # would let the first wait straight through and only hold the second. That is
        # worth telling apart from a wait that never bites at all: the first case loses
        # one frame's worth of ordering, the second loses all of them.
        rt.extmem_wait(sid)
        print(f"  pending before the first submit: {rt.extmem_wait_pending()}")
        held = submit()
        print(f"  pending after the first submit:  {rt.extmem_wait_pending()}")
        rt.extmem_wait(sid)
        held2 = submit()
        plain_after = submit()

        proc.stdin.write("quit\n")
        proc.stdin.flush()
        out, _ = proc.communicate(timeout=60)
    finally:
        if proc.poll() is None:
            proc.kill()

    print()
    print(f"  submit with no wait, before:  {1000 * plain_before:.1f} ms")
    print(f"  first waited submit:          {1000 * held:.1f} ms")
    print(f"  second waited submit:         {1000 * held2:.1f} ms")
    print(f"  submit with no wait, after:   {1000 * plain_after:.1f} ms")
    print(f"  the host was told to signal after {delay_ms} ms")
    print("--- semhost ---")
    print(out.rstrip())

    floor = 0.8 * delay_ms / 1000.0
    if held < floor:
        # `XMX_EXTMEM_TRACE=1` shows the semaphore does reach vkQueueSubmit, and stage
        # one shows the same driver honours a wait inside one process. So a submit that
        # sails through is the driver ignoring an *imported* semaphore, which is why
        # Phase 2 cannot order the frame with one.
        print(f"\nCROSS-PROCESS SEMAPHORES DO NOT ORDER ANYTHING ON THIS DRIVER: the "
              f"waited submit returned in {1000 * held:.1f} ms, under "
              f"{1000 * floor:.0f} ms, and the second in {1000 * held2:.1f} ms — so it "
              f"is not one phantom signal, it is every wait. See "
              f"notes/phase2-extmem-design.md section 6.")
        return 1
    if plain_after > 0.25:
        print(f"\nFAILED: a submit with no wait took {1000 * plain_after:.1f} ms — the "
              f"wait is leaking into later submits, which would stall every pass.")
        return 1
    print(f"\nOK: the submit was held {1000 * held:.1f} ms for a signal that came "
          f"{delay_ms} ms later, and the next one ran at once")
    return 0


if __name__ == "__main__":
    sys.exit(main())
