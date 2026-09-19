// AUTO GENERATED - FFI bindings wrapper
// ignore_for_file: type=lint, unused_import
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' show calloc;
import '../l10n/l10n.dart';

class FnbBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String) _lookup;
  FnbBindings(ffi.DynamicLibrary dl) : _lookup = dl.lookup;

  // ── 视频 ──
  late final _video_open = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, ffi.Int)>>('video_open').asFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, int)>();
  ffi.Pointer<ffi.Void> video_open(ffi.Pointer<ffi.Uint8> d, int l) => _video_open(d, l);

  late final _video_get_info = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>>('video_get_info').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>();
  ffi.Pointer<ffi.Char> video_get_info(ffi.Pointer<ffi.Void> h) => _video_get_info(h);

  late final _video_next_frame = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Double>)>>('video_next_frame').asFunction<int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Double>)>();
  int video_next_frame(ffi.Pointer<ffi.Void> h, ffi.Pointer<ffi.Uint8> out, int cap, ffi.Pointer<ffi.Int> w, ffi.Pointer<ffi.Int> ht, ffi.Pointer<ffi.Double> ts) => _video_next_frame(h, out, cap, w, ht, ts);

  late final _video_next_frame_scaled = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Int, ffi.Int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Double>)>>('video_next_frame_scaled').asFunction<int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Double>)>();
  int videoNextFrameScaled(ffi.Pointer<ffi.Void> h, ffi.Pointer<ffi.Uint8> out, int cap, int maxW, ffi.Pointer<ffi.Int> w, ffi.Pointer<ffi.Int> ht, ffi.Pointer<ffi.Double> ts) => _video_next_frame_scaled(h, out, cap, maxW, w, ht, ts);

  late final _video_seek = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Double)>>('video_seek').asFunction<int Function(ffi.Pointer<ffi.Void>, double)>();
  int video_seek(ffi.Pointer<ffi.Void> h, double t) => _video_seek(h, t);

  late final _video_close = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>('video_close').asFunction<void Function(ffi.Pointer<ffi.Void>)>();
  void video_close(ffi.Pointer<ffi.Void> h) => _video_close(h);

  late final _video_thumbnail = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, ffi.Int)>>('video_thumbnail').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, int)>();
  ffi.Pointer<ffi.Char> video_thumbnail(ffi.Pointer<ffi.Char> p, int s) => _video_thumbnail(p, s);

  late final _video_audio_info = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>>('video_audio_info').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>();
  ffi.Pointer<ffi.Char> video_audio_info(ffi.Pointer<ffi.Void> h) => _video_audio_info(h);


  late final _video_stream_pause = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int)>>('video_stream_pause').asFunction<void Function(ffi.Pointer<ffi.Void>, int)>();
  void videoStreamPause(ffi.Pointer<ffi.Void> h, int p) => _video_stream_pause(h, p);

  late final _video_audio_decode = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Int, ffi.Pointer<ffi.Int>)>>('video_audio_decode').asFunction<int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Int>)>();
  int video_audio_decode(ffi.Pointer<ffi.Void> h, ffi.Pointer<ffi.Uint8> out, int cap, ffi.Pointer<ffi.Int> written) => _video_audio_decode(h, out, cap, written);

  late final _video_audio_reset = _lookup<ffi.NativeFunction<ffi.Void Function()>>('video_audio_reset').asFunction<void Function()>();
  void video_audio_reset() => _video_audio_reset();

  late final _video_audio_decode_all = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>>('video_audio_decode_all').asFunction<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>();
  (ffi.Pointer<ffi.Uint8>, int, int, int)? videoAudioDecodeAll(ffi.Pointer<ffi.Void> h) {
    final sizeP = calloc<ffi.Int>(); final srP = calloc<ffi.Int>(); final chP = calloc<ffi.Int>();
    final pcm = _video_audio_decode_all(h, sizeP, srP, chP);
    final size = sizeP.value; final sr = srP.value; final ch = chP.value;
    calloc.free(sizeP); calloc.free(srP); calloc.free(chP);
    if (pcm.address == 0 || size <= 0) return null;
    return (pcm, size, sr, ch);
  }

  // ── 音频 ──
  late final _audio_decode = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Uint8>, ffi.Int)>>('audio_decode').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Uint8>, int)>();
  ffi.Pointer<ffi.Char> audio_decode(ffi.Pointer<ffi.Uint8> d, int l) => _audio_decode(d, l);

  late final _audio_output_open = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Int, ffi.Int, ffi.Int)>>('audio_output_open').asFunction<ffi.Pointer<ffi.Void> Function(int, int, int)>();
  ffi.Pointer<ffi.Void> audio_output_open(int sr, int ch, int bits) => _audio_output_open(sr, ch, bits);

  late final _audio_output_write = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Int)>>('audio_output_write').asFunction<int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int)>();
  int audio_output_write(ffi.Pointer<ffi.Void> h, ffi.Pointer<ffi.Uint8> p, int l) => _audio_output_write(h, p, l);

  late final _audio_output_stop = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>('audio_output_stop').asFunction<void Function(ffi.Pointer<ffi.Void>)>();
  void audio_output_stop(ffi.Pointer<ffi.Void> h) => _audio_output_stop(h);

  late final _audio_output_play_thread = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Int, ffi.Int)>>('audio_output_play_thread').asFunction<void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int, int)>();
  void audio_output_play_thread(ffi.Pointer<ffi.Void> h, ffi.Pointer<ffi.Uint8> p, int s, int o) => _audio_output_play_thread(h, p, s, o);

  late final _audio_output_close = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>('audio_output_close').asFunction<void Function(ffi.Pointer<ffi.Void>)>();
  void audio_output_close(ffi.Pointer<ffi.Void> h) => _audio_output_close(h);

  // ── 电子书 ──
  late final _epub_extract_text = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('epub_extract_text').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
  ffi.Pointer<ffi.Char> epub_extract_text(ffi.Pointer<ffi.Char> p) => _epub_extract_text(p);

  late final _epub_list_files = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('epub_list_files').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
  ffi.Pointer<ffi.Char> epub_list_files(ffi.Pointer<ffi.Char> p) => _epub_list_files(p);

  // ── 压缩包 ──
  late final _archive_list = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('archive_list').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
  ffi.Pointer<ffi.Char> archive_list(ffi.Pointer<ffi.Char> p) => _archive_list(p);

  late final _archive_extract = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_extract').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int archive_extract(ffi.Pointer<ffi.Char> z, ffi.Pointer<ffi.Char> o, ffi.Pointer<ffi.Char> e, int s) => _archive_extract(z, o, e, s);

  late final _archive_create = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_create').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int archive_create(ffi.Pointer<ffi.Char> s, ffi.Pointer<ffi.Char> z, ffi.Pointer<ffi.Char> e, int sz) => _archive_create(s, z, e, sz);

  // ── 工具 ──
  late final _bridge_free_string = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>('bridge_free_string').asFunction<void Function(ffi.Pointer<ffi.Char>)>();
  void bridge_free_string(ffi.Pointer<ffi.Char> s) => _bridge_free_string(s);

  // ── 文件系统操作 ──
  late final _fs_copy = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_copy').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_copy(ffi.Pointer<ffi.Char> s, ffi.Pointer<ffi.Char> d, ffi.Pointer<ffi.Char> e, int es) => _fs_copy(s, d, e, es);

  late final _fs_move = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_move').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_move(ffi.Pointer<ffi.Char> s, ffi.Pointer<ffi.Char> d, ffi.Pointer<ffi.Char> e, int es) => _fs_move(s, d, e, es);

  late final _fs_delete = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_delete').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_delete(ffi.Pointer<ffi.Char> p, ffi.Pointer<ffi.Char> e, int es) => _fs_delete(p, e, es);

  late final _fs_mkdir = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_mkdir').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_mkdir(ffi.Pointer<ffi.Char> p, ffi.Pointer<ffi.Char> e, int es) => _fs_mkdir(p, e, es);

  late final _fs_rename = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_rename').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_rename(ffi.Pointer<ffi.Char> o, ffi.Pointer<ffi.Char> n, ffi.Pointer<ffi.Char> e, int es) => _fs_rename(o, n, e, es);

  late final _fs_properties = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('fs_properties').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
  ffi.Pointer<ffi.Char> fs_properties(ffi.Pointer<ffi.Char> p) => _fs_properties(p);

  late final _fs_dir_size = _lookup<ffi.NativeFunction<ffi.LongLong Function(ffi.Pointer<ffi.Char>)>>('fs_dir_size').asFunction<int Function(ffi.Pointer<ffi.Char>)>();
  int fs_dir_size(ffi.Pointer<ffi.Char> p) => _fs_dir_size(p);

  late final _fs_list_dir = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_list_dir').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, int)>();
  ffi.Pointer<ffi.Char> fs_list_dir(ffi.Pointer<ffi.Char> p, int sh) => _fs_list_dir(p, sh);

  late final _fs_trash = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_trash').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_trash(ffi.Pointer<ffi.Char> p, ffi.Pointer<ffi.Char> e, int es) => _fs_trash(p, e, es);

  late final _fs_trash_restore = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_trash_restore').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_trash_restore(ffi.Pointer<ffi.Char> n, ffi.Pointer<ffi.Char> e, int es) => _fs_trash_restore(n, e, es);

  late final _fs_trash_empty = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_trash_empty').asFunction<int Function(ffi.Pointer<ffi.Char>, int)>();
  int fs_trash_empty(ffi.Pointer<ffi.Char> e, int es) => _fs_trash_empty(e, es);

  late final _fs_trash_list = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('fs_trash_list').asFunction<ffi.Pointer<ffi.Char> Function()>();
  ffi.Pointer<ffi.Char> fs_trash_list() => _fs_trash_list();

  // ── 新增操作 ──
  late final _fs_delete_permanent = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_delete_permanent').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_delete_permanent(ffi.Pointer<ffi.Char> p, ffi.Pointer<ffi.Char> e, int es) => _fs_delete_permanent(p, e, es);

  late final _fs_create_file = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_create_file').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_create_file(ffi.Pointer<ffi.Char> p, ffi.Pointer<ffi.Char> e, int es) => _fs_create_file(p, e, es);

  late final _fs_chmod = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_chmod').asFunction<int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int)>();
  int fs_chmod(ffi.Pointer<ffi.Char> p, int m, ffi.Pointer<ffi.Char> e, int es) => _fs_chmod(p, m, e, es);

  late final _fs_file_hash = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_file_hash').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, int)>();
  ffi.Pointer<ffi.Char> fs_file_hash(ffi.Pointer<ffi.Char> p, int a) => _fs_file_hash(p, a);

  late final _fs_batch_rename = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('fs_batch_rename').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int fs_batch_rename(ffi.Pointer<ffi.Char> d, ffi.Pointer<ffi.Char> j, ffi.Pointer<ffi.Char> e, int es) => _fs_batch_rename(d, j, e, es);

  // ── 压缩包进度 ──
  late final _archive_extract_progress = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_extract_progress').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int archive_extract_progress(ffi.Pointer<ffi.Char> z, ffi.Pointer<ffi.Char> o, ffi.Pointer<ffi.Char> p, ffi.Pointer<ffi.Char> e, int s) => _archive_extract_progress(z, o, p, e, s);

  late final _archive_create_progress = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_create_progress').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int archive_create_progress(ffi.Pointer<ffi.Char> s, ffi.Pointer<ffi.Char> z, ffi.Pointer<ffi.Char> e, int es) => _archive_create_progress(s, z, e, es);

  late final _archive_get_progress = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_get_progress').asFunction<int Function(ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Char>, int)>();
  int archive_get_progress(ffi.Pointer<ffi.Int> c, ffi.Pointer<ffi.Int> t, ffi.Pointer<ffi.Char> f, int fs) => _archive_get_progress(c, t, f, fs);

  late final _archive_is_running = _lookup<ffi.NativeFunction<ffi.Int Function()>>('archive_is_running').asFunction<int Function()>();
  int archive_is_running() => _archive_is_running();

  late final _archive_file_count = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>('archive_file_count').asFunction<int Function(ffi.Pointer<ffi.Char>)>();
  int archive_file_count(ffi.Pointer<ffi.Char> p) => _archive_file_count(p);

  late final _archive_cancel_extract = _lookup<ffi.NativeFunction<ffi.Int Function()>>('archive_cancel_extract').asFunction<int Function()>();
  int archiveCancelExtract() => _archive_cancel_extract();

  late final _archive_create_ex = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_create_ex').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int)>();
  int archiveCreateEx(ffi.Pointer<ffi.Char> s, ffi.Pointer<ffi.Char> o, int lv, ffi.Pointer<ffi.Char> e, int es) => _archive_create_ex(s, o, lv, e, es);

  late final _archive_create_7z = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_create_7z').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int)>();
  int archiveCreate7z(ffi.Pointer<ffi.Char> s, ffi.Pointer<ffi.Char> o, ffi.Pointer<ffi.Char> p, int lv, ffi.Pointer<ffi.Char> e, int es) => _archive_create_7z(s, o, p, lv, e, es);

  late final _archive_supported_formats = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('archive_supported_formats').asFunction<ffi.Pointer<ffi.Char> Function()>();
  ffi.Pointer<ffi.Char> archiveSupportedFormats() => _archive_supported_formats();

  late final _archive_decompress_file = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_decompress_file').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int archiveDecompressFile(ffi.Pointer<ffi.Char> i, ffi.Pointer<ffi.Char> o, ffi.Pointer<ffi.Char> e, int es) => _archive_decompress_file(i, o, e, es);

  late final _archive_compress_file = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('archive_compress_file').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int)>();
  int archiveCompressFile(ffi.Pointer<ffi.Char> i, ffi.Pointer<ffi.Char> o, int lv, ffi.Pointer<ffi.Char> e, int es) => _archive_compress_file(i, o, lv, e, es);

  // ── GPU 检测 ──
  late final _gpu_detect_hw_decode = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('gpu_detect_hw_decode').asFunction<ffi.Pointer<ffi.Char> Function()>();
  ffi.Pointer<ffi.Char> gpuDetectHwDecode() => _gpu_detect_hw_decode();

  // ── 硬件解码接口（预留） ──
  late final _hw_decode_init = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, ffi.Int)>>('hw_decode_init').asFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, int)>();
  ffi.Pointer<ffi.Void> hwDecodeInit(ffi.Pointer<ffi.Uint8> d, int l) => _hw_decode_init(d, l);

  late final _hw_decode_frame = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Double>)>>('hw_decode_frame').asFunction<int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Double>)>();
  int hwDecodeFrame(ffi.Pointer<ffi.Void> h, ffi.Pointer<ffi.Uint8> out, int cap, ffi.Pointer<ffi.Int> w, ffi.Pointer<ffi.Int> ht, ffi.Pointer<ffi.Double> ts) => _hw_decode_frame(h, out, cap, w, ht, ts);

  late final _hw_decode_seek = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Double)>>('hw_decode_seek').asFunction<int Function(ffi.Pointer<ffi.Void>, double)>();
  int hwDecodeSeek(ffi.Pointer<ffi.Void> h, double t) => _hw_decode_seek(h, t);

  late final _hw_decode_close = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>('hw_decode_close').asFunction<void Function(ffi.Pointer<ffi.Void>)>();
  void hwDecodeClose(ffi.Pointer<ffi.Void> h) => _hw_decode_close(h);

  // ── 视频格式转换 ──
  late final _video_convert = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('video_convert').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, int, ffi.Pointer<ffi.Char>, int)>();
  int videoConvert(ffi.Pointer<ffi.Char> inp, ffi.Pointer<ffi.Char> out, ffi.Pointer<ffi.Char> codec, ffi.Pointer<ffi.Char> container, int br, int mw, ffi.Pointer<ffi.Char> err, int esz) => _video_convert(inp, out, codec, container, br, mw, err, esz);

  late final _video_convert_get_progress = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>>('video_convert_get_progress').asFunction<int Function(ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>();
  (int, int) videoConvertProgress() {
    final cP = calloc<ffi.Int>(); final tP = calloc<ffi.Int>();
    _video_convert_get_progress(cP, tP);
    final c = cP.value, t = tP.value;
    calloc.free(cP); calloc.free(tP);
    return (c, t);
  }

  late final _video_convert_cancel = _lookup<ffi.NativeFunction<ffi.Int Function()>>('video_convert_cancel').asFunction<int Function()>();
  int videoConvertCancel() => _video_convert_cancel();

  // ── 媒体工具 ──
  late final _video_to_gif = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int, ffi.Int, ffi.Int, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('video_to_gif').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, int, int, int, ffi.Pointer<ffi.Char>, int)>();
  int videoToGif(ffi.Pointer<ffi.Char> inp, ffi.Pointer<ffi.Char> out, int startSec, int durSec, int fps, int width, ffi.Pointer<ffi.Char> err, int esz) => _video_to_gif(inp, out, startSec, durSec, fps, width, err, esz);

  late final _video_trim = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int, ffi.Int, ffi.Pointer<ffi.Char>, ffi.Int)>>('video_trim').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, int, ffi.Pointer<ffi.Char>, int)>();
  int videoTrim(ffi.Pointer<ffi.Char> inp, ffi.Pointer<ffi.Char> out, int startSec, int endSec, ffi.Pointer<ffi.Char> err, int esz) => _video_trim(inp, out, startSec, endSec, err, esz);

  late final _video_extract_audio = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Int)>>('video_extract_audio').asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();
  int videoExtractAudio(ffi.Pointer<ffi.Char> inp, ffi.Pointer<ffi.Char> out, ffi.Pointer<ffi.Char> err, int esz) => _video_extract_audio(inp, out, err, esz);

  late final _media_get_info = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('media_get_info').asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
  ffi.Pointer<ffi.Char> mediaGetInfo(ffi.Pointer<ffi.Char> p) => _media_get_info(p);
}
