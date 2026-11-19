import 'package:arcle/src/generators/state/common_project_files.dart';
import 'package:arcle/src/state_management.dart';
import 'package:test/test.dart';

void main() {
  group('Date formatter template', () {
    test('is included in generated common project files', () {
      final files = buildCommonProjectFiles(StateManagement.riverpod);

      expect(files.containsKey('lib/core/utils/date_formatter.dart'), isTrue);
    });

    test('exposes formatter singleton and common UX methods', () {
      final file = buildCommonProjectFiles(
        StateManagement.riverpod,
      )['lib/core/utils/date_formatter.dart'];

      expect(file, isNotNull);
      expect(file, contains('class DateFormatter'));
      expect(file, contains('const formatter = DateFormatter.instance;'));
      expect(file, contains('String uxDate('));
      expect(file, contains('String timeAgo('));
      expect(file, contains('DateTime? toLocalDateTime('));
    });
  });
}
