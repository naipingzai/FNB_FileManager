import 'dart:async';
import '../widgets/app_icons.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as fvp;
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import '../ui_design.dart';
import '../l10n/l10n.dart';

/// 视频播放器 - 支持 fvp(默认软解) 和 media_kit(可选硬解)
class VideoPlayerPage extends StatefulWidget {
  final List<String> paths;
  final int index;
  const VideoPlayerPage({super.key, required this.paths, required this.index});
  @override
  State<VideoPlayerPage> createState() => _VPS();
}

class _VPS extends State<VideoPlayerPage> {
  late int _idx;
  bool _useMkv = false; // false=fvp(软解), true=media_kit(硬解)

  // fvp 播放器
  fvp.VideoPlayerController? _fvpCtrl;

  // media_kit 播放器
  mk.Player? _mkPlayer;
  mkv.VideoController? _mkCtrl;

  bool _loading = true;
  String? _err;
  // 控件始终显示，不隐藏
  DateTime? _lastTapLeft, _lastTapRight;
  static const _seekStep = Duration(seconds: 10);

  String get _path => widget.paths[_idx];

  @override
  void initState() {
    super.initState();
    _idx = widget.index;
    _open();
  }

  @override
  void dispose() {
    _fvpCtrl?.removeListener(() { if (mounted) setState(() {}); });
    _fvpCtrl?.dispose();
    _mkPlayer?.dispose();
    super.dispose();
  }

  void _close() {
    _fvpCtrl?.dispose(); _fvpCtrl = null;
    _mkPlayer?.dispose(); _mkPlayer = null;
    _mkCtrl = null;
  }

