import 'dart:async';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import 'media_file_picker.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class GifPage extends StatefulWidget {
  const GifPage({super.key});
  @override State<GifPage> createState() => _GifPageState();
}
class _GifPageState extends State<GifPage> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  int _startSec = 0, _durationSec = 5, _fps = 10, _width = 320;
  bool _running = false; int _current = 0, _total = 0;
  Timer? _timer; String? _error; bool _done = false;
  @override void dispose() { _inputCtrl.dispose(); _outputCtrl.dispose(); _timer?.cancel(); super.dispose(); }
  String _norm(String s) => s.replaceAll('//', '/');

  void _browseInput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MediaFilePicker()));
    if (path != null && mounted) setState(() { _inputCtrl.text = _norm(path);
      _outputCtrl.text = _norm('${p.dirname(path)}/${p.basenameWithoutExtension(path)}'); });
  }
  void _start() async {
    final input = _norm(_inputCtrl.text.trim()), output = _norm(_outputCtrl.text.trim());
    if (input.isEmpty || output.isEmpty) return;
    setState(() { _running = true; _error = null; _done = false; _current = 0; _total = 1; });
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final (c, t) = NativeMediaTools.getProgress(); if (mounted) setState(() { _current = c; _total = t > 0 ? t : 1; });
    });
    final (rc, msg) = await Future(() => NativeMediaTools.gif(input, '$output.gif',
        startSec: _startSec, durationSec: _durationSec, fps: _fps, width: _width));
    _timer?.cancel();
    if (mounted) setState(() { _running = false; _done = rc == 0; _current = _total;
      if (rc != 0) _error = msg.isNotEmpty ? msg : 'GIF failed'; });
  }
  Widget _sl(String l, double v, double mn, double mx, int d, Function(double) oc) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: T.style('File Browser', 'Address Bar')),
        Slider(value: v, min: mn, max: mx, divisions: d, onChanged: _running ? null : oc)]);

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.makeGif)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _inputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.videoFile,
          border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(AppIcon.folderOpen), onPressed: _browseInput))),
        const SizedBox(height: 12),
        TextField(controller: _outputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.outputPathHint, border: OutlineInputBorder())),
        const SizedBox(height: 16),
        _sl(AppLocalizations.of(context)!.gif_start_sec(_startSec), _startSec.toDouble(), 0, 300, 60, (v) => _startSec = v.round()),
        _sl(AppLocalizations.of(context)!.gif_duration_sec(_durationSec), _durationSec.toDouble(), 1, 30, 29, (v) => _durationSec = v.round()),
        _sl(AppLocalizations.of(context)!.gif_fps(_fps), _fps.toDouble(), 5, 30, 25, (v) => _fps = v.round()),
        _sl(AppLocalizations.of(context)!.gif_width(_width == 0 ? AppLocalizations.of(context)!.original : '$_width'), _width.toDouble(), 0, 640, 12, (v) => _width = v.round()),
        const SizedBox(height: 16),
        if (_running) ...[LinearProgressIndicator(value: _total > 0 ? _current / _total : 0),
          const SizedBox(height: 8), Text(AppLocalizations.of(context)!.gifFrame, textAlign: TextAlign.center)],
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: T.style('GIF Maker', 'Address Bar', c: cs.error), textAlign: TextAlign.center)),
        if (_done) Padding(padding: const EdgeInsets.only(top: 8), child: Text(AppLocalizations.of(context)!.gifComplete, style: TextStyle(color: cs.primary), textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _running ? null : _start, icon: Icon(AppIcon.play), label: Text(_running ? AppLocalizations.of(context)!.making_gif : AppLocalizations.of(context)!.start_making)),
      ]));
  }
}
