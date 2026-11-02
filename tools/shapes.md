## 胖形状普查铲 — 进度追加（本铲，纯 CPU，件/金标未动）

### 步骤 0 环境确认
- 仓 = E:\DSH\dlss-nr-on-a770，`git branch --show-current` = **ds-quality-relax-2026-11-02**，tip = **0ec8593** ✓（与任务书一致）
- 只读输入 = E:\WorkBuddy\...\work\plan_960x544.c（未写 WB 树）

### 步骤 1a 解析器（s6/shape_parse.py）
- 图区 = plan 行 **5308..6643**（军规 13，只数捕获图区）；步表 nr_plan_steps[] 起于行 1392
- **踩坑并修**：行号算术错位（i+1+k）导致先数到 steps 2523..3858 = 672 个 REC op（假账）。
  修正后：**OP_XMX_REC_* = 691 ✓**（另 1 个 OP_XMX_BUF_ZERO 不属于 691，单列）
- 家族计数 vs 任务书交叉核对表（全部命中）：
  batched 72 / residual 68 / qkv 60 / window_attention 52 / window_int8_residual 52 /
  quant 224（+quant_window 52 另列）/ gemm f16 42 / gemm_int8 24 / window_block 10 /
  global_attention 8 / ffn 8+merge 1+stem 1=10 / unary 16+unary2 1=17
  ⇒ 合计 691 = passes=691 ✓（§12 假账教训已避）
- 参数语义取自 E:\DSH\census\knifeB_census.py 的 OPS 表（引用 libxmx_sycl.cpp decl 行），未重新推导

### 步骤 1b 落盘 tools/shapes_census.csv（691 行，每闭包一行）
- 脚本 s6/shape_census.py；列 = closure, plan_line, chain, tier, family, dtype, M,N,K,batch, lda/ldb/ldc, sa/sb/sc,
  scale_stride, flags, epi, narrow, kb_n, legs, gflop, bytes, fam_calls, fam_ms_cs2(§19), fam_ms_1a(E2D5E574 四遍中位), price_1a_per_call
- **FLOPs 模型不是猜的**：逐族照抄 shipped 自己的 flop_note 账本（libxmx_sycl.cpp:202-207 + 站点 :2348 :2349 :2857 :2977 :3043 :3426 :3733 :3838 :3890 :4567 :4910）
- **dtype 判据 = 参数表里有没有 a_scale/b_scale**：有 ⇒ int8 直通面（gemm_int8/batched/residual/wres/qkv）；
  无 ⇒ f16 面（gemm/ffn/ffn_stem/ffn_merge/window_block/window_attention/global_attention）
  ⇒ 修正：window_block 四腿是 **f16**（§37 的 81-150% 就是拿 f16 屋顶比的；§37 肉 4 才是"四腿 f16→int8"）
- **闭合校验**：整帧腿和 = **266.0 GF**（任务书口径 236 GF，差 +12.7%）；差值来源已定位：
  (a) ffn_merge 两腿是本铲按 :1978/:1992 出口形推的（shipped 未给 flop_note）= +8.56 GF；
  (b) window_block head 形多算的 +32,768 MAC/窗（§37）未计 = -0.5 GF；
  ⇒ 236 的口径应在"ffn_merge 只有一腿"处对齐，**引用 236 时必须说明它不含 merge 的第二腿**
- 家族价两份账都进表：CS2(§19, 154ms) vs 1a(E2D5E574, ~143ms)；**1a 把 batched 从 18.5 砍到 7.7**（P2/P4 折叠），
  而 residual 反而 18.0→23.8、qkv 14.8→15.5 ⇒ **家族价不能跨件混用**（本铲一律用 1a 那份）

### 步骤 2 落盘 tools/shapes_roofgap.csv（398 个 gemm/attention 闭包）
- 屋顶只认两张实测表：tools/xmx_f16_roof.csv（M=130560，raw 腿）+ s6/wbint8_roof_ext.csv（M=130560/522240，raw+pub 腿）
- **结果就是本铲最硬的一条事实：398 发里只有 3 发四腿全部有实测屋顶**（WB 的 pass1/pass3/pass682）；
  其余 386 发 = **no-roof**（军规 26/35a：不许内插）⇒ **屋顶表覆盖 <1% 的发数、覆盖 7.4/143 ms 的串行价**
