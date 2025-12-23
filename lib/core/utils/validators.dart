import '../theme/strings.dart';

class Validators {
  static String? validatePublicText(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationNameRequired;
    }
    RegExp regex = RegExp(r"^[a-zA-Z\u0600-\u06FF\s]+$");

    if (!regex.hasMatch(value)) {
      return AppStrings.validationNameLettersSpaces;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationEmailRequired;
    }
    if (!RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        .hasMatch(value)) {
      return AppStrings.validationEmailValid;
    }
    return null;
  }

  static String? validatePassword(String? value, {bool isRequired = true}) {
    if (!isRequired && (value == null || value.isEmpty)) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return AppStrings.validationPasswordRequired;
    }
    if (value.length < 8) {
      return AppStrings.validationPasswordMinLength;
    }
    if (!RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$")
        .hasMatch(value)) {
      return AppStrings.validationPasswordComplexity;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    if (!RegExp(r"^(\+?[0-9]{1,3}[-. ]?([0-9]{1,3})?)?([0-9]{1,3}[-. ]?[0-9]{1,3})([0-9]{1,3})?$")
        .hasMatch(value)) {
      return "Phone number is not valid";
    }
    return null;
  }
}