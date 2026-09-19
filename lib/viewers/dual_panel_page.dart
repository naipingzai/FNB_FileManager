import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import '../l10n/l10n.dart';
import "../widgets/app_icons.dart";

class DualPanelPage extends StatefulWidget {
  final String initialPath;
  const DualPanelPage({super.key, this.initialPath = '/'});
  @override
  State<DualPanelPage> createState() => _DualPanelState();
}

class _DualPanelState extends State<DualPanelPage> {
  late String _leftPath, _rightPath;
  List<FileEntry> _leftEntries = [], _rightEntries = [];
  bool _leftLoading = true, _rightLoading = true;
  int _activePanel = 0;
  final Set<String> _leftSelected = {}, _rightSelected = {};

  @override
  void initState() {
    super.initState();
    final home = Platform.environment['HOME'] ?? '/';
    _leftPath = widget.initialPath;
    _rightPath = home;
    _load(0); _load(1);
  }

  void _load(int panel) async {
    final path = panel == 0 ? _leftPath : _rightPath;
    setState(() { if (panel == 0) _leftLoading = true; else _rightLoading = true; });
    final entries = await NativeFs.listDir(path, showHidden: false);
    entries.sort((a, b) { if (a.isDir != b.isDir) return a.isDir ? -1 : 1; return a.name.toLowerCase().compareTo(b.name.toLowerCase()); });
    setState(() { if (panel == 0) { _leftEntries = entries; _leftLoading = false; } else { _rightEntries = entries; _rightLoading = false; } });
  }

  void _enter(int panel, String path) { if (panel == 0) _leftPath = path; else _rightPath = path; _load(panel); }
  Set<String> _sel(int n) => n == 0 ? _leftSelected : _rightSelected;
  String _otherPath() => _activePanel == 0 ? _rightPath : _leftPath;
  bool _zh() => Localizations.localeOf(context).languageCode == 'zh';

