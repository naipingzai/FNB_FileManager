import 'package:path/path.dart' as p;
import 'native.dart' show FileEntry, NativeFs;

export 'native.dart' show FileEntry;

class FileService {
  static String getFileName(String path) => p.basename(path);
  static String getFileExt(String path) => p.extension(path).toLowerCase();

  Future<List<FileEntry>> listDir(String path, {bool showHidden = false}) =>
      NativeFs.listDir(path, showHidden: showHidden);

  Future<List<String>> listRoot() => NativeFs.listRoot();
}
