# FN File Manager — UI Design Specification

## 1. Icon System

All icons are accessed through the `AppIcon` class, using CupertinoIcons (Apple HIG style).

```dart
import '../widgets/app_icons.dart';

// Correct usage
Icon(AppIcon.folder)
Icon(AppIcon.delete)
Icon(AppIcon.forExtension(ext))

// Wrong usage - do NOT use Icons.xxx directly
Icon(Icons.folder)  // Forbidden
Icon(Icons.delete)  // Forbidden
```

## 2. Text Styles

All text styles are obtained through `T.style()`, with font sizes dynamically controlled by `Ui.val()`.

```dart
import '../ui_design.dart';

// Correct usage
Text('Title', style: T.style('File Browser', 'File Name'))

// Wrong usage - do NOT hardcode fontSize
Text('Title', style: TextStyle(fontSize: 14))  // Forbidden
```

## 3. Color System

All colors are obtained through `Theme.of(context).colorScheme`. Do NOT use `Colors.xxx` directly.

```dart
// Correct usage
Text('Text', style: TextStyle(color: cs.onSurface))
Container(color: cs.surfaceContainerHighest)

// Wrong usage
Text('Text', style: TextStyle(color: Colors.grey))  // Forbidden
```

Exception: `Colors.transparent`, `Colors.white`, `Colors.black` and other transparent/monochrome colors may be used.

## 4. Spacing

Spacing is dynamically controlled through `Ui.val()`. Do NOT hardcode.

```dart
const SizedBox(height: 8)  // Forbidden
SizedBox(height: Ui.val('File Browser.File Name'))  // Correct
```

## 5. Localization

All user-visible text must be obtained through `AppLocalizations`. Do NOT hardcode.

```dart
// Correct usage
Text(AppLocalizations.of(context)!.files)

// Wrong usage
Text('Files')  // Forbidden
```

## 6. Theme Adaptation

UI must adapt to both light and dark themes using `colorScheme`.

## 7. File Naming

- Pages: `xxx_page.dart` or `xxx_viewer.dart`
- Services: `xxx_service.dart` or `xxx_queue.dart`
- Widgets: `xxx_widget.dart` or in `widgets/` directory

## 8. Modification Checklist

Before modifying any UI code, check:
- [ ] Icons accessed through `AppIcon`
- [ ] Text styles obtained through `T.style`
- [ ] Spacing controlled by `Ui.val`
- [ ] Text localized through `AppLocalizations`
- [ ] Colors obtained from `colorScheme`
- [ ] New pages have const constructors
- [ ] New strings added to ARB files
- [ ] New pages have UiItem in `ui_design.dart`

## 9. No Foreground Blocking

**Do NOT execute blocking operations on the main thread.** All I/O must be async.

### Forbidden sync APIs (freeze UI):
```dart
file.readAsBytesSync()
file.readAsStringSync()
file.existsSync()
dir.listSync()
dir.createSync()
file.deleteSync()
```

### Correct approach:
```dart
final data = await file.readAsBytes();
final text = await file.readAsString();
final exists = await file.exists();
final entries = await dir.list().toList();
await dir.create(recursive: true);
```

### Heavy computations use Isolate:
```dart
final result = await Isolate.run(() {
  // Heavy computation...
});
```

## 10. Open Source & Compliance

| Item | File |
|------|------|
| License | `LICENSE` (MIT) |
| Privacy Policy | `PRIVACY_POLICY.md` / `PRIVACY_POLICY_CN.md` |
| Disclaimer | `DISCLAIMER.md` / `DISCLAIMER_CN.md` |
| Code Check | `scripts/check_ui_standards.py` |
