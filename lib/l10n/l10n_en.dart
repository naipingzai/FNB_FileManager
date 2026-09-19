// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'File Manager';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get switchLang => 'Switch Language';

  @override
  String get theme => 'Theme';

  @override
  String get followSystem => 'Follow System';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get fontSize => 'Font Size';

  @override
  String get gridColumns => 'Grid Columns';

  @override
  String get files => 'Files';

  @override
  String get tags => 'Tags';

  @override
  String get more => 'More';

  @override
  String get search => 'Search';

  @override
  String get import => 'Import';

  @override
  String get properties => 'Properties';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get copy => 'Copy';

  @override
  String get move => 'Move';

  @override
  String get select => 'Select';

  @override
  String get selectAll => 'Select All';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get name => 'Name';

  @override
  String get size => 'Size';

  @override
  String get modified => 'Modified';

  @override
  String get type => 'Type';

  @override
  String get folder => 'Folder';

  @override
  String get file => 'File';

  @override
  String get noFiles => 'No files yet';

  @override
  String get importFiles => 'Import files to get started';

  @override
  String get tagManage => 'Manage Tags';

  @override
  String get tagSearch => 'Search by Tag';

  @override
  String get createTag => 'Create Tag';

  @override
  String get editTag => 'Edit Tag';

  @override
  String get deleteTag => 'Delete Tag';

  @override
  String get tagName => 'Tag Name';

  @override
  String get tagColor => 'Tag Color';

  @override
  String get recycleBin => 'Recycle Bin';

  @override
  String get emptyRecycleBin => 'Empty Recycle Bin';

  @override
  String get restore => 'Restore';

  @override
  String version(String version) {
    return 'Version: $version';
  }

  @override
  String nativeVersion(String version) {
    return 'Native: v$version';
  }

  @override
  String get prefix => 'Prefix';

  @override
  String get suffix => 'Suffix';

  @override
  String get replaceWith => 'Replace';

  @override
  String get sequenceNum => 'Sequence';

  @override
  String get find => 'Find';

  @override
  String get replaceWithField => 'Replace with';

  @override
  String get startNum => 'Start number';

  @override
  String get newFile => 'New File';

  @override
  String get filenameHint => 'Filename (e.g. note.txt)';

  @override
  String get create => 'Create';

  @override
  String get needFileAccess => 'File access permission required';

  @override
  String get needFileAccessDesc =>
      'This app needs \"All files access\" to work properly. Please enable it in the next settings page.';

  @override
  String get goAuthorize => 'Authorize';

  @override
  String get fileAccessDenied =>
      'File access not authorized, some features may be limited';

  @override
  String get binaryFileError =>
      'This is a binary file and cannot be opened directly.';

  @override
  String get hexView => 'Hex View';

  @override
  String get open => 'Open';

  @override
  String get extract => 'Extract';

  @override
  String get copyAction => 'Copy';

  @override
  String get cutAction => 'Cut';

  @override
  String get moveToTrash => 'Move to Trash';

  @override
  String get compress => 'Compress';

  @override
  String get propertiesAction => 'Properties';

  @override
  String pasteFail(Object fail) {
    return ', $fail failed';
  }

  @override
  String get fileExists => 'File already exists';

  @override
  String get fileExistsMsg => '\"\$\$name\" already exists';

  @override
  String get skip => 'Skip';

  @override
  String get keepBoth => 'Keep Both';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get newFolder => 'New Folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get ok => 'OK';

  @override
  String get moveAction => 'Move';

  @override
  String get cannotOpenFile => 'Cannot open this file';

  @override
  String get shareFailed => 'Share failed: \$\$e';

  @override
  String get compressFilename => 'Compressed filename';

  @override
  String get encryptCompress => 'Encrypted compression';

  @override
  String get password => 'Password';

  @override
  String get propType => 'Type';

  @override
  String get propFolder => 'Folder';

  @override
  String get propSize => 'Size';

  @override
  String get propModified => 'Modified';

  @override
  String get propPermission => 'Permission';

  @override
  String get propPath => 'Path';

  @override
  String get propChecksum => 'Checksum';

  @override
  String get fileBrowser => 'File Browser';

  @override
  String get multiSelectBtn => 'Multi-Select';

  @override
  String get fileBrowserFileSize => 'File Browser.File Size';

  @override
  String get calculatingHash => 'Calculating hash...';

  @override
  String get compressFormatSelect => 'Compression Format';

  @override
  String get closeAction => 'Close';

  @override
  String get shareAction => 'Share';

  @override
  String get filename => 'Filename';

  @override
  String get searchFilename => 'Search filename';

  @override
  String get searchKeyword => 'Enter keyword...';

  @override
  String get clearAction => 'Clear';

  @override
  String get searchAction => 'Search';

  @override
  String get tools => 'Tools';

  @override
  String get appBarTitle => 'App Bar Title';

  @override
  String get homeDir => 'Home';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get bookmarkHint => 'Long press a folder to add bookmark';

  @override
  String get mediaToolsTitle => 'Media Tools';

  @override
  String get displaySettingsTitle => 'Display Settings';

  @override
  String get pasteAction => 'Paste';

  @override
  String get exitMultiSelect => 'Exit multi-select';

  @override
  String get multiSelect => 'Multi-select';

  @override
  String get trashTitle => 'Trash';

  @override
  String get sortByName => 'By name';

  @override
  String get sortBySize => 'By size';

  @override
  String get sortByDate => 'By date';

  @override
  String get sortByType => 'By type';

  @override
  String get hideHiddenFiles => 'Hide hidden files';

  @override
  String get showHiddenFiles => 'Show hidden files';

  @override
  String get listView => 'List view';

  @override
  String get gridView => 'Grid view';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get addBookmark => 'Bookmark current directory';

  @override
  String get langChinese => 'Chinese';

  @override
  String get addrBarText => 'Address Bar';

  @override
  String get confirmBtn => 'Confirm';

  @override
  String get editPath => 'Edit path';

  @override
  String get invertSelection => 'Invert';

  @override
  String get batchRename => 'Batch rename';

  @override
  String get batchTrash => 'Batch move to trash';

  @override
  String get deleteAction => 'Delete';

  @override
  String get formatConvert => 'Format Convert';

  @override
  String get fileSize => 'File Size';

  @override
  String get compressingStatus => 'Compressing...';

  @override
  String get restored => 'Restored: \$\$name';

  @override
  String get emptyTrashAction => 'Empty Trash';

  @override
  String get emptyTrashConfirm =>
      'Are you sure you want to permanently delete all files in trash? This cannot be undone.';

  @override
  String get emptyAction => 'Empty';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get restoreAction => 'Restore';

  @override
  String get extractDone => 'Extract complete → \$\$od';

  @override
  String get archiveViewerTitle => 'Archive Viewer';

  @override
  String get archiveEmpty => 'Archive is empty';

  @override
  String get extractTo => 'Extract to…';

  @override
  String extractFmt(Object fmt) {
    return 'Extract $fmt';
  }

  @override
  String get selectExtractTarget => 'Select extract destination';

  @override
  String get selectAction => 'Select';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get archivePasswordHint => 'Password (leave empty if none)';

  @override
  String get audioExtractTitle => 'Audio Extract';

  @override
  String get videoFile => 'Video file';

  @override
  String get outputPathHint => 'Output path (without extension)';

  @override
  String get outputFormat => 'Output format';

  @override
  String get progress => 'Progress: \$\$_current / \$\$_total';

  @override
  String get extractComplete => 'Extraction complete!';

  @override
  String get extractingStatus => 'Extracting...';

  @override
  String get startExtract => 'Start extraction';

  @override
  String get audioPlayerTitle => 'Audio Player';

  @override
  String get swipeHint => '← Swipe left/right to switch →';

  @override
  String get pcmParams => 'PCM Format Parameters';

  @override
  String get sampleRate => 'Sample Rate (Hz)';

  @override
  String get channels => 'Channels';

  @override
  String get bitDepth => 'Bit Depth (bit)';

  @override
  String get byteOrder => 'Byte Order';

  @override
  String get littleEndian => 'Little-Endian';

  @override
  String get bigEndian => 'Big-Endian';

  @override
  String get globalScale => 'Global Scale';

  @override
  String get itemsConfigurable => 'items configurable';

  @override
  String get resetDefaults => 'Reset';

  @override
  String get applyBtn => 'Apply';

  @override
  String get makeGif => 'Make GIF';

  @override
  String gifStartSec(Object sec) {
    return 'Start: ${sec}s';
  }

  @override
  String gifDurationSec(Object sec) {
    return 'Duration: ${sec}s';
  }

  @override
  String gifFps(Object fps) {
    return 'FPS: $fps';
  }

  @override
  String get gifFrame => 'Frame: \$\$_current / \$\$_total';

  @override
  String get gifMakerTitle => 'GIF Maker';

  @override
  String get gifComplete => 'GIF creation complete!';

  @override
  String get gifMaking => 'Making...';

  @override
  String get startMaking => 'Start';

  @override
  String hexBytesPerLine(Object n) {
    return '$n bytes per line';
  }

  @override
  String get hexSearch => 'Search (HEX or ASCII)';

  @override
  String get hexSearchHint => 'FF D8 FF E0 or hello';

  @override
  String get hexViewerMultiSelect => 'Hex Viewer.Multi-Select';

  @override
  String get hexViewerText12 => 'Hex Viewer.Text 12px';

  @override
  String get cannotReadMediaInfo => 'Cannot read media info';

  @override
  String get mediaInfoTitle => 'Media Info';

  @override
  String get mediaFile => 'Media file';

  @override
  String get viewInfo => 'View Info';

  @override
  String get formatLabel => 'Format: \$\$format';

  @override
  String get toolTitle => 'Tool Title';

  @override
  String get formatConvertDesc => 'Convert video format, codec, resolution';

  @override
  String get makeGifDesc => 'Extract clip from video to make GIF';

  @override
  String get videoCompressTitle => 'Video Compress';

  @override
  String get videoCompressDesc => 'Reduce video file size';

  @override
  String get videoTrimTitle => 'Video Trim';

  @override
  String get videoTrimDesc => 'Trim video clip';

  @override
  String get audioExtractDesc => 'Extract audio from video';

  @override
  String get viewFileDetails => 'View file details';

  @override
  String get textViewerTitle => 'Text Viewer';

  @override
  String get textViewerFileSize => 'Text Viewer.File Size';

  @override
  String get textViewerMultiSelect => 'Text Viewer.Multi-Select';

  @override
  String get compressFailed => 'Compression failed (code: \$\$rc)';

  @override
  String get targetBitrate => 'Target bitrate';

  @override
  String get bitrate500 => '500 kbps (high compression)';

  @override
  String get bitrate1000 => '1000 kbps (recommended)';

  @override
  String get bitrate4000 => '4000 kbps (high quality)';

  @override
  String get maxWidth => 'Max width';

  @override
  String get resolution720 => '720p (recommended)';

  @override
  String get keepOriginal => 'Keep original';

  @override
  String get compressComplete => 'Compression complete!';

  @override
  String get compressingMsg => 'Compressing...';

  @override
  String get startCompress => 'Start compression';

  @override
  String get convertFailed => 'Conversion failed (code=\$\$rc)';

  @override
  String get videoFormatConvert => 'Video Format Convert';

  @override
  String get convertDialogTitle => 'Convert Dialog';

  @override
  String get codecFormat => 'Codec';

  @override
  String get containerFormat => 'Container';

  @override
  String get bitrateKbps => 'Bitrate (kbps)';

  @override
  String get autoBitrate => 'Auto';

  @override
  String get resolutionScale => 'Resolution scale';

  @override
  String get convertFrame => '\$\$_current / \$\$_total frames';

  @override
  String get convertDialogDone => 'Convert Dialog.Convert Done';

  @override
  String get convertComplete => 'Conversion complete';

  @override
  String get openFolder => 'Open folder';

  @override
  String get startConvert => 'Start conversion';

  @override
  String get noVideoFound => 'No video files found';

  @override
  String get selectVideoHint => 'Select video file or directory...';

  @override
  String get browseBtn => 'Browse';

  @override
  String get convertAllInDir => 'Convert all video files in directory';

  @override
  String get inputFileDir => 'Input file/directory';

  @override
  String get selectOutputDir => 'Select output directory...';

  @override
  String get outputSettings => 'Output Settings';

  @override
  String get selectThisDir => 'Select this directory';

  @override
  String get hwNotSupported => 'HW decode not supported, switched to SW';

  @override
  String get hwDecode => 'HW';

  @override
  String get swDecode => 'SW';

  @override
  String get trimFailed => 'Trim failed';

  @override
  String get trimComplete => 'Trim complete!';

  @override
  String get trimmingMsg => 'Trimming...';

  @override
  String get startTrim => 'Start trim';

  @override
  String get batch_rename_prefix => 'Prefix';

  @override
  String get batch_rename_suffix => 'Suffix';

  @override
  String get batch_rename_replace => 'Replace with';

  @override
  String get batch_rename_start_num => 'Start number';

  @override
  String get new_file_hint => 'Filename (e.g. note.txt)';

  @override
  String get new_folder_hint => 'Folder name';

  @override
  String get created => 'Created';

  @override
  String get permission => 'Permission';

  @override
  String get path => 'Path';

  @override
  String get search_hint => 'Enter keyword...';

  @override
  String get paste_tooltip => 'Paste';

  @override
  String get exit_multi_select => 'Exit multi-select';

  @override
  String get multi_select => 'Multi-select';

  @override
  String get hide_hidden => 'Hide hidden files';

  @override
  String get show_hidden => 'Show hidden files';

  @override
  String get list_view => 'List view';

  @override
  String get grid_view => 'Grid view';

  @override
  String get remove_bookmark => 'Remove bookmark';

  @override
  String get add_bookmark => 'Bookmark current directory';

  @override
  String get chinese => 'Chinese';

  @override
  String get light_mode => 'Light mode';

  @override
  String get dark_mode => 'Dark mode';

  @override
  String get confirm_tooltip => 'Confirm';

  @override
  String get edit_path_tooltip => 'Edit path';

  @override
  String get batch_rename_tooltip => 'Batch rename';

  @override
  String get batch_trash_tooltip => 'Batch move to trash';

  @override
  String get empty_trash_tooltip => 'Empty trash';

  @override
  String get restore_tooltip => 'Restore';

  @override
  String batch_rename_title(Object count) {
    return '$count items to rename';
  }

  @override
  String cut_done(Object name) {
    return 'Cut: $name';
  }

  @override
  String copy_done(Object name) {
    return 'Copied: $name';
  }

  @override
  String paste_result(Object ok) {
    return 'Paste: $ok succeeded';
  }

  @override
  String paste_skip(Object skip) {
    return ', $skip skipped';
  }

  @override
  String paste_fail(Object fail) {
    return ', $fail failed';
  }

  @override
  String get confirm_trash_title => 'Move to trash';

  @override
  String confirm_trash_msg(Object name) {
    return 'Move \"$name\" to trash?';
  }

  @override
  String compress_done(Object name) {
    return 'Compression complete: $name';
  }

  @override
  String get encrypted_suffix => ' (encrypted)';

  @override
  String selected_count(Object count) {
    return '$count selected';
  }

  @override
  String selected_n(Object count) {
    return '$count selected';
  }

  @override
  String get extract_to => 'Extract to…';

  @override
  String get archive_password_hint => 'Password (leave empty if none)';

  @override
  String get extract_failed => 'Extraction failed';

  @override
  String get extracting => 'Extracting...';

  @override
  String get start_extract => 'Start extraction';

  @override
  String get cannot_decode_audio => 'Cannot decode audio';

  @override
  String get display_settings => 'Display Settings';

  @override
  String get global_scale => 'Global Scale';

  @override
  String get items_configurable => 'items';

  @override
  String get restore_defaults => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get making_gif => 'Making...';

  @override
  String get start_making => 'Start';

  @override
  String get hex_search_hint => 'FF D8 FF E0 or hello';

  @override
  String get cannot_read_media_info => 'Cannot read media info';

  @override
  String get unknown => 'Unknown';

  @override
  String get format_convert => 'Format Convert';

  @override
  String get format_convert_desc => 'Convert video format, codec, resolution';

  @override
  String get make_gif => 'Make GIF';

  @override
  String get make_gif_desc => 'Extract clip from video to make GIF';

  @override
  String get video_compress => 'Video Compress';

  @override
  String get video_compress_desc => 'Reduce video file size';

  @override
  String get video_trim => 'Video Trim';

  @override
  String get video_trim_desc => 'Trim video clip';

  @override
  String get audio_extract => 'Audio Extract';

  @override
  String get audio_extract_desc => 'Extract audio from video';

  @override
  String get media_info => 'Media Info';

  @override
  String get media_info_desc => 'View file details';

  @override
  String get compressing => 'Compressing...';

  @override
  String get start_compress => 'Start compression';

  @override
  String get no_video_files => 'No video files found';

  @override
  String get select_video_file_or_dir => 'Select video file or directory...';

  @override
  String get select_output_dir => 'Select output directory...';

  @override
  String get hw_decode => 'HW';

  @override
  String get sw_decode => 'SW';

  @override
  String get trim_failed => 'Trim failed';

  @override
  String get trimming => 'Trimming...';

  @override
  String get start_trim => 'Start trim';

  @override
  String extract_fmt(Object fmt) {
    return 'Extract $fmt';
  }

  @override
  String gif_start_sec(Object sec) {
    return 'Start: ${sec}s';
  }

  @override
  String gif_duration_sec(Object sec) {
    return 'Duration: ${sec}s';
  }

  @override
  String gif_fps(Object fps) {
    return 'FPS: $fps';
  }

  @override
  String compress_failed_code(Object code) {
    return 'Compression failed (code: $code)';
  }

  @override
  String convert_failed_code(Object code) {
    return 'Conversion failed (code=$code)';
  }

  @override
  String convert_failed_file(Object file) {
    return 'Conversion failed: $file';
  }

  @override
  String gif_width(Object w) {
    return 'Width: $w';
  }

  @override
  String get original => 'Original';

  @override
  String trim_start(Object t) {
    return 'Start: $t';
  }

  @override
  String trim_end(Object t) {
    return 'End: $t';
  }

  @override
  String archive_file_count(Object dirs, Object files) {
    return '$files files$dirs';
  }

  @override
  String archive_dir_count(Object dirs) {
    return ', $dirs dirs';
  }

  @override
  String get archive_summary => '\$\$_fmt · \$\$_items_count items · \$\$_size';

  @override
  String media_duration(Object val) {
    return 'Duration: $val';
  }

  @override
  String get media_duration_unknown => 'Unknown';

  @override
  String media_streams(Object count) {
    return 'Streams ($count)';
  }

  @override
  String input_label(Object name) {
    return 'Input: $name';
  }

  @override
  String output_label(Object name) {
    return 'Output: $name';
  }

  @override
  String tv_lines(Object count) {
    return '$count lines';
  }

  @override
  String tv_chars(Object count) {
    return '$count chars';
  }

  @override
  String get tv_keyword_hint => 'keyword...';

  @override
  String get tv_clear => 'Clear';

  @override
  String get tv_search => 'Search';

  @override
  String get tv_search_tooltip => 'Search';

  @override
  String get editAction => 'Edit';

  @override
  String get textEditor => 'Text Editor';

  @override
  String get pdfPreview => 'PDF Preview';

  @override
  String get mdPreview => 'Markdown Preview';

  @override
  String get storageAnalysis => 'Storage Analysis';

  @override
  String get cannot_load_file => 'Cannot load file';

  @override
  String get file_info => 'File';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get appManager => 'File Manager';

  @override
  String get authorInfo => 'Author';

  @override
  String get author => 'Author';

  @override
  String get project => 'Project';

  @override
  String get license => 'License';

  @override
  String get design => 'Design';

  @override
  String get architecture => 'Architecture';

  @override
  String get architectureDesc => 'Flutter + C native layer (FFI)';

  @override
  String get iconsSpec => 'Icons';

  @override
  String get iconsSpecDesc => 'All icons use CupertinoIcons fill style';

  @override
  String get localization => 'Localization';

  @override
  String get localizationDesc => 'EN/ZH bilingual, 350+ keys';

  @override
  String get performance => 'Performance';

  @override
  String get performanceDesc => 'All I/O async, heavy ops use Isolate';

  @override
  String get platform => 'Platform';

  @override
  String get platformDesc => 'Linux, Android via FFI bridge';

  @override
  String get features => 'Features';

  @override
  String get fileOperations => 'File Operations';

  @override
  String get fileOperationsDesc =>
      'Browse, search, sort, multi-select\nCopy, move, delete (trash), rename';

  @override
  String get viewers => 'Viewers';

  @override
  String get viewersDesc =>
      'Text, Image, Video, Audio\nPDF, Markdown, Hex, Ebook, GIF';

  @override
  String get toolsDesc =>
      'File compare, duplicate cleaner, storage\nFormat convert, video compress/trim, media info';

  @override
  String get settingsDesc =>
      'Theme toggle, language switch\nFont size, UI scaling';

  @override
  String get privacyAndDisclaimer => 'Privacy & Disclaimer';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc =>
      'No personal data collected\nAll operations local, no tracking';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get disclaimerDesc =>
      'Provided as is, no warranty\nBackup important data yourself';

  @override
  String get dualPanel => 'Dual Panel';

  @override
  String get copyToOtherPanel => 'Copy to other panel';

  @override
  String get moveToOtherPanel => 'Move to other panel';

  @override
  String get copyingFiles => 'Copying';

  @override
  String get movingFiles => 'Moving';

  @override
  String get deletingFiles => 'Deleting';

  @override
  String get creating => 'Creating';

  @override
  String get renaming => 'Renaming';

  @override
  String get copyCount => 'Copying';

  @override
  String get moveCount => 'Moving';

  @override
  String get deleteCount => 'Deleting';

  @override
  String get scanningDir => 'Scanning';

  @override
  String get total => 'Total';

  @override
  String get directories => 'Directories';

  @override
  String get largestFiles => 'Largest Files';

  @override
  String get scanning => 'Scanning...';

  @override
  String get selectPathsToScan => 'Select paths to scan';

  @override
  String get supportsMultiple => 'Multiple directories supported';

  @override
  String get addPath => 'Add Path';

  @override
  String get startScan => 'Start Scan';

  @override
  String get addDirsToScan => 'Add directories to scan';

  @override
  String get noDuplicates => 'No duplicates found';

  @override
  String get scannedFiles => 'Scanned';

  @override
  String get groupsOfDuplicates => 'groups';

  @override
  String get filesTotal => 'files total';

  @override
  String get selectPath => 'Select Directory';

  @override
  String get selectHere => 'Select Here';

  @override
  String get inputFileOrDir => 'Select input file or directory';

  @override
  String get outputDir => 'Select output directory';

  @override
  String get browse => 'Browse';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get saveChanges => 'Save changes?';

  @override
  String get discard => 'Discard';

  @override
  String copyingNFiles(Object count) {
    return 'Copying $count files...';
  }

  @override
  String movingNFiles(Object count) {
    return 'Moving $count files...';
  }

  @override
  String deletingNFiles(Object count) {
    return 'Deleting $count files...';
  }

  @override
  String scannedNFiles(Object count) {
    return 'Scanned $count files';
  }

  @override
  String nFilesTotal(Object count) {
    return '$count files total';
  }

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get rescan => 'Rescan';

  @override
  String get selectTwoFilesToCompare => 'Select two files to compare';

  @override
  String get saveChangesPrompt => 'Save changes?';

  @override
  String get duplicateCleaner => 'Duplicate Cleaner';

  @override
  String get scanned => 'Scanned';

  @override
  String get fileCompare => 'File Compare';

  @override
  String get navigation => 'Navigation';

  @override
  String get fileTools => 'File Tools';

  @override
  String get copiesOf => 'copies';
}
