<# ab.ps1 — DS 接手：同热交替 A/B（军规 5 计时关，16 对协议）  [v2 修 bug]
   用法:
     pwsh -File E:\DSH\ab.ps1 -DllA E:\DSH\out\libxmx.dll -DllB E:\DSH\out\libxmx_new.dll -Pairs 16 -EnvB 'NR_B_WIDE=0;NR_G32_PUB=1'
   判据：赢 >=10 且均值 <= -0.5ms = 转正；|均值| <= 0.5 = 带内中性留形不吹；正 = 按军规 7 找实现错，不裸回退。
   读数：run0 丢弃（warmup），run1..3 取中位。A 侧环境变量必须 unset（空串在 C 里 = 真，老坑）。

   v2 修的两处（2026-11-01，子代理逮到）：
     * 局部量改名 $ma/$mb —— PowerShell 变量名大小写不敏感，旧版 `$b = MedMs $B` 会覆写参数 $B，
       第 2 对起把上一次的毫秒数当 dll 路径传进去（"cannot load 66.47"），delta 全是同一个陈旧数。
       **旧版 ab.ps1 出过的所有 16 对数一律作废。**
     * 本文件必须存成 UTF-8 带 BOM，否则 Windows PowerShell 5.1 按 GBK 解码：中文注释里的字节会截断字符串、
       `<--` 会被当重定向符。
#>
param(
  [string]$DllA = 'E:\DSH\out\libxmx.dll',
  [string]$DllB = 'E:\DSH\out\libxmx_new.dll',
  [int]$Pairs = 16,
  [int]$Runs  = 4,
  [string]$EnvA = '',
  [string]$EnvB = ''
)
$ErrorActionPreference = 'Continue'
$env:SYCL_DEVICE_FILTER = 'level_zero:gpu'
$plan = 'E:\DSH\out\plan_960x544.bin'
$out  = 'E:\DSH\out'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function MedMs([string]$dll, [string]$envspec, [string]$tag) {
  foreach ($kv in @('NR_B_WIDE','NR_G32_PUB','NR_Q_FUSE','NR_Q_FUSE_B','NR_QW_FUSE','NR_B6','NR_RUN_TIMING','NR_WQFUSE','NR_CHIP_CS','NR_FF9','NR_FF3','NR_RES8','NR_PGRAPH')) {
    Remove-Item "env:${kv}" -ErrorAction SilentlyContinue      # A/B 两侧都清场
  }
  if ($envspec) {
    foreach ($pair in ($envspec -split ';')) {
      if ($pair.Trim() -eq '') { continue }
      $k, $v = $pair -split '=', 2
      Set-Item -Path "env:$($k.Trim())" -Value $v.Trim()       # 要 off 用 unset，不要置空串
    }
  }
  Push-Location 'E:\DSH\oneapi'
  $raw = & .\nr_replay_now.exe $dll $plan $out 2>&1
  Pop-Location
  $raw | Out-File -Encoding utf8 "E:\DSH\logs\ab_${tag}_${stamp}.log"
  $passes = @($raw | Select-String '\((\d+) passes\)' | ForEach-Object { [int]$_.Matches[0].Groups[1].Value })
  $vals = @($raw | Select-String 'run \d+:\s+([0-9.]+) ms' | ForEach-Object { [double]$_.Matches[0].Groups[1].Value })
  $kept = @($vals | Select-Object -Skip 1)
  if ($kept.Count -eq 0) { return @{ med = [double]::NaN; passes = -1 } }
  $sorted = $kept | Sort-Object
  return @{ med = $sorted[[int]($sorted.Count / 2)]; passes = ($passes | Select-Object -Last 1) }
}

$deltas = @(); $wins = 0
for ($i = 1; $i -le $Pairs; $i++) {
  if ($i % 2) { $ra = MedMs $DllA $EnvA 'A'; $rb = MedMs $DllB $EnvB 'B' }
  else        { $rb = MedMs $DllB $EnvB 'B'; $ra = MedMs $DllA $EnvA 'A' }
  $ma = $ra.med; $mb = $rb.med
  if ([double]::IsNaN($ma) -or [double]::IsNaN($mb)) { Write-Output "pair $i : NaN —— 读数无效，停下查日志，别下结论"; break }
  $d = [math]::Round($mb - $ma, 3); $deltas += $d
  if ($d -lt 0) { $wins++ }
  Write-Output ("pair {0,2}: A={1:N3} B={2:N3} delta={3:+0.000;-0.000} passes A/B={4}/{5}" -f $i, $ma, $mb, $d, $ra.passes, $rb.passes)
}
if ($deltas.Count -eq $Pairs) {
  $mean = [math]::Round(($deltas | Measure-Object -Average).Average, 3)
  Write-Output ("== {0} 对：B 赢 {1} / 负 {2}，均值 {3:+0.000;-0.000} ms" -f $Pairs, $wins, ($Pairs - $wins), $mean)
  $verdict = if ($wins -ge 10 -and $mean -le -0.5) { '转正' }
             elseif ([math]::Abs($mean) -le 0.5)   { '带内中性 = 留形不吹' }
             else                                  { '负收益 = 按军规7 找实现错，不裸回退' }
  Write-Output "== 判定：$verdict"
  $deltas | Out-File -Encoding utf8 "E:\DSH\logs\ab_${stamp}.txt"
} else {
  Write-Output '== 对数不完整：本轮作废'
}
