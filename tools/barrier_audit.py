#!/usr/bin/env python
# -*- coding: utf-8 -*-
r"""barrier_audit.py -- 栅栏审计铲：静态租户分析 + 军规 30 竞态判据 + 反证（仪器必须有牙）

背景：§41 回退 + §35 的 1/158 非确定红 + §36 主动换 group_barrier，三条线索都指向
"跨 SG 读 + 只有 SG 级 esimd::barrier" 的潜在竞态。本工具把军规 30 做成可复跑的检查器：

  军规 30：槽/面合法 = 生命周期不相交 + 跨 SG 读的租户与更晚写者之间必须有 WG 级栅栏。
  军规 31：确定性门 = 最终件 >=4 独立进程 distinct md5（本铲提高到 8）。
  军规 32：竞态签名 = diff 占比 ~78% + x/y 全域平坦 + mod 8 均匀（数值改动通常稀疏/局部）。

判据（race_regions）：对每个区域(region=同一地址槽/面)里的租户：
  (a) 交接 handoff：一个被跨 SG 读的租户 a，它自己的写者(别的 SG)到它的读之间必须有 WG 级栅栏，
      否则快 SG 读到慢 SG 尚未可见/未写的值 => RACE_HANDOFF。
  (b) 复用 reuse：a 被跨 SG 读到 ra 之后，同区域里若有更晚的写者 b 在 wb>ra 写这块，
      ra..wb 之间必须有 WG 级栅栏，否则快 SG 的 b 覆盖慢 SG 未读完的 a => RACE_REUSE（=§40/§41 的形态）。
  esimd::barrier()/SG 级不算 WG 级；只有 group_barrier(gr)/nd_item::barrier(local_space)/fence(CTA) 算。

用法：
  python tools/barrier_audit.py                 # 跑反证 + 审 6 个热核 + 打 CSV + 打印表
  python tools/barrier_audit.py --emit-csv PATH # 另存 CSV（默认 E:\DSH\s6\barrier_audit.csv）
退出码：0 = 反证两例通过（仪器有牙）；4 = 仪器无牙（停下，别拿它出结论）。
"""
import os, re, sys, csv, importlib.util

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
# BARRIER_SRC：审另一棵树（例如候选件所在的 worktree）的同名源码；默认 = 本仓。
SRC  = os.environ.get("BARRIER_SRC") or os.path.join(REPO, "src", "bench", "sycl")
SGW  = 16   # 出货 ESIMD 核的 sub-group 宽度：window_block_v4.hpp:38 自己写死 sgid=lid>>4 => 16 lane/SG

# ------------------------------------------------------------------ WG/SG 栅栏自动抽取
SG_PAT = re.compile(r"esimd::barrier\s*\(")
WG_PAT = re.compile(r"group_barrier\s*\(|\.barrier\s*\(\s*sycl::access::fence_space::local_space|single_barrier|fence\(.*CTA")
# §43-B 硬化开关：s6_ffn_block_kernel.hpp 里 12 处交接栅栏走 S6_BAR() 宏
#   （DM_BAR=0 -> esimd::barrier() = SG；DM_BAR=1 -> group_barrier(it.get_group()) = WG）。
S6BAR_PAT = re.compile(r"\bS6_BAR\s*\(")
def extract_barriers(path, s6bar="sg"):
    """扫源码，返回 [(line, 'WG'|'SG')]。WG=group_barrier/nd_item local barrier；SG=esimd::barrier。
       s6bar: 'sg' = 按 DM_BAR=0 读 S6_BAR()（SG 级）；'cta' = 按 DM_BAR=1 读（真 CTA 栅栏）。
       预处理行（#define/#if/#else）里的 group_barrier 字样不是调用点，必须跳过，否则假 OK。"""
    out = []
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            for i, line in enumerate(f, 1):
                code = line.split("//", 1)[0]   # 去行尾注释，避免注释里提到 barrier 误报
                if code.lstrip().startswith("#"):   # 预处理行：不是调用点
                    continue
                if S6BAR_PAT.search(code):
                    out.append((i, "WG" if s6bar == "cta" else "SG"))
                elif WG_PAT.search(code):   out.append((i, "WG"))
                elif SG_PAT.search(code): out.append((i, "SG"))
    except FileNotFoundError:
        pass
    return out

