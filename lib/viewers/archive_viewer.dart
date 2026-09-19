import "package:flutter/cupertino.dart";
import 'dart:async';
import '../widgets/app_icons.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../native.dart';
import '../utils.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class ArchiveViewerPage extends StatefulWidget {
  final String path;
  const ArchiveViewerPage({super.key, required this.path});
  @override
  State<ArchiveViewerPage> createState() => _AVState();
}

class _AVState extends State<ArchiveViewerPage> {
  List<dynamic> _items = [];
  String _fmt = '';
  bool _load = true, _ext = false;
  String? _err;
  Timer? _tmr;
  int _cur = 0, _tot = 0;
  String _file = '';
  String get _name => p.basename(widget.path);
  String get _out => '${p.dirname(widget.path)}/${p.basenameWithoutExtension(widget.path)}';
  bool get _multi => !{'GZ','BZ2','XZ'}.contains(_fmt);
  bool get _pwd => _fmt == 'ZIP';
  @override
  void initState() { super.initState(); _loadList(); }
  @override
  void dispose() { _tmr?.cancel(); super.dispose(); }
  void _loadList() {
    setState(() { _load = true; _err = null; });
    try { final r = NativeArchive.list(widget.path);
      if (r != null) { final j = jsonDecode(r); _items = j['items'] ?? []; _fmt = j['format'] ?? ''; }
    } catch (e) { _err = e.toString(); }
    setState(() { _load = false; });
  }
  Color _clr(ThemeData t) { switch(_fmt){case'ZIP':return Colors.blue;case'TAR':case'TAR.GZ':return Colors.orange;
    case'BZ2':case'TAR.BZ2':return Colors.green;case'XZ':case'TAR.XZ':return Colors.purple;
    case'7Z':return Colors.red;case'RAR':return Colors.teal;default:return t.colorScheme.primary;} }
  Future<void> _doExtract() async {
    String? pw; if(_pwd){pw=await showDialog<String>(context:context,builder:(_)=>const _PwdDialog());if(pw==null)return;}
    final od=await showDialog<String>(context:context,builder:(_)=>_DirPkr(initial:_out));if(od==null)return;
    await Directory(od).create(recursive:true);
    setState(()=>{_ext=true,_cur=0,_tot=0,_file=''});
    NativeArchive.extract(widget.path,od,password:pw?.isNotEmpty==true?pw:null);
    _tmr?.cancel();
    _tmr=Timer.periodic(const Duration(milliseconds:200),(_){final pg=NativeArchive.getProgress();
      setState(()=>{_cur=pg.current,_tot=pg.total,_file=pg.file});
      if(!pg.running){_tmr?.cancel();setState(()=>_ext=false);
        if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(AppLocalizations.of(context)!.extractDone)));}});
  }
  String _fs(dynamic b)=>b==null?'0 B':Formatters.formatSize(b is int?b:0);
  String _sn(String n){final p=n.split('/');return p.length>2?'${p[p.length-2]}/${p.last}':p.last;}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme; final t = Theme.of(context);
    final tot = _items.where((i) => i['isDir'] != true).fold<int>(0, (s, i) => s + (i['size'] is int ? i['size'] as int : 0));
    final dc = _items.where((i) => i['isDir'] == true).length;
    return Scaffold(
      appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.style('File Browser', 'App Bar Title')),
        if (_fmt.isNotEmpty) Text(_fmt, style: T.style('File Browser', 'Compression Format').copyWith( color: _clr(t)))]),
        actions: [if (!_load && _items.isNotEmpty && _multi) Center(child: Padding(padding: const EdgeInsets.only(right: 12),
          child: Text(AppLocalizations.of(context)!.archive_file_count(_items.length - dc, dc > 0 ? AppLocalizations.of(context)!.archive_dir_count(dc) : ''), style: T.style('Archive Viewer', 'caption', c: cs.onSurfaceVariant))))]),
      body: _load ? const Center(child: CircularProgressIndicator()) : _err != null
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(AppIcon.error, size: 48, color: cs.error), const SizedBox(height: 8), Text(_err!, style: T.style('Archive Viewer', 'Address Bar', c: cs.error))]))
          : _items.isEmpty ? Center(child: Text(AppLocalizations.of(context)!.archiveEmpty))
          : Column(children: [
              if (_ext) Column(children: [LinearProgressIndicator(value: _tot > 0 ? _cur / _tot : null),
                Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                  Expanded(child: Text(_file, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.style('File Browser', 'Multi-Select'))),
                  const SizedBox(width: 8), Text('$_cur/$_tot', style: T.style('File Browser', 'Multi-Select'))]))]),
              if (!_ext && tot > 0) Container(padding: const EdgeInsets.all(8), color: cs.surfaceContainerHighest,
                child: Text('$_fmt · ${_items.length} 项 · ${_fs(tot)}', style: T.style('Archive Viewer', 'caption', c: cs.onSurfaceVariant))),
              Expanded(child: ListView.separated(itemCount: _items.length, separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (_, i) { final it = _items[i]; final d = it['isDir'] == true;
                  return ListTile(dense: d, leading: Icon(d ? CupertinoIcons.folder : AppIcon.file, color: d ? Colors.amber.shade600 : null, size: d ? 24 : 20),
                    title: Text(_sn(it['name'] ?? ''), maxLines: 2, overflow: TextOverflow.ellipsis, style: d ? T.style('File Browser', 'File Name') : T.style('File Browser', 'Address Bar')),
                    subtitle: d ? null : Text(_fs(it['size']), style: T.style('File Browser', 'Compression Format').copyWith( color: cs.onSurfaceVariant)),
                    visualDensity: const VisualDensity(vertical: -1)); })),
            ]),
      floatingActionButton: (!_load && !_ext && _items.isNotEmpty) ? FloatingActionButton.extended(
        onPressed: _doExtract, icon: Icon(_multi ? AppIcon.extract : Icons.file_download), label: Text(_multi ? AppLocalizations.of(context)!.extract_to : AppLocalizations.of(context)!.extract_fmt(_fmt))) : null,
    );
  }
}

