#!/usr/bin/env python3
"""
一键生成 ui_design.dart 中的 UiItem 列表
扫描 lib/ 下所有 .dart 文件，提取 T.style() 调用和 SizedBox/Divider/Padding 等间距值
用法: python3 _gen_ui.py
"""
import re, os, sys

LIB = 'lib'
OUT = os.path.join(LIB, 'ui_design.dart')

# 页面名映射 (文件名 -> 英文页面名)
PAGE_MAP = {
    'file_browser.dart': ('File Browser', '文件浏览器'),
    'archive_viewer.dart': ('Archive Viewer', '压缩包查看器'),
    'audio_player.dart': ('Audio Player', '音频播放器'),
    'audio_extract_page.dart': ('Audio Extract', '音频提取'),
    'video_player.dart': ('Video Player', '视频播放器'),
    'video_compress_page.dart': ('Video Compress', '视频压缩'),
    'video_convert_page.dart': ('Format Convert', '格式转换'),
    'video_convert_dialog.dart': ('Convert Dialog', '格式转换弹窗'),
    'video_trim_page.dart': ('Video Trim', '视频裁剪'),
    'gif_page.dart': ('GIF Maker', 'GIF制作'),
    'hex_viewer.dart': ('Hex Viewer', '十六进制查看器'),
    'text_viewer.dart': ('Text Viewer', '文本查看器'),
    'image_viewer.dart': ('Image Viewer', '图片查看器'),
    'ebook_viewer.dart': ('Ebook Reader', '电子书阅读器'),
    'media_info_page.dart': ('Media Info', '媒体信息'),
    'media_tools_page.dart': ('Media Tools', '媒体工具'),
    'display_settings_page.dart': ('Display Settings', '显示设置页'),
}

# T.style() 组件名映射 (中文 -> 英文)
COMP_MAP = {
    '文件名': ('File Name', '文件名'),
    '文件大小': ('File Size', '文件大小'),
    '地址栏文字': ('Address Bar', '地址栏文字'),
    '多选按钮': ('Multi-Select', '多选按钮'),
    '压缩格式选择': ('Compression Format', '压缩格式选择'),
    'appBar标题': ('App Bar Title', 'appBar标题'),
    '工具标题': ('Tool Title', '工具标题'),
    'caption': ('caption', 'caption'),
    '错误提示间距': ('Error Spacing', '错误提示间距'),
    '分割线高度': ('Divider Height', '分割线高度'),
    '列表项间距': ('List Item Spacing', '列表项间距'),
    '按钮间距': ('Button Spacing', '按钮间距'),
    '组件间距': ('Element Spacing', '组件间距'),
    '滑块间距': ('Slider Spacing', '滑块间距'),
    '搜索区域间距': ('搜索区域间距', '搜索区域间距'),
    '分割线间距': ('分割线间距', '分割线间距'),
    '列表项': ('List Item', '列表项'),
    '按钮': ('Button', '按钮'),
}

def scan_file(filepath):
    """扫描单个文件，提取 T.style() 调用"""
    fname = os.path.basename(filepath)
    if fname not in PAGE_MAP:
        return []
    
    pe, pz = PAGE_MAP[fname]
    items = []
    
    with open(filepath) as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines, 1):
        # 匹配 T.style('页面', '组件') 或 T.style('页面', '组件', ...)
        for m in re.finditer(r"T\.style\('([^']+)',\s*'([^']+)'", line):
            page, comp = m.group(1), m.group(2)
            # 如果页面名是中文，映射到英文
            for fname2, (p_en, p_zh) in PAGE_MAP.items():
                if page == p_zh:
                    page = p_en
                    break
            # 如果组件名是中文，映射到英文
            if comp in COMP_MAP:
                ce, cv = COMP_MAP[comp]
            else:
                ce, cv = comp, comp
            
            # 检查是否已存在
            key = f'{page}.{ce}'
            if not any(it[0] == key for it in items):
                items.append((key, pe, pz, ce, cv, f'{fname}:{i}'))
    
    return items

def main():
    all_items = []
    
    # 扫描所有 dart 文件
    for root, dirs, files in os.walk(LIB):
        for f in sorted(files):
            if not f.endswith('.dart') or '.g.dart' in f:
                continue
            if 'l10n' in f or 'ui_design' in f:
                continue
            filepath = os.path.join(root, f)
            items = scan_file(filepath)
            all_items.extend(items)
    
    # 去重
    seen = set()
    unique = []
    for item in all_items:
        key = item[0]
        if key not in seen:
            seen.add(key)
            unique.append(item)
    
    # 生成 UiItem 列表
    lines = []
    for key, pe, pz, ce, cv, desc in unique:
        lines.append(f'    UiItem("{pe}","{pz}","{ce}","{cv}","{desc}", min:0, max:32, defVal:14),')
    
    # 读取现有文件
    with open(OUT) as f:
        content = f.read()
    
    # 替换 all 列表
    pattern = r'(static const all = \[)(.*?)(\];)'
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        print('ERROR: Could not find "static const all = [..." in ui_design.dart')
        sys.exit(1)
    
    new_all = match.group(1) + '\n' + '\n'.join(lines) + '\n    ' + match.group(3)
    content = content[:match.start()] + new_all + content[match.end():]
    
    with open(OUT, 'w') as f:
        f.write(content)
    
    print(f'Generated {len(unique)} UiItem entries in {OUT}')
    for item in unique:
        print(f'  {item[0]}: {item[5]}')

if __name__ == '__main__':
    main()
