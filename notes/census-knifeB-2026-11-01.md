# knife B census -- can each frame quant be folded into its producer's store?

Static analysis only: nothing compiled, no GPU, no shipped file modified, nothing committed.
Reproduce with `python -B knifeB_census.py` (pure stdlib).

| input | role |
|---|---|
| `E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c` | the plan: names 1277-1331, signatures 1335-1389, steps 1393-6646, buffers 6651-7952, blobs 7957-9233 |
| `E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\src\gpu\nr_replay.c` | which positional arg of each OP is a buffer id (the f_rec_* translation) |
| `E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp` | recorder declarations, store maps, qfuse guards (cited as libxmx_sycl.cpp:N) |
| `E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\src\bench\sycl\quantize_row_kernel.hpp` | the quant's own row map: :31 `words = k/8`, :48 `base = held*words`, :49-57 gather |

## TL;DR

* the frame (the captured graph, plan lines 5308..6643) contains **276 quant-class ops** (224 `xmx_rec_quant` + 52 `xmx_rec_quant_window`) over 691 recorder steps.
* **212 of them are row-aligned with their producer** under an exact address/row-set test (a1 72, a2 88, a3 52); **0 are misaligned**; **64 have a producer that is not a gemm store**.
* **80 quants still launch every frame**; 196 were already dissolved by the existing knife-A (consumer-side pack fusion) takes.
* knife B removes **721.1 MB** of DRAM = **2.56 ms** mixed-roof (**3.58 ms** at the 36% pub roof, **1.46 ms** at the 88% quant roof, 1.29 ms at the bare 560 GB/s) and **77** launches. The wide-row (a2) block is 637.5 MB of that.
* of the 80 survivors, **72 have a batched-gemm consumer and pass the shared/colslice shape guard outright** (stopped only by the `NR_Q_FUSE_B` env gate on that take); the other **8** have a QKV consumer and are stopped by that take's gather-form rule. Independently of the take guards, **3 of the 80 survivors have a producer that is not a gemm store at all**, so knife B cannot apply to them.

## 0. which part of the plan is the frame
* step 2529 (plan line 3922): `OP_XMX_BEGIN`
* step 3902 (plan line 5295): `OP_XMX_ABORT`
* step 3915 (plan line 5308): `OP_XMX_BEGIN`
* step 5251 (plan line 6644): `OP_XMX_GRAPH_CAPTURE`
* step 5252 (plan line 6645): `OP_XMX_GRAPH_RUN`
* `scratch`: steps 2529..3901 (plan lines 3922..5294) -- 691 recorder steps, 224 quant, 52 quant_window
* `graph`: steps 3915..5250 (plan lines 5308..6643) -- 691 recorder steps, 224 quant, 52 quant_window

The captured region (steps 3915..5250, plan lines 5308..6643) is what `xmx_graph_run` replays: **691 recorder steps, of which 224 xmx_rec_quant + 52 xmx_rec_quant_window = 276 quant-class ops**. The aborted recording (steps 2529..3901) holds 691 recorder steps -- the same op mix, which is a parse cross-check, not a second frame.

Op mix of the captured graph (`nr_plan_steps`, plan lines 1393-6646; signature table lines 1335-1389):

| op | calls in the frame | signature | signature line | recorder declaration |
|---|---|---|---|---|
| xmx_rec_quant | 224 | `iiiii` | 1377 | libxmx_sycl.cpp:4992 |
| xmx_rec_gemm_int8_batched | 72 | `iiiiiiiiiiiiiiiii` | 1380 | libxmx_sycl.cpp:2403 |
| xmx_rec_gemm_int8_residual | 68 | `iiiiiiiiiii` | 1381 | libxmx_sycl.cpp:3032 |
| xmx_rec_gemm_int8_qkv | 60 | `iiiiiiiiiiiii` | 1383 | libxmx_sycl.cpp:2720 |
| xmx_rec_quant_window | 52 | `iiiiiiiii` | 1378 | libxmx_sycl.cpp:3362 |
| xmx_rec_window_attention | 52 | `iiiiiiii` | 1374 | libxmx_sycl.cpp:3862 |
| xmx_rec_gemm_window_int8_residual | 52 | `iiiiiiiiiiiiiii` | 1382 | libxmx_sycl.cpp:3108 |
| xmx_rec_gemm | 42 | `iiiiiiiiiiiiiiiii` | 1363 | libxmx_sycl.cpp:2221 |
| xmx_rec_gemm_int8 | 24 | `iiiiiiiii` | 1379 | libxmx_sycl.cpp:2346 |
| xmx_rec_unary | 16 | `iiiiiiifiiiii` | 1370 | libxmx_sycl.cpp:3396 |
| xmx_rec_window_block | 10 | `iiiiiiiiiiiiii` | 1375 | libxmx_sycl.cpp:4186 |
| xmx_rec_ffn | 8 | `iiiiiiiiiii` | 1385 | libxmx_sycl.cpp:1708 |
| xmx_rec_global_attention | 8 | `iiiiiii` | 1376 | libxmx_sycl.cpp:3266 |
| xmx_rec_ffn_stem | 1 | `iiiiiiii` | 1387 | libxmx_sycl.cpp:2040 |
| xmx_rec_unary2 | 1 | `iiiiiiiifiiiii` | 1371 | libxmx_sycl.cpp:3685 |
| xmx_rec_ffn_merge | 1 | `iiiiiiiiiii` | 1386 | libxmx_sycl.cpp:1873 |

## 1. every QUANT / QUANT_WINDOW in the frame, and the last writer of its src

Buffers are recycled, so the writer search is bounded to the captured graph. `producer output params` are the producer's own plan-row arguments.

