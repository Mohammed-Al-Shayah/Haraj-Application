import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../controllers/permissions_controller.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final PermissionsController controller = Get.put(PermissionsController());

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.permissionsTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.mobileNotificationPermissionText,
                          style: AppTypography.semiBold14,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    activeTrackColor: AppColors.primary,
                    value: controller.isMobileNotificationEnabled.value,
                    onChanged: (value) {
                      controller.isMobileNotificationEnabled.value = value;
                    },
                  ),
                ],
              ),
            ),

            const Divider(indent: 15, endIndent: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.messageReadPermissionText,
                        style: AppTypography.semiBold14,
                      ),
                      Switch(
                        activeTrackColor: AppColors.primary,
                        value: controller.isMessageReadEnabled.value,
                        onChanged: (value) {
                          controller.isMessageReadEnabled.value = value;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppStrings.messageReadPermissionSubText,
                    style: AppTypography.normal14,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
