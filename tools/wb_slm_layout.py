#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""wb_slm_layout.py -- WB(window_block) 两核的 SLM 账：复算 45,056B + 别名方案（军规 22：先算后改）

核： wbv4::launch_v4full  (src/bench/sycl/window_block_v4.hpp,  map @L20, slm_init<45056> @L35)
     wbv4ph::launch_v4ph  (src/bench/sycl/window_block_v4ph.hpp, map @L20, slm_init<45056> @L37)
两核同一张 map、同一个 45,056B 声明。SLM 只有这一片：两文件里没有任何非-SLM 的
local_accessor / range_local / 第二个 slm_init（已 grep 证实）。

用法：
  python tools/wb_slm_layout.py            # 复算(必须=45056) + 别名表 + 校验 + 发射 C++ 常量块
  python tools/wb_slm_layout.py --emit     # 只打 C++ 常量块
退出码：0 = 复算吻合且别名方案达标；2 = 复算不吻合（停下回报）。

方法（§36 的信用规矩：算术模型必须先复现已知数）：
  1) 从源码 regex 读现路 map 的基址 + 声明字节 => 逐字节复算 45,056；
  2) 把每块 SLM 的 (字节, 谁写, 谁读, 生命周期相区间) 列表化，按"相"求活跃并集 =>
     现路活跃并集峰值必须 == 45,056（没有闲置别名 = 现路就是全占用）；
  3) 别名方案 = 每 SG 一段 7,168B 槽 + 一片连续 4,096B 全局区 => 声明 32,768B；
     逐槽证明租户生命周期两两不相交，逐时刻证明活跃并集 <= 32,768。
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
SRC = {
    "v4full": os.path.join(REPO, "src", "bench", "sycl", "window_block_v4.hpp"),
    "v4ph":   os.path.join(REPO, "src", "bench", "sycl", "window_block_v4ph.hpp"),
}
CLIFF = 32768          # 占用崖（<= 驻留 2；§29 实测 36,928/驻1 = +184%）
CAP   = 65536          # A770 SLM 硬帽（§29：65,536 含、65,600 拒）
SG, LW = 4, 64         # 4 sub-groups x simd16

# ---------------------------------------------------------------- 1) 现路复算
def parse_current(path, use_git=False):
    """regex 读 map 行 + slm_init；use_git=True 时读 HEAD（补丁前）原文。"""
    import subprocess
    if use_git:
        rel = os.path.relpath(path, REPO).replace(os.sep, "/")
        s = subprocess.run(["git", "-C", REPO, "show", f"HEAD:{rel}"],
                           capture_output=True, text=True, encoding="utf-8").stdout
    else:
        s = open(path, encoding="utf-8", errors="replace").read()
    init = int(re.search(r"esimd::slm_init<(\d+)>", s).group(1))
    m = re.search(r"constexpr uint\s+S_AQO=(\d+),\s*S_QPO=(\d+),\s*S_KTO=(\d+),\s*"
                  r"S_VPO=(\d+),\s*S_ATO=(\d+),\s*S_PPO=(\d+),\s*S_SCR=(\d+);", s)
    if m:
        d = {k: int(v) for k, v in zip(("AQO","QPO","KTO","VPO","ATO","PPO","SCR"), m.groups())}
        return "v1", d, init
    m = re.search(r"constexpr uint\s+SG_STRIDE=(\d+)u,\s*SG_BASE=(\d+)u;", s)
    if m:
        return "v2", {"SG_STRIDE": int(m.group(1)), "SG_BASE": int(m.group(2))}, init
    raise SystemExit("map 行读不到：源码与脚本不匹配 => 停下回报")

