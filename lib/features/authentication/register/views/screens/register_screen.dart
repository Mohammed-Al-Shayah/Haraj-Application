import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/authentication/or_separator.dart';
import '../../../../../core/widgets/authentication/social_media_section.dart';
import '../../controllers/register_controller.dart';
import '../../../../../core/widgets/authentication/authentication_bar.dart';
import '../../../../../core/widgets/authentication/authentication_form.dart';
import '../../../../../core/widgets/authentication/auth_section.dart';
import '../widgets/terms_privacy_section.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AuthenticationBar(text: AppStrings.register),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const SocialMediaSection(isColumn: true),
                      const SizedBox(height: 20),
                      const OrSeparator(),
                      const SizedBox(height: 20),
                      AuthenticationForm(
                        nameController: controller.nameController,
                        emailController: controller.emailController,
                        phoneController: controller.phoneController,
                        showName: true,
                        showEmail: true,
                        showPhone: true,
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        final loading =
                            controller.registrationState.value ==
                            RegistrationState.loading;
                        final isActive = controller.isFormValid.value;
                        return PrimaryButton(
                          onPressed:
                              loading || !isActive
                                  ? () {}
                                  : controller.submitForm,
                          title: AppStrings.createAccountButtonText,
                          showProgress: loading,
                          isActive: isActive,
                        );
                      }),
                      const SizedBox(height: 20),
                      const TermsPrivacySection(),
                      const SizedBox(height: 20),
                      const AuthSection(isRegister: true),
                      const SizedBox(height: 40),
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