class _DirPkr extends StatefulWidget { final String initial; const _DirPkr({required this.initial}); @override State<_DirPkr> createState()=>_DPS(); }
class _DPS extends State<_DirPkr> { late String _c; List<FileEntry> _e = []; bool _l = true;
  @override void initState() { super.initState(); _c = widget.initial; _ld(); }
  void _ld() async { setState(() => _l = true); final r = await NativeFs.listDir(_c, showHidden: false); setState(() { _e = r.where((x) => x.isDir).toList(); _l = false; }); }
  @override Widget build(BuildContext context) { return AlertDialog(title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
    children: [Text(AppLocalizations.of(context)!.selectExtractTarget), Text(_c, style: T.style('File Browser', 'Multi-Select'), maxLines: 1, overflow: TextOverflow.ellipsis)]),
    content: SizedBox(width: double.maxFinite, height: 300, child: _l ? const Center(child: CircularProgressIndicator()) : ListView(children: [
      if (_c != '/') ListTile(dense: true, leading: Icon(AppIcon.home), title: const Text('..'), onTap: () { setState(() { final p = _c.substring(0, _c.lastIndexOf('/')); _c = p.isEmpty ? '/' : p; }); _ld(); }),
      ..._e.map((x) => ListTile(dense: true, leading: const Icon(CupertinoIcons.folder), title: Text(x.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () { setState(() => _c = x.path); _ld(); }))])),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
      FilledButton(onPressed: () => Navigator.pop(context, _c), child: Text(AppLocalizations.of(context)!.selectAction))]); }
}

class _PwdDialog extends StatefulWidget { const _PwdDialog(); @override State<_PwdDialog> createState()=>_PDS(); }
class _PDS extends State<_PwdDialog> { final _c = TextEditingController(); @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return AlertDialog(title: Text(AppLocalizations.of(context)!.enterPassword), content: TextField(controller: _c, obscureText: true, autofocus: true,
    decoration: InputDecoration(hintText: AppLocalizations.of(context)!.archive_password_hint, border: OutlineInputBorder()), onSubmitted: (_) => Navigator.pop(context, _c.text)),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')), FilledButton(onPressed: () => Navigator.pop(context, _c.text), child: Text(AppLocalizations.of(context)!.ok))]); }
}
