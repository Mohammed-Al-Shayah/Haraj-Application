import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/features/my_account/controllers/my_account_controller.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';

class MyProfileScreen extends StatelessWidget {
  MyProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final MyAccountController controller =
      Get.isRegistered<MyAccountController>()
          ? Get.find<MyAccountController>()
          : Get.put(MyAccountController());

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.myProfileTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _myProfileHeader(),
            _editableContentInner(),
          ],
        ),
      ),
    );
  }

  Widget _editableContentInner() {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              InputField(
                controller: controller.nameController,
                labelText: AppStrings.nameText,
                validator: Validators.validateName,
                hintText: AppStrings.yourNameText,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              InputField(
                controller: controller.emailController,
                labelText: AppStrings.emailText,
                validator: (value) =>
                    (value == null || value.isEmpty)
                        ? null
                        : Validators.validateEmail(value),
                hintText: AppStrings.inputFieldEmailHint,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              InputField(
                controller: controller.phoneController,
                labelText: AppStrings.inputFieldPhoneLabel,
                validator: (value) =>
                    (value == null || value.isEmpty)
                        ? null
                        : Validators.validatePhone(value),
                hintText: AppStrings.inputFieldPhoneLabel,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: MediaQuery.of(Get.context!).size.height * 0.2),
              Obx(
                () => PrimaryButton(
                  onPressed: () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    controller.saveProfile();
                  },
                  title: AppStrings.saveButtonText,
                  showProgress: controller.isUpdating.value,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _myProfileHeader() {
    return Stack(
      children: [
        Container(width: double.infinity, height: 80, color: AppColors.primary),
        Card(
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://i.pinimg.com/736x/8c/6d/db/8c6ddb5fe6600fcc4b183cb2ee228eb7.jpg',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.editIcon,
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.userName.value,
                    style: AppTypography.semiBold18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.userEmail.value,
                    style: AppTypography.normal14,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
