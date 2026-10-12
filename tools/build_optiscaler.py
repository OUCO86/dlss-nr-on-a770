"""Build OptiScaler Release|x64 with cl.exe, driven from the vcxproj settings.

Layout follows tools/build_msvc.bat (the project's existing MSVC script):
no vcvarsall (needs reg.exe), so INCLUDE/LIB/PATH are set by hand.

Steps mirror the vcxproj:
  1. PreBuildEvent  -> resource_build_date.h / resource_build_commit.h
  2. pch.cpp with /Yc (Create), then every other .cpp with /Yu (Use) and /MP
  3. OptiScaler.rc  -> .res
  4. link with /DEF:Source.def

A response file carries the source list: 136 paths will not fit on one line.
"""
import os
import subprocess
import sys

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

REL = r'E:\WorkBuddy\2026-10-09-04-20-55\refs\optiscaler\pkg'
INCLUDE_PATH = [
    PROJ, os.path.join(PROJ, "include"),
    os.path.join(REPO, "external", "vulkan", "include"),
    os.path.join(REPO, "external", "nvngx_dlss_sdk"),
    os.path.join(REPO, "external", "xess", "inc", "xess"),
    os.path.join(REPO, "external", "xess", "inc", "xell"),
    os.path.join(REPO, "external", "xess", "inc", "xess_fg"),
    os.path.join(REPO, "external", "FidelityFX-SDK", "ffx-api", "include", "ffx_api"),
    os.path.join(REPO, "external", "simpleini"),
    os.path.join(REPO, "external", "unordered_dense", "include"),
    os.path.join(REPO, "external", "spdlog", "include"),
    os.path.join(REPO, "external", "freetype"),
    os.path.join(REPO, "external", "streamline"),
    os.path.join(REPO, "external", "streamline1"),
    os.path.join(REPO, "external", "nlohmann"),
    os.path.join(REPO, "external", "fakenvapi"),
    os.path.join(REPO, "external", "magic_enum", "include", "magic_enum"),
]
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
        # ucrt.lib (the dll-import flavour, not libucrt.lib) is where __imp_exp2f
        # lives; the AMD prebuilt libs import it. delayimp.lib supplies
        # __delayLoadHelper2 for the /DELAYLOAD entries below.
        "ucrt.lib", "delayimp.lib"]
DELAY = ["vulkan-1.dll", "dxgi.dll", "d3d12.dll", "D3DCOMPILER_47.dll"]

env = dict(os.environ)
env["INCLUDE"] = ";".join(INCLUDE_PATH + [
    os.path.join(VCTOOLS, "include"),
    os.path.join(SDKDIR, "Include", SDKVER, "ucrt"),
    os.path.join(SDKDIR, "Include", SDKVER, "um"),
    os.path.join(SDKDIR, "Include", SDKVER, "shared"),
    os.path.join(SDKDIR, "Include", SDKVER, "winrt"),
])
env["LIB"] = ";".join(LIB_PATH + [
    os.path.join(VCTOOLS, "lib", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "ucrt", "x64"),
    os.path.join(SDKDIR, "Lib", SDKVER, "um", "x64"),
])
env["PATH"] = BIN + ";" + os.path.join(SDKDIR, "bin", SDKVER, "x64") + ";" + env.get("PATH", "")

os.makedirs(BUILD, exist_ok=True)
os.makedirs(os.path.dirname(LOG), exist_ok=True)

# 1. the headers the vcxproj PreBuildEvent writes
open(os.path.join(PROJ, "resource_build_date.h"), "w").write('#define VER_BUILD_DATE "manual"\n')
open(os.path.join(PROJ, "resource_build_commit.h"), "w").write('#define VER_BUILD_COMMIT "manual"\n')

# /Y- everywhere: no precompiled header. The vcxproj builds through pch.h, but
# third-party sources in the tree (imgui) do not start with it and fail under
# /Yu, and a header-only-precompiled build adds a failure mode we do not need.
# Same semantics, slower.
# /MD: the vcxproj sets no RuntimeLibrary, and VS defaults Release to the dll
# runtime. Without it cl picks the static one, which drags in LIBCMT and then
# demands WinMain for a /SUBSYSTEM:WINDOWS image.
COMMON = ["/nologo", "/c", "/O2", "/Ot", "/fp:fast", "/std:c++latest",
          "/permissive-", "/EHsc", "/W3", "/sdl", "/w34996", "/Y-", "/MD"]
# CharacterSet is Unicode in the vcxproj, which is what makes GetModuleHandle and
# friends resolve to the W variants; without these the wide strings in the proxy
# headers are handed to the A entry points.
DEFS = ["/DNDEBUG", "/D_DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR", "/D_WINDOWS", "/D_USRDLL",
        "/DUNICODE", "/D_UNICODE"]

log = open(LOG, "w", encoding="utf-8", errors="replace")

def run(cmd, cwd, label):
    print("===", label, "===", flush=True)
    p = subprocess.run(cmd, cwd=cwd, env=env, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, timeout=3600)
    t = p.stdout.decode("utf-8", "replace")
    log.write("=== %s ===\n%s\n" % (label, t))
    log.flush()
    print(t[-3000:] if len(t) > 3000 else t, flush=True)
    return p.returncode

