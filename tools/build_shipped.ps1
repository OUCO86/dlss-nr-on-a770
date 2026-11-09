# build_shipped.ps1 -- rebuild the SHIPPED-BASIS dll (the one the game load slot runs) from the
# repo source tree, reproducibly, WITHOUT dirtying the repo and WITHOUT touching oneapi\ or out\.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File E:\DSH\dlss-nr-on-a770\tools\build_shipped.ps1 [-Tag ship1] [-Repo <path>] [-Defs <file>]
#
# What it does:
#   1. copies libxmx_sycl.cpp + every *.hpp it includes into E:\DSH\tmp\shipbuild_<Tag>\
#   2. applies tools/patch_testdefs.py there (the #ifdef compile-time-default hook)
#   3. compiles with the /D list in tools/shipped_build.defs (same icx recipe as build_dll.sh)
#   4. product -> E:\DSH\builds\libxmx_<Tag>.dll   (md5 printed; nothing staged)
# Guard: s6_ffn_block_kernel.hpp must be the pre-S6_BAR state (md5 490647A9444955B5DE0B9A634A0A317E).
#   2026-11-09 19:58 C32 re-baseline (parent): add a second accepted state = ViT-reuse gate on top of the
#   SAME pre-S6_BAR state (extern decls + vit_gate() decl after q.submit + early-return before slm_init).
#   19:52 second unlock: gated md5 C38025BB (broken copy, externs landed inside a comment) -> 20A44A6E.
#   Old state is one `git checkout` away; if the ViT-reuse line is dropped, revert this guard too.
# ASCII only (host shell is Windows PowerShell 5.1; see knife2b.md P8/P11).
param(
  [string]$Tag  = 'ship1',
  [string]$Repo = 'E:\DSH\dlss-nr-on-a770',
  [string]$Defs = 'E:\DSH\dlss-nr-on-a770\tools\shipped_build.defs'
)
$ErrorActionPreference = 'Stop'

$SY      = 'E:\WorkBuddy\toolchain-mamba\sycl'
$VCTOOLS = 'E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231'
$SDK     = 'E:\Windows Kits\10'
$PY      = 'C:\Users\wangz\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe'
$HERE    = Join-Path $Repo 'src\bench\sycl'
# Rule 171: make the Tag unique per invocation. Two concurrent builds sharing one $LOG (and $SCR)
# caused icx to never run at all -- Out-File hit a locked log, exit code stayed 0, and the script
# printed "BUILD FAILED: no dll" over and over (seen 2026-11-08 07:3x, parent-side mistake).
$Tag     = "${Tag}-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
$SCR     = "E:\DSH\tmp\shipbuild_$Tag"
$LOG     = "E:\DSH\logs\build_$Tag.log"

function Get-Md5Of([string]$p) { (Get-FileHash -LiteralPath $p -Algorithm MD5).Hash }

# ---- guard: header state must match the shipped basis -------------------------------------
$hpp = Join-Path $HERE 's6_ffn_block_kernel.hpp'
$hppMd5 = Get-Md5Of $hpp
# Two accepted states: pre-gate (490647A9...) = shipped basis; gated (20A44A6E...) = same + ViT-reuse gate.
#   (C38025BB... was a BROKEN gate copy: externs landed inside a comment -> syntax error; superseded 19:52.)
# Anything else (e.g. the reverted S6_BAR experiment) still fails the build.
if (($hppMd5 -ne '20A44A6E090B585FE3731C7FB18BE770') -and ($hppMd5 -ne '490647A9444955B5DE0B9A634A0A317E')) {
  Write-Host "GUARD FAIL: s6_ffn_block_kernel.hpp = $hppMd5 (expected 20A44A6E... = pre-S6_BAR + ViT gate, or 490647A9... = pre-gate)"; exit 1 }
Write-Host ("header ok: s6_ffn_block_kernel.hpp = $hppMd5  gate=" + $(if ($hppMd5 -eq '20A44A6E090B585FE3731C7FB18BE770') {'ON'} else {'OFF'}))

foreach ($f in (Join-Path $HERE 'libxmx_sycl.cpp'), $Defs, (Join-Path $Repo 'tools\patch_testdefs.py'), $PY) {
  if (-not (Test-Path -LiteralPath $f)) { Write-Host "MISSING $f"; exit 1 } }

# ---- scratch copy -------------------------------------------------------------------------
if (Test-Path -LiteralPath $SCR) { Remove-Item -LiteralPath $SCR -Recurse -Force }
New-Item -ItemType Directory -Force -Path $SCR | Out-Null
Copy-Item -LiteralPath (Join-Path $HERE 'libxmx_sycl.cpp') -Destination $SCR
Copy-Item -Path (Join-Path $HERE '*.hpp') -Destination $SCR -Force
Copy-Item -LiteralPath (Join-Path $Repo 'tools\patch_testdefs.py') -Destination $SCR -Force
Write-Host ("source  libxmx_sycl.cpp = " + (Get-Md5Of (Join-Path $HERE 'libxmx_sycl.cpp')))

