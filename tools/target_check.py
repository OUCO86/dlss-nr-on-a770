#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""target_check.py -- 性能靶的唯一出口。任何"达标/收工/换战场"的结论必须先跑它并原样贴出输出。
用法:
  python tools/target_check.py                 # 打印靶 + 台账里记录的我们现役帧 ms + 比值与判定
  python tools/target_check.py --ms 38.4      # 用现场实测值覆盖台账值来判定
  python tools/target_check.py --claim-pass    # 声称达标：不满足判定就 exit 1（闸门用）
"""
import io, json, os, sys, argparse

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ms", type=float, default=None, help="现场实测帧 ms（覆盖台账）")
    ap.add_argument("--claim-pass", action="store_true", help="声称达标：不满足即 exit 1")
    a = ap.parse_args()
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "target.json")
    d = json.load(io.open(p, encoding="utf-8"))
    L = d["lmxx_3080L_routeA"]; N = d["normalization"]; O = d["ours"]; G = d["campaign_goals_ms"]
    ours = a.ms if a.ms is not None else O["frame_ms_fused_with_vit_reuse"]
    print("=" * 78)
    print("性能靶（唯一标准，不许换分母、不许换参考）")
    print("  对手 = lmxx 3080L 路线 A：71 层完整模型 / 每帧 %d 核" % L["cores_per_frame"])
    print("  他的实测 = %.3f ms @ %s Mpx（1920x1152）；900p = %.1f ms" % (L["total_ms_at_1080p_2p21Mpx"], "2.21", L["ms_at_900p"]))
    print("  归一到我们 %s Mpx（960x544，像素因子 %.2f）= %.1f ms" % (N["our_px_960x544"], N["pixel_factor"], N["equal_pixel_target_ms"]))
    print("  带宽归一（448->560 GB/s，x%.2f）= %.1f ms  <-- A770 int8 世代物理参考值" % (N["bw_ratio_560_over_448"], N["bandwidth_norm_ms"]))
    print("  第一战役目标 = %.0f ms；同等融合深度的物理地板 = %.0f ms" % (G["first_campaign"], G["physical_floor_same_fusion_depth"]))
    print("-" * 78)
    print("禁止当靶用（历史误读，已钉死）：")
    for f in d["_forbidden_references"]:
        print("  x " + f)
    print("-" * 78)
    print("我们（台账：dll %s，%d 闭包/帧）：" % (O["shipped_dll_md5"][:12], O["closures_per_frame_fused"]))
    print("  fused  开复用 %.2f ms / 不开 %.2f ms" % (O["frame_ms_fused_with_vit_reuse"], O["frame_ms_fused_no_reuse"]))
    print("  plain  开复用 %.2f ms / 不开 %.2f ms" % (O["frame_ms_plain_with_vit_reuse"], O["frame_ms_plain_no_reuse"]))
    print("  本次判定用值 = %.2f ms%s" % (ours, "（现场实测）" if a.ms is not None else "（台账）"))
    print("  前辈 coopmat = %.2f ms" % d["predecessor"]["coopmat_ms"])
    print("-" * 78)
    r_eq = ours / N["equal_pixel_target_ms"]; r_bw = ours / N["bandwidth_norm_ms"]
    print("比值：对等像素靶 %.2fx   对带宽归一靶 %.2fx   对第一战役目标(%.0f ms) %.2fx" % (r_eq, r_bw, G["first_campaign"], ours / G["first_campaign"]))
    beat_routeA = ours <= N["equal_pixel_target_ms"]
    beat_campaign = ours <= G["first_campaign"]
    print("判定：比过 3080L 路线 A（等像素）? %s    破第一战役目标 20 ms? %s    破前辈 47.19 ms? %s"
          % ("YES" if beat_routeA else "NO", "YES" if beat_campaign else "NO", "YES" if ours < d["predecessor"]["coopmat_ms"] else "NO"))
    print("-" * 78)
    print("大刀（钱在这里，不在单核刀）：")
    b = d["big_knife"]
    print("  %s" % b["name"])
    tr = b["traffic_region_census_per_frame"]
    print("  口径钉死（C48）：面/流量账一律用 region（执行）普查；帧账与靶只用实测 wall。")
    print("  全面合计 %.2f GB/帧；残差 ping-pong split %.3f GB/帧；块驻留可消 %.3f GB/帧 = %.2f-%.2f ms"
          % (tr["all_planes_total_GB"], tr["residual_ping_pong_split_GB"], tr["killable_by_block_residency_GB"],
             tr["killable_ms_at_560GBps"], tr["killable_ms_at_190GBps"]))
    c = b["c32_wave1_segment"]
    print("  正确试验层 = C32 wave1 全分辨率段：我们 %d 闭包 / 腿 %.1f ms / region %.2f GB每帧；lmxx %s = @544p %.1f ms => 超额 %.1f ms（与第一战役目标同量级）"
          % (c["our_closures"], c["our_leg_ms"], c["our_region_GB_per_frame"], c["lmxx_cores"], c["lmxx_equiv_ms_at_544p"], c["excess_ms"]))
    for k, v in b["gates"].items():
        print("  闸门[%s]: %s" % (k, v))
    print("  为什么 B6-1 没兑现：%s" % b["why_B6_1_died"])
    print("  为什么不选 C64：%s" % b["why_not_C64"])
    print("  坑：%s" % b["pitfall"])
    print("=" * 78)
    h = d.get("hardware_by_user_2026_11_12")
    if h:
        print("硬件对照（用户 2026-11-12 给表，永久作废'装不下'借口）：")
        a = h["A770_Xe_HPG"]; n = h["RTX3080Laptop_GA104"]
        print("  A770(Xe-HPG): %s / 单线程 %s / 每 %s" % (a["max_regs_per_thread"], a["reg_bytes_per_thread"], a["regs_per_EU"]))
        print("  3080L(GA104): %s / 单线程 %s / 每 %s" % (n["max_regs_per_thread"], n["reg_bytes_per_thread"], n["regs_per_SM"]))
        print("  结论：%s" % h["verdict"])
    rf = d.get("roofline_measured")
    if rf:
        print("-" * 78)
        print("实测 roofline（达标判定只认这些；出处 bandwidth.md:43-45,55-56,83-84）：")
        print("  fp16 峰值 %.1f TF；DRAM 读 %.1f / 拷贝 %.1f / strided %.1f GB/s；L2 复用 %.1f；SLM 读 %.1f GB/s"
              % (rf["fp16_peak_TFLOPS"], rf["DRAM_read_GBps"], rf["DRAM_copy_GBps"], rf["DRAM_strided_GBps"],
                 rf["L2_reuse_GBps"], rf["SLM_read_GBps"]))
        print("  ridge：DRAM %.1f、L2 %.1f FLOP/B；规则：%s" % (rf["ridge_DRAM_FLOP_per_B"], rf["ridge_L2_FLOP_per_B"], rf["_rule"]))
        e = rf["_our_engine_measured_by_him"]
        print("  工程师对我们引擎的实测（1080p）：%d GEMM 调用、%.1f GB/帧、%d GFLOP、AI %.1f FLOP/B、实得 %.0f GB/s = DRAM 的 %d%%、dispatch 间空洞约 %.0f ms"
              % (e["gemm_calls_per_frame_1080p"], e["GB_per_frame"], e["GFLOP"], e["AI_FLOP_per_B"], e["achieved_GBps"], e["pct_of_DRAM"], e["unattributed_ms_dispatch_tail"]))
    print("=" * 78)
    if a.claim_pass:
        if not beat_routeA:
            print("GATE: 声称达标被拒 -- 还没比过 3080L 路线 A（%.2f ms > %.1f ms）" % (ours, N["equal_pixel_target_ms"]))
            return 1
        print("GATE: 达标声称通过（已比过 3080L 路线 A）")
    return 0

if __name__ == "__main__":
    sys.exit(main())
