import "package:flutter/cupertino.dart";
import 'dart:async';
import '../widgets/app_icons.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../file_service.dart';
import '../utils.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class VideoConvertPage extends StatefulWidget {
  const VideoConvertPage({super.key});
  @override
  State<VideoConvertPage> createState() => _VCPageState();
}

class _VCPageState extends State<VideoConvertPage> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  String _codec = 'h264';
  String _container = 'mp4';
  int _bitrate = 0;
  int _maxWidth = 0;
  bool _converting = false;
  bool _inputIsDir = false;
  int _current = 0, _total = 0;
  Timer? _progressTimer;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _browseInput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(
      builder: (_) => _FilePicker()));
    if (path != null && mounted) {
      final isDir = await Directory(path).exists();
      setState(() {
        _inputCtrl.text = _normPath(path);
        _inputIsDir = isDir;
        if (isDir) { _outputCtrl.text = _normPath(path); }
      });
    }
  }

  void _browseOutput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(
      builder: (_) => _FilePicker()));
    if (path != null && mounted) {
      setState(() { _outputCtrl.text = _normPath(path); });
    }
  }

  /// 规范化路径，去除多余斜杠
  String _normPath(String p) => p.replaceAll('//', '/');
  String get _input => _normPath(_inputCtrl.text.trim());
  String get _outputDir => _normPath(_outputCtrl.text.trim());

  bool get _hasInput => _input.isNotEmpty;
  bool get _hasOutput => _outputDir.isNotEmpty;

  void _showConfigAndStart() {
    if (!_hasInput || !_hasOutput) return;
    _startConvert();
  }

  Future<List<String>> _getInputFiles() async {
    if (await File(_input).exists()) return [_input];
    if (await Directory(_input).exists()) {
      final exts = ['.mp4','.avi','.mkv','.mov','.wmv','.flv','.webm','.ts','.m4v'];
      final entities = await Directory(_input).list().toList();
      return entities.whereType<File>()
        .where((f) => exts.contains(p.extension(f.path).toLowerCase()))
        .map((f) => f.path).toList();
    }
    return [];
  }

  void _startConvert() async {
    final files = await _getInputFiles();
    if (files.isEmpty) { setState(() { _error = AppLocalizations.of(context)!.no_video_files; }); return; }
    setState(() { _converting = true; _error = null; _done = false; _current = 0; _total = files.length; });
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final (c, t) = NativeVideoConvert.getProgress();
      if (mounted) setState(() { _current = c; _total = t > 0 ? t : files.length; });
    });
    for (int i = 0; i < files.length; i++) {
      final f = files[i];
      final outBase = '$_outputDir/${p.basenameWithoutExtension(f)}_converted';
      // 用 Future 让出事件循环，保持 UI 响应
      final rc = await Future(() =>
        NativeVideoConvert.convert(f, outBase, codec: _codec, container: _container,
          bitrate: _bitrate, maxWidth: _maxWidth));
      if (rc != 0) { _progressTimer?.cancel(); setState(() { _converting = false; _error = AppLocalizations.of(context)!.convert_failed_file(p.basename(f)); }); return; }
      setState(() { _current = i + 1; });
    }
    _progressTimer?.cancel();
    if (mounted) setState(() { _converting = false; _done = true; });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.formatConvert, style: T.style('File Browser', 'App Bar Title'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // 输入文件
        Text("输出目录", style: T.style('File Browser', 'File Name').copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _inputCtrl, style: T.style('File Browser', 'File Name'),
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.select_video_file_or_dir, border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            onChanged: (_) => setState(() {}))),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(icon: Icon(AppIcon.folderOpen, size: 18), label: Text(AppLocalizations.of(context)!.browseBtn),
            onPressed: _browseInput),
        ]),
        if (_hasInput && _inputIsDir) ...[
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.convertAllInDir, style: T.style('Format Convert', 'caption', c: cs.onSurfaceVariant)),
        ],
        const SizedBox(height: 16),
        // 输出目录
        Text(AppLocalizations.of(context)!.inputFileDir, style: T.style('File Browser', 'File Name').copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _outputCtrl, style: T.style('File Browser', 'File Name'),
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.select_output_dir, border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            onChanged: (_) => setState(() {}))),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(icon: Icon(AppIcon.folderOpen, size: 18), label: Text(AppLocalizations.of(context)!.browseBtn),
            onPressed: _browseOutput),
        ]),
        const SizedBox(height: 24),
        // Codec
        Text(AppLocalizations.of(context)!.codecFormat, style: T.style('File Browser', 'File Name').copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(segments: [
          ButtonSegment(value: 'h264', label: Text('H.264')),
          ButtonSegment(value: 'h265', label: Text('H.265')),
          ButtonSegment(value: 'copy', label: Text(AppLocalizations.of(context)!.copy)),
        ], selected: {_codec}, onSelectionChanged: _converting ? null : (s) => setState(() => _codec = s.first)),
        const SizedBox(height: 16),
        // Container
        Text(AppLocalizations.of(context)!.containerFormat, style: T.style('File Browser', 'File Name').copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(segments: [
          ButtonSegment(value: 'mp4', label: Text('MP4')),
          ButtonSegment(value: 'mkv', label: Text('MKV')),
          ButtonSegment(value: 'avi', label: Text('AVI')),
          ButtonSegment(value: 'flv', label: Text('FLV')),
          ButtonSegment(value: 'webm', label: Text('WEBM')),
        ], selected: {_container}, onSelectionChanged: _converting ? null : (s) => setState(() => _container = s.first)),
        const SizedBox(height: 16),
        // Bitrate
        DropdownButtonFormField<int>(value: _bitrate,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.bitrateKbps, border: const OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.autoBitrate)),
            DropdownMenuItem(value: 1000, child: Text('1000 kbps')),
            DropdownMenuItem(value: 2000, child: Text('2000 kbps')),
            DropdownMenuItem(value: 4000, child: Text('4000 kbps')),
            DropdownMenuItem(value: 8000, child: Text('8000 kbps')),
          ], onChanged: _converting ? null : (v) => setState(() => _bitrate = v ?? 0)),
        const SizedBox(height: 16),
        // Resolution
        DropdownButtonFormField<int>(value: _maxWidth,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.resolutionScale, border: const OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.keepOriginal)),
            DropdownMenuItem(value: 640, child: Text('640p')),
            DropdownMenuItem(value: 1280, child: Text('720p')),
            DropdownMenuItem(value: 1920, child: Text('1080p')),
          ], onChanged: _converting ? null : (v) => setState(() => _maxWidth = v ?? 0)),
        const SizedBox(height: 24),
        // 转换按钮
        if (_converting) ...[
          LinearProgressIndicator(value: _total > 0 ? _current / _total : null),
          const SizedBox(height: 8),
          Row(children: [
            Text('$_current / $_total', style: T.style('File Browser', 'Address Bar').copyWith( color: cs.onSurfaceVariant)),
            const Spacer(),
            TextButton(onPressed: () { NativeVideoConvert.cancel(); _progressTimer?.cancel(); setState(() => _converting = false); },
              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.red))),
          ]),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Row(children: [const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: 16), const SizedBox(width: 8),
            Expanded(child: Text(_error!, style: T.style('Format Convert', 'Address Bar', c: cs.error)))]),
        ],
        if (_done) ...[
          const SizedBox(height: 8),
          Row(children: [Icon(CupertinoIcons.checkmark_circle, color: Colors.green, size: 16), const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.convertComplete, style: T.style('Format Convert', 'Address Bar', c: Colors.green))]),
        ],
        if (!_converting) ...[
          SizedBox(width: double.infinity, child: FilledButton.icon(
            icon: Icon(AppIcon.play), label: Text(AppLocalizations.of(context)!.startConvert),
            onPressed: (_hasInput && _hasOutput) ? _showConfigAndStart : null)),
        ],
      ]),
    );
  }
}

