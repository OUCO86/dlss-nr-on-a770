# 游戏加载链（Lies of P + OptiScaler NrBridge + 我们的引擎）—— DS 接手版，路径已改到 `E:\DSH`

> 这一页是从**源码 + 游戏目录实测**核出来的，不是复述旧笔记。所有引用都给到 文件:行。
> 代码位置：`src/OptiScaler/OptiScaler/nrbridge/`（打过补丁的 OptiScaler v0.9.4-final，**不 link、不 vendored**，见 optiscaler-bridge.md:16）。

## 1. 一条链，从双击到出帧

```
用户双击  F:\Game\Lies of P\LOP.exe
  └→ LiesofP\Binaries\Win64\LOP-Win64-Shipping.exe
       └→ 加载 Win64\dxgi.dll                      = 打过补丁的 OptiScaler（26,664,448 B，2026-10-14 装）
            │                                        官方原件备份：src/dlss-nr-on-a770/backups/liesofp-20261012-1945/dxgi.dll.official-v094
            ├→ 读同目录 OptiScaler.ini 的 [DlssNr] 段：
            │     Enabled / RunBeforeSR = auto
            │     WrapLists = true      （命令表切割靠它）
            │     Network   = true      （跑网络）
            │     MvReproject = true
            │     Folder    = E:\DSH\out      ← 2026-11-01 DS 接手加的一行；没有这行就走下面的硬编码默认
            ├→ NrBridge.cpp:600  NrFolder()：有 Folder 用 Folder，
            │                     否则默认 E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work
            ├→ NrPipeline.cpp:312-313  从 folder 里 LoadLibrary：
            │     folder\libnr_image.dll   （host 两趟：pre=16 特征通道 / post=合成回写）
            │     folder\nr_net.dll        （九个导出；= nr_replay.c 不带 NR_REPLAY_STANDALONE、
            │                               把 plan_960x544.obj 编进去后 -LD 出来的 dll）
            ├→ nr_net_open(library="libxmx.dll", folder, blobs)   （nr_replay.c:1295/1309）
            │     runtime_up():  SetDllDirectoryA(folder)         ← 不还原！桥在调用前后 Get/Set 包住（optiscaler-bridge:1645）
            │                    打开 folder\nr_net.log 做诊断
            │                    尝试 folder 下的一批 .spv（gemm_coopmat / gemm_staged32[_deep] /
            │                      attention_rows / gemm_tiled32 / nr_pre / nr_post）——
            │                      **SYCL 引擎里这些 init 记录是 (void)path 空操作，.spv 从不执行**（10-31 12:2x 破案）
            │     plan_up():     读 folder\plan_960x544.bin（455,324,584 B，1277 个 blob）上传显存
            └→ 每帧：命令表在 cut 处拆两半 → EnqueueGap（nr_replay.c 的 gap 机制）→ 691 闭包 cgraph 一次 submit
                 → 引擎 dll = folder\libxmx.dll（我编的 libxmx_sycl.dll 改名放这儿）
                      └→ 依赖链 sycl9.dll / sycl-jit.dll / ur_loader.dll / libmmd / tbb12 / umf /
                         libhwloc-15 / libiomp5md / svml_dispmd / common_clang64 全部从同一 folder 解析
```