  void _open() async {
    setState(() { _loading = true; _err = null; });
    _close();
    try {
      if (_useMkv) {
        await _openMkv();
      } else {
        await _openFvp();
      }
      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _err = e.toString(); _loading = false; });
    }
  }

  Future<void> _openFvp() async {
    _fvpCtrl = fvp.VideoPlayerController.file(File(_path));
    await _fvpCtrl!.initialize();
    _fvpCtrl!.setLooping(false);
    _fvpCtrl!.addListener(() { if (mounted) setState(() {}); });
    _fvpCtrl!.play();
  }

  Future<void> _openMkv() async {
    try {
      _mkPlayer = mk.Player();
      _mkCtrl = mkv.VideoController(_mkPlayer!);
      _mkPlayer!.open(mk.Media(_path));
    } catch (e) {
      // media_kit 不支持，自动回退到 fvp 软解
      _mkPlayer?.dispose(); _mkPlayer = null; _mkCtrl = null;
      _useMkv = false;
      await _openFvp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.hwNotSupported)));
      }
    }
  }

  // ── 播放控制 ──
  bool get _isPlaying {
    if (_useMkv) return _mkPlayer?.state.playing ?? false;
    return _fvpCtrl?.value.isPlaying ?? false;
  }

  Duration get _position {
    if (_useMkv) return _mkPlayer?.state.position ?? Duration.zero;
    return _fvpCtrl?.value.position ?? Duration.zero;
  }

  Duration get _duration {
    if (_useMkv) return _mkPlayer?.state.duration ?? Duration.zero;
    return _fvpCtrl?.value.duration ?? Duration.zero;
  }

  void _togglePlay() {
    if (_useMkv) {
      _mkPlayer?.playOrPause();
    } else {
      if (_fvpCtrl?.value.isPlaying ?? false) _fvpCtrl!.pause();
      else _fvpCtrl?.play();
    }
    setState(() {});
      }

  void _seek(Duration d) {
    if (_useMkv) {
      final pos = (_mkPlayer?.state.position ?? Duration.zero) + d;
      _mkPlayer?.seek(pos < Duration.zero ? Duration.zero : pos);
    } else {
      final pos = (_fvpCtrl?.value.position ?? Duration.zero) + d;
      _fvpCtrl?.seekTo(pos < Duration.zero ? Duration.zero : pos);
    }
      }

  void _sw(int i) {
    if (i < 0 || i >= widget.paths.length || i == _idx) return;
    _idx = i;
    _open();
  }

  void _nx() { if (_idx < widget.paths.length - 1) _sw(_idx + 1); }
  void _pv() { if (_idx > 0) _sw(_idx - 1); }

  void _toggleEngine() {
    _useMkv = !_useMkv;
    _open();
    setState(() {});
  }





  void _onTapDown(TapDownDetails d, BoxConstraints bc) {
    final x = d.localPosition.dx;
    final half = bc.maxWidth / 2;
    final now = DateTime.now();
    final isLeft = x < half;
    final last = isLeft ? _lastTapLeft : _lastTapRight;
    if (last != null && now.difference(last) < const Duration(milliseconds: 300)) {
      if (isLeft) _lastTapLeft = null; else _lastTapRight = null;
      _seek(isLeft ? -_seekStep : _seekStep);
    } else {
      if (isLeft) _lastTapLeft = now; else _lastTapRight = now;
    }
  }

  String _ft(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, "0")}:${d.inSeconds.remainder(60).toString().padLeft(2, "0")}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dur = _duration;
    final pos = _position;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, bc) {
        if (_loading) return const Center(child: CircularProgressIndicator(color: Colors.white));
        if (_err != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(AppIcon.error, size: 48, color: Colors.red),
          const SizedBox(height: 8), Text(_err!, style: const TextStyle(color: Colors.white))]));

        return Stack(children: [
          // 视频画面
          Center(child: GestureDetector(
            onDoubleTapDown: (d) => _onTapDown(d, bc),
            onTap: _togglePlay,
            child: _useMkv && _mkCtrl != null
                ? mkv.Video(controller: _mkCtrl!, controls: mkv.NoVideoControls)
                : _fvpCtrl != null && _fvpCtrl!.value.isInitialized
                    ? AspectRatio(aspectRatio: _fvpCtrl!.value.aspectRatio, child: fvp.VideoPlayer(_fvpCtrl!))
                    : const SizedBox(),
          )),
          // 顶部栏
          Positioned(top: 0, left: 0, right: 0, child: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
            child: SafeArea(bottom: false, child: Row(children: [
              IconButton(icon: Icon(AppIcon.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              Expanded(child: Text(_path.split("/").last, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.style('File Browser', 'App Bar Title').copyWith(color: Colors.white))),
              // 引擎切换按钮
              TextButton.icon(
                icon: Icon(_useMkv ? Icons.speed : AppIcon.code, size: 16, color: Colors.white70),
                label: Text(_useMkv ? AppLocalizations.of(context)!.hw_decode : AppLocalizations.of(context)!.sw_decode, style: T.style('File Browser', 'Compression Format').copyWith(color: Colors.white70)),
                onPressed: _toggleEngine,
              ),
              if (widget.paths.length > 1) Text("${_idx + 1}/${widget.paths.length}", style: T.style('File Browser', 'Address Bar').copyWith(color: Colors.white70)),
              const SizedBox(width: 8),
            ]))),),
          // 播放/暂停
          Center(child: GestureDetector(
            onTap: _togglePlay,
            child: Container(width: 72, height: 72,
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: Icon(_isPlaying ? AppIcon.pause : AppIcon.play, size: 42, color: Colors.white),),)),
          // 上一个/下一个
          if (_idx > 0) Positioned(left: 8, top: 0, bottom: 0,
            child: Center(child: IconButton(icon: Icon(AppIcon.skipPrev, color: Colors.white70, size: 36), onPressed: _pv))),
          if (_idx < widget.paths.length - 1) Positioned(right: 8, top: 0, bottom: 0,
            child: Center(child: IconButton(icon: Icon(AppIcon.skipNext, color: Colors.white70, size: 36), onPressed: _nx))),
          // 进度条
          Positioned(bottom: 0, left: 0, right: 0, child: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
            child: SafeArea(top: false, child: Row(children: [
              Text(_ft(pos), style: T.style('File Browser', 'Compression Format').copyWith(color: Colors.white70)),
              const SizedBox(width: 8),
              Expanded(child: Slider(
                value: dur.inMilliseconds > 0 ? pos.inMilliseconds.toDouble().clamp(0.0, dur.inMilliseconds.toDouble()) : 0.0,
                min: 0, max: dur.inMilliseconds > 0 ? dur.inMilliseconds.toDouble() : 1.0,
                activeColor: Colors.white, inactiveColor: Colors.white30,
                onChanged: (val) {
                  final target = Duration(milliseconds: val.toInt());
                  if (_useMkv) _mkPlayer?.seek(target);
                  else _fvpCtrl?.seekTo(target);
                },
              )),
              const SizedBox(width: 8),
              Text(_ft(dur), style: T.style('File Browser', 'Compression Format').copyWith(color: Colors.white70)),
            ]))),),
        ]);
      }),
    );
  }
}