# landmark 按锚点正则在真实文件里定位（硬化铲在 hpp 顶部加了宏块 => 行号整体平移，
# 硬编码行号会错位 => §43 修过的"合成 landmark vs 真实栅栏线"假 RACE 会复发）
LM_ANCHORS = {
    "s6_ffn_block_kernel.hpp": [
        ("P1",  r"// ---- P1:"),
        ("P2",  r"// ---- P2:"),
        ("P3",  r"// ---- P3:"),
        ("P4a", r"// ---- P4:"),
        ("P4b", r"all PKH reads done"),
        ("P5q", r"// ---- P5q"),
        ("P6a", r"// ---- P6:"),
        ("P6b", r"uint32_t slot = S::O_STG \+ \(\("),
    ],
}
def resolve_landmarks(path, fallback):
    """返回按真实行号定位的 landmarks（升序）。任何锚点缺失或顺序不单调 => 退回硬编码并告警。"""
    anchors = LM_ANCHORS.get(os.path.basename(path))
    if not anchors:
        return fallback, "hardcoded"
    try:
        lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    except FileNotFoundError:
        return fallback, "hardcoded(missing file)"
    lm, want = [], {p: rx for p, rx in anchors}
    for ph, rx in anchors:
        pat = re.compile(rx)
        hits = [i for i, ln in enumerate(lines, 1) if pat.search(ln)]
        if len(hits) != 1:
            print(f"  !! landmark {ph} 在 {os.path.basename(path)} 命中 {len(hits)} 次 => 退回硬编码行号")
            return fallback, "hardcoded(anchor not unique)"
        lm.append((ph, hits[0]))
    if [l for _, l in lm] != sorted(l for _, l in lm):
        print(f"  !! landmark 顺序不单调 => 退回硬编码行号")
        return fallback, "hardcoded(unordered)"
    return lm, "auto"

def phase_of(line, landmarks):
    """landmarks=[(phase, start_line),...] 升序；返回包含 line 的相（最后一个 start<=line）。"""
    cur = landmarks[0][0]
    for ph, st in landmarks:
        if st <= line: cur = ph
        else: break
    return cur

def wg_barriers_between(landmarks, barriers, p_lo, p_hi):
    """是否存在 WG 栅栏，其相 u>=p_lo 且 v<=p_hi（写在栅栏之后才安全）。相邻相 u==v==该相。"""
    order = [ph for ph, _ in landmarks]
    MI = {ph: i for i, ph in enumerate(order)}
    lo, hi = MI[p_lo], MI[p_hi]
    for (ln, kind) in barriers:
        if kind != "WG": continue
        ph = phase_of(ln, landmarks)
        # WG 栅栏把 [<=ph] 与 [>=ph] 分隔：对 (p_lo,p_hi) 成立 <=> ph 落在 (p_lo..p_hi] 且能盖住边界
        if MI[ph] >= lo and MI[ph] <= hi:
            return True
    return False

