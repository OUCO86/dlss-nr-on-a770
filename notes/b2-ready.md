
## B2-ready（**由主会话代写：代理在落盘前被暂停令打断**；下次开工直接照这一节走，不用再问）

**现场已核（16:2x，全部实证）**：`git` = `b54de7e`、porcelain **CLEAN**；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **`ABB969FE…`**；三金标 `bk.1301.bin`=`bk.1301.skip.bin`=**`DD49827D…`**、`bk.1301.pre-skip-1a.bin`=**`249A46F3…`**；**GPU/bench 进程 = 0**；`E:\DSH\tmp\pe_stress.cpp`、`pe_stress_att.cpp` 仍在（已被仓内版 `src/bench/sycl/stress_repeat.cpp` 取代，可删）。

### ① B2 要写的东西（端到端合成体，**目前不存在**）
`src/bench/sycl/port_e_chain.cpp` = **一条 C=64 链、11 发 → 3 发**，两半各自已绿、只差串起来：
- **att 半** = `s6b_att.cpp` 的 `att5L::fused`（**0 bad / 1200 连发**，GATE GREEN，C64 档 5 发合一相 wall **0.4329** / GPU 0.3531）；
- **FFN 半** = `s6_ffn_block4.cpp` 的 `ffn2::fused`（**0 bad / 600 连发**，9/9 + 13/13；**M2b 档 0.4109-0.4142**）；
- **共享面直连（零 pack / 零 quant）**：把 **FFN 半的 global A 面寻址参数化**成
  `kb*2048 + (hb*16 + band)*512 + lane*32`（`hb ∈ {0,1}` = 窗口半），
  与 att 半的 `PKT + kb*2048 + row*32` **逐位同式**；scale 单列同形（`AS2 + row*4` vs `O_SC + t*4`）；
- **几何锁死**：**T=32、LW=64、SLM 31,104 B（2 resident WG）、网格 1020 WG**（与现档 `nblk = M/T = 1020` 一致）；**禁 LW=32**、**一律 KN=0**；
- **不许改数值**：累加顺序、`fdiv_rn`、e4m3 snap、`eh_round/ef_div`、FMA contraction 全部 VERBATIM。

### ② B2 的判据（写死，缺一不算成）
1. **13 + 4 项检查点逐字节 = 0**（4 项接口 = 面布局字节序 / scale 粒度 / e4m3 编码 / epilogue 出口形态）；
2. **LIVENESS 反证**（中间面 ×0.5 ⇒ 出口必须变）+ **`--cross` 两组进程 IDENTICAL**；
3. **新合成核必须过自重复门：`stress_repeat` ≥1000 连发 bad=0**（军规 46/48；**注意 200 连发只做快筛**——本案 port 核 1×200 bad=0、2×1000 各 bad=4，真基率 ≈0.5%）；
4. **单价**：≥10 个独立进程、**进程间 ≥60 s**（P18/军规 45：背靠背把 TOPS 压低 2.5 倍）、min-of-15×5、nosink、台账逐列（**key 含 simd+module_id**，`private/spill/scratch=0`、scratch 指令=0）；
5. **基线用实测**：`tools/rt_per_closure.csv` 的 **chain 48 = 1.525 ms/链**、**8 条 C64 链均值 1.658**（**不许再用 1a 之前的 2.080**）；
6. **目标 ≤0.844 ms/链**（bench 内 −42%）⇒ **8 链 −5.6 ms 串行 ⇒ 帧 −2.4**（**诚实净值，别报回 −4.5/−5.1**）。

### ③ B2 之前必须留的空 / 已知坑
- **`WKey` 四元组**：新支路的权重缓存键必须另立字段，**复用 split 键会静默吃到非块对角的预铺 B**（门可能照样绿、到 1301 才爆）；实施后**先跑 1301 再看门**，并在 trace 里打印四元组；
- **`att5L` 的 fATT 面故意不 scrub / 不比**（核不重写整块 att 面；第一版误算造成 **bad=199/200 假警**）；
- **`ffn2` 臂只在 `C2_STAGE=1 或 3` 执行**（`C2_STAGE=2` 释放 1a taps ⇒ 探针静默不跑）；
- **接图（阶段 C）需要记录/计划层换序 + 稳定面**（§56b：96 个 residual 站点里相邻同形腿对 = 0；R9 已证"重写本身在改图"）⇒ **B2 只在 bench 层，接图前另立铲**；
- **构建一律走 `tools/build_shipped.ps1` + `tools/shipped_build.defs`**（HEAD 不带 `/D` ⇒ 1301 会落在旧代 `249A46F3`，逐位门假红）。

### ④ 下次开工第一步（照抄）
```
# 0) 现场核对 + 凉 GPU >=5 分钟（本轮 GPU 已用 ~55 分钟）
cd E:\DSH\dlss-nr-on-a770 ; git status --porcelain        # 期望 0 行
Get-Process | ? { $_.ProcessName -like 'LOP-Win64-Shipping*' }   # 期望 0（用户在玩就等）
# 1) 先复现两颗牙（~2 分钟，确保仪器还在响）
cmd /c "E:\DSH\oneapi\stress_repeat.exe >> E:\DSH\s6\SR_ctrl.log 2>&1"     # 期望 bad=0/200
cmd /c "set PORT_STRESS=1000&& E:\DSH\oneapi\port_ffn_fused.exe >> E:\DSH\s6\SR_port.log 2>&1"   # 期望 bad>0
# 2) 再写 port_e_chain.cpp（按 ①），gate 全绿后才谈单价
```

### ⑤ 新仪器坑 P19（本次实测）：**python 在 GBK 控制台打印 CJK/箭头会 `UnicodeEncodeError` 崩**
⇒ **脚本里若要打印非 ASCII，先 `sys.stdout.reconfigure(encoding="utf-8")`**，或只打印 ASCII 摘要（**16c 的延伸：不只是 .ps1，任何机器读的 stdout 都优先 ASCII**）。
