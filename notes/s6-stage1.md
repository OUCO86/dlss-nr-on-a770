# S6-1a ç¬¬ 1 é˜¶æ®µï¼ˆbench å±‚ 6 å‘ vs 1 å‘ + é€å­—èŠ‚å¯¹æ‹ï¼‰

## å·²é’‰äº‹å®ï¼ˆ07:0x-07:3xï¼Œæºç å®šä½ï¼Œæœªæ•´è¯»å¤§æ–‡ä»¶ï¼‰

### é“¾å‚æ•°ï¼ˆplan_960x544.c 5337-5349ï¼Œåªè¯»ä¸å†™ WorkBuddyï¼‰
- op1 QUANT {1270â†’1272,1273; M=32640 K=64}
- op2 BATCHED {1272,W83â†’1274; M=32640 N=128 K=64 b=2, sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 ss=0 flags=0x1300â†’epi=3,narrow}
- op3 QUANT {1274â†’1272,1273; K=256}ï¼ˆ1274 è¡Œ = ä¸¤ç»„ 128 åˆ—**äº¤ç»‡æˆ 256 å®½è¡Œ**ï¼Œå³°å€¼è·¨å…¨è¡Œï¼‰
- op4 BATCHED {1272,W85â†’1275; N=32 K=128 b=2, sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 flags=0x1100â†’epi=1} â†’ **wide_ok å…¨æ¡ä»¶æˆç«‹**ï¼ˆ:2479-2503ï¼‰â‡’ å®å‘ = wide-mergeï¼ˆNw=64,Kw=256,b1ï¼‰
- op5 QUANT {1275â†’1272,1273; K=64}
- op6 RESIDUAL {1272,W77â†’1267; sc1273/W78, skip=1270(half), cos=73, N=64 K=64 flags=0x41100â†’epi=1,narrow,half_skip}

### ç°è·¯å®é™…å‘å°„åºåˆ—ï¼ˆlibxmx_sycl.cpp è°ƒç”¨ç‚¹æŠ„ä¸‹ï¼ŒMp=32768=l0_ceil_bmï¼‰
**å…³é”®å‘ç°ï¼šbatched çš„ quant èåˆé»˜è®¤ OFFï¼ˆqfuse_b=NR_Q_FUSE_B opt-in, :384ï¼‰ï¼Œresidual çš„èåˆé»˜è®¤ ONï¼ˆqfuse_take, qfuse_on() é»˜è®¤ true, :304/3092ï¼‰** â‡’ ç°è·¯ 6 ä¸ª op å®é™…å‘ **8 å‘**ï¼š
1. qr_launch_esimdâ†’qr_kernel_rowthread<64>ï¼ˆ1270â†’pk1272/sc1273ï¼‰
2. packdev::gather_pack_a_b_v(pk1272â†’dAp2, K=64, lda=64, sa=0, b=2)
3. s8v8::gemm_b_pub_slm<false>(dAp2, dBp83, 1274, as,bs, M,Mp,128,64,2, sc=128,ldc=256,ss=0, col_stride=128, narrow, epi3)ï¼ˆpubslm é»˜è®¤ true :2666ï¼‰
4. qr_launch_esimdâ†’rowthread<256>ï¼ˆ1274â†’pk1272/sc1273ï¼‰
5. packdev::gather_pack_a_b_v(pk1272â†’dAp4, K=256, lda=256, sa=0, b=1)ï¼ˆwide å½¢æ€ï¼‰
6. s8v8::gemm_b_pub(dAp4, dBp85diag, 1275, as,bs, M,Mp,64,256,1, sc=0,ldc=64,ss=0,cs=0, narrow, epi1)
7. packdev::pack_a_fused(1275â†’dAp2, sc1273, K=64)ï¼ˆ**op5 çš„ quant å·²æº¶è¿›è¿™é‡Œ**ï¼ŒB3-2 é»˜è®¤èµ° pack_a_fused_sr_k<64> :131-137ï¼‰
8. s8v8::gemm_b_res(dAp2, dBp77, 1267, as,bs, skip=1270, cos=73, M,Mp,64,64, narrow, half_skip, epi1)
æƒé‡ packï¼ˆdBp83/85/77ï¼‰= è®°å½•æ—¶ç¼“å­˜ä¸€æ¬¡ï¼ˆg_wcacheï¼‰ï¼Œå¸§ replay ä¸é‡å‘ â‡’ bench é‡Œ setup ä¸€æ¬¡ã€ä¸å…¥è®¡æ—¶åŒºã€‚

