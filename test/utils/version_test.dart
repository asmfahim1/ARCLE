import 'package:arcle/src/utils/version.dart';
import 'package:test/test.dart';

void main() {
  group('Version', () {
    test('arcleVersion is 2.4.0', () {
      expect(arcleVersion, '2.4.0');
    });
  });
}
