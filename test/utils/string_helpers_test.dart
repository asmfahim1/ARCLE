import 'package:arcle/src/utils/string_helpers.dart';
import 'package:test/test.dart';

void main() {
  group('StringHelpers', () {
    group('snakeCase', () {
      test('converts camelCase to snake_case', () {
        expect(StringHelpers.snakeCase('myAwesomeVariable'),
            'my_awesome_variable');
        expect(StringHelpers.snakeCase('myVariable'), 'my_variable');
      });

      test('converts PascalCase to snake_case', () {
        expect(StringHelpers.snakeCase('MyAwesomeVariable'),
            'my_awesome_variable');
        expect(
            StringHelpers.snakeCase('ProfileQuotation'), 'profile_quotation');
      });

      test('handles hyphens', () {
        expect(StringHelpers.snakeCase('my-awesome-variable'),
            'my_awesome_variable');
      });

      test('handles spaces', () {
        expect(StringHelpers.snakeCase('my awesome variable'),
            'my_awesome_variable');
      });

      test('handles special characters', () {
        expect(StringHelpers.snakeCase('my@awesome#variable'),
            'myawesomevariable');
      });

      test('handles empty string', () {
        expect(StringHelpers.snakeCase(''), '');
      });

      test('handles whitespace-only string', () {
        expect(StringHelpers.snakeCase('   '), '');
      });
    });

    group('toPascalCase', () {
      test('converts snake_case to PascalCase', () {
        expect(StringHelpers.toPascalCase('profile_quotation'),
            'ProfileQuotation');
        expect(StringHelpers.toPascalCase('my_variable'), 'MyVariable');
      });

      test('converts camelCase to PascalCase (lowercases and recaps)', () {
        expect(StringHelpers.toPascalCase('myVariable'), 'Myvariable');
        expect(
            StringHelpers.toPascalCase('profileQuotation'), 'Profilequotation');
      });

      test('converts hyphenated strings to PascalCase', () {
        expect(StringHelpers.toPascalCase('user-profile'), 'UserProfile');
      });

      test('handles spaces', () {
        expect(StringHelpers.toPascalCase('my awesome feature'),
            'MyAwesomeFeature');
      });

      test('handles empty string', () {
        expect(StringHelpers.toPascalCase(''), '');
      });

      test('handles single word', () {
        expect(StringHelpers.toPascalCase('hello'), 'Hello');
      });
    });

    group('toSnakeCase', () {
      test('converts PascalCase to snake_case', () {
        expect(
            StringHelpers.toSnakeCase('ProfileQuotation'), 'profile_quotation');
        expect(StringHelpers.toSnakeCase('MyAwesomeFeature'),
            'my_awesome_feature');
      });

      test('converts camelCase to snake_case', () {
        expect(StringHelpers.toSnakeCase('myVariable'), 'my_variable');
      });

      test('handles empty string', () {
        expect(StringHelpers.toSnakeCase(''), '');
      });

      test('handles single word', () {
        expect(StringHelpers.toSnakeCase('hello'), 'hello');
      });
    });

    group('toCamelCase', () {
      test('converts snake_case to camelCase', () {
        expect(
            StringHelpers.toCamelCase('profile_quotation'), 'profileQuotation');
        expect(StringHelpers.toCamelCase('user_profile'), 'userProfile');
      });

      test('converts PascalCase to camelCase (lowercases first)', () {
        expect(
            StringHelpers.toCamelCase('ProfileQuotation'), 'profilequotation');
        expect(StringHelpers.toCamelCase('MyVariable'), 'myvariable');
      });

      test('converts hyphenated strings to camelCase', () {
        expect(StringHelpers.toCamelCase('user-profile'), 'userProfile');
      });

      test('handles empty string', () {
        expect(StringHelpers.toCamelCase(''), '');
      });

      test('handles single word', () {
        expect(StringHelpers.toCamelCase('hello'), 'hello');
      });
    });

    group('toDisplayName', () {
      test('converts snake_case to display name', () {
        expect(StringHelpers.toDisplayName('profile_quotation'),
            'Profile Quotation');
      });

      test('converts hyphenated to display name', () {
        expect(StringHelpers.toDisplayName('user-profile'), 'User Profile');
      });

      test('handles empty string', () {
        expect(StringHelpers.toDisplayName(''), '');
      });

      test('handles single word', () {
        expect(StringHelpers.toDisplayName('hello'), 'Hello');
      });
    });

    group('isSnakeCase', () {
      test('identifies valid snake_case', () {
        expect(StringHelpers.isSnakeCase('my_variable'), isTrue);
        expect(StringHelpers.isSnakeCase('profile_quotation'), isTrue);
      });

      test('rejects invalid snake_case', () {
        expect(StringHelpers.isSnakeCase('MyVariable'), isFalse);
        expect(StringHelpers.isSnakeCase('my-variable'), isFalse);
        expect(StringHelpers.isSnakeCase(''), isFalse);
      });
    });

    group('isPascalCase', () {
      test('identifies valid PascalCase', () {
        expect(StringHelpers.isPascalCase('MyVariable'), isTrue);
        expect(StringHelpers.isPascalCase('ProfileQuotation'), isTrue);
      });

      test('rejects invalid PascalCase', () {
        expect(StringHelpers.isPascalCase('myVariable'), isFalse);
        expect(StringHelpers.isPascalCase('my_variable'), isFalse);
        expect(StringHelpers.isPascalCase(''), isFalse);
      });
    });

    group('capitalize', () {
      test('capitalizes first letter', () {
        expect(StringHelpers.capitalize('hello'), 'Hello');
        expect(StringHelpers.capitalize('world'), 'World');
      });

      test('handles empty string', () {
        expect(StringHelpers.capitalize(''), '');
      });

      test('handles already capitalized', () {
        expect(StringHelpers.capitalize('Hello'), 'Hello');
      });
    });

    group('removeSpecialChars', () {
      test('removes special characters', () {
        expect(StringHelpers.removeSpecialChars('hello@world#test'),
            'helloworldtest');
      });

      test('preserves alphanumeric', () {
        expect(StringHelpers.removeSpecialChars('hello123world456'),
            'hello123world456');
      });

      test('handles empty string', () {
        expect(StringHelpers.removeSpecialChars(''), '');
      });
    });

    group('aliases', () {
      test('pascalCase is alias for toPascalCase', () {
        expect(StringHelpers.pascalCase('my_var'),
            StringHelpers.toPascalCase('my_var'));
      });

      test('camelCase is alias for toCamelCase', () {
        expect(StringHelpers.camelCase('my_var'),
            StringHelpers.toCamelCase('my_var'));
      });
    });
  });
}
