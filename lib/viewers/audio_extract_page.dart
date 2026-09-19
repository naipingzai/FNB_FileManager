import 'dart:async';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import 'media_file_picker.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class AudioExtractPage extends StatefulWidget {
  const AudioExtractPage({super.key});
  @override State<AudioExtractPage> createState() => _AEState();
}
class _AEState extends State<AudioExtractPage> {
  final _inputCtrl = TextEditingController(), _outputCtrl = TextEditingController();
  String _format = 'mp3';
  bool _running = false; int _current = 0, _total = 0;
  Timer? _timer; String? _error; bool _done = false;
  @override void dispose() { _inputCtrl.dispose(); _outputCtrl.dispose(); _timer?.cancel(); super.dispose(); }
  String _norm(String s) => s.replaceAll('//', '/');

  void _browseInput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MediaFilePicker()));
    if (path != null && mounted) setState(() { _inputCtrl.text = _norm(path);
      _outputCtrl.text = _norm('${p.dirname(path)}/${p.basenameWithoutExtension(path)}_audio'); });
  }
  void _start() async {
    final input = _norm(_inputCtrl.text.trim()), output = _norm(_outputCtrl.text.trim());
    if (input.isEmpty || output.isEmpty) return;
    setState(() { _running = true; _error = null; _done = false; _current = 0; _total = 1; });
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final (c, t) = NativeMediaTools.getProgress(); if (mounted) setState(() { _current = c; _total = t > 0 ? t : 1; });
    });
    final (rc, msg) = await Future(() => NativeMediaTools.extractAudio(input, '$output.$_format'));
    _timer?.cancel();
    if (mounted) setState(() { _running = false; _done = rc == 0; _current = _total;
      if (rc != 0) _error = msg.isNotEmpty ? msg : AppLocalizations.of(context)!.extract_failed; });
  }

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.audioExtractTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _inputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.videoFile,
          border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(AppIcon.folderOpen), onPressed: _browseInput))),
        const SizedBox(height: 12),
        TextField(controller: _outputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.outputPathHint, border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _format,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.outputFormat, border: OutlineInputBorder()),
          items: [DropdownMenuItem(value: 'mp3', child: Text('MP3')),
            DropdownMenuItem(value: 'm4a', child: Text('M4A')), DropdownMenuItem(value: 'aac', child: Text('AAC')),
            DropdownMenuItem(value: 'flac', child: Text('FLAC')), DropdownMenuItem(value: 'wav', child: Text('WAV'))],
          onChanged: (v) => setState(() { _format = v ?? 'mp3'; })),
        const SizedBox(height: 16),
        if (_running) ...[LinearProgressIndicator(value: _total > 0 ? _current / _total : 0),
          const SizedBox(height: 8), Text(AppLocalizations.of(context)!.progress, textAlign: TextAlign.center)],
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: T.style('Audio Extract', 'Address Bar', c: cs.error), textAlign: TextAlign.center)),
        if (_done) Padding(padding: const EdgeInsets.only(top: 8), child: Text(AppLocalizations.of(context)!.extractComplete, style: TextStyle(color: cs.primary), textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _running ? null : _start, icon: Icon(AppIcon.play), label: Text(_running ? AppLocalizations.of(context)!.extracting : AppLocalizations.of(context)!.start_extract)),
      ]));
  }
}
