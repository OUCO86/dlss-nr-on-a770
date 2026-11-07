# gates_known_red.md — **SUPERSEDED / 作废**（2026-11-07 09:1x）

**本文件的全部内容已被 [`tools/gates_caliber_notes.md`](gates_caliber_notes.md) 取代。**

一句话结论：**这里原来记的"两条已知红门"（`gate_window_block` 9 fails、`gate_gemm_f16_qkv_window` 5 fails）不成立 —— `caliber suspect — 未复现`。**
原因：产生那张表所用的仪器（旧版 `s6/run_gates_scratch.sh:22` 硬编码 `DSH_ONEAPI=E:/DSH/oneapi`）让门脚本 `os.chdir(E:/DSH/oneapi)` 后 `CDLL(./libxmx_sycl.dll)`，**门链一直在测加载槽实体件**，`cp` 进 `gs_<tag>\` 的变体从未被加载；修好仪器（`tools/dsh_run_gates.sh` 打 `[gate-selfcheck]` 两行、`RUNDIR` 可覆盖）后，**父级 09:0x 的复跑：旧槽 `A05A47AB` 与新槽 `F2364615` 在 staged/scratch 两种口径下这两门都 GREEN，现槽全链 40 GREEN / 0 RED**。**注意：子代理 08:4x 的复跑同一只旧槽在同一两门上读到 RED（两种口径都是）⇒ 这两门的红/绿目前是"读数不一致"的待复现项（候选：缓存态、`NR_*` 泄漏、CWD），不是件属性**——详见 `gates_caliber_notes.md` §3/§4。

另外两条当时混在"红门"里的现象现在有了正确归因：
- **`gate_graph` / `gate_skip_graph` 在任何 scratch 目录下必红（CWD 敏感门，军规 147）**，与件无关；
- **`gate_skip_graph` 在 staged 口径下 GREEN**，当时"按设计红"的说法只在 scratch 口径下成立。

**新口径与合格线（staged 40 GREEN / 0 RED）、两份成绩表、`6AEE1ADE` 的待复现项与两个候选成因、复现命令，全部在 [`gates_caliber_notes.md`](gates_caliber_notes.md)。**
旧文本可 `git log -p -- tools/gates_known_red.md` 取回（保留在历史里，不再作为认证依据）。
