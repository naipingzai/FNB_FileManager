import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../ui_design.dart';
import '../l10n/l10n.dart';

class ImageViewerPage extends StatefulWidget {
  final List<String> paths;
  final int index;
  const ImageViewerPage({super.key, required this.paths, required this.index});
  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late int _index;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(p.basename(widget.paths[_index]), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (widget.paths.length > 1)
            Center(child: Padding(padding: const EdgeInsets.only(right: 12),
              child: Text('${_index + 1}/${widget.paths.length}',
                  style: T.style('File Browser', 'Address Bar').copyWith(color: Colors.white70)))),
        ],
      ),
      body: Stack(children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.paths.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(child: Image.file(File(widget.paths[i]), fit: BoxFit.contain)),
          ),
        ),
        // Filename overlay at bottom
        if (widget.paths.length > 1) Positioned(bottom: 16, left: 0, right: 0,
          child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: Text(p.basename(widget.paths[_index]),
              style: T.style('File Browser', 'Multi-Select').copyWith(color: Colors.white70),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          )),
        ),
      ]),
    );
  }
}
