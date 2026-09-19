#!/usr/bin/env python3
"""
一键扫描 lib/ 下所有 .dart 文件中的中文字符串，生成 l10n 条目
用法: python3 _gen_l10n.py
输出: 更新 app_en.arb, app_zh.arb, 然后运行 flutter gen-l10n
"""
import re, os, json, hashlib, sys

LIB = 'lib'
ARB_DIR = os.path.join(LIB, 'l10n')
CJ = '\\u4e00-\\u9fff'

def scan_chinese_strings():
    """扫描所有 .dart 文件中的中文字符串"""
    results = []
    for root, dirs, files in os.walk(LIB):
        for fname in sorted(files):
            if not fname.endswith('.dart') or '.g.dart' in fname:
                continue
            if 'l10n' in fname or 'ui_design' in fname:
                continue
            filepath = os.path.join(root, fname)
            with open(filepath) as f:
                for i, line in enumerate(f.readlines(), 1):
                    if line.strip().startswith('//'):
                        continue
                    if 'AppLocalizations' in line or 'l10n' in line:
                        continue
                    for m in re.finditer(f"'([^']*[{CJ}][^']*)'", line):
                        text = m.group(1)
                        if len(text) >= 2:
                            results.append({
                                'file': os.path.relpath(filepath, LIB),
                                'line': i,
                                'text': text,
                            })
    return results

def generate_key(text):
    """生成有意义的英文 key"""
    # 简单翻译映射
    simple_map = {
        '取消': 'cancel', '确定': 'ok', '删除': 'delete', '重命名': 'rename',
        '创建': 'create', '打开': 'open', '关闭': 'close', '搜索': 'search',
        '复制': 'copy', '剪切': 'cut', '粘贴': 'paste', '移动': 'move',
        '分享': 'share', '属性': 'properties', '压缩': 'compress', '解压': 'extract',
        '选择': 'select', '跳过': 'skip', '覆盖': 'overwrite', '恢复': 'restore',
        '密码': 'password', '类型': 'type', '大小': 'size', '修改': 'modified',
        '权限': 'permission', '路径': 'path', '文件名': 'filename', '文件夹': 'folder',
    }
    if text in simple_map:
        return simple_map[text]
    # 用 MD5 哈希作为 fallback
    return 'c_' + hashlib.md5(text.encode()).hexdigest()[:8]

def main():
    results = scan_chinese_strings()
    if not results:
        print('No Chinese strings found!')
        return
    
    print(f'Found {len(results)} Chinese strings:')
    for r in results:
        print(f"  {r['file']}:{r['line']}: {r['text'][:50]}")
    
    # 读取现有 ARB
    en_path = os.path.join(ARB_DIR, 'app_en.arb')
    zh_path = os.path.join(ARB_DIR, 'app_zh.arb')
    
    with open(en_path) as f:
        en = json.load(f)
    with open(zh_path) as f:
        zh = json.load(f)
    
    # 添加新条目
    added = 0
    for r in results:
        key = generate_key(r['text'])
        if key not in en:
            en[key] = r['text']  # 英文暂时用中文，需要手动翻译
            zh[key] = r['text']
            added += 1
    
    # 保存
    with open(en_path, 'w') as f:
        json.dump(en, f, ensure_ascii=False, indent=2)
    with open(zh_path, 'w') as f:
        json.dump(zh, f, ensure_ascii=False, indent=2)
    
    print(f'\nAdded {added} new entries to ARB')
    print(f'Total: {len(en)-1} entries')
    print(f'\nNext steps:')
    print(f'1. Translate English values in {en_path}')
    print(f'2. Run: flutter gen-l10n')
    print(f'3. Update code references')

if __name__ == '__main__':
    main()
