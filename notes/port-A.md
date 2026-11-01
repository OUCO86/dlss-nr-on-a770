# S6-1b 完整机制移植试验 — 工作日志（追加式）

任务：A 几何存活探针 → B 忠实移植 `native_wave_ffn_fused.hlsl` → C 三形状对拍+单价。
**不接线、不上 shipped、不 commit/push。** 产物只进 `E:\DSH\s6\` 与
`E:\DSH\dlss-nr-on-a770\src\bench\sycl\port_*`。`E:\DSH\out\libxmx.dll`(E2D5E574) 不许覆盖。

---

## 0. 规格/蓝本已读（11-01 13:0x）

- 规格 `E:\DSH\s6\port_spec.md`（= notes/s6-port-spec.md，同一内容）：R1-R8 / T1-T3 / D1-D3 / 判据 §4。
- 蓝本 `E:\DSH\backup\pre-port-2026-11-01\lmxx_src_ref\native_wave_ffn_fused.hlsl`（101 行）已逐行读。
- 现路蓝本 = `src/bench/sycl/s6_ffn_block2.cpp`（bench 层，750 行，P1..P6 已读）
  + `src/bench/sycl/s6_ffn_block_kernel.hpp`（**shipped 版同名 ffn2::fused**，S1=Shape<32,64,256,false,4,2>、
  S2=Shape<16,128,512,false,4,2>、S3=Shape<8,256,1024,**true**,1,2>）。

### 0.1 三条决定移植写法的关键事实（已核对源码）

1. **`s8v8::pub_vec_v8(3u, x)` = `gate_vec_v8` → `e4m3_vec_v8`**（gemm_s8_v8_kernel.hpp:441-446）
   ⇒ 现路 P2 发布的 hidden 已经在 **e4m3 网格**上（= 他们 `Activate()=Ffast(poly)` 的对应物），
   而 e4m3 ⊂ f16 ⇒ `convert<half>(pub)` **无损** ⇒ 现路 P3 在 f16 面上取的行峰/除法与在寄存器 pub 上取的
   **逐位相同** ⇒ **R4（累加器寄存器内 encode 直落 int8+scale）可以过 diff=0**。
   ⇒ 用户更正成立：**T1 换网格不破坏"与现路逐字节 diff=0"判据**（现路本来就是 int8+scale 网格 + e4m3 发布），
   不需要额外 golden 考古。（port_spec §4.1 的那句保守写法按此更正。）
2. **ESIMD 与 DX 的线程对应**：本工具链里 **1 个 ESIMD work-item = 1 个 HW 线程 = 他们 1 个 wave**
   （`simd<T,N>` 铺在该线程的 32 lanes 上；现路 fused 核 `nd_range(...,range(64))` 的 64 = 64 个这样的 SIMD 线程，
   notes §39 "~128 live ESIMD threads"、"LW=64（4×SIMD16）" 同此口径）。
   ⇒ 他们 `numthreads(32*WAVES)` 的 **512 DX 线程 ⇔ 我们 16 个 ESIMD work-item（16 waves）**，
   不是 512 work-item。A 阶段仍按用户口径把 LW∈{64,128,256,512} 全扫一遍（拿硬数据），
   但 **B 阶段的几何按 "wave 数=C/16" 忠实照搬**，偏离只发生在"每 WG 打包几个 token 组"（SLM/占用决定）。
3. **S3 的现路不是 int8 contract**：shipped S3 = f16-proj（`gemm_b_pub_f16`，f32 累加，hidden **不 requant**）。
   他们的核 contract 用 **操作数量化（我们=int8+scale）** ⇒ 移植核在 S3 上与 shipped S3 **数值路径不同**，
   逐字节 diff=0 只能对 **现路的 int8-proj 家族在 C=256 的同一形状**（`ffn2::Shape<8,256,1024,false,4,2>`，
   现路 bench 里可实例化）来对。C 阶段会**两条都报**：
   - 判据（diff=0）：port vs 现路 int8-proj@C256；
   - 单价对照：port vs 现路 fused（f16-proj，0.3660）**和** vs 现路 int8-proj@C256。

---

## A 阶段（D1 几何存活探针）

文件：`src/bench/sycl/port_geo_probe.cpp`；驱动：`E:\DSH\s6\port_geo_run.ps1`（每配置一个进程、
进程内 3 次、每次 20s 看门狗 + 进程级 100s 硬超时 + 每次之后 canary 探 GPU 是否被卡死）。
网格：LW∈{64,128,256,512} × MODE∈{0 SLM-only,1 +CTA group_barrier,2 +dpas<8,8,32>,3 both} × SLM∈{8,16,32,48,64}KB，
总线程预算固定 130560（= 2040×64 安全区同量级），iters=200。

（状态：编译中 → 结果见下）

## A 阶段结果（D1 几何存活探针）—— 数据落盘 `port_geo.csv` / `port_geo2.csv` / `port_geo3.csv`

协议：每配置**独立进程**、进程内 3 次、每次 20s 看门狗（HANG 即 `_exit(3)`）、
每次之后跑 **canary**（1 task + dpas）确认 GPU 没被卡死；总线程预算固定 130560（=2040x64 安全区量级）、iters=200。

| LW (SYCL local size) | SLM 8/16/32/48/64KB x {0 SLM-only, 1 +CTA barrier, 2 +dpas, 3 both} | 结论 |
|---|---|---|
| 64  | 全 20 格 | **ALIVE**（gpu 1.7-3.2ms / 200 iters / 2040 WG） |
| 128 | 全 20 格 | **ALIVE**（gpu 2.1-3.7ms / 200 iters / 1020 WG） |
| 256 | mode 0/1 @ 8,16,32KB + mode 2/3 @16,32KB | **HANG**（首轮还见过 FAIL 0xC0000409 = failfast/DEVICE_LOST） |
| 512 | 见 port_geo3.csv | HANG（重负载）；light/iters=0 见下 |

**读数与旧账更正**：
1. `LW>=128 + barrier = 死锁区` 这条旧账**错**：**128 线程 + CTA barrier + dpas + 64KB SLM 全活**；
   墙在 **256**（与本工具链 §39 "~128 live ESIMD threads" 一致 —— 那是 **GRF/线程数** 的墙，不是 barrier 的墙）。
2. `max_work_group_size=1024` 的上报值对 ESIMD **不成立**（256 就死）。
3. barrier 与 dpas 单独都不致命：LW=128 下 mode1(barrier)=2.95ms vs mode3(barrier+dpas)=3.74ms vs mode2(dpas only) —— 增量是算力，不是挂死。
4. **他们的 wave 数（C/16 = 4/8/16 个 ESIMD work-item/组）远在安全区内** ⇒ B 阶段几何**照搬他们的 wave 数**，
   不需要为"线程数"偏离；偏离只发生在 **每 WG 装几个 16-token 组**（SLM 帽 64KB、占用崖 32KB 决定）与 **grid 的组序映射**。

**D1 定案（B 阶段用的几何）**：
- 1 ESIMD work-item = 1 个他们的 wave（32 lanes，跑 16x16 tile，SIMD16）；
- W = C/16（4/8/16，忠实）；每组 16 token（忠实 R7）；
- G = 每 WG 的 token 组数 = **16/W**（⇒ LW = W*G = **16 work-items/WG**，SLM ~25KB < 32KB 占用崖）：
  C=64 G=4 / C=128 G=2 / C=256 G=1。
- 为什么 LW=16 而不是把 LW 拉到 64/128：SLM。hidden int8 fragment map = 16 token x HID = **4C x 16 = 16KB** 每 WG 固定
  （C=64:4KB x G … 见 B 的 SLM 账），LW=64 ⇒ G=16 ⇒ hidden 64KB + out 32KB = 96KB **超 64KB 帽**。
  这是 **D 类偏离 #1**（下面 B 节逐条列）。

