import 'dart:async';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import 'media_file_picker.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class VideoCompressPage extends StatefulWidget {
  const VideoCompressPage({super.key});
  @override State<VideoCompressPage> createState() => _VCPageState();
}
class _VCPageState extends State<VideoCompressPage> {
  final _inputCtrl = TextEditingController(), _outputCtrl = TextEditingController();
  int _bitrate = 1000, _maxWidth = 1280;
  bool _running = false; int _current = 0, _total = 0;
  Timer? _timer; String? _error; bool _done = false;
  @override void dispose() { _inputCtrl.dispose(); _outputCtrl.dispose(); _timer?.cancel(); super.dispose(); }
  String _norm(String s) => s.replaceAll('//', '/');

  void _browseInput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MediaFilePicker()));
    if (path != null && mounted) setState(() { _inputCtrl.text = _norm(path);
      _outputCtrl.text = _norm('${p.dirname(path)}/${p.basenameWithoutExtension(path)}_compressed'); });
  }
  void _start() async {
    final input = _norm(_inputCtrl.text.trim()), output = _norm(_outputCtrl.text.trim());
    if (input.isEmpty || output.isEmpty) return;
    setState(() { _running = true; _error = null; _done = false; _current = 0; _total = 1; });
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final (c, t) = NativeVideoConvert.getProgress(); if (mounted) setState(() { _current = c; _total = t > 0 ? t : 1; });
    });
    final rc = await Future(() => NativeVideoConvert.convert(input, output,
        codec: 'h264', container: 'mp4', bitrate: _bitrate, maxWidth: _maxWidth));
    _timer?.cancel();
    if (mounted) setState(() { _running = false; _done = rc == 0; _current = _total;
      if (rc != 0) _error = AppLocalizations.of(context)!.compress_failed_code(rc); });
  }

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.videoCompressTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _inputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.videoFile,
          border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(AppIcon.folderOpen), onPressed: _browseInput))),
        const SizedBox(height: 12),
        TextField(controller: _outputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.outputPathHint, border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(value: _bitrate,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.targetBitrate, border: OutlineInputBorder()),
          items: [DropdownMenuItem(value: 500, child: Text(AppLocalizations.of(context)!.bitrate500)),
            DropdownMenuItem(value: 1000, child: Text(AppLocalizations.of(context)!.bitrate1000)),
            DropdownMenuItem(value: 2000, child: Text('2000 kbps')),
            DropdownMenuItem(value: 4000, child: Text(AppLocalizations.of(context)!.bitrate4000))],
          onChanged: (v) => setState(() { _bitrate = v ?? 1000; })),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(value: _maxWidth,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.maxWidth, border: OutlineInputBorder()),
          items: [DropdownMenuItem(value: 640, child: Text('640p')),
            DropdownMenuItem(value: 848, child: Text('480p')),
            DropdownMenuItem(value: 1280, child: Text(AppLocalizations.of(context)!.resolution720)),
            DropdownMenuItem(value: 1920, child: Text('1080p')),
            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.keepOriginal))],
          onChanged: (v) => setState(() { _maxWidth = v ?? 1280; })),
        const SizedBox(height: 16),
        if (_running) ...[LinearProgressIndicator(value: _total > 0 ? _current / _total : 0),
          const SizedBox(height: 8), Text(AppLocalizations.of(context)!.progress, textAlign: TextAlign.center)],
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: T.style('Video Compress', 'Address Bar', c: cs.error), textAlign: TextAlign.center)),
        if (_done) Padding(padding: const EdgeInsets.only(top: 8), child: Text(AppLocalizations.of(context)!.compressComplete, style: TextStyle(color: cs.primary), textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _running ? null : _start, icon: Icon(AppIcon.play), label: Text(_running ? AppLocalizations.of(context)!.compressing : AppLocalizations.of(context)!.start_compress)),
      ]));
  }
}
