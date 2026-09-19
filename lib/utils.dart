import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Formatters {
  static String formatSize(int b) {
    if (b < 0) return '--';
    if (b < 1024) return '$b B';
    if (b < 1048576) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1073741824) return '${(b / 1048576).toStringAsFixed(1)} MB';
    return '${(b / 1073741824).toStringAsFixed(1)} GB';
  }

  static String formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) {
      return diff.inHours == 0 ? '${diff.inMinutes}m ago' : '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String formatTimestamp(int ts) {
    if (ts <= 0) return '--';
    final d = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return diff.inHours == 0 ? '${diff.inMinutes}m ago' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class FileIcons {
  static IconData iconForType(String t) {
    switch (t) {
      case 'folder': return CupertinoIcons.folder_fill;
      case 'image': return CupertinoIcons.photo_fill;
      case 'video': return CupertinoIcons.videocam_fill;
      case 'audio': return CupertinoIcons.music_note;
      case 'pdf': return CupertinoIcons.doc_richtext;
      case 'text': return CupertinoIcons.doc_text_fill;
      case 'archive': return CupertinoIcons.archivebox_fill;
      case 'ebook': return CupertinoIcons.book_fill;
      default: return CupertinoIcons.doc_fill;
    }
  }

  static Color colorForType(String t, ColorScheme cs) {
    switch (t) {
      case 'folder': return cs.primary;
      case 'image': return Colors.purple;
      case 'video': return Colors.red;
      case 'audio': return Colors.orange;
      case 'pdf': return Colors.red.shade700;
      case 'archive': return Colors.brown;
      default: return cs.onSurfaceVariant;
    }
  }
}
