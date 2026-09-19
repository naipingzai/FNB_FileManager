import 'package:flutter/material.dart';
import '../widgets/app_icons.dart';
import '../native.dart';
import '../utils.dart';
import 'media_file_picker.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class MediaInfoPage extends StatefulWidget {
  const MediaInfoPage({super.key});
  @override State<MediaInfoPage> createState() => _MIState();
}
class _MIState extends State<MediaInfoPage> {
  final _inputCtrl = TextEditingController();
  Map<String, dynamic>? _info; String? _error;
  @override void dispose() { _inputCtrl.dispose(); super.dispose(); }
  String _norm(String s) => s.replaceAll('//', '/');

  void _browseInput() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MediaFilePicker()));
    if (path != null && mounted) { setState(() { _inputCtrl.text = _norm(path); _info = null; _error = null; }); _loadInfo(); }
  }
  void _loadInfo() async {
    final input = _norm(_inputCtrl.text.trim());
    if (input.isEmpty) return;
    final info = NativeMediaTools.getInfo(input);
    if (mounted) setState(() { if (info != null && info.containsKey('format')) { _info = info; _error = null; }
      else { _error = AppLocalizations.of(context)!.cannot_read_media_info; _info = null; } });
  }

  @override Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.mediaInfoTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _inputCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.mediaFile,
          border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(AppIcon.folderOpen), onPressed: _browseInput))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _loadInfo, icon: Icon(AppIcon.info), label: Text(AppLocalizations.of(context)!.viewInfo)),
        const SizedBox(height: 16),
        if (_error != null) Text(_error!, style: T.style('Media Info', 'Address Bar', c: cs.error)),
        if (_info != null) _buildInfo(),
      ]));
  }
  Widget _buildInfo() {
    final info = _info!;
    final format = info['format']?.toString() ?? 'unknown';
    final duration = (info['duration'] as num?)?.toDouble() ?? 0;
    final streams = info['streams'] as List<dynamic>? ?? [];
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppLocalizations.of(context)!.formatLabel, style: T.style('File Browser', 'Tool Title')),
      Text(AppLocalizations.of(context)!.media_duration(duration > 0 ? '${duration.toStringAsFixed(1)}s' : AppLocalizations.of(context)!.media_duration_unknown), style: T.style('File Browser', 'Address Bar')),
      const Divider(height: 24),
      Text(AppLocalizations.of(context)!.media_streams(streams.length), style: T.style('File Browser', 'Multi-Select')),
      const SizedBox(height: 8),
      for (int idx = 0; idx < streams.length; idx++) Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest, margin: const EdgeInsets.only(bottom: 8),
        child: Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('[$idx] ${streams[idx]['type']} - ${streams[idx]['codec']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          if (streams[idx]['type'] == 'video')
            Text('${streams[idx]['width']}x${streams[idx]['height']}  ${(streams[idx]['fps'] as num?)?.toStringAsFixed(1) ?? "?"} fps'),
          if (streams[idx]['type'] == 'audio')
            Text('${streams[idx]['sample_rate']} Hz  ${streams[idx]['channels']} ch'),
        ]))),
    ])));
  }
}
