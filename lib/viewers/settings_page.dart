import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n.dart';
import '../widgets/app_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _github = 'https://github.com/naipingzai/FN_FileManager';
  static const _author = 'naipingzai';
  static const _email = 'naipingzai@github.com';
  static const _version = '1.0.0+1';
  static const _license = 'MIT License';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.about)),
      body: ListView(children: [
        // ── App Header ──
        Container(padding: const EdgeInsets.all(24), color: cs.surfaceContainerHighest,
          child: Column(children: [
            Icon(CupertinoIcons.folder_fill, size: 56, color: cs.primary), const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.appManager, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text('v$_version', style: TextStyle(fontSize: 13, color: cs.outline)),
          ])),

        // ── Author ──
        _section(AppLocalizations.of(context)!.authorInfo, cs),
        _tile(CupertinoIcons.person_fill, cs.primary, AppLocalizations.of(context)!.author, _author, cs),
        _tile(CupertinoIcons.mail, cs.primary, 'Email', _email, cs),

        // ── Project ──
        _section(AppLocalizations.of(context)!.project, cs),
        _tile(CupertinoIcons.globe, cs.primary, 'GitHub', _github, cs, onTap: () => launchUrl(Uri.parse(_github))),
        _tile(CupertinoIcons.doc_text, cs.primary, AppLocalizations.of(context)!.license, _license, cs),

        // ── Design ──
        _section(AppLocalizations.of(context)!.design, cs),
        _infoTile(CupertinoIcons.layers_fill, AppLocalizations.of(context)!.architecture,
          AppLocalizations.of(context)!.architectureDesc, cs),
        _infoTile(CupertinoIcons.paintbrush, AppLocalizations.of(context)!.iconsSpec,
          'CupertinoIcons (Apple HIG)\n'
          'AppLocalizations.of(context)!.iconsSpecDesc', cs),
        _infoTile(CupertinoIcons.globe, AppLocalizations.of(context)!.localization,
          AppLocalizations.of(context)!.localizationDesc, cs),
        _infoTile(CupertinoIcons.speedometer, AppLocalizations.of(context)!.performance,
          AppLocalizations.of(context)!.performanceDesc, cs),
        _infoTile(CupertinoIcons.device_laptop, AppLocalizations.of(context)!.platform,
          'Linux, Android\n'
          'AppLocalizations.of(context)!.platformDesc', cs),

        // ── Features ──
        _section(AppLocalizations.of(context)!.features, cs),
        _infoTile(CupertinoIcons.doc, AppLocalizations.of(context)!.fileOperations,
          AppLocalizations.of(context)!.fileOperationsDesc, cs),
        _infoTile(CupertinoIcons.eye, AppLocalizations.of(context)!.viewers,
          AppLocalizations.of(context)!.viewersDesc, cs),
        _infoTile(CupertinoIcons.wrench, AppLocalizations.of(context)!.tools,
          AppLocalizations.of(context)!.toolsDesc, cs),
        _infoTile(CupertinoIcons.gear, AppLocalizations.of(context)!.settings,
          AppLocalizations.of(context)!.settingsDesc, cs),

        // ── Privacy ──
        _section(AppLocalizations.of(context)!.privacyAndDisclaimer, cs),
        _infoTile(CupertinoIcons.lock_shield, AppLocalizations.of(context)!.privacyPolicy,
          AppLocalizations.of(context)!.privacyPolicyDesc, cs),
        _infoTile(CupertinoIcons.exclamationmark_triangle, AppLocalizations.of(context)!.disclaimer,
          AppLocalizations.of(context)!.disclaimerDesc, cs),

        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _section(String title, ColorScheme cs) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
  );

  Widget _tile(IconData icon, Color color, String title, String subtitle, ColorScheme cs, {VoidCallback? onTap}) =>
    ListTile(leading: Icon(icon, size: 20, color: color), title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: cs.outline)),
      trailing: onTap != null ? Icon(CupertinoIcons.link, size: 16, color: cs.outline) : null,
      onTap: onTap);

  Widget _infoTile(IconData icon, String title, String desc, ColorScheme cs) =>
    ListTile(leading: Icon(icon, size: 20, color: cs.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(desc, style: TextStyle(fontSize: 12, color: cs.outline, height: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4));
}
