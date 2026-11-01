# S6-1b PORT 阶段 B 工作日志（追加式）

任务：写出忠实移植 `native_wave_ffn_fused.hlsl` 的 bench 原型，并让它**逐字节对拍通过**。
产物：`src/bench/sycl/port_ffn_fused.cpp`。不单价、不 S3、不接线、不上 shipped、不 commit。

---

## B0 已读（11-01 14:3x）
- `E:\DSH\s6\port.md`（77 行，A 阶段定案几何）
- `notes/s6-port-spec.md` §2（R1-R8）/ §3（T/D）
- 蓝本 `E:\DSH\backup\pre-port-2026-11-01\lmxx_src_ref\native_wave_ffn_fused.hlsl`（101 行，全读）
- 现路只 grep/读需要的行：`s6_ffn_block2.cpp`（P1..P6 + control leg + 判据）、
  `gemm_s8_v8_kernel.hpp`（dpas 操作数槽约定 :678、pub_vec_v8 :441-446、e4m3_vec_v8 :393-408）、
  `pack_device.hpp`（pack_a/pack_b 的 fragment 索引映射 :18-19, :215-216）、
  `quantize_row_kernel.hpp`（qr_kernel_rowthread :266-285 = pk 面行主序 int8）

## B0.1 三条从源码里挖出来、决定移植写法的事实
1. **dpas 操作数槽约定**：`dpas<8,8,int32>(acc, X, Y)` 里 **X = 权重(N 行 × 32K，pack_b 的 4 字节交织)**、
   **Y = token(M 行 × 32K，pack_a 的行连续 32B)**，累加器 flat = **M-major（行=token，列=权重 N）**
   （证据：gemm_s8_v8_kernel.hpp:678 "fragment c0q row r = cols wi_col*16 + q*8.." +
   s6_ffn_block2.cpp:172-177 的 epilogue 组装）。⇒ 一个 16×16 tile = 4 个 dpas（c00/c01/c10/c11）。
2. **他们 512B B 块 ≠ 我们 pack_b 的分块顺序**：他们 `((col/16)*(K/32)+g)*512`（cb 外层），
   我们 `pack_b` 是 `(kk32*(N/8)+ntile)*256`（kb 外层）。内容相同、**顺序不同** ⇒ R2 = setup 期一次纯置换
   （`retile_b`，零算术 ⇒ 按构造 bit-exact）。
3. **他们的 hidden LDS 是 e4m3 字节（16×4C B）** ⇒ 移植里 SLM 暂存也用 **e4m3 字节**（1B/元素），
   这样 T1 的 int8+scale 原位 requant 才能塞进 32KB 占用崖（f16 暂存会翻倍到 ~60KB）。
   e4m3 ⊂ f16 ⇒ 现路 P2 发布的 f16 hidden 与 e4m3 字节**逐位同值**（port.md 0.1-1 的推论），
   所以 `hid-f16` 检查点可以过 diff=0。

## B1 几何/SLM 账（照抄 port.md D1 定案）
W = C/16（忠实）；G = 16/W；LW = W*G = 16 work-items/WG。每组 16 token（R7）。
每 WG 的 SLM（per-group span PG × G）：
- S1 C=64 HID=256：PG=7296B（HIDF 4096 + OUT 2048 + PKO 1024 + SC 128）× G=4 = **29184B**
- S2 C=128 HID=512：PG=14464B × G=2 = **28928B**
（两者都 < 32768 占用崖；`static_assert` 已钉死）
grid：ngrp/G 个 WG（S1 510、S2 255），cull 写成 **WG-uniform**（`(wg*G*16 >= M)`），
因为 D1 把 G 个组塞进一个 WG ⇒ 按组 cull 会让部分 work-item 越过同伴在等的 barrier = 正案 HANG。

## B2 五相结构（他们的两相 + T1/我们链路带来的三刀）
1. PHASE1 expand：kb(C/32) × 4 tile/wave，dpas×4，寄存器内 `pub_vec_v8(3u, acc*scA*bsExp)`
   → **e4m3 字节直落 SLM**（R4；他们 :75 的对应物）。零 pack（R1/R2）。
