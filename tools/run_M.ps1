# run_M.ps1 -- mixed-chain (M1/M2/M3) runner: ONE (exe,shape,stage) per process, watchdog'd,
# logs into E:\DSH\s6. Copy of run_C1.ps1 with the block3/block4 env names.
# usage: powershell -File E:/DSH/s6/run_M.ps1 <exe> <shape 1|2> <stage 1|2> <logname> [capsec]
param([string]$exename = "s6_ffn_block4.exe", [int]$shape = 1, [int]$stage = 1, [string]$log = "M_x", [int]$capsec = 900, [int]$mode = 0)
$exe = "E:\DSH\oneapi\$exename"
if (-not (Test-Path $exe)) { "no exe staged: $exe"; exit 2 }
$env:C2_SHAPE = "$shape"; $env:C2_STAGE = "$stage"; $env:M_MODE = "$mode"
$env:SYCL_DEVICE_FILTER = "level_zero:gpu"
$env:SYCL_CACHE_PERSISTENT = "1"; $env:SYCL_CACHE_DIR = "E:\DSH\sycl-cache"
$outfile = "E:\DSH\s6\$log.log"; $errfile = "E:\DSH\s6\$log.err"
$p = Start-Process -FilePath $exe -WorkingDirectory "E:\DSH\oneapi" `
     -RedirectStandardOutput $outfile -RedirectStandardError $errfile -PassThru -NoNewWindow
if (-not $p.WaitForExit($capsec * 1000)) {
    "TIMEOUT > $capsec s -> killing PID $($p.Id)"
    try { $p.Kill(); Start-Sleep -Milliseconds 500 } catch {}
    "VERDICT: HANG"
    exit 3
}
"RUN exe=$exename shape=$shape stage=$stage EXITCODE=$($p.ExitCode)"
Select-String -Path $outfile -Pattern 'DIFF|diff |GATE|B3GATE|CSVROW|ph\d |SUM=|DELTA|R1 GAIN|#####|memprobe|THREW|alloc ' | ForEach-Object { $_.Line }