# 2a. create the precompiled header
rc = run([CL] + COMMON + DEFS + ["/Fo" + os.path.join(BUILD, "pch.obj"),
                                 os.path.join(PROJ, "pch.cpp")], PROJ, "pch.cpp (plain, /Y-)")
if rc != 0:
    print("FAILED at pch: see", LOG); sys.exit(1)

# 2b. every other source, strictly the vcxproj's own list.
# Walking the tree instead would pull in imgui.cpp / imgui_draw.cpp and friends,
# which the project deliberately does not compile here (and which fail under /Yu).
vcx = open(os.path.join(PROJ, "OptiScaler.vcxproj"), "r", encoding="utf-8", errors="replace").read()
import re
rel_srcs = re.findall(r'<ClCompile\s+Include="([^"]+)"', vcx)
blocks = re.findall(r'<ClCompile\s+Include="([^"]+)"\s*>(.*?)</ClCompile>', vcx, re.S)
no_pch = set()
for name, body in blocks:
    if re.search(r"<PrecompiledHeader[^>]*>NotUsing</PrecompiledHeader>", body):
        no_pch.add(name)

with_pch = [s for s in rel_srcs if s != "pch.cpp" and s not in no_pch]
without_pch = [s for s in rel_srcs if s != "pch.cpp" and s in no_pch]
srcs = [s for s in rel_srcs if s != "pch.cpp"]
print("compiling %d sources (%d without pch)" % (len(srcs), len(without_pch)), flush=True)


def objname(rel):
    """Flat, unique object name: the tree has no duplicate basenames, but keep the
    path in the name anyway so nested files stay unambiguous."""
    return os.path.join(BUILD, rel.replace("\\", "_").replace("/", "_").replace(".cpp", ".obj"))


def compile_batch(rels, label, use_pch):
    rsp = os.path.join(BUILD, "src_%s.rsp" % label)
    with open(rsp, "w") as f:
        f.write("\n".join('"%s"' % os.path.join(PROJ, s) for s in rels))
    args = [CL] + COMMON + DEFS
    if use_pch:
        args += ["/MP", "/Yupch.h", "/Fp" + os.path.join(BUILD, "pch.pch")]
    else:
        args += ["/MP", "/Y-"]
    # one /Fo per file is not allowed, so compile with an explicit obj per file
    # is impossible in a single call; instead compile serially for this small batch.
    if use_pch:
        args += ["/Fo" + BUILD + "\\", "@" + rsp]
        return run(args, PROJ, "compile %s" % label)
    rc = 0
    for s in rels:
        one = [CL] + COMMON + DEFS + ["/Y-", "/Fo" + objname(s), os.path.join(PROJ, s)]
        rc = run(one, PROJ, "compile %s" % s)
        if rc != 0:
            return rc
    return 0


rc = compile_batch(with_pch, "pch_sources", True)
if rc != 0:
    print("FAILED at compile (with pch): see", LOG); sys.exit(1)
if without_pch:
    rc = compile_batch(without_pch, "nopch_sources", False)
    if rc != 0:
        print("FAILED at compile (no pch): see", LOG); sys.exit(1)

# 3. resource
rc_exe = os.path.join(SDKDIR, "bin", SDKVER, "x64", "rc.exe")
rc = run([rc_exe, "/nologo", "/fo" + os.path.join(BUILD, "OptiScaler.res"),
          os.path.join(PROJ, "OptiScaler.rc")], PROJ, "resource")
if rc != 0:
    print("FAILED at rc: see", LOG); sys.exit(1)

# 4. link
# with_pch was compiled with /Fo <dir>\ so those objects keep their basename;
# without_pch was given an explicit object per file.
objs = [os.path.join(BUILD, os.path.basename(s).replace(".cpp", ".obj")) for s in with_pch]
objs += [objname(s) for s in without_pch]
objs.append(os.path.join(BUILD, "pch.obj"))
link_rsp = os.path.join(BUILD, "link.rsp")
with open(link_rsp, "w") as f:
    f.write("\n".join(objs + [os.path.join(BUILD, "OptiScaler.res")]))

# Driven through cl.exe rather than link.exe: cl injects the default runtime
# libraries, which link.exe invoked on its own does not. /DELAYLOAD also needs
# delayimp.lib for __delayLoadHelper2.
# /LD is cl's switch; it forwards /DLL to the linker. Passing /DLL before /link
# leaves cl building an executable, and the CRT then demands WinMain.
rc = run([CL, "/nologo", "/LD", "/Fe:" + os.path.join(BUILD, "OptiScaler.dll"),
          "@" + link_rsp, "/link",
          "/OPT:REF", "/OPT:ICF", "/SUBSYSTEM:WINDOWS",
          "/DEF:" + os.path.join(PROJ, "Source.def"),
          "/IMPLIB:" + os.path.join(BUILD, "OptiScaler.lib"),
          "delayimp.lib"]
         + ["/DELAYLOAD:" + d for d in DELAY]
         + LIBS, PROJ, "link")
if rc != 0:
    print("FAILED at link: see", LOG); sys.exit(1)

print("BUILD OK:", os.path.join(BUILD, "OptiScaler.dll"))
log.close()