2. barrier（R5）
3. PHASE2 **T1a requant**：e4m3 字节 → 行峰（整行 HID，跨 wave）→ `div_ieee(rnde+clamp±127)` →
   **int8+scale 原位落同一 fragment 偏移**（他们核里没有这一趟：e4m3 逐元素、无 scale）
4. barrier
5. PHASE3 contract：SLM int8 当 A 载入（R4），Wproj 按他们 512B 块（R2），
   epilogue `pub_vec_v8(1u, acc*scH*bsProj)` → f16 落 SLM + 落 global 1275（他们 :98）
6. barrier → PHASE4 outquant（行峰→scO + pkO int8 fragment，= 现路 P5q）
7. barrier → PHASE5 residual（= 现路 P6，非他们 101 行内的东西，为了 1267 检查点带在同一发里）
⇒ barrier 数：他们 1 个，我们 4 个（全 CTA，无条件绕过）。

## B3 编译（compile-only，不跑）
- 脚本：`bash E:/DSH/s6/cc_bench.sh port_ffn_fused.cpp _portchk.exe //DD_CRT_SECURE_NO_WARNINGS`
  （新写的 `E:/DSH/s6/cc_bench.sh` = bench.sh 的 env/flag，只链接不 stage 不 run；
  `//Fe:` 必须传**相对名**，MSYS 会把 `//Fe:E:/...` 打碎 —— 与 bench.sh 的"cd 传相对名"同一个坑）
- 第 1 铲报错（`port_B_compile1.log`/`compile2.log`）：
  `using S = port::Geo<C,HID>` 用了运行期形参 ⇒ `run_shape` 改模板 `<int C_,int HID_>`；
  `sycl::fence_option` 本工具链**没有**（`group_barrier(gr, fence_option::CTA)` 编不过）⇒ 用 `group_barrier(gr)`
  （与 A 阶段探针/shipped 核同一写法）——**记为工具链偏离**；
  `select<8,1>` 不能在 `const simd&` 上调、`bit_cast_view`/`convert` 不能直接挂在表达式模板上 ⇒ 具名中间量；
  内层 lambda 传 `const simd&` 的同款问题 ⇒ 改具名非 const 引用 + 把 `rss[r]` 提成 `float rs`（现路写法）。
- **COMPILE OK**（`port_B_compile3.log`，11-01 15:1x，_portchk.exe）。
- 待跑：`bash E:/DSH/bench.sh port_ffn_fused.cpp port_ffn_fused.exe`（先 PORT_SHAPES=1 = S1）。

## B4 S1 首跑 + 三处 bug（日志 portB_S1.log / portB_S1f.log / portB_S1g.log）
首跑（S1 C=64 M=32640，WG=510、LW=16、SLM=29184B）**不挂、跑通**，GPU 0.59-0.66ms。
检查点定位（phase dump 直接指出是哪一相）：
1. `pk1-face`/`sc1` **= 0** ⇒ R1 输入面（按 dpas-A fragment 序预铺）与现路 pk 面逐字节同 ✅
2. **bug#1 ESIMD 布尔掩码不是全 1**：`simd<int32_t,N> mk(isnorm)` 得到 **0/1**，我用 `&/~` 混合
   normal/subnormal 两条 e4m3 编码路径 ⇒ 只有 bit0 被保留 ⇒ 字节写成 `msub & ~1`（例：-0.4375
   应 0xAE，实得 0xE8）。⇒ 全 1 掩码必须 **用减法造**（`0 - mk1` / `mk1 - 1`）。
   （window_block_v3.hpp:43-44 早就写着 "mask converts to 0/1"，我没读。）
3. **bug#2 dpas 累加器 fragment 行索引**：`c10/c11` 是 **8 行** 的 fragment，我却把"瓦片行号"
   (r+8=8..15) 当 select 偏移用 ⇒ `select<8,1>((r+8)*8)` 越界到 64..120 ⇒ 每组 16 行里的后 8 行全错。
   正解 = 分开两个量：**fragment 内行 fr=0..7（select 偏移 fr*8）** 与 **瓦片行 r=0..15（地址）**，
   这正是 gemm_s8_v8_kernel.hpp:108-116 绿尾的写法。