### æ•°å€¼é“¾ï¼ˆå¿…é¡» VERBATIMï¼‰
- quantï¼špeak=è¡Œ f16â†’float |max|ï¼›scale=(peak==0)?1:div_ieee(peak,127)ï¼›q=clip(Â±127, rnde(div_ieee(v,scale)))ï¼›int8ã€‚rowthread å…¨è¡Œè¿› GRFã€hmaxã€æ—  barrierï¼ˆquantize_row_kernel.hpp:266-285ï¼‰ã€‚
- pubï¼šgemm å°¾ = convert<float>(acc) * rs * cs â†’ **pub_vec_v8<16>(epi,...)**ï¼ˆepi3=gate+e4m3, epi1=e4m3ï¼‰â†’ convert<half> å­˜é¢ï¼ˆgemm_s8_v8_kernel.hpp:441-446,510-533ï¼‰ã€‚
- residual å°¾ï¼š**é€å…ƒç´ æ ‡é‡å¼** `t[e] = sk[e]*cos[e] + f[e]`ï¼ˆç¼–è¯‘å™¨è‡ªåŠ¨ç¼©æˆ FMA=å•æ¬¡èˆå…¥ï¼Œ**ä¸è®¸å†™æˆ simd muladd**â€”â€”:936 çš„"frame 0%"æ•™è®­ï¼‰ï¼Œå† pub_vec_v8(1)ï¼ˆ:941-950ï¼‰ã€‚
- è¡Œå³°å€¼å¿…é¡»åœ¨ **f16 èˆå…¥ä¹‹å**å–ï¼šä¸­é—´é¢åœ¨å—å†…ä»¥ f16 å­˜ SLMï¼Œpeak ä» f16 è¯»å›è½¬ floatï¼ˆä¸ç°è·¯è¯»é¢é€ä½åŒï¼‰ã€‚e4m3/gate å°¾å€¼ f16 å¾€è¿”æ— æŸï¼Œä½†ç…§è§„åˆ™æ˜¾å¼åšã€‚

### SLM è´¦ï¼ˆçˆ¶ä»£ç† 07:33 ä¿®æ­£ç‰ˆï¼Œå–ä»£ Â§16 çš„ 48KB ç²—ä¼°ï¼‰
**T=32 token/WG**ï¼šå³°å€¼ â‰ˆ hidden 16KB + pkH 8KB + pkA/O 2KBÃ—2 + out 4KB + sc 0.4KB â‰ˆ **30.4KBï¼ˆ32KB æ¡¶å†…ï¼‰**ï¼›B èµ° globalâ†’GRF ç›´è¯»ï¼ˆæƒé‡ L2-hotï¼Œstage-1 ä¸åš SLM åŒç¼“å†²ï¼Œè‹¥æ…¢åˆ™è®°ä¸ºä¸‹ä¸€å½¢çŠ¶ï¼‰ã€‚LW=64ï¼ˆÂ§96 å®‰å…¨åŒºï¼‰ï¼Œgrid = M/32 = 1020 WG â‡’ **å®½ M åœ¨ grid ç»´ä¸Šä¸ç ´å†›è§„ 1**ã€‚

### å¯¹æ‹ç‚¹ï¼ˆå…¥åœºåˆ¸ï¼‰
cpk1/csc1(op1å)ã€chid(1274é¢)ã€cpk2/csc2(op3å)ã€cout(1275é¢)ã€cpk3/csc3(op5 ç‹¬ç«‹è·‘ä¸€æ¬¡å–ä¸­é—´æ€â€”â€”ç°è·¯é“¾é‡Œå®ƒå·²æº¶è¿› pack_a_fused)ã€**1267 é¢é€å­—èŠ‚ diff=0**ã€‚èåˆè…¿ DUMP æ¨¡æ¿æŠŠ SLM å…­å¤„å†™è¿› scratchï¼ˆè®¡æ—¶è·‘ DUMP=falseï¼‰ã€‚

