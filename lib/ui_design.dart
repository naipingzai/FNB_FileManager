import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

final ValueNotifier<int> uiVersion = ValueNotifier<int>(0);

class UiItem {
  final String pe, pz, ce, cv, desc;
  final double min, max, defVal;
  const UiItem(this.pe, this.pz, this.ce, this.cv, this.desc, {this.min=6, this.max=40, this.defVal=14});
  String key(bool zh) => zh ? (pz+"."+cv) : (pe+"."+ce);
}

class Ui {
  Ui._();

  static const all = [
    UiItem("File Browser","文件浏览器","Multi-Select","多选","file_browser.dart:504", min:0, max:32, defVal:14),
    UiItem("File Browser","文件浏览器","Compression Format","压缩格式","file_browser.dart:508", min:0, max:32, defVal:14),
    UiItem("File Browser","文件浏览器","File Name","文件名","file_browser.dart:525", min:0, max:32, defVal:14),
    UiItem("File Browser","文件浏览器","App Bar Title","标题栏","file_browser.dart:576", min:0, max:32, defVal:14),
    UiItem("File Browser","文件浏览器","Address Bar","地址栏","file_browser.dart:639", min:0, max:32, defVal:14),
    UiItem("File Browser","文件浏览器","File Size","文件大小","file_browser.dart:771", min:0, max:32, defVal:14),
    UiItem("Archive Viewer","压缩包查看器","caption","说明文字","archive_viewer.dart:70", min:0, max:32, defVal:14),
    UiItem("Archive Viewer","压缩包查看器","Address Bar","地址栏","archive_viewer.dart:72", min:0, max:32, defVal:14),
    UiItem("Audio Extract","音频提取","Address Bar","地址栏","audio_extract_page.dart:59", min:0, max:32, defVal:14),
    UiItem("Audio Player","音频播放器","File Name","文件名","audio_player.dart:217", min:0, max:32, defVal:14),
    UiItem("Audio Player","音频播放器","caption","说明文字","audio_player.dart:222", min:0, max:32, defVal:14),
    UiItem("GIF Maker","GIF制作","Address Bar","地址栏","gif_page.dart:63", min:0, max:32, defVal:14),
    UiItem("Media Info","媒体信息","Address Bar","地址栏","media_info_page.dart:40", min:0, max:32, defVal:14),
    UiItem("Media Info","媒体信息","Tool Title","工具标题","media_info_page.dart:51", min:0, max:32, defVal:14),
    UiItem("Text Viewer","文本查看器","caption","说明文字","text_viewer.dart:112", min:0, max:32, defVal:14),
    UiItem("Video Compress","视频压缩","Address Bar","地址栏","video_compress_page.dart:70", min:0, max:32, defVal:14),
    UiItem("Convert Dialog","格式转换弹窗","caption","说明文字","video_convert_dialog.dart:68", min:0, max:32, defVal:14),
    UiItem("Format Convert","格式转换","caption","说明文字","video_convert_page.dart:132", min:0, max:32, defVal:14),
    UiItem("Format Convert","格式转换","Address Bar","地址栏","video_convert_page.dart:162", min:0, max:32, defVal:14),
    UiItem("Video Trim","视频裁剪","Address Bar","地址栏","video_trim_page.dart:60", min:0, max:32, defVal:14),
    ];

  static final Map<String,double> _values = {};
  static Map<String,double> get values => Map.of(_values);
  static double val(String key) {
    if (_values.containsKey(key)) return _values[key]!;
    for (var i in all) { if (i.key(false) == key || i.key(true) == key) return i.defVal; }
    return 14;
  }
  static void setVal(String key, double v) { _values[key]=v; _save(); uiVersion.value++; }
  static void apply(Map<String,double> t, String p) { _values.clear(); _values.addAll(t); _save(); uiVersion.value++; }
  static void resetAll() { _values.clear(); _save(); uiVersion.value++; }
  static void resetPage(String pg) { for(var i in all){if(i.pe==pg||i.pz==pg){_values.remove(i.key(false));_values.remove(i.key(true));}} _save(); uiVersion.value++; }
  static Future<void> load() async { final sp=await SharedPreferences.getInstance(); for(var i in all){final v=sp.getDouble("ui_"+i.key(false));if(v!=null)_values[i.key(false)]=v;} }
  static void _save() { SharedPreferences.getInstance().then((sp){for(var i in all){if(_values.containsKey(i.key(false)))sp.setDouble("ui_"+i.key(false),_values[i.key(false)]!);}}); }
}

class T {
  T._();
  static TextStyle style(String pe, String pn, {FontWeight? w, Color? c, String? ff}) {
    TextStyle s = TextStyle(fontSize: Ui.val(pe+'.'+pn), fontWeight: w);
    if (c!=null) s=s.copyWith(color:c); if (ff!=null) s=s.copyWith(fontFamily:ff);
    return s;
  }
}

class UiScope extends StatelessWidget {
  final Widget child;
  const UiScope({super.key,required this.child});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(valueListenable:uiVersion,
      builder:(ctx,ver,_)=>KeyedSubtree(key:ValueKey(ver),child:child));
  }
}
