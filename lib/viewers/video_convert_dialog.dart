import "package:flutter/cupertino.dart";
import 'dart:async';
import '../widgets/app_icons.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

/// 视频格式转换对话框
class VideoConvertDialog extends StatefulWidget {
  final String inputPath;
  const VideoConvertDialog({super.key, required this.inputPath});
  @override
  State<VideoConvertDialog> createState() => _VCDState();
}

class _VCDState extends State<VideoConvertDialog> {
  String _codec = 'h264';
  String _container = 'mp4';
  int _bitrate = 0;
  int _maxWidth = 0;
  bool _converting = false;
  int _current = 0, _total = 0;
  Timer? _progressTimer;
  String? _error;
  bool _done = false;

  String get _outputBase {
    final base = p.basenameWithoutExtension(widget.inputPath);
    final dir = p.dirname(widget.inputPath);
    return '$dir/${base}_converted';
  }

  String get _outputPath => '$_outputBase.$_container';

  @override
  void dispose() { _progressTimer?.cancel(); super.dispose(); }

  void _start() {
    setState(() { _converting = true; _error = null; _done = false; });
    // 后台执行转换（C层阻塞调用）
    Future(() async {
      final rc = NativeVideoConvert.convert(widget.inputPath, _outputBase,
        codec: _codec, container: _container, bitrate: _bitrate, maxWidth: _maxWidth);
      if (mounted) {
        if (rc != 0) setState(() { _error = AppLocalizations.of(context)!.convert_failed_code(rc); _converting = false; });
        else setState(() { _done = true; _converting = false; });
      }
    });
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) => _pollProgress());
  }

  void _pollProgress() {
    final (c, t) = NativeVideoConvert.getProgress();
    if (mounted) setState(() { _current = c; _total = t; });
    if (c >= t && t > 0) _progressTimer?.cancel();
  }

  void _cancel() { NativeVideoConvert.cancel(); _progressTimer?.cancel(); setState(() => _converting = false); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.videoFormatConvert),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.input_label(p.basename(widget.inputPath)), style: T.style('Convert Dialog', 'caption', c: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.codecFormat, style: TextStyle(fontWeight: FontWeight.w500)),
        SegmentedButton<String>(segments: [
          ButtonSegment(value: 'h264', label: Text('H.264')),
          ButtonSegment(value: 'h265', label: Text('H.265')),
          ButtonSegment(value: 'copy', label: Text(AppLocalizations.of(context)!.copy)),
        ], selected: {_codec}, onSelectionChanged: _converting ? null : (s) => setState(() => _codec = s.first)),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context)!.containerFormat, style: TextStyle(fontWeight: FontWeight.w500)),
        SegmentedButton<String>(segments: [
          ButtonSegment(value: 'mp4', label: Text('MP4')),
          ButtonSegment(value: 'mkv', label: Text('MKV')),
          ButtonSegment(value: 'avi', label: Text('AVI')),
          ButtonSegment(value: 'flv', label: Text('FLV')),
          ButtonSegment(value: 'mov', label: Text('MOV')),
          ButtonSegment(value: 'webm', label: Text('WEBM')),
        ], selected: {_container}, onSelectionChanged: _converting ? null : (s) => setState(() => _container = s.first)),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _bitrate, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.bitrateKbps, border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.autoBitrate)),
            DropdownMenuItem(value: 1000, child: Text('1000 kbps')),
            DropdownMenuItem(value: 2000, child: Text('2000 kbps')),
            DropdownMenuItem(value: 4000, child: Text('4000 kbps')),
            DropdownMenuItem(value: 8000, child: Text('8000 kbps')),
          ],
          onChanged: _converting ? null : (v) => setState(() => _bitrate = v ?? 0),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _maxWidth, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.resolutionScale, border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.keepOriginal)),
            DropdownMenuItem(value: 640, child: Text('640p')),
            DropdownMenuItem(value: 1280, child: Text('720p')),
            DropdownMenuItem(value: 1920, child: Text('1080p')),
          ],
          onChanged: _converting ? null : (v) => setState(() => _maxWidth = v ?? 0),
        ),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context)!.output_label(p.basename(_outputPath)), style: T.style('Convert Dialog', 'caption', c: cs.onSurfaceVariant)),
        if (_converting) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _total > 0 ? _current / _total : null),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.convertFrame, style: T.style('Convert Dialog', 'caption', c: cs.onSurfaceVariant)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: cs.error, fontSize: Ui.val('Convert Dialog.Convert Done'))),
        ],
        if (_done) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(CupertinoIcons.checkmark_circle, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text(AppLocalizations.of(context)!.convertComplete, style: TextStyle(color: Colors.green, fontSize: Ui.val('Convert Dialog.Convert Done'))),
          ]),
        ],
      ])),
      actions: [
        if (_converting) TextButton(onPressed: _cancel, child: Text(AppLocalizations.of(context)!.cancel)),
        if (!_converting && !_done) TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.closeAction)),
        if (_done) TextButton(onPressed: () { Navigator.pop(context, _outputPath); }, child: Text(AppLocalizations.of(context)!.openFolder)),
        if (!_converting && !_done) FilledButton(onPressed: _start, child: Text(AppLocalizations.of(context)!.startConvert)),
      ],
    );
  }
}