#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""gate_skip_graph.py -- 第 40 门：跳块路径的**整图**回归门（§45 缺口一）。

为什么必须存在（notes/DS-takeover-2026-11-01.md §45 缺口一）：
  39 门里没有任何一扇在测跳块。只有 gate_graph / gate_coexist 的日志里出现 `[skip-chains]`，
  而那两扇门的小图只有 1 条链，请求的链号 18..32 全部 `OUT OF RANGE ... ignored`
  => `chains_skipped=0 refused=14 closures_noop=0 passes=1 (unchanged)`。
  ⇒ "跳块会让整链门红"从未发生，因为门里根本没有跳块类；跳块路径此前**只活在 walk 里**。

这一门判什么（三件事，全部硬断言）：
  1) **整图 691 闭包 + 跳 C512 全 14 链**：record-time 打印
     `[skip-chains] graph=0 chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)`
     —— 14 条链真被跳过（不是越界 ignored）、硬守卫一条没拒、闭包数不变；
  2) 1301 面**逐位 = 新金标** `dumps/bk.1301.skip.bin`（DD49827DD33A7EF07C2C17892F18970D），
     且**两个独立进程**读数相同（跨进程抖动 = 一票否决，军规 33 (d) 同一条）；
  3) `passes` 仍 691（跳块=整条链从图里移除，闭包数不许变；变了就是记账错了）。

被测件 = 当前转正件（md5 的唯一出处 = E:/DSH/out/SHIPPED_MD5.txt，军规 62）：
  * `out/libxmx.dll`（加载位，用户实机验收过的那只）—— 进程 1、2；
  * `oneapi/libxmx_sycl.dll`（其余 39 门所 stage 的同一份字节）—— 进程 3，交叉核对。
门**不 stage、不覆盖**任何 dll/金标；只写 `dumps/gate40_p{1,2,3}.1301.bin` 与 `logs/`。

