# FN 文件管理器 — UI 设计规范

## 1. 图标系统

所有图标通过 `AppIcon` 类访问，底层使用 CupertinoIcons（Apple HIG 风格）。

```dart
import '../widgets/app_icons.dart';

// 正确用法
Icon(AppIcon.folder)           // 文件夹
Icon(AppIcon.delete)           // 删除
Icon(AppIcon.forExtension(ext)) // 根据扩展名自动选图标

// 错误用法 - 禁止直接使用 Icons.xxx
Icon(Icons.folder)             // 禁止
Icon(Icons.delete)             // 禁止
```

## 2. 文字样式

所有文字样式通过 `T.style()` 获取，字体大小由 `Ui.val()` 动态控制。

```dart
import '../ui_design.dart';

// 正确用法 - 通过 T.style
Text('标题', style: T.style('File Browser', 'File Name'))

// 错误用法 - 禁止硬编码 fontSize
Text('标题', style: TextStyle(fontSize: 14))  // 禁止
```

## 3. 颜色系统

所有颜色通过 `Theme.of(context).colorScheme` 获取，禁止直接使用 `Colors.xxx`。

```dart
// 正确用法
Text('文字', style: TextStyle(color: cs.onSurface))
Container(color: cs.surfaceContainerHighest)

// 错误用法 - 禁止直接使用
Text('文字', style: TextStyle(color: Colors.grey))  // 禁止
Container(color: Colors.blue)  // 禁止
```

例外：`Colors.transparent`、`Colors.white`、`Colors.black` 等透明/黑白颜色可以使用。

## 4. 间距规范

间距通过 `Ui.val()` 动态控制，禁止硬编码。

```dart
const SizedBox(height: 8)      // 禁止
SizedBox(height: Ui.val('File Browser.File Name'))  // 正确
```

## 5. 国际化

所有用户可见文字必须通过 `AppLocalizations` 获取，禁止硬编码。

```dart
// 正确用法
Text(AppLocalizations.of(context)!.files)

// 错误用法
Text('文件')  // 禁止
Text('Files')  // 禁止
```

## 6. 主题适配

UI 必须适配浅色和深色主题，通过 `colorScheme` 获取颜色。

## 7. 文件命名

- 页面：`xxx_page.dart` 或 `xxx_viewer.dart`
- 服务：`xxx_service.dart` 或 `xxx_queue.dart`
- 组件：`xxx_widget.dart` 或放在 `widgets/` 目录

## 8. 修改检查清单

修改任何 UI 代码前，检查：
- [ ] 图标是否通过 `AppIcon` 访问
- [ ] 文字样式是否通过 `T.style` 获取
- [ ] 间距是否通过 `Ui.val` 动态控制
- [ ] 文本是否通过 `AppLocalizations` 本地化
- [ ] 颜色是否通过 `colorScheme` 获取
- [ ] 新页面是否有 const 构造函数
- [ ] 新字符串是否添加到 ARB 文件
- [ ] 新页面是否在 `ui_design.dart` 中定义了 UiItem

## 9. 前台阻塞规范

**禁止在主线程执行阻塞操作。** 所有 I/O 操作必须使用异步方式。

### 禁止使用的同步 API（会冻结 UI）：
```dart
file.readAsBytesSync()
file.readAsStringSync()
file.existsSync()
dir.listSync()
dir.createSync()
file.deleteSync()
```

### 正确做法：
```dart
final data = await file.readAsBytes();
final text = await file.readAsString();
final exists = await file.exists();
final entries = await dir.list().toList();
await dir.create(recursive: true);
```

### 重计算使用 Isolate：
```dart
final result = await Isolate.run(() {
  // 重计算任务...
});
```

## 10. 开源与合规

| 项目 | 文件 |
|------|------|
| 许可证 | `LICENSE` (MIT) |
| 隐私政策 | `PRIVACY_POLICY.md` |
| 免责声明 | `DISCLAIMER.md` |
| 代码检查 | `scripts/check_ui_standards.py` |
