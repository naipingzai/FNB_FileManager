# FN File Manager

A cross-platform file manager built with Flutter and a native C layer via FFI.

## Features

### Core
- **File Browser** — Browse, search, sort, multi-select files
- **File Operations** — Copy, move, delete (trash), rename, new file/folder
- **Dual Panel** — Side-by-side file management with cross-panel operations
- **Bookmarks** — Quick access to frequently used directories

### Viewers
- **Text Viewer/Editor** — View and edit text files with syntax info
- **Image Viewer** — Gallery-style image browsing with zoom
- **Video Player** — Media-kit based video playback
- **Audio Player** — PCM/FFmpeg audio decoding and playback
- **PDF Preview** — pdfx-based PDF viewing
- **Markdown Preview** — Rendered markdown display
- **Hex Viewer** — Binary file hex dump with search
- **Ebook Viewer** — EPUB rendering
- **GIF Viewer** — Animated GIF display

### Tools
- **File Compare** — Side-by-side file diff view
- **Duplicate Cleaner** — Multi-path duplicate file detection and cleanup
- **Storage Analysis** — Directory size scanning and large file detection
- **Media Tools** — Video compress, format convert, audio extract, media info
- **Archive** — ZIP/7z/RAR extraction and creation

### Settings
- **Display Settings** — Font size, UI component scaling per page
- **Localization** — English and Chinese (Simplified)
- **Theme** — Light, dark, system modes

## Architecture

```
lib/
  main.dart                 — App entry, theme, locale
  file_browser.dart         — Main file browser UI
  native.dart               — FFI bridge to C layer
  native_bindings_generated.dart — Auto-generated FFI bindings
  utils.dart                — Formatters, file icons
  ui_design.dart            — Dynamic UI configuration system
  file_service.dart         — File service abstraction
  l10n/                     — Localization (EN/ZH)
  viewers/                  — All viewer and tool pages
  widgets/                  — Shared widgets (AppIcon)
  services/                 — Operation queue (async file ops)
native/
  src/                      — C source files (fs, archive, media, gpu)
  include/                  — C header files
scripts/
  check_ui_standards.py     — Code quality check script
  gen_ui_config.py          — Auto-generate UI config
```

## Build

### Prerequisites
- Flutter SDK >= 3.12.2
- Linux: GTK, CMake, Clang

### Commands

```bash
# Build for Linux
flutter build linux

# Run the check script
python3 scripts/check_ui_standards.py

# Generate l10n files
flutter gen-l10n
```

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Privacy

This app collects NO data. All operations are local. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## Disclaimer

See [DISCLAIMER.md](DISCLAIMER.md).