# 现路：每块 (名字, 字节, 写相, 读相, 谁写谁读, 作用域)
# 相 = 程序序栅栏点（见 MOMENTS），别名只能在栅栏点之间成立。
CUR_BLOCKS = [
    ("AQO",      4096, "P0",   "PH1",    "P0 gather 写(A 面 e4m3) / PH1 tile8s A 侧读(本 SG)",  "SG-local"),
    ("QPO",      4096, "PH2_0","P3",     "PH2 part0 写(Q 面) / P3 hoist 读(本 SG)",             "SG-local"),
    ("KTO",      4096, "PH2_1","P3",     "PH2 part1 写(K 面) / P3 dpas B 侧读(跨 SG)",          "跨 SG 读"),
    ("VPO",      4096, "PH2_2","P5",     "PH2 part2 写(V 面) / P5 dpas B 侧读(跨 SG)",          "跨 SG 读"),
    ("ATO",      4096, "P6A",  "P6B",    "P6 头段 attended->ATO 写 / P6 dpas A 侧读(本 SG)",    "SG-local"),
    ("PPO/scrC", 8192, "PH1",  "PH2_2",  "PH1 part2 f32 累加面 scrC=S_PPO+sgid*2048",           "SG-local"),
    ("PPO/probs",8192, "P4",   "P5",     "P4 softmax 写 / P5 dpas A 侧读(本 SG)",               "SG-local"),
    ("SCR/scrA", 4096, "PH1",  "PH2_0",  "PH1 part0 f32 累加面 =S_SCR+sgid*4096",               "SG-local"),
    ("SCR/scrB", 4096, "PH1",  "PH2_1",  "PH1 part1 f32 累加面 =S_SCR+sgid*4096+2048",          "SG-local"),
    ("SCR/scores",16384,"P3",  "P4",     "P3 写 f32 16x64/SG / P4 读(同区) =S_SCR+sgid*4096",   "SG-local"),
    ("SCR/att",  16384, "P5",  "P6A",    "P5 store16s 写 attended / P6 读(同区)",               "SG-local"),
    ("SCR/proj", 16384, "P6B", "P7",     "P6 store16s 写 proj / P7 读(同区)",                   "SG-local"),
    ("SCR/headA",16384, "P7",  "P7",     "v4ph head: hbase=scr+2048 pa16 打包 + tile8s 读",     "SG-local"),
]
MOMENTS = ["P0","PH1","PH2_0","PH2_1","PH2_2","P3","P4","P5","P6A","P6B","P7"]
MI = {m: i for i, m in enumerate(MOMENTS)}

def live_union(blocks):
    """按相求活跃并集（同区不同用途只算一次字节）。"""
    out = []
    for k, m in enumerate(MOMENTS):
        act = {}
        for (nm, b, w, r, who, sc) in blocks:
            if MI[w] <= k <= MI[r]:
                reg = nm.split("/")[0]
                act[reg] = max(act.get(reg, 0), b)
        out.append((m, sum(act.values()), sorted(act)))
    return out

# ---------------------------------------------------------------- 3) 别名方案
# 每 SG 一段 SG_STRIDE=7,168B（基址 4096 + sgid*7168），外加一片连续 4,096B 全局区给 VPO。
# VPO 必须连续：P5 的 wbv3::tile8ss 里 B 侧步长写死 = kc*(tc_n*2*256) = 1024，不许改 helper。
# 每槽 = (槽名, 槽内偏移/SG, 字节/SG, [(租户, 写相, 读相, 不相交理由)])
ARENA = 7168
GVPO  = 4096
SLOTS = [
    ("S0",    0,    2048, [
        ("accA",  "PH1",  "PH2_0", "part0 的 f32 累加面（16 行 x 32 f32 = 2048B/SG）"),
        ("QPO",   "PH2_0","P3",  "accA 的 f32 行在 PH2_0 被本 SG 读完(:115)后，part0 才写 QPO 进前 1KB；数据依赖链 hv->hr->qv->oh->store，不可倒序"),
        ("PROBS", "P4",   "P5",  "PROBS 与 accA/QPO 不同相：accA 死于 PH2_0，QPO 死于 P3 hoist"),
    ]),
    ("S1",    2048, 2048, [
        ("accB",   "PH1", "PH2_1", "part1 的 f32 累加面（含 blade-7 的行暂存=本槽前 1KB）"),
        ("SCORES", "P3",  "P4",    "accB 死于 PH2_1（:124/:178/:193 栅栏），P3 才写 scores"),
        ("ATT",    "P5",  "P6A",   "scores 死于 P4（:310 栅栏）"),
        ("PROJ",   "P6B", "P7",    "attended 在 P6A 被本 SG 读完(:338)，:344 栅栏后 :348 才写 proj（=今天同区复用的老规矩）"),
    ]),
    ("S2",    4096, 2048, [
        ("accC",   "PH1", "PH2_2", "part2 的 f32 累加面（行暂存=本槽前 1KB）"),
        ("SCORES", "P3",  "P4",    "accC 死于 PH2_2"),
        ("ATO",    "P6A", "P6B",   "scores 死于 P4；ATO 只被本 SG 写/读（tile8s A 侧 = sbase+S_ATO）"),
        ("HEAD-A", "P7",  "P7",    "v4ph head：hbase=scr+2048（scr=proj 基）；:389 栅栏保证本 SG 读完 proj 才打包"),
    ]),
    ("S3",    6144, 1024, [
        ("AQO",  "P0",   "PH1",  "P0 写 A 面 / PH1 tile8s A 侧读本 SG 的 1KB"),
        ("KTO",  "PH2_1","P3",   "AQO 死于 PH1（:110 栅栏），PH2_1 才写 KTO；P3 读它、P3 的 scores 写在 S1+S2 不碰这里"),
    ]),
]
NEW_DECL = ARENA*SG + GVPO

