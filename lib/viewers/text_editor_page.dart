import 'dart:io';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../ui_design.dart';
import '../l10n/l10n.dart';

class TextEditorPage extends StatefulWidget {
  final String path;
  const TextEditorPage({super.key, required this.path});
  @override
  State<TextEditorPage> createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  late TextEditingController _ctrl;
  bool _loading = true;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _load();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _load() async {
    try {
      final content = await File(widget.path).readAsString();
      _ctrl.text = content;
      _ctrl.addListener(() { if (!_dirty) setState(() => _dirty = true); });
    } catch (e) { _error = e.toString(); }
    setState(() => _loading = false);
  }

  void _save() async {
    try {
      await File(widget.path).writeAsString(_ctrl.text);
      setState(() => _dirty = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.create), duration: const Duration(seconds: 1)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = p.basename(widget.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_dirty) IconButton(icon: Icon(AppIcon.save), tooltip: AppLocalizations.of(context)!.ok, onPressed: _save),
          IconButton(icon: Icon(AppIcon.copy), tooltip: AppLocalizations.of(context)!.copyAction, onPressed: () {
            Clipboard.setData(ClipboardData(text: _ctrl.text));
          }),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _error != null ? Center(child: Text(_error!))
          : TextField(
        controller: _ctrl,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        decoration: null,
        style: TextStyle(fontSize: Ui.val('Text Viewer.File Size'), fontFamily: 'monospace', color: cs.onSurface),
      ),
      floatingActionButton: _dirty ? FloatingActionButton(
        onPressed: _save,
        child: Icon(AppIcon.save),
      ) : null,
    );
  }
}
