# FN 文件管理器

基于 Flutter 和 C 原生层（通过 FFI）的跨平台文件管理器。

## 功能

### 核心
- **文件浏览器** — 浏览、搜索、排序、多选文件
- **文件操作** — 复制、移动、删除（回收站）、重命名、新建文件/文件夹
- **双面板** — 左右并排文件管理，跨面板操作
- **书签** — 快速访问常用目录

### 查看器
- **文本查看/编辑器** — 查看和编辑文本文件
- **图片查看器** — 相册式图片浏览，支持缩放
- **视频播放器** — 基于 media-kit 的视频播放
- **音频播放器** — PCM/FFmpeg 音频解码播放
- **PDF 预览** — 基于 pdfx 的 PDF 查看
- **Markdown 预览** — 渲染 Markdown 显示
- **十六进制查看器** — 二进制文件十六进制查看与搜索
- **电子书阅读器** — EPUB 渲染
- **GIF 查看器** — 动态 GIF 显示

### 工具
- **文件对比** — 并排文件差异对比
- **重复文件清理** — 多路径重复文件检测与清理
- **存储分析** — 目录大小扫描与大文件检测
- **媒体工具** — 视频压缩、格式转换、音频提取、媒体信息
- **压缩包** — ZIP/7z/RAR 解压与创建

### 设置
- **显示设置** — 字体大小、UI 组件缩放
- **国际化** — 中英文支持
- **主题** — 浅色、深色、跟随系统

## 架构

```
lib/
  main.dart                 — 应用入口、主题、语言
  file_browser.dart         — 主文件浏览器界面
  native.dart               — FFI 桥接层
  native_bindings_generated.dart — 自动生成的 FFI 绑定
  utils.dart                — 格式化工具、文件图标
  ui_design.dart            — 动态 UI 配置系统
  file_service.dart         — 文件服务抽象
  l10n/                     — 国际化（中英文）
  viewers/                  — 所有查看器和工具页面
  widgets/                  — 共享组件
  services/                 — 操作队列（异步文件操作）
native/
  src/                      — C 源代码
  include/                  — C 头文件
scripts/
  check_ui_standards.py     — 代码质量检查脚本
  gen_ui_config.py          — 自动生成 UI 配置
```

## 构建

### 前提条件
- Flutter SDK >= 3.12.2
- Linux: GTK, CMake, Clang

### 命令

```bash
# 构建 Linux
flutter build linux

# 运行检查脚本
python3 scripts/check_ui_standards.py

# 生成本地化文件
flutter gen-l10n
```

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE)。

## 隐私

本应用不收集任何数据，所有操作均在本地进行。详见 [PRIVACY_POLICY.md](PRIVACY_POLICY.md)。

## 免责声明

详见 [DISCLAIMER.md](DISCLAIMER.md)。
