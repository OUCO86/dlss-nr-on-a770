<# walk.ps1 — DS 接手：帧判官（端到端 walk + passes + 1301 逐位对拍）
   用法:
     pwsh -File E:\DSH\walk.ps1                      # 用 E:\DSH\out\libxmx.dll，tag=cur
     pwsh -File E:\DSH\walk.ps1 -Dll E:\DSH\out\libxmx_new.dll -Tag new -Runs 4
   判据（军规 5）：passes 必须与基线同构（现在=691，S6 后按新基线）；1301 md5 必须 = bk.1301.bin。
#>
param(
  [string]$Dll  = 'E:\DSH\out\libxmx.dll',
  [string]$Tag  = 'cur',
  [int]$runsOut    = 4,
  [string]$Gold = 'E:\DSH\dumps\bk.1301.bin'
)
$ErrorActionPreference = 'Continue'
$env:SYCL_DEVICE_FILTER = 'level_zero:gpu'
$env:NR_DUMP_OUT = "E:\DSH\dumps\$Tag"
$plan = 'E:\DSH\out\plan_960x544.bin'
$out = 'E:\DSH\out'
New-Item -ItemType Directory -Force -Path 'E:\DSH\logs','E:\DSH\dumps' | Out-Null
Push-Location 'E:\DSH\oneapi'
$raw = & .\nr_replay_now.exe $Dll $plan $out 2>&1
Pop-Location
$raw | Out-File -Encoding utf8 "E:\DSH\logs\walk_$Tag.txt"
$dev   = ($raw | Select-String 'device ' | Select-Object -First 1)
$ext   = ($raw | Select-String 'extent ' | Select-Object -First 1)
$runsOut  = $raw | Select-String 'run \d+: .*passes' | ForEach-Object { $_.ToString().Trim() }
$walk  = $raw | Select-String 'walk run' | ForEach-Object { $_.ToString().Trim() }
Write-Output "dll   : $Dll"
Write-Output $dev; Write-Output $ext
Write-Output ("runs  : " + ($runsOut -join ' | '))
Write-Output ("walk  : " + ($walk -join ' | '))
$dump = "E:\DSH\dumps\$Tag.1301.bin"
if (Test-Path $dump) {
  $a = (Get-FileHash -Algorithm MD5 $dump).Hash
  $b = (Get-FileHash -Algorithm MD5 $Gold).Hash
  $verdict = if ($a -eq $b) { '1301 EXACT' } else { '1301 MISMATCH' }
  Write-Output ("1301  : $verdict  ($Tag=$a  bk=$b)  bytes=" + (Get-Item $dump).Length)
} else {
  Write-Output "1301  : 没有 dump（检查 NR_DUMP_OUT）"
}
if ($LASTEXITCODE -ne 0) { Write-Output "exit=$LASTEXITCODE  <-- 红，当场停" }
