import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import "package:flutter/cupertino.dart";
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'l10n/l10n.dart';
import 'file_service.dart';
import 'native.dart';
import 'utils.dart';
import 'viewers/image_viewer.dart';
import 'viewers/video_player.dart';
import 'viewers/audio_player.dart';
import 'viewers/text_viewer.dart';
import 'viewers/archive_viewer.dart';
import 'viewers/ebook_viewer.dart';
import 'viewers/hex_viewer.dart';
import 'viewers/media_tools_page.dart';
import 'viewers/video_convert_page.dart';
import 'viewers/gif_page.dart';
import 'viewers/video_compress_page.dart';
import 'viewers/video_trim_page.dart';
import 'viewers/audio_extract_page.dart';
import 'viewers/media_info_page.dart';
import 'ui_design.dart';
import 'package:share_plus/share_plus.dart';
import 'viewers/text_editor_page.dart';
import 'viewers/pdf_preview_page.dart';
import 'viewers/markdown_preview_page.dart';
import 'viewers/storage_analysis_page.dart';
import 'viewers/duplicate_cleaner_page.dart';
import 'viewers/file_compare_page.dart';
import 'viewers/dual_panel_page.dart';
import 'widgets/app_icons.dart';
import 'viewers/display_settings_page.dart';
import 'viewers/settings_page.dart';

