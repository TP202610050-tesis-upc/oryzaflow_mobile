import 'package:flutter_test/flutter_test.dart';
import 'package:oryzaflow_mobile/core/utils/uuid_v4.dart';

void main() {
  final re = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

  test('tiene formato UUID v4 (versión 4, variante RFC 4122)', () {
    for (var i = 0; i < 100; i++) {
      expect(uuidV4(), matches(re));
    }
  });

  test('1000 generaciones son únicas', () {
    final ids = {for (var i = 0; i < 1000; i++) uuidV4()};
    expect(ids.length, 1000);
  });
}
