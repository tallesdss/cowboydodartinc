import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final av = AsyncValue<List<String>>.data(['a']);
  print(av.value);
}