4. **顺手钉**：16-wide simd 的动态下标（`rss[r+8]`）现路从不使用 ⇒ 全改成两个 8-wide 载入
   （`rssA/rssB`、`rosA/rosB`），与 shipped P2/P6 的 `simd<float,8> rss` 同形。
5. **bug#3（只伤 dump 探针，不伤数据）**：fragment 序转储 tap 的**组跨度**写成 `grp*HID`，
   应为 `grp*(16*HID)`（一组 = 16 行 × HID 字节）⇒ 组间互相踩 ⇒ 三个 `*-frag` 检查点报错，
   而 SLM 真数据（dec/pk2/out/pk3/1267）全 diff=0。
修完 1-3 后的 S1（portB_S1g.log）：**hid-f16 / e4m3-dec / pk2-slm / sc2 / out-1275 / pk3 / sc3 /
1267-FINAL 全部 = 0**；只剩三个 `*-frag` tap（bug#3）。

## B5 交工判据达成（官方命令跑通，两形状 **全部检查点 diff=0**）
命令：`cd E:/DSH/dlss-nr-on-a770/src/bench/sycl && bash E:/DSH/bench.sh port_ffn_fused.cpp port_ffn_fused.exe`
日志：`E:\DSH\s6\portB_final.log`（EXIT=0）；结果表：`E:\DSH\s6\port_B_diffs.csv`（26 行，diff 列全 0）。
定位用日志（同一 exec 的三次迭代）：`portB_S1.log`(首跑) / `portB_S1f.log`(加 codec 探针) /
`portB_S1g.log`(修 bug1-2) / `portB_S1h.log`(修 bug3，S1 GATE PASS) / `portB_S2.log`(S2 GATE PASS)。
编译日志：`port_B_compile1..5.log`（compile-only 用我新写的 `E:/DSH/s6/cc_bench.sh`，不 stage 不 run）。

| 检查点 | S1 (C=64,M=32640,HID=256) | S2 (C=128,M=8160,HID=512) |
|---|---|---|
| pk1-face / sc1（R1 输入面 + 生产者 scale） | 0 / 0 | 0 / 0 |
| e4m3-enc（SLM 暂存字节，按存储序） | 0 | 0 |
| e4m3-dec（暂存解码回 f32→f16） | 0 | 0 |
| hid-f16（PHASE1 发布值 tap vs 现路 hidden 面） | 0 (16.7MB) | 0 (8.4MB) |
| pk2-slm / pk2-frag / sc2（R4 hidden int8+scale） | 0 / 0 / 0 | 0 / 0 / 0 |
| out-1275（PHASE3 契约输出面） | 0 (4.2MB) | 0 (2.1MB) |
| pk3 / pk3-frag / sc3（T1 出峰量化） | 0 / 0 / 0 | 0 / 0 / 0 |
| **1267-FINAL（全链末端面）** | **0** (4,177,920 B) | **0** (2,088,960 B) |
| 一次 GPU 时间（DUMP=false 实例，3 组×15 次，**非判据**） | msM 0.677 | msM 0.407 |

参考对照（S6-1a 已验数）：现路 0.8139 / 0.5898，1a 融合链 0.4647 / 0.3787 ⇒ 移植核在 D1 几何下
**已快过现路、但慢于 1a 融合链**（原因见 B7 的占用账）。B 阶段不评单价，此数只作 C 的起点。

## B6 R1-R7 逐条供上（`port_ffn_fused.cpp` 行号）
- **R1 零 pack**：核内 A 操作数 = 面直读，**无任何 pack 趟**：:247 注释、:261-263 `block_load<int8_t,256>`
  两半（512B = 16 token × 32K）；面的 fragment 序在 **setup** 生成：:501 `retile_a`（纯索引置换）+ :685 调用。
  证据：`pk1-face` diff=0（把面按 fragment 序 un-frag 回行主序，与现路 pk 面逐字节同）。
- **R2 权重预铺**：:253-255（expand 的 512B 块两半）、:369-371（contract 用他们 :85 的
  `((col/16)*(HID/32)+g)*512`）；setup 期一次铺好：:511 `retile_b` + :686-687 调用。
  运行期**零 pack_b**；证据：out-1275 / 1267 diff=0。
