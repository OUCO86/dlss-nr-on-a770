#!/usr/bin/env python3
"""Does a submit really wait on a semaphore that came from another process?

The second gate in notes/phase2-extmem-design.md section 5. Sharing a buffer is not
enough on its own: the frame's bytes are written by the layer's CPU, which is not in
any queue, so the only thing that puts those writes before the daemon's first pass is
a semaphore the layer signals. If the wait is dropped somewhere between
`xmx_sem_import` and `vkQueueSubmit`, nothing here fails — the frame just silently
reads bytes that have not arrived yet. So this test does not check that a submit
succeeds; it checks that a submit is *slow*.

Three stages, because the first two are the controls that let the third be read:

  1. in one process, does a wait hold a submit back at all? If not, the card ignores
     waits generally and nothing about Phase 2 is to blame.
  2. across processes with a *binary* semaphore, waited on before anything has been
     submitted to signal it. This is outside the rules — VUID-vkQueueSubmit-
     pWaitSemaphores-03238 requires a binary wait to reference a signal already
     submitted — and the specification lets a driver run such a wait as though it had
     succeeded. So a fast result here is legal, not a fault, and this stage reports
     without judging.
  3. across processes with a *timeline* semaphore, which has no signal-before-wait
     rule at all and can be signalled from the host. This is the one that decides.

    python src/bench/check_extmem_sem.py [delay-ms]

Exits non-zero if the timeline wait did not hold the submit back, or if the in-process
control failed.
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
    """Stage one: does a wait hold a submit back at all, before any process boundary?"""
    proc = subprocess.Popen([str(EXE), "semhost", str(os.getpid())],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, bufsize=1)
    try:
        out = say_host(proc, f"waittest {delay_ms}")
        return proc.returncode, out
    finally:
        if proc.poll() is None:
            proc.kill()


def offer_handle(delay_ms, timeline):
    """Start a semhost and read the handle it duplicates into this process."""
    argv = [str(EXE), "semhost", str(os.getpid())]
    if timeline:
        argv.append("timeline")
    proc = subprocess.Popen(argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, bufsize=1)
    for _ in range(20):
        banner = proc.stdout.readline().strip()
        if banner.startswith("S ") or not banner:
            break
        print(f"  semhost: {banner}")
    if not banner.startswith("S "):
        print(f"semhost did not offer a handle: {banner!r}")
        proc.kill()
        return None, None
    return proc, int(banner[2:], 16)


def main():
    delay_ms = int(sys.argv[1]) if len(sys.argv) > 1 else 1500
    if not EXE.exists():
        print(f"missing {EXE} — build it with tools\\build_extmem_xproc.bat")
        return 1

    print("[1] does a waited submit wait, in one process?")
    code, _ = driver_self_test(delay_ms)
    if code:
        print("\nFAILED: the driver ignored a wait inside one process. Nothing about "
              "Phase 2 can work until that is understood.")
        return 1
    print("    yes — waits are real on this card inside a process\n")

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

    print("[2] binary semaphore, waited on before the signal is submitted")
    print("    (outside the rules; a fast result is legal, reported not judged)")
    proc, handle = offer_handle(delay_ms, timeline=False)
    if proc is None:
        return 1
    try:
        proc.stdin.write(f"signal-after {delay_ms}\n")
        proc.stdin.flush()
        sid = rt.import_semaphore(handle, timeline=False)
        rt.extmem_wait(sid)
        binary_held = submit()
        proc.stdin.write("quit\n")
        proc.stdin.flush()
        proc.communicate(timeout=60)
    finally:
        if proc.poll() is None:
            proc.kill()
    print(f"    the submit came back in {1000 * binary_held:.1f} ms\n")

    print("[3a] does a timeline semaphore's counter cross the process boundary at all?")
    proc, handle = offer_handle(delay_ms, timeline=True)
    if proc is None:
        return 1
    try:
        sid0 = rt.import_semaphore(handle, timeline=True)
        proc.stdin.write("signal-after 200\n")
        proc.stdin.flush()
        time.sleep(1.0)
        seen = rt.semaphore_value(sid0)
        proc.stdin.write("quit\n")
        proc.stdin.flush()
        out0, _ = proc.communicate(timeout=60)
    finally:
        if proc.poll() is None:
            proc.kill()
    print(f"    counter here after the other process signalled: {seen}")
    if seen != 1:
        print("    the payload is not shared — a wait can never see the signal")
        print("--- semhost ---")
        print(out0.rstrip())
        return 1
    print("    yes — the signal reached this process\n")

    print(f"[3b] does a submit wait on it, with the signal still {delay_ms} ms away?")
    proc, handle = offer_handle(delay_ms, timeline=True)
    if proc is None:
        return 1
    try:
        sid = rt.import_semaphore(handle, timeline=True)
        before = rt.semaphore_value(sid)
        proc.stdin.write(f"signal-after {delay_ms}\n")
        proc.stdin.flush()
        rt.extmem_wait(sid, value=1)
        print(f"    counter before the host signals: {before}")
        print(f"    pending before the submit: {rt.extmem_wait_pending()}")
        held = submit()
        print(f"    pending after the submit:  {rt.extmem_wait_pending()}")
        print(f"    counter after: {rt.semaphore_value(sid)}")
        plain_after = submit()
        proc.stdin.write("quit\n")
        proc.stdin.flush()
        out, _ = proc.communicate(timeout=60)
    finally:
        if proc.poll() is None:
            proc.kill()

    print()
    print(f"  submit with no wait, before: {1000 * plain_before:.1f} ms")
    print(f"  submit waiting on the timeline semaphore: {1000 * held:.1f} ms")
    print(f"  submit with no wait, after:  {1000 * plain_after:.1f} ms")
    print(f"  the host was told to signal after {delay_ms} ms")
    print("--- semhost ---")
    print(out.rstrip())

    floor = 0.8 * delay_ms / 1000.0
    if held < floor:
        print(f"\nFAILED: the timeline wait did not hold the submit: it returned in "
              f"{1000 * held:.1f} ms, under {1000 * floor:.0f} ms. A frame would run "
              f"on bytes that had not arrived.")
        return 1
    if plain_after > 0.25:
        print(f"\nFAILED: a submit with no wait took {1000 * plain_after:.1f} ms — the "
              f"wait is leaking into later submits, which would stall every pass.")
        return 1
    print(f"\nOK: a timeline semaphore shared across the process boundary held the "
          f"submit {1000 * held:.1f} ms for a host signal that came {delay_ms} ms "
          f"later, and the next submit ran at once")
    return 0


if __name__ == "__main__":
    sys.exit(main())
