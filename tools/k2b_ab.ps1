# K2b_ab.ps1 -- the A/B paired replay for the section-51(7) open account.
# ASCII ONLY on purpose (knife2b.md P8/P11): this host runs Windows PowerShell 5.1 under
# the harness name "pwsh" (C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe);
# there is NO PowerShell 7 on PATH, so a child "pwsh" spawn fails -- everything is done
# in-process here.
# Rules honoured: no staging, never touches out\libxmx.dll / the three goldens, no commit.
# Env managed in-process: A side = NR_S6_FFN removed (default ON), B side = NR_S6_FFN=0.
# Products: s6\K2b_<side><pair>.log (stdout+stderr) and s6\K2b_<side><pair>_rt.txt (run_timing.txt copy)
$ErrorActionPreference = 'Stop'
Set-Location E:\DSH\oneapi

$DLL   = 'E:\DSH\builds\libxmx_rt2.dll'    # 9FDD0E93... : shipped source + 11-line rtcsv hunk, NO compile-time skip
$PLAN  = 'E:\DSH\out\plan_960x544.bin'
$REPLY = 'E:\DSH\oneapi\nr_replay_now.exe'
foreach ($t in $DLL,$PLAN,$REPLY) { if (-not (Test-Path -LiteralPath $t)) { Write-Host "MISSING $t"; exit 1 } }
if (@(Get-Process | Where-Object { $_.ProcessName -like 'LOP-Win64-Shipping*' }).Count -gt 0) {
  Write-Host 'BUSY: LOP-Win64-Shipping is running -- wait for it to exit'; exit 1 }

function Get-Md5Of([string]$p) { (Get-FileHash -LiteralPath $p -Algorithm MD5).Hash }
$gold = 'E:\DSH\dumps\bk.1301.bin','E:\DSH\dumps\bk.1301.skip.bin','E:\DSH\dumps\bk.1301.pre-skip-1a.bin'
Write-Host ('BEFORE gold = ' + (($gold | ForEach-Object { (Get-Md5Of $_).Substring(0,8) }) -join ' '))

# scrub every NR_* in this process, then set exactly the two traces we want
Get-ChildItem Env: | Where-Object { $_.Name -like 'NR_*' } | ForEach-Object { Remove-Item ("Env:" + $_.Name) }
$env:SYCL_DEVICE_FILTER    = 'level_zero:gpu'
$env:SYCL_CACHE_PERSISTENT = '1'
$env:SYCL_CACHE_DIR        = 'E:\DSH\sycl-cache'
$env:NR_RUN_TIMING         = '1'
$env:NR_BPACK_TRACE        = '1'

$t0 = Get-Date
foreach ($pair in 1,2) {
  foreach ($side in 'A','B') {
    if ($side -eq 'A') { Remove-Item Env:NR_S6_FFN -ErrorAction SilentlyContinue }   # default: S6-1a ON
    else               { $env:NR_S6_FFN = '0' }                                       # escape hatch: pre-S6 path
    $log = "E:\DSH\s6\K2b_$side$pair.log"
    $rt  = "E:\DSH\s6\K2b_$side${pair}_rt.txt"
    if (Test-Path -LiteralPath .\run_timing.txt) { Remove-Item -LiteralPath .\run_timing.txt -Force }
    # nr_replay_now writes its init banner to STDERR. With ErrorActionPreference=Stop PowerShell
    # promotes that to a terminating error and kills the batch after ~1s (seen 2026-11-03 11:4x).
    $ErrorActionPreference = 'Continue'
    & $REPLY $DLL $PLAN 'E:\DSH\out' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if (-not (Test-Path -LiteralPath .\run_timing.txt)) { Write-Host "NO run_timing.txt after side=$side pair=$pair (exit=$code)"; exit 1 }
    Copy-Item -LiteralPath .\run_timing.txt -Destination $rt -Force
    $nw  = @(Select-String -Path $log -Pattern '\[bwide\]' -ErrorAction SilentlyContinue).Count
    $np  = @(Select-String -Path $log -Pattern '\[bpack\]'  -ErrorAction SilentlyContinue).Count
    $nr  = @(Select-String -Path $rt  -Pattern '^rtcsv '     -ErrorAction SilentlyContinue).Count
    $tot = (Select-String -Path $log -Pattern '691 passes, total' -ErrorAction SilentlyContinue | ForEach-Object { $_.Line.Trim() }) -join ' || '
    Write-Host ("side=$side pair=$pair exit=$code bwide=$nw bpack=$np rtcsv_rows=$nr log_bytes=" + (Get-Item $log).Length)
    Write-Host ("   $tot")
    if ($nr -lt 691) { Write-Host "EMPTY/BROKEN rt account after side=$side pair=$pair -- STOP"; exit 1 }
  }
}
$mins = [math]::Round(((Get-Date) - $t0).TotalMinutes, 1)
Write-Host "batch_minutes = $mins   (over 20 min => cool the GPU before the next batch)"
Write-Host ('AFTER  gold = ' + (($gold | ForEach-Object { (Get-Md5Of $_).Substring(0,8) }) -join ' '))
Write-Host ('oneapi\libxmx_sycl.dll = ' + (Get-Md5Of 'E:\DSH\oneapi\libxmx_sycl.dll'))
Write-Host ('out\libxmx.dll = ' + (Get-Md5Of 'E:\DSH\out\libxmx.dll'))
Write-Host ('leftover nr_replay procs = ' + @(Get-Process | Where-Object { $_.ProcessName -match 'nr_replay' }).Count)
Write-Host 'NEXT: python E:\DSH\s6\k2b_rtcmp.py'