| # | quant step | plan line | op | src | M | K | pk | scale | in-place | producer | producer step/line | producer output params |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 3944 | 5337 | xmx_rec_quant | 1270 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm | 3940 / 5333 | M=32640 N=64 K=32 batch=1 sa=1044480 sb=2048 sc=2088960 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 |
| 2 | 3949 | 5342 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 3947 / 5340 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 3 | 3954 | 5347 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 3952 / 5345 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 4 | 3958 | 5351 | xmx_rec_quant_window | 1267 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 3956 / 5349 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 5 | 3966 | 5359 | xmx_rec_quant | 1277 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 3964 / 5357 | batches=1020 heads=2 merged=1 |
| 6 | 3970 | 5363 | xmx_rec_quant | 1270 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 3968 / 5361 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=30 pad=0x0 |
| 7 | 3974 | 5367 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 3972 / 5365 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 8 | 3978 | 5371 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 3976 / 5369 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 9 | 3982 | 5375 | xmx_rec_quant_window | 1267 | 35712 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 3980 / 5373 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 10 | 3988 | 5381 | xmx_rec_quant | 1277 | 35712 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 3986 / 5379 | batches=1116 heads=2 merged=1 |
| 11 | 3992 | 5385 | xmx_rec_quant | 1270 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 3990 / 5383 | M=35712 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=31 pad=0x40004 |
| 12 | 3996 | 5389 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 3994 / 5387 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 13 | 4000 | 5393 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 3998 / 5391 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 14 | 4004 | 5397 | xmx_rec_quant_window | 1267 | 33728 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4002 / 5395 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 15 | 4010 | 5403 | xmx_rec_quant | 1277 | 33728 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 4008 / 5401 | batches=1054 heads=2 merged=1 |
| 16 | 4014 | 5407 | xmx_rec_quant | 1270 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4012 / 5405 | M=33728 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=31 pad=0x4 |
| 17 | 4018 | 5411 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4016 / 5409 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 18 | 4022 | 5415 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4020 / 5413 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 19 | 4026 | 5419 | xmx_rec_quant_window | 1267 | 34560 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4024 / 5417 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 20 | 4032 | 5425 | xmx_rec_quant | 1277 | 34560 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 4030 / 5423 | batches=1080 heads=2 merged=1 |
| 21 | 4039 | 5432 | xmx_rec_quant | 1279 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm | 4037 / 5430 | M=8160 N=128 K=64 batch=1 sa=522240 sb=8192 sc=1044480 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 |
| 22 | 4043 | 5436 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4041 / 5434 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 23 | 4047 | 5440 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4045 / 5438 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 24 | 4051 | 5444 | xmx_rec_quant_window | 1267 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4049 / 5442 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 25 | 4057 | 5450 | xmx_rec_quant | 1277 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 4055 / 5448 | batches=540 heads=4 merged=1 |
| 26 | 4061 | 5454 | xmx_rec_quant | 1279 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4059 / 5452 | M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x0 |
| 27 | 4065 | 5458 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4063 / 5456 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 28 | 4069 | 5462 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4067 / 5460 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 29 | 4073 | 5466 | xmx_rec_quant_window | 1267 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4071 / 5464 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 30 | 4079 | 5472 | xmx_rec_quant | 1277 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 4077 / 5470 | batches=576 heads=4 merged=1 |
| 31 | 4083 | 5476 | xmx_rec_quant | 1279 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4081 / 5474 | M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x40004 |
| 32 | 4087 | 5480 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4085 / 5478 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 33 | 4091 | 5484 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4089 / 5482 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 34 | 4095 | 5488 | xmx_rec_quant_window | 1267 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4093 / 5486 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 35 | 4101 | 5494 | xmx_rec_quant | 1277 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 4099 / 5492 | batches=576 heads=4 merged=1 |
| 36 | 4105 | 5498 | xmx_rec_quant | 1279 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4103 / 5496 | M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x4 |
| 37 | 4109 | 5502 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4107 / 5500 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 38 | 4113 | 5506 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4111 / 5504 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 39 | 4117 | 5510 | xmx_rec_quant_window | 1267 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4115 / 5508 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 40 | 4123 | 5516 | xmx_rec_quant | 1277 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 4121 / 5514 | batches=540 heads=4 merged=1 |
| 41 | 4127 | 5520 | xmx_rec_quant | 1279 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4125 / 5518 | M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x40000 |
| 42 | 4131 | 5524 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4129 / 5522 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 43 | 4135 | 5528 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4133 / 5526 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 44 | 4139 | 5532 | xmx_rec_quant_window | 1267 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4137 / 5530 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 45 | 4145 | 5538 | xmx_rec_quant | 1277 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 4143 / 5536 | batches=540 heads=4 merged=1 |
| 46 | 4149 | 5542 | xmx_rec_quant | 1279 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4147 / 5540 | M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x0 |
| 47 | 4153 | 5546 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4151 / 5544 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 48 | 4157 | 5550 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4155 / 5548 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 49 | 4161 | 5554 | xmx_rec_quant_window | 1267 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4159 / 5552 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 50 | 4167 | 5560 | xmx_rec_quant | 1277 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 4165 / 5558 | batches=576 heads=4 merged=1 |
| 51 | 4174 | 5567 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4172 / 5565 | M=2040 N=256 K=128 batch=1 sa=261120 sb=32768 sc=522240 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 |
| 52 | 4179 | 5572 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4177 / 5570 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 53 | 4183 | 5576 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4181 / 5574 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 54 | 4189 | 5582 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4187 / 5580 | batches=320 heads=8 merged=1 |
| 55 | 4193 | 5586 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4191 / 5584 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x0 |
| 56 | 4198 | 5591 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4196 / 5589 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 57 | 4202 | 5595 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4200 / 5593 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 58 | 4208 | 5601 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4206 / 5599 | batches=320 heads=8 merged=1 |
| 59 | 4212 | 5605 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4210 / 5603 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40004 |
| 60 | 4217 | 5610 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4215 / 5608 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 61 | 4221 | 5614 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4219 / 5612 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 62 | 4227 | 5620 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4225 / 5618 | batches=320 heads=8 merged=1 |
| 63 | 4231 | 5624 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4229 / 5622 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x4 |
| 64 | 4236 | 5629 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4234 / 5627 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 65 | 4240 | 5633 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4238 / 5631 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 66 | 4246 | 5639 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4244 / 5637 | batches=320 heads=8 merged=1 |
| 67 | 4250 | 5643 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4248 / 5641 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40000 |
| 68 | 4255 | 5648 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4253 / 5646 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 69 | 4259 | 5652 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4257 / 5650 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 70 | 4265 | 5658 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4263 / 5656 | batches=320 heads=8 merged=1 |
| 71 | 4269 | 5662 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4267 / 5660 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x0 |
| 72 | 4274 | 5667 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4272 / 5665 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 73 | 4278 | 5671 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4276 / 5669 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 74 | 4284 | 5677 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4282 / 5675 | batches=320 heads=8 merged=1 |
| 75 | 4288 | 5681 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4286 / 5679 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40004 |
| 76 | 4293 | 5686 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4291 / 5684 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 77 | 4297 | 5690 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4295 / 5688 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 78 | 4303 | 5696 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4301 / 5694 | batches=320 heads=8 merged=1 |
| 79 | 4307 | 5700 | xmx_rec_quant | 1281 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4305 / 5698 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x4 |
| 80 | 4312 | 5705 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4310 / 5703 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 81 | 4316 | 5709 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4314 / 5707 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 82 | 4322 | 5715 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4320 / 5713 | batches=320 heads=8 merged=1 |
| 83 | 4330 | 5723 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm | 4328 / 5721 | M=640 N=512 K=256 batch=1 sa=163840 sb=131072 sc=327680 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 |
| 84 | 4335 | 5728 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4333 / 5726 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 85 | 4339 | 5732 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4337 / 5730 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 86 | 4343 | 5736 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4341 / 5734 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 87 | 4349 | 5742 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4347 / 5740 | batches=192 heads=16 merged=1 |
| 88 | 4353 | 5746 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4351 / 5744 | M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x0 |
| 89 | 4358 | 5751 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4356 / 5749 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 90 | 4362 | 5755 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4360 / 5753 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 91 | 4366 | 5759 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4364 / 5757 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 92 | 4372 | 5765 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4370 / 5763 | batches=240 heads=16 merged=1 |
| 93 | 4376 | 5769 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4374 / 5767 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x40004 |
| 94 | 4381 | 5774 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4379 / 5772 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 95 | 4385 | 5778 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4383 / 5776 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 96 | 4389 | 5782 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4387 / 5780 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 97 | 4395 | 5788 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4393 / 5786 | batches=240 heads=16 merged=1 |
| 98 | 4399 | 5792 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4397 / 5790 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x4 |
| 99 | 4404 | 5797 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4402 / 5795 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 100 | 4408 | 5801 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4406 / 5799 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 101 | 4412 | 5805 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4410 / 5803 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 102 | 4418 | 5811 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4416 / 5809 | batches=192 heads=16 merged=1 |
| 103 | 4422 | 5815 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4420 / 5813 | M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x40000 |
| 104 | 4427 | 5820 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4425 / 5818 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 105 | 4431 | 5824 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4429 / 5822 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 106 | 4435 | 5828 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4433 / 5826 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 107 | 4441 | 5834 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4439 / 5832 | batches=192 heads=16 merged=1 |
| 108 | 4445 | 5838 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4443 / 5836 | M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x0 |
| 109 | 4450 | 5843 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4448 / 5841 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 110 | 4454 | 5847 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4452 / 5845 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 111 | 4458 | 5851 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4456 / 5849 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 112 | 4464 | 5857 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4462 / 5855 | batches=240 heads=16 merged=1 |
| 113 | 4468 | 5861 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4466 / 5859 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x40004 |
| 114 | 4473 | 5866 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4471 / 5864 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 115 | 4477 | 5870 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4475 / 5868 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 116 | 4481 | 5874 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4479 / 5872 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 117 | 4487 | 5880 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4485 / 5878 | batches=240 heads=16 merged=1 |
| 118 | 4491 | 5884 | xmx_rec_quant | 1283 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4489 / 5882 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x4 |
| 119 | 4496 | 5889 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4494 / 5887 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 120 | 4500 | 5893 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4498 / 5891 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 121 | 4504 | 5897 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4502 / 5895 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 122 | 4510 | 5903 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4508 / 5901 | batches=192 heads=16 merged=1 |
| 123 | 4522 | 5915 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm | 4518 / 5911 | M=192 N=1024 K=512 batch=1 sa=98304 sb=524288 sc=196608 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 |
| 124 | 4526 | 5919 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4524 / 5917 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 125 | 4530 | 5923 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4528 / 5921 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 126 | 4536 | 5929 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4534 / 5927 | rows=192 tokens=192 heads=32 |
| 127 | 4540 | 5933 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4538 / 5931 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 128 | 4544 | 5937 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4542 / 5935 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 129 | 4548 | 5941 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4546 / 5939 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 130 | 4554 | 5947 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4552 / 5945 | rows=192 tokens=192 heads=32 |
| 131 | 4558 | 5951 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4556 / 5949 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 132 | 4562 | 5955 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4560 / 5953 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 133 | 4566 | 5959 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4564 / 5957 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 134 | 4572 | 5965 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4570 / 5963 | rows=192 tokens=192 heads=32 |
| 135 | 4576 | 5969 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4574 / 5967 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 136 | 4580 | 5973 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4578 / 5971 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 137 | 4584 | 5977 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4582 / 5975 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 138 | 4590 | 5983 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4588 / 5981 | rows=192 tokens=192 heads=32 |
| 139 | 4594 | 5987 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4592 / 5985 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 140 | 4598 | 5991 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4596 / 5989 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 141 | 4602 | 5995 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4600 / 5993 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 142 | 4608 | 6001 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4606 / 5999 | rows=192 tokens=192 heads=32 |
| 143 | 4612 | 6005 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4610 / 6003 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 144 | 4616 | 6009 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4614 / 6007 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 145 | 4620 | 6013 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4618 / 6011 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 146 | 4626 | 6019 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4624 / 6017 | rows=192 tokens=192 heads=32 |
| 147 | 4630 | 6023 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4628 / 6021 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 148 | 4634 | 6027 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4632 / 6025 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 149 | 4638 | 6031 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4636 / 6029 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 150 | 4644 | 6037 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4642 / 6035 | rows=192 tokens=192 heads=32 |
| 151 | 4648 | 6041 | xmx_rec_quant | 1285 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4646 / 6039 | M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] |
| 152 | 4652 | 6045 | xmx_rec_quant | 1274 | 192 | 4096 | 1286 | 1287 | no | xmx_rec_gemm_int8 | 4650 / 6043 | M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] |
| 153 | 4656 | 6049 | xmx_rec_quant | 1267 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_gemm_int8_residual | 4654 / 6047 | M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] |
| 154 | 4662 | 6055 | xmx_rec_quant | 1277 | 192 | 1024 | 1286 | 1287 | no | xmx_rec_global_attention | 4660 / 6053 | rows=192 tokens=192 heads=32 |
| 155 | 4668 | 6061 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_unary | 4666 / 6059 | kind=0x11115[epi=1 narrow=yes] n=327680 channels=512 batch=0 sa=32 sb=16 sc=0 k=0 |
| 156 | 4673 | 6066 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4671 / 6064 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 157 | 4677 | 6070 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4675 / 6068 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 158 | 4681 | 6074 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4679 / 6072 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 159 | 4687 | 6080 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4685 / 6078 | batches=192 heads=16 merged=1 |
| 160 | 4691 | 6084 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4689 / 6082 | M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x0 |
| 161 | 4696 | 6089 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4694 / 6087 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 162 | 4700 | 6093 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4698 / 6091 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 163 | 4704 | 6097 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4702 / 6095 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 164 | 4710 | 6103 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4708 / 6101 | batches=240 heads=16 merged=1 |
| 165 | 4714 | 6107 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4712 / 6105 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x40004 |
| 166 | 4719 | 6112 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4717 / 6110 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 167 | 4723 | 6116 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4721 / 6114 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 168 | 4727 | 6120 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4725 / 6118 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 169 | 4733 | 6126 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4731 / 6124 | batches=240 heads=16 merged=1 |
| 170 | 4737 | 6130 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4735 / 6128 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x4 |
| 171 | 4742 | 6135 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4740 / 6133 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 172 | 4746 | 6139 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4744 / 6137 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 173 | 4750 | 6143 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4748 / 6141 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 174 | 4756 | 6149 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4754 / 6147 | batches=192 heads=16 merged=1 |
| 175 | 4760 | 6153 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4758 / 6151 | M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x40000 |
| 176 | 4765 | 6158 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4763 / 6156 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 177 | 4769 | 6162 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4767 / 6160 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 178 | 4773 | 6166 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4771 / 6164 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 179 | 4779 | 6172 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4777 / 6170 | batches=192 heads=16 merged=1 |
| 180 | 4783 | 6176 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4781 / 6174 | M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x0 |
| 181 | 4788 | 6181 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4786 / 6179 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 182 | 4792 | 6185 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4790 / 6183 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 183 | 4796 | 6189 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4794 / 6187 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 184 | 4802 | 6195 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4800 / 6193 | batches=240 heads=16 merged=1 |
| 185 | 4806 | 6199 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4804 / 6197 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x40004 |
| 186 | 4811 | 6204 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4809 / 6202 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 187 | 4815 | 6208 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4813 / 6206 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 188 | 4819 | 6212 | xmx_rec_quant_window | 1267 | 960 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4817 / 6210 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 189 | 4825 | 6218 | xmx_rec_quant | 1277 | 960 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4823 / 6216 | batches=240 heads=16 merged=1 |
| 190 | 4829 | 6222 | xmx_rec_quant | 1288 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4827 / 6220 | M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x4 |
| 191 | 4834 | 6227 | xmx_rec_quant | 1274 | 640 | 2048 | 1272 | 1273 | no | xmx_rec_gemm | 4832 / 6225 | M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 |
| 192 | 4838 | 6231 | xmx_rec_quant | 1275 | 640 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 4836 / 6229 | M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 193 | 4842 | 6235 | xmx_rec_quant_window | 1267 | 768 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4840 / 6233 | M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] |
| 194 | 4848 | 6241 | xmx_rec_quant | 1277 | 768 | 512 | 1272 | 1273 | no | xmx_rec_window_attention | 4846 / 6239 | batches=192 heads=16 merged=1 |
| 195 | 4854 | 6247 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_unary | 4852 / 6245 | kind=0x11115[epi=1 narrow=yes] n=522240 channels=256 batch=0 sa=60 sb=32 sc=0 k=0 |
| 196 | 4859 | 6252 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4857 / 6250 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 197 | 4863 | 6256 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4861 / 6254 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 198 | 4869 | 6262 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4867 / 6260 | batches=320 heads=8 merged=1 |
| 199 | 4873 | 6266 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4871 / 6264 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x0 |
| 200 | 4878 | 6271 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4876 / 6269 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 201 | 4882 | 6275 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4880 / 6273 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 202 | 4888 | 6281 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4886 / 6279 | batches=320 heads=8 merged=1 |
| 203 | 4892 | 6285 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4890 / 6283 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40004 |
| 204 | 4897 | 6290 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4895 / 6288 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 205 | 4901 | 6294 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4899 / 6292 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 206 | 4907 | 6300 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4905 / 6298 | batches=320 heads=8 merged=1 |
| 207 | 4911 | 6304 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4909 / 6302 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x4 |
| 208 | 4916 | 6309 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4914 / 6307 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 209 | 4920 | 6313 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4918 / 6311 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 210 | 4926 | 6319 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4924 / 6317 | batches=320 heads=8 merged=1 |
| 211 | 4930 | 6323 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4928 / 6321 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40000 |
| 212 | 4935 | 6328 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4933 / 6326 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 213 | 4939 | 6332 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4937 / 6330 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 214 | 4945 | 6338 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4943 / 6336 | batches=320 heads=8 merged=1 |
| 215 | 4949 | 6342 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4947 / 6340 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x0 |
| 216 | 4954 | 6347 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4952 / 6345 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 217 | 4958 | 6351 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4956 / 6349 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 218 | 4964 | 6357 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4962 / 6355 | batches=320 heads=8 merged=1 |
| 219 | 4968 | 6361 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4966 / 6359 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40004 |
| 220 | 4973 | 6366 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4971 / 6364 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 221 | 4977 | 6370 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4975 / 6368 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 222 | 4983 | 6376 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 4981 / 6374 | batches=320 heads=8 merged=1 |
| 223 | 4987 | 6380 | xmx_rec_quant | 1291 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 4985 / 6378 | M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x4 |
| 224 | 4992 | 6385 | xmx_rec_quant | 1275 | 2040 | 256 | 1272 | 1273 | no | xmx_rec_gemm | 4990 / 6383 | M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 |
| 225 | 4996 | 6389 | xmx_rec_quant_window | 1267 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 4994 / 6387 | M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] |
| 226 | 5002 | 6395 | xmx_rec_quant | 1277 | 2560 | 256 | 1272 | 1273 | no | xmx_rec_window_attention | 5000 / 6393 | batches=320 heads=8 merged=1 |
| 227 | 5008 | 6401 | xmx_rec_quant | 1294 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_unary | 5006 / 6399 | kind=0x11115[epi=1 narrow=yes] n=1044480 channels=128 batch=0 sa=120 sb=60 sc=0 k=0 |
| 228 | 5012 | 6405 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5010 / 6403 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 229 | 5016 | 6409 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5014 / 6407 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 230 | 5020 | 6413 | xmx_rec_quant_window | 1267 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5018 / 6411 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 231 | 5026 | 6419 | xmx_rec_quant | 1277 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 5024 / 6417 | batches=576 heads=4 merged=1 |
| 232 | 5030 | 6423 | xmx_rec_quant | 1294 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5028 / 6421 | M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x4 |
| 233 | 5034 | 6427 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5032 / 6425 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 234 | 5038 | 6431 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5036 / 6429 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 235 | 5042 | 6435 | xmx_rec_quant_window | 1267 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5040 / 6433 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 236 | 5048 | 6441 | xmx_rec_quant | 1277 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 5046 / 6439 | batches=540 heads=4 merged=1 |
| 237 | 5052 | 6445 | xmx_rec_quant | 1294 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5050 / 6443 | M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x40000 |
| 238 | 5056 | 6449 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5054 / 6447 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 239 | 5060 | 6453 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5058 / 6451 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 240 | 5064 | 6457 | xmx_rec_quant_window | 1267 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5062 / 6455 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 241 | 5070 | 6463 | xmx_rec_quant | 1277 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 5068 / 6461 | batches=540 heads=4 merged=1 |
| 242 | 5074 | 6467 | xmx_rec_quant | 1294 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5072 / 6465 | M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x0 |
| 243 | 5078 | 6471 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5076 / 6469 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 244 | 5082 | 6475 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5080 / 6473 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 245 | 5086 | 6479 | xmx_rec_quant_window | 1267 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5084 / 6477 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 246 | 5092 | 6485 | xmx_rec_quant | 1277 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 5090 / 6483 | batches=576 heads=4 merged=1 |
| 247 | 5096 | 6489 | xmx_rec_quant | 1294 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5094 / 6487 | M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x40004 |
| 248 | 5100 | 6493 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5098 / 6491 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 249 | 5104 | 6497 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5102 / 6495 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 250 | 5108 | 6501 | xmx_rec_quant_window | 1267 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5106 / 6499 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 251 | 5114 | 6507 | xmx_rec_quant | 1277 | 9216 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 5112 / 6505 | batches=576 heads=4 merged=1 |
| 252 | 5118 | 6511 | xmx_rec_quant | 1294 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5116 / 6509 | M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x4 |
| 253 | 5122 | 6515 | xmx_rec_quant | 1274 | 8160 | 512 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5120 / 6513 | M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 254 | 5126 | 6519 | xmx_rec_quant | 1275 | 8160 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5124 / 6517 | M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 255 | 5130 | 6523 | xmx_rec_quant_window | 1267 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5128 / 6521 | M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] |
| 256 | 5136 | 6529 | xmx_rec_quant | 1277 | 8640 | 128 | 1272 | 1273 | no | xmx_rec_window_attention | 5134 / 6527 | batches=540 heads=4 merged=1 |
| 257 | 5142 | 6535 | xmx_rec_quant | 1297 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_unary | 5140 / 6533 | kind=0x11115[epi=1 narrow=yes] n=2088960 channels=64 batch=0 sa=240 sb=120 sc=0 k=0 |
| 258 | 5146 | 6539 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5144 / 6537 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 259 | 5150 | 6543 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5148 / 6541 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 260 | 5154 | 6547 | xmx_rec_quant_window | 1267 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5152 / 6545 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 261 | 5160 | 6553 | xmx_rec_quant | 1277 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 5158 / 6551 | batches=1020 heads=2 merged=1 |
| 262 | 5164 | 6557 | xmx_rec_quant | 1297 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5162 / 6555 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=30 pad=0x0 |
| 263 | 5168 | 6561 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5166 / 6559 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 264 | 5172 | 6565 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5170 / 6563 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 265 | 5176 | 6569 | xmx_rec_quant_window | 1267 | 35712 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5174 / 6567 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 266 | 5182 | 6575 | xmx_rec_quant | 1277 | 35712 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 5180 / 6573 | batches=1116 heads=2 merged=1 |
| 267 | 5186 | 6579 | xmx_rec_quant | 1297 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5184 / 6577 | M=35712 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=31 pad=0x40004 |
| 268 | 5190 | 6583 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5188 / 6581 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 269 | 5194 | 6587 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5192 / 6585 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 270 | 5198 | 6591 | xmx_rec_quant_window | 1267 | 33728 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5196 / 6589 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 271 | 5204 | 6597 | xmx_rec_quant | 1277 | 33728 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 5202 / 6595 | batches=1054 heads=2 merged=1 |
| 272 | 5208 | 6601 | xmx_rec_quant | 1297 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_window_int8_residual | 5206 / 6599 | M=33728 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=31 pad=0x4 |
| 273 | 5212 | 6605 | xmx_rec_quant | 1274 | 32640 | 256 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5210 / 6603 | M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] |
| 274 | 5216 | 6609 | xmx_rec_quant | 1275 | 32640 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_batched | 5214 / 6607 | M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] |
| 275 | 5220 | 6613 | xmx_rec_quant_window | 1267 | 34560 | 64 | 1272 | 1273 | no | xmx_rec_gemm_int8_residual | 5218 / 6611 | M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] |
| 276 | 5226 | 6619 | xmx_rec_quant | 1277 | 34560 | 64 | 1272 | 1273 | no | xmx_rec_window_attention | 5224 / 6617 | batches=1080 heads=2 merged=1 |

