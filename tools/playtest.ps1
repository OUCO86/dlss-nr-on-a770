<# playtest.ps1 — 游戏实机画面验收用的加载位切换器（只在 E:\DSH\out 内动文件）
   用法:
     powershell -NoProfile -File E:\DSH\playtest.ps1 -List                 # 列出可试的件与 md5
     powershell -NoProfile -File E:\DSH\playtest.ps1 -Use test_1270e4m3.dll # 把它放进加载位 libxmx.dll
     powershell -NoProfile -File E:\DSH\playtest.ps1 -Restore               # 回到出货件（E2D5E574）
   规矩:
     * 游戏加载的是 E:\DSH\out\libxmx.dll（OptiScaler.ini 里 [DlssNr] Folder = E:\DSH\out）。
     * 任何时刻 libxmx.dll.bak-shipped 都是出货件原件，-Restore 就是把它 copy 回来。
     * 换件前请确认游戏没在跑（LOP.exe 进程在 = 文件被占用，脚本会拒绝并提示）。
#>
param(
  [string]$Use = '',
  [switch]$List,
  [switch]$Restore
)
$ErrorActionPreference = 'Stop'
$OUT  = 'E:\DSH\out'
$LOAD = Join-Path $OUT 'libxmx.dll'
$SHIP = Join-Path $OUT 'libxmx.bak-shipped.dll'     # 出货件原件（E2D5E574）

function Md5Short([string]$p) { if (Test-Path $p) { (Get-FileHash -Algorithm MD5 $p).Hash.Substring(0,12) } else { '--------' } }

# 一次性把当前出货件存成原件（只存一次，之后不覆盖）
if (-not (Test-Path $SHIP)) {
  Copy-Item $LOAD $SHIP
  Write-Output ("已建立出货件原件: libxmx.bak-shipped.dll = " + (Md5Short $SHIP))
}

if ($List) {
  Write-Output ("load slot : libxmx.dll = " + (Md5Short $LOAD))
  Write-Output ("shipped   : libxmx.bak-shipped.dll = " + (Md5Short $SHIP))
  Write-Output '--- 可试的件（test_*.dll / *_new.dll）---'
  Get-ChildItem $OUT -Filter '*.dll' | Where-Object { $_.Name -like 'test_*' -or $_.Name -eq 'libxmx_new.dll' } |
    ForEach-Object { "  {0,-34} {1}  {2}" -f $_.Name, (Md5Short $_.FullName), $_.LastWriteTime.ToString('MM-dd HH:mm') }
  return
}

$busy = Get-Process -Name 'LOP' -ErrorAction SilentlyContinue
if ($busy) { Write-Output 'LOP.exe 正在运行 —— 先退出游戏再换件（dll 被占用）。'; return }

if ($Restore) {
  Copy-Item $SHIP $LOAD -Force
  Write-Output ("已回到出货件: libxmx.dll = " + (Md5Short $LOAD))
  return
}

if ($Use) {
  $src = Join-Path $OUT $Use
  if (-not (Test-Path $src)) { Write-Output "找不到 $Use —— 先用 -List 看有哪些件"; return }
  Copy-Item $LOAD (Join-Path $OUT ("libxmx.before-" + (Md5Short $LOAD) + ".keep")) -Force
  Copy-Item $src $LOAD -Force
  Write-Output ("加载位已换: libxmx.dll = " + (Md5Short $LOAD) + "   （来源 $Use）")
  Write-Output '进游戏看画面；要回出货件： powershell -NoProfile -File E:\DSH\playtest.ps1 -Restore'
  return
}

Write-Output '什么都没做。用 -List / -Use <file> / -Restore'
