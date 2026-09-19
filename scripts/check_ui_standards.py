#!/usr/bin/env python3
import os, re, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
R='\033[0m'; RED='\033[91m'; GRN='\033[92m'; YLW='\033[93m'; CYN='\033[96m'
errs=[]; warns=[]
def err(m): errs.append(m); print(f'  {RED}X{R} {m}')
def wrn(m): warns.append(m); print(f'  {YLW}!{R} {m}')
def ok(m): print(f'  {GRN}OK{R} {m}')
def scan():
    out=[]
    for d in [LIB, os.path.join(LIB,'viewers'), os.path.join(LIB,'services'), os.path.join(LIB,'widgets')]:
        if not os.path.isdir(d): continue
        for f in sorted(os.listdir(d)):
            if f.endswith('.dart') and 'l10n' not in f and 'generated' not in f:
                with open(os.path.join(d,f)) as fh: out.append((f,fh.readlines()))
    return out
print(f'\n{"="*60}\n  UI Standards Checker\n{"="*60}')
print(f'\n{CYN}=== 1. Sync I/O ==={R}')
pats=[(r'readAsBytesSync','use await readAsBytes()'),(r'readAsStringSync','use await readAsString()'),
      (r'existsSync','use await exists()'),(r'listSync','use await list()'),
      (r'createSync','use await create()'),(r'deleteSync','use await delete()'),
      (r'renameSync','use await rename()'),(r'\.statSync','use await stat()')]
f=False
for fn,lines in scan():
    for i,l in enumerate(lines,1):
        if l.strip().startswith('//'): continue
        for p,d in pats:
            if re.search(p,l): err(f'{fn}:{i} {d}'); f=True
if not f: ok('No sync I/O')
print(f'\n{CYN}=== 2. FFI in Loops ==={R}')
f=False
for fn,lines in scan():
    inl=False
    for i,l in enumerate(lines,1):
        if re.search(r'for\s*\(|while\s*\(',l): inl=True
        if inl and ('NativeFs.' in l or 'NativeArchive.' in l) and 'await' not in l and 'Isolate' not in l:
            wrn(f'{fn}:{i} Native call in loop'); f=True; inl=False
        if inl and re.search(r'^\s{0,4}\}',l): inl=False
if not f: ok('No FFI in loops')
print(f'\n{CYN}=== 3. Hardcoded Strings ==={R}')
known={'MP4','MKV','AVI','FLV','WEBM','H.264','H.265','kbps','UTF-8','ASCII','OK','URL','IP','PCM','Linux','Android'}
f=False
for fn,lines in scan():
    for i,l in enumerate(lines,1):
        if l.strip().startswith('//') or 'import ' in l: continue
        for m in re.finditer(r"Text\('([A-Z][a-z]+(?:\s+[a-z]+)+)'\)",l):
            if m.group(1) not in known: err(f'{fn}:{i} Hardcoded: "{m.group(1)}"'); f=True
if not f: ok('No hardcoded English')
print(f'\n{CYN}=== 4. Hardcoded Colors ==={R}')
ok_c={'Colors.transparent','Colors.white','Colors.black','Colors.black87','Colors.black54'}
f=False
for fn,lines in scan():
    for i,l in enumerate(lines,1):
        if l.strip().startswith('//'): continue
        for m in re.finditer(r'Colors\.([\w.]+)',l):
            full=m.group(0)
            if full in ok_c or 'green' in full or 'red' in full: continue
            wrn(f'{fn}:{i} Hardcoded: {full}'); f=True
if not f: ok('All colors use colorScheme')
print(f'\n{CYN}=== 5. fontSize ==={R}')
c=0
for fn,lines in scan():
    for i,l in enumerate(lines,1):
        if l.strip().startswith('//'): continue
        if 'fontSize' in l and 'T.style' not in l and 'Ui.val' not in l: c+=1
if c==0: ok('All via T.style/Ui.val')
else: wrn(f'{c} hardcoded fontSize')
print(f'\n{CYN}=== 6. Icons ==={R}')
c=0
for fn,lines in scan():
    for i,l in enumerate(lines,1):
        if 'Icons.' in l and 'CupertinoIcons' not in l and 'AppIcon' not in l and 'IconData' not in l:
            wrn(f'{fn}:{i} Material Icons'); c+=1
if c==0: ok('All use CupertinoIcons/AppIcon')
print(f'\n{CYN}=== 7. L10n ==={R}')
en=os.path.join(LIB,'l10n','app_en.arb'); zh=os.path.join(LIB,'l10n','app_zh.arb')
if os.path.exists(en) and os.path.exists(zh):
    with open(en) as f: ek=set(re.findall(r'"(@?[a-zA-Z_]\w*)":',f.read()))
    with open(zh) as f: zk=set(re.findall(r'"(@?[a-zA-Z_]\w*)":',f.read()))
    mz=ek-zk; me=zk-ek
    if mz: err(f'EN has ZH missing: {mz}')
    if me: wrn(f'ZH has EN missing: {me}')
    if not mz and not me: ok(f'Keys match ({len(ek)})')
else: err('Missing ARB files')
print(f'\n{CYN}=== 8. Isolate ==={R}')
f=False
for fn,lines in scan():
    for i,l in enumerate(lines,1):
        if 'Isolate.run' in l or 'compute(' in l: ok(f'{fn}:{i} Isolate'); f=True
if not f: wrn('No Isolate usage found')
print(f'\n{CYN}=== 9. Structure ==={R}')
for f in ['lib/main.dart','lib/file_browser.dart','lib/native.dart','lib/utils.dart',
          'lib/viewers/storage_analysis_page.dart','lib/viewers/video_convert_page.dart',
          'lib/viewers/dual_panel_page.dart','lib/viewers/settings_page.dart']:
    if os.path.exists(os.path.join(ROOT,f)): ok(f)
    else: err(f'Missing: {f}')
print(f'\n{"="*60}')
print(f'  {RED}Errors: {len(errs)}{R}  {YLW}Warnings: {len(warns)}{R}')
if errs: print(f'\n  {RED}FIX ERRORS{R}'); sys.exit(1)
else: print(f'\n  {GRN}ALL CHECKS PASSED{R}'); sys.exit(0)
