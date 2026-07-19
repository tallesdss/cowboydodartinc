import 'package:cross_file/cross_file.dart';
import 'package:open_filex/open_filex.dart';

extension XfileOpen on XFile {
  Future<void> open() => OpenFilex.open(path);
}
