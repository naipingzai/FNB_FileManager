import "package:flutter/cupertino.dart";
import 'dart:io';
import 'dart:isolate';
import '../widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class StorageAnalysisPage extends StatefulWidget {
  const StorageAnalysisPage({super.key});
  @override
  State<StorageAnalysisPage> createState() => _SAState();
}

class _SAState extends State<StorageAnalysisPage> {
  bool _loading = true;
  String _root = '/';
  List<_DirEntry> _dirs = [];
  List<_FileEntry> _largeFiles = [];
  int _totalSize = 0;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    setState(() { _loading = true; });
    final home = Platform.environment['HOME'] ?? '/';
    _root = home;
    final entries = await NativeFs.listDir(_root, showHidden: false);
    final dirPaths = entries.where((e) => e.isDir).map((e) => e.path).toList();
    final dirEntries = await Isolate.run(() {
      final result = <_DirEntry>[];
      for (final dp in dirPaths) result.add(_DirEntry(p.basename(dp), dp, NativeFs.dirSize(dp)));
      result.sort((a, b) => b.size.compareTo(a.size));
      return result;
    });
    final files = entries.where((e) => !e.isDir).toList()..sort((a, b) => b.size.compareTo(a.size));
    setState(() {
      _dirs = dirEntries;
      _largeFiles = files.take(20).map((e) => _FileEntry(e.name, e.path, e.size)).toList();
      _totalSize = dirEntries.fold(0, (s, d) => s + d.size);
      _loading = false;
    });
  }

  void _scanDir(String path) async {
    setState(() { _loading = true; _root = path; });
    final entries = await NativeFs.listDir(path, showHidden: false);
    final dirPaths = entries.where((e) => e.isDir).map((e) => e.path).toList();
    final dirs = await Isolate.run(() {
      final result = <_DirEntry>[];
      for (final dp in dirPaths) result.add(_DirEntry(p.basename(dp), dp, NativeFs.dirSize(dp)));
      result.sort((a, b) => b.size.compareTo(a.size));
      return result;
    });
    final files = entries.where((e) => !e.isDir).toList()..sort((a, b) => b.size.compareTo(a.size));
    setState(() {
      _dirs = dirs;
      _largeFiles = files.take(20).map((e) => _FileEntry(e.name, e.path, e.size)).toList();
      _totalSize = dirs.fold(0, (s, d) => s + d.size);
      _loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.storageAnalysis)),
      body: _loading ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(), const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.scanning),
      ]))
          : ListView(children: [
              Container(padding: const EdgeInsets.all(16), color: cs.surfaceContainerHighest, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('\${AppLocalizations.of(context)!.scanningDir}: $_root', style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _totalSize > 0 ? 1.0 : 0),
                  const SizedBox(height: 4),
                  Text('\${AppLocalizations.of(context)!.total}: ${Formatters.formatSize(_totalSize)}', style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary)),
                ])),
              if (_dirs.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(AppLocalizations.of(context)!.directories, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                ..._dirs.take(15).map((d) => _dirTile(d, cs)),
              ],
              if (_largeFiles.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(AppLocalizations.of(context)!.largestFiles, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                ..._largeFiles.map((f) => _fileTile(f, cs)),
              ],
            ]),
    );
  }

  Widget _dirTile(_DirEntry d, ColorScheme cs) {
    final pct = _totalSize > 0 ? d.size / _totalSize : 0.0;
    return ListTile(
      leading: Icon(CupertinoIcons.folder_fill, color: cs.primary),
      title: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: LinearProgressIndicator(value: pct, backgroundColor: cs.surfaceContainerHighest),
      trailing: Text(Formatters.formatSize(d.size), style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      onTap: () => _scanDir(d.path),
    );
  }

  Widget _fileTile(_FileEntry f, ColorScheme cs) {
    final ext = p.extension(f.name).toLowerCase();
    return ListTile(
      leading: Icon(_fileIcon(ext), size: 20, color: cs.onSurfaceVariant),
      title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(Formatters.formatSize(f.size), style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext) {
      case '.mp4': case '.mkv': case '.avi': case '.mov': return AppIcon.video;
      case '.mp3': case '.wav': case '.flac': case '.m4a': return AppIcon.audio;
      case '.jpg': case '.jpeg': case '.png': case '.gif': case '.webp': return AppIcon.image;
      case '.pdf': return AppIcon.pdf;
      case '.zip': case '.tar': case '.gz': case '.7z': case '.rar': return AppIcon.compress;
      case '.txt': case '.md': case '.json': case '.xml': return AppIcon.text;
      default: return AppIcon.file;
    }
  }
}

class _DirEntry { final String name, path; final int size; _DirEntry(this.name, this.path, this.size); }
class _FileEntry { final String name, path; final int size; _FileEntry(this.name, this.path, this.size); }