### è®¡æ—¶åè®®ï¼ˆç…§ gemm32_tile.cpp:366-408 TRAP 1-9ï¼‰
1 å‘ä¸è®¡æ—¶ï¼ˆmodule uploadï¼‰â†’ 5 ç»„ Ã— 15 å‘ã€ç»„é—´ 60ms ç©ºé—²ï¼›msm=ç»„minæœ€å¥½å€¼ã€**msM=ç»„minä¸­ä½æ•°ï¼ˆä¸»åˆ¤ï¼‰**ã€msX=ç»„minæœ€å·®ã€med=75 å‘ä¸­ä½æ•°ã€‚çŸ­çˆ†å‘è¿› boostã€é•¿é¢„çƒ­å throttle â‡’ ä¸åŠ å¼ºé¢„çƒ­ã€‚å¯¹ç…§è…¿è®¡æ—¶ = 8 å‘é“¾æ•´ä½“ï¼›èåˆè…¿ = 1 å‘ã€‚å¦åŠ æ¯ op å•ä»·åˆ†è§£ï¼ˆåˆ¤"å“ªä¸€æ­¥æœ€è´µ"ç”¨ï¼‰ã€‚

## ÈÚºÏºËÉè¼Æ¶¤ËÀ£¨07:5x£¬s6_ffn_block.cpp ÒÑÂäÅÌ£©
- ÃüÃû¿Õ¼ä ffnblk£¬T=32/C=64/HID=256/LW=64£¬grid=M/32=1020 WG£¬Áù½×¶Î´® SLM£º
  P1 quant1270(=rowthread<64> VERBATIM)->pkA SLM+scA | P2 expand dpas(32x256,K=64,epi3)->hid f16 SLM
  | P3 hid ĞĞ·å(**´Ó SLM f16 ¶Á»Ø=f16 ÉáÈëºó**)->pkH SLM+scH | P4 proj dpas(32x64,K=256,epi1)->out f16 SLM
  | P5 out ĞĞ·å->pkO SLM(¸´ÓÃ pkA Çø)+scO | P6 outproj dpas(32x64,K=64)+²Ğ²îÎ²(ÖğÔªËØ±êÁ¿ sk*cos+stage£¬
  pub_vec_v8(1))->Ğ´ 1267¡£B Èı¿é global->GRF Ö±¶Á£¨pack_b/gather_pack_b_diag_b ÏÖ³É map£¬kb ²½³¤ Np*32 ¹æÔò£©¡£
- SLM ±í£ºpkH 8K@0 + pk 2K@8192 + hid 16K@10240 + out 4K@26624 + sc 384B@30720 = 31104B -> 32KB Í°¡£
- ¿éÄÚ A µÄ SLM pack map = s8v8 dpas map ÏŞ 2 ¸ö 16-row band£º(kb*2+wi)*512 + r16*32£¨8-row Ïß³ÌÈ¡°ë´ø 256B£©¡£
- expand µÄ B ÓÃ**¿í N=256 µ¥ pack**£¨W83 Á½×éÑØ N Æ´½Ó + W84 256 floats ±¾À´¾ÍÆ´½Ó£©£»dpas Öğ kb Ë³ĞòÓë
  gemm_b_pub_slm(batch=2) ÍêÈ«Í¬ ? Î»Í¬¡£proj ÓÃÏÖ³É dBp85£¨wide-merge Í¬ buffer£©£»res ÓÃÏÖ³É dBp77¡£
- ¶ÔÅÄ = 9 ¼ì²éµã£ºpk1/sc1¡¢1274 Ãæ¡¢pk2/sc2¡¢1275 Ãæ¡¢pk3/sc3¡¢1267 ÖÕÃæ£¨ÖĞ¼ä pk Áù´¦ÔÚ DUMP=true
  ÊµÀı»¯²ÅÂä global£»¼ÆÊ±ÊµÀı DUMP=false£¬pk/sc Ö»ÔÚ SLM£©¡£
