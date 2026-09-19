/// native.dart - FFI 桥接层（Dart 只做内存管理，零业务逻辑）
library;

import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'native_bindings_generated.dart' as bindings;
import '../l10n/l10n.dart';

DynamicLibrary _loadLib() {
  if (Platform.isAndroid) return DynamicLibrary.open('libfn_file_manager.so');
  return DynamicLibrary.process();
}

final _lib = _loadLib();
final _api = bindings.FnbBindings(_lib);
final Map<Pointer<Void>, Pointer<Uint8>> _videoBufs = {};

void _freeErr(Pointer<Char> e) { calloc.free(e); }
Pointer<Char> _allocErr() => calloc<Char>(256);

String? _cStr(Pointer<Char> r) {
  if (r == nullptr) return null;
  final s = r.cast<Utf8>().toDartString();
  _api.bridge_free_string(r);
  return s;
}

/// 释放 calloc 分配的本地缓冲区，返回字符串
String? _cLocal(Pointer<Char> r) {
  if (r == nullptr) return null;
  final s = r.cast<Utf8>().toDartString();
  calloc.free(r);
  return s;
}

// ── 文件系统操作 ──

class NativeFs {
  static Future<List<FileEntry>> listDir(String path, {bool showHidden = false}) async {
    final p = path.toNativeUtf8();
    final r = _api.fs_list_dir(p.cast(), showHidden ? 1 : 0);
    calloc.free(p);
    if (r == nullptr) return [];
    final json = _cStr(r);
    if (json == null) return [];
    return FileEntry.parseList(json);
  }

  static Future<List<String>> listRoot() async {
    if (Platform.isAndroid) {
      for (final p in ['/storage/emulated/0', '/sdcard']) {
        if (await Directory(p).exists()) return [p];
      }
      return [];
    }
    final home = Platform.environment['HOME'] ?? '/home';
    return [home, '/tmp', '/'];
  }

  static (int, String) _callCopyMove(String src, String dst, int Function(Pointer<Char>, Pointer<Char>, Pointer<Char>, int) fn) {
    final s = src.toNativeUtf8(); final d = dst.toNativeUtf8(); final e = _allocErr();
    final r = fn(s.cast(), d.cast(), e.cast(), 256);
    final msg = _cLocal(e); calloc.free(s); calloc.free(d);
    return (r, msg ?? '');
  }

  static (int, String) _callSimple(String path, int Function(Pointer<Char>, Pointer<Char>, int) fn) {
    final p = path.toNativeUtf8(); final e = _allocErr();
    final r = fn(p.cast(), e.cast(), 256);
    final msg = _cLocal(e); calloc.free(p);
    return (r, msg ?? '');
  }

  static (int, String) copy(String src, String dst) => _callCopyMove(src, dst, _api.fs_copy);
  static (int, String) move(String src, String dst) => _callCopyMove(src, dst, _api.fs_move);
  static (int, String) delete(String path) => _callSimple(path, _api.fs_delete);
  static (int, String) mkdir(String path) => _callSimple(path, _api.fs_mkdir);

  static (int, String) rename(String oldPath, String newPath) {
    final o = oldPath.toNativeUtf8(); final n = newPath.toNativeUtf8(); final e = _allocErr();
    final r = _api.fs_rename(o.cast(), n.cast(), e.cast(), 256);
    final msg = _cLocal(e); calloc.free(o); calloc.free(n);
    return (r, msg ?? '');
  }

  static Map<String, dynamic>? properties(String path) {
    final p = path.toNativeUtf8();
    final r = _api.fs_properties(p.cast());
    calloc.free(p);
    final json = _cStr(r);
    if (json == null) return null;
    return _parseJson(json);
  }

  static (int, String) trash(String path) => _callSimple(path, _api.fs_trash);
  static (int, String) trashRestore(String name) => _callSimple(name, _api.fs_trash_restore);
  static int trashEmpty() { final e = _allocErr(); final r = _api.fs_trash_empty(e.cast(), 256); _freeErr(e); return r; }
  static List<FileEntry> trashList() { final r = _api.fs_trash_list(); final j = _cStr(r); if (j == null) return []; return FileEntry.parseList(j); }

