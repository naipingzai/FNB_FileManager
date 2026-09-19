import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'File Manager'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @switchLang.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLang;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @gridColumns.
  ///
  /// In en, this message translates to:
  /// **'Grid Columns'**
  String get gridColumns;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @noFiles.
  ///
  /// In en, this message translates to:
  /// **'No files yet'**
  String get noFiles;

  /// No description provided for @importFiles.
  ///
  /// In en, this message translates to:
  /// **'Import files to get started'**
  String get importFiles;

  /// No description provided for @tagManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get tagManage;

  /// No description provided for @tagSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by Tag'**
  String get tagSearch;

  /// No description provided for @createTag.
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get createTag;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTag;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagName;

  /// No description provided for @tagColor.
  ///
  /// In en, this message translates to:
  /// **'Tag Color'**
  String get tagColor;

  /// No description provided for @recycleBin.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBin;

  /// No description provided for @emptyRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Empty Recycle Bin'**
  String get emptyRecycleBin;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(String version);

  /// No description provided for @nativeVersion.
  ///
  /// In en, this message translates to:
  /// **'Native: v{version}'**
  String nativeVersion(String version);

  /// No description provided for @prefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get prefix;

  /// No description provided for @suffix.
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get suffix;

  /// No description provided for @replaceWith.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceWith;

  /// No description provided for @sequenceNum.
  ///
  /// In en, this message translates to:
  /// **'Sequence'**
  String get sequenceNum;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get find;

  /// No description provided for @replaceWithField.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get replaceWithField;

  /// No description provided for @startNum.
  ///
  /// In en, this message translates to:
  /// **'Start number'**
  String get startNum;

  /// No description provided for @newFile.
  ///
  /// In en, this message translates to:
  /// **'New File'**
  String get newFile;

  /// No description provided for @filenameHint.
  ///
  /// In en, this message translates to:
  /// **'Filename (e.g. note.txt)'**
  String get filenameHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @needFileAccess.
  ///
  /// In en, this message translates to:
  /// **'File access permission required'**
  String get needFileAccess;

  /// No description provided for @needFileAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'This app needs \"All files access\" to work properly. Please enable it in the next settings page.'**
  String get needFileAccessDesc;

  /// No description provided for @goAuthorize.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get goAuthorize;

  /// No description provided for @fileAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'File access not authorized, some features may be limited'**
  String get fileAccessDenied;

  /// No description provided for @binaryFileError.
  ///
  /// In en, this message translates to:
  /// **'This is a binary file and cannot be opened directly.'**
  String get binaryFileError;

  /// No description provided for @hexView.
  ///
  /// In en, this message translates to:
  /// **'Hex View'**
  String get hexView;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @extract.
  ///
  /// In en, this message translates to:
  /// **'Extract'**
  String get extract;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @cutAction.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cutAction;

  /// No description provided for @moveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get moveToTrash;

  /// No description provided for @compress.
  ///
  /// In en, this message translates to:
  /// **'Compress'**
  String get compress;

  /// No description provided for @propertiesAction.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesAction;

  /// No description provided for @pasteFail.
  ///
  /// In en, this message translates to:
  /// **', {fail} failed'**
  String pasteFail(Object fail);

  /// No description provided for @fileExists.
  ///
  /// In en, this message translates to:
  /// **'File already exists'**
  String get fileExists;

  /// No description provided for @fileExistsMsg.
  ///
  /// In en, this message translates to:
  /// **'\"\$\$name\" already exists'**
  String get fileExistsMsg;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @keepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep Both'**
  String get keepBoth;

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get overwrite;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get newFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @moveAction.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveAction;

  /// No description provided for @cannotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this file'**
  String get cannotOpenFile;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: \$\$e'**
  String get shareFailed;

  /// No description provided for @compressFilename.
  ///
  /// In en, this message translates to:
  /// **'Compressed filename'**
  String get compressFilename;

  /// No description provided for @encryptCompress.
  ///
  /// In en, this message translates to:
  /// **'Encrypted compression'**
  String get encryptCompress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @propType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get propType;

  /// No description provided for @propFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get propFolder;

  /// No description provided for @propSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get propSize;

  /// No description provided for @propModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get propModified;

  /// No description provided for @propPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get propPermission;

  /// No description provided for @propPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get propPath;

  /// No description provided for @propChecksum.
  ///
  /// In en, this message translates to:
  /// **'Checksum'**
  String get propChecksum;

  /// No description provided for @fileBrowser.
  ///
  /// In en, this message translates to:
  /// **'File Browser'**
  String get fileBrowser;

  /// No description provided for @multiSelectBtn.
  ///
  /// In en, this message translates to:
  /// **'Multi-Select'**
  String get multiSelectBtn;

  /// No description provided for @fileBrowserFileSize.
  ///
  /// In en, this message translates to:
  /// **'File Browser.File Size'**
  String get fileBrowserFileSize;

  /// No description provided for @calculatingHash.
  ///
  /// In en, this message translates to:
  /// **'Calculating hash...'**
  String get calculatingHash;

  /// No description provided for @compressFormatSelect.
  ///
  /// In en, this message translates to:
  /// **'Compression Format'**
  String get compressFormatSelect;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @filename.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get filename;

  /// No description provided for @searchFilename.
  ///
  /// In en, this message translates to:
  /// **'Search filename'**
  String get searchFilename;

  /// No description provided for @searchKeyword.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword...'**
  String get searchKeyword;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'App Bar Title'**
  String get appBarTitle;

  /// No description provided for @homeDir.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeDir;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @bookmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Long press a folder to add bookmark'**
  String get bookmarkHint;

  /// No description provided for @mediaToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Tools'**
  String get mediaToolsTitle;

  /// No description provided for @displaySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettingsTitle;

  /// No description provided for @pasteAction.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteAction;

  /// No description provided for @exitMultiSelect.
  ///
  /// In en, this message translates to:
  /// **'Exit multi-select'**
  String get exitMultiSelect;

  /// No description provided for @multiSelect.
  ///
  /// In en, this message translates to:
  /// **'Multi-select'**
  String get multiSelect;

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get sortByName;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'By size'**
  String get sortBySize;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get sortByDate;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get sortByType;

  /// No description provided for @hideHiddenFiles.
  ///
  /// In en, this message translates to:
  /// **'Hide hidden files'**
  String get hideHiddenFiles;

  /// No description provided for @showHiddenFiles.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get showHiddenFiles;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark current directory'**
  String get addBookmark;

  /// No description provided for @langChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get langChinese;

  /// No description provided for @addrBarText.
  ///
  /// In en, this message translates to:
  /// **'Address Bar'**
  String get addrBarText;

  /// No description provided for @confirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmBtn;

  /// No description provided for @editPath.
  ///
  /// In en, this message translates to:
  /// **'Edit path'**
  String get editPath;

  /// No description provided for @invertSelection.
  ///
  /// In en, this message translates to:
  /// **'Invert'**
  String get invertSelection;

  /// No description provided for @batchRename.
  ///
  /// In en, this message translates to:
  /// **'Batch rename'**
  String get batchRename;

  /// No description provided for @batchTrash.
  ///
  /// In en, this message translates to:
  /// **'Batch move to trash'**
  String get batchTrash;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @formatConvert.
  ///
  /// In en, this message translates to:
  /// **'Format Convert'**
  String get formatConvert;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @compressingStatus.
  ///
  /// In en, this message translates to:
  /// **'Compressing...'**
  String get compressingStatus;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Restored: \$\$name'**
  String get restored;

  /// No description provided for @emptyTrashAction.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrashAction;

  /// No description provided for @emptyTrashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all files in trash? This cannot be undone.'**
  String get emptyTrashConfirm;

  /// No description provided for @emptyAction.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get emptyAction;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @extractDone.
  ///
  /// In en, this message translates to:
  /// **'Extract complete → \$\$od'**
  String get extractDone;

  /// No description provided for @archiveViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Viewer'**
  String get archiveViewerTitle;

  /// No description provided for @archiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Archive is empty'**
  String get archiveEmpty;

  /// No description provided for @extractTo.
  ///
  /// In en, this message translates to:
  /// **'Extract to…'**
  String get extractTo;

  /// No description provided for @extractFmt.
  ///
  /// In en, this message translates to:
  /// **'Extract {fmt}'**
  String extractFmt(Object fmt);

  /// No description provided for @selectExtractTarget.
  ///
  /// In en, this message translates to:
  /// **'Select extract destination'**
  String get selectExtractTarget;

  /// No description provided for @selectAction.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectAction;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @archivePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (leave empty if none)'**
  String get archivePasswordHint;

  /// No description provided for @audioExtractTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Extract'**
  String get audioExtractTitle;

  /// No description provided for @videoFile.
  ///
  /// In en, this message translates to:
  /// **'Video file'**
  String get videoFile;

  /// No description provided for @outputPathHint.
  ///
  /// In en, this message translates to:
  /// **'Output path (without extension)'**
  String get outputPathHint;

  /// No description provided for @outputFormat.
  ///
  /// In en, this message translates to:
  /// **'Output format'**
  String get outputFormat;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress: \$\$_current / \$\$_total'**
  String get progress;

  /// No description provided for @extractComplete.
  ///
  /// In en, this message translates to:
  /// **'Extraction complete!'**
  String get extractComplete;

  /// No description provided for @extractingStatus.
  ///
  /// In en, this message translates to:
  /// **'Extracting...'**
  String get extractingStatus;

  /// No description provided for @startExtract.
  ///
  /// In en, this message translates to:
  /// **'Start extraction'**
  String get startExtract;

  /// No description provided for @audioPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get audioPlayerTitle;

  /// No description provided for @swipeHint.
  ///
  /// In en, this message translates to:
  /// **'← Swipe left/right to switch →'**
  String get swipeHint;

  /// No description provided for @pcmParams.
  ///
  /// In en, this message translates to:
  /// **'PCM Format Parameters'**
  String get pcmParams;

  /// No description provided for @sampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample Rate (Hz)'**
  String get sampleRate;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @bitDepth.
  ///
  /// In en, this message translates to:
  /// **'Bit Depth (bit)'**
  String get bitDepth;

  /// No description provided for @byteOrder.
  ///
  /// In en, this message translates to:
  /// **'Byte Order'**
  String get byteOrder;

  /// No description provided for @littleEndian.
  ///
  /// In en, this message translates to:
  /// **'Little-Endian'**
  String get littleEndian;

  /// No description provided for @bigEndian.
  ///
  /// In en, this message translates to:
  /// **'Big-Endian'**
  String get bigEndian;

  /// No description provided for @globalScale.
  ///
  /// In en, this message translates to:
  /// **'Global Scale'**
  String get globalScale;

  /// No description provided for @itemsConfigurable.
  ///
  /// In en, this message translates to:
  /// **'items configurable'**
  String get itemsConfigurable;

  /// No description provided for @resetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetDefaults;

  /// No description provided for @applyBtn.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyBtn;

  /// No description provided for @makeGif.
  ///
  /// In en, this message translates to:
  /// **'Make GIF'**
  String get makeGif;

  /// No description provided for @gifStartSec.
  ///
  /// In en, this message translates to:
  /// **'Start: {sec}s'**
  String gifStartSec(Object sec);

  /// No description provided for @gifDurationSec.
  ///
  /// In en, this message translates to:
  /// **'Duration: {sec}s'**
  String gifDurationSec(Object sec);

  /// No description provided for @gifFps.
  ///
  /// In en, this message translates to:
  /// **'FPS: {fps}'**
  String gifFps(Object fps);

  /// No description provided for @gifFrame.
  ///
  /// In en, this message translates to:
  /// **'Frame: \$\$_current / \$\$_total'**
  String get gifFrame;

  /// No description provided for @gifMakerTitle.
  ///
  /// In en, this message translates to:
  /// **'GIF Maker'**
  String get gifMakerTitle;

  /// No description provided for @gifComplete.
  ///
  /// In en, this message translates to:
  /// **'GIF creation complete!'**
  String get gifComplete;

  /// No description provided for @gifMaking.
  ///
  /// In en, this message translates to:
  /// **'Making...'**
  String get gifMaking;

  /// No description provided for @startMaking.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startMaking;

  /// No description provided for @hexBytesPerLine.
  ///
  /// In en, this message translates to:
  /// **'{n} bytes per line'**
  String hexBytesPerLine(Object n);

  /// No description provided for @hexSearch.
  ///
  /// In en, this message translates to:
  /// **'Search (HEX or ASCII)'**
  String get hexSearch;

  /// No description provided for @hexSearchHint.
  ///
  /// In en, this message translates to:
  /// **'FF D8 FF E0 or hello'**
  String get hexSearchHint;

  /// No description provided for @hexViewerMultiSelect.
  ///
  /// In en, this message translates to:
  /// **'Hex Viewer.Multi-Select'**
  String get hexViewerMultiSelect;

  /// No description provided for @hexViewerText12.
  ///
  /// In en, this message translates to:
  /// **'Hex Viewer.Text 12px'**
  String get hexViewerText12;

  /// No description provided for @cannotReadMediaInfo.
  ///
  /// In en, this message translates to:
  /// **'Cannot read media info'**
  String get cannotReadMediaInfo;

  /// No description provided for @mediaInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Info'**
  String get mediaInfoTitle;

  /// No description provided for @mediaFile.
  ///
  /// In en, this message translates to:
  /// **'Media file'**
  String get mediaFile;

  /// No description provided for @viewInfo.
  ///
  /// In en, this message translates to:
  /// **'View Info'**
  String get viewInfo;

  /// No description provided for @formatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format: \$\$format'**
  String get formatLabel;

  /// No description provided for @toolTitle.
  ///
  /// In en, this message translates to:
  /// **'Tool Title'**
  String get toolTitle;

  /// No description provided for @formatConvertDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert video format, codec, resolution'**
  String get formatConvertDesc;

  /// No description provided for @makeGifDesc.
  ///
  /// In en, this message translates to:
  /// **'Extract clip from video to make GIF'**
  String get makeGifDesc;

  /// No description provided for @videoCompressTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Compress'**
  String get videoCompressTitle;

  /// No description provided for @videoCompressDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce video file size'**
  String get videoCompressDesc;

  /// No description provided for @videoTrimTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Trim'**
  String get videoTrimTitle;

  /// No description provided for @videoTrimDesc.
  ///
  /// In en, this message translates to:
  /// **'Trim video clip'**
  String get videoTrimDesc;

  /// No description provided for @audioExtractDesc.
  ///
  /// In en, this message translates to:
  /// **'Extract audio from video'**
  String get audioExtractDesc;

  /// No description provided for @viewFileDetails.
  ///
  /// In en, this message translates to:
  /// **'View file details'**
  String get viewFileDetails;

  /// No description provided for @textViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Viewer'**
  String get textViewerTitle;

  /// No description provided for @textViewerFileSize.
  ///
  /// In en, this message translates to:
  /// **'Text Viewer.File Size'**
  String get textViewerFileSize;

  /// No description provided for @textViewerMultiSelect.
  ///
  /// In en, this message translates to:
  /// **'Text Viewer.Multi-Select'**
  String get textViewerMultiSelect;

  /// No description provided for @compressFailed.
  ///
  /// In en, this message translates to:
  /// **'Compression failed (code: \$\$rc)'**
  String get compressFailed;

  /// No description provided for @targetBitrate.
  ///
  /// In en, this message translates to:
  /// **'Target bitrate'**
  String get targetBitrate;

  /// No description provided for @bitrate500.
  ///
  /// In en, this message translates to:
  /// **'500 kbps (high compression)'**
  String get bitrate500;

  /// No description provided for @bitrate1000.
  ///
  /// In en, this message translates to:
  /// **'1000 kbps (recommended)'**
  String get bitrate1000;

  /// No description provided for @bitrate4000.
  ///
  /// In en, this message translates to:
  /// **'4000 kbps (high quality)'**
  String get bitrate4000;

  /// No description provided for @maxWidth.
  ///
  /// In en, this message translates to:
  /// **'Max width'**
  String get maxWidth;

  /// No description provided for @resolution720.
  ///
  /// In en, this message translates to:
  /// **'720p (recommended)'**
  String get resolution720;

  /// No description provided for @keepOriginal.
  ///
  /// In en, this message translates to:
  /// **'Keep original'**
  String get keepOriginal;

  /// No description provided for @compressComplete.
  ///
  /// In en, this message translates to:
  /// **'Compression complete!'**
  String get compressComplete;

  /// No description provided for @compressingMsg.
  ///
  /// In en, this message translates to:
  /// **'Compressing...'**
  String get compressingMsg;

  /// No description provided for @startCompress.
  ///
  /// In en, this message translates to:
  /// **'Start compression'**
  String get startCompress;

  /// No description provided for @convertFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed (code=\$\$rc)'**
  String get convertFailed;

  /// No description provided for @videoFormatConvert.
  ///
  /// In en, this message translates to:
  /// **'Video Format Convert'**
  String get videoFormatConvert;

  /// No description provided for @convertDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert Dialog'**
  String get convertDialogTitle;

  /// No description provided for @codecFormat.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get codecFormat;

  /// No description provided for @containerFormat.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get containerFormat;

  /// No description provided for @bitrateKbps.
  ///
  /// In en, this message translates to:
  /// **'Bitrate (kbps)'**
  String get bitrateKbps;

  /// No description provided for @autoBitrate.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoBitrate;

  /// No description provided for @resolutionScale.
  ///
  /// In en, this message translates to:
  /// **'Resolution scale'**
  String get resolutionScale;

  /// No description provided for @convertFrame.
  ///
  /// In en, this message translates to:
  /// **'\$\$_current / \$\$_total frames'**
  String get convertFrame;

  /// No description provided for @convertDialogDone.
  ///
  /// In en, this message translates to:
  /// **'Convert Dialog.Convert Done'**
  String get convertDialogDone;

  /// No description provided for @convertComplete.
  ///
  /// In en, this message translates to:
  /// **'Conversion complete'**
  String get convertComplete;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @startConvert.
  ///
  /// In en, this message translates to:
  /// **'Start conversion'**
  String get startConvert;

  /// No description provided for @noVideoFound.
  ///
  /// In en, this message translates to:
  /// **'No video files found'**
  String get noVideoFound;

  /// No description provided for @selectVideoHint.
  ///
  /// In en, this message translates to:
  /// **'Select video file or directory...'**
  String get selectVideoHint;

  /// No description provided for @browseBtn.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseBtn;

  /// No description provided for @convertAllInDir.
  ///
  /// In en, this message translates to:
  /// **'Convert all video files in directory'**
  String get convertAllInDir;

  /// No description provided for @inputFileDir.
  ///
  /// In en, this message translates to:
  /// **'Input file/directory'**
  String get inputFileDir;

  /// No description provided for @selectOutputDir.
  ///
  /// In en, this message translates to:
  /// **'Select output directory...'**
  String get selectOutputDir;

  /// No description provided for @outputSettings.
  ///
  /// In en, this message translates to:
  /// **'Output Settings'**
  String get outputSettings;

  /// No description provided for @selectThisDir.
  ///
  /// In en, this message translates to:
  /// **'Select this directory'**
  String get selectThisDir;

  /// No description provided for @hwNotSupported.
  ///
  /// In en, this message translates to:
  /// **'HW decode not supported, switched to SW'**
  String get hwNotSupported;

  /// No description provided for @hwDecode.
  ///
  /// In en, this message translates to:
  /// **'HW'**
  String get hwDecode;

  /// No description provided for @swDecode.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get swDecode;

  /// No description provided for @trimFailed.
  ///
  /// In en, this message translates to:
  /// **'Trim failed'**
  String get trimFailed;

  /// No description provided for @trimComplete.
  ///
  /// In en, this message translates to:
  /// **'Trim complete!'**
  String get trimComplete;

  /// No description provided for @trimmingMsg.
  ///
  /// In en, this message translates to:
  /// **'Trimming...'**
  String get trimmingMsg;

  /// No description provided for @startTrim.
  ///
  /// In en, this message translates to:
  /// **'Start trim'**
  String get startTrim;

  /// No description provided for @batch_rename_prefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get batch_rename_prefix;

  /// No description provided for @batch_rename_suffix.
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get batch_rename_suffix;

  /// No description provided for @batch_rename_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get batch_rename_replace;

  /// No description provided for @batch_rename_start_num.
  ///
  /// In en, this message translates to:
  /// **'Start number'**
  String get batch_rename_start_num;

  /// No description provided for @new_file_hint.
  ///
  /// In en, this message translates to:
  /// **'Filename (e.g. note.txt)'**
  String get new_file_hint;

  /// No description provided for @new_folder_hint.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get new_folder_hint;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @permission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permission;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword...'**
  String get search_hint;

  /// No description provided for @paste_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste_tooltip;

  /// No description provided for @exit_multi_select.
  ///
  /// In en, this message translates to:
  /// **'Exit multi-select'**
  String get exit_multi_select;

  /// No description provided for @multi_select.
  ///
  /// In en, this message translates to:
  /// **'Multi-select'**
  String get multi_select;

  /// No description provided for @hide_hidden.
  ///
  /// In en, this message translates to:
  /// **'Hide hidden files'**
  String get hide_hidden;

  /// No description provided for @show_hidden.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get show_hidden;

  /// No description provided for @list_view.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get list_view;

  /// No description provided for @grid_view.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get grid_view;

  /// No description provided for @remove_bookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get remove_bookmark;

  /// No description provided for @add_bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark current directory'**
  String get add_bookmark;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get light_mode;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get dark_mode;

  /// No description provided for @confirm_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm_tooltip;

  /// No description provided for @edit_path_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit path'**
  String get edit_path_tooltip;

  /// No description provided for @batch_rename_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Batch rename'**
  String get batch_rename_tooltip;

  /// No description provided for @batch_trash_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Batch move to trash'**
  String get batch_trash_tooltip;

  /// No description provided for @empty_trash_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get empty_trash_tooltip;

  /// No description provided for @restore_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore_tooltip;

  /// No description provided for @batch_rename_title.
  ///
  /// In en, this message translates to:
  /// **'{count} items to rename'**
  String batch_rename_title(Object count);

  /// No description provided for @cut_done.
  ///
  /// In en, this message translates to:
  /// **'Cut: {name}'**
  String cut_done(Object name);

  /// No description provided for @copy_done.
  ///
  /// In en, this message translates to:
  /// **'Copied: {name}'**
  String copy_done(Object name);

  /// No description provided for @paste_result.
  ///
  /// In en, this message translates to:
  /// **'Paste: {ok} succeeded'**
  String paste_result(Object ok);

  /// No description provided for @paste_skip.
  ///
  /// In en, this message translates to:
  /// **', {skip} skipped'**
  String paste_skip(Object skip);

  /// No description provided for @paste_fail.
  ///
  /// In en, this message translates to:
  /// **', {fail} failed'**
  String paste_fail(Object fail);

  /// No description provided for @confirm_trash_title.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get confirm_trash_title;

  /// No description provided for @confirm_trash_msg.
  ///
  /// In en, this message translates to:
  /// **'Move \"{name}\" to trash?'**
  String confirm_trash_msg(Object name);

  /// No description provided for @compress_done.
  ///
  /// In en, this message translates to:
  /// **'Compression complete: {name}'**
  String compress_done(Object name);

  /// No description provided for @encrypted_suffix.
  ///
  /// In en, this message translates to:
  /// **' (encrypted)'**
  String get encrypted_suffix;

  /// No description provided for @selected_count.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected_count(Object count);

  /// No description provided for @selected_n.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected_n(Object count);

  /// No description provided for @extract_to.
  ///
  /// In en, this message translates to:
  /// **'Extract to…'**
  String get extract_to;

  /// No description provided for @archive_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password (leave empty if none)'**
  String get archive_password_hint;

  /// No description provided for @extract_failed.
  ///
  /// In en, this message translates to:
  /// **'Extraction failed'**
  String get extract_failed;

  /// No description provided for @extracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting...'**
  String get extracting;

  /// No description provided for @start_extract.
  ///
  /// In en, this message translates to:
  /// **'Start extraction'**
  String get start_extract;

  /// No description provided for @cannot_decode_audio.
  ///
  /// In en, this message translates to:
  /// **'Cannot decode audio'**
  String get cannot_decode_audio;

  /// No description provided for @display_settings.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get display_settings;

  /// No description provided for @global_scale.
  ///
  /// In en, this message translates to:
  /// **'Global Scale'**
  String get global_scale;

  /// No description provided for @items_configurable.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items_configurable;

  /// No description provided for @restore_defaults.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get restore_defaults;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @making_gif.
  ///
  /// In en, this message translates to:
  /// **'Making...'**
  String get making_gif;

  /// No description provided for @start_making.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start_making;

  /// No description provided for @hex_search_hint.
  ///
  /// In en, this message translates to:
  /// **'FF D8 FF E0 or hello'**
  String get hex_search_hint;

  /// No description provided for @cannot_read_media_info.
  ///
  /// In en, this message translates to:
  /// **'Cannot read media info'**
  String get cannot_read_media_info;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @format_convert.
  ///
  /// In en, this message translates to:
  /// **'Format Convert'**
  String get format_convert;

  /// No description provided for @format_convert_desc.
  ///
  /// In en, this message translates to:
  /// **'Convert video format, codec, resolution'**
  String get format_convert_desc;

  /// No description provided for @make_gif.
  ///
  /// In en, this message translates to:
  /// **'Make GIF'**
  String get make_gif;

  /// No description provided for @make_gif_desc.
  ///
  /// In en, this message translates to:
  /// **'Extract clip from video to make GIF'**
  String get make_gif_desc;

  /// No description provided for @video_compress.
  ///
  /// In en, this message translates to:
  /// **'Video Compress'**
  String get video_compress;

  /// No description provided for @video_compress_desc.
  ///
  /// In en, this message translates to:
  /// **'Reduce video file size'**
  String get video_compress_desc;

  /// No description provided for @video_trim.
  ///
  /// In en, this message translates to:
  /// **'Video Trim'**
  String get video_trim;

  /// No description provided for @video_trim_desc.
  ///
  /// In en, this message translates to:
  /// **'Trim video clip'**
  String get video_trim_desc;

  /// No description provided for @audio_extract.
  ///
  /// In en, this message translates to:
  /// **'Audio Extract'**
  String get audio_extract;

  /// No description provided for @audio_extract_desc.
  ///
  /// In en, this message translates to:
  /// **'Extract audio from video'**
  String get audio_extract_desc;

  /// No description provided for @media_info.
  ///
  /// In en, this message translates to:
  /// **'Media Info'**
  String get media_info;

  /// No description provided for @media_info_desc.
  ///
  /// In en, this message translates to:
  /// **'View file details'**
  String get media_info_desc;

  /// No description provided for @compressing.
  ///
  /// In en, this message translates to:
  /// **'Compressing...'**
  String get compressing;

  /// No description provided for @start_compress.
  ///
  /// In en, this message translates to:
  /// **'Start compression'**
  String get start_compress;

  /// No description provided for @no_video_files.
  ///
  /// In en, this message translates to:
  /// **'No video files found'**
  String get no_video_files;

  /// No description provided for @select_video_file_or_dir.
  ///
  /// In en, this message translates to:
  /// **'Select video file or directory...'**
  String get select_video_file_or_dir;

  /// No description provided for @select_output_dir.
  ///
  /// In en, this message translates to:
  /// **'Select output directory...'**
  String get select_output_dir;

  /// No description provided for @hw_decode.
  ///
  /// In en, this message translates to:
  /// **'HW'**
  String get hw_decode;

  /// No description provided for @sw_decode.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get sw_decode;

  /// No description provided for @trim_failed.
  ///
  /// In en, this message translates to:
  /// **'Trim failed'**
  String get trim_failed;

  /// No description provided for @trimming.
  ///
  /// In en, this message translates to:
  /// **'Trimming...'**
  String get trimming;

  /// No description provided for @start_trim.
  ///
  /// In en, this message translates to:
  /// **'Start trim'**
  String get start_trim;

  /// No description provided for @extract_fmt.
  ///
  /// In en, this message translates to:
  /// **'Extract {fmt}'**
  String extract_fmt(Object fmt);

  /// No description provided for @gif_start_sec.
  ///
  /// In en, this message translates to:
  /// **'Start: {sec}s'**
  String gif_start_sec(Object sec);

  /// No description provided for @gif_duration_sec.
  ///
  /// In en, this message translates to:
  /// **'Duration: {sec}s'**
  String gif_duration_sec(Object sec);

  /// No description provided for @gif_fps.
  ///
  /// In en, this message translates to:
  /// **'FPS: {fps}'**
  String gif_fps(Object fps);

  /// No description provided for @compress_failed_code.
  ///
  /// In en, this message translates to:
  /// **'Compression failed (code: {code})'**
  String compress_failed_code(Object code);

  /// No description provided for @convert_failed_code.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed (code={code})'**
  String convert_failed_code(Object code);

  /// No description provided for @convert_failed_file.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed: {file}'**
  String convert_failed_file(Object file);

  /// No description provided for @gif_width.
  ///
  /// In en, this message translates to:
  /// **'Width: {w}'**
  String gif_width(Object w);

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @trim_start.
  ///
  /// In en, this message translates to:
  /// **'Start: {t}'**
  String trim_start(Object t);

  /// No description provided for @trim_end.
  ///
  /// In en, this message translates to:
  /// **'End: {t}'**
  String trim_end(Object t);

  /// No description provided for @archive_file_count.
  ///
  /// In en, this message translates to:
  /// **'{files} files{dirs}'**
  String archive_file_count(Object dirs, Object files);

  /// No description provided for @archive_dir_count.
  ///
  /// In en, this message translates to:
  /// **', {dirs} dirs'**
  String archive_dir_count(Object dirs);

  /// No description provided for @archive_summary.
  ///
  /// In en, this message translates to:
  /// **'\$\$_fmt · \$\$_items_count items · \$\$_size'**
  String get archive_summary;

  /// No description provided for @media_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {val}'**
  String media_duration(Object val);

  /// No description provided for @media_duration_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get media_duration_unknown;

  /// No description provided for @media_streams.
  ///
  /// In en, this message translates to:
  /// **'Streams ({count})'**
  String media_streams(Object count);

  /// No description provided for @input_label.
  ///
  /// In en, this message translates to:
  /// **'Input: {name}'**
  String input_label(Object name);

  /// No description provided for @output_label.
  ///
  /// In en, this message translates to:
  /// **'Output: {name}'**
  String output_label(Object name);

  /// No description provided for @tv_lines.
  ///
  /// In en, this message translates to:
  /// **'{count} lines'**
  String tv_lines(Object count);

  /// No description provided for @tv_chars.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String tv_chars(Object count);

  /// No description provided for @tv_keyword_hint.
  ///
  /// In en, this message translates to:
  /// **'keyword...'**
  String get tv_keyword_hint;

  /// No description provided for @tv_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get tv_clear;

  /// No description provided for @tv_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tv_search;

  /// No description provided for @tv_search_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tv_search_tooltip;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @textEditor.
  ///
  /// In en, this message translates to:
  /// **'Text Editor'**
  String get textEditor;

  /// No description provided for @pdfPreview.
  ///
  /// In en, this message translates to:
  /// **'PDF Preview'**
  String get pdfPreview;

  /// No description provided for @mdPreview.
  ///
  /// In en, this message translates to:
  /// **'Markdown Preview'**
  String get mdPreview;

  /// No description provided for @storageAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Storage Analysis'**
  String get storageAnalysis;

  /// No description provided for @cannot_load_file.
  ///
  /// In en, this message translates to:
  /// **'Cannot load file'**
  String get cannot_load_file;

  /// No description provided for @file_info.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file_info;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @appManager.
  ///
  /// In en, this message translates to:
  /// **'File Manager'**
  String get appManager;

  /// No description provided for @authorInfo.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorInfo;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get architecture;

  /// No description provided for @architectureDesc.
  ///
  /// In en, this message translates to:
  /// **'Flutter + C native layer (FFI)'**
  String get architectureDesc;

  /// No description provided for @iconsSpec.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get iconsSpec;

  /// No description provided for @iconsSpecDesc.
  ///
  /// In en, this message translates to:
  /// **'All icons use CupertinoIcons fill style'**
  String get iconsSpecDesc;

  /// No description provided for @localization.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localization;

  /// No description provided for @localizationDesc.
  ///
  /// In en, this message translates to:
  /// **'EN/ZH bilingual, 350+ keys'**
  String get localizationDesc;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @performanceDesc.
  ///
  /// In en, this message translates to:
  /// **'All I/O async, heavy ops use Isolate'**
  String get performanceDesc;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @platformDesc.
  ///
  /// In en, this message translates to:
  /// **'Linux, Android via FFI bridge'**
  String get platformDesc;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @fileOperations.
  ///
  /// In en, this message translates to:
  /// **'File Operations'**
  String get fileOperations;

  /// No description provided for @fileOperationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse, search, sort, multi-select\nCopy, move, delete (trash), rename'**
  String get fileOperationsDesc;

  /// No description provided for @viewers.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get viewers;

  /// No description provided for @viewersDesc.
  ///
  /// In en, this message translates to:
  /// **'Text, Image, Video, Audio\nPDF, Markdown, Hex, Ebook, GIF'**
  String get viewersDesc;

  /// No description provided for @toolsDesc.
  ///
  /// In en, this message translates to:
  /// **'File compare, duplicate cleaner, storage\nFormat convert, video compress/trim, media info'**
  String get toolsDesc;

  /// No description provided for @settingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme toggle, language switch\nFont size, UI scaling'**
  String get settingsDesc;

  /// No description provided for @privacyAndDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Disclaimer'**
  String get privacyAndDisclaimer;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'No personal data collected\nAll operations local, no tracking'**
  String get privacyPolicyDesc;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @disclaimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Provided as is, no warranty\nBackup important data yourself'**
  String get disclaimerDesc;

  /// No description provided for @dualPanel.
  ///
  /// In en, this message translates to:
  /// **'Dual Panel'**
  String get dualPanel;

  /// No description provided for @copyToOtherPanel.
  ///
  /// In en, this message translates to:
  /// **'Copy to other panel'**
  String get copyToOtherPanel;

  /// No description provided for @moveToOtherPanel.
  ///
  /// In en, this message translates to:
  /// **'Move to other panel'**
  String get moveToOtherPanel;

  /// No description provided for @copyingFiles.
  ///
  /// In en, this message translates to:
  /// **'Copying'**
  String get copyingFiles;

  /// No description provided for @movingFiles.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get movingFiles;

  /// No description provided for @deletingFiles.
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get deletingFiles;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating'**
  String get creating;

  /// No description provided for @renaming.
  ///
  /// In en, this message translates to:
  /// **'Renaming'**
  String get renaming;

  /// No description provided for @copyCount.
  ///
  /// In en, this message translates to:
  /// **'Copying'**
  String get copyCount;

  /// No description provided for @moveCount.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get moveCount;

  /// No description provided for @deleteCount.
  ///
  /// In en, this message translates to:
  /// **'Deleting'**
  String get deleteCount;

  /// No description provided for @scanningDir.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get scanningDir;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @directories.
  ///
  /// In en, this message translates to:
  /// **'Directories'**
  String get directories;

  /// No description provided for @largestFiles.
  ///
  /// In en, this message translates to:
  /// **'Largest Files'**
  String get largestFiles;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @selectPathsToScan.
  ///
  /// In en, this message translates to:
  /// **'Select paths to scan'**
  String get selectPathsToScan;

  /// No description provided for @supportsMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple directories supported'**
  String get supportsMultiple;

  /// No description provided for @addPath.
  ///
  /// In en, this message translates to:
  /// **'Add Path'**
  String get addPath;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get startScan;

  /// No description provided for @addDirsToScan.
  ///
  /// In en, this message translates to:
  /// **'Add directories to scan'**
  String get addDirsToScan;

  /// No description provided for @noDuplicates.
  ///
  /// In en, this message translates to:
  /// **'No duplicates found'**
  String get noDuplicates;

  /// No description provided for @scannedFiles.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get scannedFiles;

  /// No description provided for @groupsOfDuplicates.
  ///
  /// In en, this message translates to:
  /// **'groups'**
  String get groupsOfDuplicates;

  /// No description provided for @filesTotal.
  ///
  /// In en, this message translates to:
  /// **'files total'**
  String get filesTotal;

  /// No description provided for @selectPath.
  ///
  /// In en, this message translates to:
  /// **'Select Directory'**
  String get selectPath;

  /// No description provided for @selectHere.
  ///
  /// In en, this message translates to:
  /// **'Select Here'**
  String get selectHere;

  /// No description provided for @inputFileOrDir.
  ///
  /// In en, this message translates to:
  /// **'Select input file or directory'**
  String get inputFileOrDir;

  /// No description provided for @outputDir.
  ///
  /// In en, this message translates to:
  /// **'Select output directory'**
  String get outputDir;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get saveChanges;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @copyingNFiles.
  ///
  /// In en, this message translates to:
  /// **'Copying {count} files...'**
  String copyingNFiles(Object count);

  /// No description provided for @movingNFiles.
  ///
  /// In en, this message translates to:
  /// **'Moving {count} files...'**
  String movingNFiles(Object count);

  /// No description provided for @deletingNFiles.
  ///
  /// In en, this message translates to:
  /// **'Deleting {count} files...'**
  String deletingNFiles(Object count);

  /// No description provided for @scannedNFiles.
  ///
  /// In en, this message translates to:
  /// **'Scanned {count} files'**
  String scannedNFiles(Object count);

  /// No description provided for @nFilesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} files total'**
  String nFilesTotal(Object count);

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @selectTwoFilesToCompare.
  ///
  /// In en, this message translates to:
  /// **'Select two files to compare'**
  String get selectTwoFilesToCompare;

  /// No description provided for @saveChangesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get saveChangesPrompt;

  /// No description provided for @duplicateCleaner.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Cleaner'**
  String get duplicateCleaner;

  /// No description provided for @scanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get scanned;

  /// No description provided for @fileCompare.
  ///
  /// In en, this message translates to:
  /// **'File Compare'**
  String get fileCompare;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @fileTools.
  ///
  /// In en, this message translates to:
  /// **'File Tools'**
  String get fileTools;

  /// No description provided for @copiesOf.
  ///
  /// In en, this message translates to:
  /// **'copies'**
  String get copiesOf;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
