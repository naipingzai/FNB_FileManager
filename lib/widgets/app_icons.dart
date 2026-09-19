import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';

/// Apple HIG style icon mapping using CupertinoIcons
class AppIcon {
  AppIcon._();

  // Navigation & UI
  static const home = CupertinoIcons.house;
  static const back = CupertinoIcons.back;
  static const close = CupertinoIcons.xmark;
  static const search = CupertinoIcons.search;
  static const settings = CupertinoIcons.gear;
  static const info = CupertinoIcons.info;
  static const refresh = CupertinoIcons.arrow_clockwise;
  static const save = CupertinoIcons.floppy_disk;
  static const check = CupertinoIcons.check_mark;
  static const error = CupertinoIcons.exclamationmark_circle;
  static const warning = CupertinoIcons.exclamationmark_triangle;
  static const loading = CupertinoIcons.timer;

  // File operations
  static const folder = CupertinoIcons.folder;
  static const folderOpen = CupertinoIcons.folder_open;
  static const folderAdd = CupertinoIcons.folder_open;
  static const file = CupertinoIcons.doc;
  static const fileAdd = CupertinoIcons.doc;
  static const copy = CupertinoIcons.doc_on_doc;
  static const cut = CupertinoIcons.scissors;
  static const paste = CupertinoIcons.doc_on_clipboard;
  static const delete = CupertinoIcons.trash;
  static const trash = CupertinoIcons.trash;
  static const trashEmpty = CupertinoIcons.trash_slash;
  static const rename = CupertinoIcons.pencil;
  static const compress = CupertinoIcons.archivebox;
  static const extract = CupertinoIcons.tray_arrow_down;
  static const share = CupertinoIcons.share;
  static const move = CupertinoIcons.doc_on_doc;
  static const edit = CupertinoIcons.pencil;
  static const open = CupertinoIcons.arrow_up_right_square;
  static const bookmark = CupertinoIcons.bookmark;
  static const bookmarkFilled = CupertinoIcons.bookmark_fill;

  // Selection & View
  static const selectAll = CupertinoIcons.checkmark_rectangle;
  static const listView = CupertinoIcons.list_bullet;
  static const gridView = CupertinoIcons.square_grid_2x2;
  static const sortBy = CupertinoIcons.sort_down;
  static const visibility = CupertinoIcons.eye;
  static const visibilityOff = CupertinoIcons.eye_slash;
  static const zoomIn = CupertinoIcons.zoom_in;
  static const zoomOut = CupertinoIcons.zoom_out;
  static const zoomFit = CupertinoIcons.rectangle_expand_vertical;

  // Sort
  static const sortName = CupertinoIcons.sort_down;
  static const sortSize = CupertinoIcons.arrow_up_arrow_down;
  static const sortDate = CupertinoIcons.calendar;
  static const sortType = CupertinoIcons.square_grid_2x2;

  // Media player
  static const play = CupertinoIcons.play_fill;
  static const pause = CupertinoIcons.pause_fill;
  static const stop = CupertinoIcons.stop_fill;
  static const skipNext = CupertinoIcons.forward_end_fill;
  static const skipPrev = CupertinoIcons.backward_end_fill;
  static const volumeUp = CupertinoIcons.speaker_2_fill;
  static const volumeMute = CupertinoIcons.speaker_slash_fill;
  static const fastForward = CupertinoIcons.forward_fill;
  static const fullscreen = CupertinoIcons.fullscreen;

  // File type icons
  static const image = CupertinoIcons.photo;
  static const video = CupertinoIcons.videocam;
  static const audio = CupertinoIcons.music_note;
  static const text = CupertinoIcons.doc_text;
  static const code = CupertinoIcons.chevron_left_slash_chevron_right;
  static const pdf = CupertinoIcons.doc_richtext;
  static const archive = CupertinoIcons.archivebox;
  static const ebook = CupertinoIcons.book;

  // Storage & Analysis
  static const storage = CupertinoIcons.device_laptop;
  static const pieChart = CupertinoIcons.chart_pie;
  static const analytics = CupertinoIcons.chart_bar;
  static const cleanup = CupertinoIcons.paintbrush;
  static const preview = CupertinoIcons.eye;
  static const editDoc = CupertinoIcons.doc_text;
  static const markdown = CupertinoIcons.doc_plaintext;
  static const splitView = CupertinoIcons.square_grid_2x2;
  static const queue = CupertinoIcons.line_horizontal_3;

  /// Get icon for file extension
  static IconData forExtension(String ext) {
    switch (ext.toLowerCase()) {
      case '.mp4': case '.mkv': case '.avi': case '.mov': case '.webm': return video;
      case '.mp3': case '.wav': case '.flac': case '.m4a': case '.aac': return audio;
      case '.jpg': case '.jpeg': case '.png': case '.gif': case '.webp': return image;
      case '.pdf': return pdf;
      case '.zip': case '.tar': case '.gz': case '.bz2': case '.xz': case '.7z': case '.rar': return archive;
      case '.md': return markdown;
      case '.epub': return ebook;
      case '.txt': case '.json': case '.xml': case '.yaml': case '.py': case '.dart': case '.c': case '.h':
        return text;
      default: return CupertinoIcons.doc;
    }
  }
}