class FileBrowserPage extends StatefulWidget {
  final Function(BuildContext) onSwitchLocale;
  final VoidCallback onToggleTheme;
  final List<String> bookmarks;
  final Function(String) onAddBookmark;
  final Function(String) onRemoveBookmark;
  final bool pickVideo;
  final double textScale;
  final Function(double) onTextScaleChanged;
  const FileBrowserPage({super.key, required this.onSwitchLocale, required this.onToggleTheme,
    this.bookmarks = const [], required this.onAddBookmark, required this.onRemoveBookmark,
    this.pickVideo = false, this.textScale = 1.0, required this.onTextScaleChanged});
  @override
  State<FileBrowserPage> createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends State<FileBrowserPage> {
  final _fs = FileService();
  final List<String> _stack = [];
  List<FileEntry> _entries = [];
  bool _loading = true;
  bool _grid = false;
  bool _showHidden = false;
  String _searchQuery = '';
  int _sortMode = 0; // 0=name, 1=size, 2=date, 3=type

  // 剪贴板
  List<String> _clipboardPaths = [];
  bool _clipboardIsCut = false;

  // 多选
  bool _selectMode = false;
  final Set<String> _selected = {};

  // 地址栏
  bool _editingPath = false;
  final _pathController = TextEditingController();

  // 撤销已移除

  String get _currentDir => _stack.isEmpty ? '/' : _stack.last;

  // ── 多选 ──
  void _toggleSelect(String path) { setState(() { _selected.contains(path) ? _selected.remove(path) : _selected.add(path); }); }
  void _selectAll() { setState(() { _selected.addAll(_filteredEntries.map((e) => e.path)); }); }
  void _invertSelection() { setState(() { final all = _filteredEntries.map((e) => e.path).toSet(); _selected.containsAll(all) ? _selected.clear() : _selected.addAll(all.where((p) => !_selected.contains(p))); }); }
  void _exitSelectMode() { setState(() { _selectMode = false; _selected.clear(); }); }

  // ── 批量重命名 ──
  void _showBatchRenameDialog() async {
    final entries = _entries.where((e) => _selected.contains(e.path)).toList();
    if (entries.isEmpty) return;
    int mode = 0; final c1 = TextEditingController(), c2 = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(title: Text(AppLocalizations.of(context)!.batch_rename_title(entries.length)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          SegmentedButton<int>(segments: [
            ButtonSegment(value: 0, label: Text(AppLocalizations.of(context)!.prefix)), ButtonSegment(value: 1, label: Text(AppLocalizations.of(context)!.suffix)),
            ButtonSegment(value: 2, label: Text(AppLocalizations.of(context)!.replaceWith)), ButtonSegment(value: 3, label: Text(AppLocalizations.of(context)!.sequenceNum)),
          ], selected: {mode}, onSelectionChanged: (s) => setS(() => mode = s.first)),
          const SizedBox(height: 12),
          if (mode == 2) TextField(controller: c1, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.find, border: OutlineInputBorder())),
          TextField(controller: c2, decoration: InputDecoration(labelText: [AppLocalizations.of(context)!.batch_rename_prefix, AppLocalizations.of(context)!.batch_rename_suffix, AppLocalizations.of(context)!.batch_rename_replace, AppLocalizations.of(context)!.batch_rename_start_num][mode], border: const OutlineInputBorder())),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, {'mode': mode, 'v1': c1.text, 'v2': c2.text}), child: Text(AppLocalizations.of(context)!.rename))],
      ),
    ));
    if (result == null) return;
    int n = int.tryParse(result['v2'] as String) ?? 1;
    final items = entries.map((e) {
      String nn;
      switch (result['mode'] as int) {
        case 0: nn = '${result['v1']}${e.name}'; break;
        case 1: nn = '${e.name}${result['v2']}'; break;
        case 2: nn = e.name.replaceAll(result['v1'] as String, result['v2'] as String); break;
        default: final ext = p.extension(e.name); nn = '${p.basenameWithoutExtension(e.name)}_${n++}$ext';
      }
      return '{"old":"${e.name}","new":"$nn"}';
    }).toList();
    NativeFs.batchRename(_currentDir, '[${items.join(',')}]');
    _load();
  }

  // ── 新建文件 ──
  void _showNewFileDialog() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.newFile),
      content: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(hintText: AppLocalizations.of(context)!.new_file_hint, border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(AppLocalizations.of(context)!.create))],
    ));
    if (name != null && name.isNotEmpty) { NativeFs.createFile('$_currentDir/$name'); _load(); }
  }

  // ── 地址栏 ──
  void _submitPath() async {
    final path = _pathController.text.trim();
    if (path.isNotEmpty && await Directory(path).exists()) { _stack.clear(); _stack.add(path); _load(); }
    setState(() => _editingPath = false);
  }

  @override
  void initState() { super.initState(); _loadRoot();  }


  @override
  void dispose() {  super.dispose(); }

  static const _permChannel = MethodChannel('com.naipingzai.fn_file_manager/permissions');

  /// 启动时请求全文件访问权限（Android 11+ MANAGE_EXTERNAL_STORAGE）
  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;
    try {
      // 1. 检查 MANAGE_EXTERNAL_STORAGE（Android 11+）
      final granted = await _permChannel.invokeMethod<bool>('isManageExternalStorageGranted') ?? false;
      if (!granted) {
        // 弹窗提示用户去设置页授权
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.needFileAccess),
            content: Text(AppLocalizations.of(context)!.needFileAccessDesc),
            actions: [FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.goAuthorize))],
          ),
        );
        if (proceed == true) {
          await _permChannel.invokeMethod('openAllFilesAccessSettings');
          // 等用户从设置页返回后重新检查
          await Future.delayed(const Duration(seconds: 1));
          final ok = await _permChannel.invokeMethod<bool>('isManageExternalStorageGranted') ?? false;
          if (!ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.fileAccessDenied)));
          }
        }
      }
      // 2. 同时用 permission_handler 请求普通存储权限（Android < 11 兜底）
      await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
    } catch (e) {
      // 非 Android 或 channel 调用失败，忽略
    }
  }

  Future<void> _loadRoot() async {
    await _requestPermissions();
    final roots = await _fs.listRoot();
    if (roots.isNotEmpty) { _stack..clear()..add(roots.first); await _load(); }
    else { setState(() { _entries = []; _loading = false; }); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _fs.listDir(_stack.last, showHidden: _showHidden);
    setState(() { _entries = entries; _loading = false; });
  }

  void _enter(String path) { _stack.add(path); _load(); }
  void _back() { if (_stack.length > 1) { _stack.removeLast(); _load(); } }
  void _navTo(int i) { while (_stack.length > i + 1) _stack.removeLast(); _load(); }

  /// 收集同类型媒体文件列表，用于左右滑动切换
  List<String> _mediaPaths(FileEntry e) {
    final ext = FileService.getFileExt(e.path);
    final mediaExts = _mediaExtGroup(ext);
    if (mediaExts == null) return [e.path];
    return _entries
        .where((f) => !f.isDir && mediaExts.contains(FileService.getFileExt(f.path)))
        .map((f) => f.path)
        .toList();
  }

  List<String>? _mediaExtGroup(String ext) {
    const imgExts = {'.jpg','.jpeg','.png','.gif','.bmp','.webp','.tiff'};
    const vidExts = {'.mp4','.avi','.mkv','.mov','.wmv','.flv','.webm','.ts','.m4v'};
    const audExts = {'.mp3','.wav','.flac','.aac','.ogg','.m4a','.pcm','.raw'};
    if (imgExts.contains(ext)) return imgExts.toList();
    if (vidExts.contains(ext)) return vidExts.toList();
    if (audExts.contains(ext)) return audExts.toList();
    return null;
  }

  static const _binExts = {'.bin','.hex','.elf','.o','.so','.dll','.exe','.apk','.img','.dat','.iso','.dmg','.pyc','.class','.wasm','.pptx','.ppt','.docx','.doc','.xlsx','.xls','.pdf','.ttf','.otf','.woff','.woff2','.cur','.ico'};
  static const _archiveExts = {'.zip','.rar','.7z','.tar','.gz','.bz2','.xz','.zst'};
  static const _epubExts = {'.epub','.mobi'};
  static const _imgExts = {'.jpg','.jpeg','.png','.gif','.bmp','.webp','.tiff'};
  static const _vidExts = {'.mp4','.avi','.mkv','.mov','.wmv','.flv','.webm','.ts','.m4v'};
  static const _audExts = {'.mp3','.wav','.flac','.aac','.ogg','.m4a','.pcm','.raw','.opus','.wma','.amr','.aiff','.ape','.wv'};

  void _openFile(FileEntry e) {
    // 选择视频文件模式：返回路径
    if (widget.pickVideo && _vidExts.contains(FileService.getFileExt(e.path))) {
      Navigator.pop(context, e.path);
      return;
    }
    final ext = FileService.getFileExt(e.path);
    final paths = _mediaPaths(e);
    final idx = paths.indexOf(e.path);
    if (_imgExts.contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ImageViewerPage(paths: paths, index: idx)));
    } else if (_vidExts.contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerPage(paths: paths, index: idx)));
    } else if (_audExts.contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerPage(paths: paths, index: idx)));
    } else if (_archiveExts.contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ArchiveViewerPage(path: e.path)));
    } else if (_epubExts.contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => EbookViewerPage(path: e.path)));
    } else if (ext == '.pdf') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(path: e.path)));
    } else if (ext == '.md' || ext == '.markdown') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MarkdownPreviewPage(path: e.path)));
    } else if (_binExts.contains(ext)) {
      // 二进制文件：提示不支持直接打开，提供十六进制查看选项
      _showBinaryDialog(e);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => TextViewerPage(path: e.path)));
    }
  }

  void _showBinaryDialog(FileEntry e) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      content: Text(AppLocalizations.of(context)!.binaryFileError),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton.icon(
          icon: const Icon(AppIcon.code, size: 18),
          label: Text(AppLocalizations.of(context)!.hexView),
          onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => HexViewerPage(path: e.path))); },
        ),
      ],
    ));
  }

  // ── 文件操作 ──

  List<FileEntry> get _filteredEntries {
    var list = _entries;
    if (_searchQuery.isNotEmpty) list = list.where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    switch (_sortMode) {
      case 1: list = List.of(list)..sort((a, b) { if (a.isDir != b.isDir) return a.isDir ? -1 : 1; return b.size.compareTo(a.size); }); break;
      case 2: list = List.of(list)..sort((a, b) { if (a.isDir != b.isDir) return a.isDir ? -1 : 1; return b.modified.compareTo(a.modified); }); break;
      case 3: list = List.of(list)..sort((a, b) { if (a.isDir != b.isDir) return a.isDir ? -1 : 1; return a.type.compareTo(b.type); }); break;
      default: break;
    }
    return list;
  }

  void _showContextMenu(FileEntry e, TapDownDetails details) {
    final ext = FileService.getFileExt(e.path);
    final isArchive = _archiveExts.contains(ext);
    showMenu<String>(context: context, position: RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, details.globalPosition.dx + 1, details.globalPosition.dy + 1),
      items: [
        if (e.isDir) PopupMenuItem(value: 'open', child: Text(AppLocalizations.of(context)!.open)),
        if (!e.isDir && isArchive) PopupMenuItem(value: 'extract', child: Text(AppLocalizations.of(context)!.extract)),
        if (!e.isDir) PopupMenuItem(value: 'hex', child: Text(AppLocalizations.of(context)!.hexView)),
        PopupMenuItem(value: 'copy', child: Text(AppLocalizations.of(context)!.copyAction)),
        PopupMenuItem(value: 'cut', child: Text(AppLocalizations.of(context)!.cutAction)),
        PopupMenuItem(value: 'rename', child: Text(AppLocalizations.of(context)!.rename)),
        PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.moveToTrash)),
        if (!isArchive) PopupMenuItem(value: 'compress', child: Text(AppLocalizations.of(context)!.compress)),
        PopupMenuItem(value: 'properties', child: Text(AppLocalizations.of(context)!.propertiesAction)),
      ],
    ).then((v) {
      if (v == null) return;
      switch (v) {
        case 'open': e.isDir ? _enter(e.path) : _openFile(e); break;
        case 'extract': Navigator.push(context, MaterialPageRoute(builder: (_) => ArchiveViewerPage(path: e.path))); break;
        case 'hex': Navigator.push(context, MaterialPageRoute(builder: (_) => HexViewerPage(path: e.path))); break;
        case 'copy': _copyToClipboard(e, false); break;
        case 'cut': _copyToClipboard(e, true); break;
        case 'rename': _showRenameDialog(e); break;
        case 'delete': _showDeleteDialog(e); break;
        case 'compress': _showCompressDialog(e); break;
        case 'properties': _showProperties(e); break;
      }
    });
  }

  void _copyToClipboard(FileEntry e, bool cut) {
    _clipboardPaths = [e.path]; _clipboardIsCut = cut;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cut ? AppLocalizations.of(context)!.cut_done(e.name) : AppLocalizations.of(context)!.copy_done(e.name)), duration: const Duration(seconds: 2)));
    setState(() {});
  }

  Future<void> _paste() async {
    if (_clipboardPaths.isEmpty) return;
    int ok = 0, skip = 0, fail = 0;
    for (final src in _clipboardPaths) {
      final name = p.basename(src);
      final dst = '$_currentDir/$name';
      if (await File(dst).exists()) {
        final action = await _showConflictDialog(name);
        if (action == 'skip') { skip++; continue; }
        if (action == 'rename') {
          final ext = p.extension(name);
          final base = p.basenameWithoutExtension(name);
          var i = 1;
          var newPath = dst;
          while (await File(newPath).exists()) {
            newPath = '$_currentDir/${base}_$i$ext'; i++;
          }
          final (rc, _) = _clipboardIsCut ? NativeFs.move(src, newPath) : NativeFs.copy(src, newPath);
          if (rc == 0) ok++; else fail++;
          continue;
        }
        // 'overwrite': fall through
      }
      final (rc, _) = _clipboardIsCut ? NativeFs.move(src, dst) : NativeFs.copy(src, dst);
      if (rc == 0) ok++; else fail++;
    }
    _clipboardPaths.clear(); _clipboardIsCut = false;
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.paste_result(ok) + (skip > 0 ? AppLocalizations.of(context)!.paste_skip(skip) : '') + (fail > 0 ? AppLocalizations.of(context)!.paste_fail(fail) : '')),
    ));
    _load();
  }

  Future<String> _showConflictDialog(String name) async {
    return await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.fileExists),
      content: Text(AppLocalizations.of(context)!.fileExistsMsg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, 'skip'), child: Text(AppLocalizations.of(context)!.skip)),
        TextButton(onPressed: () => Navigator.pop(context, 'rename'), child: Text(AppLocalizations.of(context)!.keepBoth)),
        FilledButton(onPressed: () => Navigator.pop(context, 'overwrite'), child: Text(AppLocalizations.of(context)!.overwrite)),
      ],
    )) ?? 'skip';
  }

  void _showNewFolderDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.newFolder),
      content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: AppLocalizations.of(context)!.new_folder_hint, border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(AppLocalizations.of(context)!.create))],
    ));
    if (name != null && name.isNotEmpty) { NativeFs.mkdir('$_currentDir/$name'); _load(); }
  }

  void _showRenameDialog(FileEntry e) async {
    final controller = TextEditingController(text: e.name);
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.rename),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(AppLocalizations.of(context)!.ok))],
    ));
    if (name != null && name.isNotEmpty && name != e.name) {
      NativeFs.rename(e.path, '${p.dirname(e.path)}/$name');
      _load();
    }
  }

  void _showDeleteDialog(FileEntry e) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.moveToTrash),
      content: Text(AppLocalizations.of(context)!.confirm_trash_msg(e.name)),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.moveAction))],
    ));
    if (ok == true) { NativeFs.trash(e.path); _load(); }
  }

  void _showTrash() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TrashPage()));
  }

  void _showDisplaySettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DisplaySettingsPage(onScaleChanged: widget.onTextScaleChanged, currentScale: widget.textScale))).then((_) => setState(() {}));
  }

  /// 打开文件选择器，选择视频文件后跳转格式转换页


  void _shareFile(FileEntry e) async {
    try {
      // Use url_launcher for sharing on supported platforms
      final uri = Uri.file(e.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cannotOpenFile)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.shareFailed)));
    }
  }

  void _batchTrash() async {
    final paths = _selected.toList();
    for (final p in paths) { NativeFs.trash(p); }
    _exitSelectMode(); _load();
  }

  void _showCompressDialog(FileEntry e) async {
    final baseName = p.basenameWithoutExtension(e.path);
    String fmt = 'zip';
    final nameController = TextEditingController(text: '${baseName}.zip');
    final passController = TextEditingController();
    bool encrypted = false;
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.compress),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.compressFilename, border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'zip', label: Text('ZIP'), icon: Icon(AppIcon.compress, size: 16)),
              ButtonSegment(value: 'tar.gz', label: Text('TAR.GZ'), icon: Icon(CupertinoIcons.archivebox, size: 16)),
              ButtonSegment(value: 'tar.bz2', label: Text('TAR.BZ2'), icon: Icon(CupertinoIcons.archivebox, size: 16)),
              ButtonSegment(value: 'tar.xz', label: Text('TAR.XZ'), icon: Icon(CupertinoIcons.archivebox, size: 16)),
            ],
            selected: {fmt},
            onSelectionChanged: (s) => setDialogState(() {
              fmt = s.first;
              final old = nameController.text;
              final ext = RegExp(r'\.(zip|tar\.gz|tar\.bz2|tar\.xz|tgz|tbz2|txz)$', caseSensitive: false);
              nameController.text = ext.hasMatch(old) ? old.replaceAll(ext, '') + '.' + fmt : old + '.' + fmt;
            }),
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(height: 12),
          if (fmt == 'zip') Row(children: [
            Text(AppLocalizations.of(context)!.encryptCompress), const Spacer(),
            Switch(value: encrypted, onChanged: (v) => setDialogState(() => encrypted = v)),
          ]),
          if (encrypted && fmt == 'zip') TextField(controller: passController, obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password, border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, {
            'name': nameController.text.trim(), 'format': fmt,
            'password': passController.text, 'encrypted': encrypted,
          }), child: Text(AppLocalizations.of(context)!.compress)),
        ],
      ),
    ));
    if (result == null || result['name'] == null || (result['name'] as String).isEmpty) return;
    final zipPath = '${p.dirname(e.path)}/${result['name']}';
    _startCompressWithProgress(e.path, zipPath, result);
  }

  void _startCompressWithProgress(String srcPath, String zipPath, Map<String, dynamic> result) {
    // C 层启动 pthread 压缩，立即返回；进度对话框自行轮询关闭
    NativeArchive.createEx(srcPath, zipPath);
    showDialog(context: context, barrierDismissible: false, builder: (_) => _CompressProgressDialog(onDone: () {
      _load();
      if (mounted) {
        String msg = AppLocalizations.of(context)!.compress_done(result['name']);
        if (result['encrypted'] == true) msg += AppLocalizations.of(context)!.encrypted_suffix;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }));
  }

  void _showProperties(FileEntry e) async {
    final props = await Future(() => NativeFs.properties(e.path));
    if (!mounted || props == null) return;
    String? hash;
    if (!e.isDir) { hash = await Future(() => NativeFs.fileHash(e.path)); }
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pr(AppLocalizations.of(context)!.type, e.isDir ? AppLocalizations.of(context)!.folder : '${props['type'] ?? ''}'),
        _pr(AppLocalizations.of(context)!.size, e.isDir ? '--' : Formatters.formatSize(props['size'] is int ? props['size'] : 0)),
        _pr(AppLocalizations.of(context)!.modified, Formatters.formatTimestamp(props['modified'] is int ? props['modified'] : 0)),
        if (props['created'] != null && (props['created'] as int) > 0)
          _pr(AppLocalizations.of(context)!.created, Formatters.formatTimestamp(props['created'] as int)),
        if (props['mode'] != null) _pr(AppLocalizations.of(context)!.permission, '${props['mode']}'),
        _pr(AppLocalizations.of(context)!.path, e.path),
        if (hash != null && hash.isNotEmpty) ...[
          const Divider(),
          Text(AppLocalizations.of(context)!.propChecksum, style: T.style('File Browser', 'Multi-Select').copyWith(fontWeight: FontWeight.w500)),
          SelectableText('MD5: $hash', style: TextStyle(fontSize: Ui.val('File Browser.File Size'), fontFamily: 'monospace')),
        ],
        if (!e.isDir && hash != null && hash.isEmpty)
          Text(AppLocalizations.of(context)!.calculatingHash, style: T.style('File Browser', 'Compression Format').copyWith(color: Colors.grey)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.closeAction)),
        if (!e.isDir) FilledButton.icon(
          icon: const Icon(AppIcon.share, size: 18),
          label: Text(AppLocalizations.of(context)!.shareAction),
          onPressed: () { Navigator.pop(context); _shareFile(e); },
        ),
      ],
    ));
  }

  Widget _pr(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 60, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: T.style('File Browser', 'File Name'))),
    ]),
  );

  void _showSearch() {
    final ctrl = TextEditingController(text: _searchQuery);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.searchFilename),
      content: TextField(
        controller: ctrl, autofocus: true,
        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.search_hint, prefixIcon: Icon(AppIcon.search), border: OutlineInputBorder()),
        onChanged: (v) => _searchQuery = v,
      ),
      actions: [
        TextButton(onPressed: () { setState(() => _searchQuery = ''); Navigator.pop(context); }, child: Text(AppLocalizations.of(context)!.clearAction)),
        FilledButton(onPressed: () { setState(() {}); Navigator.pop(context); }, child: Text(AppLocalizations.of(context)!.searchAction)),
      ],
    ));
  }

  void _onMenuAction(String v) {
    switch (v) {
      case 'newFolder': _showNewFolderDialog(); break;
      case 'newFile': _showNewFileDialog(); break;
      case 'trash': _showTrash(); break;
      case 'sort0': case 'sort1': case 'sort2': case 'sort3':
        setState(() => _sortMode = int.parse(v.substring(4))); break;
      case 'hidden': setState(() { _showHidden = !_showHidden; _load(); }); break;
      case 'grid': setState(() => _grid = !_grid); break;
      case 'lang': widget.onSwitchLocale(context); break;
      case 'theme': widget.onToggleTheme(); break;
      case 'bookmark':
        if (widget.bookmarks.contains(_currentDir)) { widget.onRemoveBookmark(_currentDir); }
        else { widget.onAddBookmark(_currentDir); }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_stack.length > 1) { _back(); }
        else { SystemNavigator.pop(); }
      },
      child: Scaffold(
      drawer: Drawer(child: SafeArea(child: ListView(padding: EdgeInsets.zero, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(Localizations.localeOf(context).languageCode == 'zh' ? '导航栏' : 'Navigation', style: T.style('File Browser', 'App Bar Title'))),
        ListTile(leading: const Icon(AppIcon.home), title: Text(AppLocalizations.of(context)!.homeDir),
          onTap: () { Navigator.pop(context); _stack.clear(); _loadRoot(); }),
        const Divider(),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(AppLocalizations.of(context)!.bookmarks, style: T.style('File Browser', 'Multi-Select').copyWith(color: Colors.grey))),
        if (widget.bookmarks.isEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text(AppLocalizations.of(context)!.bookmarkHint, style: T.style('File Browser', 'Multi-Select').copyWith(color: Colors.grey))),
        ...widget.bookmarks.map((bm) => ListTile(
          leading: const Icon(AppIcon.bookmark, size: 20), title: Text(bm, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.style('File Browser', 'File Name')), dense: true,
          onTap: () { Navigator.pop(context); _stack.clear(); _stack.add(bm); _load(); },
          trailing: IconButton(icon: const Icon(AppIcon.close, size: 16), onPressed: () => widget.onRemoveBookmark(bm)),
        )),
        const Divider(),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(Localizations.localeOf(context).languageCode == 'zh' ? '文件工具' : 'File Tools', style: T.style('File Browser', 'Multi-Select').copyWith(color: Colors.grey))),
        ListTile(leading: const Icon(CupertinoIcons.doc_on_doc, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '文件对比' : 'File Compare'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const FileComparePage())); }),
        ListTile(leading: const Icon(CupertinoIcons.doc_on_doc, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '重复文件清理' : 'Duplicate Cleaner'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DuplicateCleanerPage())); }),
        ListTile(leading: const Icon(AppIcon.analytics, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '存储分析' : 'Storage Analysis'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const StorageAnalysisPage())); }),
        ListTile(leading: const Icon(CupertinoIcons.square_grid_2x2, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '双面板' : 'Dual Panel'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => DualPanelPage(initialPath: _currentDir))); }),
        const Divider(),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(Localizations.localeOf(context).languageCode == 'zh' ? '媒体工具' : 'Media Tools', style: T.style('File Browser', 'Multi-Select').copyWith(color: Colors.grey))),
        ListTile(leading: const Icon(AppIcon.analytics, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '格式转换' : 'Format Convert'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoConvertPage())); }),
        ListTile(leading: const Icon(AppIcon.image, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? 'GIF制作' : 'Make GIF'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const GifPage())); }),
        ListTile(leading: const Icon(AppIcon.compress, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '视频压缩' : 'Video Compress'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoCompressPage())); }),
        ListTile(leading: const Icon(AppIcon.cut, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '视频裁剪' : 'Video Trim'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoTrimPage())); }),
        ListTile(leading: const Icon(AppIcon.audio, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '音频提取' : 'Audio Extract'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AudioExtractPage())); }),
        ListTile(leading: const Icon(AppIcon.info, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '媒体信息' : 'Media Info'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaInfoPage())); }),
        const Divider(),
        ListTile(leading: const Icon(AppIcon.settings), title: Text(AppLocalizations.of(context)!.displaySettingsTitle),
          onTap: () { Navigator.pop(context); _showDisplaySettings(); },),
        ListTile(leading: const Icon(CupertinoIcons.globe, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '语言' : 'Language'),
          onTap: () { Navigator.pop(context); widget.onSwitchLocale(context); }),
        ListTile(leading: const Icon(CupertinoIcons.info, size: 20),
          title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '关于' : 'About'),
          onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())); }),
      ]))),
      appBar: AppBar(
        leading: _stack.length > 1 ? IconButton(icon: const Icon(AppIcon.close), onPressed: _back) : null,
        title: Text(_stack.isEmpty ? l10n.files : p.basename(_stack.last), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          // 核心操作直接显示
          IconButton(icon: const Icon(AppIcon.search), onPressed: _showSearch, tooltip: l10n.search),
          if (_clipboardPaths.isNotEmpty)
            IconButton(icon: const Icon(AppIcon.paste), onPressed: _paste, tooltip: AppLocalizations.of(context)!.paste_tooltip),
          // 其余全部收入溢出菜单
          PopupMenuButton<String>(
            icon: const Icon(CupertinoIcons.ellipsis),
            onSelected: _onMenuAction,
            itemBuilder: (_) => [
              PopupMenuItem(value: 'newFolder', child: Row(children: [Icon(AppIcon.folderAdd, size: 20), SizedBox(width: 8), Text(AppLocalizations.of(context)!.newFolder)])),
              PopupMenuItem(value: 'newFile', child: Row(children: [Icon(AppIcon.fileAdd, size: 20), SizedBox(width: 8), Text(AppLocalizations.of(context)!.newFile)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'trash', child: Row(children: [Icon(AppIcon.delete, size: 20), SizedBox(width: 8), Text(AppLocalizations.of(context)!.trashTitle)])),
              const PopupMenuDivider(),
              // 排序子项
              PopupMenuItem(value: 'sort0', child: Row(children: [Icon(_sortMode == 0 ? AppIcon.check : AppIcon.selectAll, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.sortByName)])),
              PopupMenuItem(value: 'sort1', child: Row(children: [Icon(_sortMode == 1 ? AppIcon.check : AppIcon.selectAll, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.sortBySize)])),
              PopupMenuItem(value: 'sort2', child: Row(children: [Icon(_sortMode == 2 ? AppIcon.check : AppIcon.selectAll, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.sortByDate)])),
              PopupMenuItem(value: 'sort3', child: Row(children: [Icon(_sortMode == 3 ? AppIcon.check : AppIcon.selectAll, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.sortByType)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'hidden', child: Row(children: [Icon(_showHidden ? AppIcon.visibility : AppIcon.visibilityOff, size: 20), const SizedBox(width: 8), Text(_showHidden ? AppLocalizations.of(context)!.hide_hidden : AppLocalizations.of(context)!.show_hidden)])),
              PopupMenuItem(value: 'grid', child: Row(children: [Icon(_grid ? AppIcon.listView : AppIcon.gridView, size: 20), const SizedBox(width: 8), Text(_grid ? AppLocalizations.of(context)!.list_view : AppLocalizations.of(context)!.grid_view)])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'bookmark', child: Row(children: [
                  Icon(widget.bookmarks.contains(_currentDir) ? AppIcon.bookmark : AppIcon.bookmarkFilled, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.bookmarks.contains(_currentDir) ? AppLocalizations.of(context)!.remove_bookmark : AppLocalizations.of(context)!.add_bookmark),
                ])),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'theme', child: Row(children: [Icon(Theme.of(context).brightness == Brightness.dark ? CupertinoIcons.sun_max : CupertinoIcons.moon, size: 20), const SizedBox(width: 8), Text(Theme.of(context).brightness == Brightness.dark ? AppLocalizations.of(context)!.light_mode : AppLocalizations.of(context)!.dark_mode)])),
            ],
          ),
        ],
      ),
      body: Column(children: [
        // 地址栏 / 面包屑
        Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            Expanded(child: _editingPath ? TextField(
              controller: _pathController..text = _currentDir,
              autofocus: true, style: T.style('File Browser', 'Address Bar'),
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
              onSubmitted: (_) => _submitPath(),
              onEditingComplete: _submitPath,
            ) : GestureDetector(
              onDoubleTap: () { _pathController.text = _currentDir; setState(() => _editingPath = true); },
              child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _stack.length,
                itemBuilder: (_, i) => Row(mainAxisSize: MainAxisSize.min, children: [
                  if (i > 0) const Icon(CupertinoIcons.chevron_right, size: 16),
                  TextButton(onPressed: () => _navTo(i), child: Text(i == 0 ? '/' : p.basename(_stack[i]))),
                ]),
              ),
            )),
            IconButton(
              icon: Icon(_editingPath ? AppIcon.check : AppIcon.edit, size: 18),
              onPressed: () {
                if (_editingPath) { _submitPath(); }
                else { _pathController.text = _currentDir; setState(() => _editingPath = true); }
              },
              tooltip: _editingPath ? AppLocalizations.of(context)!.confirm_tooltip : AppLocalizations.of(context)!.edit_path_tooltip,
              padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32),
            ),
          ]),
        ),
        // 多选工具栏
        if (_selectMode) Container(
          height: 40, color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(children: [
            IconButton(icon: const Icon(AppIcon.close, size: 20), onPressed: _exitSelectMode),
            Text(AppLocalizations.of(context)!.selected_n(_selected.length), style: T.style('File Browser', 'File Name')),
            const Spacer(),
            TextButton(onPressed: _selectAll, child: Text(AppLocalizations.of(context)!.selectAll, style: T.style('File Browser', 'Multi-Select'))),
            TextButton(onPressed: _invertSelection, child: Text(AppLocalizations.of(context)!.invertSelection, style: T.style('File Browser', 'Multi-Select'))),
            if (_selected.isNotEmpty) ...[
              IconButton(icon: const Icon(AppIcon.cut, size: 20), onPressed: () { _clipboardPaths = _selected.toList(); _clipboardIsCut = true; _exitSelectMode(); }),
              IconButton(icon: const Icon(AppIcon.copy, size: 20), onPressed: () { _clipboardPaths = _selected.toList(); _clipboardIsCut = false; _exitSelectMode(); }),
              IconButton(icon: const Icon(AppIcon.edit, size: 20), onPressed: _showBatchRenameDialog, tooltip: AppLocalizations.of(context)!.batch_rename_tooltip),
              IconButton(icon: const Icon(AppIcon.delete, size: 20), onPressed: _batchTrash, tooltip: AppLocalizations.of(context)!.batch_trash_tooltip),
            ],
          ]),
        ),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator())
            : _filteredEntries.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                Icon(AppIcon.folderOpen, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16), Text(_searchQuery.isNotEmpty ? '未找到匹配项' : l10n.noFiles),
              ]))
            : _grid ? GridView.builder(key: ValueKey(_currentDir), padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1, mainAxisSpacing: 4, crossAxisSpacing: 4),
                itemCount: _filteredEntries.length, itemBuilder: (_, i) => _gridTile(_filteredEntries[i]))
            : Scrollbar(thumbVisibility: true, child: ListView.builder(key: ValueKey(_currentDir), itemCount: _filteredEntries.length, itemBuilder: (_, i) => _listTile(_filteredEntries[i]), primary: true))),
      ]), // Column
      ), // Scaffold
    ); // PopScope
  }

  Widget _listTile(FileEntry e) {
    final cs = Theme.of(context).colorScheme;
    final isSel = _selected.contains(e.path);
    return Container(
      color: isSel ? cs.primaryContainer.withOpacity(0.4) : null,
      child: GestureDetector(
        onSecondaryTapDown: (d) => _showContextMenu(e, d),
        child: ListTile(
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!_selectMode) {
                setState(() { _selectMode = true; _selected.add(e.path); });
              } else {
                _toggleSelect(e.path);
              }
            },
            child: Icon(FileIcons.iconForType(e.type), color: isSel ? cs.primary : FileIcons.colorForType(e.type, cs)),
          ),
          title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: e.isDir ? null : Text('${Formatters.formatSize(e.size)} · ${Formatters.formatTimestamp(e.modified)}'),
        trailing: PopupMenuButton<String>(
          icon: const Icon(CupertinoIcons.ellipsis, size: 20),
          onSelected: (v) {
            switch (v) {
              case 'open': e.isDir ? _enter(e.path) : _openFile(e); break;
              case 'extract': Navigator.push(context, MaterialPageRoute(builder: (_) => ArchiveViewerPage(path: e.path))); break;
              case 'hex': Navigator.push(context, MaterialPageRoute(builder: (_) => HexViewerPage(path: e.path))); break;
              case 'copy': _copyToClipboard(e, false); break;
              case 'cut': _copyToClipboard(e, true); break;
              case 'rename': _showRenameDialog(e); break;
              case 'delete': _showDeleteDialog(e); break;
              case 'compress': _showCompressDialog(e); break;
              case 'convert': Navigator.push(context, MaterialPageRoute(builder: (_) => VideoConvertPage())); break;
              case 'properties': _showProperties(e); break;
            }
          },
          itemBuilder: (_) {
            final ext = FileService.getFileExt(e.path);
            final isArchive = _archiveExts.contains(ext);
            return [
              if (e.isDir) PopupMenuItem(value: 'open', child: Text(AppLocalizations.of(context)!.open)),
              if (!e.isDir && isArchive) PopupMenuItem(value: 'extract', child: Text(AppLocalizations.of(context)!.extract)),
              if (!e.isDir) PopupMenuItem(value: 'hex', child: Text(AppLocalizations.of(context)!.hexView)),
              if (e.type == 'video') PopupMenuItem(value: 'convert', child: Text(AppLocalizations.of(context)!.formatConvert)),
              PopupMenuItem(value: 'copy', child: Text(AppLocalizations.of(context)!.copyAction)),
              PopupMenuItem(value: 'cut', child: Text(AppLocalizations.of(context)!.cutAction)),
              PopupMenuItem(value: 'rename', child: Text(AppLocalizations.of(context)!.rename)),
              PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.moveToTrash)),
              if (!isArchive) PopupMenuItem(value: 'compress', child: Text(AppLocalizations.of(context)!.compress)),
              PopupMenuItem(value: 'properties', child: Text(AppLocalizations.of(context)!.propertiesAction)),
            ];
          },
        ),
        onTap: () { e.isDir ? _enter(e.path) : _openFile(e); },
      ),
      ),
    );
  }

  Widget _gridTile(FileEntry e) {
    final cs = Theme.of(context).colorScheme;
    final isSel = _selected.contains(e.path);
    return Card(child: InkWell(borderRadius: BorderRadius.circular(12),
      onLongPress: () { if (_selectMode) _toggleSelect(e.path); else _showProperties(e); },
      onTap: () => e.isDir ? _enter(e.path) : _openFile(e),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_selectMode) {
              setState(() { _selectMode = true; _selected.add(e.path); });
            } else {
              _toggleSelect(e.path);
            }
          },
          child: Padding(padding: const EdgeInsets.only(top: 8),
            child: Icon(FileIcons.iconForType(e.type), size: 32, color: isSel ? cs.primary : FileIcons.colorForType(e.type, cs))),
        ),
        const SizedBox(height: 6),
        Text(e.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          style: T.style('File Browser', 'File Name')),
        if (!e.isDir) Padding(padding: const EdgeInsets.only(top: 2),
          child: Text(Formatters.formatSize(e.size), style: T.style('File Browser', 'File Size').copyWith( color: cs.onSurfaceVariant))),
      ]),
    ));
  }
}

