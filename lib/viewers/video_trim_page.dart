import 'dart:async';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import 'media_file_picker.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class VideoTrimPage extends StatefulWidget {
  const VideoTrimPage({super.key});
  @override State<VideoTrimPage> createState() => _VTState();
}
class _VTState extends State<VideoTrimPage> {
  final _inputCtrl = TextEditingController(), _outputCtrl = TextEditingController();
  int _startSec = 0, _endSec = 60;
  bool _running = false; int _current = 0, _total = 0;
  Timer? _timer; String? _error; bool _done = false;
  @override void dispose() { _inputCtrl.dispose(); _outputCtrl.dispose(); _timer?.cancel(); super.dispose(); }
  String _norm(String s) => s.replaceAll('//', '/');
  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _browseInput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MediaFilePicker()));
    if (path != null && mounted) setState(() { _inputCtrl.text = _norm(path);
      _outputCtrl.text = _norm('${p.dirname(path)}/${p.basenameWithoutExtension(path)}_trimmed'); });
  }
  void _start() async {
    final input = _norm(_inputCtrl.text.trim()), output = _norm(_outputCtrl.text.trim());
    if (input.isEmpty || output.isEmpty) return;
    setState(() { _running = true; _error = null; _done = false; _current = 0; _total = 1; });
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final (c, t) = NativeMediaTools.getProgress(); if (mounted) setState(() { _current = c; _total = t > 0 ? t : 1; });
    });
    final (rc, msg) = await Future(() => NativeMediaTools.trim(input, '$output.mp4', startSec: _startSec, endSec: _endSec));
    _timer?.cancel();
    if (mounted) setState(() { _running = false; _done = rc == 0; _current = _total;
      if (rc != 0) _error = msg.isNotEmpty ? msg : AppLocalizations.of(context)!.trim_failed; });
  }

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.videoTrimTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _inputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.videoFile,
          border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(AppIcon.folderOpen), onPressed: _browseInput))),
        const SizedBox(height: 12),
        TextField(controller: _outputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.outputPathHint, border: OutlineInputBorder())),
        const SizedBox(height: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.trim_start(_fmt(_startSec)), style: T.style('File Browser', 'Address Bar')),
          Slider(value: _startSec.toDouble(), min: 0, max: 600, divisions: 120, onChanged: _running ? null : (v) => setState(() => _startSec = v.round()))]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.trim_end(_fmt(_endSec)), style: T.style('File Browser', 'Address Bar')),
          Slider(value: _endSec.toDouble(), min: 1, max: 600, divisions: 120, onChanged: _running ? null : (v) => setState(() => _endSec = v.round()))]),
        const SizedBox(height: 16),
        if (_running) ...[LinearProgressIndicator(value: _total > 0 ? _current / _total : 0),
          const SizedBox(height: 8), Text(AppLocalizations.of(context)!.progress, textAlign: TextAlign.center)],
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: T.style('Video Trim', 'Address Bar', c: cs.error), textAlign: TextAlign.center)),
        if (_done) Padding(padding: const EdgeInsets.only(top: 8), child: Text(AppLocalizations.of(context)!.trimComplete, style: TextStyle(color: cs.primary), textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _running ? null : _start, icon: Icon(AppIcon.play), label: Text(_running ? AppLocalizations.of(context)!.trimming : AppLocalizations.of(context)!.start_trim)),
      ]));
  }
}
