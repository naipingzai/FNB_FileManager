import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import '../l10n/l10n.dart';

class DuplicateGroup {
  DuplicateGroup(this.hash, this.size, this.files);
  late final String hash;
  late final int size;
  late final List<DuplicateFile> files;
  int get wastedSize => (files.length - 1) * size;
}

class DuplicateFile {
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  bool selected;
  DuplicateFile(this.path, this.name, this.size, this.modified, {this.selected = false});
}

class DuplicateCleanerPage extends StatefulWidget {
  final String? initialPath;
  const DuplicateCleanerPage({super.key, this.initialPath});
  @override
  State<DuplicateCleanerPage> createState() => _DCHState();
}

class _DCHState extends State<DuplicateCleanerPage> {
  final List<String> _scanPaths = [];
  bool _scanning = false;
  bool _done = false;
  int _scannedFiles = 0;
  int _totalFiles = 0;
  int _scannedDirs = 0;
  String _currentDir = '';
  List<DuplicateGroup> _groups = [];
  int _totalWasted = 0;
  int _duplicateFiles = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialPath != null) _scanPaths.add(widget.initialPath!);
  }

  void _addPath() async {
    final path = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => _PathPickerPage()));
    if (path != null && !_scanPaths.contains(path)) setState(() => _scanPaths.add(path));
  }

  void _removePath(int i) => setState(() => _scanPaths.removeAt(i));

  void _startScan() {
    if (_scanPaths.isEmpty) return;
    setState(() {
      _scanning = true; _done = false; _scannedFiles = 0; _totalFiles = 0;
      _scannedDirs = 0; _currentDir = ''; _groups = []; _totalWasted = 0; _duplicateFiles = 0;
    });
    _doScan();
  }

  Future<void> _doScan() async {
    final hashGroups = <String, List<DuplicateFile>>{};
    for (final root in _scanPaths) {
      if (!_scanning) break;
      await _scanDir(root, hashGroups);
    }
    _groups = [];
    for (final e in hashGroups.entries) {
      if (e.value.length >= 2) {
        final g = DuplicateGroup(e.key, e.value.first.size, e.value);
        _groups.add(g);
        _totalWasted += g.wastedSize;
        _duplicateFiles += e.value.length;
      }
    }
    _groups.sort((a, b) => b.wastedSize.compareTo(a.wastedSize));
    setState(() { _scanning = false; _done = true; });
  }

  Future<void> _scanDir(String dirPath, Map<String, List<DuplicateFile>> hg) async {
    if (!_scanning) return;
    try {
      final entities = await Directory(dirPath).list(followLinks: false).toList();
      final files = <File>[]; final dirs = <Directory>[];
      for (final e in entities) {
        if (e is File) { try { final s = await e.stat(); if (s.size > 0) files.add(e); } catch (_) {} }
        else if (e is Directory) dirs.add(e);
      }
      _scannedDirs++; _totalFiles += files.length;
      if (_scannedDirs % 10 == 0) { setState(() { _currentDir = dirPath; }); await Future.delayed(Duration.zero); }
      await _processFiles(files, hg);
      for (final d in dirs) { if (!_scanning) return; await _scanDir(d.path, hg); }
    } catch (_) {}
  }

  Future<void> _processFiles(List<File> files, Map<String, List<DuplicateFile>> hg) async {
    final sg = <int, List<File>>{};
    for (final f in files) { try { final s = await f.stat(); if (s.size > 0) sg.putIfAbsent(s.size, () => []).add(f); } catch (_) {} }
    for (final e in sg.entries) {
      if (e.value.length < 2) continue;
      for (final f in e.value) {
        if (!_scanning) return;
        try {
          final s = await f.stat(); final h = NativeFs.fileHash(f.path);
          if (h != null && h.isNotEmpty) {
            hg.putIfAbsent(h, () => []).add(DuplicateFile(f.path, p.basename(f.path), s.size, s.modified));
            _scannedFiles++;
          }
          if (_scannedFiles % 50 == 0) { setState(() {}); await Future.delayed(Duration.zero); }
        } catch (_) {}
      }
    }
  }

  void _stopScan() => setState(() { _scanning = false; _done = true; });

  void _deleteSelected() async {
    final toDelete = _groups.expand((g) => g.files.where((f) => f.selected)).toList();
    if (toDelete.isEmpty) return;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteSelected),
      content: Text('${toDelete.length} files?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context)!.delete))],
    ));
    if (ok != true) return;
    for (final f in toDelete) { try { await NativeFs.trash(f.path); } catch (_) {} }
    setState(() { for (final g in _groups) g.files.removeWhere((f) => f.selected); _groups.removeWhere((g) => g.files.length < 2); });
  }

  void _selectAllInGroup(DuplicateGroup g) {
    setState(() { for (var i = 1; i < g.files.length; i++) g.files[i].selected = true; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.duplicateCleaner), actions: [
        if (_done && _groups.isNotEmpty) IconButton(icon: const Icon(CupertinoIcons.trash, size: 20), onPressed: _deleteSelected),
        if (_scanning) IconButton(icon: const Icon(CupertinoIcons.stop_fill, size: 20), onPressed: _stopScan),
      ]),
      body: _scanning ? _buildScanning(cs, zh) : _done ? _buildResults(cs, zh) : _buildPathSel(cs, zh),
    );
  }

  Widget _buildPathSel(ColorScheme cs, bool zh) => Column(children: [
    Container(padding: const EdgeInsets.all(16), color: cs.surfaceContainerHighest,
      child: Row(children: [
        Icon(CupertinoIcons.search, size: 28, color: cs.primary), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.selectPathsToScan, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(AppLocalizations.of(context)!.supportsMultiple, style: TextStyle(fontSize: 12, color: cs.outline)),
        ])),
      ])),
    Expanded(child: _scanPaths.isEmpty
      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(CupertinoIcons.question_circle, size: 64, color: cs.onSurfaceVariant), const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.addDirsToScan, style: TextStyle(color: cs.onSurfaceVariant)),
        ]))
      : ListView.builder(itemCount: _scanPaths.length, itemBuilder: (_, i) => ListTile(
          leading: Icon(CupertinoIcons.folder_fill, size: 20, color: cs.primary),
          title: Text(_scanPaths[i], maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(icon: Icon(CupertinoIcons.xmark_circle, size: 20, color: cs.error), onPressed: () => _removePath(i))))),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outlineVariant))),
      child: Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: _addPath, icon: const Icon(CupertinoIcons.plus, size: 18), label: Text(AppLocalizations.of(context)!.addPath))),
        const SizedBox(width: 12),
        Expanded(child: FilledButton.icon(onPressed: _scanPaths.isEmpty ? null : _startScan, icon: const Icon(CupertinoIcons.play_fill, size: 18), label: Text(AppLocalizations.of(context)!.startScan))),
      ])),
  ]);

  Widget _buildScanning(ColorScheme cs, bool zh) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const CircularProgressIndicator(), const SizedBox(height: 16),
    Text(AppLocalizations.of(context)!.scanning, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Text('Files: $_scannedFiles  Dirs: $_scannedDirs', style: TextStyle(color: cs.onSurfaceVariant)),
    if (_currentDir.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(_currentDir, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: cs.outline))),
  ]));

  Widget _buildResults(ColorScheme cs, bool zh) {
    if (_groups.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(CupertinoIcons.checkmark_circle_fill, size: 64, color: Colors.green), const SizedBox(height: 16),
      Text(AppLocalizations.of(context)!.noDuplicates, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(AppLocalizations.of(context)!.scannedNFiles(_totalFiles.toString()), style: TextStyle(color: cs.onSurfaceVariant)),
      const SizedBox(height: 24),
      OutlinedButton.icon(onPressed: () => setState(() { _done = false; _groups.clear(); }),
        icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 18), label: Text(AppLocalizations.of(context)!.rescan)),
    ]));
    final sel = _groups.expand((g) => g.files.where((f) => f.selected)).length;
    return Column(children: [
      Container(padding: const EdgeInsets.all(12), color: cs.surfaceContainerHighest,
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_groups.length} ${AppLocalizations.of(context)!.groupsOfDuplicates} \u00b7 ${Formatters.formatSize(_totalWasted)} wasted', style: TextStyle(fontWeight: FontWeight.w600)),
            Text(AppLocalizations.of(context)!.nFilesTotal(_duplicateFiles.toString()), style: TextStyle(color: cs.outline, fontSize: 12)),
          ])),
          if (sel > 0) FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: _deleteSelected, icon: const Icon(CupertinoIcons.trash, size: 16), label: Text('Delete $sel')),
        ])),
      Expanded(child: ListView.builder(itemCount: _groups.length, itemBuilder: (_, i) {
        final g = _groups[i]; final s = g.files.where((f) => f.selected).length;
        return Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: ExpansionTile(
          leading: Icon(CupertinoIcons.doc_on_doc_fill, color: cs.primary),
          title: Text('${g.files.length} ${AppLocalizations.of(context)!.copiesOf}', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${Formatters.formatSize(g.size)} \u00b7 ${(g.wastedSize/1024/1024).toStringAsFixed(1)} MB'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (s > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: cs.error, borderRadius: BorderRadius.circular(10)),
              child: Text('$s', style: TextStyle(color: cs.onError, fontSize: 12))),
            IconButton(icon: const Icon(CupertinoIcons.checkmark_rectangle, size: 18), onPressed: () => _selectAllInGroup(g)),
          ]),
          children: g.files.map((f) => ListTile(dense: true,
            leading: Checkbox(value: f.selected, onChanged: (v) => setState(() => f.selected = v ?? false)),
            title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(f.path, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: cs.outline)),
            trailing: Text(Formatters.formatDate(f.modified), style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          )).toList(),
        ));
      })),
    ]);
  }
}

