# ★ 性能靶（唯一标准，用户钉死）= **lmxx 3080L 路线 A：71 层完整模型 / 每帧 35 核**

**不是** 31-block Small（720p 5.62 / 900p 8.38 / 1080p 11.07 ms = 后来降画质模型）；**不是** 9070XT hip-port 的 10.4 ms（fp8 + 3.7× 带宽卡，只作实现手法参考）。

**来源（只读）**：`E:\WorkBuddy\a770-speedopt\refs\lmxxf_dlss5-on-amd-9070xt-porting\...\Development\DevHistory.md` → `#### 4.4 1x Original 1080p (1920×1152) 完整 35 核属性与耗时普查表（Total = 111.300 ms）`
（同一份也在 `E:\WorkBuddy\2026-10-09-04-20-55\refs\lmxxf-src\Development\DevHistory.md`）

## 归一到我们的分辨率
- 他的表 = **1920×1152 = 2.21 Mpx，Total 111.300 ms**；我们 NR = **960×544 = 0.522 Mpx** ⇒ **像素因子 4.23**
- **等像素参考 ≈ 26.3 ms**（`lmxx-architecture-comparison.md` 记 **~25.8 ms**）；**带宽归一（448→560 GB/s）≈ 20.6 ms = A770 int8 世代物理参考值**
- **我们现役 = 42.15 ms（fused，含 ViT 周期复用；不开复用 46.26）** ⇒ **仍慢 1.6-2.0×**；**前辈 coopmat 47.19 = 1.8× 慢**
- **⇒ 第一战役目标 = 20 ms**（破前辈、贴归一值）；**10-12 ms = 同等融合深度在 A770 上的地板**

## 逐核普查（原表；最右列 = 我按像素因子 4.23 折算的 **@544p 等效 ms**，用来跟我们的族腿对表）
```
Kernel Name                                      Calls Total(ms)  Avg(us)  Grid  Block Regs LMem  SMem   OccW   @544p等效
sp_run256_w16（C256 块 persistent 版）              2    15.208   7604.2    893    256  255   576  49152    8      3.60
c128_wave2_bi_bo                                  10    13.612   1361.2    540    128  248     0  24576    8      3.22
c64_wave2_bi_bo                                    5     8.818   1763.7   2160     64  248     0  12288    8      2.08
c32_wave1_prefix_b8d_w16                           1     8.702   8702.0  34560     32  178     0  10240    9      2.06
c32_wave1_post_b8_w16                              1     7.589   7588.9  34945     32  177     0  10240    9      1.80
c32_wave1_chain_w16                                4     7.290   1822.4   8833     32  162     0  10240    9      1.72
c512_qkv_attention_compact_w16                    16     4.602    287.6    640     64  229     0   6144    8      1.09
vit_stream_qkv_frag_bin_w5f8                       8     4.315    539.4    768    160  135     0  16384   15      1.02
vit_stream_contract_frag_bstream_bout_compactw     8     4.091    511.4    640     32  162     0   4096   12      0.97
split_ffn_one_w2f8_w16_bin                        16     3.593    224.6    544     64  149     0      0   12      0.85
c256_wave2_bi_bo_w16                               3     3.462   1154.0    135    256  240     0  49152    8      0.82
vit_expand_blocked_fp8_frag_bytein_w16             8     3.187    398.3   2560     32  119     0      0   16      0.75
c64_wave2_bi                                       1     2.162   2161.7   2220     64  248     0  12288    8      0.51
mh_attention_project_frag_c512_w16_u4_bout        15     2.157    143.8   1080     32  133     0      0   15      0.51
vit_attention_fused_640_bytein_bout                8     2.071    258.8   1280     32  122     0      0   16      0.49
c32_wave1_up_b8_w16                                1     2.052   2052.1   8640     32  234     0  10240    8      0.49
c32_wave1_finish_dcrop_b8d_w16                     1     2.029   2028.5   8760     32  168     0  10240    9      0.48
c64_wave2_up_lb_sh                                 1     1.990   1989.6   2160     64  247     0  12288    8      0.47
c32_wave1_mapped_b8_w16                            1     1.969   1969.2   8640     32  170     0  10240    9      0.47
c64_wave2_bi_ho                                    1     1.882   1882.1   2220     64  247     0  12288    8      0.44
c32_wave1_finish_b8_w16                            1     1.817   1816.6   8760     32  168     0  10240    9      0.43
split_projection_frag_w16_bskip                   16     1.597     99.8   1080     32  135     0   1024   15      0.38
c128_wave2_up_lb_sh                                1     1.533   1532.9    558    128  247     0  24576    8      0.36
c256_wave2_bi_w16                                  1     1.507   1507.3    150    256  240     0  49152    8      0.36
vit_stream_project_n64_bb_bout_compactw_w16        8     1.502    187.7    640     32  218     0      0    9      0.36
c128_wave2_bi_ho                                   1     1.501   1501.2    589    128  247     0  24576    8      0.35
decoder_project2x_h16w_byteout_w_bin_f8w16         2     0.369    184.3   1280     32   71     0   2176   16      0.09
（余下 mh_pool_project_* / mh_attention_project 单发各 0.08-0.15 ms；vit_gather_b8 2 发 0.024 ms）
```
**合计 = 111.300 ms @1080p ⇒ @544p 等效 ≈ 26.3 ms**

## 这张表告诉我们三件事（今后逐层照它比）
1. **形态**：**每块一个 megakernel**（`c64/c128/c256_wave2_bi_bo` = 一个 wave 拥有该块全部 64 token，块内五阶段 **FFN contract → feature-scale → QKV → attention → out-proj + diag residual** 全在 **LDS 两块 64×C 字节 plane 交替**里完成，**no global intermediate**）；`sp_run256_w16` = C256 的 **persistent 版**（grid 893 跑完所有 window，只 2 发）；c32 全分辨率块 = prefix/post/chain 三核；
2. **资源形态（S6 战役的第一道闸门）**：他 `Regs 240-255`（Ampere 上限 255）、`SMem 12-49 KB`、`OccW 8-16`、只有 persistent 核带 `LMem 576` ⇒ **我们这边要装下"一块一核"，必须核对 DG2 的每线程 128 GRF 与 65,536 B/每 WG SLM 上限**；
3. **钱在哪**：最贵的是 **解码器全分辨率大块链**（`sp_run256` 3.60 + `c128_wave2` 3.22 + `c64_wave2` 2.08 + `c32_wave1_*` ≈ 7.5 ⇒ @544p 共 ~16.4 ms），**ViT 流式核合计 @544p ≈ 3.6-4.0 ms**；**我们 ViT 段串行 13.94 ms ⇒ 比他的 ViT 贵 4×** ⇒ **大刀 = 块驻留（1267 的 W122×R278 → 每块 1 写 1 读 = 26.7 GB → 4.8 GB，屋顶 47.7 → 8.6 ms），不是任何单核刀（每把 0.3-1.5 ms）**。

**B6-1 死因最终版（已钉）**：它只把 5 个 split op 串成一核但 **plane 照写** ⇒ 消的全是 L2 已吸收的小面（1277/1272/1270），**1267 大面原样进出 DRAM**；**wave2 形态是"块的输入输出才过 DRAM，中间量根本不存在 global buffer"**。
