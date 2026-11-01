# run_C2.ps1 -- one (shape,stage) per process (gemm32_tile / C1 methodology), watchdog'd.
# The exe MUST run from E:\DSH\oneapi (that is where the sycl9.dll chain lives; PATH is not
# enough for the native loader -- E:/DSH/bench.sh header note).
# usage: powershell -File E:/DSH/s6/run_C2.ps1 <shape 1|2> <stage 1|2|3> <logname> [capsec] [srcexe]
param([int]$shape = 1, [int]$stage = 1, [string]$log = "C2_S1", [int]$capsec = 900, [string]$srcexe = "_c2chk.exe")
$run = "E:\DSH\oneapi"
# ALWAYS re-stage: a stale copy in the run dir silently ran old code for two rounds (the trap).
$alt = "E:\DSH\dlss-nr-on-a770\src\bench\sycl\$srcexe"
if (-not (Test-Path $alt)) { "no exe: $srcexe / $alt"; exit 2 }
Copy-Item $alt (Join-Path $run $srcexe) -Force
$exe = Join-Path $run $srcexe
$env:C2_SHAPE = "$shape"; $env:C2_STAGE = "$stage"
$env:SYCL_DEVICE_FILTER = "level_zero:gpu"
$env:SYCL_CACHE_PERSISTENT = "1"; $env:SYCL_CACHE_DIR = "E:\DSH\sycl-cache"
$outfile = "E:\DSH\s6\$log.log"; $errfile = "E:\DSH\s6\$log.err"
$p = Start-Process -FilePath $exe -WorkingDirectory $run `
     -RedirectStandardOutput $outfile -RedirectStandardError $errfile -PassThru -NoNewWindow
if (-not $p.WaitForExit($capsec * 1000)) {
    "TIMEOUT > $capsec s -> killing PID $($p.Id)"
    try { $p.Kill(); Start-Sleep -Milliseconds 500 } catch {}
    "VERDICT: HANG"; exit 3
}
"RUN shape=$shape stage=$stage exe=$srcexe EXITCODE=$($p.ExitCode)"
Select-String -Path $outfile -Pattern 'DIFF|diff |GATE|CSVROW|ph[1-6] |#####|device:|EXC|released|ref|GAIN' | ForEach-Object { $_.Line }
