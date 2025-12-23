import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/widgets/authentication/authentication_bar.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/authentication/authentication_form.dart';
import '../../controllers/reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResetPasswordController controller =
        Get.put(ResetPasswordController());

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AuthenticationBar(text: AppStrings.resetPassword),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      AuthenticationForm(
                          emailController: controller.emailController,
                          phoneController: controller.passwordController,
                          showEmail: true,
                          showPhone: true,
                          isResetPassword: true),
                      const SizedBox(height: 20),
                      Obx(() {
                        final loading = controller.resetPasswordState.value ==
                            ResetPasswordState.loading;
                        final isActive = controller.isFormValid.value;
                        return PrimaryButton(
                          onPressed: loading || !isActive
                              ? () {}
                              : controller.submitForm,
                          title: AppStrings.resetPassword,
                          showProgress: loading,
                          isActive: isActive,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