# 跨 SG 读的租户：别的 SG 会在它的生命周期内读这块字节。
# 规矩：若同槽里另一个租户在**更晚的相**写这块，两者之间必须有 **group_barrier**（WG 级），
# 只有 esimd::barrier()（SG 级）不算 —— 快 SG 会覆盖慢 SG 还没读完的数据。
XSG_READ = {"KTO": "P3", "VPO": "P5"}          # 名字 -> 最后一次跨 SG 读的相
GROUP_BARRIERS = [("PH2_2", "P3")]             # 全核唯一的 group_barrier（v4.hpp:208 / v4ph.hpp:202）
LOCAL_ONLY_SLOTS = set()                       # 只有本 SG 读写的槽（无）

def group_barrier_between(read_phase, write_phase):
    """存在一个 WG 级栅栏 (u,v)：u >= read_phase 且 v <= write_phase（写在栅栏之后才安全）。"""
    return any(MI[u] >= MI[read_phase] and MI[v] <= MI[write_phase]
               for (u, v) in GROUP_BARRIERS)


# 同相"交接"白名单：同一相内先读后写、且写者的数据来自该读（不可倒序）=> 允许共址。
HANDOFF = {
    ("QPO", "accA"): "PH2_0 part0: :115 读本 SG 的 accA f32 行 -> :158-167 epilogue -> 写 QPO 进 accA 前 1KB；"
                     "写者的值就是这条读的派生值，编译器不可能把它排到读之前（无跨 SG：accA/QPO 都是本 SG 私有）",
}

def check_alias():
    """逐槽：租户生命周期两两不相交（同相交接需白名单）；逐时刻：活跃并集 <= 声明。"""
    errs = []
    for (nm, off, size, tenants) in SLOTS:
        iv = [(t[1], t[2], t[0]) for t in tenants]
        for i in range(len(iv)):
            for j in range(i+1, len(iv)):
                a, b = iv[i], iv[j]
                if not (MI[a[1]] < MI[b[0]] or MI[b[1]] < MI[a[0]]):
                    pair = tuple(sorted((a[2], b[2])))
                    if pair in HANDOFF:
                        continue
                    errs.append(f"槽 {nm} 内 {a[2]}[{a[0]}..{a[1]}] 与 {b[2]}[{b[0]}..{b[1]}] 相区间重叠")
    # VPO 与槽内租户的冲突：VPO 活 PH2_2..P5，但它在全局区，不与任何槽共址 => 只需总量核对
    # 跨 SG 读 vs 同槽晚写：必须有 WG 级栅栏，否则快 SG 会覆盖慢 SG 未读完的数据
    for (nm, off, size, tenants) in SLOTS:
        for a in tenants:
            if a[0] not in XSG_READ: continue
            for b in tenants:
                if b[0] == a[0] or MI[b[1]] <= MI[XSG_READ[a[0]]]: continue
                if not group_barrier_between(XSG_READ[a[0]], b[1]):
                    errs.append(f"竞态：槽 {nm} 里 {a[0]} 被跨 SG 读到 {XSG_READ[a[0]]}，"
                                f"而 {b[0]} 在 {b[1]} 写同一槽（其间没有 group_barrier）")
    curve = []
    for k, m in enumerate(MOMENTS):
        per_sg = 0
        for (_, _, size, tenants) in SLOTS:
            if any(MI[t[2]] >= k >= MI[t[1]] for t in tenants):
                per_sg += size
        vpo = GVPO if MI["PH2_2"] <= k <= MI["P5"] else 0
        curve.append((m, per_sg*SG + vpo))
    peak = max(c[1] for c in curve)
    if NEW_DECL > CLIFF:  errs.append(f"新声明 {NEW_DECL} 未进崖 (<= {CLIFF})")
    if NEW_DECL > CAP:    errs.append(f"新声明 {NEW_DECL} 超帽")
    if peak > NEW_DECL:   errs.append(f"活跃并集峰值 {peak} > 声明 {NEW_DECL}")
    if ARENA*SG + GVPO != NEW_DECL: errs.append("算术不闭合")
    return errs, curve, peak