# ------------------------------------------------------------------ 通用竞态引擎（军规 30）
def race_regions(landmarks, regions, xsg_read, barriers):
    """regions=[{name, tenants:[(tenant, wphase, rphase)], note}] ; xsg_read={tenant: last_xsg_read_phase}.
       返回错误列表；空 = 该核无跨 SG 竞态（就这两道判据而言）。
       barriers 只取落在本核 landmark 行区间内的（多核文件不串味）。"""
    errs = []
    lo_line = landmarks[0][1]
    hi_line = landmarks[-1][1] + 100000
    barriers = [(ln, k) for (ln, k) in barriers if lo_line <= ln <= hi_line]
    for reg in regions:
        comm = reg.get("commutative", False)   # 归约可交换可结合(float max/sum) => 可见性风险非顺序风险
        sev = "NEEDS-HUMAN" if comm else "RACE"
        for a in reg["tenants"]:
            nm, wa, ra0 = a
            if nm not in xsg_read: continue
            ra = xsg_read[nm]
            # (a) handoff：本租户的写(别的 SG) -> 跨 SG 读，之间要 WG 栅栏
            if wa != ra and not wg_barriers_between(landmarks, barriers, wa, ra):
                errs.append(f"[{sev}][HANDOFF] region {reg['name']}: {nm} 被跨 SG 读于 {ra}，"
                            f"但其写({wa})与读之间没有 WG 级栅栏（只有 SG 级 esimd::barrier）")
            # (b) reuse：更晚写者 b 在同区域覆盖
            for b in reg["tenants"]:
                bn, wb, rb0 = b
                if bn == nm: continue
                if not (MI_of(landmarks, wb) > MI_of(landmarks, ra)): continue
                if not wg_barriers_between(landmarks, barriers, ra, wb):
                    errs.append(f"[{sev}][REUSE] region {reg['name']}: {nm} 跨 SG 读到 {ra}，"
                                f"更晚 {bn} 在 {wb} 写同一区域，{ra}..{wb} 之间没有 WG 级栅栏")
    return errs

def MI_of(landmarks, ph):
    return {p: i for i, (p, _) in enumerate(landmarks)}[ph]

# ------------------------------------------------------------------ 反证：复用 §40 已证模型（仪器必须有牙）
def load_wb_layout():
    spec = importlib.util.spec_from_file_location("wb_slm_layout",
                                                 os.path.join(HERE, "wb_slm_layout.py"))
    L = importlib.util.module_from_spec(spec); spec.loader.exec_module(L)
    return L

def wb_to_regions(L):
    """把 §40 的 SLOTS 转成 race_regions 的 regions（每槽=一个 region）。"""
    regions = []
    for (nm, off, size, tenants) in L.SLOTS:
        regions.append({"name": nm,
                        "tenants": [(t[0], t[1], t[2]) for t in tenants],
                        "note": f"off={off} size={size}"})
    # VPO 是独立连续全局区（不与槽共址）=> 单列 region
    regions.append({"name": "VPO(global)", "tenants": [("VPO", "PH2_2", "P5")], "note": "0..4095 连续"})
    return regions

# window_block_v4.hpp 的相 -> 真实源码行 landmark（teeth 与 wb_model 共用，保证一致）
WBLM = [("P0",36),("PH1",64),("PH2_0",124),("PH2_1",178),("PH2_2",190),("P3",210),
        ("P4",310),("P5",324),("P6A",338),("P6B",344),("P7",350)]

