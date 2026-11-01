# run_s6b.ps1 -- one S6-1b probe CONFIG per process, watchdog'd (the run_C1.ps1 shape).
# usage: powershell -File E:/DSH/s6/run_s6b.ps1 <cfg 0..12> <smoke|time> [capsec] [force 0|1]
# smoke = ONE launch, 20s watchdog -> verdict LIVE / HANG / REJECT
# time  = 5 groups x 15 reps, 60ms gaps (GPU event + host wall), longer cap
param([int]$cfg = 0, [string]$mode = "smoke", [int]$capsec = 20, [int]$force = 0)
$run = "E:\DSH\oneapi"
$src = "E:\DSH\dlss-nr-on-a770\src\bench\sycl\s6b_probe.exe"
if (-not (Test-Path $src)) { "no exe: $src (compile it first)"; exit 2 }
Copy-Item $src (Join-Path $run "s6b_probe.exe") -Force     # ALWAYS re-stage (the stale-exe trap)
$exe = Join-Path $run "s6b_probe.exe"
$env:S6B_CFG = "$cfg"
if ($mode -eq "smoke") { $env:S6B_SMOKE = "1" } else { Remove-Item Env:S6B_SMOKE -ErrorAction SilentlyContinue }
if ($force -eq 1) { $env:S6B_FORCE = "1" } else { Remove-Item Env:S6B_FORCE -ErrorAction SilentlyContinue }
$env:SYCL_DEVICE_FILTER = "level_zero:gpu"
$env:SYCL_CACHE_PERSISTENT = "1"; $env:SYCL_CACHE_DIR = "E:\DSH\sycl-cache"
$log = "S6b_c{0}_{1}" -f $cfg, $mode
$outfile = "E:\DSH\s6\$log.log"; $errfile = "E:\DSH\s6\$log.err"
$p = Start-Process -FilePath $exe -WorkingDirectory $run `
     -RedirectStandardOutput $outfile -RedirectStandardError $errfile -PassThru -NoNewWindow
if (-not $p.WaitForExit($capsec * 1000)) {
    "TIMEOUT > $capsec s -> killing PID $($p.Id)"
    try { $p.Kill(); Start-Sleep -Milliseconds 500 } catch {}
    "VERDICT cfg=$cfg mode=${mode} -- HANG"
    exit 3
}
"RUN cfg=$cfg mode=$mode force=$force EXITCODE=$($p.ExitCode)"
Select-String -Path $outfile -Pattern '####|blocks|SKIPROW|LIVE|REJECT|WALL|GPU|CSVROW|DCE|local_mem' | ForEach-Object { $_.Line }