### 1b. who writes the quant sources
* xmx_rec_gemm_int8_residual               67   (store map: libxmx_sycl.cpp:3084 gemm_b_res -- dense, row pitch N)
* xmx_rec_gemm_int8_batched                56   (store map: libxmx_sycl.cpp:2670/2673 gemm_b_pub[_slm] / :2690-2692 publish -- out = g*sc + r*ldc_ + col, ldc_ = ldc?ldc:N)
* xmx_rec_window_attention                 52   (store map: resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder)
* xmx_rec_gemm_window_int8_residual        44   (store map: libxmx_sycl.cpp:3093-3102 + :3249 gemm_b_res_window -- at = ((y-top)*width + x-left)*N + c, out-of-range slots skipped entirely)
* xmx_rec_gemm                             37   (store map: libxmx_sycl.cpp:2304 gemm_b_pub_f16 / :2316-2327 publish -- out = oc + g*sc + r*ldc_e + col, ldc_e = ldc?ldc:N, narrow = bt&0x1000, epi = (bt>>8)&0xF, only r<M published (:2260))
* xmx_rec_gemm_int8                        8   (store map: libxmx_sycl.cpp:2382-2383 gemm_b_pub(batch=1, group stride M*N, ldc=N))
* xmx_rec_global_attention                 8   (store map: libxmx_sycl.cpp:3263 merged = rows x heads*32 (composed from the two gated gemms))
* xmx_rec_unary                            4   (store map: libxmx_sycl.cpp:3391-3393 generic load/store over n elements, row length = channels)

### 1c. the pk/scale scratch the quants write into
* distinct (pk, scale) pairs over 276 quants: 2 -- (1272,1273) x244, (1286,1287) x32
* in-place quants (pk == src): 0
  Every frame quant is NON-in-place, which is the guard that cancelled the old v9b FOLD (`libxmx_sycl.cpp:5024` requires `packed == source`, :5036-5040 cancels otherwise). Knife B does not need in-place: the producer writes the pk/scale ids the consumers already read.
* adjacency of the pair (producer step -> quant step): min 2, max 4, mean 2.01

### 1d. size cross-check against `nr_plan_buffers` (catches any mis-read of M/K)
* 276 quant ops x 3 operands = 828 checks, **0 violations** (every quant's M*K*2 source bytes, M*K packed bytes and 4*M scale bytes fit inside the plan's own buffer sizes).

### 1e. buffer identity across the two recordings
* 1313 `OP_BUF` rows but 1302 distinct plan buffer numbers, and 11 `xmx_buf_destroy` rows: ids 1267, 1271-1277, 1285-1287 are created as 256-byte placeholders in the aborted recording, destroyed at plan lines 5296-5306 and re-created at their real sizes inside the captured graph (e.g. 1267 = 66846720 B at plan line 5309). The replayer numbers buffers by plan index (`nr_replay.c:475`), so a plan index means ONE plane inside the captured graph -- which is what the writer search above relies on.

## 2. alignment verdict -- exact row-set comparison

For each pair the census enumerates the address intervals each row covers and compares them as multisets (code: `producer_rows`/`quant_rows`/`classify`). Coverage of the whole plane is checked first (holes, double writes, base offsets), then the row CONTENT multiset, and only afterwards where the fold has to put the result (one run per row, several column groups, or a gathered row index).

