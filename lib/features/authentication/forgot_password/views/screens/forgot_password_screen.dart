import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/widgets/authentication/authentication_bar.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/authentication/authentication_form.dart';
import '../../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
        Get.put(ForgotPasswordController());

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AuthenticationBar(text: AppStrings.forgotPassword),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      AuthenticationForm(
                          emailController: controller.emailController,
                          showEmail: true),
                      const SizedBox(height: 20),
                      Obx(() {
                        final loading =
                            controller.forgotPasswordState.value ==
                                ForgotPasswordState.loading;
                        final isActive = controller.isFormValid.value;
                        return PrimaryButton(
                          onPressed: loading || !isActive
                              ? () {}
                              : controller.submitForm,
                          title: AppStrings.forgotPassword,
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