def teeth_test():
    L = load_wb_layout()
    # 用真实源码抽取核对：window_block_v4.hpp 全核唯一 group_barrier 在 :208（落在 PH2_2..P3 之间）。
    # landmarks 用真实行号（WBLM），barriers 用真实抽取线 => 二者一致，phase_of 不会错映射。
    real_b = extract_barriers(os.path.join(SRC, "window_block_v4.hpp"))
    wg_real = [ln for (ln, k) in real_b if k == "WG"]
    lm = WBLM
    barriers = real_b
    xsg = dict(L.XSG_READ)
    regions = wb_to_regions(L)
    pos = race_regions(lm, regions, xsg, barriers)
    pos_race = any("REUSE" in e or "HANDOFF" in e for e in pos)

    # 反证：把 ATO 搬回 S3（就是 §40 那版 1301 全帧 MISMATCH）=> 必须报 RACE
    for s in L.SLOTS:
        if s[0] == "S2": s[3][:] = [t for t in s[3] if t[0] != "ATO"]
        if s[0] == "S3": s[3].append(("ATO", "P6A", "P6B", "(故意放错)"))
    regions_neg = wb_to_regions(L)
    neg = race_regions(lm, regions_neg, xsg, barriers)
    neg_race = any("REUSE" in e or "HANDOFF" in e for e in neg)

    print("== 反证（仪器必须有牙）==")
    print(f"  window_block_v4.hpp 源码抽取: WG 栅栏 {len(wg_real)} 条 @ {wg_real} ; SG 栅栏 {len(real_b)-len(wg_real)} 条")
    print(f"  修好的 S2 版   -> {'RACE(错!)' if pos_race else 'NO-RACE'}   {'PASS' if not pos_race else 'FAIL'}")
    print(f"  故意 ATO->S3  -> {'RACE' if neg_race else 'NO-RACE(仪器无牙!)'}   {'PASS' if neg_race else 'FAIL'}")
    for e in neg: print("     -", e)
    teeth_ok = (not pos_race) and neg_race
    print(f"  牙齿判定: {'有牙 PASS' if teeth_ok else '无牙 FAIL => 别拿它出结论'}")
    return teeth_ok

# ------------------------------------------------------------------ 6 个热核的租户模型
def s6_ffn_model():
    """ffn2::fused (1a, 正在游戏里跑)。WG=64 => >=2 sub-group。SLM 按扁平 t 索引，
       相位之间经 SLM 跨 64 线程交接，只有 esimd::barrier（无 group_barrier）。
       且 P4/P6 的 split-K staging 把部分和别名进 PKH/PK/HID 死区(O_STG=O_PKH, :229 注释)——
       这正是 §40 的 REUSE 形态：某面被跨 SG 读后，更晚的租户写同一地址区。"""
    lm = [("P1",117),("P2",144),("P3",189),("P4a",214),("P4b",229),
          ("P5q",305),("P6a",342),("P6b",356)]
    regions = [
        {"name":"O_PK (面, 被 P1/P5q 复用)","tenants":[("PK1","P1","P2"),("PK5q","P5q","P6a")],
         "note":"P1 写行 t=0..T-1(跨SG)→P2 rb=t/16 读别的 SG 写的行; P5q 又写同面→P6 读"},
        {"name":"O_HID (hidden f16)","tenants":[("HID2","P2","P3")],"note":"P2 写行→P3 t 读别的 SG 的行"},
        {"name":"O_PKH span (含 staging 别名 O_STG=O_PKH)","tenants":[("PKH3","P3","P4a"),("STG4","P4b","P4b"),("STG6","P6b","P6b")],
         "note":"P3 写 pkH→P4a 跨 SG 读; 之后 P4b/P6b 把 split-K 部分和写进同一片 PKH 死区"},
        {"name":"O_OUT (out f16)","tenants":[("OUT4","P4b","P5q")],"note":"P4b 写→P5q t 读别的 SG 的行"},
    ]
    xsg = {"PK1":"P2","PK5q":"P6a","HID2":"P3","PKH3":"P4a","OUT4":"P5q"}
    return "ffn2::fused (1a)", "s6_ffn_block_kernel.hpp", lm, regions, xsg

def wb_model():
    L = load_wb_layout()
    lm = WBLM
    regions = wb_to_regions(L)
    return "wbv4::launch_v4full", "window_block_v4.hpp", lm, regions, dict(L.XSG_READ)

def wbph_model():
    L = load_wb_layout()
    lm = [("P0",36),("PH1",66),("PH2_0",120),("PH2_1",172),("PH2_2",190),("P3",204),
          ("P4",301),("P5",315),("P6A",335),("P6B",341),("P7",389)]
    regions = wb_to_regions(L)
    return "wbv4ph::launch_v4ph", "window_block_v4ph.hpp", lm, regions, dict(L.XSG_READ)