- ¼ÆÊ±£ºÃ¿ op host-wall£¨º¬ launch£¬Á´Ì¬£©+ Á´ÕûÌå wall + ÈÚºÏ wall + ÈÚºÏºË GPU-only event¡£
  Èë³¡È¯ = ¾ÅµãÈ« 0 ²ÅÅÜ¼Û¡£
- ÏÖÂ·Á´µÄ¿Ó£¨ÒÑ¶¤£©£ºop5 µÄ quant ÔÚÏÖÂ·**²»ÊÇ¶ÀÁ¢·¢**¡ª¡ªqfuse_take Ä¬ÈÏ ON£¬ËüÈÜ½ø op6 µÄ pack_a_fused
  £¨:3092/3101£©£¬ËùÒÔÏÖÂ· 6 op = 8 ·¢£»op4 ×ß wide-merge£¨:2484-2503£©£¬²»ÊÇ gemm32_b+publish ·ÖÁÑÂ·¡£

## ±ß½çºÏ¹æ£¨µÚ 1 ½×¶Î£©
- Ö»ĞÂÔö E:\DSH\dlss-nr-on-a770\src\bench\sycl\s6_ffn_block.cpp£¨bench ²ã£©£»libxmx_sycl.cpp / ÈÎºÎÍ·ÎÄ¼ş / recorder / 39 ÃÅ **Áã¸Ä¶¯**£»ÎŞ commit/push£»²»Åö libxmx.dll£»WorkBuddy Ö»¶Á£¨plan_960x544.c 5330-5365£©¡£
- ±àÒë = E:/DSH/compile_check.sh Ò»´Î¹ı£¨icx_exit=0£¬½ö getenv ÆúÓÃ¸æ¾¯£©¡£
- GPU£ºÅÜÇ°È·ÈÏÎŞ bench_*/nr_replay ½ø³Ì£»Ö»ÅÜ±¾ bench¡£

## ¶ÔÅÄµÚ 1 ÂÖ£¨08:0x£©£ºÇ° 5 ¼ì²éµãÈ« 0£¬¿¨ÔÚ P4
pk1/sc1 = 0¡¢**hid1274 = 0**£¨16.7MB Öğ×Ö½Ú£¡expand dpas+epi3+wide-B È«¶Ô£©¡¢pk2/sc2 = 0 ? **out1275 ÆğÆ«**£º
¸ùÒò = phase 4 ĞĞ±êÁ¿ rss Îó¶Á scA£¨SLM_SC+0£©£¬Ó¦Îª **scH£¨SLM_SC+128£©**£¨ÏÖÂ· op4 µÄ as=op3 µÄ scale£©¡£Ò»ĞĞĞŞ¸´£¬ÖØÅÜ¡£

## µÚ 1 ÂÖµ¥¼Û£¨08:0x£¬GATE PASS ºó²â£¬min-of-15x5 ×é / 60ms ×é¼ä£©
¾Å¼ì²éµãÈ« diff=0£¨pk1/sc1, hid1274, pk2/sc2, out1275, pk3/sc3, 1267 ÖÕÃæ£©= **Èë³¡È¯µ½ÊÖ**¡£
- Ã¿ op host-wall£¨º¬ launch£¬Á´Ì¬£©£ºop1 quant .0920 | op2 packA .1081 | op2 gemm_pubslm **.3198** |
  op3 quantK256 **.1971** | op4 packAwide .1092 | op4 gemm_wide **.2305** | op5+6 pack_fused .0909 | op6 gemm_res .2165£»µ¥·¢ºÍ=1.3641
