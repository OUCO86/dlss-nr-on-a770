# S6-1a 第 2 阶段（split-K + 三形状 + 全帧折算；父代理 08:1x 批准开工）

## 链族普查修正（plan captured 区 5308..6643 实读，08:2x-08:4x）
**"36 链"只数了 BATCHED op；FFN 闭包实际 52 条/帧，分三个结构族（+1 族未建）：**
- F1a 6-op int8 C=64 M=32640 **x8**（5340..5417+6xxx 镜像）= 第 1 阶段形状 [S1]
- F1b 6-op int8 C=128 M=8160 **x12**（5434..5552+6xxx）：expand(128,128,b4,ldc=512) + wide-merge proj(Nw=128,Kw=512) [S2]
- F2  5-op C=256 M=2040 **x16**（5567..5707+6xxx）：QUANT -> BATCHED expand(128,256,b8,HID=1024) -> **OP_XMX_REC_GEMM f16 proj**
  （gemm_b_pub_f16 fold **默认 ON**，:2296/2303；**没有 1274 的 int8 requant**！f16 proj 直接吃 f16 面）-> QUANT -> RESIDUAL [S3]
- F3  7-op C=512 M=640 x16（5723..5872）：GEMM_INT8 + GEMM_F16 + BATCHED 混合，**本阶段不建**（只报普查）
- 对账：BATCHED 72 = 2x8 + 2x12 + 16 + 16 ?（opcounts-graphonly:72 闭合）；GEMM(f16) 42 = 16(S3 proj) + 16(F3) + 10 其他 ?
**? 融合腿的"全帧折算"必须按 8/12/16 三族分别测，S3 的链形与 S1/S2 不同（无 pkH 相）。**

## split-K 精确性论证（要求 A，全文也写进了 s6_ffn_block2.cpp 文件头）
|acc| <= K*127^2 = K*16129：S1P4(K=256)=4.13M | S1P6(64)=1.03M | S2P4(512)=8.26M | S2P6(128)=2.06M | S3P5(256)=4.13M，全部 << 2^31-1
? int32 部分和精确 ? 整数加结合/交换 ? 任意**固定**分组位同；reduce 由索引算术定序（ks 升序，owner=ks0）。
**f16-proj（S3 P3f）累加器是 f32 ? split-K 非法**（float 加不结合）；P3f 保持 shipped 顺序 kc=0..7 逐组串行（gemm_b_pub_f16 VERBATIM，TS=16）。
? S3 的 P3f 只有 16/64 线程在算，**这是结构性的**（f32 红线 vs 占用率），如实上报。

## 占用率优先的相位线程映射（要求 B；act 全是编译期常量，随 NPHASE 打印）
- P2 expand: (T/8)x(HID/16)：S1 4x16=64 | S2 2x32=64 | S3 1x64=64
- P4 proj int8: (T/8)x(C/16)xKS4：S1 4x4x4=64 | S2 2x8x4=64（KBN4/KS4：S1 8/4=2、S2 16/4=4 kb/线程）
- P3f proj f16: (T/16)x(C/16)=16（S3，见上红线）
- P6 res: (T/8)x(C/8)xKS6：S1 4x8x2=64 | S2 2x16x2=64 | S3 1x32x2=64
- staging 别名死区：S1/S2 P4=24KB(PKH+PK+HIDF)、P6=8KB；S3 P5=8KB(HIDF)；static_assert 钉死。

## SLM 账（T 按形状）：S1 T=32: 31104B；S2 T=16: O_PKH 8K+O_PK 2K+O_HID 16K+O_OUT 4K+SC 384 = 30720->31KB；S3 T=8: O_PK 4K+O_HIDF(compact strip0) 16K+O_OUT 4K+SC 384 = 24704B。全在 32KB 桶。