# ---- apply the compile-time-default hook (in the scratch copy only) -----------------------
& $PY (Join-Path $SCR 'patch_testdefs.py') ("--src=" + (Join-Path $SCR 'libxmx_sycl.cpp'))
if ($LASTEXITCODE -ne 0) { Write-Host "PATCH FAILED exit=$LASTEXITCODE"; exit 1 }
Write-Host ("patched = " + (Get-Md5Of (Join-Path $SCR 'libxmx_sycl.cpp')))

# ---- generate the export .def from the extern "C" block -----------------------------------
$mkdef = Join-Path $SCR 'mkdef.py'
@'
import re, sys
src, out = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8', errors='replace').read()
block = re.search(r'extern "C" \{(.*?)\n\} // extern "C"', s, re.S).group(1)
names = re.findall(r'^(?:const char\*|int|unsigned long long)\s+(xmx_\w+)\s*\(', block, re.M)
data = "\r\n".join(["LIBRARY libxmx_sycl", "EXPORTS"] + ["    " + n for n in names]) + "\r\n"
open(out, 'wb').write(data.encode('ascii'))
print("def: %d exports" % len(names))
'@ | Set-Content -LiteralPath $mkdef -Encoding ASCII
& $PY $mkdef (Join-Path $SCR 'libxmx_sycl.cpp') (Join-Path $SCR 'libxmx_sycl.def')
if ($LASTEXITCODE -ne 0) { Write-Host 'DEF GENERATION FAILED'; exit 1 }

# ---- compile ------------------------------------------------------------------------------
$dargs = @(Get-Content -LiteralPath $Defs -Encoding ASCII |
            Where-Object { $_ -and ($_ -notmatch '^\s*#') } |
            ForEach-Object { '/D' + $_.Trim() })
Write-Host ("/D flags: " + ($dargs -join '  '))
$env:INCLUDE = "$SY\Library\include;$VCTOOLS\include;$SDK\Include\10.0.26100.0\ucrt;$SDK\Include\10.0.26100.0\um;$SDK\Include\10.0.26100.0\shared"
$env:LIB     = "$SY\Library\lib;$VCTOOLS\lib\x64;$SDK\Lib\10.0.26100.0\ucrt\x64;$SDK\Lib\10.0.26100.0\um\x64"
$env:LIBPATH = $env:LIB
$env:SYCL_CACHE_PERSISTENT = '1'
$env:SYCL_CACHE_DIR        = 'E:\DSH\sycl-cache-shipbuild'   # separate cache: ledger keys on cache dir (rules 29/34)
New-Item -ItemType Directory -Force -Path $env:SYCL_CACHE_DIR | Out-Null
$prod = Join-Path $SCR 'libxmx_sycl.dll'
if (Test-Path -LiteralPath $prod) { Remove-Item -LiteralPath $prod -Force }
Push-Location $SCR
$t0 = Get-Date
# icx writes warnings/notes to STDERR; with ErrorActionPreference=Stop PowerShell 5.1 promotes
# the first such line into a TERMINATING error and kills the compile (seen 2026-11-03 11:5x).
$ErrorActionPreference = 'Continue'
& "$SY\Library\bin\icx.exe" /nologo /Qstd=c++17 /O2 /fsycl /EHsc /D_CRT_SECURE_NO_WARNINGS `
   @dargs /Fe:libxmx_sycl.dll /LD libxmx_sycl.cpp /link /DEF:libxmx_sycl.def ze_loader.lib d3d12.lib dxgi.lib `
   *> $LOG
$code = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
Pop-Location
$mins = [math]::Round(((Get-Date) - $t0).TotalMinutes, 1)
Write-Host "icx exit=$code  compile_minutes=$mins  log=$LOG"
if (-not (Test-Path -LiteralPath $prod)) { Write-Host 'BUILD FAILED: no dll'; Get-Content -LiteralPath $LOG -Tail 25; exit 1 }
New-Item -ItemType Directory -Force -Path 'E:\DSH\builds' | Out-Null
Copy-Item -LiteralPath $prod -Destination "E:\DSH\builds\libxmx_$Tag.dll" -Force
Write-Host ("BUILT E:\DSH\builds\libxmx_$Tag.dll  md5 = " + (Get-Md5Of "E:\DSH\builds\libxmx_$Tag.dll") + "  bytes = " + (Get-Item "E:\DSH\builds\libxmx_$Tag.dll").Length)
Write-Host ("repo porcelain after build (expect 0): " + @(git -C $Repo status --porcelain).Count)