- **Á´ÕûÌå wall = 0.7984**£¨8 ·¢Á¬·¢»¥ÏàÑÚ¸Ç launch/ÒÀÀµ ? Á´¼Û < µ¥·¢ºÍ£»Õâ²ÅÊÇ 6 ·¢¶ÔÕÕµÄÕæ¼Û£©
- ÈÚºÏµ¥·¢£ºwall 1.0148 / GPU-only **0.8918** ? **Êä 0.2164 ms/Á´£¨GPU ¿Ú¾¶Ò²Êä ~0.09£©**
- ÕÛËã£º8 Á´/Ö¡ ? +1.73 ms/Ö¡£¨ÏÖĞÎ×´£©¡£**Ã»µ½"µ¥·¢<=Á´ºÍ"£¬°´¾ü¹æ 7 ²»ÅĞËÀ£¬ÕıÔÚ²éÄÚ²¿ÄÄ¶Î×î¹ó£¨NPHASE ÏàÎ»¶ş·Ö£¬µÚ 2 ÂÖÅÜ£©**

## Êä¼ÛµÄºòÑ¡¸ùÒò£¨´ı NPHASE ¶ş·ÖÖ¤Êµ£¬±ğÌáÇ°¶¨×ï£©
1. P4/P6 Ö»ÓĞ 16/64 Ïß³ÌÔÚËã£¨32x64 Êä³ö @ 8x16 Ïß³Ìtile£©= 75% »úÆ÷ÏĞÖÃ ? split-K£¨int32 ²¿·ÖºÍÏà¼Ó**¾«È·=Î»Í¬**£¬
   K=256 ÇĞ 4 ·İ¡¢K=64 ÇĞ 2 ·İ£¬SLM reduce£©ÊÇµÚÒ»»»ĞÎ¡£
2. B Ö±¶Á global ÎŞÔ¤È¡£¨s8d2 Èı»º³åÔÚÏÖÂ·ºËÀï¶¼ÓĞ£©£»dpas Ñ­»·Ã¿ kb Í£µÈ L2¡£
3. SLM 31KB -> 32KB Í° => Ã¿ºË 2 WG ×¤Áô£»Á´ÉÏÏÖÂ·ºËÒ²ÊÇ 32KB(NT32) µ«Ğ¡ºË¼äÓĞ kernel ÖØµş£¬ÈÚºÏºËÄÚÏàÎ»´®ĞĞÎŞÖØµş¡£
4. ¶ÔÕÕÁ´ wall(0.798) << µ¥·¢ºÍ(1.364)£ºÁ¬·¢ÑÚ¸ÇÁË launch/ÒÀÀµ ¡ª¡ª ÈÚºÏÍÈÒªÓ®µÄÊÇ 0.798 Õâ¸öÊı£¬²»ÊÇ 1.364¡£

