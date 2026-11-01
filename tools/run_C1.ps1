# run_C1.ps1 -- one (shape,G,KNIFE) port rung per process, watchdog'd, logs into E:\DSH\s6.
# usage: powershell -File E:/DSH/s6/run_C1.ps1 <shape 1|2> <G> <KN 0|1> <SINK 0|1> <logname> [capsec]
param([int]$shape = 1, [int]$g = 4, [int]$kn = 1, [int]$sink = 0, [string]$log = "C1_x", [int]$capsec = 420, [string]$exename = "port_ffn_fused.exe")
$exe = "E:\DSH\oneapi\$exename"
if (-not (Test-Path $exe)) { "no exe staged: $exe"; exit 2 }
$env:PORT_SHAPE = "$shape"; $env:PORT_G = "$g"; $env:PORT_KN = "$kn"; $env:PORT_SINK = "$sink"
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
"RUN shape=$shape G=$g KN=$kn SINK=$sink EXITCODE=$($p.ExitCode)"
Select-String -Path $outfile -Pattern 'DIFF|diff |ROW;|SKIPROW|GATE|phase msM|TOPS|#####|\[dev\]' | ForEach-Object { $_.Line }
