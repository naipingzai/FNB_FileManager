import 'dart:async';
import '../widgets/app_icons.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart';
import '../native.dart' as native;
import '../ui_design.dart';
import '../l10n/l10n.dart';

class AudioPlayerPage extends StatefulWidget {
  final List<String> paths;
  final int index;
  const AudioPlayerPage({super.key, required this.paths, required this.index});
  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late int _index;
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _info;
  Pointer<Void>? _audioHandle;
  bool _playing = false;

  // PCM 数据（保留指针给线程用）
  Pointer<Uint8>? _pcmPtr;
  int _pcmSize = 0;
  int _pcmSampleRate = 44100;
  int _pcmChannels = 2;
  bool _pcmBigEndian = false;

  // 进度追踪
  Timer? _progressTimer;
  double _positionMs = 0;
  double _durationMs = 0;

  String get _currentPath => widget.paths[_index];

  @override
  void initState() { super.initState(); _index = widget.index; _decode(); }

  @override
  void dispose() { _progressTimer?.cancel(); _stopPlayback(); _freePcm(); super.dispose(); }

  void _stopPlayback() {
    _progressTimer?.cancel();
    if (_audioHandle != null) { native.audioStop(_audioHandle!); native.audioClose(_audioHandle!); _audioHandle = null; }
    _playing = false;
  }

  void _freePcm() {
    if (_pcmPtr != null) { calloc.free(_pcmPtr!); _pcmPtr = null; _pcmSize = 0; }
  }

  void _closeCurrent() {
    _stopPlayback(); _freePcm(); _info = null; _error = null; _positionMs = 0; _durationMs = 0;
  }

  void _switchTo(int i) {
    if (i < 0 || i >= widget.paths.length || i == _index) return;
    _closeCurrent(); _index = i; _decode();
  }
  void _next() { if (_index < widget.paths.length - 1) _switchTo(_index + 1); }
  void _prev() { if (_index > 0) _switchTo(_index - 1); }

  bool _isRawPcm(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ext == 'pcm' || ext == 'raw';
  }

