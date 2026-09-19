import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownPreviewPage extends StatelessWidget {
  final String path;
  const MarkdownPreviewPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(path.split(Platform.pathSeparator).last)),
      body: FutureBuilder<String>(
        future: File(path).readAsString(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text(snap.error.toString()));
          return Markdown(data: snap.data ?? '', padding: const EdgeInsets.all(16));
        },
      ),
    );
  }
}