class _ConfigDialog extends StatefulWidget {
  final String codec, container;
  final int bitrate, maxWidth;
  final Function(String, String, int, int) onConfirm;
  const _ConfigDialog({required this.codec, required this.container,
    required this.bitrate, required this.maxWidth, required this.onConfirm});
  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  late String _codec, _container;
  late int _bitrate, _maxWidth;
  @override
  void initState() {
    super.initState();
    _codec = widget.codec; _container = widget.container;
    _bitrate = widget.bitrate; _maxWidth = widget.maxWidth;
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.outputSettings, style: T.style('File Browser', 'App Bar Title')),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.codecFormat, style: T.style('File Browser', 'File Name').copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(segments: [
          ButtonSegment(value: 'h264', label: Text('H.264')),
          ButtonSegment(value: 'h265', label: Text('H.265')),
          ButtonSegment(value: 'copy', label: Text(AppLocalizations.of(context)!.copy)), ],
          selected: {_codec}, onSelectionChanged: (s) => setState(() => _codec = s.first)),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.containerFormat, style: T.style('File Browser', 'File Name').copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(segments: [
          ButtonSegment(value: 'mp4', label: Text('MP4')),
          ButtonSegment(value: 'mkv', label: Text('MKV')),
          ButtonSegment(value: 'avi', label: Text('AVI')),
          ButtonSegment(value: 'flv', label: Text('FLV')),
          ButtonSegment(value: 'webm', label: Text('WEBM')), ],
          selected: {_container}, onSelectionChanged: (s) => setState(() => _container = s.first)),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(value: _bitrate,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.bitrateKbps, border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.autoBitrate)),
            DropdownMenuItem(value: 1000, child: Text('1000 kbps')),
            DropdownMenuItem(value: 2000, child: Text('2000 kbps')),
            DropdownMenuItem(value: 4000, child: Text('4000 kbps')),
            DropdownMenuItem(value: 8000, child: Text('8000 kbps')), ],
          onChanged: (v) => setState(() => _bitrate = v ?? 0),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(value: _maxWidth,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.resolutionScale, border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.keepOriginal)),
            DropdownMenuItem(value: 640, child: Text('640p')),
            DropdownMenuItem(value: 1280, child: Text('720p')),
            DropdownMenuItem(value: 1920, child: Text('1080p')), ],
          onChanged: (v) => setState(() => _maxWidth = v ?? 0),
        ),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () { Navigator.pop(context); widget.onConfirm(_codec, _container, _bitrate, _maxWidth); },
          child: Text(AppLocalizations.of(context)!.startConvert)),
      ],
    );
  }
}

