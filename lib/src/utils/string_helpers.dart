class StringHelpers {
  /// Converts a string to `snake_case`.
  /// Handles camelCase, spaces, hyphens and removes non-alphanumeric characters
  /// (except underscore).
  static String snakeCase(String input) {
    var s = input.trim();
    if (s.isEmpty) return '';

    // Insert underscore between lower->upper transitions (camelCase -> camel_case)
    s = s.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m[1]}_${m[2]}',
    );

    // Replace spaces and hyphens with underscore
    s = s.replaceAll(RegExp(r'[\s\-]+'), '_');

    // Remove any characters that are not letters, numbers or underscore
    s = s.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');

    return s.toLowerCase();
  }

  /// Convert to PascalCase (remove underscores/hyphens and capitalize each word)
  /// Examples:
  ///   profile_quotation -> ProfileQuotation
  ///   user-profile -> UserProfile
  ///   my_awesome_feature -> MyAwesomeFeature
  static String toPascalCase(String input) {
    if (input.isEmpty) return input;

    final words = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => _capitalizeFirst(word))
        .toList();

    return words.join('');
  }

  /// Simple capitalize first letter (legacy method, kept for compatibility)
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Convert to snake_case (for file names)
  /// Examples:
  ///   ProfileQuotation -> profile_quotation
  ///   MyAwesomeFeature -> my_awesome_feature
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '')
        .toLowerCase();
  }

  /// Convert to camelCase (for variable names)
  /// Examples:
  ///   profile_quotation -> profileQuotation
  ///   user-profile -> userProfile
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    final pascal = toPascalCase(input);
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Capitalize first letter of a word
  static String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Get display name (human-readable with spaces)
  /// Examples:
  ///   profile_quotation -> Profile Quotation
  ///   user-profile -> User Profile
  static String toDisplayName(String input) {
    if (input.isEmpty) return input;

    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]'), ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => _capitalizeFirst(word))
        .join(' ');
  }

  /// Remove all non-alphanumeric characters
  static String removeSpecialChars(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  /// Check if string is in snake_case format
  static bool isSnakeCase(String input) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(input);
  }

  /// Check if string is in PascalCase format
  static bool isPascalCase(String input) {
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(input);
  }

  static String pascalCase(String input) => toPascalCase(input);

  static String camelCase(String input) => toCamelCase(input);
}