# ---------------------------------------------------------------- 发射
def emit_cpp():
    return r"""
// ===== SLM map v2 (wb_slm 驻留刀): 45,056B -> 32,768B =====
// 一片 SLM：0..4095 = VPO(全局连续 4096B，P5 的 tile8ss B 侧步长写死，不许拆)
//            4096 + sgid*7168 = 每 sub-group 自己的 7,168B 槽（4 段）
//   S0 = sg+0    (2048): QPO(PH2_0..P3) / PROBS(P4..P5)
//   S1 = sg+2048 (2048): accB(PH1..PH2_1) / SCORES(P3..P4) / ATT(P5..P6A) / PROJ(P6B..P7)
//   S2 = sg+4096 (2048): accC(PH1..PH2_2) / SCORES(P3..P4) / HEAD-A(v4ph P7 head)
//   S3 = sg+6144 (1024): AQO(P0..PH1) / KTO(PH2_1..P3) / ATO(P6A..P6B)
// 每段内部只在栅栏点换租户；单位一律「字节」，*2 只出现在 half-index->byte 的那一处。
constexpr uint SG_STRIDE = 7168u;      // 4x2048(=2KB acc) + 2048 + 2048 + 1024
constexpr uint S_VPO   = 0u;           // 连续 4096B 全局区（V 面）
constexpr uint S_AQO   = 6144u;        // 以下都是「每 SG 槽内偏移」
constexpr uint S_KTO   = 6144u;        // 别名 AQO 槽（AQO 死于 PH1）
constexpr uint S_ATO   = 6144u;        // 别名 KTO/AQO 槽（KTO 死于 P3）
constexpr uint S_QPO   = 0u;           // accA 的前 1KB（accA 死于 PH2_0 的本 SG 读）
constexpr uint S_ACCA  = 0u;           // 2048B
constexpr uint S_ACCB  = 2048u;        // 2048B
constexpr uint S_ACCC  = 4096u;        // 2048B
constexpr uint S_PROBS = 0u;           // PROBS = 2048B 连续（QPO 死于 P3）
constexpr uint S_SCORES= 2048u;        // SCORES = 4096B 连续 = S1+S2
constexpr uint S_ATT   = 2048u;
constexpr uint S_PROJ  = 2048u;
constexpr uint S_HEADA = 4096u;        // = S_PROJ + 2048（今天的 scr+2048，表达式不动）
constexpr uint SG_BASE = 4096u;        // SG 槽区起点（0..4095 = VPO）
constexpr uint SLM_BYTES = SG_BASE + SG_STRIDE*4u;   // = 32,768
static_assert(SLM_BYTES == 32768u, "wb_slm: 驻留刀必须落在 32KB 崖内(<=32768)");
static_assert(S_AQO == 6144u && SG_STRIDE == 7168u, "wb_slm: 槽布局变了就停下重算");
static_assert(S_SCORES + 4096u <= SG_STRIDE, "wb_slm: SCORES 必须整段落在 SG 槽内");
static_assert(S_PROBS + 2048u <= SG_STRIDE, "wb_slm: PROBS 必须整段落在 SG 槽内");
static_assert(S_KTO + 1024u <= SG_STRIDE && S_ATO + 1024u <= SG_STRIDE, "wb_slm: KTO/ATO 槽");
static_assert(S_HEADA + 1024u <= SG_STRIDE, "wb_slm: HEAD-A 槽");
"""