| # | step/line | op | src | M x K | producer (step/line) | producer rows x pitch | coverage equal | row multiset equal | groups per row | gather view? | other readers of src | class |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 3944/5337 | xmx_rec_quant | 1270 | 32640x64 | xmx_rec_gemm @3940/5333 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 2 | 3949/5342 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @3947/5340 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 3 | 3954/5347 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @3952/5345 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 4 | 3958/5351 | xmx_rec_quant_window | 1267 | 32640x64 | xmx_rec_gemm_int8_residual @3956/5349 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 5 | 3966/5359 | xmx_rec_quant | 1277 | 32640x64 | xmx_rec_window_attention @3964/5357 | - | False | False | - | - | 0 | c-fused-block-producer |
| 6 | 3970/5363 | xmx_rec_quant | 1270 | 32640x64 | xmx_rec_gemm_window_int8_residual @3968/5361 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 7 | 3974/5367 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @3972/5365 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 8 | 3978/5371 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @3976/5369 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 9 | 3982/5375 | xmx_rec_quant_window | 1267 | 35712x64 | xmx_rec_gemm_int8_residual @3980/5373 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 10 | 3988/5381 | xmx_rec_quant | 1277 | 35712x64 | xmx_rec_window_attention @3986/5379 | - | False | False | - | - | 0 | c-fused-block-producer |
| 11 | 3992/5385 | xmx_rec_quant | 1270 | 32640x64 | xmx_rec_gemm_window_int8_residual @3990/5383 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 12 | 3996/5389 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @3994/5387 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 13 | 4000/5393 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @3998/5391 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 14 | 4004/5397 | xmx_rec_quant_window | 1267 | 33728x64 | xmx_rec_gemm_int8_residual @4002/5395 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 15 | 4010/5403 | xmx_rec_quant | 1277 | 33728x64 | xmx_rec_window_attention @4008/5401 | - | False | False | - | - | 0 | c-fused-block-producer |
| 16 | 4014/5407 | xmx_rec_quant | 1270 | 32640x64 | xmx_rec_gemm_window_int8_residual @4012/5405 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 17 | 4018/5411 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @4016/5409 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 18 | 4022/5415 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @4020/5413 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 19 | 4026/5419 | xmx_rec_quant_window | 1267 | 34560x64 | xmx_rec_gemm_int8_residual @4024/5417 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 20 | 4032/5425 | xmx_rec_quant | 1277 | 34560x64 | xmx_rec_window_attention @4030/5423 | - | False | False | - | - | 0 | c-fused-block-producer |
| 21 | 4039/5432 | xmx_rec_quant | 1279 | 8160x128 | xmx_rec_gemm @4037/5430 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 22 | 4043/5436 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @4041/5434 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 23 | 4047/5440 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @4045/5438 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 24 | 4051/5444 | xmx_rec_quant_window | 1267 | 8640x128 | xmx_rec_gemm_int8_residual @4049/5442 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 25 | 4057/5450 | xmx_rec_quant | 1277 | 8640x128 | xmx_rec_window_attention @4055/5448 | - | False | False | - | - | 0 | c-fused-block-producer |
| 26 | 4061/5454 | xmx_rec_quant | 1279 | 8160x128 | xmx_rec_gemm_window_int8_residual @4059/5452 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 27 | 4065/5458 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @4063/5456 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 28 | 4069/5462 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @4067/5460 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 29 | 4073/5466 | xmx_rec_quant_window | 1267 | 9216x128 | xmx_rec_gemm_int8_residual @4071/5464 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 30 | 4079/5472 | xmx_rec_quant | 1277 | 9216x128 | xmx_rec_window_attention @4077/5470 | - | False | False | - | - | 0 | c-fused-block-producer |
| 31 | 4083/5476 | xmx_rec_quant | 1279 | 8160x128 | xmx_rec_gemm_window_int8_residual @4081/5474 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 32 | 4087/5480 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @4085/5478 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 33 | 4091/5484 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @4089/5482 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 34 | 4095/5488 | xmx_rec_quant_window | 1267 | 9216x128 | xmx_rec_gemm_int8_residual @4093/5486 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 35 | 4101/5494 | xmx_rec_quant | 1277 | 9216x128 | xmx_rec_window_attention @4099/5492 | - | False | False | - | - | 0 | c-fused-block-producer |
| 36 | 4105/5498 | xmx_rec_quant | 1279 | 8160x128 | xmx_rec_gemm_window_int8_residual @4103/5496 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 37 | 4109/5502 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @4107/5500 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 38 | 4113/5506 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @4111/5504 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 39 | 4117/5510 | xmx_rec_quant_window | 1267 | 8640x128 | xmx_rec_gemm_int8_residual @4115/5508 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 40 | 4123/5516 | xmx_rec_quant | 1277 | 8640x128 | xmx_rec_window_attention @4121/5514 | - | False | False | - | - | 0 | c-fused-block-producer |
| 41 | 4127/5520 | xmx_rec_quant | 1279 | 8160x128 | xmx_rec_gemm_window_int8_residual @4125/5518 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 42 | 4131/5524 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @4129/5522 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 43 | 4135/5528 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @4133/5526 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 44 | 4139/5532 | xmx_rec_quant_window | 1267 | 8640x128 | xmx_rec_gemm_int8_residual @4137/5530 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 45 | 4145/5538 | xmx_rec_quant | 1277 | 8640x128 | xmx_rec_window_attention @4143/5536 | - | False | False | - | - | 0 | c-fused-block-producer |
| 46 | 4149/5542 | xmx_rec_quant | 1279 | 8160x128 | xmx_rec_gemm_window_int8_residual @4147/5540 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 47 | 4153/5546 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @4151/5544 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 48 | 4157/5550 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @4155/5548 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 49 | 4161/5554 | xmx_rec_quant_window | 1267 | 9216x128 | xmx_rec_gemm_int8_residual @4159/5552 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 50 | 4167/5560 | xmx_rec_quant | 1277 | 9216x128 | xmx_rec_window_attention @4165/5558 | - | False | False | - | - | 0 | c-fused-block-producer |
| 51 | 4174/5567 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm @4172/5565 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 52 | 4179/5572 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4177/5570 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 53 | 4183/5576 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4181/5574 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 54 | 4189/5582 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4187/5580 | - | False | False | - | - | 0 | c-fused-block-producer |
| 55 | 4193/5586 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4191/5584 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 56 | 4198/5591 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4196/5589 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 57 | 4202/5595 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4200/5593 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 58 | 4208/5601 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4206/5599 | - | False | False | - | - | 0 | c-fused-block-producer |
| 59 | 4212/5605 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4210/5603 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 60 | 4217/5610 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4215/5608 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 61 | 4221/5614 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4219/5612 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 62 | 4227/5620 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4225/5618 | - | False | False | - | - | 0 | c-fused-block-producer |
| 63 | 4231/5624 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4229/5622 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 64 | 4236/5629 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4234/5627 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 65 | 4240/5633 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4238/5631 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 66 | 4246/5639 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4244/5637 | - | False | False | - | - | 0 | c-fused-block-producer |
| 67 | 4250/5643 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4248/5641 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 68 | 4255/5648 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4253/5646 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 69 | 4259/5652 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4257/5650 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 70 | 4265/5658 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4263/5656 | - | False | False | - | - | 0 | c-fused-block-producer |
| 71 | 4269/5662 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4267/5660 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 72 | 4274/5667 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4272/5665 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 73 | 4278/5671 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4276/5669 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 74 | 4284/5677 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4282/5675 | - | False | False | - | - | 0 | c-fused-block-producer |
| 75 | 4288/5681 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4286/5679 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 76 | 4293/5686 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4291/5684 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 77 | 4297/5690 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4295/5688 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 78 | 4303/5696 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4301/5694 | - | False | False | - | - | 0 | c-fused-block-producer |
| 79 | 4307/5700 | xmx_rec_quant | 1281 | 2040x256 | xmx_rec_gemm_window_int8_residual @4305/5698 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 80 | 4312/5705 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4310/5703 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 81 | 4316/5709 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4314/5707 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 82 | 4322/5715 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4320/5713 | - | False | False | - | - | 0 | c-fused-block-producer |
| 83 | 4330/5723 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm @4328/5721 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 84 | 4335/5728 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4333/5726 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 85 | 4339/5732 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4337/5730 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 86 | 4343/5736 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4341/5734 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 87 | 4349/5742 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4347/5740 | - | False | False | - | - | 0 | c-fused-block-producer |
| 88 | 4353/5746 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4351/5744 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 89 | 4358/5751 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4356/5749 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 90 | 4362/5755 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4360/5753 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 91 | 4366/5759 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4364/5757 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 92 | 4372/5765 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4370/5763 | - | False | False | - | - | 0 | c-fused-block-producer |
| 93 | 4376/5769 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4374/5767 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 94 | 4381/5774 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4379/5772 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 95 | 4385/5778 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4383/5776 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 96 | 4389/5782 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4387/5780 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 97 | 4395/5788 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4393/5786 | - | False | False | - | - | 0 | c-fused-block-producer |
| 98 | 4399/5792 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4397/5790 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 99 | 4404/5797 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4402/5795 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 100 | 4408/5801 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4406/5799 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 101 | 4412/5805 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4410/5803 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 102 | 4418/5811 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4416/5809 | - | False | False | - | - | 0 | c-fused-block-producer |
| 103 | 4422/5815 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4420/5813 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 104 | 4427/5820 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4425/5818 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 105 | 4431/5824 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4429/5822 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 106 | 4435/5828 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4433/5826 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 107 | 4441/5834 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4439/5832 | - | False | False | - | - | 0 | c-fused-block-producer |
| 108 | 4445/5838 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4443/5836 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 109 | 4450/5843 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4448/5841 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 110 | 4454/5847 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4452/5845 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 111 | 4458/5851 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4456/5849 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 112 | 4464/5857 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4462/5855 | - | False | False | - | - | 0 | c-fused-block-producer |
| 113 | 4468/5861 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4466/5859 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 114 | 4473/5866 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4471/5864 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 115 | 4477/5870 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4475/5868 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 116 | 4481/5874 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4479/5872 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 117 | 4487/5880 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4485/5878 | - | False | False | - | - | 0 | c-fused-block-producer |
| 118 | 4491/5884 | xmx_rec_quant | 1283 | 640x512 | xmx_rec_gemm_window_int8_residual @4489/5882 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 119 | 4496/5889 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4494/5887 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 120 | 4500/5893 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4498/5891 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 121 | 4504/5897 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4502/5895 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 122 | 4510/5903 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4508/5901 | - | False | False | - | - | 0 | c-fused-block-producer |
| 123 | 4522/5915 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm @4518/5911 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 124 | 4526/5919 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4524/5917 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 125 | 4530/5923 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4528/5921 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 126 | 4536/5929 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4534/5927 | - | False | False | - | - | 0 | c-fused-block-producer |
| 127 | 4540/5933 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4538/5931 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 128 | 4544/5937 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4542/5935 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 129 | 4548/5941 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4546/5939 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 130 | 4554/5947 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4552/5945 | - | False | False | - | - | 0 | c-fused-block-producer |
| 131 | 4558/5951 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4556/5949 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 132 | 4562/5955 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4560/5953 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 133 | 4566/5959 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4564/5957 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 134 | 4572/5965 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4570/5963 | - | False | False | - | - | 0 | c-fused-block-producer |
| 135 | 4576/5969 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4574/5967 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 136 | 4580/5973 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4578/5971 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 137 | 4584/5977 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4582/5975 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 138 | 4590/5983 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4588/5981 | - | False | False | - | - | 0 | c-fused-block-producer |
| 139 | 4594/5987 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4592/5985 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 140 | 4598/5991 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4596/5989 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 141 | 4602/5995 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4600/5993 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 142 | 4608/6001 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4606/5999 | - | False | False | - | - | 0 | c-fused-block-producer |
| 143 | 4612/6005 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4610/6003 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 144 | 4616/6009 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4614/6007 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 145 | 4620/6013 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4618/6011 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 146 | 4626/6019 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4624/6017 | - | False | False | - | - | 0 | c-fused-block-producer |
| 147 | 4630/6023 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4628/6021 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 148 | 4634/6027 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4632/6025 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 149 | 4638/6031 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4636/6029 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 150 | 4644/6037 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4642/6035 | - | False | False | - | - | 0 | c-fused-block-producer |
| 151 | 4648/6041 | xmx_rec_quant | 1285 | 192x1024 | xmx_rec_gemm_int8_residual @4646/6039 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 152 | 4652/6045 | xmx_rec_quant | 1274 | 192x4096 | xmx_rec_gemm_int8 @4650/6043 | 192 x 4096 | True | True | 1 | no | 0 | a1-single-run |
| 153 | 4656/6049 | xmx_rec_quant | 1267 | 192x1024 | xmx_rec_gemm_int8_residual @4654/6047 | 192 x 1024 | True | True | 1 | no | 1 | a1-single-run |
| 154 | 4662/6055 | xmx_rec_quant | 1277 | 192x1024 | xmx_rec_global_attention @4660/6053 | - | False | False | - | - | 0 | c-fused-block-producer |
| 155 | 4668/6061 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_unary @4666/6059 | - | False | False | - | - | 1 | c-elementwise-producer |
| 156 | 4673/6066 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4671/6064 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 157 | 4677/6070 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4675/6068 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 158 | 4681/6074 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4679/6072 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 159 | 4687/6080 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4685/6078 | - | False | False | - | - | 0 | c-fused-block-producer |
| 160 | 4691/6084 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4689/6082 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 161 | 4696/6089 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4694/6087 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 162 | 4700/6093 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4698/6091 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 163 | 4704/6097 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4702/6095 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 164 | 4710/6103 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4708/6101 | - | False | False | - | - | 0 | c-fused-block-producer |
| 165 | 4714/6107 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4712/6105 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 166 | 4719/6112 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4717/6110 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 167 | 4723/6116 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4721/6114 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 168 | 4727/6120 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4725/6118 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 169 | 4733/6126 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4731/6124 | - | False | False | - | - | 0 | c-fused-block-producer |
| 170 | 4737/6130 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4735/6128 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 171 | 4742/6135 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4740/6133 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 172 | 4746/6139 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4744/6137 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 173 | 4750/6143 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4748/6141 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 174 | 4756/6149 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4754/6147 | - | False | False | - | - | 0 | c-fused-block-producer |
| 175 | 4760/6153 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4758/6151 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 176 | 4765/6158 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4763/6156 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 177 | 4769/6162 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4767/6160 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 178 | 4773/6166 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4771/6164 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 179 | 4779/6172 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4777/6170 | - | False | False | - | - | 0 | c-fused-block-producer |
| 180 | 4783/6176 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4781/6174 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 181 | 4788/6181 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4786/6179 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 182 | 4792/6185 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4790/6183 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 183 | 4796/6189 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4794/6187 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 184 | 4802/6195 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4800/6193 | - | False | False | - | - | 0 | c-fused-block-producer |
| 185 | 4806/6199 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4804/6197 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 186 | 4811/6204 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4809/6202 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 187 | 4815/6208 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4813/6206 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 188 | 4819/6212 | xmx_rec_quant_window | 1267 | 960x512 | xmx_rec_gemm_int8_residual @4817/6210 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 189 | 4825/6218 | xmx_rec_quant | 1277 | 960x512 | xmx_rec_window_attention @4823/6216 | - | False | False | - | - | 0 | c-fused-block-producer |
| 190 | 4829/6222 | xmx_rec_quant | 1288 | 640x512 | xmx_rec_gemm_window_int8_residual @4827/6220 | 640 x 512 | True | True | 1 | no | 1 | a1-single-run |
| 191 | 4834/6227 | xmx_rec_quant | 1274 | 640x2048 | xmx_rec_gemm @4832/6225 | 640 x 2048 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 192 | 4838/6231 | xmx_rec_quant | 1275 | 640x512 | xmx_rec_gemm_int8_batched @4836/6229 | 640 x 512 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 193 | 4842/6235 | xmx_rec_quant_window | 1267 | 768x512 | xmx_rec_gemm_int8_residual @4840/6233 | 640 x 512 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 194 | 4848/6241 | xmx_rec_quant | 1277 | 768x512 | xmx_rec_window_attention @4846/6239 | - | False | False | - | - | 0 | c-fused-block-producer |
| 195 | 4854/6247 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_unary @4852/6245 | - | False | False | - | - | 1 | c-elementwise-producer |
| 196 | 4859/6252 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4857/6250 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 197 | 4863/6256 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4861/6254 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 198 | 4869/6262 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4867/6260 | - | False | False | - | - | 0 | c-fused-block-producer |
| 199 | 4873/6266 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4871/6264 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 200 | 4878/6271 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4876/6269 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 201 | 4882/6275 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4880/6273 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 202 | 4888/6281 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4886/6279 | - | False | False | - | - | 0 | c-fused-block-producer |
| 203 | 4892/6285 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4890/6283 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 204 | 4897/6290 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4895/6288 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 205 | 4901/6294 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4899/6292 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 206 | 4907/6300 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4905/6298 | - | False | False | - | - | 0 | c-fused-block-producer |
| 207 | 4911/6304 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4909/6302 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 208 | 4916/6309 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4914/6307 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 209 | 4920/6313 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4918/6311 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 210 | 4926/6319 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4924/6317 | - | False | False | - | - | 0 | c-fused-block-producer |
| 211 | 4930/6323 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4928/6321 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 212 | 4935/6328 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4933/6326 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 213 | 4939/6332 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4937/6330 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 214 | 4945/6338 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4943/6336 | - | False | False | - | - | 0 | c-fused-block-producer |
| 215 | 4949/6342 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4947/6340 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 216 | 4954/6347 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4952/6345 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 217 | 4958/6351 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4956/6349 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 218 | 4964/6357 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4962/6355 | - | False | False | - | - | 0 | c-fused-block-producer |
| 219 | 4968/6361 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4966/6359 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 220 | 4973/6366 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4971/6364 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 221 | 4977/6370 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4975/6368 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 222 | 4983/6376 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @4981/6374 | - | False | False | - | - | 0 | c-fused-block-producer |
| 223 | 4987/6380 | xmx_rec_quant | 1291 | 2040x256 | xmx_rec_gemm_window_int8_residual @4985/6378 | 2040 x 256 | True | True | 1 | no | 1 | a1-single-run |
| 224 | 4992/6385 | xmx_rec_quant | 1275 | 2040x256 | xmx_rec_gemm @4990/6383 | 2040 x 256 | True | True | 8 | no | 0 | a2-row-spans-groups |
| 225 | 4996/6389 | xmx_rec_quant_window | 1267 | 2560x256 | xmx_rec_gemm_int8_residual @4994/6387 | 2040 x 256 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 226 | 5002/6395 | xmx_rec_quant | 1277 | 2560x256 | xmx_rec_window_attention @5000/6393 | - | False | False | - | - | 0 | c-fused-block-producer |
| 227 | 5008/6401 | xmx_rec_quant | 1294 | 8160x128 | xmx_rec_unary @5006/6399 | - | False | False | - | - | 1 | c-elementwise-producer |
| 228 | 5012/6405 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @5010/6403 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 229 | 5016/6409 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @5014/6407 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 230 | 5020/6413 | xmx_rec_quant_window | 1267 | 9216x128 | xmx_rec_gemm_int8_residual @5018/6411 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 231 | 5026/6419 | xmx_rec_quant | 1277 | 9216x128 | xmx_rec_window_attention @5024/6417 | - | False | False | - | - | 0 | c-fused-block-producer |
| 232 | 5030/6423 | xmx_rec_quant | 1294 | 8160x128 | xmx_rec_gemm_window_int8_residual @5028/6421 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 233 | 5034/6427 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @5032/6425 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 234 | 5038/6431 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @5036/6429 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 235 | 5042/6435 | xmx_rec_quant_window | 1267 | 8640x128 | xmx_rec_gemm_int8_residual @5040/6433 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 236 | 5048/6441 | xmx_rec_quant | 1277 | 8640x128 | xmx_rec_window_attention @5046/6439 | - | False | False | - | - | 0 | c-fused-block-producer |
| 237 | 5052/6445 | xmx_rec_quant | 1294 | 8160x128 | xmx_rec_gemm_window_int8_residual @5050/6443 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 238 | 5056/6449 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @5054/6447 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 239 | 5060/6453 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @5058/6451 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 240 | 5064/6457 | xmx_rec_quant_window | 1267 | 8640x128 | xmx_rec_gemm_int8_residual @5062/6455 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 241 | 5070/6463 | xmx_rec_quant | 1277 | 8640x128 | xmx_rec_window_attention @5068/6461 | - | False | False | - | - | 0 | c-fused-block-producer |
| 242 | 5074/6467 | xmx_rec_quant | 1294 | 8160x128 | xmx_rec_gemm_window_int8_residual @5072/6465 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 243 | 5078/6471 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @5076/6469 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 244 | 5082/6475 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @5080/6473 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 245 | 5086/6479 | xmx_rec_quant_window | 1267 | 9216x128 | xmx_rec_gemm_int8_residual @5084/6477 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 246 | 5092/6485 | xmx_rec_quant | 1277 | 9216x128 | xmx_rec_window_attention @5090/6483 | - | False | False | - | - | 0 | c-fused-block-producer |
| 247 | 5096/6489 | xmx_rec_quant | 1294 | 8160x128 | xmx_rec_gemm_window_int8_residual @5094/6487 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 248 | 5100/6493 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @5098/6491 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 249 | 5104/6497 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @5102/6495 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 250 | 5108/6501 | xmx_rec_quant_window | 1267 | 9216x128 | xmx_rec_gemm_int8_residual @5106/6499 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 251 | 5114/6507 | xmx_rec_quant | 1277 | 9216x128 | xmx_rec_window_attention @5112/6505 | - | False | False | - | - | 0 | c-fused-block-producer |
| 252 | 5118/6511 | xmx_rec_quant | 1294 | 8160x128 | xmx_rec_gemm_window_int8_residual @5116/6509 | 8160 x 128 | True | True | 1 | no | 1 | a1-single-run |
| 253 | 5122/6515 | xmx_rec_quant | 1274 | 8160x512 | xmx_rec_gemm_int8_batched @5120/6513 | 8160 x 512 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 254 | 5126/6519 | xmx_rec_quant | 1275 | 8160x128 | xmx_rec_gemm_int8_batched @5124/6517 | 8160 x 128 | True | True | 4 | no | 0 | a2-row-spans-groups |
| 255 | 5130/6523 | xmx_rec_quant_window | 1267 | 8640x128 | xmx_rec_gemm_int8_residual @5128/6521 | 8160 x 128 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 256 | 5136/6529 | xmx_rec_quant | 1277 | 8640x128 | xmx_rec_window_attention @5134/6527 | - | False | False | - | - | 0 | c-fused-block-producer |
| 257 | 5142/6535 | xmx_rec_quant | 1297 | 32640x64 | xmx_rec_unary @5140/6533 | - | False | False | - | - | 1 | c-elementwise-producer |
| 258 | 5146/6539 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @5144/6537 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 259 | 5150/6543 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @5148/6541 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 260 | 5154/6547 | xmx_rec_quant_window | 1267 | 32640x64 | xmx_rec_gemm_int8_residual @5152/6545 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 261 | 5160/6553 | xmx_rec_quant | 1277 | 32640x64 | xmx_rec_window_attention @5158/6551 | - | False | False | - | - | 0 | c-fused-block-producer |
| 262 | 5164/6557 | xmx_rec_quant | 1297 | 32640x64 | xmx_rec_gemm_window_int8_residual @5162/6555 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 263 | 5168/6561 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @5166/6559 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 264 | 5172/6565 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @5170/6563 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 265 | 5176/6569 | xmx_rec_quant_window | 1267 | 35712x64 | xmx_rec_gemm_int8_residual @5174/6567 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 266 | 5182/6575 | xmx_rec_quant | 1277 | 35712x64 | xmx_rec_window_attention @5180/6573 | - | False | False | - | - | 0 | c-fused-block-producer |
| 267 | 5186/6579 | xmx_rec_quant | 1297 | 32640x64 | xmx_rec_gemm_window_int8_residual @5184/6577 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 268 | 5190/6583 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @5188/6581 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 269 | 5194/6587 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @5192/6585 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 270 | 5198/6591 | xmx_rec_quant_window | 1267 | 33728x64 | xmx_rec_gemm_int8_residual @5196/6589 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 271 | 5204/6597 | xmx_rec_quant | 1277 | 33728x64 | xmx_rec_window_attention @5202/6595 | - | False | False | - | - | 0 | c-fused-block-producer |
| 272 | 5208/6601 | xmx_rec_quant | 1297 | 32640x64 | xmx_rec_gemm_window_int8_residual @5206/6599 | 32640 x 64 | True | True | 1 | no | 1 | a1-single-run |
| 273 | 5212/6605 | xmx_rec_quant | 1274 | 32640x256 | xmx_rec_gemm_int8_batched @5210/6603 | 32640 x 256 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 274 | 5216/6609 | xmx_rec_quant | 1275 | 32640x64 | xmx_rec_gemm_int8_batched @5214/6607 | 32640 x 64 | True | True | 2 | no | 0 | a2-row-spans-groups |
| 275 | 5220/6613 | xmx_rec_quant_window | 1267 | 34560x64 | xmx_rec_gemm_int8_residual @5218/6611 | 32640 x 64 | True | True | 1 | yes | 1 | a3-gather-scatter-view |
| 276 | 5226/6619 | xmx_rec_quant | 1277 | 34560x64 | xmx_rec_window_attention @5224/6617 | - | False | False | - | - | 0 | c-fused-block-producer |

