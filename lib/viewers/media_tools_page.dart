import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import '../widgets/app_icons.dart';
import 'video_convert_page.dart';
import 'gif_page.dart';
import 'video_compress_page.dart';
import 'video_trim_page.dart';
import 'audio_extract_page.dart';
import 'media_info_page.dart';
import '../l10n/l10n.dart';

class MediaToolsPage extends StatelessWidget {
  const MediaToolsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final items = [
      (AppIcon.analytics, l10n.format_convert, l10n.format_convert_desc, 'convert'),
      (AppIcon.image, l10n.make_gif, l10n.make_gif_desc, 'gif'),
      (AppIcon.compress, l10n.video_compress, l10n.video_compress_desc, 'compress'),
      (AppIcon.cut, l10n.video_trim, l10n.video_trim_desc, 'trim'),
      (AppIcon.audio, l10n.audio_extract, l10n.audio_extract_desc, 'audio'),
      (AppIcon.info, l10n.media_info, l10n.media_info_desc, 'info'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.mediaToolsTitle)),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final (icon, title, desc, action) = items[i];
          return ListTile(
            leading: Icon(icon, color: cs.primary),
            title: Text(title),
            subtitle: Text(desc),
            trailing: Icon(CupertinoIcons.chevron_right, size: 20),
            onTap: () {
              Widget page;
              switch (action) {
                case 'convert': page = const VideoConvertPage(); break;
                case 'gif': page = const GifPage(); break;
                case 'compress': page = const VideoCompressPage(); break;
                case 'trim': page = const VideoTrimPage(); break;
                case 'audio': page = const AudioExtractPage(); break;
                case 'info': page = const MediaInfoPage(); break;
                default: return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
          );
        },
      ),
    );
  }
}
