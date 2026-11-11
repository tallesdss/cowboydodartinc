import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  const av = AsyncData<List<String>>(['a']);
  assert(av.value.single == 'a');
}