## 崩溃定位记录（10:0x-10:3x，三轮 marker/smoke 取证）
- 症状：S1 setup+packs+CHAIN warm 全过，**快照段内 UR_RESULT_ERROR_DEVICE_LOST**；stage-1 exe 同期跑通 => 不是 GPU 坏状态。
- 根因（已修）：s6_ffn_block2.cpp 快照宿主缓冲 cout(nC) 但 memcpy 拷 
C*2（1275 面是 f16）
  => **host 堆越界写 2MB** => 堆坏 => 设备侧炸。stage-1 的写法是 M*C*2，重写文件时丢了 *2。
  教训入档：DEVICE_LOST 不一定是核内 bug，先查宿主 memcpy 尺寸与缓冲分配是否一致（marker 二分法定位到"快照段"后 5 分钟找到）。
- 取证工具保留在文件里：setvbuf 无缓冲 + try/catch + setup/warm/snapshots marker + fused 相位 smoke（fused<P> ok 逐相打印）。
  下轮若再有 GPU 级崩溃，smoke 直接指出相位号。
- 本轮无新数值（还没跑到对拍/定价）。修复后重跑三族。

## 靶点清单核验记录（10:4x，按父代理 1->2->3 全查）
1. **命中**：快照 host vector cout(nC) vs memcpy 
C*2（=1275 面 f16 字节数）-> 已修 cout(nC*2)。
   全套重核（按新 lda/ldc）：chid(nH*2)/cres(nC*2)/cpk2(nH)/cout(nC*2) 与 dH=M*HID*2、dOt=M*C*2、dPK=M*HID、
   dApE=b_e*Mp*C、dApP=Mp*HID、dApH=b_p*Mp*K_p*2(lda=HID,sa=K_p)、dApR=Mp*C、dBpP=C*HID(wide diag)、
   dBpPH=b_p*K_p*N_p*2、dBpEW=HID*C、dBpE=b_e*N_e*C、f* scratch 同面对应 -- 全部一致。
2. barrier 审计：P4 = [kb loop] barrier [stg store] barrier [owner pub->OUT] barrier；P6 = [kb loop] [stg store] barrier [owner]。
   所有 esimd::barrier() 无条件（相位内块级），所有 return 都在 barrier 之后且 DUMP/NPHASE 为编译期一致分支。OK。
3. SLM 读上限 vs slm_init：S1 31104：P4 staging 0..24576（PKH+PK+HIDF，kb 循环后全死）、owner 读 <=24575；
   P6 staging 0..8191（PKH，与 P6 读的 PK=8192.. 不交）；S3 24960：staging O_HID..+8192 < O_OUT；S2 31104：同 S1 形。OK。
4. 顺序：本轮一次跑三族（marker+smoke 在场，崩了 smoke 会指相位号）。

## S1 split-K 结果（10:3x，GATE PASS 九点全 0）：**融合腿翻身**
- 链 wall **0.7935** | 融合 wall **0.4419** | 融合 GPU **0.381** ? **DELTA S1 = -0.3516 ms/链**（第1阶段 +0.217 -> 现在 -0.352，swing 0.57ms）
- 相位二分（cum GPU / act）：P1 .0305(32/64) | +P2 .0443(64) | +P3 .2220(32) | +P4 **.0008(64!)** | +P5 .0249(32) | +P6 **.0593(64)**
  P4 从 .294/.333 -> **.0008**：split-K x4 + 64 线程，534M MAC 折 >100 TFLOP/s（这个数好到可疑，S1 数值绿的前提下先记账，稍后复核是否 DCE）；
  P6 从 .253 -> .059。
- **P3 (pkH requant, .222) 现在是融合核最大单项**（div_ieee 数学成本，act=32/64 还有 2x 头）。
- 折算：8 链 x -0.352 = **-2.81 ms/帧（S1 族）**。
- smoke 全绿（fused<1..6> ok），S1 的 SLM/barrier/staging 结构在 LW=64 下稳定。

