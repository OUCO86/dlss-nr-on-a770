<#
  tools/stress_repeat.ps1 -- the rule-46 stress gate: every kernel that wants to go into shipped
  must pass "same-process N relaunches + 0xA5 sentinel scrub, bad=0". This runner drives the four
  arms and enforces the two COUNTER-CHECKS that give the instrument its teeth:
      CTRL  (stress_repeat.exe)          qr_kernel_rowthread, no SLM/no barrier  => MUST be bad=0
      PORT  (port_ffn_fused.exe)         their core, LW=16 KN=1                  => MUST be bad>0
      ATT   (s6b_att.exe)                our att 5-in-1 leg                      => reported
      FFN2  (s6_ffn_block4.exe / b4_*)   our SHIPPED 1a chain (C2_STAGE=1)       => reported
  ASCII ONLY (rule 16b/16c). Processes are independent, >=60 s apart (rule 47 / P18: a ~5% race
  cannot be attributed with 10 back-to-back processes, and back-to-back runs shift TOPS by >2x).
  usage: powershell -File tools/stress_repeat.ps1 [-N 200] [-Arms ctrl,port,att,ffn2] [-Exe b4_base.exe]
#>
param([int]$N = 200, [string]$Arms = 'ctrl,port,att,ffn2', [string]$Exe = 'b4_base.exe',
      [string]$RunDir = 'E:\DSH\oneapi', [int]$Gap = 60, [int]$Cap = 1500)
$ErrorActionPreference = 'Continue'
$PY = 'C:\Users\wangz\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe'
$env:SYCL_DEVICE_FILTER = 'level_zero:gpu'
$env:SYCL_CACHE_PERSISTENT = '1'; $env:SYCL_CACHE_DIR = 'E:\DSH\sycl-cache-portE'
$running = @(Get-Process | Where-Object { $_.ProcessName -like 'LOP-Win64-Shipping*' }).Count
Write-Output ("game procs (must be 0) = " + $running)
if ($running -gt 0) { Write-Output 'ABORT: the game is running'; exit 9 }

function Grab([string]$log, [string]$pat) {
  return (& $PY -c "import sys,re;d=open(sys.argv[1],'rb').read();t=d.decode('utf-16' if d[:2] in (b'\xff\xfe',b'\xfe\xff') else 'utf-8',errors='replace');pat=re.compile(sys.argv[2]);ls=[l.strip()[:200] for l in t.splitlines() if pat.search(l)];print(' ;; '.join(ls[:5]) if ls else 'NO-MATCH')" $log $pat)
}
function Arm([string]$name, [string]$exe, [hashtable]$envs, [string]$pat) {
  Get-ChildItem Env: | Where-Object { $_.Name -match '^(PORT_|C2_|M_|S6B_|NR_|ATT_)' } | ForEach-Object { Remove-Item ("Env:" + $_.Name) }
  foreach ($k in $envs.Keys) { Set-Item "env:$k" ([string]$envs[$k]) }
  $logf = "E:\DSH\s6\SR_${name}_$([DateTimeOffset]::Now.ToUnixTimeSeconds()).log"
  $p = Start-Process -FilePath (Join-Path $RunDir $exe) -WorkingDirectory $RunDir `
        -RedirectStandardOutput $logf -RedirectStandardError ($logf + '.err') -PassThru -NoNewWindow
  if (-not $p.WaitForExit($Cap * 1000)) { try { $p.Kill() } catch {}; Write-Output ("{0,-6} {1} TIMEOUT" -f $name, $exe); return $null }
  $line = Grab $logf $pat
  Write-Output ("{0,-6} {1,-22} {2}" -f $name, $exe, $line)
  Start-Sleep -Seconds $Gap
  return $line
}
$want = $Arms.Split(',')
$bad_ctrl = $null; $bad_port = $null
foreach ($a in $want) {
  switch ($a.Trim()) {
    'ctrl'  { $r = Arm 'ctrl' 'stress_repeat.exe' @{} ("STRESS SUMMARY|STRESS s="); if ($r -match 'bad=(\d+)') { $bad_ctrl = [int]$Matches[1] } }
    'port'  { $r = Arm 'port' 'port_ffn_fused.exe' @{ PORT_SHAPE='1'; PORT_G='4'; PORT_KN='1'; PORT_SINK='0'; PORT_STRESS="$N" } ("STRESS SUMMARY|STRESS s="); if ($r -match 'bad=(\d+)') { $bad_port = [int]$Matches[1] } }
    'att'   { $r = Arm 'att'  's6b_att.exe' @{ S6B_ATT_REPEAT="$N" } ("STRESS SUMMARY|STRESS s=|GATE: ") }
    'ffn2'  { $r = Arm 'ffn2' $Exe @{ C2_SHAPE='1'; C2_STAGE='1'; M_MODE='1'; M_REPEAT="$N" } ("FLAKY |B3GATE|GATE PASS|GATE FAIL") }
    default { Write-Output ("unknown arm: " + $a) }
  }
}
Write-Output '--- teeth check ---'
if ($bad_ctrl -eq $null) { Write-Output 'CTRL arm did not report' }
elseif ($bad_ctrl -ne 0) { Write-Output ("CTRL bad=" + $bad_ctrl + " => INSTRUMENT BROKEN (a barrier-free kernel must be bad=0)") }
else { Write-Output ("CTRL bad=0 OK (no false positives)") }
if ($bad_port -eq $null) { Write-Output 'PORT arm did not report' }
elseif ($bad_port -eq 0) { Write-Output 'PORT bad=0 => the positive control lost its signal (re-check the arm/scrub set)' }
else { Write-Output ("PORT bad=" + $bad_port + " OK (the instrument does catch the known race)") }
Write-Output ("leftover procs = " + @(Get-Process | Where-Object { $_.ProcessName -match 'stress_repeat|port_ffn|s6b_att|b4_|s6_ffn_block' }).Count)
