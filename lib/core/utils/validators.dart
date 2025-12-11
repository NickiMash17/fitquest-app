/// Input validation and sanitization utilities
/// Includes security measures to prevent injection attacks
class Validators {
  /// Sanitize input to remove potentially dangerous characters
  /// Removes HTML tags, script tags, and special characters that could be used for injection
  static String? sanitizeInput(String? input) {
    if (input == null) return null;
    
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'[<>"\'']'), '') // Remove HTML/script tags
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control characters
        .trim();
  }

  /// Validate and sanitize email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Trim whitespace
    final trimmed = value.trim();
    
    // Basic email format validation (don't sanitize emails as they may contain valid special chars)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email';
    }
    
    // Only check for obviously dangerous characters
    if (trimmed.contains('<') || trimmed.contains('>') || trimmed.contains('"')) {
      return 'Email contains invalid characters';
    }
    
    return null;
  }

  /// Validate password for login (only checks if not empty)
  /// For signup, use passwordStrength instead
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  /// Validate password strength for signup
  /// Requirements: At least 8 characters, 1 uppercase, 1 lowercase, 1 number
  static String? passwordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be no more than $maxLength characters';
    }
    return null;
  }

  /// Validate numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;
    
    if (value != null && double.parse(value) <= 0) {
      return '${fieldName ?? 'This field'} must be greater than zero';
    }
    return null;
  }
}