  // ── 新增操作 ──
  static (int, String) deletePermanent(String path) => _callSimple(path, _api.fs_delete_permanent);
  static (int, String) createFile(String path) => _callSimple(path, _api.fs_create_file);
  static int dirSize(String path) { final p = path.toNativeUtf8(); final r = _api.fs_dir_size(p.cast()); calloc.free(p); return r; }

  static (int, String) chmod(String path, int mode) {
    final p = path.toNativeUtf8(); final e = _allocErr();
    final r = _api.fs_chmod(p.cast(), mode, e.cast(), 256);
    final msg = _cLocal(e); calloc.free(p);
    return (r, msg ?? '');
  }

  static String? fileHash(String path, {int algo = 0}) {
    final p = path.toNativeUtf8(); final r = _api.fs_file_hash(p.cast(), algo); calloc.free(p);
    return _cStr(r);
  }

  static (int, String) batchRename(String dir, String json) {
    final d = dir.toNativeUtf8(); final j = json.toNativeUtf8(); final e = _allocErr();
    final r = _api.fs_batch_rename(d.cast(), j.cast(), e.cast(), 256);
    final msg = _cLocal(e); calloc.free(d); calloc.free(j);
    return (r, msg ?? '');
  }
}

// ── 视频解码（C层FFmpeg软解码） ──

Pointer<Void>? hwDecodeInit(List<int> data) {
  final ptr = calloc<Uint8>(data.length);
  for (var i = 0; i < data.length; i++) ptr[i] = data[i];
  final h = _api.hwDecodeInit(ptr, data.length);
  if (h == nullptr) { calloc.free(ptr); return null; }
  _videoBufs[h] = ptr;
  return h;
}

(Uint8List, int, int, double)? hwDecodeFrame(Pointer<Void> h, Pointer<Uint8> buf, int bufCap) {
  final wP = calloc<Int>(); final hP = calloc<Int>(); final tP = calloc<Double>();
  final ret = _api.hwDecodeFrame(h, buf, bufCap, wP, hP, tP);
  if (ret == 1) {
    final w = wP.value, ht = hP.value, ts = tP.value, need = w * ht * 4;
    final copy = Uint8List(need)..setRange(0, need, buf.asTypedList(need));
    calloc.free(wP); calloc.free(hP); calloc.free(tP);
    return (copy, w, ht, ts);
  }
  calloc.free(wP); calloc.free(hP); calloc.free(tP);
  return null;
}

bool hwDecodeSeek(Pointer<Void> h, double ts) => _api.hwDecodeSeek(h, ts) == 1;

/// 缩放解码：指定最大宽度，保持宽高比，提升软解性能
(Uint8List, int, int, double)? hwDecodeFrameScaled(Pointer<Void> h, Pointer<Uint8> buf, int bufCap, int maxWidth) {
  final wP = calloc<Int>(); final hP = calloc<Int>(); final tP = calloc<Double>();
  final ret = _api.videoNextFrameScaled(h, buf, bufCap, maxWidth, wP, hP, tP);
  if (ret == 1) {
    final w = wP.value, ht = hP.value, ts = tP.value, need = w * ht * 4;
    final copy = Uint8List(need)..setRange(0, need, buf.asTypedList(need));
    calloc.free(wP); calloc.free(hP); calloc.free(tP);
    return (copy, w, ht, ts);
  }
  calloc.free(wP); calloc.free(hP); calloc.free(tP);
  return null;
}

void hwDecodeClose(Pointer<Void> h) {
  _api.hwDecodeClose(h);
  final buf = _videoBufs.remove(h);
  if (buf != null) calloc.free(buf);
}

// ── 旧接口兼容 ──

Pointer<Void>? videoOpen(List<int> data) {
  final ptr = calloc<Uint8>(data.length);
  for (var i = 0; i < data.length; i++) ptr[i] = data[i];
  final h = _api.video_open(ptr, data.length);
  if (h == nullptr) { calloc.free(ptr); return null; }
  _videoBufs[h] = ptr;
  return h;
}

String? videoGetInfo(Pointer<Void> h) => _cStr(_api.video_get_info(h));
String? videoAudioInfo(Pointer<Void> h) => _cStr(_api.video_audio_info(h));
bool videoSeek(Pointer<Void> h, double ts) => _api.video_seek(h, ts) == 1;

