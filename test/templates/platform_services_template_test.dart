import 'package:arcle/src/templates/core/services_templates.dart';
import 'package:arcle/src/state_management.dart';
import 'package:test/test.dart';

void main() {
  group('Platform-safe service templates', () {
    test('permission service adds platform guards', () {
      final template = ServicesTemplates.permissionService(
        StateManagement.riverpod,
      );

      expect(template, contains("import 'package:flutter/foundation.dart';"));
      expect(template, contains('bool get supportsNotifications'));
      expect(template, contains('if (_isWeb) return false;'));
      expect(template, contains('if (supportsPhotosPermission) {'));
    });

    test('notification service adds web and darwin guards', () {
      final template = ServicesTemplates.notificationService(
        StateManagement.riverpod,
      );

      expect(template, contains("import 'package:flutter/foundation.dart';"));
      expect(template, contains('bool get isSupportedPlatform'));
      expect(template, contains('if (!isSupportedPlatform) return;'));
      expect(template, contains('macOS: darwinSettings'));
      expect(template, contains('macOS: const DarwinNotificationDetails()'));
    });
  });
}
