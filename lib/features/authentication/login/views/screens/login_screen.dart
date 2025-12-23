import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/widgets/authentication/auth_section.dart';
import '../../../../../core/theme/strings.dart';
import '../../../../../core/widgets/authentication/authentication_bar.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/authentication/or_separator.dart';
import '../../../../../core/widgets/authentication/social_media_section.dart';
import '../../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                AuthenticationBar(text: AppStrings.logIn),
                const SizedBox(height: 20),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text(AppStrings.inputFieldEmailLabel),
                        selectedColor: AppColors.secondary,
                        selected: controller.isEmailSelected.value,
                        onSelected:
                            (val) => controller.isEmailSelected.value = true,
                      ),
                      const SizedBox(width: 20),
                      ChoiceChip(
                        label: Text(AppStrings.inputFieldPhoneLabel),
                        selected: !controller.isEmailSelected.value,
                        selectedColor: AppColors.secondary,
                        onSelected:
                            (val) => controller.isEmailSelected.value = false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Obx(
                  () => Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.isEmailSelected.value
                              ? AppStrings.inputFieldEmailLabel
                              : AppStrings.inputFieldPhoneLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ).paddingSymmetric(horizontal: 3),
                        SizedBox(height: 10),
                        controller.isEmailSelected.value
                            ? TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: AppStrings.inputFieldEmailLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (!value.contains('@')) {
                                  return 'Invalid email';
                                }
                                return null;
                              },
                            )
                            : Row(
                              children: [
                                CountryCodePicker(
                                  onChanged: (country) {
                                    controller.countryCode.value =
                                        country.dialCode ?? '+967';
                                  },
                                  initialSelection: 'IL',
                                  favorite: ['+972', 'IL'],
                                  // initialSelection: 'YE',
                                  // favorite: ['+967', 'YE'],
                                  showFlag: true,
                                  showDropDownButton: true,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppStrings.inputFieldPhoneLabel,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Obx(() {
                  final loading =
                      controller.loginState.value == LoginState.loading;
                  final isActive = controller.isFormValid.value;
                  return PrimaryButton(
                    onPressed:
                        loading || !isActive ? () {} : controller.submitForm,
                    title: AppStrings.logIn,
                    showProgress: loading,
                    isActive: isActive,
                  );
                }),

                const SizedBox(height: 20),
                const OrSeparator(),
                const SizedBox(height: 20),
                const SocialMediaSection(isColumn: true),
                const SizedBox(height: 20),
                const AuthSection(isRegister: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
