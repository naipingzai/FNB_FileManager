#!/usr/bin/env python3
"""Flutter File Manager - Code Quality Check Script"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
RED='\033[91m'; GREEN='\033[92m'; YELLOW='\033[93m'; R='\033[0m'
errors=[]; warnings=[]
def err(m): errors.append(m); print(f'  {RED}X{R} {m}')
def warn(m): warnings.append(m); print(f'  {YELLOW}!{R} {m}')
def ok(m): print(f'  {GREEN}OK{R} {m}')

def scan_file(path, label):
    if not os.path.exists(path): return
    sync_pats = [
        (r'readAsBytesSync\s*\(','readAsBytesSync -> use await readAsBytes()'),
        (r'readAsStringSync\s*\(','readAsStringSync -> use await readAsString()'),
        (r'writeAsBytesSync\s*\(','writeAsBytesSync -> use await writeAsBytes()'),
        (r'writeAsStringSync\s*\(','writeAsStringSync -> use await writeAsString()'),
        (r'existsSync\s*\(','existsSync -> use await exists()'),
        (r'listSync\s*\(','listSync -> use await list().toList()'),
        (r'createSync\s*\(','createSync -> use await create()'),
        (r'deleteSync\s*\(','deleteSync -> use await delete()'),
        (r'renameSync\s*\(','renameSync -> use await rename()'),
    ]
    with open(path) as f:
        for i, line in enumerate(f, 1):
            s = line.strip()
            if s.startswith('//') or s.startswith('*') or s.startswith('///'): continue
            for pat, desc in sync_pats:
                if re.search(pat, line):
                    err(f'{label}:{i} {desc}')

print('\n=== 1. Foreground Blocking Check ===')
for d in [LIB, os.path.join(LIB,'viewers'), os.path.join(LIB,'services')]:
    if not os.path.isdir(d): continue
    for f in sorted(os.listdir(d)):
        if f.endswith('.dart'):
            scan_file(os.path.join(d,f), f)
if not errors: ok('No foreground blocking operations found')

print('\n=== 2. Isolate Usage ===')
found=False
for d in [LIB, os.path.join(LIB,'viewers'), os.path.join(LIB,'services')]:
    if not os.path.isdir(d): continue
    for f in sorted(os.listdir(d)):
        if not f.endswith('.dart'): continue
        with open(os.path.join(d,f)) as fh:
            c = fh.read()
            if 'Isolate.run' in c or 'Isolate.spawn' in c:
                found=True; ok(f'{f} uses Isolate')
if not found: warn('No Isolate usage found')

print('\n=== 3. L10n Completeness ===')
en=os.path.join(LIB,'l10n','app_en.arb'); zh=os.path.join(LIB,'l10n','app_zh.arb')
if os.path.exists(en) and os.path.exists(zh):
    with open(en) as f: ek=set(re.findall(r'"(@?[a-zA-Z_]\w*)":', f.read()))
    with open(zh) as f: zk=set(re.findall(r'"(@?[a-zA-Z_]\w*)":', f.read()))
    mz=ek-zk; me=zk-ek
    if mz: err(f'EN has but ZH missing: {mz}')
    if me: warn(f'ZH has but EN missing: {me}')
    if not mz and not me: ok(f'Keys match ({len(ek)} keys)')
else: err('Missing app_en.arb or app_zh.arb')

print('\n=== 4. File Structure ===')
for f in ['lib/main.dart','lib/file_browser.dart','lib/native.dart','lib/utils.dart',
          'lib/viewers/dual_panel_page.dart','lib/viewers/duplicate_cleaner_page.dart',
          'lib/viewers/file_compare_page.dart','lib/viewers/storage_analysis_page.dart']:
    if os.path.exists(os.path.join(ROOT,f)): ok(f)
    else: err(f'Missing: {f}')

print(f'\n{"="*50}')
print(f'  Errors: {len(errors)}  Warnings: {len(warnings)}')
if errors: print(f'\n  {RED}FIX ERRORS BEFORE COMMIT{R}'); sys.exit(1)
else: print(f'\n  {GREEN}ALL CHECKS PASSED{R}'); sys.exit(0)