def _single_sg_model(name, fname, lm, buffers):
    """WG<=sub-group => 每 WG 只有一个 sub-group：esimd::barrier 已覆盖全 WG，无跨 SG。"""
    regions = [{"name": b, "tenants": [(b, lm[0][0], lm[-1][0])], "note": "WG=16=1 sub-group"} for b in buffers]
    return name, fname, lm, regions, {}   # 无跨 SG 读 => xsg 空 => 判据不触发

def wa_model():
    lm = [("load",41),("gemm",151),("epi",184),("tail",214)]
    return _single_sg_model("wares::launch_wa_res", "wa_res_kernel.hpp", lm,
                            ["WA_QT","WA_KT","WA_VT","WA_X(double-buffer staging)","WA_Z(acc tile)"])

def b6_model():
    lm = [("load",74),("gemm",90),("hstage",131),("scores",190),("softmax",231),("attnV",334),("tail",441)]
    return _single_sg_model("b6res::launch_b6_res", "b6_res_kernel.hpp", lm,
                            ["X0","Z0","Y0","QT","KT","VT","double-buffer staging"])

def qkv_model():
    """gemm_qkv_res WG=NT=32 => 2 sub-group。但 staging 几何 wi_row=lid/4, wi_col=lid%4：
       每个读块的写者落在同一 16-lane sub-group => intra-SG。"""
    lm = [("prologue",107),("loop",111),("stage",121),("tail",147)]
    regions = [
        {"name":"SLM_A(double-buf A)","tenants":[("A","prologue","loop")],"note":"wi_row=lid/4 读写同 SG"},
        {"name":"SLM_B(double-buf B)","tenants":[("B","prologue","loop")],"note":"wi_col=lid%4 读写同 SG"},
        {"name":"acc tile(float stage)","tenants":[("Ztile","stage","tail")],"note":"(wi_row*16+r) 读写同 SG"},
    ]
    return "qres::gemm_qkv_res", "qkv_resident.hpp", lm, regions, {}   # intra-SG => 无跨 SG

def gemm_pub_model():
    """gemm_b_pub(NT=32)/gemm32_b_pub(NT32P=32)/pub_vec_v8(纯元素). staging wi_row=lid/4 或 /2 => 读写同 16-lane SG。"""
    lm = [("prologue",70),("loop",71),("pubtail",505)]
    regions = [
        {"name":"SLM_A/SLM_B staging","tenants":[("A","prologue","loop")],"note":"wi_row=lid/4 同 SG"},
        {"name":"pub tail (gemm_b_pub:505-522)","tenants":[("C","loop","pubtail")],"note":"寄存器内 pub, 无跨 SG SLM"},
    ]
    return "s8v8::gemm_b_pub / gemm32_b_pub", "gemm_s8_v8_kernel.hpp", lm, regions, {}

def qr_model():
    """qr_kernel_rowthread(item<1>,range(m))：一行一 work-item，无 SLM 无 barrier => OK。
       同文件的 qr_kernel_esimd/qr_kernel_rowgroup（LW=64=4 sub-group）跨子组读 per-lane row-max 槽，
       只有 esimd::barrier@319 => 跨 SG 读；值是 float max(可交换可结合)=> 顺序无碍、但可见性受 §35 缺 ACQUIRE 影响
       => NEEDS-HUMAN（K>=1024 路径）。landmark 只覆盖 rowgroup 段(300..335)，不串到 L98 那个 SIMT 核。"""
    lm = [("store_slot",318),("read_slots",320),("scale_write",324)]
    regions = [
        {"name":"rowthread (item5, K<=512, 无 SLM)","tenants":[("RT","store_slot","read_slots")],"note":"range(m) 一行一 item, 无跨线程读"},
        {"name":"rowgroup/esimd row-max slots (K>=1024)","tenants":[("RM","store_slot","read_slots")],
         "note":"LW=64 跨子组读 64 槽, 只有 esimd::barrier@319","commutative":True},
    ]
    xsg = {"RM":"read_slots"}   # 跨子组读；landmark 段内无 WG 栅栏
    return "qr_kernel_rowthread (item5)", "quantize_row_kernel.hpp", lm, regions, xsg

