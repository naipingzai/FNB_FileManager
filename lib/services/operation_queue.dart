import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../native.dart';

enum OpType { copy, move, delete, compress, extract }
enum OpStatus { pending, running, done, failed, cancelled }

class FileOperation {
  final OpType type;
  final String src;
  final String? dst;
  OpStatus status;
  int progress, total;
  String? error;
  final DateTime createdAt;
  FileOperation(this.type, this.src, {this.dst})
      : status = OpStatus.pending, progress = 0, total = 0, createdAt = DateTime.now();
}

class OperationQueue extends ChangeNotifier {
  static final OperationQueue instance = OperationQueue._();
  OperationQueue._();

  final List<FileOperation> _queue = [];
  bool _processing = false;
  FileOperation? _current;

  List<FileOperation> get queue => List.unmodifiable(_queue);
  FileOperation? get current => _current;
  bool get isProcessing => _processing;

  void add(FileOperation op) {
    _queue.add(op);
    notifyListeners();
    _processNext();
  }

  void cancel(FileOperation op) {
    op.status = OpStatus.cancelled;
    if (op == _current) {
      NativeArchive.cancelExtract();
      _current = null;
      _processing = false;
      _processNext();
    }
    notifyListeners();
  }

  void cancelAll() {
    for (final op in _queue.where((o) => o.status == OpStatus.pending || o.status == OpStatus.running)) {
      op.status = OpStatus.cancelled;
    }
    NativeArchive.cancelExtract();
    _current = null;
    _processing = false;
    notifyListeners();
  }

  void clearCompleted() {
    _queue.removeWhere((o) => o.status == OpStatus.done || o.status == OpStatus.failed || o.status == OpStatus.cancelled);
    notifyListeners();
  }

  void _processNext() {
    if (_processing) return;
    final next = _queue.where((o) => o.status == OpStatus.pending).firstOrNull;
    if (next == null) return;
    _processing = true;
    _current = next;
    _execute(next);
  }

  void _execute(FileOperation op) async {
    op.status = OpStatus.running;
    notifyListeners();
    try {
      // Run heavy native FFI operations off the main thread via Isolate
      final result = await Isolate.run(() {
        switch (op.type) {
          case OpType.copy:
            final (rc, msg) = NativeFs.copy(op.src, op.dst!);
            return (rc, msg);
          case OpType.move:
            final (rc, msg) = NativeFs.move(op.src, op.dst!);
            return (rc, msg);
          case OpType.delete:
            final (rc, msg) = NativeFs.delete(op.src);
            return (rc, msg);
          case OpType.compress:
            final rc = NativeArchive.createEx(op.src, op.dst ?? '${op.src}.zip');
            return (rc, '');
          case OpType.extract:
            final rc = NativeArchive.extract(op.src, op.dst ?? '');
            return (rc, '');
        }
      });
      final (rc, msg) = result;
      op.status = rc == 0 ? OpStatus.done : OpStatus.failed;
      if (rc != 0) op.error = msg.isNotEmpty ? msg : '${op.type.name} failed';
    } catch (e) {
      op.status = OpStatus.failed;
      op.error = e.toString();
    }
    _current = null;
    _processing = false;
    notifyListeners();
    _processNext();
  }
}
