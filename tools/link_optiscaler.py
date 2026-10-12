"""Link only: the objects in build_x64 are already built, so re-run just the link.

The previous attempt passed /DLL (a link.exe switch) to cl, which does not know
it, so the image was linked as an executable and the CRT demanded WinMain.
cl's own switch is /LD, which forwards /DLL to the linker.
"""
import os
import subprocess

VSROOT = r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community"
VCVER = "14.51.36231"
SDKVER = "10.0.26100.0"
SDKDIR = r"E:\Windows Kits\10"
REPO = r"E:\WorkBuddy\2026-10-09-04-20-55\src\OptiScaler"
PROJ = os.path.join(REPO, "OptiScaler")
BUILD = os.path.join(REPO, "build_x64")
LOG = r"E:\WorkBuddy\2026-10-09-04-20-55\logs\opti_build.log"
VCTOOLS = os.path.join(VSROOT, "VC", "Tools", "MSVC", VCVER)
BIN = os.path.join(VCTOOLS, "bin", "Hostx64", "x64")
CL = os.path.join(BIN, "cl.exe")

LIB_PATH = [
    os.path.join(PROJ, "library", "fsr2"),
    os.path.join(PROJ, "library", "fsr2_212"),
    os.path.join(PROJ, "library", "fsr31"),
    os.path.join(PROJ, "library", "vulkan"),
    os.path.join(PROJ, "library", "d3dx"),
    os.path.join(PROJ, "library", "detours"),
    os.path.join(REPO, "external", "xess", "lib"),
    os.path.join(REPO, "external", "freetype"),
]
LIBS = ["winhttp.lib", "WindowsApp.lib", "Dbghelp.lib", "dxgi.lib", "d3d11.lib",
        "d3d12.lib", "vulkan-1.lib", "dxguid.lib", "freetype.lib",
        "ffx_fsr2_api_x64.lib", "ffx_fsr2_api_dx11_x64.lib", "ffx_fsr2_api_dx12_x64.lib",
        "ffx_fsr2_api_vk_x64.lib", "ffx_fsr2_212_api_dx12_x64.lib",
        "ffx_fsr2_212_api_vk_x64.lib", "ffx_fsr2_212_api_x64.lib", "d3dcompiler.lib",
        "ffx_backend_dx11_x64.lib", "ffx_fsr3_x64.lib", "ffx_frameinterpolation_x64.lib",
        "ffx_fsr3upscaler_x64.lib", "ffx_opticalflow_x64.lib",
        "ucrt.lib", "delayimp.lib"]
DELAY = ["vulkan-1.dll", "dxgi.dll", "d3d12.dll", "D3DCOMPILER_47.dll"]

env = dict(os.environ)
env["LIB"] = ";".join(LIB_PATH + [
    os.path.join(VCTOOLS, "lib", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "ucrt", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "um", "x64"),
])
env["PATH"] = BIN + ";" + os.path.join(SDKDIR, "bin", SDKVER, "x64") + ";" + env.get("PATH", "")

link_rsp = os.path.join(BUILD, "link.rsp")
objs = [l.strip() for l in open(link_rsp) if l.strip()]
missing = [o for o in objs if not os.path.exists(o)]
print("objects:", len(objs), "| missing:", len(missing))
if missing:
    print("MISSING:", missing[:5])

cmd = [CL, "/nologo", "/LD", "/Fe:" + os.path.join(BUILD, "OptiScaler.dll"),
       "@" + link_rsp, "/link",
       "/OPT:REF", "/OPT:ICF", "/SUBSYSTEM:WINDOWS",
       "/DEF:" + os.path.join(PROJ, "Source.def"),
       "/IMPLIB:" + os.path.join(BUILD, "OptiScaler.lib")] + \
      ["/DELAYLOAD:" + d for d in DELAY] + LIBS

p = subprocess.run(cmd, cwd=PROJ, env=env, stdout=subprocess.PIPE,
                   stderr=subprocess.STDOUT, timeout=1800)
t = p.stdout.decode("utf-8", "replace")
open(LOG, "ab").write(("=== link only ===\n" + t).encode("utf-8", "replace"))
print("returncode:", p.returncode)
print(t[-2500:])
if p.returncode == 0:
    print("LINK OK:", os.path.join(BUILD, "OptiScaler.dll"))
