/// Basic validators for common input types.
/// For form-specific validation, use [AppValidators].
class Validators {
  static bool isEmail(String value) {
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    return regex.hasMatch(value.trim());
  }
  
  static bool isPhone(String value) {
    final regex = RegExp(r'^\+?[0-9]{10,14}$');
    return regex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''));
  }
  
  static bool isUrl(String value) {
    return Uri.tryParse(value)?.hasAbsolutePath ?? false;
  }
  
  static bool isStrongPassword(String value) {
    // At least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(value);
  }
}