  void _decode() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_isRawPcm(_currentPath)) {
        await _decodeRawPcm();
      } else {
        _decodeFfmpeg();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _decodeRawPcm() async {
    final params = await showDialog<Map<String, int>>(context: context, builder: (_) => _PcmParamDialog());
    if (params == null) { if (mounted) Navigator.of(context).pop(); return; }
    var data = await File(_currentPath).readAsBytes();
    _pcmSampleRate = params['sampleRate'] ?? 44100;
    _pcmChannels = params['channels'] ?? 2;
    final bits = params['bits'] ?? 16;
    _pcmBigEndian = (params['bigEndian'] ?? 0) == 1;
    // 大端 → 转小端（ALSA/AAudio 都是 little-endian S16/S24/S32）
    if (_pcmBigEndian && bits >= 16) {
      final swapped = Uint8List(data.length);
      final bytesPerSample = bits ~/ 8;
      for (int i = 0; i + bytesPerSample <= data.length; i += bytesPerSample) {
        for (int j = 0; j < bytesPerSample; j++) {
          swapped[i + j] = data[i + bytesPerSample - 1 - j];
        }
      }
      data = swapped;
    }
    _pcmPtr = calloc<Uint8>(data.length);
    _pcmSize = data.length;
    _pcmPtr!.asTypedList(data.length).setAll(0, data);
    final bytesPerSample = (bits / 8).toInt();
    final totalSamples = data.length ~/ (bytesPerSample * _pcmChannels);
    _durationMs = totalSamples / _pcmSampleRate * 1000;
    _info = {'format': 'raw', 'sample_rate': _pcmSampleRate, 'channels': _pcmChannels, 'bits': bits, 'endian': _pcmBigEndian ? 'big' : 'little'};
    setState(() { _loading = false; _positionMs = 0; });
  }

  void _decodeFfmpeg() async {
    final data = await File(_currentPath).readAsBytes();
    final result = native.decodeAudio(data);
    if (result == null) { setState(() { _error = AppLocalizations.of(context)!.cannot_decode_audio; _loading = false; }); return; }
    _info = jsonDecode(result);
    _pcmSampleRate = _info!['sample_rate'] ?? 44100;
    _pcmChannels = _info!['channels'] ?? 2;
    final bits = _info!['bits'] ?? 16;
    final base64Pcm = _info!['base64'];
    if (base64Pcm != null) {
      final pcm = base64Decode(base64Pcm);
      _pcmPtr = calloc<Uint8>(pcm.length);
      _pcmSize = pcm.length;
      _pcmPtr!.asTypedList(pcm.length).setAll(0, pcm);
      final bytesPerSample = (bits / 8).toInt();
      final totalSamples = pcm.length ~/ (bytesPerSample * _pcmChannels);
      _durationMs = totalSamples / _pcmSampleRate * 1000;
    }
    setState(() { _loading = false; _positionMs = 0; });
  }

  void _togglePlay() {
    if (_playing) {
      _stopPlayback();
      _positionMs = 0;
      setState(() {});
    } else {
      if (_info == null || _pcmPtr == null) return;
      _audioHandle = native.audioOpen(_pcmSampleRate, _pcmChannels, 16);
      if (_audioHandle != null) {
        native.audioPlayThread(_audioHandle!, _pcmPtr!, _pcmSize, 0);
        _playing = true;
        _positionMs = 0;
        _startProgressTimer();
        setState(() {});
      }
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_playing || !mounted) return;
      _positionMs += 200;
      if (_positionMs >= _durationMs) {
        _positionMs = _durationMs;
        _stopPlayback();
        _positionMs = 0;
        setState(() {});
        return;
      }
      setState(() {});
    });
  }

  void _seek(double ms) {
    if (_pcmPtr == null || _pcmSize == 0) return;
    _positionMs = ms;
    final bytesPerSec = _pcmSampleRate * _pcmChannels * 2;
    final offset = (ms / 1000 * bytesPerSec).toInt().clamp(0, _pcmSize);
    if (_playing && _audioHandle != null) {
      native.audioStop(_audioHandle!);
      native.audioPlayThread(_audioHandle!, _pcmPtr!, _pcmSize, offset);
    }
    setState(() {});
  }

  String _fmtTime(double ms) {
    final s = ms ~/ 1000;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final fileName = _currentPath.split('/').last;
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (widget.paths.length > 1)
            Center(child: Text('${_index + 1}/${widget.paths.length}',
                style: T.style('File Browser', 'Address Bar').copyWith(color: cs.onSurface))),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == null) return;
                    if (details.primaryVelocity! < -100) _next();
                    else if (details.primaryVelocity! > 100) _prev();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(AppIcon.audio, size: 80, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(fileName, style: T.style('Audio Player', 'File Name'),
                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      if (_info != null)
                        Text('${_info!['sample_rate']} Hz · ${_info!['channels']}ch · ${_info!['bits']}bit',
                            style: T.style('Audio Player', 'caption', c: cs.onSurfaceVariant)),
                      const SizedBox(height: 32),
                      // 进度条
                      if (_durationMs > 0) ...[
                        Slider(value: _positionMs.clamp(0.0, _durationMs), min: 0, max: _durationMs,
                            onChanged: _seek),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(_fmtTime(_positionMs), style: T.style('Audio Player', 'caption', c: cs.onSurfaceVariant)),
                            Text(_fmtTime(_durationMs), style: T.style('Audio Player', 'caption', c: cs.onSurfaceVariant)),
                          ])),
                        const SizedBox(height: 16),
                      ],
                      // 播放控制
                      if (widget.paths.length > 1)
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          IconButton(iconSize: 36, icon: Icon(AppIcon.skipPrev),
                              onPressed: _index > 0 ? _prev : null),
                          const SizedBox(width: 24),
                          IconButton(iconSize: 64, icon: Icon(_playing ? Icons.stop_circle : AppIcon.play,
                              color: cs.primary), onPressed: _togglePlay),
                          const SizedBox(width: 24),
                          IconButton(iconSize: 36, icon: Icon(AppIcon.skipNext),
                              onPressed: _index < widget.paths.length - 1 ? _next : null),
                        ])
                      else
                        IconButton(iconSize: 64, icon: Icon(_playing ? Icons.stop_circle : AppIcon.play,
                            color: cs.primary), onPressed: _togglePlay),
                      if (widget.paths.length > 1) ...[
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.swipeHint, style: T.style('Audio Player', 'caption', c: cs.onSurfaceVariant)),
                      ],
                    ]),
                  ),
                ),
    );
  }
}

/// PCM 格式参数对话框
class _PcmParamDialog extends StatefulWidget {
  @override
  State<_PcmParamDialog> createState() => _PcmParamDialogState();
}

class _PcmParamDialogState extends State<_PcmParamDialog> {
  String _sr = '44100';
  String _ch = '2';
  String _bits = '16';
  bool _bigEndian = false;
  static const _srOptions = ['8000','16000','22050','44100','48000','96000'];
  static const _chOptions = ['1','2','6','8'];
  static const _bitsOptions = ['8','16','24','32'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.pcmParams),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          value: _sr, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.sampleRate),
          items: _srOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) { if (v != null) setState(() => _sr = v); },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _ch, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.channels),
          items: _chOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) { if (v != null) setState(() => _ch = v); },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _bits, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.bitDepth),
          items: _bitsOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) { if (v != null) setState(() => _bits = v); },
        ),
        if (int.parse(_bits) > 8) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<bool>(
            value: _bigEndian, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.byteOrder),
            items: [
              DropdownMenuItem(value: false, child: Text(AppLocalizations.of(context)!.littleEndian)),
              DropdownMenuItem(value: true, child: Text(AppLocalizations.of(context)!.bigEndian)),
            ],
            onChanged: (v) { if (v != null) setState(() => _bigEndian = v); },
          ),
        ],
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, {
          'sampleRate': int.parse(_sr), 'channels': int.parse(_ch), 'bits': int.parse(_bits),
          'bigEndian': _bigEndian ? 1 : 0,
        }), child: Text(AppLocalizations.of(context)!.ok)),
      ],
    );
  }
}