(Uint8List, int, int, double)? videoNextFrame(Pointer<Void> h, Pointer<Uint8> buf, int bufCap) {
  final wP = calloc<Int>(); final hP = calloc<Int>(); final tP = calloc<Double>();
  final ret = _api.video_next_frame(h, buf, bufCap, wP, hP, tP);
  if (ret == 1) {
    final w = wP.value, ht = hP.value, ts = tP.value, need = w * ht * 4;
    final copy = Uint8List(need)..setRange(0, need, buf.asTypedList(need));
    calloc.free(wP); calloc.free(hP); calloc.free(tP);
    return (copy, w, ht, ts);
  }
  calloc.free(wP); calloc.free(hP); calloc.free(tP);
  return null;
}

void videoClose(Pointer<Void> h) {
  _api.video_close(h);
  final buf = _videoBufs.remove(h);
  if (buf != null) calloc.free(buf);
}

// ── 视频格式转换 ──

class NativeVideoConvert {
  static int convert(String input, String outputPath, {String codec = 'h264', String container = 'mp4', int bitrate = 0, int maxWidth = 0}) {
    final inp = input.toNativeUtf8();
    final out = outputPath.toNativeUtf8();
    final cd = codec.toNativeUtf8();
    final ct = container.toNativeUtf8();
    final err = calloc<Char>(256);
    final r = _api.videoConvert(inp.cast(), out.cast(), cd.cast(), ct.cast(), bitrate, maxWidth, err.cast(), 256);
    final msg = _cLocal(err);
    calloc.free(inp); calloc.free(out); calloc.free(cd); calloc.free(ct);
    return r;
  }

  static (int, int) getProgress() => _api.videoConvertProgress();

  static void cancel() => _api.videoConvertCancel();
}

/// 从视频解码音频 PCM，返回 (success, writtenBytes)
(int, int) videoAudioDecode(Pointer<Void> h, Pointer<Uint8> buf, int cap) {
  final wP = calloc<Int>();
  final ret = _api.video_audio_decode(h, buf, cap, wP);
  final written = wP.value;
  calloc.free(wP);
  return (ret, written);
}

/// 一次性解码全部音频，返回 (pcm pointer, size, sampleRate, channels)
(Pointer<Uint8>, int, int, int)? videoAudioDecodeAll(Pointer<Void> h) {
  return _api.videoAudioDecodeAll(h);
}

// ── 音频 ──

String? decodeAudio(List<int> data) {
  final ptr = calloc<Uint8>(data.length);
  for (var i = 0; i < data.length; i++) ptr[i] = data[i];
  final r = _api.audio_decode(ptr, data.length);
  calloc.free(ptr);
  return _cStr(r);
}

Pointer<Void>? audioOpen(int sr, int ch, int bits) {
  final h = _api.audio_output_open(sr, ch, bits);
  return h == nullptr ? null : h;
}

int audioWrite(Pointer<Void> h, List<int> pcm) {
  final ptr = calloc<Uint8>(pcm.length);
  for (var i = 0; i < pcm.length; i++) ptr[i] = pcm[i];
  final n = _api.audio_output_write(h, ptr, pcm.length);
  calloc.free(ptr);
  return n;
}

void audioStop(Pointer<Void> h) => _api.audio_output_stop(h);
void audioPlayThread(Pointer<Void> h, Pointer<Uint8> pcm, int size, int startOffset) => _api.audio_output_play_thread(h, pcm, size, startOffset);
void audioClose(Pointer<Void> h) => _api.audio_output_close(h);

// ── 电子书 ──

String? epubExtractText(String path) => _cStr(_api.epub_extract_text(path.toNativeUtf8().cast()));
String? epubListFiles(String path) => _cStr(_api.epub_list_files(path.toNativeUtf8().cast()));

// ── 缩略图 ──

String? makeVideoThumbnail(String path, int maxSize) => _cStr(_api.video_thumbnail(path.toNativeUtf8().cast(), maxSize));

// ── 压缩包 ──

class NativeArchive {
  static String? list(String path) => _cStr(_api.archive_list(path.toNativeUtf8().cast()));

