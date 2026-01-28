class StringHelpers {
  static String snakeCase(String input) {
    final normalized = input
        .trim()
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return normalized.toLowerCase();
  }

  static String pascalCase(String input) {
    final parts = input.split(RegExp(r'[_\\-\\s]+'));
    return parts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1);
    }).join();
  }

  static String camelCase(String input) {
    final pascal = pascalCase(input);
    if (pascal.isEmpty) return pascal;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
