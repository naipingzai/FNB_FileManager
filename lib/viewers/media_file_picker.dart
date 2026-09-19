import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import '../widgets/app_icons.dart';
import '../native.dart';
import '../utils.dart';
import '../l10n/l10n.dart';

class MediaFilePicker extends StatefulWidget {
  final bool videoOnly;
  const MediaFilePicker({super.key, this.videoOnly = false});
  @override State<MediaFilePicker> createState() => _MFPState();
}

class _MFPState extends State<MediaFilePicker> {
  String _dir = '/';
  List<FileEntry> _entries = [];
  bool _loading = true;
  @override void initState() { super.initState(); _init(); }
  void _init() async {
    final roots = await NativeFs.listRoot();
    if (roots.isNotEmpty) _dir = roots.first; _load();
  }
  void _load() async {
    setState(() { _loading = true; });
    _entries = await NativeFs.listDir(_dir);
    setState(() { _loading = false; });
  }
  String _norm(String s) => s.replaceAll('//', '/');

  bool _isMedia(FileEntry e) {
    if (e.isDir) return true;
    if (!widget.videoOnly) return true;
    final ext = e.name.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.avi') || ext.endsWith('.mkv') ||
        ext.endsWith('.mov') || ext.endsWith('.wmv') || ext.endsWith('.flv') ||
        ext.endsWith('.webm') || ext.endsWith('.ts') || ext.endsWith('.m4v') ||
        ext.endsWith('.mp3') || ext.endsWith('.m4a') || ext.endsWith('.wav');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _entries.where(_isMedia).toList();
    return Scaffold(
      appBar: AppBar(title: Text(_dir, maxLines: 1, overflow: TextOverflow.ellipsis)),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pop(context, _norm(_dir)),
          label: Text(AppLocalizations.of(context)!.selectAction), icon: Icon(AppIcon.check)),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
        final e = filtered[i];
        return ListTile(
          leading: Icon(FileIcons.iconForType(e.type), color: FileIcons.colorForType(e.type, Theme.of(context).colorScheme)),
          title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: e.isDir ? null : Text(Formatters.formatSize(e.size)),
          trailing: e.isDir ? Icon(CupertinoIcons.chevron_right, size: 20) : null,
          onTap: () {
            if (e.isDir) { setState(() { _dir = _norm(e.path); _load(); }); }
            else { Navigator.pop(context, _norm(e.path)); }
          },
        );
      }));
  }
}
