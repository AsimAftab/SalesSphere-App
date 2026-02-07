/// Helper class for common text field validations
class FieldValidators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  // Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Phone number validation (basic)
  static String? validatePhone(String? value, {int minLength = 10}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]+$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter only numbers';
    }

    if (value.length < minLength) {
      return 'Phone number must be at least $minLength digits';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  // Min/Max length validation
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }

    return null;
  }

  // Indian PAN validation
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN is required';
    }

    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

    if (!panRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid PAN number';
    }

    return null;
  }

  // GST number validation (India)
  static String? validateGST(String? value) {
    if (value == null || value.isEmpty) {
      return 'GST number is required';
    }

    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );

    if (!gstRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid GST number';
    }

    return null;
  }

  // Match validation (e.g., confirm password)
  static String? validateMatch(
    String? value,
    String? matchValue, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value != matchValue) {
      return '${fieldName ?? 'Fields'} do not match';
    }

    return null;
  }

  // Age validation (from date of birth)
  static String? validateAge(DateTime? dateOfBirth, {int minAge = 18}) {
    if (dateOfBirth == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    return null;
  }

  // Custom regex validation
  static String? validateRegex(
    String? value,
    String pattern,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}

/// Example usage with CustomTextField:
///
/// CustomTextField(
///   hintText: 'Email Address',
///   controller: emailController,
///   validator: FieldValidators.validateEmail,
/// )
///
/// Or combine multiple validators:
///
/// CustomTextField(
///   hintText: 'Password',
///   controller: passwordController,
///   validator: FieldValidators.combine([
///     (value) => FieldValidators.validateRequired(value, fieldName: 'Password'),
///     FieldValidators.validateStrongPassword,
///   ]),
/// )
