import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import '../l10n/l10n.dart';

class FileComparePage extends StatefulWidget {
  const FileComparePage({super.key});
  @override
  State<FileComparePage> createState() => _FCPState();
}

class _FCPState extends State<FileComparePage> {
  String? _file1Path, _file2Path;
  List<String> _lines1 = [], _lines2 = [];
  bool _loading = false;
  String? _error;
  bool _showOnlyDiff = false;

  Future<void> _pickFile(int slot) async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => _FilePickerPage()));
    if (path == null) return;
    setState(() { if (slot == 1) _file1Path = path; else _file2Path = path; });
    if (_file1Path != null && _file2Path != null) _compare();
  }

  Future<void> _compare() async {
    setState(() { _loading = true; _error = null; });
    try {
      final c1 = await File(_file1Path!).readAsString();
      final c2 = await File(_file2Path!).readAsString();
      _lines1 = c1.split('\n');
      _lines2 = c2.split('\n');
    } catch (e) { _error = e.toString(); }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '文件对比' : 'File Compare'),
        actions: [
          if (_file1Path != null && _file2Path != null)
            IconButton(
              icon: Icon(_showOnlyDiff ? CupertinoIcons.eye : CupertinoIcons.eye_slash),
              onPressed: () => setState(() => _showOnlyDiff = !_showOnlyDiff),
            ),
        ],
      ),
      body: Column(children: [
        Container(padding: const EdgeInsets.all(8), color: cs.surfaceContainerHighest,
          child: Row(children: [
            Expanded(child: _fileSlot(1, cs)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(CupertinoIcons.arrow_right)),
            Expanded(child: _fileSlot(2, cs)),
          ])),
        if (_loading) const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null) Expanded(child: Center(child: Text(_error!, style: TextStyle(color: cs.error))))
        else if (_file1Path != null && _file2Path != null) Expanded(child: _buildDiffView(cs))
        else Expanded(child: Center(child: Text(
          Localizations.localeOf(context).languageCode == 'zh' ? '请选择两个文件进行对比' : 'Select two files to compare',
          style: TextStyle(color: cs.onSurfaceVariant)))),
      ]),
    );
  }


  Widget _fileSlot(int slot, ColorScheme cs) {
    final path = slot == 1 ? _file1Path : _file2Path;
    final name = path != null ? p.basename(path) : '-';
    return InkWell(onTap: () => _pickFile(slot),
      child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(8), border: Border.all(color: cs.outlineVariant)),
        child: Row(children: [
          Icon(CupertinoIcons.doc, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13))),
        ])));
  }

  Widget _buildDiffView(ColorScheme cs) {
    final maxLen = _lines1.length > _lines2.length ? _lines1.length : _lines2.length;
    return ListView.builder(itemCount: maxLen, itemBuilder: (_, i) {
      final l1 = i < _lines1.length ? _lines1[i] : '';
      final l2 = i < _lines2.length ? _lines2[i] : '';
      final isDiff = l1 != l2;
      final isOnly1 = l2.isEmpty;
      final isOnly2 = l1.isEmpty;
      if (_showOnlyDiff && !isDiff) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        color: isDiff ? cs.errorContainer.withOpacity(0.3) : null,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 40, child: Text('${i + 1}', style: TextStyle(fontSize: 10, color: cs.outline, fontFamily: 'monospace'))),
          Expanded(child: Container(padding: const EdgeInsets.all(2), color: isOnly2 ? cs.surfaceContainerHighest : null,
            child: Text(l1, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: isOnly2 ? cs.outline : cs.onSurface)))),
          Container(width: 1, color: cs.outlineVariant),
          Expanded(child: Container(padding: const EdgeInsets.all(2), color: isOnly1 ? cs.surfaceContainerHighest : null,
            child: Text(l2, style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: isOnly1 ? cs.outline : cs.onSurface)))),
        ]));
    });
  }
}

class _FilePickerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.open)),
      body: FutureBuilder<List<FileEntry>>(
        future: NativeFs.listDir(Platform.environment['HOME'] ?? '/', showHidden: false),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final entries = snap.data!;
          return ListView.builder(itemCount: entries.length, itemBuilder: (_, i) {
            final e = entries[i];
            return ListTile(
              leading: Icon(e.isDir ? CupertinoIcons.folder : CupertinoIcons.doc, size: 20),
              title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => Navigator.pop(context, e.path));
          });
        }));
  }
}