class _PathPickerPage extends StatefulWidget {
  @override
  State<_PathPickerPage> createState() => _PPState();
}

class _PPState extends State<_PathPickerPage> {
  String _current = Platform.environment['HOME'] ?? '/';
  List<FileEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    setState(() { _loading = true; });
    final e = await NativeFs.listDir(_current, showHidden: false);
    e.sort((a, b) { if (a.isDir != b.isDir) return a.isDir ? -1 : 1; return a.name.toLowerCase().compareTo(b.name.toLowerCase()); });
    setState(() { _entries = e; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.selectPath),
        actions: [Padding(padding: const EdgeInsets.only(right: 8),
          child: FilledButton.tonal(onPressed: () => Navigator.pop(context, _current), child: Text(AppLocalizations.of(context)!.selectHere)))]),
      body: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: cs.surfaceContainerHighest,
          child: Row(children: [
            if (_current != '/') IconButton(icon: const Icon(CupertinoIcons.back, size: 18), padding: EdgeInsets.zero,
              onPressed: () { _current = p.dirname(_current); _load(); }),
            const SizedBox(width: 4),
            Expanded(child: Text(_current, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: cs.primary))),
          ])),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator())
          : ListView.builder(itemCount: _entries.length, itemBuilder: (_, i) {
            final e = _entries[i];
            if (!e.isDir) return const SizedBox.shrink();
            return ListTile(leading: Icon(CupertinoIcons.folder_fill, size: 20, color: cs.primary),
              title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () { _current = e.path; _load(); });
          })),
      ]),
    );
  }
}
