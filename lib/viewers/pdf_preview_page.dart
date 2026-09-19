import "package:flutter/cupertino.dart";
import 'dart:io';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as p;
import '../l10n/l10n.dart';

class PdfPreviewPage extends StatefulWidget {
  final String path;
  const PdfPreviewPage({super.key, required this.path});
  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  PdfController? _controller;
  int _page = 1, _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  void _load() async {
    try {
      final doc = await PdfDocument.openFile(widget.path);
      _controller = PdfController(document: Future.value(doc));
      _total = doc.pagesCount;
    } catch (e) { _error = e.toString(); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(widget.path)),
        actions: [
          if (_controller != null) IconButton(
            icon: Icon(AppIcon.back), onPressed: () => _controller!.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.ease),
          ),
          if (_total > 0) Text('$_page/$_total', style: const TextStyle(fontSize: 14)),
          if (_controller != null) IconButton(
            icon: Icon(CupertinoIcons.chevron_right), onPressed: () => _controller!.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.ease),
          ),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _error != null ? Center(child: Text(_error!))
          : PdfView(controller: _controller!, onPageChanged: (p) => setState(() => _page = p)),
    );
  }
}
