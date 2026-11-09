param([string]$Exe = 'E:\DSH\builds\nr_replay_c26.exe')
$ErrorActionPreference = 'Continue'
# s6/mk_c26rt.ps1 -- build E:\DSH\tmp\c26rt: the C26 harness exe beside HARD LINKS of the
# oneapi runtime set (same bytes, no copies, nothing written into oneapi or out). The
# deployed nr_replay_now.exe resolves sycl9/ur_loader/ur_adapter_level_zero from its OWN
# directory; a replay exe built elsewhere loses that and the UR loader picks OpenCL
# (cgraph RECORD fails). Windows does not need admin rights for hard links on one volume.
$D = 'E:\DSH\tmp\c26rt'
Remove-Item -Recurse -Force $D -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $D | Out-Null
Copy-Item -LiteralPath $Exe -Destination (Join-Path $D 'nr_replay_c26.exe') -Force
foreach ($f in (Get-ChildItem 'E:\DSH\oneapi' -Filter '*.dll' -File)) {
    New-Item -ItemType HardLink -Path (Join-Path $D $f.Name) -Target $f.FullName -EA 0 | Out-Null
    if (-not (Test-Path (Join-Path $D $f.Name))) { Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $D $f.Name) -Force }
}
$n = @(Get-ChildItem $D -File).Count
Write-Output ("c26rt files=" + $n)
foreach ($want in @('sycl9.dll','ur_loader.dll','ur_adapter_level_zero.dll','ur_adapter_opencl.dll')) {
    Write-Output ("  " + $want + " present=" + (Test-Path (Join-Path $D $want)))
}
