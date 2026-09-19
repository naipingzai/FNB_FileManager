import 'dart:convert';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import '../native.dart' as native;
import '../ui_design.dart';
import '../l10n/l10n.dart';

class EbookViewerPage extends StatefulWidget {
  final String path;
  const EbookViewerPage({super.key, required this.path});
  @override
  State<EbookViewerPage> createState() => _EbookViewerPageState();
}

class _EbookViewerPageState extends State<EbookViewerPage> {
  String? _text;
  bool _loading = true;
  double _fontSize = 16.0;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final result = native.epubExtractText(widget.path);
    if (result != null) {
      final j = jsonDecode(result);
      _text = j['text'];
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(AppIcon.zoomOut, size: 20),
            onPressed: _fontSize > 12 ? () => setState(() => _fontSize -= 2) : null,
            tooltip: 'A-',
          ),
          Center(child: Text('${_fontSize.toInt()}', style: T.style('File Browser', 'Multi-Select'))),
          IconButton(
            icon: Icon(AppIcon.zoomIn, size: 20),
            onPressed: _fontSize < 32 ? () => setState(() => _fontSize += 2) : null,
            tooltip: 'A+',
          ),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _text == null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(AppIcon.error, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(Localizations.localeOf(context).languageCode == 'zh' ? '无法解析电子书' : 'Cannot parse ebook'),
            ]))
          : SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              child: SelectableText(_text!, style: TextStyle(fontSize: _fontSize, height: 1.6)),
            ),
    );
  }
}
