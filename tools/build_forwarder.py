"""Build The's DLSS-NR forwarder (nvngx.dll_dlssnr.dll) with cl.exe.

The release package does not contain this DLL and the repository only has its source, so it
is built here. Driven straight through cl.exe the way tools/build_optiscaler.py does it,
because vcvarsall needs reg.exe and reg.exe is denied on this machine.

Settings are read off the project's own vcxproj (refs/optiscaler/ta_forwarder.vcxproj):
  TargetName  nvngx.dll_dlssnr   -- the name is the whole point of the library
  Release     /MT (RuntimeLibrary MultiThreaded), MaxSpeed, IntrinsicFunctions
  Link        /SUBSYSTEM:WINDOWS, d3d12.lib only
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

REF = r"E:\WorkBuddy\2026-10-09-04-20-55\refs\optiscaler"
SRC = os.path.join(REF, "ta_dlssnr_forwarder.cpp")
OUT = os.path.join(REF, "pkg", "ta_v1.11.0", "nvngx.dll_dlssnr.dll")
OBJ = os.path.join(r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work",
                   "dlssnr_forwarder.obj")
LOG = r"E:\WorkBuddy\2026-10-09-04-20-55\logs\forwarder_build.log"

env = dict(os.environ)
env["INCLUDE"] = ";".join([
    os.path.join(VCTOOLS, "include"),
    os.path.join(SDKDIR, "Include", SDKVER, "ucrt"),
    os.path.join(SDKDIR, "Include", SDKVER, "um"),
    os.path.join(SDKDIR, "Include", SDKVER, "shared"),
    os.path.join(SDKDIR, "Include", SDKVER, "winrt"),
])
env["LIB"] = ";".join([
    os.path.join(VCTOOLS, "lib", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "ucrt", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "um", "x64"),
])
env["PATH"] = BIN + ";" + os.path.join(SDKDIR, "bin", SDKVER, "x64") + ";" + env.get("PATH", "")

if not os.path.isfile(SRC):
    print("missing source:", SRC)
    sys.exit(1)
os.makedirs(os.path.dirname(LOG), exist_ok=True)

# /LD: a DLL. /MT: the vcxproj's Release RuntimeLibrary is MultiThreaded and this DLL is
# loaded into games that bring no redistributable with them.
# /Gy /Gw /OPT:ICF /OPT:REF: the project's FunctionLevelLinking / EnableCOMDATFolding /
# OptimizeReferences.
CMD = [CL, "/nologo", "/O2", "/Ot", "/fp:fast", "/std:c++17", "/permissive-", "/EHsc",
       "/W3", "/sdl", "/Gy", "/Gw", "/Y-", "/MT",
       "/DNDEBUG", "/D_WINDOWS", "/D_USRDLL", "/DUNICODE", "/D_UNICODE",
       "/Fo" + OBJ, "/Fd" + OBJ.replace(".obj", ".pdb"),
       "/LD", "/Fe" + OUT, SRC, "d3d12.lib",
       "/link", "/SUBSYSTEM:WINDOWS", "/OPT:ICF", "/OPT:REF",
       "/IMPLIB:" + OBJ.replace(".obj", ".lib")]

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
