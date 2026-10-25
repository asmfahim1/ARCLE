import 'package:arcle/src/utils/version.dart';
import 'package:test/test.dart';

void main() {
  group('Version', () {
    test('arcleVersion is 3.0.1', () {
      expect(arcleVersion, '3.0.1');
    });
  });
}