class _FilePicker extends StatefulWidget {
  @override
  State<_FilePicker> createState() => _FilePickerState();
}

class _FilePickerState extends State<_FilePicker> {
  final _fs = FileService();
  String _dir = '/';
  List<FileEntry> _entries = [];
  bool _loading = true;
  @override
  void initState() { super.initState(); _initDir(); }

  void _initDir() async {
    final roots = await NativeFs.listRoot();
    if (roots.isNotEmpty) { _dir = roots.first; }
    _load();
  }

  void _load() async {
    setState(() { _loading = true; });
    _entries = await _fs.listDir(_dir);
    setState(() { _loading = false; });
  }

  String _norm(String s) => s.replaceAll('//', '/');
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_dir, maxLines: 1, overflow: TextOverflow.ellipsis)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _norm(_dir)),
        label: Text(AppLocalizations.of(context)!.selectThisDir), icon: Icon(AppIcon.check)),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : Scrollbar(thumbVisibility: true, child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (_, i) {
                final e = _entries[i];
                return ListTile(
                  leading: Icon(FileIcons.iconForType(e.type), color: FileIcons.colorForType(e.type, cs)),
                  title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: e.isDir ? null : Text(Formatters.formatSize(e.size) + ' · ' + Formatters.formatTimestamp(e.modified)),
                  trailing: e.isDir ? Icon(CupertinoIcons.chevron_right, size: 20) : null,
                  onTap: () {
                    if (e.isDir) {
                      setState(() { _dir = _norm(e.path); _load(); });
                    } else {
                      Navigator.pop(context, _norm(e.path));
                    }
                  },
                );
              },
            )),
    );
  }
}

