"""Build src/probe/split_probe.cpp -- asks whether the game's command list can be cut.

The companion to tools/build_extmem_probe.py. That one asked whether a shared D3D12
resource can be imported into a Vulkan device of our own; this one asks whether the list can
be split around the upscaler's evaluate so our work can be sandwiched between the halves.

Console program, outside the game, one variable at a time. It compiles the reference's own
submission module (refs/optiscaler/src/ta_submission, unmodified) and Detours from the
OptiScaler tree, which is the same Detours the host links.
"""
import os
import subprocess
import sys

VSROOT = r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community"
VCVER = "14.51.36231"
SDKVER = "10.0.26100.0"
SDKDIR = r"E:\Windows Kits\10"
VCTOOLS = os.path.join(VSROOT, "VC", "Tools", "MSVC", VCVER)
BIN = os.path.join(VCTOOLS, "bin", "Hostx64", "x64")
CL = os.path.join(BIN, "cl.exe")

ROOT = r"E:\WorkBuddy\2026-10-09-04-20-55"
OP = os.path.join(ROOT, "src", "OptiScaler")
PROJ = os.path.join(ROOT, "src", "dlss-nr-on-a770")
SRC = os.path.join(PROJ, "src", "probe", "split_probe.cpp")
OUT = os.path.join(PROJ, "work", "split_probe.exe")
LOG = os.path.join(ROOT, "logs", "split_probe_build.log")

env = dict(os.environ)
env["INCLUDE"] = ";".join([
    os.path.join(ROOT, "refs", "optiscaler", "src", "ta_submission"),
    os.path.join(OP, "OptiScaler", "include"),
    os.path.join(VCTOOLS, "include"),
    os.path.join(SDKDIR, "Include", SDKVER, "ucrt"),
    os.path.join(SDKDIR, "Include", SDKVER, "um"),
    os.path.join(SDKDIR, "Include", SDKVER, "shared"),
    os.path.join(SDKDIR, "Include", SDKVER, "winrt"),
])
env["LIB"] = ";".join([
    os.path.join(OP, "OptiScaler", "library", "detours"),
    os.path.join(VCTOOLS, "lib", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "ucrt", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "um", "x64"),
])
env["PATH"] = BIN + ";" + os.path.join(SDKDIR, "bin", SDKVER, "x64") + ";" + env.get("PATH", "")

if not os.path.isfile(SRC):
    print("missing source:", SRC)
    sys.exit(1)
os.makedirs(os.path.dirname(LOG), exist_ok=True)
os.makedirs(os.path.dirname(OUT), exist_ok=True)

# C++20: the reference's tracker uses std::unordered_map::contains.
CMD = [CL, "/nologo", "/O2", "/std:c++20", "/EHsc", "/W3", "/Y-", "/MD",
       "/DNDEBUG", "/DUNICODE", "/D_UNICODE", "/D_CONSOLE",
       "/Fo" + os.path.join(os.path.dirname(OUT), "split_probe.obj"),
       "/Fe" + OUT, SRC, "d3d12.lib", "dxgi.lib", "detours.lib",
       "/link", "/SUBSYSTEM:CONSOLE"]

log = open(LOG, "w", encoding="utf-8", errors="replace")
p = subprocess.run(CMD, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=900)
text = p.stdout.decode("utf-8", "replace")
log.write(text)
log.write("\nexit=%d\n" % p.returncode)
log.close()
print(text[-6000:] if len(text) > 6000 else text)
print("exit=%d" % p.returncode)
if os.path.isfile(OUT):
    print("built:", OUT, os.path.getsize(OUT), "bytes")
sys.exit(p.returncode)