  Future<void> _runOp(String label, Future<void> Function() task) async {
    bool done = false; String? error;
    if (mounted) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => StatefulBuilder(builder: (ctx, setDS) {
        if (done) WidgetsBinding.instance.addPostFrameCallback((_) { if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop(); });
        return AlertDialog(content: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(), const SizedBox(height: 16), Text(label),
          if (error != null) ...[const SizedBox(height: 8), Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 12))],
        ]));
      }));
    }
    try { await task(); } catch (e) { error = e.toString(); }
    done = true; if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _copyTo(String src) async {
    final dst = p.join(_otherPath(), p.basename(src));
    await _runOp(_zh() ? '复制中...' : 'Copying...', () async { final (rc, _) = NativeFs.copy(src, dst); if (rc != 0) throw Exception('Copy failed'); });
    _load(_activePanel == 0 ? 1 : 0);
  }
  void _moveTo(String src) async {
    final dst = p.join(_otherPath(), p.basename(src));
    await _runOp(_zh() ? '移动中...' : 'Moving...', () async { final (rc, _) = NativeFs.move(src, dst); if (rc != 0) throw Exception('Move failed'); });
    _load(0); _load(1);
  }
  void _delete(FileEntry e) async {
    await _runOp(_zh() ? '删除中...' : 'Deleting...', () async { final (rc, _) = NativeFs.trash(e.path); if (rc != 0) throw Exception('Delete failed'); });
    _load(0); _load(1);
  }
  void _toggle(int panel, String path) { final s = _sel(panel); setState(() { s.contains(path) ? s.remove(path) : s.add(path); }); }

  void _newFolder(int panel) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.newFolder),
      content: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(hintText: AppLocalizations.of(context)!.new_folder_hint, border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(AppLocalizations.of(context)!.ok))],
    ));
    if (name != null && name.isNotEmpty) {
      final dirPath = panel == 0 ? _leftPath : _rightPath;
      await _runOp(_zh() ? '创建中...' : 'Creating...', () async { NativeFs.mkdir('$dirPath/$name'); });
      _load(panel);
    }
  }

  void _renameFile(FileEntry e, int panel) async {
    final ctrl = TextEditingController(text: e.name);
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.rename),
      content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: Text(AppLocalizations.of(context)!.ok))],
    ));
    if (name != null && name.isNotEmpty && name != e.name) {
      await _runOp(_zh() ? '重命名中...' : 'Renaming...', () async { NativeFs.rename(e.path, p.join(p.dirname(e.path), name)); });
      _load(panel);
    }
  }

  void _back(int panel) {
    final path = panel == 0 ? _leftPath : _rightPath;
    if (path != '/') _enter(panel, p.dirname(path));
  }

  bool _canGoBack(int panel) {
    final path = panel == 0 ? _leftPath : _rightPath;
    return path != '/';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_canGoBack(_activePanel)) { _back(_activePanel); }
        else { Navigator.of(context).pop(); }
      },
      child: Scaffold(
      appBar: AppBar(title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '双面板' : 'Dual Panel'), actions: [
        IconButton(icon: Icon(AppIcon.check, size: 20), tooltip: 'Left', onPressed: () => setState(() => _activePanel = 0)),
        IconButton(icon: Icon(AppIcon.selectAll, size: 20), tooltip: 'Right', onPressed: () => setState(() => _activePanel = 1)),
      ]),
      body: Row(children: [
        Expanded(child: _buildPanel(0, cs)),
        Container(width: 1, color: cs.outlineVariant),
        Expanded(child: _buildPanel(1, cs)),
      ]),),
    );
  }

  Widget _buildPanel(int panel, ColorScheme cs) {
    final path = panel == 0 ? _leftPath : _rightPath;
    final entries = panel == 0 ? _leftEntries : _rightEntries;
    final loading = panel == 0 ? _leftLoading : _rightLoading;
    final isActive = _activePanel == panel;
    return Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        color: isActive ? cs.primaryContainer : cs.surfaceContainerHighest,
        child: Row(children: [
          if (path != '/') IconButton(icon: Icon(CupertinoIcons.house, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28), onPressed: () => _enter(panel, p.dirname(path))),
          const SizedBox(width: 4),
          Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _breadcrumb(path, panel, cs)))),
          const SizedBox(width: 4),
          Text('${entries.length}', style: TextStyle(fontSize: 10, color: cs.outline)),
        ])),
      Expanded(child: loading ? const Center(child: CircularProgressIndicator())
          : ListView.builder(itemCount: entries.length, itemBuilder: (_, i) {
            final e = entries[i]; final isSel = _sel(panel).contains(e.path);
            return InkWell(onLongPress: () => _showActions(e, panel),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: isSel ? cs.primaryContainer.withOpacity(0.4) : null,
                child: Row(children: [
                  GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _toggle(panel, e.path),
                    child: Padding(padding: const EdgeInsets.all(4),
                      child: Icon(FileIcons.iconForType(e.type), size: 20, color: isSel ? cs.primary : FileIcons.colorForType(e.type, cs)))),
                  const SizedBox(width: 4),
                  Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque,
                    onTap: () => e.isDir ? _enter(panel, e.path) : null,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      if (!e.isDir) Text(Formatters.formatSize(e.size), style: TextStyle(fontSize: 11, color: cs.outline)),
                    ]))),
                ]))); })),
      Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outlineVariant))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // 复制到对面
          TextButton.icon(onPressed: _sel(panel).isEmpty ? null : () async {
            final paths = _sel(panel).toList();
            final other = _otherPath();
            final zh = _zh();
            await _runOp(AppLocalizations.of(context)!.copyingNFiles(paths.length.toString()), () async {
              for (final sp in paths) { NativeFs.copy(sp, p.join(other, p.basename(sp))); }
            });
            _sel(panel).clear(); setState((){}); _load(_activePanel == 0 ? 1 : 0);
          }, icon: Icon(CupertinoIcons.doc_on_doc, size: 16), label: Text(_zh() ? '复制' : 'Copy', style: TextStyle(fontSize: 12))),
          TextButton.icon(onPressed: _sel(panel).isEmpty ? null : () async {
            final paths = _sel(panel).toList();
            final other = _otherPath();
            final zh = _zh();
            await _runOp(AppLocalizations.of(context)!.movingNFiles(paths.length.toString()), () async {
              for (final sp in paths) { NativeFs.move(sp, p.join(other, p.basename(sp))); }
            });
            _sel(panel).clear(); setState((){}); _load(0); _load(1);
          }, icon: Icon(CupertinoIcons.doc, size: 16), label: Text(_zh() ? '移动' : 'Move', style: TextStyle(fontSize: 12))),
          TextButton.icon(onPressed: _sel(panel).isEmpty ? null : () async {
            final paths = _sel(panel).toList();
            final entries = panel == 0 ? _leftEntries : _rightEntries;
            final zh = _zh();
            await _runOp(AppLocalizations.of(context)!.deletingNFiles(paths.length.toString()), () async {
              for (final sp in paths) { final e = entries.where((x) => x.path == sp).firstOrNull; if (e != null) NativeFs.trash(e.path); }
            });
            _sel(panel).clear(); setState((){}); _load(0); _load(1);
          }, icon: Icon(CupertinoIcons.trash, size: 16, color: cs.error), label: Text(_zh() ? '删除' : 'Delete', style: TextStyle(fontSize: 12, color: cs.error))),
          // 在当前面板新建
          TextButton.icon(onPressed: () {
            _newFolder(panel);
          }, icon: Icon(CupertinoIcons.folder_badge_plus, size: 16), label: Text(Localizations.localeOf(context).languageCode == 'zh' ? '新建' : 'New', style: TextStyle(fontSize: 12))),
          // 刷新
          TextButton.icon(onPressed: () => _load(panel),
            icon: Icon(CupertinoIcons.arrow_clockwise, size: 16), label: Text(Localizations.localeOf(context).languageCode == 'zh' ? '刷新' : 'Refresh', style: TextStyle(fontSize: 12))),
        ])),
    ]);
  }

  List<Widget> _breadcrumb(String path, int panel, ColorScheme cs) {
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    final widgets = <Widget>[]
      ..add(InkWell(onTap: () => _enter(panel, '/'), child: Text('/', style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w500))));
    String acc = '';
    for (var i = 0; i < parts.length; i++) {
      acc += '/' + parts[i];
      final snap = acc;
      widgets.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Icon(CupertinoIcons.back, size: 8, color: cs.outline)));
      widgets.add(InkWell(onTap: () => _enter(panel, snap), child: Text(parts[i], style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w500))));
    }
    return widgets;
  }

  void _showActions(FileEntry e, int panel) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(CupertinoIcons.doc_on_doc, size: 20), title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '复制到对面' : 'Copy to other panel'), onTap: () { Navigator.pop(ctx); _copyTo(e.path); }),
      ListTile(leading: Icon(CupertinoIcons.doc, size: 20), title: Text(Localizations.localeOf(context).languageCode == 'zh' ? '移动到对面' : 'Move to other panel'), onTap: () { Navigator.pop(ctx); _moveTo(e.path); }),
      ListTile(leading: Icon(CupertinoIcons.pencil, size: 20), title: Text(AppLocalizations.of(context)!.rename), onTap: () { Navigator.pop(ctx); _renameFile(e, panel); }),
      ListTile(leading: Icon(CupertinoIcons.trash, size: 20, color: cs.error), title: Text(AppLocalizations.of(context)!.moveToTrash, style: TextStyle(color: cs.error)), onTap: () { Navigator.pop(ctx); _delete(e); }),
    ])));
  }
}
