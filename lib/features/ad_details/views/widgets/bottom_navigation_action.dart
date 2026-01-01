import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import '../../../../core/utils/constants.dart';

class BottomNavigationAction extends StatelessWidget {
  BottomNavigationAction({super.key});

  final AdDetailsController controller = Get.find<AdDetailsController>();

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
              onPressed: () => _openChatWithOwner(),
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
    final ad = controller.ad.value;
    final ownerName = ad?.ownerName ?? 'Owner Name';
    final phone = ad?.ownerPhone ?? AppConstants.ownerPhoneNumber;
    if (phone.isEmpty) {
      AppSnack.error('خطأ', 'رقم صاحب الإعلان غير متوفر');
      return;
    }

    Get.bottomSheet(
      CallOwnerBottomSheet(phoneNumber: phone, ownerName: ownerName),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> _openChatWithOwner() async {
    final ad = controller.ad.value;
    final ownerId = ad?.ownerId;
    final ownerName = ad?.ownerName ?? 'Owner';

    if (ownerId == null) {
      AppSnack.error('خطأ', 'معرف صاحب الإعلان غير متوفر');
      return;
    }

    final currentUserId = await getUserIdFromPrefs();
    if (currentUserId == null) {
      AppSnack.error('خطأ', 'سجّل الدخول أولاً');
      return;
    }

    try {
      final api = ApiClient(client: Dio());
      final res = await api.get(
        ApiEndpoints.chatList,
        queryParams: {'userId': currentUserId},
      );

      final data = res['data'];
      if (data is! List) {
        AppSnack.error('خطأ', 'لا توجد محادثات متاحة');
        return;
      }

      int? chatId;
      String chatTitle = ownerName;

      for (final item in data) {
        if (item is! Map) continue;
        final members = item['members'];
        if (members is List) {
          for (final m in members) {
            if (m is! Map) continue;
            final uid = m['user_id'] ?? m['userId'];
            final uidInt =
                uid is num ? uid.toInt() : int.tryParse(uid?.toString() ?? '');
            if (uidInt == ownerId) {
              final cid = item['id'] ?? item['chat_id'];
              if (cid is num) {
                chatId = cid.toInt();
                final user = m['users'];
                if (user is Map && user['name'] != null) {
                  chatTitle = user['name'].toString();
                }
              }
            }
          }
        }
        if (chatId != null) break;
      }

      if (chatId == null) {
        AppSnack.error('تنبيه', 'لا توجد محادثة سابقة مع صاحب الإعلان');
        return;
      }

      Get.toNamed(
        Routes.chatDetailsScreen,
        arguments: {
          'chatId': chatId,
          'chatName': chatTitle,
          'otherUserId': ownerId,
        },
      );
    } catch (_) {
      AppSnack.error('خطأ', 'تعذر فتح المحادثة');
    }
  }
}

class CallOwnerBottomSheet extends StatelessWidget {
  final String phoneNumber;
  final String ownerName;

  const CallOwnerBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    final displayNumber =
        phoneNumber.trim().startsWith('+')
            ? phoneNumber.trim()
            : '+${phoneNumber.trim()}';

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
                  ownerName.isEmpty ? 'Owner Name' : ownerName,
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
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PrimaryButton(
                        onPressed:
                            () => PhoneCallService.makePhoneCall(displayNumber),
                        title: displayNumber,
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

class PhoneCallService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    var status = await Permission.phone.status;

    if (status.isGranted) {
      await _launchPhoneCall(phoneNumber);
    } else if (status.isDenied) {
      if (await Permission.phone.request().isGranted) {
        await _launchPhoneCall(phoneNumber);
      } else {
        AppSnack.error(
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
      AppSnack.error('Error', 'Could not launch phone call');
    }
  }
}