  static int extract(String zipPath, String outDir, {String? password}) {
    final z = zipPath.toNativeUtf8(); final o = outDir.toNativeUtf8(); final e = _allocErr();
    final p = (password != null && password.isNotEmpty) ? password.toNativeUtf8() : nullptr;
    final r = _api.archive_extract_progress(z.cast(), o.cast(), p.cast(), e.cast(), 256);
    calloc.free(z); calloc.free(o); _freeErr(e);
    if (p != nullptr) calloc.free(p);
    return r;
  }

  static int create(String srcPath, String zipPath) {
    final s = srcPath.toNativeUtf8(); final z = zipPath.toNativeUtf8(); final e = _allocErr();
    final r = _api.archive_create_progress(s.cast(), z.cast(), e.cast(), 256);
    calloc.free(s); calloc.free(z); _freeErr(e);
    return r;
  }

  static int createEx(String srcPath, String outPath, {int level = -1}) {
    final s = srcPath.toNativeUtf8(); final o = outPath.toNativeUtf8(); final e = _allocErr();
    final r = _api.archiveCreateEx(s.cast(), o.cast(), level, e.cast(), 256);
    calloc.free(s); calloc.free(o); _freeErr(e);
    return r;
  }

  static int create7z(String srcPath, String outPath, {String? password, int level = 5}) {
    final s = srcPath.toNativeUtf8(); final o = outPath.toNativeUtf8(); final e = _allocErr();
    final p = (password != null && password.isNotEmpty) ? password.toNativeUtf8() : nullptr;
    final r = _api.archiveCreate7z(s.cast(), o.cast(), p.cast(), level, e.cast(), 256);
    calloc.free(s); calloc.free(o); _freeErr(e);
    if (p != nullptr) calloc.free(p);
    return r;
  }

  static int cancelExtract() => _api.archiveCancelExtract();

  static ({int current, int total, String file, bool running}) getProgress() {
    final cP = calloc<Int>(); final tP = calloc<Int>(); final fP = calloc<Char>(1024);
    final running = _api.archive_get_progress(cP, tP, fP, 1024);
    final c = cP.value; final t = tP.value; final f = _cStr(fP);
    calloc.free(cP); calloc.free(tP);
    return (current: c, total: t, file: f ?? '', running: running != 0);
  }

  static int fileCount(String path) => _api.archive_file_count(path.toNativeUtf8().cast());

  static Map<String, dynamic>? supportedFormats() {
    final r = _api.archiveSupportedFormats();
    final json = _cStr(r);
    if (json == null) return null;
    return _parseJson(json);
  }
}

// ── GPU 检测（C层逻辑，Dart只做FFI调用和JSON解析） ──

class NativeGpu {
  /// 解析推荐的 hwdec 模式（"auto-safe" 或 "no"）
  static String getHwdecRecommendation() {
    final r = _api.gpuDetectHwDecode();
    final json = _cStr(r);
    if (json == null) return 'no';
    final map = _parseJson(json);
    return (map['recommendation'] as String?) ?? 'no';
  }

  /// GPU 类型名称
  static String getGpuType() {
    final r = _api.gpuDetectHwDecode();
    final json = _cStr(r);
    if (json == null) return 'unknown';
    final map = _parseJson(json);
    return (map['gpu'] as String?) ?? 'unknown';
  }

  /// 是否有硬件解码能力
  static bool hasHwDecode() {
    final r = _api.gpuDetectHwDecode();
    final json = _cStr(r);
    if (json == null) return false;
    final map = _parseJson(json);
    return map['hw_decode'] == true;
  }
}

// ── 媒体工具 ──

class NativeMediaTools {
  static (int, int) getProgress() => _api.videoConvertProgress();
  static void cancel() => _api.videoConvertCancel();

  static (int, String) gif(String input, String output,
      {int startSec = 0, int durationSec = 10, int fps = 10, int width = 0}) {
    final i = input.toNativeUtf8(); final o = output.toNativeUtf8(); final e = _allocErr();
    final r = _api.videoToGif(i.cast(), o.cast(), startSec, durationSec, fps, width, e.cast(), 256);
    final msg = _cLocal(e); calloc.free(i); calloc.free(o);
    return (r, msg ?? '');
  }