## µÚ 2 ÂÖ = ÅĞ¶¨£¨08:1x£¬GATE ÈÔ¾ÅµãÈ« 0£»Á½ÂÖÊı×ÖÒ»ÖÂ£¬msM ¿Ú¾¶£©
**ÈÚºÏµ¥·¢ GPU 0.887 / wall 1.014  vs  Á´ wall 0.797£¨µ¥·¢ºÍ 1.354£©? ±¾ĞÎ×´ÅĞ¸º ~0.09-0.22 ms/Á´¡£**
### ÈÚºÏºËÄÚ²¿ÏàÎ»¶ş·Ö£¨cum GPU msM£©
P1 quant-in .0318 | +P2 expand .0433 | +P3 pkH quant .2236 | +P4 proj gemm .2938 | +P5 pkO quant .0420 | +P6 res+write .2528
### ¶ÔÕÕÁ´Ã¿ op wall£ºop1 .092 | op2pack .088 | op2gemm .311 | op3quant .198 | op4pack .119 | op4gemm .235 | op5+6pack .101 | op6gemm .211
### ¶Á·¨£¨ÕâÊÇ±¾½×¶Î×îÓĞ¼ÛÖµµÄÈıÌõÊÂÊµ£©
1. **¿éÄÚ gemm µÄËãÊõĞ§ÂÊÄëÑ¹ÏÖÂ·**£ºP2 expand = 1.07 GFLOP/Á´ ÔÚ .0433ms = **24.7 TFLOP/s**£¬Í¬Ò» FLOPs ÏÖÂ· gemm_b_pub_slm+pack Òª .399 wall£¨7.7x Âı£©¡£SLM ×¤ÁôµÄ dpas ±¾Ìå²»ÊÇÎÊÌâ¡£
2. **ÈÚºÏÍÈµÄ¹ó = P4/P6 µÄ¼¸ºÎÀË·Ñ**£º32x64 Êä³öÓÃ 8x16 Ïß³Ì tile ? **Ö»ÓĞ 16/64 Ïß³ÌÔÚËã**£¨75% »úÆ÷ÏĞÖÃ£©+ K ÇĞ 8 ¸ö kb ÎŞÔ¤È¡Ö±¶Á global¡£P4=.294¡¢P6=.253£¬Á½¶ÎÕ¼ÈÚºÏºË 62%¡£
3. **P3 requant£¨.224£©ÓëÏÖÂ· op3 quant£¨.198£©Í¬¼Û**£ºdiv_ieee Á´ÊÇÊıÑ§³É±¾£¬²»ÊÇÍù·µ³É±¾¡ª¡ªÕâ¿é±¾À´¾ÍÊ¡²»µô£¬·ûºÏÔ¤ÆÚ¡£
### ÅĞ¶¨ÓëÏÂÒ»ĞÎ×´£¨¾ü¹æ 7£º·½°¸²»ËÀ£¬ĞÎ×´Òª»»£©
- ÏÖÂ· 8 ·¢Á¬·¢»¥ÏàÑÚ¸Ç£¨wall .797 << µ¥·¢ºÍ 1.354£©£¬ÈÚºÏÍÈ±ØĞë GPU<.797 ²ÅÓ®£»±¾ÊµÏÖ .887 ²î .09¡£
- **ÏÂÒ»²ùÇĞ"split-K ²¹ P4/P6 µÄ¿ÕÏß³Ì"**£ºP4 K=256 ÇĞ 4 ·İ£¨4rb x 4cb x 4ks = 64 Ïß³Ì£©¡¢P6 K=64 ÇĞ 2 ·İ£»
  ²¿·ÖºÍ int32 Ïà¼Ó**¾«È·=Î»Í¬**£¨|acc|<=256x127x127=4.1M<<2^31£¬ÕûÊı¼Ó½áºÏÂÉ£©? ²»ÆÆÊıÖµºìÏß£»
  reduce staging ¸´ÓÃËÀµôµÄ SLM_HID/PKH Çø£¨SLM ²»¼ÓÇ®£©¡£Ô¤¹À P4->~.10¡¢P6->~.15 ? ÈÚºÏ ~.60 ? **Ã¿Á´ -.20ms¡¢8 Á´/Ö¡ = -1.6ms/Ö¡**¡£
- ´Î¼¶ºòÑ¡£¨Èô split-K ºóÈÔ²»¹»£©£ºB µÄ s8d2 Ë«»º³å½ø SLM£¨Ô¤Ëã»¹ÓĞ ~1KB + ËÀÇø£©£»P3 Óë P2 µÄ store ÈÚºÏ£¨Éú²úÕß²àĞĞ·åĞèÒª¿çÏß³Ì reduce£¬ÏÈ²»¶¯£©¡£
### ½»¸¶Îï
- E:\DSH\dlss-nr-on-a770\src\bench\sycl\s6_ffn_block.cpp£¨¶ÔÕÕÍÈ 8 ·¢ + ESIMD ÈÚºÏÍÈ T=32 + 9 µã¶ÔÅÄ + Á½ÍÈµ¥¼Û + NPHASE ¶ş·Ö£©
- ¸´ÏÖ£ºcd E:/DSH/dlss-nr-on-a770/src/bench/sycl && bash E:/DSH/bench.sh s6_ffn_block.cpp s6_ffn_block.exe
- ±ß½çÊØ×¡£ºÎ´Åö libxmx_sycl.cpp/recorder/39 ÃÅ/ÈÎºÎ dll£»ÎŞ commit/push£»WorkBuddy Ö»¶Á£»GPU ÅÜÍêÎŞ²ĞÁô½ø³Ì¡£
