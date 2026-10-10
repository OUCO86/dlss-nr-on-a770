#!/usr/bin/env python3
"""The switches the game actually runs with, for a script that is not the daemon.

`xmxres.Runtime` reads `NR_INT8_PROJECT` and its default is `"0"`. The daemon is what
turns it on: it reads `int8` out of `work/nr_settings.json` and injects the environment
variable before the runtime is built (`src/layer/nr_daemon.py`). A benchmark that builds
a `Runtime` of its own therefore measures the **integer path switched off**, and every
number it prints is about a configuration no game has ever run.

It does not look like a mistake when it happens. `src/bench/frame_ledger.py` measured
43.49 ms over 415 passes with the default, against about 36.4 ms over 723 with the
integer path on: the float graph is *fewer* passes and *slower*, which is what "the
integer path adds a quantise and a scale to each product" should look like, so nothing
about the output says the switch is off. There is no `gemm_int8` in the ledger and the
projections come out of `nr_resident.py:429` (`gemm_residual`) instead of `:422`
(`gemm_int8`) — that is the tell, and it is easy to miss.

    import game_settings; game_settings.apply()

before `xmxres.Runtime()` is constructed. The values are the ones
`work/nr_settings.json` and `docs/A770-HANDOFF.md` agree on.

`NR_INT8_TRANSITION` is **0** on purpose: it was measured and it did not pay, and the
plan is to leave it off (`docs/A770-HANDOFF.md`, the table in section 3). None of the
others may be turned off to make a measurement look better — that is the rule this
project runs under.
"""
import os

# name -> the value the daemon injects for the game, or the code's default where the
# daemon does not set it at all
SETTINGS = {
    "NR_INT8_PROJECT": "1",        # work/nr_settings.json: "int8": 1
    "NR_INT8_WINDOW_FUSE": "1",    # work/nr_settings.json: "int8_window_fuse": 1
    "NR_INT8_QKV": "1",
    "NR_INT8_WINDOW": "1",
    "NR_INT8_WINDOW_OUT": "1",
    "NR_INT8_OUT": "1",
    "NR_INT8_EXPAND": "1",
    "NR_INT8_TRANSITION": "0",     # measured, no gain, left off on purpose
}


def apply(overrides=None):
    """Set them, and say which of them were already something else."""
    for name, value in {**SETTINGS, **(overrides or {})}.items():
        had = os.environ.get(name)
        if had is not None and had != value:
            print(f"[game_settings] {name} was {had!r}, the game runs {value!r}",
                  flush=True)
        os.environ[name] = value
    return dict(SETTINGS)
