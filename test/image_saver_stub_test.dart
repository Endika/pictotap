import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/services/image_saver_stub.dart';

void main() {
  test('saveAndShareImage throws UnsupportedError', () {
    expect(
      () => saveAndShareImage(Uint8List(0), 'test.png', 'text'),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