  static (int, String) trim(String input, String output,
      {int startSec = 0, int endSec = 0}) {
    final i = input.toNativeUtf8(); final o = output.toNativeUtf8(); final e = _allocErr();
    final r = _api.videoTrim(i.cast(), o.cast(), startSec, endSec, e.cast(), 256);
    final msg = _cLocal(e); calloc.free(i); calloc.free(o);
    return (r, msg ?? '');
  }

  static (int, String) extractAudio(String input, String output) {
    final i = input.toNativeUtf8(); final o = output.toNativeUtf8(); final e = _allocErr();
    final r = _api.videoExtractAudio(i.cast(), o.cast(), e.cast(), 256);
    final msg = _cLocal(e); calloc.free(i); calloc.free(o);
    return (r, msg ?? '');
  }

  static Map<String, dynamic>? getInfo(String path) {
    final p = path.toNativeUtf8();
    final r = _api.mediaGetInfo(p.cast());
    calloc.free(p);
    final json = _cStr(r);
    if (json == null) return null;
    return _parseJson(json);
  }
}

// ── FileEntry ──

class FileEntry {
  final String path, name, type;
  final bool isDir;
  final int size, modified;
  const FileEntry({required this.path, required this.name, required this.isDir, required this.size, required this.modified, required this.type});

  static List<FileEntry> parseList(String json) {
    final entries = <FileEntry>[];
    final marker = '"entries":[';
    final start = json.indexOf(marker);
    if (start < 0) return entries;
    int i = start + marker.length;
    while (i < json.length) {
      while (i < json.length && json[i] != '{' && json[i] != ']') i++;
      if (json[i] == ']') break;
      i++; // skip {
      String? name, path, type;
      bool isDir = false; int size = 0, modified = 0;
      while (i < json.length && json[i] != '}') {
        while (i < json.length && json[i] != '"') i++; i++; // skip "
        final ks = i; while (i < json.length && json[i] != '"') i++;
        final key = json.substring(ks, i); i += 2; // skip "
        if (key == 'name') { while (i < json.length && json[i] != '"') i++; i++; final vs = i; while (i < json.length && json[i] != '"') i++; name = json.substring(vs, i); i++; }
        else if (key == 'path') { while (i < json.length && json[i] != '"') i++; i++; final vs = i; while (i < json.length && json[i] != '"') i++; path = json.substring(vs, i); i++; }
        else if (key == 'type') { while (i < json.length && json[i] != '"') i++; i++; final vs = i; while (i < json.length && json[i] != '"') i++; type = json.substring(vs, i); i++; }
        else if (key == 'is_dir') { isDir = json.startsWith('true', i); i += isDir ? 4 : 5; }
        else { final vs = i; while (i < json.length && json[i] != ',' && json[i] != '}') i++;
          final val = json.substring(vs, i);
          if (key == 'size') size = int.tryParse(val) ?? 0;
          else if (key == 'modified') modified = int.tryParse(val) ?? 0;
        }
        if (i < json.length && json[i] == ',') i++;
      }
      if (name != null && path != null) {
        entries.add(FileEntry(path: path, name: name, isDir: isDir, size: size, modified: modified, type: type ?? 'file'));
      }
    }
    entries.sort((a, b) {
      if (a.isDir && !b.isDir) return -1;
      if (!a.isDir && b.isDir) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return entries;
  }
}

// ── JSON 工具 ──

Map<String, dynamic> _parseJson(String json) {
  final map = <String, dynamic>{};
  if (json.isEmpty || !json.startsWith('{')) return map;
  int i = 1;
  while (i < json.length && json[i] != '}') {
    while (i < json.length && json[i] != '"') i++; i++;
    final ks = i; while (i < json.length && json[i] != '"') i++;
    final key = json.substring(ks, i); i += 2;
    if (json[i] == '"') { i++; final vs = i; while (i < json.length && json[i] != '"') i++; map[key] = json.substring(vs, i); i++; }
    else if (json.startsWith('true', i)) { map[key] = true; i += 4; }
    else if (json.startsWith('false', i)) { map[key] = false; i += 5; }
    else if (json.startsWith('null', i)) { map[key] = null; i += 4; }
    else { final vs = i; while (i < json.length && json[i] != ',' && json[i] != '}') i++; map[key] = num.tryParse(json.substring(vs, i).trim()) ?? 0; }
    if (i < json.length && json[i] == ',') i++;
  }
  return map;
}
