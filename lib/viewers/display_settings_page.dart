import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import '../widgets/app_icons.dart';
import '../ui_design.dart';
import '../l10n/l10n.dart';

class DisplaySettingsPage extends StatefulWidget {
  final ValueChanged<double> onScaleChanged;
  final double currentScale;
  const DisplaySettingsPage({super.key, required this.onScaleChanged, required this.currentScale});
  @override
  State<DisplaySettingsPage> createState() => _DSS();
}

class _DSS extends State<DisplaySettingsPage> {
  late double _scale;
  late Map<String, double> _temp;
  String? _exp;
  bool _zh(ctx) => Localizations.localeOf(ctx).languageCode == 'zh';

  @override
  void initState() { super.initState(); _scale = widget.currentScale; _temp = Map.of(Ui.values); }

  UiItem? _find(String k) { for (var i in Ui.all) { if (i.key(false)==k||i.key(true)==k) return i; } return null; }
  void _inc(String k) { final it = _find(k); if (it==null) return;
    setState(()=>_temp[k]=((_temp[k]??it.defVal)+1).clamp(it.min,it.max)); }
  void _dec(String k) { final it = _find(k); if (it==null) return;
    setState(()=>_temp[k]=((_temp[k]??it.defVal)-1).clamp(it.min,it.max)); }
  double _val(String k) { final it = _find(k); return _temp[k] ?? (it?.defVal ?? 14); }
  void _apply() { Ui.apply(_temp, 'custom'); Navigator.pop(context); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = _zh(context);
    final grp = <String, List<UiItem>>{};
    for (var i in Ui.all) grp.putIfAbsent(i.pe, ()=>[]).add(i);
    return Scaffold(appBar: AppBar(title: Text(AppLocalizations.of(context)!.display_settings)),
      body: Column(children: [
        Container(padding: const EdgeInsets.all(12), color: cs.surfaceContainerHighest,
          child: Row(children: [
            Icon(CupertinoIcons.search, size: 20), const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.global_scale),
            Expanded(child: Slider(value: _scale, min: 0.7, max: 1.5, divisions: 8,
              label: _scale.toStringAsFixed(2), onChanged: (v) => setState(() => _scale = v))),
            SizedBox(width: 40, child: Text(_scale.toStringAsFixed(2) + 'x', textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant))),
          ])),
        Expanded(child: ListView.builder(itemCount: grp.length, itemBuilder: (ctx, i) {
          final pg = grp.keys.elementAt(i);
          final its = grp[pg]!;
          final ex = _exp == pg;
          final pn = its[0].pz;
          return Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(children: [
              ListTile(leading: Icon(_pi(pg), size: 20, color: cs.primary),
                title: Text(zh ? pn : pg, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${its.length} ${AppLocalizations.of(context)!.items_configurable}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                trailing: Icon(ex ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down),
                onTap: () => setState(() => _exp = ex ? null : pg)),
              if (ex) Column(children: [
                Container(height: 120, margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: cs.outlineVariant)), child: _buildPreview(pg, cs)),
                ...its.map((it) => _row(it, cs, zh)),
              ]),
            ]));
        })),
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest,
            border: Border(top: BorderSide(color: cs.outlineVariant))),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {
              setState(() { _temp = { for (var i in Ui.all) i.key(false): i.defVal }; _scale = 1.0; }); },
              child: Text(AppLocalizations.of(context)!.restore_defaults))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton.icon(onPressed: _apply,
              icon: Icon(AppIcon.check), label: Text(AppLocalizations.of(context)!.apply))),
          ])),
      ]),
    );
  }

  Widget _row(UiItem it, ColorScheme cs, bool zh) {
    final k = it.key(false);  // Always use English key for storage
    final v = _val(k);
    final lb = zh ? it.cv : it.ce;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(children: [
        Expanded(flex: 3, child: Text(lb, style: TextStyle(fontSize: v.clamp(8.0, 20.0)))),
        Expanded(flex: 4, child: Text(it.desc, style: TextStyle(fontSize: 10, color: cs.outline),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
        IconButton(visualDensity: VisualDensity.compact, iconSize: 18,
          icon: const Icon(CupertinoIcons.minus_circle, size: 18), onPressed: () => _dec(k)),
        SizedBox(width: 36, child: Text('${v.toInt()}', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary))),
        IconButton(visualDensity: VisualDensity.compact, iconSize: 18,
          icon: const Icon(CupertinoIcons.plus_circle, size: 18), onPressed: () => _inc(k)),
      ]));
  }

  Widget _buildPreview(String pg, ColorScheme cs) {
    switch (pg) {
      case "File Browser": return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(CupertinoIcons.folder, size: 24, color: Colors.amber),
        Icon(CupertinoIcons.folder, size: 20, color: Colors.amber.shade300),
        Icon(CupertinoIcons.doc_text, size: 20, color: cs.onSurfaceVariant),
        Icon(CupertinoIcons.photo, size: 20, color: Colors.purple),
        Icon(CupertinoIcons.videocam, size: 20, color: Colors.red),
      ]);
      case "Archive Viewer": return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(CupertinoIcons.archivebox, size: 24, color: Colors.brown),
        Icon(CupertinoIcons.folder, size: 18, color: Colors.amber),
        Icon(CupertinoIcons.doc_text, size: 18, color: cs.onSurfaceVariant),
      ]);
      case "Audio Player": return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(CupertinoIcons.music_note, size: 32, color: Colors.orange),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(CupertinoIcons.backward_end_fill, size: 16),
          const SizedBox(width: 12),
          Icon(CupertinoIcons.play_fill, size: 24),
          const SizedBox(width: 12),
          Icon(CupertinoIcons.forward_end_fill, size: 16),
        ]),
      ]);
      case "Text Viewer": return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(CupertinoIcons.doc_text, size: 24, color: cs.primary),
        const SizedBox(height: 4),
        Text("Lines | Chars | Encoding", style: TextStyle(fontSize: 9, color: cs.outline)),
      ]);
      case "Hex Viewer": return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("00 FF A3 1B", style: TextStyle(fontFamily: "monospace", fontSize: 12, color: cs.primary)),
        const SizedBox(width: 8),
        Text(". . .", style: TextStyle(color: cs.outline)),
        const SizedBox(width: 8),
        Text("hello", style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ]);
      default: return Center(child: Icon(_pi(pg), size: 32, color: cs.primary));
    }
  }

  IconData _pi(String pg) {
    switch (pg) {
      case 'File Browser': return AppIcon.folderOpen;
      case 'Archive Viewer': return AppIcon.compress;
      case 'Audio Player': return AppIcon.audio;
      case 'Video Player': return AppIcon.play;
      case 'Text Viewer': return AppIcon.text;
      case 'Hex Viewer': return AppIcon.code;
      case 'Format Convert': return AppIcon.analytics;
      case 'Convert Dialog': return AppIcon.analytics;
      case 'GIF Maker': return AppIcon.image;
      case 'Video Compress': return AppIcon.compress;
      case 'Video Trim': return AppIcon.cut;
      case 'Audio Extract': return AppIcon.audio;
      case 'Media Info': return CupertinoIcons.info;
      case 'Ebook Reader': return AppIcon.ebook;
      case 'Image Viewer': return AppIcon.image;
      default: return AppIcon.settings;
    }
  }
}