def main():
    emit = "--emit" in sys.argv
    if emit:
        print(emit_cpp()); return 0
    ok = True
    print("== 1) 现路复算（BEFORE 从 git HEAD 读，AFTER 从工作树读）==")
    for tag, path in SRC.items():
        ends = {"AQO":4096,"QPO":4096,"KTO":4096,"VPO":4096,"ATO":4096,"PPO":8192,"SCR":16384}
        form, bases, decl = parse_current(path, use_git=True)
        if form == "v1":
            span = max(bases[k] + ends[k] for k in bases)
        else:
            span = bases["SG_BASE"] + bases["SG_STRIDE"]*SG
        print(f"  BEFORE {tag:7s} ({form}) 末端={span}  slm_init<{decl}>  => "
              f"{'吻合 45,056' if span == decl == 45056 else '不吻合'}")
        if not (span == decl == 45056): ok = False
        form2, bases2, decl2 = parse_current(path)
        if form2 == "v2":
            span2 = bases2["SG_BASE"] + bases2["SG_STRIDE"]*SG
            print(f"  AFTER  {tag:7s} (v2) stride={bases2['SG_STRIDE']} base={bases2['SG_BASE']} "
                  f"末端={span2}  slm_init<{decl2}>  => "
                  f"{'吻合' if span2 == decl2 == NEW_DECL else '不吻合'}")
            if not (span2 == decl2 == NEW_DECL): ok = False
        else:
            print(f"  AFTER  {tag:7s} 工作树仍是 v1（未打补丁）")
    print("\n== 2) 现路逐块账（谁写谁读 + 生命周期）==")
    for (nm, b, w, r, who, sc) in CUR_BLOCKS:
        print(f"  {nm:11s} {b:6d}B  活 {w:6s}..{r:6s}  {sc:9s}  {who}")
    print("\n== 3) 现路按相活跃并集（现路只别名了一处：scrC->PPO）==")
    for (m, tot, regs) in live_union(CUR_BLOCKS):
        print(f"  {m:6s} {tot:6d}B  {','.join(regs)}")
    curve_cur = live_union(CUR_BLOCKS)
    peak_cur = max(t for _, t, _ in curve_cur)
    print(f"  现路声明 45,056B / 活跃并集峰值 {peak_cur}B => 闲置可挖 {45056-peak_cur}B"
          f"  {'(复算吻合)' if peak_cur == 28672 else '(注意：与预期 28,672 不符，查表)'}")

    errs, curve, peak_new = check_alias()
    print(f"\n== 4) 别名方案：每 SG 槽 {ARENA}B x {SG} + 连续 VPO {GVPO}B = {NEW_DECL}B（省 {45056-NEW_DECL}B）==")
    for (nm, off, size, tenants) in SLOTS:
        print(f"  槽 {nm} = sg+{off:5d} ({size}B)")
        for t in tenants:
            print(f"      {t[0]:7s} 活 {t[1]:6s}..{t[2]:6s}   {t[3]}")
    print("  全局区 VPO = 0..4095  活 PH2_2..P5（tile8ss 的 B 侧步长写死 => 必须连续）")
    print("\n== 5) 别名后逐相活跃并集（必须 <= 32,768）==")
    for (m, tot) in curve:
        print(f"  {m:6s} {tot:6d}B {'OK' if tot <= CLIFF else 'OVER-CLIFF'}")
    print(f"  峰值 {peak_new}B  声明 {NEW_DECL}B  驻留 = {CAP // NEW_DECL}（现路 {CAP // 45056}）")
    if errs:
        print("\n!! 校验失败:"); [print("   -", e) for e in errs]; ok = False
    else:
        print("\n校验：槽内租户相区间两两不相交 OK；并集 <= 声明 OK；进崖 OK")
    print("\n== 6) 为什么不能再低（结构地板）==")
    print(f"  PH1 同时活：accA+accB+accC = 3x2048/SG + AQO 1024/SG = {3*2048+1024}B/SG "
          f"=> 槽 >= {ARENA}B/SG；VPO 要连续 4096B 且活 PH2_2..P5（与 scores/PROBS 同窗）")
    print(f"  => 地板 = 4*{ARENA} + {GVPO} = {4*ARENA+GVPO}B = 正好贴崖（§36 att 相同的情形）")
    print("\n结论:", "复算与别名方案全部通过" if ok else "复算/校验未过 => 停下回报")
    return 0 if ok else 2

if __name__ == "__main__":
    sys.exit(main())
