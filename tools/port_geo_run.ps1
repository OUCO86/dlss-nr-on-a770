# port_geo_run.ps1 -- driver for phase A (D1 geometry survival probe).
# One PROCESS per config, 3 reps inside the process, per-rep 20 s watchdog inside the exe,
# plus a hard process timeout here (20*3 + 40 s) in case the process itself wedges.
# Writes a CSV next to port.md and prints a compact table.
$ErrorActionPreference = 'Continue'
$SY = 'E:/WorkBuddy/toolchain-mamba/sycl'
$env:PATH = "$SY/Library/bin;$env:PATH"
$env:SYCL_DEVICE_FILTER = 'level_zero:gpu'
$env:SYCL_CACHE_PERSISTENT = '1'
$env:SYCL_CACHE_DIR = 'E:/DSH/sycl-cache'
$exe = 'E:/DSH/oneapi/port_geo_probe.exe'
$iters = 200
$lws  = @(64, 128, 256, 512)
$modes = @(0, 1, 2, 3)
$slms = @(8, 16, 32, 48, 64)
$csv = 'E:/DSH/s6/port_geo.csv'
"lw,mode,slm_kb,ngroups,status,rep_ms,reps_ok" | Set-Content -Encoding UTF8 $csv
$results = @()
foreach ($lw in $lws) {
  foreach ($slm in $slms) {
    foreach ($md in $modes) {
      $ng = [int](130560 / $lw)
      $psi = New-Object System.Diagnostics.ProcessStartInfo
      $psi.FileName = $exe
      $psi.Arguments = "$lw $md $slm $iters $ng"
      $psi.WorkingDirectory = 'E:/DSH/oneapi'
      $psi.RedirectStandardOutput = $true
      $psi.RedirectStandardError = $true
      $psi.UseShellExecute = $false
      $p = [System.Diagnostics.Process]::Start($psi)
      $tout = 20 * 3 + 40
      if (-not $p.WaitForExit([int]($tout * 1000))) {
        try { $p.Kill($true) } catch {}
        $out = $p.StandardOutput.ReadToEnd()
        $status = 'HANG-PROC'
      } else {
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        if ($p.ExitCode -eq 3) { $status = 'HANG' }
        elseif ($out -match 'VERDICT.*ALIVE') { $status = 'ALIVE' }
        else { $status = "FAIL($($p.ExitCode))" }
      }
      $reps = ([regex]::Matches($out, 'REP\d+ OK')).Count
      $ms = @([regex]::Matches($out, 'REP\d+ OK wall=([\d.]+)') | ForEach-Object { [double]$_.Groups[1].Value })
      $msline = if ($ms.Count) { ($ms | ForEach-Object { $_.ToString('0.000') }) -join '/' } else { '-' }
      $line = "$lw,$md,$slm,$ng,$status,$msline,$reps"
      $line | Add-Content -Encoding UTF8 $csv
      Write-Host ("lw={0,4} mode={1} slm={2,3}KB ng={3,5}  {4,-9} reps={5} wall_ms={6}" -f $lw, $md, $slm, $ng, $status, $reps, $msline)
      $results += [pscustomobject]@{ lw = $lw; mode = $md; slm = $slm; status = $status; ms = $(if ($ms.Count) { ($ms | Measure-Object -Minimum).Minimum } else { $null }) }
      if ($status -like '*HANG*' -or $status -like 'FAIL*') {
        # GPU may be wedged: run a one-shot canary config before continuing
        $p2 = Start-Process -FilePath $exe -ArgumentList "64 2 8 20 1" -WorkingDirectory 'E:/DSH/oneapi' -PassThru -NoNewWindow -RedirectStandardOutput 'E:/DSH/s6/port_geo_canary.txt'
        if (-not $p2.WaitForExit(30000)) { try { $p2.Kill($true) } catch {} ; Write-Host 'CANARY HANG -- GPU WEDGED, stopping sweep'; break }
        Write-Host ('canary exit=' + $p2.ExitCode)
      }
    }
  }
}
Write-Host "`n=== summary (min wall ms per surviving config) ==="
$results | Where-Object { $_.status -eq 'ALIVE' } | Sort-Object lw, slm, mode | Format-Table -AutoSize
$results | Group-Object status | ForEach-Object { "{0}: {1}" -f $_.Name, $_.Count }