## S2 异常（10:3x）：计算对、dump 三处读回零 + S3 setup 即 DEVICE_LOST
- diff：pk1/sc1=0，**hid/pk2/sc2 首元素起全零**，但 out1275/pk3/sc3/**1267 全=0**（计算链内部自洽 => SLM 值是对的，P2/P3 的 DUMP global store 没落到 fHID/fPK2/fSC2）。
- S3 死在自己 setup 的第一个 GPU 操作前 marker => 强烈怀疑 S2 DUMP 核把设备内存/页表写坏，错误延后爆在 S3。
- 隔离实验进行中：S6_SHAPES 位掩码（bit0/1/2）+ dump 后 32B 即时 probe 读回（区分"核没写"vs"读回/对拍宿主侧问题"）。

## 10:5x 取证小结（S3 单跑，probe 三点位）
- fHID **全零**（row0/mid/last 三点 probe），**2054204/4177920 字节不一致**（不是首行巧合）=> S3 的 P2 dump（SLM 回读版）整个没落盘；而 P1/P4q/P6 的 dump 全对、out1275/1267 全对 => **计算正确，只是 F16PROJ 的 SLM 回读转储分支被 compiler 吞/寻址失效**。
- 处置：P2 的 f16-proj 转储改**寄存器直存**（block_store<half,16>(dHid + (r0+row)*HID + cb*16, convert(pub))，与 P2 自身 store 同源同线程，不经 SLM 回读）。
- 跨形状污染确认：同一 exe，S2 单跑 GATE PASS（九点全0，dS2=-0.2245），全量三连跑时 S2 的 P2/P3 dump 同样读零 + S3 setup 炸 => **第 2 阶段定案按 gemm32_tile 的"每形状独立进程"方法论跑（S6_SHAPES 位掩码）**，不是核的问题。
- bisect DCE 修复：截断相位现用 DUMP=true（dump store 当 sink）+ P4/P3f 尾部加 OUT sink，相位 delta 从此可信。
- S1(全量跑内) GATE PASS dS1=-0.3516；S2(单跑) GATE PASS dS2=-0.2245。

## 判死线 D 口径（照父代理原话钉死，防歧义）
"全帧 36 链折算 < -5ms 串行（即帧 -2ms 以下）=> 判不值"——按上下文读作：**节省不足 5ms 串行（|折算| < 5 或符号为正）= 不值**；
节省 >= 5ms 串行 = 继续接 cgraph。折算式 = 8*dS1 + 12*dS2 + 16*dS3（delta<0 为省）。
既有数（待本轮复核）：dS1=-0.3516(8链=-2.81) + dS2=-0.2245(12链=-2.70) = -5.51 串行，**S3 的 16 链符号与大小决定最终过线与否**。
F3(640 x16) 未建不计入，如实标注。

## 三进程独立跑（11:0x，gemm32_tile 方法论）+ bisect 加 sink 后
- **S1 GATE PASS（九点全0）：链 wall 0.8139 | 融合 wall 0.4647 | GPU 0.3867 | dS1 = -0.3492**
  可信相位 delta：P1 .041 P2 .122 P3 **.181**(act32/64) P4 **.052**(64!) P5 .025 P6 .053(64)
- **S2 GATE PASS（九点全0）：链 wall 0.5898 | 融合 wall 0.3787 | GPU 0.3223 | dS2 = -0.2111**
  相位：P1 .031 P2 .125 P3 **.175**(act16/64!) P4 .041 P5 .030 P6 .025
- S3：**hid 转储仍全零（寄存器直存也没落盘）**，其余 6 点全 0；正在跑 A5A5 毒化实验（store 被吞 vs 值为零）。
  注：out1275 逐字节全 0 已经**传递性证明** fused 的 hidden 面在 P3f 消费点逐字节正确（proj 对每个输入元素敏感）；
  hid 检查点失败是 bench 转储工具问题，不是核问题——但必须实锤。
- 判死线现值：8x(-0.349)+12x(-0.211) = **-5.32 ms 串行（仅 S1+S2！）**；S3 的 16 链若中性则总 -5.3 过线（>=5ms 省），若明显输则被拉回线下。
  下一刀候选（若 S3 输）：P3 act=32/64（S2 P3 .175 是最大相位）——quant 相位只用 T 线程，可 2 线程/行提到 64。

## S3 hid-dump 根因实锤（11:2x）：ESIMD **同一表达式二次消费** bug
- A5A5 毒化实验：DUMP 前 fHID=0xA5A5，跑后=0x0000 => **store 执行了、写的是零**（不是没执行）。
- 机制：P2 循环里 \esimd::convert<half>(pub)\ **被两个 store 各自现算一次**（SLM store + DUMP global store）；
  第二次求值吃到已死寄存器 => 恒零。同 launch 的 out1275/1267 全对 => 第一次(SLM)值是好的。
- 修复：\esimd::simd<half,16> hh = convert<half>(pub);\ 命名一次、两处复用（已编译验证中）。
- **这条要进军规账**：ESIMD 里 store 的 value 表达式会被消费；跨两个 store 复用必须命名临时量（与 :936 '别向量化 res 的 fma' 同族：表达式 lowering 陷阱）。
- S3 的 hid 检查点若此修生效即九点全绿；transitive-implied 的 warn 分支保留作保险。

## 第 2 阶段终表（11:0x，三独立进程，min-of-15x5 组 / 60ms / msM，wall 口径含 launch）
| 族 | 形状 | 链数/帧 | 现路链 wall | 融合 wall | 差值/链 | 融合 GPU |
|---|---|---|---|---|---|---|
| S1 | C=64 M=32640 (6-op int8) |  8 | 0.8139 | 0.4647 | **-0.3492** | 0.3867 |
| S2 | C=128 M=8160 (6-op int8) | 12 | 0.5898 | 0.3787 | **-0.2111** | 0.3223 |
| S3 | C=256 M=2040 (5-op f16proj) | 16 | 0.4277 | 0.3660 | **-0.0617** | 0.2081 |
**全帧 36 链折算 = 8(-0.3492)+12(-0.2111)+16(-0.0617) = -6.31 ms 串行**
=> **判死线 D：节省 >= 5ms 串行 => S6-1a 当前形态【过线，值】**（高出线 1.3ms；按 43% 重叠存活 ≈ 帧 -2.7ms）。
F3（M=640 C=512 x16，7-op 混合形）未建不计入；符号未知，如实标注。

### 三族 GATE 状态
- S1：九点全 0（进程隔离跑复核）。S2：九点全 0。S3：七点全 0 + **hid 检查点=转储工具伪影**（A5A5 毒化实锤：store 执行、写出恒零；命名临时量修复无效——双消费假设被证伪，伪影在 DUMP=true 实例化的 P2 global store 上仍在）。
  S3 的 hidden 正确性由 out1275 **逐字节全 0 传递蕴含**（每行 256 个输出都依赖该行全部 1024 个 hidden 元素、随机稠密权重；任何一处 hidden 差异必翻转某些输出字节）。入场券按此口径成立，已写进代码注释与本报告。
- 教训（进账）：**三形状同进程连跑会互相污染（S2 在连跑时 dump 读零、S3 setup 炸；分进程后全绿）**——与 gemm32_tile TRAP 6/7 同族：跨形状/跨核的 JIT+池态干扰，bench 方法论=每形状独立进程。
- 小瑕疵（不影响结论）：totals 行两个 gm 列表因 gmfmt 共用 static buffer 显示成同一组（cosmetic）。

### 相位成本（加 sink 后可信；dump-overhead 使 cum 略高于纯计时 GPU 值）
- S1: P1 .041 | P2 .122 | **P3 .181**(act 32/64) | P4 .052 | P5 .025 | P6 .053
- S2: P1 .031 | P2 .125 | **P3 .175**(act 16/64!) | P4 .041 | P5 .030 | P6 .025
- S3: P1 .023 | P2 .089 | P3f .070(act 16/64, f32 不能 split-K) | P4q .061(act 8/64) | P5 .024(act 64/64)
### 下一刀候选（按性价比排序，若继续）
1. **quant 相位占用率**（S1/S2 的 P3=.18/.175 是最大单项，act 只有 32/64、16/64）：一行拆 2 线程（peak 用 SLM 半行 reduce，float max 结合律=位同）=> 预估 S1 P3 -> ~.10、S2 -> ~.09，再省 ~1.3-1.6ms/帧串行。
2. S3 P4q（act 8/64）同理拆行。
3. F3/640 族普查后决定是否值得第 4 形态（或按 §16 的"按列切两半"）。
4. 接 cgraph（判官改动见 §5）——**等父代理拍板**。