### ⚠ §92 铁律（当年 GPUCrash 事故的根因）
**UR adapter 只从 EXE 自己所在目录枚举**（`UR_ADAPTERS_SEARCH_PATH` / `FORCE_LOAD` 对这个 loader build 无效，已离线证明）。
所以游戏目录 `Win64\` 里必须有 `ur_adapter_level_zero.dll` + `ur_adapter_level_zero_v2.dll`（现在在位，2026-10-15 那份）。
缺了它 → 游戏进程只枚举到 OpenCL 的 Arc → 融合核在那儿 fault（2026-10-20 GPUCrash）。
`tools/swap_engine.bat swap` 干的正是"换 dll + 铺这 7 个 adapter 依赖"。

## 2. 目录映射（WB → DSH，2026-11-01 起）

| 角色 | 原（WorkBuddy，现在**只读**） | 新（DS 接手，**我的所有改动都在这**） |
|---|---|---|
| 源码/笔记仓 | `E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770` | `E:\DSH\dlss-nr-on-a770`（分支 `ds-takeover-2026-11-01`；`origin`=GitHub，`wblocal`=原仓） |
| 引擎件目录（游戏加载的 folder） | `…\dlss-nr-on-a770\work` | **`E:\DSH\out`**（已用 ini 的 `Folder=` 指过去） |
| bench/门 的运行时 stage 位 | `E:\WorkBuddy\2026-10-09-04-20-55\oneapi` | `E:\DSH\oneapi`（已放齐 14 个运行时 dll + `nr_replay_now.exe`） |
| 帧判官 exe | `oneapi\nr_replay_now.exe` | `E:\DSH\oneapi\nr_replay_now.exe` |
| 金标 1301 | `oneapi\bk.1301.bin` | `E:\DSH\dumps\bk.1301.bin` |
| 我的产物 | —（原 work\libxmx.dll = md5 b8908bd2，**不动**） | `E:\DSH\out\libxmx.dll`（当前=与 b8908bd2 逐位同的基线件）+ `E:\DSH\out\libxmx_new.dll`（待验收件） |
| 日志 | `work\nr_net.log`、`Win64\OptiScaler.log` | `E:\DSH\out\nr_net.log`（游戏写）、`E:\DSH\logs\*`（我写） |
| 工具链 | `E:\WorkBuddy\toolchain-mamba\sycl`、MSVC18、SDK | **只读引用同一份**；要装新东西只装 `E:\DSH\toolchain\`，**绝不写 C 盘** |

## 3. 一刀的完整回路（以后每刀都走这四条命令）

```bash
# ① 编引擎 + 全套门（40 个 gate 脚本，1250 门；任何一红=当场停）
bash E:/DSH/build_dll.sh                    # 产物 E:\DSH\out\libxmx_new.dll + md5 落 E:\DSH\logs
# ② 端到端逐位对拍（walk 1301 EXACT + passes）
pwsh -File E:\DSH\walk.ps1 -Dll E:\DSH\out\libxmx_new.dll -Tag new
# ③ 同热交替 A/B（16 对协议）
pwsh -File E:\DSH\ab.ps1 -A E:\DSH\out\libxmx.dll -B E:\DSH\out\libxmx_new.dll -Pairs 16
# ④ 转正才 cp（游戏重启即生效；回退=换回旧件）
cp /e/DSH/out/libxmx_new.dll /e/DSH/out/libxmx.dll
```

**bench 层单独刀**（先定价再上 dll，军规 8）：
```bash
bash E:/DSH/bench.sh E:/DSH/dlss-nr-on-a770/src/bench/sycl/<x>.cpp E:/DSH/oneapi/<x>.exe
```

## 4. 游戏侧验收（只有用户能双击）

1. 双击 `F:\Game\Lies of P\LOP.exe`，游戏里 Insert 开 OptiScaler 面板 A/B。
2. 看 `Win64\OptiScaler.log`：`NrBridge gap run #N took=…ms | work=…` = NR 本体成本；
   启动头几行会打印桥用的 folder（现在应是 `E:\DSH\out`）。
3. 画面判据：`E:\DSH\out\nr_net.log` + 眼睛；红 = 我把 `libxmx.dll` 换回 `E:\DSH\out\libxmx_b8908bd2.dll.bak`。

## 5. 回退（两行搞定，随时可逆）

- 恢复 WB 原加载位：删掉 `OptiScaler.ini` 里 `Folder = E:\DSH\out` 那行（或还原 `OptiScaler.ini.dsh-backup-20261101`）。
- 恢复引擎件：`E:\DSH\out\libxmx.dll` 换回 `E:\DSH\out\libxmx_b8908bd2.dll.bak`（我每次转正前都会留 `.bak`）。
- **WB 那侧从头到尾没被我改过**：`work\libxmx.dll` 仍是 b8908bd2，`oneapi\` 只有我 stage 的 bench exe/dll 副本。
