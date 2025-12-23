import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/strings.dart';
import '../../utils/validators.dart';
import '../input_field.dart';

class AuthenticationForm extends StatelessWidget {
  final TextEditingController? nameController;
  final TextEditingController? emailController;
  final TextEditingController? phoneController;

  final bool showName;
  final bool showEmail;
  final bool showPhone;
  final bool? isResetPassword;
  final bool? isPasswordVisible;
  final RxBool isPasswordVisibleState = (false).obs;

  AuthenticationForm({
    super.key,
    this.nameController,
    this.emailController,
    this.phoneController,
    this.showName = false,
    this.showEmail = false,
    this.showPhone = false,
    this.isResetPassword = false,
    this.isPasswordVisible = false,
  }) {
    if (isPasswordVisible != null) {
      isPasswordVisibleState.value = isPasswordVisible!;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisibleState.value = !isPasswordVisibleState.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showName)
          InputField(
            labelText: AppStrings.inputFieldNameLabel,
            validator: Validators.validateName,
            hintText: AppStrings.inputFieldNameHint,
            keyboardType: TextInputType.text,
            controller: nameController,
            isPasswordVisible: isPasswordVisibleState.value,
          ),
        if (showName) const SizedBox(height: 20),
        if (showEmail)
          InputField(
            labelText: AppStrings.inputFieldEmailLabel,
            validator: Validators.validateEmail,
            hintText: AppStrings.inputFieldEmailHint,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
          ),
        if (showEmail) const SizedBox(height: 20),
        if (showPhone)
          InputField(
            labelText: AppStrings.inputFieldPhoneLabel,
            hintText: AppStrings.inputFieldPhoneLabel,
            validator: Validators.validatePhone,
            keyboardType: TextInputType.text,
            controller: phoneController,
          ),
      ],
    );
  }
}