### 2b. class counts (all 276 quant-class ops in the frame)
* `a1-single-run`: 72
* `a2-row-spans-groups`: 88
* `a3-gather-scatter-view`: 52
* `c-elementwise-producer`: 4
* `c-fused-block-producer`: 60
* **(a) row-aligned -- knife B legal in principle: 212**
* **(b) shape/view misaligned: 0**
* **(c) src not written by a gemm-family store: 64**

### 2c. the classes b and c, grouped by the actual parameter combination

| count | quant op (M x K) | producer op + params | class | what breaks | example plan lines |
|---|---|---|---|---|---|
| 16 | xmx_rec_quant 2560x256 | xmx_rec_window_attention batches=320 heads=8 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5582, 5601, 5620, 5639 |
| 8 | xmx_rec_quant 768x512 | xmx_rec_window_attention batches=192 heads=16 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5742, 5811, 5834, 5903 |
| 8 | xmx_rec_quant 960x512 | xmx_rec_window_attention batches=240 heads=16 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5765, 5788, 5857, 5880 |
| 8 | xmx_rec_quant 192x1024 | xmx_rec_global_attention rows=192 tokens=192 heads=32 | c-fused-block-producer | producer xmx_rec_global_attention writes libxmx_sycl.cpp:3263 merged = rows x heads*32 (composed from the two gated gemms) | 5929, 5947, 5965, 5983 |
| 6 | xmx_rec_quant 8640x128 | xmx_rec_window_attention batches=540 heads=4 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5450, 5516, 5538, 6441 |
| 6 | xmx_rec_quant 9216x128 | xmx_rec_window_attention batches=576 heads=4 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5472, 5494, 5560, 6419 |
| 2 | xmx_rec_quant 32640x64 | xmx_rec_window_attention batches=1020 heads=2 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5359, 6553 |
| 2 | xmx_rec_quant 35712x64 | xmx_rec_window_attention batches=1116 heads=2 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5381, 6575 |
| 2 | xmx_rec_quant 33728x64 | xmx_rec_window_attention batches=1054 heads=2 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5403, 6597 |
| 2 | xmx_rec_quant 34560x64 | xmx_rec_window_attention batches=1080 heads=2 merged=1 | c-fused-block-producer | producer xmx_rec_window_attention writes resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder | 5425, 6619 |
| 1 | xmx_rec_quant 640x512 | xmx_rec_unary kind=0x11115[epi=1 narrow=yes] n=327680 channels=512 batch=0 sa=32 sb=16 sc=0 k=0 | c-elementwise-producer | producer xmx_rec_unary writes libxmx_sycl.cpp:3391-3393 generic load/store over n elements, row length = channels | 6061 |
| 1 | xmx_rec_quant 2040x256 | xmx_rec_unary kind=0x11115[epi=1 narrow=yes] n=522240 channels=256 batch=0 sa=60 sb=32 sc=0 k=0 | c-elementwise-producer | producer xmx_rec_unary writes libxmx_sycl.cpp:3391-3393 generic load/store over n elements, row length = channels | 6247 |
| 1 | xmx_rec_quant 8160x128 | xmx_rec_unary kind=0x11115[epi=1 narrow=yes] n=1044480 channels=128 batch=0 sa=120 sb=60 sc=0 k=0 | c-elementwise-producer | producer xmx_rec_unary writes libxmx_sycl.cpp:3391-3393 generic load/store over n elements, row length = channels | 6401 |
| 1 | xmx_rec_quant 32640x64 | xmx_rec_unary kind=0x11115[epi=1 narrow=yes] n=2088960 channels=64 batch=0 sa=240 sb=120 sc=0 k=0 | c-elementwise-producer | producer xmx_rec_unary writes libxmx_sycl.cpp:3391-3393 generic load/store over n elements, row length = channels | 6535 |

