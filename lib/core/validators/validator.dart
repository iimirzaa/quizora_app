// validators.dart

class AppValidator {
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    }
    if (value.length < 3) {
      return "Minimum 3 characters required";
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Invalid email";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    // At least 1 lowercase, 1 uppercase, 1 number, no symbols
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]+$');

    if (!regex.hasMatch(value)) {
      return "Password must contain uppercase, lowercase, and a number (no symbols)";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return "Otp is required";
    }
    if (value.length < 6) {
      return "Minimum 6 characters required";
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return "OTP must contain only digits";
    }
    return null;
  }

  static String? quizTitle(String? value) {
    if (value == null || value.isEmpty) {
      return "Quiz Title is required";
    }
    if (value.length > 30) {
      return "Maximum 30 characters required";
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return "Only letters allowed";
    }
    return null;
  }
  static String? quizCode(String? value) {
    if (value == null || value.isEmpty) {
      return "Quiz code is required";
    }
    if (!RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(value)) {
      return "Enter only 6 characters or digits";
    }
    return null;
  }
}