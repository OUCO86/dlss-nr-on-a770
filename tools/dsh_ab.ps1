<# ab.ps1 — DS 接手：同热交替 A/B（军规 5 的计时关，16 对协议）
   用法:
     pwsh -File E:\DSH\ab.ps1 -A E:\DSH\out\libxmx.dll -B E:\DSH\out\libxmx_new.dll -Pairs 16
   判据：赢 >=10 且均值 <= -0.5ms = 转正；±0.5 带内 = 中性留形不吹；负 = 找实现错（军规 7），不裸回退。
   读数取每次 run1..3 的中位（run0 是 warmup）。
#>
param(
  [string]$A = 'E:\DSH\out\libxmx.dll',
  [string]$B = 'E:\DSH\out\libxmx_new.dll',
  [int]$Pairs = 16,
  [int]$Runs  = 4
)
$env:SYCL_DEVICE_FILTER = 'level_zero:gpu'
$plan = 'E:\DSH\out\plan_960x544.bin'
$out  = 'E:\DSH\out'
function MedMs([string]$dll) {
  Push-Location 'E:\DSH\oneapi'
  $raw = & .\nr_replay_now.exe $dll $plan $out 2>&1
  Pop-Location
  $v = @($raw | Select-String 'run \d+:\s+([0-9.]+) ms' | ForEach-Object { [double]$_.Matches[0].Groups[1].Value })
  $v = $v | Select-Object -Skip 1 | Sort-Object
  if ($v.Count -eq 0) { return [double]::NaN }
  return $v[[int]($v.Count/2)]
}
$deltas = @(); $wins = 0
for ($i = 1; $i -le $Pairs; $i++) {
  if ($i % 2) { $a = MedMs $A; $b = MedMs $B } else { $b = MedMs $B; $a = MedMs $A }
  $d = [math]::Round($b - $a, 3)
  $deltas += $d
  if ($d -lt 0) { $wins++ }
  Write-Output ("pair {0,2}: A={1:N2} B={2:N2} delta={3:+0.000;-0.000}  (B-A, 负=B 快)" -f $i, $a, $b, $d)
}
$mean = [math]::Round(($deltas | Measure-Object -Average).Average, 3)
Write-Output ("== {0} 对：B 赢 {1} / 负 {2}，均值 {3:+0.000;-0.000} ms" -f $Pairs, $wins, ($Pairs-$wins), $mean)
$verdict = if ($wins -ge 10 -and $mean -le -0.5) { '转正' } elseif ([math]::Abs($mean) -le 0.5) { '带内中性=留形不吹' } else { '负收益=按军规7 找实现错，不裸回退' }
Write-Output "== 判定：$verdict"
$deltas | Out-File -Encoding utf8 "E:\DSH\logs\ab_$(Get-Date -Format yyyyMMdd-HHmmss).txt"