- 已屋顶的 3 发可回收 = **3.4 ms 串行**（pass1 2.66 + pass3/682 各 0.37）⇒ 与 §37"矩阵腿 92% 贴顶"咬合（WB 只有 21% 肉，且被 SLM/elementwise 吃掉）
- 待测屋顶清单（按 GF 降序，见 csv 尾部打印）：int8 2040x128x256b8 / 2560x768x256 / 192x4096x1024 / 192x1024x4096 /
  8160x128x128b4 / 960x1536x512 / 640x512x512 / 768x1536x512 / 192x3072x1024 / 32640x128x64b2 / 9216x384x128 / 2560x256x256 ...
  ⇒ **肉集中在两类小 M 深 K 形状**（M=192..2560、K=256..1024、N=768..4096），**屋顶表一格都没有**
### 步骤 2.5（加令）实测屋顶探针
- 新探针 s6/shape_roof_probe.cpp（untracked，**不改任何 shipped 源**）；编译 s6/cc_shaperoof.ps1
  ⇒ E:\DSH\oneapi\shape_roof_probe.exe（657,920B，exit=0，只有 getenv deprecation 警告）
- 引擎直接用仓内两份核头：16v1::gemm_b / 16v1::gemm_b_pub_f16 / s8v8::gemm_b(_pub) / s8v8::gemm32_b(_pub)
  （N%64==0 走 BN64，N%32 走 BN32 —— 与 §47 同判据）
- 协议：**每形状点一个独立进程 × 6 进程取中位**（军规 35b）、进程内 **min-of-15×5、5 组、组间 60ms、nosink**（军规 19）、
  **f16 与 int8 都测**（军规 35a）、raw 与 pub 两腿都测、**M 成轴**（军规 37）
- **52 个形状点 = 成对设计（军规 1）**：小 M 原形 / **batch 进 grid** / **fat-N 多输出列（sa=0 ⇒ A 广播）** /
  **block-diagonal wide（sa=K, lda=K·batch）** / **fat-M 上界参照**
- **仪器自校验（G46 锚 130560×128×32）**：f16 gemm_b **2.798 TOPS**（落在屋顶表 N96K32=2.745 与 N192K32=3.165 之间 ✓）、
  int8 gemm_b **4.820 TOPS**（屋顶表 int8 N128K32 = 5.05，差 4.6% ✓）、int8 pub 2.944（raw→pub 附加率 1.64x，§47 的 BN64 1.27x 在 K=32 浅 K 处更贵）
- 扫批日志 = E:\DSH\s6\SHAPE_ROOF_sweep.log（后台 job pwsh-1db760fdadf24128）；JIT 缓存独立目录 E:\DSH\sycl-cache-roof
  ⇒ 跑完用 spillcheck 出每核台账（grf/simd/slm/private/spill/scratch，**key 含 simd**，军规 29），临时 exe **跑完删除**

### 顺带挖出的一条**已在出货里的合并机制**（比探针更值钱）
- libxmx_sycl.cpp:3089-3126 = **P8-b block-diagonal WIDE-MERGE，默认 ON，逃生门 NR_B_WIDE=0**：
  把 xmx_rec_gemm_int8_batched 的 **N=32 且 batch≥2** 的站点并成 **一发 wide gemm（M, Nw=N·batch, Kw=K·batch）**，
  B 预铺成**块对角**（gather_pack_b_diag_b，按 WKey 缓存），A 用 gather_pack_a_b_v 直读宽行 ⇒ **逐字节 diff 0**、
  **2 launch → 1**，实测 **0.511→0.138 / 0.280→0.103 ms/发（3.7x / 2.7x）**。
- **守卫只放行 N==32**（wide_ok :3101）。普查表里 batched 家族 72 发的真实分布是：
  | 形状 | 发数 | lda/sa 形态 | 现在的处置 |
  |---|---|---|---|
  | 32640×32×128 b2 | 8 | lda=256=K·b, sa=128=K ⇒ **块对角** | **已并 wide（Nw=64,Kw=256）** |
  | 8160×32×128 b4 | 12 | 同上 | **已并 wide（Nw=128,Kw=512）** |
  | 32640×128×64 b2 | 8 | lda=64=K, **sa=0 ⇒ A 广播** | **未并**（可 fat-N：Nw=256,Kw=64） |
  | 8160×128×128 b4 | 12 | lda=128=K, sa=0 | **未并**（fat-N：Nw=512,Kw=128） |
  | 2040×128×256 b8 | 16 | lda=256=K, sa=0 | **未并**（fat-N：Nw=1024,Kw=256） |
  | 640×64×256 b8 | 16 | lda=2048=K·b, sa=256=K ⇒ 块对角 | **未并**（wide：Nw=512,Kw=2048） |
  ⇒ **52/72 发 batched 还没上这条已证明逐位合法的合并路**；f16 家族里同样有 32 发块对角形态
  （2040×32×128 b8 lda=1024/sa=128、640×256×64 b8 lda=512/sa=64）**没走 wide-merge**。
  ⇒ **这就是"他们 71 块只需 35 核"的机制在我们仓内的现成版本**，也是施工图第一刀（放宽 wide_ok 的 N==32 守卫）。

