// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '文件管理器';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get language => '语言';

  @override
  String get switchLang => '切换语言';

  @override
  String get theme => '主题';

  @override
  String get followSystem => '跟随系统';

  @override
  String get lightMode => '亮色模式';

  @override
  String get darkMode => '暗色模式';

  @override
  String get fontSize => '字体大小';

  @override
  String get gridColumns => '网格列数';

  @override
  String get files => '文件';

  @override
  String get tags => '标签';

  @override
  String get more => '更多';

  @override
  String get search => '搜索';

  @override
  String get import => '导入';

  @override
  String get properties => '属性';

  @override
  String get delete => '删除';

  @override
  String get rename => '重命名';

  @override
  String get copy => '复制';

  @override
  String get move => '移动';

  @override
  String get select => '选择';

  @override
  String get selectAll => '全选';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get name => '名称';

  @override
  String get size => '大小';

  @override
  String get modified => '修改';

  @override
  String get type => '类型';

  @override
  String get folder => '文件夹';

  @override
  String get file => '文件';

  @override
  String get noFiles => '暂无文件';

  @override
  String get importFiles => '导入文件以开始使用';

  @override
  String get tagManage => '管理标签';

  @override
  String get tagSearch => '按标签搜索';

  @override
  String get createTag => '创建标签';

  @override
  String get editTag => '编辑标签';

  @override
  String get deleteTag => '删除标签';

  @override
  String get tagName => '标签名称';

  @override
  String get tagColor => '标签颜色';

  @override
  String get recycleBin => '回收站';

  @override
  String get emptyRecycleBin => '清空回收站';

  @override
  String get restore => '恢复';

  @override
  String version(String version) {
    return '版本: $version';
  }

  @override
  String nativeVersion(String version) {
    return '原生层: v$version';
  }

  @override
  String get prefix => '前缀';

  @override
  String get suffix => '后缀';

  @override
  String get replaceWith => '替换';

  @override
  String get sequenceNum => '序号';

  @override
  String get find => '查找';

  @override
  String get replaceWithField => '替换为';

  @override
  String get startNum => '起始序号';

  @override
  String get newFile => '新建文件';

  @override
  String get filenameHint => '文件名 (如 note.txt)';

  @override
  String get create => '创建';

  @override
  String get needFileAccess => '需要文件访问权限';

  @override
  String get needFileAccessDesc => '此应用需要「所有文件访问」权限才能正常工作，请在接下来的设置页中开启。';

  @override
  String get goAuthorize => '去授权';

  @override
  String get fileAccessDenied => '未授权文件访问权限，部分功能可能受限';

  @override
  String get binaryFileError => '此为二进制文件，不支持直接打开。';

  @override
  String get hexView => '十六进制查看';

  @override
  String get open => '打开';

  @override
  String get extract => '解压';

  @override
  String get copyAction => '复制';

  @override
  String get cutAction => '剪切';

  @override
  String get moveToTrash => '移到回收站';

  @override
  String get compress => '压缩';

  @override
  String get propertiesAction => '属性';

  @override
  String pasteFail(Object fail) {
    return ', $fail 失败';
  }

  @override
  String get fileExists => '文件已存在';

  @override
  String get fileExistsMsg => '\"\$\$name\" 已存在于当前目录';

  @override
  String get skip => '跳过';

  @override
  String get keepBoth => '保留两者';

  @override
  String get overwrite => '覆盖';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get folderName => '文件夹名';

  @override
  String get ok => '确定';

  @override
  String get moveAction => '移动';

  @override
  String get cannotOpenFile => '无法打开此文件';

  @override
  String get shareFailed => '分享失败: \$\$e';

  @override
  String get compressFilename => '压缩文件名';

  @override
  String get encryptCompress => '加密压缩';

  @override
  String get password => '密码';

  @override
  String get propType => '类型';

  @override
  String get propFolder => '文件夹';

  @override
  String get propSize => '大小';

  @override
  String get propModified => '修改';

  @override
  String get propPermission => '权限';

  @override
  String get propPath => '路径';

  @override
  String get propChecksum => '校验和';

  @override
  String get fileBrowser => '文件浏览器';

  @override
  String get multiSelectBtn => '多选按钮';

  @override
  String get fileBrowserFileSize => '文件浏览器.文件大小';

  @override
  String get calculatingHash => '正在计算哈希...';

  @override
  String get compressFormatSelect => '压缩格式选择';

  @override
  String get closeAction => '关闭';

  @override
  String get shareAction => '分享';

  @override
  String get filename => '文件名';

  @override
  String get searchFilename => '搜索文件名';

  @override
  String get searchKeyword => '输入关键词...';

  @override
  String get clearAction => '清除';

  @override
  String get searchAction => '搜索';

  @override
  String get tools => '工具';

  @override
  String get appBarTitle => 'appBar标题';

  @override
  String get homeDir => '主目录';

  @override
  String get bookmarks => '书签';

  @override
  String get bookmarkHint => '长按文件夹可添加书签';

  @override
  String get mediaToolsTitle => '媒体工具';

  @override
  String get displaySettingsTitle => '显示设置';

  @override
  String get pasteAction => '粘贴';

  @override
  String get exitMultiSelect => '退出多选';

  @override
  String get multiSelect => '多选';

  @override
  String get trashTitle => '回收站';

  @override
  String get sortByName => '按名称';

  @override
  String get sortBySize => '按大小';

  @override
  String get sortByDate => '按日期';

  @override
  String get sortByType => '按类型';

  @override
  String get hideHiddenFiles => '隐藏隐藏文件';

  @override
  String get showHiddenFiles => '显示隐藏文件';

  @override
  String get listView => '列表视图';

  @override
  String get gridView => '网格视图';

  @override
  String get removeBookmark => '移除书签';

  @override
  String get addBookmark => '添加当前目录到书签';

  @override
  String get langChinese => '中文';

  @override
  String get addrBarText => '地址栏文字';

  @override
  String get confirmBtn => '确认';

  @override
  String get editPath => '编辑路径';

  @override
  String get invertSelection => '反选';

  @override
  String get batchRename => '批量重命名';

  @override
  String get batchTrash => '批量移到回收站';

  @override
  String get deleteAction => '删除';

  @override
  String get formatConvert => '格式转换';

  @override
  String get fileSize => '文件大小';

  @override
  String get compressingStatus => '正在压缩...';

  @override
  String get restored => '已恢复: \$\$name';

  @override
  String get emptyTrashAction => '清空回收站';

  @override
  String get emptyTrashConfirm => '确定要永久删除回收站中的所有文件吗？此操作不可撤销。';

  @override
  String get emptyAction => '清空';

  @override
  String get trashEmpty => '回收站为空';

  @override
  String get restoreAction => '恢复';

  @override
  String get extractDone => '解压完成 → \$\$od';

  @override
  String get archiveViewerTitle => '压缩包查看器';

  @override
  String get archiveEmpty => '压缩包为空';

  @override
  String get extractTo => '解压到…';

  @override
  String extractFmt(Object fmt) {
    return '解压 $fmt';
  }

  @override
  String get selectExtractTarget => '选择解压目标';

  @override
  String get selectAction => '选择';

  @override
  String get enterPassword => '输入密码';

  @override
  String get archivePasswordHint => '密码（无密码留空）';

  @override
  String get audioExtractTitle => '音频提取';

  @override
  String get videoFile => '视频文件';

  @override
  String get outputPathHint => '输出路径（不含扩展名）';

  @override
  String get outputFormat => '输出格式';

  @override
  String get progress => '进度: \$\$_current / \$\$_total';

  @override
  String get extractComplete => '提取完成!';

  @override
  String get extractingStatus => '提取中...';

  @override
  String get startExtract => '开始提取';

  @override
  String get audioPlayerTitle => '音频播放器';

  @override
  String get swipeHint => '← 左右滑动切换 →';

  @override
  String get pcmParams => 'PCM 格式参数';

  @override
  String get sampleRate => '采样率 (Hz)';

  @override
  String get channels => '声道数';

  @override
  String get bitDepth => '位深度 (bit)';

  @override
  String get byteOrder => '字节序';

  @override
  String get littleEndian => '小端 (Little-Endian)';

  @override
  String get bigEndian => '大端 (Big-Endian)';

  @override
  String get globalScale => '全局缩放';

  @override
  String get itemsConfigurable => '项可配置';

  @override
  String get resetDefaults => '恢复默认';

  @override
  String get applyBtn => '应用';

  @override
  String get makeGif => '制作 GIF';

  @override
  String gifStartSec(Object sec) {
    return '起始秒: $sec';
  }

  @override
  String gifDurationSec(Object sec) {
    return '持续秒: $sec';
  }

  @override
  String gifFps(Object fps) {
    return '帧率: $fps';
  }

  @override
  String get gifFrame => '帧: \$\$_current / \$\$_total';

  @override
  String get gifMakerTitle => 'GIF制作';

  @override
  String get gifComplete => 'GIF 制作完成!';

  @override
  String get gifMaking => '制作中...';

  @override
  String get startMaking => '开始制作';

  @override
  String hexBytesPerLine(Object n) {
    return '每行 $n 字节';
  }

  @override
  String get hexSearch => '搜索 (HEX 或 ASCII)';

  @override
  String get hexSearchHint => 'FF D8 FF E0 或 hello';

  @override
  String get hexViewerMultiSelect => '十六进制查看器.多选按钮';

  @override
  String get hexViewerText12 => '十六进制查看器.文字12px';

  @override
  String get cannotReadMediaInfo => '无法读取媒体信息';

  @override
  String get mediaInfoTitle => '媒体信息';

  @override
  String get mediaFile => '媒体文件';

  @override
  String get viewInfo => '查看信息';

  @override
  String get formatLabel => '格式: \$\$format';

  @override
  String get toolTitle => '工具标题';

  @override
  String get formatConvertDesc => '转换视频格式、编码、分辨率';

  @override
  String get makeGifDesc => '从视频中提取片段制作 GIF';

  @override
  String get videoCompressTitle => '视频压缩';

  @override
  String get videoCompressDesc => '减小视频文件体积';

  @override
  String get videoTrimTitle => '视频裁剪';

  @override
  String get videoTrimDesc => '裁剪视频片段';

  @override
  String get audioExtractDesc => '从视频中提取音频';

  @override
  String get viewFileDetails => '查看文件详细信息';

  @override
  String get textViewerTitle => '文本查看器';

  @override
  String get textViewerFileSize => '文本查看器.文件大小';

  @override
  String get textViewerMultiSelect => '文本查看器.多选按钮';

  @override
  String get compressFailed => '压缩失败 (code: \$\$rc)';

  @override
  String get targetBitrate => '目标码率';

  @override
  String get bitrate500 => '500 kbps (高压缩)';

  @override
  String get bitrate1000 => '1000 kbps (推荐)';

  @override
  String get bitrate4000 => '4000 kbps (高质量)';

  @override
  String get maxWidth => '最大宽度';

  @override
  String get resolution720 => '720p (推荐)';

  @override
  String get keepOriginal => '保持原始';

  @override
  String get compressComplete => '压缩完成!';

  @override
  String get compressingMsg => '压缩中...';

  @override
  String get startCompress => '开始压缩';

  @override
  String get convertFailed => '转换失败 (code=\$\$rc)';

  @override
  String get videoFormatConvert => '视频格式转换';

  @override
  String get convertDialogTitle => '格式转换弹窗';

  @override
  String get codecFormat => '编码格式';

  @override
  String get containerFormat => '容器格式';

  @override
  String get bitrateKbps => '码率 (kbps)';

  @override
  String get autoBitrate => '自动';

  @override
  String get resolutionScale => '分辨率缩放';

  @override
  String get convertFrame => '\$\$_current / \$\$_total 帧';

  @override
  String get convertDialogDone => '格式转换弹窗.转换完成';

  @override
  String get convertComplete => '转换完成';

  @override
  String get openFolder => '打开文件夹';

  @override
  String get startConvert => '开始转换';

  @override
  String get noVideoFound => '没有找到视频文件';

  @override
  String get selectVideoHint => '选择视频文件或目录...';

  @override
  String get browseBtn => '浏览';

  @override
  String get convertAllInDir => '将转换目录下所有视频文件';

  @override
  String get inputFileDir => '输入文件/目录';

  @override
  String get selectOutputDir => '选择输出目录...';

  @override
  String get outputSettings => '输出设置';

  @override
  String get selectThisDir => '选择此目录';

  @override
  String get hwNotSupported => '硬解不支持，已切换到软解';

  @override
  String get hwDecode => '硬解';

  @override
  String get swDecode => '软解';

  @override
  String get trimFailed => '裁剪失败';

  @override
  String get trimComplete => '裁剪完成!';

  @override
  String get trimmingMsg => '裁剪中...';

  @override
  String get startTrim => '开始裁剪';

  @override
  String get batch_rename_prefix => '前缀';

  @override
  String get batch_rename_suffix => '后缀';

  @override
  String get batch_rename_replace => '替换为';

  @override
  String get batch_rename_start_num => '起始序号';

  @override
  String get new_file_hint => '文件名 (如 note.txt)';

  @override
  String get new_folder_hint => '文件夹名';

  @override
  String get created => '创建';

  @override
  String get permission => '权限';

  @override
  String get path => '路径';

  @override
  String get search_hint => '输入关键词...';

  @override
  String get paste_tooltip => '粘贴';

  @override
  String get exit_multi_select => '退出多选';

  @override
  String get multi_select => '多选';

  @override
  String get hide_hidden => '隐藏隐藏文件';

  @override
  String get show_hidden => '显示隐藏文件';

  @override
  String get list_view => '列表视图';

  @override
  String get grid_view => '网格视图';

  @override
  String get remove_bookmark => '移除书签';

  @override
  String get add_bookmark => '添加当前目录到书签';

  @override
  String get chinese => '中文';

  @override
  String get light_mode => '亮色模式';

  @override
  String get dark_mode => '暗色模式';

  @override
  String get confirm_tooltip => '确认';

  @override
  String get edit_path_tooltip => '编辑路径';

  @override
  String get batch_rename_tooltip => '批量重命名';

  @override
  String get batch_trash_tooltip => '批量移到回收站';

  @override
  String get empty_trash_tooltip => '清空回收站';

  @override
  String get restore_tooltip => '恢复';

  @override
  String batch_rename_title(Object count) {
    return '批量重命名 ($count 项)';
  }

  @override
  String cut_done(Object name) {
    return '已剪切: $name';
  }

  @override
  String copy_done(Object name) {
    return '已复制: $name';
  }

  @override
  String paste_result(Object ok) {
    return '粘贴完成: $ok 成功';
  }

  @override
  String paste_skip(Object skip) {
    return ', $skip 跳过';
  }

  @override
  String paste_fail(Object fail) {
    return ', $fail 失败';
  }

  @override
  String get confirm_trash_title => '移到回收站';

  @override
  String confirm_trash_msg(Object name) {
    return '确定要将 \"$name\" 移到回收站吗？';
  }

  @override
  String compress_done(Object name) {
    return '压缩完成: $name';
  }

  @override
  String get encrypted_suffix => ' (已加密)';

  @override
  String selected_count(Object count) {
    return '已选 $count 项';
  }

  @override
  String selected_n(Object count) {
    return '$count 已选';
  }

  @override
  String get extract_to => '解压到…';

  @override
  String get archive_password_hint => '密码（无密码留空）';

  @override
  String get extract_failed => '提取失败';

  @override
  String get extracting => '提取中...';

  @override
  String get start_extract => '开始提取';

  @override
  String get cannot_decode_audio => '无法解码音频';

  @override
  String get display_settings => '显示设置';

  @override
  String get global_scale => '全局缩放';

  @override
  String get items_configurable => '项可配置';

  @override
  String get restore_defaults => '恢复默认';

  @override
  String get apply => '应用';

  @override
  String get making_gif => '制作中...';

  @override
  String get start_making => '开始制作';

  @override
  String get hex_search_hint => 'FF D8 FF E0 或 hello';

  @override
  String get cannot_read_media_info => '无法读取媒体信息';

  @override
  String get unknown => '未知';

  @override
  String get format_convert => '格式转换';

  @override
  String get format_convert_desc => '转换视频格式、编码、分辨率';

  @override
  String get make_gif => '制作 GIF';

  @override
  String get make_gif_desc => '从视频中提取片段制作 GIF';

  @override
  String get video_compress => '视频压缩';

  @override
  String get video_compress_desc => '减小视频文件体积';

  @override
  String get video_trim => '视频裁剪';

  @override
  String get video_trim_desc => '裁剪视频片段';

  @override
  String get audio_extract => '音频提取';

  @override
  String get audio_extract_desc => '从视频中提取音频';

  @override
  String get media_info => '媒体信息';

  @override
  String get media_info_desc => '查看文件详细信息';

  @override
  String get compressing => '压缩中...';

  @override
  String get start_compress => '开始压缩';

  @override
  String get no_video_files => '没有找到视频文件';

  @override
  String get select_video_file_or_dir => '选择视频文件或目录...';

  @override
  String get select_output_dir => '选择输出目录...';

  @override
  String get hw_decode => '硬解';

  @override
  String get sw_decode => '软解';

  @override
  String get trim_failed => '裁剪失败';

  @override
  String get trimming => '裁剪中...';

  @override
  String get start_trim => '开始裁剪';

  @override
  String extract_fmt(Object fmt) {
    return '解压 $fmt';
  }

  @override
  String gif_start_sec(Object sec) {
    return '起始秒: $sec';
  }

  @override
  String gif_duration_sec(Object sec) {
    return '持续秒: $sec';
  }

  @override
  String gif_fps(Object fps) {
    return '帧率: $fps';
  }

  @override
  String compress_failed_code(Object code) {
    return '压缩失败 (code: $code)';
  }

  @override
  String convert_failed_code(Object code) {
    return '转换失败 (code=$code)';
  }

  @override
  String convert_failed_file(Object file) {
    return '转换失败: $file';
  }

  @override
  String gif_width(Object w) {
    return '宽度: $w';
  }

  @override
  String get original => '原始';

  @override
  String trim_start(Object t) {
    return '开始: $t';
  }

  @override
  String trim_end(Object t) {
    return '结束: $t';
  }

  @override
  String archive_file_count(Object dirs, Object files) {
    return '$files 个文件$dirs';
  }

  @override
  String archive_dir_count(Object dirs) {
    return ', $dirs 个目录';
  }

  @override
  String get archive_summary => '\$\$_fmt · \$\$_items_count 项 · \$\$_size';

  @override
  String media_duration(Object val) {
    return '时长: $val';
  }

  @override
  String get media_duration_unknown => '未知';

  @override
  String media_streams(Object count) {
    return '流信息 ($count)';
  }

  @override
  String input_label(Object name) {
    return '输入: $name';
  }

  @override
  String output_label(Object name) {
    return '输出: $name';
  }

  @override
  String tv_lines(Object count) {
    return '$count 行';
  }

  @override
  String tv_chars(Object count) {
    return '$count 字符';
  }

  @override
  String get tv_keyword_hint => '关键词...';

  @override
  String get tv_clear => '清除';

  @override
  String get tv_search => '搜索';

  @override
  String get tv_search_tooltip => '搜索';

  @override
  String get editAction => '编辑';

  @override
  String get textEditor => '文本编辑器';

  @override
  String get pdfPreview => 'PDF 预览';

  @override
  String get mdPreview => 'Markdown 预览';

  @override
  String get storageAnalysis => '存储分析';

  @override
  String get cannot_load_file => '无法加载文件';

  @override
  String get file_info => '文件';

  @override
  String get languageSettings => '语言设置';

  @override
  String get appManager => '文件管理器';

  @override
  String get authorInfo => '作者信息';

  @override
  String get author => '作者';

  @override
  String get project => '项目';

  @override
  String get license => '开源协议';

  @override
  String get design => '工程设计';

  @override
  String get architecture => '架构';

  @override
  String get architectureDesc => 'Flutter + C 原生层（FFI）';

  @override
  String get iconsSpec => '图标规范';

  @override
  String get iconsSpecDesc => '所有图标统一使用填充样式';

  @override
  String get localization => '国际化';

  @override
  String get localizationDesc => '中英文双语支持，350+ 翻译键';

  @override
  String get performance => '性能';

  @override
  String get performanceDesc => '所有 I/O 异步执行，重操作使用 Isolate';

  @override
  String get platform => '平台';

  @override
  String get platformDesc => 'Linux, Android，原生层通过 FFI 桥接';

  @override
  String get features => '功能列表';

  @override
  String get fileOperations => '文件操作';

  @override
  String get fileOperationsDesc => '浏览、搜索、排序、多选\n复制、移动、删除（回收站）、重命名';

  @override
  String get viewers => '查看器';

  @override
  String get viewersDesc => '文本查看/编辑、图片、视频、音频\nPDF、Markdown、Hex、Ebook、GIF';

  @override
  String get toolsDesc => '文件对比、重复文件清理、存储分析\n格式转换、视频压缩/裁剪、媒体信息';

  @override
  String get settingsDesc => '主题切换、语言切换\n字体大小、UI 缩放';

  @override
  String get privacyAndDisclaimer => '隐私与免责';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicyDesc => '不收集任何个人数据\n所有操作均在本地设备上运行';

  @override
  String get disclaimer => '免责声明';

  @override
  String get disclaimerDesc => '按原样提供，不作任何保证\n用户应自行备份重要数据';

  @override
  String get dualPanel => '双面板';

  @override
  String get copyToOtherPanel => '复制到对面';

  @override
  String get moveToOtherPanel => '移动到对面';

  @override
  String get copyingFiles => '复制中';

  @override
  String get movingFiles => '移动中';

  @override
  String get deletingFiles => '删除中';

  @override
  String get creating => '创建中';

  @override
  String get renaming => '重命名中';

  @override
  String get copyCount => '复制';

  @override
  String get moveCount => '移动';

  @override
  String get deleteCount => '删除';

  @override
  String get scanningDir => '扫描目录';

  @override
  String get total => '总计';

  @override
  String get directories => '目录';

  @override
  String get largestFiles => '最大文件';

  @override
  String get scanning => '扫描中...';

  @override
  String get selectPathsToScan => '选择要扫描的路径';

  @override
  String get supportsMultiple => '支持选择多个目录一起检查';

  @override
  String get addPath => '添加路径';

  @override
  String get startScan => '开始扫描';

  @override
  String get addDirsToScan => '请添加要扫描的目录';

  @override
  String get noDuplicates => '未发现重复文件';

  @override
  String get scannedFiles => '已扫描';

  @override
  String get groupsOfDuplicates => '组重复';

  @override
  String get filesTotal => '个文件';

  @override
  String get selectPath => '选择目录';

  @override
  String get selectHere => '选择此处';

  @override
  String get inputFileOrDir => '选择输入文件或目录';

  @override
  String get outputDir => '选择输出目录';

  @override
  String get browse => '浏览';

  @override
  String get unsavedChanges => '未保存的更改';

  @override
  String get saveChanges => '是否保存更改？';

  @override
  String get discard => '不保存';

  @override
  String copyingNFiles(Object count) {
    return '复制 $count 个文件...';
  }

  @override
  String movingNFiles(Object count) {
    return '移动 $count 个文件...';
  }

  @override
  String deletingNFiles(Object count) {
    return '删除 $count 个文件...';
  }

  @override
  String scannedNFiles(Object count) {
    return '已扫描 $count 个文件';
  }

  @override
  String nFilesTotal(Object count) {
    return '共 $count 个文件';
  }

  @override
  String get deleteSelected => '删除选中';

  @override
  String get rescan => '重新扫描';

  @override
  String get selectTwoFilesToCompare => '请选择两个文件进行对比';

  @override
  String get saveChangesPrompt => '是否保存更改？';

  @override
  String get duplicateCleaner => '重复文件清理';

  @override
  String get scanned => '已扫描';

  @override
  String get fileCompare => '文件对比';

  @override
  String get navigation => '导航栏';

  @override
  String get fileTools => '文件工具';

  @override
  String get copiesOf => '个副本';
}
