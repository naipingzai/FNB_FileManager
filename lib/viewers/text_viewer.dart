import "package:flutter/cupertino.dart";
import 'dart:io';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../ui_design.dart';
import '../l10n/l10n.dart';

class TextViewerPage extends StatefulWidget {
  final String path;
  const TextViewerPage({super.key, required this.path});
  @override
  State<TextViewerPage> createState() => _TVState();
}

class _TVState extends State<TextViewerPage> {
  String? _content;
  bool _loading = true;
  String? _error;
  int _lineCount = 0;
  String _encoding = 'UTF-8';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  List<int> _searchHits = [];
  int _searchIdx = -1;
  final _scrollCtrl = ScrollController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _searchCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final file = File(widget.path);
      final size = await file.length();
      if (size > 10 * 1024 * 1024) {
        final stream = file.openRead(0, 500 * 1024);
        final bytes = <int>[];
        await for (final chunk in stream) { bytes.addAll(chunk); }
        _content = String.fromCharCodes(bytes);
        _encoding = 'Partial (500KB/${(size / 1024 / 1024).toStringAsFixed(1)}MB)';
      } else {
        _content = await file.readAsString();
        _encoding = 'UTF-8';
      }
      _lineCount = '\n'.allMatches(_content!).length + 1;
    } catch (e) { _error = e.toString(); }
    setState(() { _loading = false; });
  }

  void _search() {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty || _content == null) {
      setState(() { _searchHits = []; _searchIdx = -1; _searchQuery = ''; }); return;
    }
    _searchQuery = q; _searchHits.clear();
    final lines = _content!.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toLowerCase().contains(q)) _searchHits.add(i);
    }
    _searchIdx = _searchHits.isNotEmpty ? 0 : -1;
    if (_searchHits.isNotEmpty) _jumpToLine(_searchHits[0]);
    setState(() {});
  }

  void _jumpToLine(int lineIdx) {
    _scrollCtrl.animateTo(lineIdx * 18.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _nextHit() {
    if (_searchHits.isEmpty) return;
    _searchIdx = (_searchIdx + 1) % _searchHits.length;
    _jumpToLine(_searchHits[_searchIdx]); setState(() {});
  }

  void _prevHit() {
    if (_searchHits.isEmpty) return;
    _searchIdx = (_searchIdx - 1 + _searchHits.length) % _searchHits.length;
    _jumpToLine(_searchHits[_searchIdx]); setState(() {});
  }

  void _showSearchDialog() {
    _searchCtrl.text = _searchQuery;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.search),
      content: TextField(controller: _searchCtrl, autofocus: true,
        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.tv_keyword_hint, prefixIcon: Icon(AppIcon.search), border: const OutlineInputBorder()),
        onSubmitted: (_) { Navigator.pop(context); _search(); }),
      actions: [
        TextButton(onPressed: () { setState(() { _searchHits = []; _searchIdx = -1; _searchQuery = ''; }); Navigator.pop(context); }, child: Text(AppLocalizations.of(context)!.tv_clear)),
        FilledButton(onPressed: () { Navigator.pop(context); _search(); }, child: Text(AppLocalizations.of(context)!.tv_search)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(widget.path), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_searchHits.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              IconButton(icon: Icon(AppIcon.back, size: 20), onPressed: _prevHit),
              Text('${_searchIdx + 1}/${_searchHits.length}', style: T.style('File Browser', 'Multi-Select').copyWith(color: cs.onSurface)),
              IconButton(icon: Icon(CupertinoIcons.chevron_right, size: 20), onPressed: _nextHit),
            ])),
          IconButton(icon: Icon(AppIcon.search), onPressed: _showSearchDialog, tooltip: AppLocalizations.of(context)!.tv_search_tooltip),
          PopupMenuButton<String>(icon: Icon(AppIcon.info), itemBuilder: (_) => [
            PopupMenuItem(enabled: false, child: Text(AppLocalizations.of(context)!.tv_lines(_lineCount), style: T.style('Text Viewer', 'caption', c: cs.onSurfaceVariant))),
            PopupMenuItem(enabled: false, child: Text(_content != null ? AppLocalizations.of(context)!.tv_chars(_content!.length) : '', style: T.style('Text Viewer', 'caption', c: cs.onSurfaceVariant))),
            PopupMenuItem(enabled: false, child: Text(_encoding, style: T.style('Text Viewer', 'caption', c: cs.onSurfaceVariant))),
          ]),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(AppIcon.error, size: 48, color: cs.error), const SizedBox(height: 8), Text(_error!, textAlign: TextAlign.center)]))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_content == null) return const SizedBox();
    final lines = _content!.split('\n');
    final hitSet = _searchHits.toSet();
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
        width: 56, color: cs.surfaceContainerHighest,
        child: ListView.builder(
          controller: _scrollCtrl, itemCount: lines.length, itemExtent: 18,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemBuilder: (_, i) => Text('${i + 1}',
            style: TextStyle(fontSize: Ui.val('Text Viewer.File Size'), fontFamily: 'monospace').copyWith(
              color: hitSet.contains(i) ? Colors.orange : cs.onSurfaceVariant),
            textAlign: TextAlign.right),
        ),
      ),
      Expanded(child: ListView.builder(
        itemCount: lines.length, itemExtent: 18,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (_, i) {
          final line = lines[i];
          if (hitSet.contains(i) && _searchQuery.isNotEmpty) {
            final lower = line.toLowerCase();
            final spans = <TextSpan>[];
            int start = 0;
            while (true) {
              final idx = lower.indexOf(_searchQuery, start);
              if (idx < 0) { spans.add(TextSpan(text: line.substring(start))); break; }
              if (idx > start) spans.add(TextSpan(text: line.substring(start, idx)));
              spans.add(TextSpan(text: line.substring(idx, idx + _searchQuery.length),
                style: const TextStyle(backgroundColor: Colors.orange, color: Colors.black)));
              start = idx + _searchQuery.length;
            }
            return Text.rich(TextSpan(children: spans, style: TextStyle(fontSize: Ui.val('Text Viewer.Multi-Select'), fontFamily: 'monospace')));
          }
          return Text(line, style: TextStyle(fontSize: Ui.val('Text Viewer.Multi-Select'), fontFamily: 'monospace'), maxLines: 1, overflow: TextOverflow.ellipsis);
        },
      )),
    ]);
  }
}