Run from oneapi/ (the staging dir where sycl9.dll and its chain live), like every other gate.
"""
import ctypes, hashlib, os, pathlib, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
_STAGE = os.environ.get("DSH_ONEAPI") or (
    str(ROOT.parent / "oneapi") if os.path.isdir(str(ROOT.parent / "oneapi"))
    else str(ROOT.parent.parent / "oneapi"))
ONEAPI = pathlib.Path(_STAGE)
DSH = ONEAPI.parent                      # E:\DSH
OUT = DSH / "out"
DUMPS = DSH / "dumps"
LOGS = DSH / "logs"

# 身份守卫读"当前转正件 md5"的唯一出处（军规 59）：每次转正只改 out/SHIPPED_MD5.txt，
# 不改本门。历史上这里是写死的 abb969fe...（§45 部署链），导致每次转正都让本门的身份检查
# 按设计 RED，把"实质检查"淹掉。缺失即 RED（不许静默放行）。
_SHIPF = OUT / "SHIPPED_MD5.txt"
if not _SHIPF.exists():
    print("FAIL 缺 out/SHIPPED_MD5.txt —— 无法核对被测件身份（这是身份守卫，不是实质检查）")
    sys.exit(1)
SHIP_MD5 = _SHIPF.read_text(encoding="utf-8").strip().lower()   # 当前转正件
GOLDEN = DUMPS / "bk.1301.skip.bin"                # 新金标（跳块代）
GOLDEN_MD5 = "dd49827dd33a7ef07c2c17892f18970d"
PLAN = OUT / "plan_960x544.bin"
EXE = ONEAPI / "nr_replay_now.exe"

SKIP_CHAINS = "18,19,20,21,22,23,24,26,27,28,29,30,31,32"
EXPECT_SKIPPED = 14
EXPECT_REFUSED = 0
EXPECT_NOOP = 168          # 14 链 x 12 闭包
EXPECT_PASSES = 691
EXPECT_CLOSURES = 691
EXPECT_CHAINS = 52
EXPECT_NAMES = 1382

fails = 0


def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond:
        fails += 1


def md5(p):
    h = hashlib.md5()
    with open(p, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def replay(tag, dll):
    """一次独立进程：整图 5254 步 -> 691 闭包 -> 跳 14 链 -> 落 1301 dump。返回 (lines, dump_path)."""
    env = dict(os.environ)
    env['SYCL_DEVICE_FILTER'] = 'level_zero:gpu'
    env['SYCL_CACHE_PERSISTENT'] = '1'
    env['SYCL_CACHE_DIR'] = str(DSH / 'sycl-cache')
    env['NR_DUMP_OUT'] = str(DUMPS / tag)
    dump = DUMPS / (tag + ".1301.bin")
    if dump.exists():
        dump.unlink()
    r = subprocess.run([str(EXE), str(dll), str(PLAN), str(OUT)],
                       cwd=str(ONEAPI), env=env, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, timeout=900)
    txt = r.stdout.decode('utf-8', 'replace').splitlines()
    (LOGS / ("gate40_%s.txt" % tag)).write_text("\n".join(txt), encoding='utf-8')
    print("     [%s] exit=%d  dll=%s  -> 日志 logs/gate40_%s.txt"
          % (tag, r.returncode, os.path.basename(str(dll)), tag), flush=True)
    return txt, dump


def find(lines, pat):
    return [ln for ln in lines if pat in ln]


# ---------------------------------------------------------------- 前置：件与金标的身份
print("gate_skip_graph: 第 40 门（跳块路径的整图回归）")
ok(EXE.exists(), "replay exe 存在: %s" % EXE)
ok(PLAN.exists(), "plan 存在: %s (%d B)" % (PLAN, PLAN.stat().st_size if PLAN.exists() else -1))
ok(GOLDEN.exists() and md5(GOLDEN) == GOLDEN_MD5,
   "金标 %s md5=%s（=%s）" % (GOLDEN.name, GOLDEN_MD5, 'DD49827D...'))
shipped = OUT / "libxmx.dll"
staged = ONEAPI / "libxmx_sycl.dll"
ok(md5(shipped) == SHIP_MD5, "被测 out/libxmx.dll md5=%s（应等于 out/SHIPPED_MD5.txt = %s...）" % (md5(shipped), SHIP_MD5[:8]))
ok(md5(staged) == SHIP_MD5, "stage oneapi/libxmx_sycl.dll md5 同一只（本门不 stage、不改写）")

# ---------------------------------------------------------------- 三个独立进程
seen = {}
for tag, dll in (("gate40_p1", shipped), ("gate40_p2", shipped), ("gate40_p3", staged)):
    lines, dump = replay(tag, dll)
    seen[tag] = (lines, dump)

for tag, (lines, dump) in seen.items():
    print("\n--- 进程 %s ---" % tag)
    # 1) 整图规模：closures/names/chains（不是小图）
    head = find(lines, '[skip-chains] graph=0 closures=')
    ok(bool(head), "%s: record-time 打印了 [skip-chains] 表头（说明真建了图）" % tag)
    if head:
        print("     原文: %s" % head[0].strip())
        ok('closures=%d' % EXPECT_CLOSURES in head[0],
           "%s: 整图 closures=%d（不是 gate_graph 的 1 闭包小图）" % (tag, EXPECT_CLOSURES))
        ok('chains=%d' % EXPECT_CHAINS in head[0],
           "%s: 整图 chains=%d 条链（跳块类有对象可跳）" % (tag, EXPECT_CHAINS))
        ok('names=%d' % EXPECT_NAMES in head[0], "%s: names=%d" % (tag, EXPECT_NAMES))
        ok(("'%s'" % SKIP_CHAINS) in head[0], "%s: NR_SKIP_CHAINS=%s" % (tag, SKIP_CHAINS))
    # 2) 14 条链真被 SKIPPED（而不是 OUT OF RANGE ignored）
    sk = find(lines, ' SKIPPED closures ')
    ok(len(sk) == EXPECT_SKIPPED, "%s: SKIPPED 行数=%d（期望 %d）" % (tag, len(sk), EXPECT_SKIPPED))
    oor = find(lines, 'OUT OF RANGE')
    ok(len(oor) == 0, "%s: 没有 OUT OF RANGE ignored（gate_graph/gate_coexist 那种空跳 = 0）" % tag)
    ids = sorted(int(ln.split('chain=')[1].split()[0]) for ln in sk)
    ok(ids == [int(x) for x in SKIP_CHAINS.split(',')], "%s: 被跳的链号 = %s" % (tag, ids))
    noop = sum(int(ln.split('(')[1].split()[0].split()[0]) for ln in sk if '(' in ln)
    ok(noop == EXPECT_NOOP, "%s: 逐条累加的 no-op 闭包=%d（期望 %d）" % (tag, noop, EXPECT_NOOP))
    # 3) 汇总行：chains_skipped / refused / passes
    fin = find(lines, 'chains_skipped=')
    ok(bool(fin), "%s: 打印了 chains_skipped 汇总行" % tag)
    if fin:
        print("     原文: %s" % fin[-1].strip())
        ok('chains_skipped=%d' % EXPECT_SKIPPED in fin[-1],
           "%s: chains_skipped=%d refused=%d" % (tag, EXPECT_SKIPPED, EXPECT_REFUSED))
        ok('refused=%d' % EXPECT_REFUSED in fin[-1],
           "%s: refused=%d（硬守卫一条都没拒）" % (tag, EXPECT_REFUSED))
        ok('closures_noop=%d' % EXPECT_NOOP in fin[-1], "%s: closures_noop=%d" % (tag, EXPECT_NOOP))
        ok('passes=%d' % EXPECT_PASSES in fin[-1], "%s: passes=%d (unchanged)" % (tag, EXPECT_PASSES))
    # 4) 图确实录了 691 闭包，且每趟 replay 返回 691
    cg = find(lines, 'recorded graph id=')
    ok(bool(cg) and ('(%d closures)' % EXPECT_CLOSURES) in cg[0],
       "%s: [cgraph] recorded graph id= (%d closures)" % (tag, EXPECT_CLOSURES))
    runs = find(lines, 'passes)')
    runs = [ln for ln in runs if ln.strip().startswith('run ')]
    ok(len(runs) >= 2, "%s: 有 %d 趟 replay run 行" % (tag, len(runs)))
    ok(all(('(%d passes)' % EXPECT_PASSES) in ln for ln in runs),
       "%s: 每趟 replay 都返回 (%d passes)" % (tag, EXPECT_PASSES))
    # 5) 1301 逐位对新金标
    ok(dump.exists() and dump.stat().st_size == 8355840,
       "%s: 1301 dump 落盘 %s (%s B)" % (tag, dump.name, dump.stat().st_size if dump.exists() else '-'))
    if dump.exists():
        m = md5(dump)
        ok(m == GOLDEN_MD5, "%s: 1301 EXACT vs bk.1301.skip.bin  md5=%s" % (tag, m))

# ---------------------------------------------------------------- 跨进程一致性（反抖动）
print("\n--- 跨进程一致性 ---")
m1 = md5(seen['gate40_p1'][1]) if seen['gate40_p1'][1].exists() else '-'
m2 = md5(seen['gate40_p2'][1]) if seen['gate40_p2'][1].exists() else '-'
m3 = md5(seen['gate40_p3'][1]) if seen['gate40_p3'][1].exists() else '-'
ok(m1 == m2 == GOLDEN_MD5, "两个独立进程（out/libxmx.dll）1301 逐位相同且=新金标: %s / %s" % (m1, m2))
ok(m3 == GOLDEN_MD5, "第三进程（oneapi/libxmx_sycl.dll 同一只字节）1301 也=新金标: %s" % m3)
ok(md5(staged) == SHIP_MD5 and md5(shipped) == SHIP_MD5,
   "门跑完后 out/libxmx.dll 与 oneapi/libxmx_sycl.dll 仍等于 out/SHIPPED_MD5.txt 记录的转正件（本门没有改写任何 dll）")

print("\nSKIP_GRAPH %s (%d fails)" % ("GREEN" if not fails else "RED", fails))
sys.exit(1 if fails else 0)
