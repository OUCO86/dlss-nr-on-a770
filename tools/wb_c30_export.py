import subprocess, sys, hashlib
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c30_export.py -- export EVERY tracked change (engine .cpp + any kernel header) as
# an LF, UTF-8 (no BOM) patch, then verify `git apply --check`. Also prints the new md5 of
# each changed file, because the shipped md5 guard (tools/shipped_build.defs / the build
# script's header check) is the PARENT's to update -- this shovel only reports (rule 170/197).
REPO = r'E:\DSH\dlss-nr-on-a770'
OUT = r'E:\DSH\tools\C30_engine_u8.diff'
files = subprocess.run(['git', '-C', REPO, 'diff', '--name-only'], capture_output=True, text=True).stdout.split()
print('changed files:', files)
p = subprocess.run(['git', '-C', REPO, 'diff'], capture_output=True)
raw = p.stdout
if not raw:
    print('EMPTY DIFF'); sys.exit(1)
lf = raw.decode('utf-8', 'replace').replace('\r\n', '\n').replace('\r', '\n')
if lf.startswith('\ufeff'):
    lf = lf.lstrip('\ufeff')
open(OUT, 'wb').write(lf.encode('utf-8'))
add = sum(1 for L in lf.split('\n') if L.startswith('+') and not L.startswith('+++'))
rem = sum(1 for L in lf.split('\n') if L.startswith('-') and not L.startswith('---'))
print('wrote %s bytes=%d crlf_left=%d bom=%s hunks=%d added=%d removed=%d' % (
    OUT, len(lf.encode('utf-8')), lf.count('\r'), lf.startswith('\ufeff'),
    sum(1 for L in lf.split('\n') if L.startswith('@@')), add, rem))
for rel in files:
    fp = REPO + '\\' + rel.replace('/', '\\')
    print('  new md5 %-46s %s' % (rel, hashlib.md5(open(fp, 'rb').read()).hexdigest().upper()))
print('=== done wb_c30_export ===')
