/// Form field validators with localization-ready error messages.
/// 
/// Usage:
/// ```dart
/// TextFormField(
///   validator: AppValidators.email,
/// )
/// ```
class AppValidators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password with minimum requirements
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
  
  /// Validates strong password (uppercase, lowercase, number, special char)
  static String? strongPassword(String? value) {
    final baseError = password(value);
    if (baseError != null) return baseError;
    
    if (!RegExp(r'[A-Z]').hasMatch(value!)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[@$!%*?&]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
  
  /// Validates password confirmation matches
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Generic required field validator
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }
  
  /// Validates minimum length
  static String? Function(String?) minLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.length < length) {
        return '${fieldName ?? 'Field'} must be at least $length characters';
      }
      return null;
    };
  }
  
  /// Validates maximum length
  static String? Function(String?) maxLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value != null && value.length > length) {
        return '${fieldName ?? 'Field'} must be at most $length characters';
      }
      return null;
    };
  }
  
  /// Validates phone number format
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-()]'), '');
    if (!RegExp(r'^\+?[0-9]{10,14}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
  
  /// Combines multiple validators
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
