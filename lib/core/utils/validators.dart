/// Static validation helpers. Return an error string on failure, null on pass.
/// Used in forms before submitting to the API.
class Validators {
  Validators._();

  /// Non-empty check. [field] is used in the error message.
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  /// 10-digit phone number.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Employee ID must contain an underscore (format: NAME_001).
  static String? employeeId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Employee ID is required';
    if (!value.trim().contains('_')) {
      return 'Employee ID must follow format NAME_001';
    }
    return null;
  }

  /// Company ID: no spaces, no empty.
  static String? companyId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Company ID is required';
    if (value.trim().contains(' ')) return 'Company ID must not contain spaces';
    return null;
  }

  /// 6-digit OTP.
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter the 6-digit OTP';
    }
    return null;
  }
}