### 步骤 2.5 落盘 tools/xmx_roof.csv（**实测屋顶 244 个形状点**）
- 扫批 = 52 形状组 × **6 独立进程** = 312 进程、1464 条 CSVROW；日志 s6/SHAPE_ROOF_sweep.log
- 台账（s6/SHAPE_ROOF_ledger.csv，key 含 simd，军规 29）：16v1::gemm_b / gemm_b_pub_f16 / s8v8::gemm_b(slm 18432) / gemm32_b(15360) / gemm_b_pub / gemm32_b_pub(10240)
  ⇒ **grf=128、simd=1、private=spill=scratch=0、scratch 指令=0** ⇒ 计价腿干净（§34/§35/§36/§47 同标准）
- **合并倍率实测（原形→合并形，raw TOPS）**：192×1024×4096 b1→b8 = **8.04→32.33（4.02x）**；2560×768×256 b1→b8 = 11.70→29.73（**2.54x**）；
  640×512×512 b1→b8 = 10.23→20.41（2.0x）；2560×256×256 b1→b8 = 1.58x；2040×256×256 = 1.76x；9216×384×128 b1→b4 = 1.95x；
  **8160×32×128 b4(gemm32_b 3.88) → wide 8160×128×512(23.82) = 6.14x**（= 已出货 P8-b 的实测倍率）；
  640×64×256 b8 → wide-diag 640×512×2048 = 6.67→15.37（2.30x）；f16 2040×32×128 b8 → 2040×256×1024 = 3.28→8.70（2.65x）
  ⇒ **但 batched 家族的"fat-N（A 广播 sa=0）"三条几乎无肉**：2040×128×256b8→1024 = 1.07x、8160×128×128b4→512 = 1.01x、32640×128×64b2→256 = 1.01x
  ⇒ **合并的收益全在"把不同块的独立发并进 grid 维"和"块对角 wide 把 K/N 同时抬"，不在"给单个 batched 发换胖 N"**（这条会改刀序）
- **新规律（军规候补 41）**：pub 腿代价随 K 变深而塌缩 —— 浅 K：pub/raw = 41-59%（640×512×512: 4.22/10.23）；
  深 K 大 M：81-85%（5120×512×512: 17.59/20.79）⇒ **折叠与胖形状必须同时做，单做一件只兑现一半**
- 仪器自校验：锚 130560×128×32 f16 = **2.85**（旧表 N96=2.745 / N192=3.165 之间）、int8 = **5.00**（旧表 5.05，差 1%）

### 步骤 4 交付（施工图）
- E:\DSH\notes\shape-merge-plan.md（340 行 / 46KB，11 节）：§0 屋顶覆盖率醒目标注 / §1 普查与 266 GF 更正 / §2 实测屋顶 + 合并倍率表 /
  §3 iolation_ms 前 20 / **§4 表一（port-E 七项完整性对照，② 几何 = G1 原样 / G2 只动并行度）** / **§5 表二（A 级 13+4 检查点、B 级两档×六相、健康闸六条、验收线）** /
  §6 port-E spec（选 C=64 档 S1 链：11 发 → 3 发、新建 N1-N4 面、逐腿预测 ≈0.61-0.81 vs 现值 2.08）/ §7 逐腿合并施工图（备胎：候选清单 + 前 3 刀 + 691→380→115-160 路线图 + TOPS 账）/
  §8 待测屋顶清单 / §9 不再接受的手段 / §10 账本更正与军规候补 40-41 / §11 未做与风险

### 收尾核对（纪律）
- 临时件已删：E:\DSH\oneapi\shape_roof_probe.exe（Test-Path = False），**0 残留进程**
- 保护件 md5 复核未变：out\libxmx.dll = ABB969FE4AAF0F94AA03C3F53781EDD0；
  dumps\bk.1301.bin = DD49827D…、k.1301.skip.bin = DD49827D…、k.1301.pre-skip-1a.bin = 249A46F3…
- 分支 tip 已由父代理推进到 ee5bbc6（§49 入库），**本铲自身未 commit/push**；git status --porcelain = 0
- 只写了 E:\DSH\（tools/ s6/ notes/ tmp/ oneapi/(已清) sycl-cache-roof/)；WB 树全程只读
