import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import '../../../../core/utils/constants.dart';

/// Main widget container (Row with buttons)
class BottomNavigationAction extends StatelessWidget {
  const BottomNavigationAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              onPressed: () => _showOwnerCallSheet(),
              title: AppStrings.callButtonText,
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              minimumSize: const Size(0, 50),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryButton(
              onPressed: () => Get.toNamed(Routes.chatDetailsScreen),
              title: AppStrings.sendMessageButtonText,
              backgroundColor: AppColors.secondary,
              textColor: AppColors.black75,
              minimumSize: const Size(0, 50),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  void _showOwnerCallSheet() {
    Get.bottomSheet(
      const CallOwnerBottomSheet(phoneNumber: AppConstants.ownerPhoneNumber),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

/// Bottom sheet content widget (owner name, mobile, call button)
class CallOwnerBottomSheet extends StatelessWidget {
  final String phoneNumber;

  const CallOwnerBottomSheet({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: SvgPicture.asset(AppAssets.bottomSheetIndicatorIcon)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner Name',
                  style: AppTypography.bold20.copyWith(
                    color: AppColors.black75,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mobile',
                      style: AppTypography.normal18.copyWith(
                        color: AppColors.black75,
                        fontSize: 16,
                      ),
                    ),
                    PrimaryButton(
                      onPressed:
                          () => PhoneCallService.makePhoneCall(phoneNumber),
                      title: phoneNumber,
                      backgroundColor: AppColors.green00CD52,
                      textColor: AppColors.white,
                      minimumSize: const Size(180, 40),
                      borderRadius: BorderRadius.circular(10),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      elevation: 0,
                      showProgress: false,
                      leadingIcon: AppAssets.callIcon,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone call logic separated into a service/helper class
class PhoneCallService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    var status = await Permission.phone.status;

    if (status.isGranted) {
      await _launchPhoneCall(phoneNumber);
    } else if (status.isDenied) {
      if (await Permission.phone.request().isGranted) {
        await _launchPhoneCall(phoneNumber);
      } else {
        Get.snackbar(
          'Permission Denied',
          'Permission not granted to make phone calls',
        );
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  static Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch phone call');
    }
  }
}