- **R3 hidden 只在 SLM**：SLM 区 `O_HIDF`（:175，16×HID 字节，e4m3→int8 同一块原位复用），
  核内**没有任何 global hidden 面**；只有 `DUMP=true` 实例里的 bench 探针（:202 起，`dHid/dfrag1/ddec`），
  交工的 `DUMP=false` 实例（时间那行用的就是它）里一行都不存在。
- **R4 量化即落位**：:271 起"寄存器内 encode"，:288-291 `pub_vec_v8(3u,...)` → `e4m3_enc<16>` →
  `slm_block_store`；:337-352 `div_ieee(rnde+clamp±127)` 后 **int8 原位落同一 fragment 偏移**；
  契约相 :366-368 把 SLM int8 当 A 载入、:378-388 **scale 在 epilogue 乘**。
  证据：`pk2-slm`/`pk2-frag`/`sc2`/`out-1275` 全 0 ⇒ R4 与现路 P3+P4 逐字节等价（P3 requant 相确实消失）。
- **R5 两相之间一次 CTA barrier、绝不条件绕过**：:309 / :357 / :401 / :440 四个 `group_barrier(gr)`，
  中间只有**编译期** `NPHASE` 截断（work-group 一致）；cull 写成 WG-uniform（:234）。
- **R6 K 步进 = 32**：:261（expand `KB_C=C/32`）、:365（contract `KB_H=HID/32`）、:449（residual），
  全部 `dpas<8,8,int32_t>`（K=32 原生）。
- **R7 16 token 组 + 线性 token 序 + `gid.x*16>=总数` cull**：:220-226（`grp`、`r0=grp*16`）、
  :234（cull，见 D1 的 WG-uniform 写法）。

## B7 偏离清单（全部列名，无静默改）
**T 类**
1. **T1** OPERAND `F8_E4M3FN` → **int8 + 每行 scale**（他们 e4m3 逐元素、无 scale）。
   - **T1a**（新增的一趟，他们核里没有）：int8 网格需要**整行 HID 的行峰**，而每个 wave 只见自己
     64 列 ⇒ 在 SLM 里把 e4m3 字节 **原位** requant 成 int8+scale（:308-355）。峰值在 f16/e4m3 舍入
     **之后**取（与现路 P3 同）；`e4m3-enc`/`e4m3-dec` 两个探针证明暂存往返逐位无损。
   - **T1b** 契约 epilogue 用现路的 `pub_vec_v8(1u, acc*scH*bsProj)`（= e4m3-only），
     **不搬**他们的 `Ffast(H(acc))` 双舍入（H=软件 f16 RNE）。这是"数值链必须与已出货链一致"的要求。
   - **T1c** SLM 暂存选 **e4m3 字节**（他们 LDS 本来就是 e4m3）：f16 暂存会把 hidden 区翻倍
     （S1 每 WG 60KB）撞穿 32KB 占用崖。
2. **T3** `dx::linalg` wave MMA → **`dpas<8,8,int32_t>`**：一个 16×16 tile = 4 个 dpas
   （:253-255 / :369-372 / :450-453），操作数槽 = 权重在前、token 在后（gemm_s8_v8_kernel.hpp:678 的
   shipped 约定）；累加器 flat 行索引只有 0..7 ⇒ 见 B8-坑2。
3. **工具链偏离（新发现，必须记）**：本 oneAPI **没有 `sycl::fence_option`**，
   `group_barrier(gr, sycl::fence_option::CTA)`（spec R5 的字面写法）**编不过** ⇒ 用 `group_barrier(gr)`
   （= A 探针与全部 shipped SLM 共享核的写法）。证据：`port_B_compile2.log`。

**D 类**
4. **D1** 几何：W=C/16（忠实）；**G=16/W ⇒ LW=16 work-items/WG**（S1 G=4、S2 G=2），
   照抄 port.md A 阶段定案，未重新设计。SLM：S1 29184B、S2 28928B（`static_assert` 钉 <32KB）。
   连带的写法偏离：cull 必须按 **WG 跨度**（:234）而不是按组，否则部分 work-item 越过同伴在等的
   barrier = 正案 HANG。
5. **D2** 占用账（照实说）：LW=16 ⇒ S1 只有 510 WG × 16 = **8160 个 ESIMD 线程**
   （S2 4080），远低于 A 阶段扫出的 130560-线程甜区 ⇒ **这是移植核目前慢于 1a 融合链的主因**，
   不是算法工作量。C 阶段的第一把刀就在这（见 B9）。