### 2d. the (a) classes, grouped by shape

| count | class | quant op (M x K) | producer op + params | first plan lines |
|---|---|---|---|---|
| 8 | a2-row-spans-groups | xmx_rec_quant 32640x256 | xmx_rec_gemm_int8_batched M=32640 N=128 K=64 batch=2 sa=0 sb=8192 sc=128 lda=64 ldb=64 ldc=256 scale_stride=0 flags=0x1300[epi=3 narrow=yes] | 5342, 5367, 5389, 5411 |
| 12 | a2-row-spans-groups | xmx_rec_quant 8160x512 | xmx_rec_gemm_int8_batched M=8160 N=128 K=128 batch=4 sa=0 sb=16384 sc=128 lda=128 ldb=128 ldc=512 scale_stride=0 flags=0x1300[epi=3 narrow=yes] | 5436, 5458, 5480, 5502 |
| 16 | a2-row-spans-groups | xmx_rec_quant 640x2048 | xmx_rec_gemm M=640 N=256 K=64 batch=8 sa=64 sb=16384 sc=256 bt=0x1200[epi=2 narrow=yes] lda=512 ldb=0 ldc=2048 oa=0 ob=0 oc=0 | 5728, 5751, 5774, 5797 |
| 8 | a2-row-spans-groups | xmx_rec_quant 32640x64 | xmx_rec_gemm_int8_batched M=32640 N=32 K=128 batch=2 sa=128 sb=4096 sc=32 lda=256 ldb=128 ldc=64 scale_stride=0 flags=0x1100[epi=1 narrow=yes] | 5347, 5371, 5393, 5415 |
| 12 | a2-row-spans-groups | xmx_rec_quant 8160x128 | xmx_rec_gemm_int8_batched M=8160 N=32 K=128 batch=4 sa=128 sb=4096 sc=32 lda=512 ldb=128 ldc=128 scale_stride=0 flags=0x1100[epi=1 narrow=yes] | 5440, 5462, 5484, 5506 |
| 16 | a3-gather-scatter-view | xmx_rec_quant_window 2560x256 | xmx_rec_gemm_int8_residual M=2040 N=256 K=256 flags=0x41100[epi=1 narrow=yes] | 5576, 5595, 5614, 5633 |
| 16 | a2-row-spans-groups | xmx_rec_quant 2040x256 | xmx_rec_gemm M=2040 N=32 K=128 batch=8 sa=128 sb=4096 sc=32 bt=0x1100[epi=1 narrow=yes] lda=1024 ldb=0 ldc=256 oa=0 ob=0 oc=0 | 5572, 5591, 5610, 5629 |
| 6 | a3-gather-scatter-view | xmx_rec_quant_window 9216x128 | xmx_rec_gemm_int8_residual M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] | 5466, 5488, 5554, 6413 |
| 6 | a3-gather-scatter-view | xmx_rec_quant_window 8640x128 | xmx_rec_gemm_int8_residual M=8160 N=128 K=128 flags=0x41100[epi=1 narrow=yes] | 5444, 5510, 5532, 6435 |
| 8 | a1-single-run | xmx_rec_quant 192x4096 | xmx_rec_gemm_int8 M=192 N=4096 K=1024 flags=0x1300[epi=3 narrow=yes] | 5919, 5937, 5955, 5973 |
| 16 | a2-row-spans-groups | xmx_rec_quant 640x512 | xmx_rec_gemm_int8_batched M=640 N=64 K=256 batch=8 sa=256 sb=16384 sc=64 lda=2048 ldb=256 ldc=512 scale_stride=0 flags=0x1100[epi=1 narrow=yes] | 5732, 5755, 5778, 5801 |
| 2 | a3-gather-scatter-view | xmx_rec_quant_window 35712x64 | xmx_rec_gemm_int8_residual M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] | 5375, 6569 |
| 2 | a3-gather-scatter-view | xmx_rec_quant_window 34560x64 | xmx_rec_gemm_int8_residual M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] | 5419, 6613 |
| 2 | a3-gather-scatter-view | xmx_rec_quant_window 33728x64 | xmx_rec_gemm_int8_residual M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] | 5397, 6591 |
| 2 | a3-gather-scatter-view | xmx_rec_quant_window 32640x64 | xmx_rec_gemm_int8_residual M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] | 5351, 6547 |
| 2 | a1-single-run | xmx_rec_quant 32640x64 | xmx_rec_gemm_window_int8_residual M=32640 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=30 pad=0x0 | 5363, 6557 |
| 2 | a1-single-run | xmx_rec_quant 32640x64 | xmx_rec_gemm_window_int8_residual M=35712 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=31 pad=0x40004 | 5385, 6579 |
| 2 | a1-single-run | xmx_rec_quant 32640x64 | xmx_rec_gemm_window_int8_residual M=33728 N=64 K=64 flags=0x41100[epi=1 narrow=yes] h=136 w=240 across=31 pad=0x4 | 5407, 6601 |
| 8 | a3-gather-scatter-view | xmx_rec_quant_window 960x512 | xmx_rec_gemm_int8_residual M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] | 5759, 5782, 5851, 5874 |
| 8 | a3-gather-scatter-view | xmx_rec_quant_window 768x512 | xmx_rec_gemm_int8_residual M=640 N=512 K=512 flags=0x41100[epi=1 narrow=yes] | 5736, 5805, 5828, 5897 |
| 3 | a1-single-run | xmx_rec_quant 8160x128 | xmx_rec_gemm_window_int8_residual M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x0 | 5454, 5542, 6467 |
| 3 | a1-single-run | xmx_rec_quant 8160x128 | xmx_rec_gemm_window_int8_residual M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x4 | 5498, 6423, 6511 |
| 1 | a1-single-run | xmx_rec_quant 32640x64 | xmx_rec_gemm M=32640 N=64 K=32 batch=1 sa=1044480 sb=2048 sc=2088960 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 | 5337 |
| 2 | a1-single-run | xmx_rec_quant 8160x128 | xmx_rec_gemm_window_int8_residual M=9216 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=16 pad=0x40004 | 5476, 6489 |
| 2 | a1-single-run | xmx_rec_quant 8160x128 | xmx_rec_gemm_window_int8_residual M=8640 N=128 K=128 flags=0x41100[epi=1 narrow=yes] h=68 w=120 across=15 pad=0x40000 | 5520, 6445 |
| 4 | a1-single-run | xmx_rec_quant 2040x256 | xmx_rec_gemm_window_int8_residual M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x0 | 5586, 5662, 6266, 6342 |
| 4 | a1-single-run | xmx_rec_quant 2040x256 | xmx_rec_gemm_window_int8_residual M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40004 | 5605, 5681, 6285, 6361 |
| 4 | a1-single-run | xmx_rec_quant 2040x256 | xmx_rec_gemm_window_int8_residual M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x4 | 5624, 5700, 6304, 6380 |
| 8 | a1-single-run | xmx_rec_quant 192x1024 | xmx_rec_gemm_int8_residual M=192 N=1024 K=4096 flags=0x41100[epi=1 narrow=yes] | 5923, 5941, 5959, 5977 |
| 7 | a1-single-run | xmx_rec_quant 192x1024 | xmx_rec_gemm_int8_residual M=192 N=1024 K=1024 flags=0x41100[epi=1 narrow=yes] | 5933, 5951, 5969, 5987 |
| 4 | a1-single-run | xmx_rec_quant 640x512 | xmx_rec_gemm_window_int8_residual M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x0 | 5746, 5838, 6084, 6176 |
| 4 | a1-single-run | xmx_rec_quant 640x512 | xmx_rec_gemm_window_int8_residual M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x40004 | 5769, 5861, 6107, 6199 |
| 4 | a1-single-run | xmx_rec_quant 640x512 | xmx_rec_gemm_window_int8_residual M=960 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=5 pad=0x4 | 5792, 5884, 6130, 6222 |
| 1 | a1-single-run | xmx_rec_quant 8160x128 | xmx_rec_gemm M=8160 N=128 K=64 batch=1 sa=522240 sb=8192 sc=1044480 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 | 5432 |
| 2 | a1-single-run | xmx_rec_quant 2040x256 | xmx_rec_gemm_window_int8_residual M=2560 N=256 K=256 flags=0x41100[epi=1 narrow=yes] h=34 w=60 across=8 pad=0x40000 | 5643, 6323 |
| 2 | a1-single-run | xmx_rec_quant 640x512 | xmx_rec_gemm_window_int8_residual M=768 N=512 K=512 flags=0x41100[epi=1 narrow=yes] h=20 w=32 across=4 pad=0x40000 | 5815, 6153 |
| 1 | a1-single-run | xmx_rec_quant 2040x256 | xmx_rec_gemm M=2040 N=256 K=128 batch=1 sa=261120 sb=32768 sc=522240 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 | 5567 |
| 1 | a1-single-run | xmx_rec_quant 640x512 | xmx_rec_gemm M=640 N=512 K=256 batch=1 sa=163840 sb=131072 sc=327680 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 | 5723 |
| 1 | a1-single-run | xmx_rec_quant 192x1024 | xmx_rec_gemm M=192 N=1024 K=512 batch=1 sa=98304 sb=524288 sc=196608 bt=0x1100[epi=1 narrow=yes] lda=0 ldb=0 ldc=0 oa=0 ob=0 oc=0 | 5915 |

