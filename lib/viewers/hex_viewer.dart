import "package:flutter/cupertino.dart";
import 'dart:io';
import '../widgets/app_icons.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../ui_design.dart';
import '../l10n/l10n.dart';

class HexViewerPage extends StatefulWidget {
  final String path;
  const HexViewerPage({super.key, required this.path});
  @override
  State<HexViewerPage> createState() => _HexViewerPageState();
}

class _HexViewerPageState extends State<HexViewerPage> {
  Uint8List? _data;
  String? _error;
  int _bytesPerLine = 16;
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  List<int> _searchHits = [];
  int _searchIdx = -1;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _scrollCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  void _load() async {
    try {
      _data = await File(widget.path).readAsBytes();
    } catch (e) { _error = e.toString(); }
    setState(() {});
  }

  void _search() {
    final q = _searchCtrl.text;
    if (q.isEmpty || _data == null) { setState(() { _searchHits = []; _searchIdx = -1; }); return; }
    // 支持十六进制搜索（如 "FF D8"）或 ASCII 搜索
    Uint8List? needle;
    if (RegExp(r'^[0-9a-fA-F\s]+$').hasMatch(q) && q.replaceAll(RegExp(r'\s'), '').length.isEven) {
      final hex = q.replaceAll(RegExp(r'\s'), '');
      needle = Uint8List(hex.length ~/ 2);
      for (int i = 0; i < needle.length; i++) {
        needle[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }
    } else {
      needle = Uint8List.fromList(q.codeUnits);
    }
    _searchHits.clear();
    for (int i = 0; i <= _data!.length - needle.length; i++) {
      bool match = true;
      for (int j = 0; j < needle.length; j++) {
        if (_data![i + j] != needle[j]) { match = false; break; }
      }
      if (match) _searchHits.add(i);
    }
    _searchIdx = _searchHits.isNotEmpty ? 0 : -1;
    if (_searchHits.isNotEmpty) _jumpTo(_searchHits[0]);
    setState(() {});
  }

  void _jumpTo(int offset) {
    final line = offset ~/ _bytesPerLine;
    final target = line * 30.0; // 估算每行高度
    _scrollCtrl.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _nextHit() {
    if (_searchHits.isEmpty) return;
    _searchIdx = (_searchIdx + 1) % _searchHits.length;
    _jumpTo(_searchHits[_searchIdx]);
    setState(() {});
  }

  String _hexByte(int b) => b.toRadixString(16).toUpperCase().padLeft(2, '0');
  String _ascii(int b) => (b >= 0x20 && b < 0x7f) ? String.fromCharCode(b) : '.';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(widget.path), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_data != null) Center(child: Text(
            '${(_data!.length / 1024).toStringAsFixed(1)} KB',
            style: T.style('File Browser', 'Multi-Select').copyWith(color: cs.onSurface))),
          PopupMenuButton<int>(
            icon: Icon(AppIcon.listView),
            onSelected: (v) => setState(() { _bytesPerLine = v; }),
            itemBuilder: (_) => [8,16,32].map((n) =>
              PopupMenuItem(value: n, child: Text(AppLocalizations.of(context)!.hexBytesPerLine(n)))).toList(),
          ),
          IconButton(icon: Icon(AppIcon.search), onPressed: () {
            showDialog(context: context, builder: (_) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.hexSearch),
              content: TextField(controller: _searchCtrl,
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.hex_search_hint, border: OutlineInputBorder()),
                onSubmitted: (_) { _search(); Navigator.pop(context); }),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
                FilledButton(onPressed: () { _search(); Navigator.pop(context); }, child: Text(AppLocalizations.of(context)!.searchAction)),
              ],
            ));
          }),
          if (_searchHits.isNotEmpty)
            IconButton(icon: Icon(CupertinoIcons.chevron_right, size: 20),
              onPressed: _nextHit, tooltip: '${_searchIdx + 1}/${_searchHits.length}'),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _data == null
              ? const Center(child: CircularProgressIndicator())
              : _buildHexView(),
    );
  }

  Widget _buildHexView() {
    final data = _data!;
    final cs = Theme.of(context).colorScheme;
    final totalLines = (data.length + _bytesPerLine - 1) ~/ _bytesPerLine;
    final hitSet = _searchHits.toSet();

    // 固定列头
    final colHeaderSpans = <TextSpan>[];
    for (int i = 0; i < _bytesPerLine; i++) {
      colHeaderSpans.add(TextSpan(text: i.toRadixString(16).toUpperCase().padLeft(2, '0'),
          style: TextStyle(fontSize: Ui.val('Hex Viewer.Multi-Select'), fontFamily: 'monospace').copyWith( color: cs.onSurfaceVariant)));
      colHeaderSpans.add(const TextSpan(text: ' '));
      if (i > 0 && (i + 1) % 4 == 0 && i < _bytesPerLine - 1) {
        colHeaderSpans.add(const TextSpan(text: ' '));
      }
    }

    return Column(children: [
      // 固定列头
      Container(
        color: cs.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(height: 20, child: Row(children: [
          SizedBox(width: 72, child: Text('OFFSET', style: TextStyle(fontSize: Ui.val('Hex Viewer.Multi-Select'), fontFamily: 'monospace').copyWith( color: cs.onSurfaceVariant))),
          Expanded(child: Text.rich(TextSpan(children: colHeaderSpans))),
          SizedBox(width: _bytesPerLine * 8, child: Text('ASCII', style: TextStyle(fontSize: Ui.val('Hex Viewer.Multi-Select'), fontFamily: 'monospace').copyWith( color: cs.onSurfaceVariant))),
        ])),
      ),
      // 可滚动的数据行
      Expanded(child: ListView.builder(
        controller: _scrollCtrl,
        itemCount: totalLines,
        itemExtent: 20,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (_, lineIdx) {
          final offset = lineIdx * _bytesPerLine;
          final end = (offset + _bytesPerLine).clamp(0, data.length);
          final hexParts = <String>[];
          final asciiParts = <String>[];
          for (int i = offset; i < end; i++) {
            hexParts.add(_hexByte(data[i]));
            asciiParts.add(_ascii(data[i]));
          }
          while (hexParts.length < _bytesPerLine) { hexParts.add('  '); asciiParts.add(' '); }

          final isHit = hitSet.contains(offset);
          final addr = offset.toRadixString(16).toUpperCase().padLeft(8, '0');

          // 构建 hex 列 span
          final hexSpans = <TextSpan>[];
          for (int i = 0; i < hexParts.length; i++) {
            hexSpans.add(TextSpan(text: hexParts[i], style: TextStyle(
              fontFamily: "monospace", fontSize: Ui.val('Hex Viewer.Text 12px'),
              color: isHit ? Colors.yellow : null,
              backgroundColor: isHit ? Colors.yellow.withAlpha(77) : null)));
            hexSpans.add(const TextSpan(text: ' '));
            if (i > 0 && (i + 1) % 4 == 0 && i < hexParts.length - 1) {
              hexSpans.add(const TextSpan(text: ' '));
            }
          }

          // 构建 ASCII 列 span
          final asciiSpans = <TextSpan>[];
          for (int i = 0; i < asciiParts.length; i++) {
            asciiSpans.add(TextSpan(text: asciiParts[i], style: TextStyle(
              fontFamily: "monospace", fontSize: Ui.val('Hex Viewer.Text 12px'),
              color: isHit ? Colors.yellow : null,
              backgroundColor: isHit ? Colors.yellow.withAlpha(77) : null)));
            if (i > 0 && (i + 1) % 4 == 0 && i < asciiParts.length - 1) {
              asciiSpans.add(const TextSpan(text: ' '));
            }
          }

          return Row(children: [
            SizedBox(width: 72, child: Text(addr, style: TextStyle(fontSize: Ui.val('Hex Viewer.Multi-Select'), fontFamily: 'monospace').copyWith( color: cs.onSurfaceVariant))),
            Expanded(child: Text.rich(TextSpan(children: hexSpans))),
            SizedBox(width: _bytesPerLine * 8, child: Text.rich(TextSpan(children: asciiSpans))),
          ]);
        },
      )),
    ]);
  }
}

