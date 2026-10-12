"""Build src/probe/handshake_probe.cpp -- asks which half of the hand-over this adapter does.

Console program, deliberately outside the game. The host's between slot waits on a shared
D3D12 fence from Vulkan and signals another one back; in Lies of P that wait was never
satisfied. Which half fails is a driver question, so it is asked here, where an answer is a
line of output rather than a frame rate.

Same cl.exe driving as tools/build_extmem_probe.py.
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
SRC = os.path.join(ROOT, "src", "dlss-nr-on-a770", "src", "probe", "handshake_probe.cpp")
OUT = os.path.join(ROOT, "src", "dlss-nr-on-a770", "work", "handshake_probe.exe")
LOG = os.path.join(ROOT, "logs", "handshake_probe_build.log")

env = dict(os.environ)
env["INCLUDE"] = ";".join([
    os.path.join(OP, "external", "vulkan", "include"),
    os.path.join(VCTOOLS, "include"),
    os.path.join(SDKDIR, "Include", SDKVER, "ucrt"),
    os.path.join(SDKDIR, "Include", SDKVER, "um"),
    os.path.join(SDKDIR, "Include", SDKVER, "shared"),
    os.path.join(SDKDIR, "Include", SDKVER, "winrt"),
])
env["LIB"] = ";".join([
    os.path.join(OP, "OptiScaler", "library", "vulkan"),
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

CMD = [CL, "/nologo", "/O2", "/std:c++17", "/permissive-", "/EHsc", "/W3", "/Y-", "/MT",
       "/DNDEBUG", "/DUNICODE", "/D_UNICODE", "/D_CONSOLE",
       "/Fo" + os.path.join(os.path.dirname(OUT), "handshake_probe.obj"),
       "/Fe" + OUT, SRC, "d3d12.lib", "dxgi.lib", "vulkan-1.lib",
       "/link", "/SUBSYSTEM:CONSOLE"]

log = open(LOG, "w", encoding="utf-8", errors="replace")
p = subprocess.run(CMD, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=900)
text = p.stdout.decode("utf-8", "replace")
log.write(text)
log.write("\nexit=%d\n" % p.returncode)
log.close()
print(text[-4000:] if len(text) > 4000 else text)
print("exit=%d" % p.returncode)
if os.path.isfile(OUT):
    print("built:", OUT, os.path.getsize(OUT), "bytes")
sys.exit(p.returncode)