### 2e. worked examples (address arithmetic, rows 0/1/7/8 of each side)

**a1-single-run** -- quant at plan line 5337: `{ OP_XMX_REC_QUANT, 5, { 1270, 1272, 1273, 32640, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -1 },`
* producer xmx_rec_gemm @3940/5333: `{ OP_XMX_REC_GEMM, 17, { 1271, 1268, 1270, 32640, 64, 32, 1, 1044480, 2048, 2088960, 4352, 0, 0, 0, 0, 0, 0, 0 }, -1 },`
  * store map: libxmx_sycl.cpp:2304 gemm_b_pub_f16 / :2316-2327 publish -- out = oc + g*sc + r*ldc_e + col, ldc_e = ldc?ldc:N, narrow = bt&0x1000, epi = (bt>>8)&0xF, only r<M published (:2260)
  * producer rows (rows [0, 1, 7, 8]): [(0, [[0, 64]]), (1, [[64, 128]]), (7, [[448, 512]]), (8, [[512, 576]])]
  * quant rows (quantize_row_kernel.hpp:31/48, rows [0, 1, 7, 8]): [(0, [(0, 64)]), (1, [(64, 128)]), (7, [(448, 512)]), (8, [(512, 576)])]
  * merged producer rows: [(0, ((0, 64),)), (1, ((64, 128),)), (7, ((448, 512),)), (8, ((512, 576),))]

**a2-row-spans-groups** -- quant at plan line 5342: `{ OP_XMX_REC_QUANT, 5, { 1274, 1272, 1273, 32640, 256, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -1 },`
* producer xmx_rec_gemm_int8_batched @3947/5340: `{ OP_XMX_REC_GEMM_INT8_BATCHED, 17, { 1272, 83, 1274, 1273, 84, 32640, 128, 64, 2, 0, 8192, 128, 64, 64, 256, 0, 4864, 0 }, -1 },`
  * store map: libxmx_sycl.cpp:2670/2673 gemm_b_pub[_slm] / :2690-2692 publish -- out = g*sc + r*ldc_ + col, ldc_ = ldc?ldc:N
  * producer rows (rows [0, 1, 7, 8]): [(0, [[0, 128], [128, 256]]), (1, [[256, 384], [384, 512]]), (7, [[1792, 1920], [1920, 2048]]), (8, [[2048, 2176], [2176, 2304]])]
  * quant rows (quantize_row_kernel.hpp:31/48, rows [0, 1, 7, 8]): [(0, [(0, 256)]), (1, [(256, 512)]), (7, [(1792, 2048)]), (8, [(2048, 2304)])]
  * merged producer rows: [(0, ((0, 256),)), (1, ((256, 512),)), (7, ((1792, 2048),)), (8, ((2048, 2304),))]

**a3-gather-scatter-view** -- quant at plan line 5351: `{ OP_XMX_REC_QUANT_WINDOW, 9, { 1267, 1272, 1273, 32640, 64, 136, 240, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -1 },`
* producer xmx_rec_gemm_int8_residual @3956/5349: `{ OP_XMX_REC_GEMM_INT8_RESIDUAL, 11, { 1272, 77, 1267, 1273, 78, 1270, 73, 32640, 64, 64, 266496, 0, 0, 0, 0, 0, 0, 0 }, -1 },`
  * store map: libxmx_sycl.cpp:3084 gemm_b_res -- dense, row pitch N
  * producer rows (rows [0, 1, 7, 8]): [(0, [(0, 64)]), (1, [(64, 128)]), (7, [(448, 512)]), (8, [(512, 576)])]
  * quant rows (quantize_row_kernel.hpp:49-57, rows [0, 1, 7, 8]): [(0, [(0, 64)]), (1, [(64, 128)]), (7, [(448, 512)]), (8, [(15360, 15424)])]
  * merged producer rows: [(0, ((0, 64),)), (1, ((64, 128),)), (7, ((448, 512),)), (8, ((512, 576),))]
  * first divergence: pk row 8 reads address (15360, 15424), not (512, 576) -- the window map moved it (row contents still identical as a multiset, so the peak VALUE per row is unchanged; only where the fold must store it changes)

The quant's own read map is the one in `quantize_row_kernel.hpp` (:48 flat, :49-57 gathered); the producer's write map is the one its recorder body runs. If the two agree as multisets, folding the peak into the store cannot change any row's peak value -- which is exactly the premise knife B needs.

## 3. byte ledger

For an aligned pair, `m = M*K` elements. States, from the plan itself:

| state today | traffic today | traffic with knife B | removed |
|---|---|---|---|
| **split** -- the quant really runs (its consumer never took it) | producer f16 write 2m + quant f16 read 2m + pk write m + pk read m | pk write m + pk read m | **4m** |
| **dissolved** -- knife A already no-oped the quant, the consumer's `pack_a_fused` reads the f16 plane | f16 write 2m + f16 read 2m | pk write m + pk read m | **2m** |
| **plane-stays** -- the f16 plane has another live reader inside the frame (residual skip etc.), so the f16 write cannot vanish | as above | f16 write 2m + pk write m + pk read m | **2m** (split) / **0** (dissolved) |

Live-interval reader test: a reader of the src buffer between the producer's write and the buffer's next write inside the captured graph.

| class | state | pairs | bytes removed | ms @ nominal 560 | ms @ mixed roofs | ms @ 36% pub roof | ms @ 88% quant roof |
|---|---|---|---|---|---|---|---|
| a1-single-run | dissolved | 8 | 12582912 | 0.02 | 0.06 | 0.06 | 0.03 |
| a1-single-run | plane-stays | 64 | 71036928 | 0.13 | 0.14 | 0.35 | 0.14 |
| a2-row-spans-groups | dissolved | 52 | 85688320 | 0.15 | 0.43 | 0.43 | 0.17 |
| a2-row-spans-groups | split | 36 | 551813120 | 0.99 | 1.93 | 2.74 | 1.12 |
| a3-gather-scatter-view | plane-stays | 52 | 0 | 0.00 | 0.00 | 0.00 | 0.00 |
| **total** | | **212** | **721121280 B = 721.1 MB** | **1.29** | **2.56** | **3.58** | **1.46** |

Bandwidths used, spelled out: nominal 560 GB/s = 5.6e11 B/s; 36% of it = 2.016e+11 B/s; 88% of it = 4.928e+11 B/s. The mixed-roof column prices each leg separately: the f16 write leg at the pub roof, the read/pk legs at the quant roof.

### 3b. the same ledger for the surviving quants only (the 10.3 ms / 5.8 ms line)
* surviving quants: 80 (of 276)
* their own traffic: f16 read 354254848 B + pk/scale write 180177408 B = 534432256 B = 534.4 MB
  * 5.8 ms over 534.4 MB = 92.1 GB/s = 16% of the 560 GB/s nominal
  * 10.3 ms over 534.4 MB = 51.9 GB/s = 9% of the 560 GB/s nominal
* knife B on that subset removes 622850048 B = 622.9 MB (3.09 ms at the 36% roof, 1.26 ms at the 88% roof)

The two implied numbers above (16% / 9%) sit far under the 88% single-kernel roof: the surviving quant line is not pure-DRAM-bound at the plan's byte volume -- the launch count (80 ops) and the f16 read/write dependency chain carry part of it. Knife B removes both the bytes and the launches, so treat the ms figures below as the bandwidth-only floor.

## 4. why they are still standing: the existing guards, simulated on the plan

Mechanisms that can already dissolve a quant (all from `libxmx_sycl.cpp`):

| mechanism | call sites | guards | default |
|---|---|---|---|
| `qfuse_take` :349-363 | gemm_int8 :2369, gemm_int8_residual :3065, gemm_window_int8_residual :3208 | `g_quant_pk[a]` id hit, `sc == a_scale`, `M == M`, `K == K`; no adjacency limit, no pointer fallback | ON (`NR_Q_FUSE` unset = on, :304) |
| `qfuse_take_b` :382-416 | gemm_int8_batched :2453 | `scale_stride == 0` (:386), shared (`K_q == gemm K == lda, sa == 0`) or colslice (`K_q == lda, sa == gemm K`) (:402-403), `M` (:405), scale id or pointer alias (:406-408), adjacency <= 4 (:410) | **OFF** (`NR_Q_FUSE_B` unset, :384) |
| `qfuse_take_gather` :369-381 | gemm_int8_qkv :2753 | gather registration (:373), `sc == a_scale`, `M == M`, `K == channels` (:374), adjacency <= 4 (:375) | ON (`NR_QW_FUSE`, :2751) |
| v9b FOLD :5018-5041 | gemm_int8_batched :2443-2448 | in-place (`packed == source`, :5024), `cbuf == source`, adjacency 1 | **OFF** (`NR_V9B` :2438 and `NR_V9B_FOLD` :5019) |
| B6 :3203 | window_int8_residual | full 4-op pattern | **OFF** (`NR_B6`, :346) |

