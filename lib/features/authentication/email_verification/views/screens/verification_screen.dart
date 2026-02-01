import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/widgets/authentication/auth_section.dart';
import '../../../../../core/widgets/authentication/authentication_bar.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../controllers/verification_controller.dart';
import '../widgets/verification_code_input.dart';
import '../widgets/verification_message.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VerificationController controller = Get.put(VerificationController());
    final args = Get.arguments ?? {};
    final contact = (args['contact'] ?? args['mobile'] ?? '').toString();
    final isEmail = args['isEmail'] == true;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  AuthenticationBar(
                    text:
                        isEmail
                            ? AppStrings.emailVerification
                            : AppStrings.phoneVerification,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      VerificationMessage(contact: contact),
                      const SizedBox(height: 20),
                      VerificationCodeInput(otp: controller.otp),
                      const SizedBox(height: 20),
                      Obx(() {
                        final loading =
                            controller.emailVerificationState.value ==
                            EmailVerificationState.loading;
                        final isActive = controller.isFormValid.value;

                        return PrimaryButton(
                          onPressed:
                              loading || !isActive
                                  ? () {}
                                  : controller.submitForm,
                          title: AppStrings.verify,
                          showProgress: loading,
                          isActive: isActive,
                        );
                      }),
                      const SizedBox(height: 20),
                      const AuthSection(isRegister: false, resendCode: true),
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