/// 显示设置弹窗（字体组 + 预设 + 全局缩放）
class _CompressProgressDialog extends StatefulWidget {
  final VoidCallback? onDone;
  const _CompressProgressDialog({this.onDone});
  @override
  State<_CompressProgressDialog> createState() => _CompressProgressDialogState();
}

class _CompressProgressDialogState extends State<_CompressProgressDialog> {
  Timer? _timer;
  int _current = 0, _total = 0;
  String _file = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _poll());
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _poll() {
    final pg = NativeArchive.getProgress();
    if (!mounted) return;
    setState(() { _current = pg.current; _total = pg.total; _file = pg.file; });
    if (!pg.running) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
        widget.onDone?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(AppLocalizations.of(context)!.compressingStatus, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Text(p.basename(_file), maxLines: 1, overflow: TextOverflow.ellipsis, style: T.style('File Browser', 'Address Bar').copyWith( color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: _total > 0 ? _current / _total : null),
        const SizedBox(height: 8),
        Text('$_current / $_total', style: T.style('File Browser', 'Multi-Select').copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}


/// 回收站页面
class TrashPage extends StatefulWidget {
  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  List<FileEntry> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  void _load() {
    setState(() { _loading = true; });
    final entries = NativeFs.trashList();
    setState(() { _items = entries; _loading = false; });
  }

  void _restore(FileEntry e) {
    final name = e.name;
    final (rc, _) = NativeFs.trashRestore(name);
    if (rc == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.restored)));
    }
    _load();
  }

  void _emptyTrash() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.emptyTrashAction),
      content: Text(AppLocalizations.of(context)!.emptyTrashConfirm),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: Text(AppLocalizations.of(context)!.emptyAction))],
    ));
    if (ok == true) { NativeFs.trashEmpty(); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trashTitle),
        actions: [
          if (_items.isNotEmpty)
            IconButton(icon: const Icon(AppIcon.trashEmpty), onPressed: _emptyTrash, tooltip: AppLocalizations.of(context)!.empty_trash_tooltip),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(AppIcon.delete, size: 64, color: Colors.grey), SizedBox(height: 16), Text(AppLocalizations.of(context)!.trashEmpty),
            ]))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final e = _items[i];
                return ListTile(
                  leading: Icon(AppIcon.delete, color: Colors.grey.shade600),
                  title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(Formatters.formatSize(e.size)),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.arrow_counterclockwise, color: Colors.blue),
                    onPressed: () => _restore(e),
                    tooltip: AppLocalizations.of(context)!.restore_tooltip,
                  ),
                );
              },
            ),
    );
  }
}


/// 撤销操作数据类