### 4a. result of the simulation on the captured graph
* dissolved today: **196**
* surviving (the quant kernel really launches every frame): **80**

### 4b. surviving quants, grouped by the guard that actually stopped the take

| count | quant op (M x K) | guard class | the real parameter combination | example plan lines |
|---|---|---|---|---|
| 16 | xmx_rec_quant 2040x256 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=256 gemmK=256 lda=256 sa=0 scale_stride=0 M_q=2040 M_g=2040 scale_q=1273 a_scale=1273 gap=2 -> shared=True colslice=False | 5567, 5586, 5605, 5624 |
| 16 | xmx_rec_quant 640x2048 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=2048 gemmK=256 lda=2048 sa=256 scale_stride=0 M_q=640 M_g=640 scale_q=1273 a_scale=1273 gap=2 -> shared=False colslice=True | 5728, 5751, 5774, 5797 |
| 12 | xmx_rec_quant 8160x128 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=128 gemmK=128 lda=128 sa=0 scale_stride=0 M_q=8160 M_g=8160 scale_q=1273 a_scale=1273 gap=2 -> shared=True colslice=False | 5432, 5454, 5476, 5498 |
| 12 | xmx_rec_quant 8160x512 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=512 gemmK=128 lda=512 sa=128 scale_stride=0 M_q=8160 M_g=8160 scale_q=1273 a_scale=1273 gap=2 -> shared=False colslice=True | 5436, 5458, 5480, 5502 |
| 8 | xmx_rec_quant 192x1024 | blocked: this take only accepts gather registrations (:373) -- the consumer is a QKV but the quant is a plain one | consumer xmx_rec_gemm_int8_qkv: channels=1024 K_q=1024 M_q=192 M_g=192 scale_q=1287 a_scale=1287 gap=2 | 5923, 5941, 5959, 5977 |
| 7 | xmx_rec_quant 32640x64 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=64 gemmK=64 lda=64 sa=0 scale_stride=0 M_q=32640 M_g=32640 scale_q=1273 a_scale=1273 gap=2 -> shared=True colslice=False | 5363, 5385, 5407, 6535 |
| 7 | xmx_rec_quant 32640x256 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=256 gemmK=128 lda=256 sa=128 scale_stride=0 M_q=32640 M_g=32640 scale_q=1273 a_scale=1273 gap=2 -> shared=False colslice=True | 5367, 5389, 5411, 6539 |
| 1 | xmx_rec_quant 32640x64 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=64 gemmK=64 lda=64 sa=0 scale_stride=0 M_q=32640 M_g=32640 scale_q=1273 a_scale=1273 gap=3 -> shared=True colslice=False | 5337 |
| 1 | xmx_rec_quant 32640x256 | PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385) | consumer xmx_rec_gemm_int8_batched: K_q=256 gemmK=128 lda=256 sa=128 scale_stride=0 M_q=32640 M_g=32640 scale_q=1273 a_scale=1273 gap=3 -> shared=False colslice=True | 5342 |

* **72 of the 80 survivors pass the shared/colslice shape guard outright** and are blocked only by the `NR_Q_FUSE_B` env gate on the whole batched take (libxmx_sycl.cpp:384-385). Concretely: batched consumers with `lda == K_q` and either `sa == 0, gemm K == K_q` (shared) or `sa == gemm K` (colslice), `scale_stride == 0`, `a_scale == scale id`, `M` equal, adjacency gap 2-3 (the guard allows <= 4).
* **8 of the 80 survivors are blocked by a mechanism/shape guard** (the QKV take only accepts gather-form registrations, :373 -- their quant is a plain one).

### 4c. the survivors, crossed with knife-B legality and whether the f16 write can vanish

| survivors | class | f16 write vanishes? | bytes knife B removes | write leg ms @36% roof | read/pk leg ms @88% roof |
|---|---|---|---|---|---|
| 36 | a2-row-spans-groups | yes | 551813120 (551.8 MB) | 1.37 | 0.56 |
| 41 | a1-single-run | no (another live reader of the plane) | 71036928 (71.0 MB) | 0.00 | 0.14 |
| 3 | c-elementwise-producer | no (another live reader of the plane) | 0 (0.0 MB) | 0.00 | 0.00 |
| **80** | | | **622850048 (622.9 MB)** | **1.37** | **0.70** |

### 4d. knife-B validity of the survivors (producer side, independent of those guards)
* class `a1-single-run`, producer `xmx_rec_gemm_window_int8_residual`: 30
* class `a2-row-spans-groups`, producer `xmx_rec_gemm_int8_batched`: 20
* class `a2-row-spans-groups`, producer `xmx_rec_gemm`: 16
* class `a1-single-run`, producer `xmx_rec_gemm_int8_residual`: 8
* class `a1-single-run`, producer `xmx_rec_gemm`: 3
* class `c-elementwise-producer`, producer `xmx_rec_unary`: 3

* survivors with a row-aligned producer (knife B applies): **77**
* survivors with a misaligned producer view (knife B needs a layout change first): 0
* survivors whose producer is not a gemm store at all (knife B is a no-op for them): 3

### 4e. the '160 surviving' count, checked against the plan
The plan contains 448 `xmx_rec_quant` + 104 `xmx_rec_quant_window` = 552 quant-class ops in TOTAL. They split 224/224 for xmx_rec_quant and 52/52 for xmx_rec_quant_window between the aborted recording (plan lines 3922..5294) and the captured graph (plan lines 5308..6643). The captured graph -- the thing that replays every frame -- holds 276 quant-class ops, 80 of which survive the takes. Counting BOTH recordings doubles it: 552 ops, 160 survivors, which is the shape of the '160 surviving' figure. The frame itself pays 80.

## 5. verdict

### 5a. ranked by op family (producer side of the pair)


| producer family | quants | a | b | c | surviving | foldable (a & surviving) | removable B | MB | ms mixed | ms @36% | ms @88% |
|---|---|---|---|---|---|---|---|---|---|---|---|
| xmx_rec_gemm_int8_batched | 56 | 56 | 0 | 0 | 20 | 20 | 536903680 | 536.9 | 1.98 | 2.66 | 1.09 |
| xmx_rec_gemm | 37 | 37 | 0 | 0 | 19 | 19 | 107909120 | 107.9 | 0.39 | 0.54 | 0.22 |
| xmx_rec_gemm_window_int8_residual | 44 | 44 | 0 | 0 | 30 | 30 | 60579840 | 60.6 | 0.12 | 0.30 | 0.12 |
| xmx_rec_gemm_int8 | 8 | 8 | 0 | 0 | 0 | 0 | 12582912 | 12.6 | 0.06 | 0.06 | 0.03 |
| xmx_rec_gemm_int8_residual | 67 | 67 | 0 | 0 | 8 | 8 | 3145728 | 3.1 | 0.01 | 0.02 | 0.01 |
| xmx_rec_window_attention | 52 | 0 | 0 | 52 | 0 | 0 | 0 | 0.0 | 0.00 | 0.00 | 0.00 |
| xmx_rec_global_attention | 8 | 0 | 0 | 8 | 0 | 0 | 0 | 0.0 | 0.00 | 0.00 | 0.00 |
| xmx_rec_unary | 4 | 0 | 0 | 4 | 3 | 0 | 0 | 0.0 | 0.00 | 0.00 | 0.00 |

### 5b. the one-sentence answer

* Knife B can legally cover **212 of the 276 quant-class ops in the frame** -- their row-peak sets are exactly their producer's stored row sets (72 single-run, 88 row-spans-groups, 52 gather/scatter view); **0 are shape/view-misaligned** and **64 have a producer that is not a gemm store at all** (fused attention/mega blocks, elementwise), for whom knife B has nothing to fold into.
* Of the class-a pairs, only **96** can drop the producer's f16 write at all -- the other **116** have another live reader of the same plane inside the frame (the residual `skip`), so the f16 write stays and knife B only swaps who writes the int8 plane (net 0 for the pairs knife A already dissolved, 71.0 MB for the rest).
* Expected frame-level saving if every class-a pair folds: **721.1 MB of DRAM traffic, 2.56 ms (mixed roofs) .. 3.58 ms (all at the 36% pub roof) .. 1.46 ms (all at the 88% quant roof); at the bare 560 GB/s nominal it is 1.29 ms**. Knife B also removes a launch: **77 of the class-a quants still launch today** (the other 135 were already no-oped by knife A), so the launch-side saving is 77, not 212. That alone does not take 66-70 ms below 45 ms; the batched wide-row family is the single biggest block.
* Biggest single block: **xmx_rec_gemm_int8_batched** -- 56 quants, 20 of them foldable-and-live, 536.9 MB, 1.98 ms mixed-roof.

### 5c. caveats the census can see but not settle
* `pk` and `scale` are the SAME scratch pair for 244 of the 276 frame quants, so a producer-side fold inherits the aliasing hazard the old fold tripped on (`libxmx_sycl.cpp:5026-5029`): the fold must keep the exact producer->quant adjacency the plan shows (measured above: gap min 2 / max 4).
* class a2 pairs need a row peak spanning several column groups inside one store tile (`88` pairs). The plan proves the row CONTENTS are right; whether the tile can hold the row (SLM) is a kernel question this census cannot answer.
* class a3 pairs need the pk/scale written at the quant's (gathered) row index, i.e. a scatter store in the epilogue: 52 pairs.
* class c pairs whose producer is a fused mega block (`window_attention`, `window_block`, `global_attention`) can only be folded inside that block's own store, which is a different piece of work: 60 pairs.
* the byte ledger counts DRAM legs only; the front-end cost of the 77 quant launches that knife B removes (the class-a pairs still launching today; the other 135 class-a quants are already no-ops) is not priced here.

### 5d. what this census says the cut should be, in order

1. **the wide-row pairs (class a2): 88 pairs, 36 of them still launching, 551.8 MB from those + 85.7 MB from the ones knife A already dissolved.** The producer stores the whole K-wide row but as several column groups -- groups-per-row distribution {2: 16, 4: 24, 8: 48} -- so the epilogue has to hold the row and take the peak across groups. Biggest byte block in the frame.
2. **the single-run pairs whose plane has no other live reader: 8 pairs** (of 72 a1 pairs) -- one contiguous run per row and the f16 write vanishes: 12.6 MB = 0.06 ms at the 36% pub roof, 0.03 ms at the 88% quant roof.
3. **class a1/a3 pairs whose plane is also a residual `skip` (116 pairs)**: the f16 write has to stay, so knife B degenerates to "move the int8 write into the producer" -- 71.0 MB, mostly the quant's read leg.
4. **the 8 survivors blocked by the QKV gather-only take** (`libxmx_sycl.cpp:373`): their producer is a plain int8 residual gemm and their consumer is a QKV -- a plain-take path for QKV would dissolve them without touching the producer at all: their standalone legs are 3.1 MB (f16 read) + 1.6 MB (pk+scale write).
5. **do not bother with the 64 class-c pairs** (fused attention/mega/elementwise producers) under knife B -- they need their own blade.

### 5e. reproduce

```
python -B E:\DSH\census\knifeB_census.py --md E:\DSH\census\knifeB_census.md
```
(stdlib only; reads the plan, nr_replay.c roles and libxmx_sycl.cpp by line, writes only the --md file.)
