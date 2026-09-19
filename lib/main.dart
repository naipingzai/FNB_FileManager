import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:media_kit/media_kit.dart';
import 'l10n/l10n.dart';
import 'native.dart';
import 'ui_design.dart';
import 'file_browser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NativeGpu.getHwdecRecommendation();
  fvp.registerWith();
  MediaKit.ensureInitialized();
  await Ui.load();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale; // null = follow system
  ThemeMode _themeMode = ThemeMode.system;
  List<String> _bookmarks = [];
  double _textScale = 1.0;
  final _navKey = GlobalKey<NavigatorState>();

  void _switch(BuildContext callerCtx) async {
    final zh = Localizations.localeOf(callerCtx).languageCode == 'zh';
    final current = _locale?.languageCode ?? 'system';
    final cs = Theme.of(callerCtx).colorScheme;
    final result = await showDialog<String>(context: callerCtx, builder: (ctx) => SimpleDialog(
      title: Text(AppLocalizations.of(context)!.languageSettings),
      children: [
        _langOption(ctx, 'system', AppLocalizations.of(context)!.followSystem, current, cs),
        _langOption(ctx, 'en', 'English', current, cs),
        _langOption(ctx, 'zh', '中文', current, cs),
      ],
    ));
    if (result != null) {
      setState(() { _locale = result == 'system' ? null : Locale(result); });
      _savePrefs();
    }
  }

  Widget _langOption(BuildContext ctx, String code, String label, String current, ColorScheme cs) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, code),
      child: Row(children: [
        Icon(code == current ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20, color: cs.primary),
        const SizedBox(width: 12),
        Text(label),
      ]),
    );
  }
  void _toggleTheme() => setState(() { _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark; _savePrefs(); });
  void setTextScale(double v) { setState(() => _textScale = v); _savePrefs(); }

  @override
  void initState() { super.initState(); _loadPrefs(); }
  void _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _bookmarks = sp.getStringList('bookmarks') ?? [];
      final t = sp.getString('theme') ?? 'system';
      _themeMode = t == 'dark' ? ThemeMode.dark : t == 'light' ? ThemeMode.light : ThemeMode.system;
      _textScale = sp.getDouble('textScale') ?? 1.0;
      final lang = sp.getString('language');
      _locale = lang == null ? null : (lang == 'en' ? const Locale('en') : lang == 'zh' ? const Locale('zh') : null);
    });
  }
  void _savePrefs() async {
    final sp = await SharedPreferences.getInstance();
    sp.setStringList('bookmarks', _bookmarks);
    sp.setString('theme', _themeMode == ThemeMode.dark ? 'dark' : _themeMode == ThemeMode.light ? 'light' : 'system');
    sp.setDouble('textScale', _textScale);
    sp.setString('language', _locale == null ? 'system' : _locale!.languageCode);
  }
  void _addBookmark(String p) { if (!_bookmarks.contains(p)) { _bookmarks.add(p); _savePrefs(); setState(() {}); } }
  void _removeBookmark(String p) { _bookmarks.remove(p); _savePrefs(); setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return UiScope(child: MaterialApp(
      locale: _locale, localeResolutionCallback: (locale, supported) {
        final target = _locale ?? locale ?? const Locale('en');
        for (final s in supported) { if (s.languageCode == target.languageCode) return s; }
        return supported.first;
      }, title: 'File Manager', debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light), darkTheme: _theme(Brightness.dark), themeMode: _themeMode,
      builder: (ctx, child) => MediaQuery(data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(_textScale)), child: child!),
      localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FileBrowserPage(onSwitchLocale: _switch, onToggleTheme: _toggleTheme, bookmarks: _bookmarks,
        onAddBookmark: _addBookmark, onRemoveBookmark: _removeBookmark, textScale: _textScale, onTextScaleChanged: setTextScale),
    ));
  }
  ThemeData _theme(Brightness b) {
    final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF006B5E), brightness: b);
    return ThemeData(colorScheme: cs, useMaterial3: true,
      cardTheme: CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: cs.outlineVariant)), margin: EdgeInsets.zero),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, scrolledUnderElevation: 1));
  }
}
