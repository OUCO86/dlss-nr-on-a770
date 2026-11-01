# port_geo_run3.ps1 -- phase A, LAST cells (post-reboot continuation):
# LW=256 modes 2/3 (the cells the 13:53 reboot cut off), LW=512 heavy, and the LIGHT
# payload sweep (mode 4 = traffic+CTA barrier with NO wide vectors -> minimal GRF) plus
# iters=0 pure-launch legality at LW=256/512/1024. This separates "the 512-thread
# geometry itself is illegal" from "only our heavy ESIMD payload dies at 256".
$ErrorActionPreference = 'Continue'
$SY = 'E:/WorkBuddy/toolchain-mamba/sycl'
$env:PATH = "$SY/Library/bin;$env:PATH"
$env:SYCL_DEVICE_FILTER = 'level_zero:gpu'
$env:SYCL_CACHE_PERSISTENT = '1'
$env:SYCL_CACHE_DIR = 'E:/DSH/sycl-cache'
$exe = 'E:/DSH/oneapi/port_geo_probe.exe'
$csv = 'E:/DSH/s6/port_geo3.csv'
"lw,mode,slm_kb,ngroups,iters,status,rep_wall_ms,rep_gpu_ms,reps_ok" | Set-Content -Encoding UTF8 $csv
$cfg = New-Object System.Collections.Generic.List[object]
foreach ($slm in 16,32) { $cfg.Add(@(256,2,$slm,200)); $cfg.Add(@(256,3,$slm,200)) }
$cfg.Add(@(256,0,8,200)); $cfg.Add(@(256,1,8,200)); $cfg.Add(@(256,2,8,200)); $cfg.Add(@(256,3,8,200))
foreach ($md in 0,1,2,3) { $cfg.Add(@(512,$md,8,200)); $cfg.Add(@(512,$md,32,200)) }
foreach ($lw in 256,512,1024) { foreach ($slm in 8,32,64) { $cfg.Add(@($lw,4,$slm,200)) }; $cfg.Add(@($lw,5,32,200)) }
foreach ($lw in 256,512,1024) { foreach ($md in 1,4) { $cfg.Add(@($lw,$md,8,0)) } }
$seen = @{}
foreach ($c in $cfg) {
  $lw=$c[0]; $md=$c[1]; $slm=$c[2]; $it=$c[3]
  $key = "$lw-$md-$slm-$it"; if ($seen.ContainsKey($key)) { continue }; $seen[$key] = 1
  # skip cells already measured in port_geo.csv / port_geo2.csv (iters=200)
  if ($it -eq 200) {
    foreach ($prev in 'E:/DSH/s6/port_geo.csv','E:/DSH/s6/port_geo2.csv') {
      if (Test-Path $prev) { foreach ($r in Import-Csv $prev) { if ([int]$r.lw -eq $lw -and [int]$r.mode -eq $md -and [int]$r.slm_kb -eq $slm) { $key = 'dup' } } }
    }
    if ($key -eq 'dup') { continue }
  }
  $ng = [int](130560 / $lw); if ($ng -lt 1) { $ng = 1 }
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $exe; $psi.Arguments = "$lw $md $slm $it $ng"
  $psi.WorkingDirectory = 'E:/DSH/oneapi'
  $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.UseShellExecute = $false
  $p = [System.Diagnostics.Process]::Start($psi)
  if (-not $p.WaitForExit(100000)) { try { $p.Kill($true) } catch {}; $out = $p.StandardOutput.ReadToEnd(); $st = 'HANG-PROC' }
  else { $out = $p.StandardOutput.ReadToEnd(); $st = if ($p.ExitCode -eq 3) { 'HANG' } elseif ($out -match 'VERDICT.*ALIVE') { 'ALIVE' } else { "FAIL(0x{0:X8})" -f $p.ExitCode } }
  $wall = @([regex]::Matches($out, 'REP\d+ OK wall=([\d.]+)') | ForEach-Object { $_.Groups[1].Value })
  $gpu  = @([regex]::Matches($out, 'gpu=([\d.]+)') | ForEach-Object { $_.Groups[1].Value })
  $reps = ([regex]::Matches($out, 'REP\d+ OK')).Count
  "$lw,$md,$slm,$ng,$it,$st,$($wall -join '/'),$($gpu -join '/'),$reps" | Add-Content -Encoding UTF8 $csv
  Write-Host ("lw={0,4} mode={1} slm={2,3}KB it={3,3} ng={4,5}  {5,-16} reps={6} gpu_ms={7}" -f $lw,$md,$slm,$it,$ng,$st,$reps,($gpu -join '/'))
  if ($st -like '*HANG*' -or $st -like 'FAIL*') {
    $p2 = Start-Process -FilePath $exe -ArgumentList "64 2 8 20 1" -WorkingDirectory 'E:/DSH/oneapi' -PassThru -NoNewWindow -RedirectStandardOutput 'E:/DSH/s6/port_geo_canary.txt'
    if (-not $p2.WaitForExit(30000)) { try { $p2.Kill($true) } catch {}; Write-Host 'CANARY HANG -- GPU WEDGED, stopping sweep'; break }
  }
}
Write-Host "done"