def pack_model():
    """pack_a_fused_b/b1：range-based ESIMD（item<1>），无 slm_init、无 barrier => 每 item 独立，无跨 SG。"""
    lm = [("body",513)]
    regions = [{"name":"no SLM (range 1:1)","tenants":[("P","body","body")],"note":"§35 折叠路, 每 item 独立"}]
    return "packdev::pack_a_fused_b/b1 (item6)", "pack_device.hpp", lm, regions, {}

# ------------------------------------------------------------------ 两栏 verdict（source-level / machine-level）
# 2026-11-02 promote2 铲的教训：源码级"缺 WG 级栅栏"不等于机器级有竞态。
# 出货件 E2D5E574 与 DM_BAR=1 变体的 ffn2 设备码 **逐字节相同**（.text md5 一致、8 条
# `send.gtwy ... signal barrier`），而工具链把 esimd::barrier() 写成
# `__esimd_fence(global_coherent_fence|local_barrier) + __esimd_barrier()`，注释
# "esimd_barrier, generic group barrier"（esimd/memory.hpp:12045、esimd/detail/memory_intrin.hpp:651）
# => 这个核里两种写法降级到同一条 CTA 栅栏指令。
NOT_MEASURED = "not-measured（ISA 未对照，别当绿也别当红）"
MACHINE_EVIDENCE = {
    "s6_ffn_block_kernel.hpp":
        "machine-level MEASURED 2026-11-02: esimd::barrier() 与 group_barrier(it.get_group()) "
        "=> 逐字节相同的 .text（S1 md5 053032299BADFDC09BE3144438741E26 / S2 21DDE963AC6AF9BEDEBB6B1EA6B28795），"
        "各 8 条 signal barrier；DM_PROBE 反证 = 多插 1 条 esimd::barrier => 9 条、asm 尺寸变 "
        "=> 两种写法在机器上是同一条 CTA 栅栏，源码级 RACE 条目在机器级不存在",
    "window_block_v4.hpp":
        "machine-level PARTIAL 2026-11-02: 出货件 .text 里 launch_v4full 共 15 条 signal barrier"
        "（源码 13 esimd + 1 group_barrier + 循环/条件复制）=> 未见两种写法的指令差异，但没做逐字节对照",
    "window_block_v4ph.hpp":
        "machine-level PARTIAL 2026-11-02: launch_v4ph 共 18 条 signal barrier，同上未逐字节对照",
}
# 机器级判据草案（**未施工**，留给下一把栅栏铲）：
#   1) 用 ocloc disasm 的 .text 里 `signal barrier` 的行号把机器码切成"栅栏区间"；
#   2) 把源码 landmark 映射到区间（不是反过来信源码注释）；
#   3) REUSE 条目再分两类：
#      (i)  **跨区间重叠**：读者 a 的读与更晚写者 b 的写落在**不同**栅栏区间，且两区间之间没有
#           已发射的 CTA 栅栏 => 真竞态候选（machine-level RACE）；
#      (ii) **同区间内重叠**：a 的读与 b 的写在同一条已发射栅栏的同一侧 => 机器上没有边界可言，
#           源码 landmark 只是注释 => 只能报 source-level，不许升格成机器级红。
#   4) HANDOFF 同理：只有"写与读跨区间且区间之间无栅栏"才是 machine-level 缺陷。
#   5) 这样 §40/§41 的 100% 红要重新解释：那道红不是"缺栅栏"，而是别名让读与更晚的写落在
#      **同一个 CTA 栅栏区间内**仍然重叠（同相内无边界）——修法是拆槽/挪相，不是加 group_barrier。