6. **D3** 未做（按任务边界）：S3/C=256 档、五个依赖 shuffle 的核、split-K（本移植**不用** split-K：
   顺序升序 kb 与现路升序 ks 求和在 int32 精确区间内恒等，累加语义未改）。

## B8 三个坑（军规候补，都是本工具链 ESIMD 的硬事实）
1. **`simd<bool,N>` 转 int32 是 0/1，不是全 1 掩码** ⇒ 用 `&`/`~` 做 blend 会静默只留 bit0。
   全 1 掩码必须减法造（`0-mk1` / `mk1-1`）。现证：`window_block_v3.hpp:43-44` 早写了
   "mask converts to 0/1"，我第一次没读，代价 = e4m3 字节全花（-0.4375 → 0xE8）。
2. **dpas 累加器 fragment 只有 8 行**：`select<8,1>(row*8)` 的 row 必须是 **fragment 内行 0..7**，
   不是瓦片行 0..15；把瓦片行号喂进去 = 越界 64..120 ⇒ 每组后 8 行静默全错（首现：hid-f16 从 row8 起崩）。
3. **`esimd::convert`/`bit_cast_view` 不能挂在表达式模板结果上**，且 16-wide simd 的**动态下标**
   （`v[r+8]`）shipped 链从不使用 ⇒ 一律具名中间量 + 拆成两个 8-wide 载入（rssA/rssB、rosA/rosB）。
   （另：`//Fe:`/`//Fo:` 传绝对盘符路径会被 MSYS 打碎 ⇒ 同 bench.sh 的"cd 传相对名"。）

## B9 要不要进 C（单价）——建议：**进，但先修占用再谈单价**
- 入场券已拿：**两形状、13 个检查点、逐字节 diff=0**，且 R1-R7 全部供上 ⇒ 移植核**语义正确**，
  进 C 不会踩"数值形态未过 golden"的死刑线（T1 换网格不破坏与现路逐位同，port.md 0.1-1 已论证、
  本次 `pk2/out1275/1267` 全 0 实证）。
- 但**别按现在这个几何去报单价**：D1 的 LW=16 只喂了甜区 1/16 的线程。C 阶段第一铲应是
  **同一核、同一 diff 判据下**扫 G/LW（G=4/8/16 ⇒ LW=16/32/64；SLM 帽决定上限：S1 每多一组 +7.3KB，
  32KB 崖 ⇒ G≤4；要 G=8/16 就得砍 SLM —— 现成的两把刀：(a) 去掉 SLM 的 out 副本、直接从 global 1275
  读回做行峰；(b) hidden 暂存与 pkO 复用同一块）；并给 32-token 组（G 减半、每 wave 2 tile）留一档。
- 预期对照：1a 融合链 S1 0.4647 / S2 0.3787，目标 ≤0.30/0.25 ⇒ 消 pack(R1/R2)+消 P3(R4) 的功已经
  在数值上兑现（现路 0.8139 → 移植 0.677 是**低占用下**拿到的），占用一修就有机会进目标带。
- 风险预告（C 里必须一起测）：`esimd::barrier()` 在现路 fused 核里被当 CTA barrier 用（实际只同步
  lane，见 bench_bar.cpp 的结论）——移植核用的是真 `group_barrier`，**这才是正确写法**，但两者
  对比单价时要把这个差别写清，别让"移植核更慢"背错锅。

## B10 现场纪律
只写 `E:\DSH\`（产物 = `src/bench/sycl/port_ffn_fused.cpp`、`E:\DSH\s6\port_B*.md/log/csv`、
`E:\DSH\s6\cc_bench.sh`、`E:\DSH\s6\run_port.ps1`、stage 件 `E:\DSH\oneapi\port_ffn_fused.exe`）；
未动 shipped 源、未动 `E:\DSH\out\libxmx.dll`（跑后复核 MD5 仍 = **E2D5E574**0035BE47321D55A1C7385C8D）；
未 commit/push；跑前查过 LOP/bench 进程（无），跑后无残留进程（`_portchk.exe` 已删）。