MODELS = [s6_ffn_model, wb_model, wbph_model, wa_model, b6_model, qkv_model,
          gemm_pub_model, qr_model, pack_model]
# 1a 融合核要跑两侧：DM_BAR=0（出货现状，SG 写法）与 DM_BAR=1（硬化写法）。
# 判据必须能同时给出"前 = RACE / 后 = OK"，否则 B 的验收无从谈起。
s6_ffn_model.variants = (("DM_BAR=0", "sg"), ("DM_BAR=1", "cta"))

# ------------------------------------------------------------------ 审计
def audit():
    rows = []
    print("\n== 热核审计（军规 30 判据）==")
    for mk in MODELS:
        for (vlabel, mode) in getattr(mk, "variants", ((None, "sg"),)):
            name, fname, lm, regions, xsg = mk()
            path = os.path.join(SRC, fname)
            lm, how = resolve_landmarks(path, lm)
            barriers = extract_barriers(path, s6bar=mode)
            n_wg = sum(1 for (_, k) in barriers if k == "WG")
            n_sg = sum(1 for (_, k) in barriers if k == "SG")
            errs = race_regions(lm, regions, xsg, barriers)
            hard = [e for e in errs if "[RACE]" in e]
            nh   = [e for e in errs if "[NEEDS-HUMAN]" in e]
            races = hard + nh
            if hard:
                verdict = "RACE"
            elif nh:
                verdict = "NEEDS-HUMAN"
            else:
                verdict = "OK"
            klabel = name if vlabel is None else f"{name} [{vlabel}]"
            mach = MACHINE_EVIDENCE.get(fname, NOT_MEASURED)
            # per-buffer rows
            for reg in regions:
                reg_races = [e for e in races if reg["name"] in e]
                reg_hard = [e for e in reg_races if "[RACE]" in e]
                bv = "RACE" if reg_hard else ("NEEDS-HUMAN" if reg_races else "OK")
                note = f"{n_wg}WG/{n_sg}SG barriers; lm={how}; " + reg.get("note","")
                rows.append({"file": fname, "kernel": klabel, "buffer": reg["name"],
                             "writer_sgs": "", "reader_sgs": "",
                             "cross_sg": "yes" if reg["tenants"][0][0] in xsg else "no",
                             "barriers_between": f"WG={n_wg},SG={n_sg}",
                             "verdict_source": bv, "verdict_machine": mach,
                             "note": note + (" | " + " || ".join(reg_races) if reg_races else "")})
            tag = {"RACE":"!! RACE","NEEDS-HUMAN":"?? NEEDS-HUMAN","OK":"OK"}[verdict]
            print(f"  {klabel:52s} {fname:28s} WG={n_wg} SG={n_sg} lm={how:9s} => source:{tag}"
                  f"  machine:{'see table' if fname in MACHINE_EVIDENCE else 'not-measured'}")
            for e in races: print("       -", e)
    return rows

def emit_csv(rows, path):
    cols = ["file","kernel","buffer","writer_sgs","reader_sgs","cross_sg","barriers_between",
            "verdict_source","verdict_machine","note"]
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols); w.writeheader()
        for r in rows: w.writerow(r)
    print(f"\nCSV 写出: {path}  ({len(rows)} 行)")

def main():
    teeth = teeth_test()
    if not teeth:
        print("\n!! 仪器无牙 => 不跑审计、不出结论（先修仪器）")
        return 4
    rows = audit()
    out = os.environ.get("BARRIER_CSV")
    if "--emit-csv" in sys.argv:
        out = sys.argv[sys.argv.index("--emit-csv")+1] if len(sys.argv) > sys.argv.index("--emit-csv")+1 else out
    out = out or r"E:\DSH\s6\barrier_audit.csv"
    emit_csv(rows, out)
    return 0

if __name__ == "__main__":
    sys.exit(main())
