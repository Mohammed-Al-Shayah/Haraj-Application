import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/widgets/primary_button.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
      AppSnack.error('Error', 'Phone number is not available.');
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
    final ownerName =
        (ad?.ownerName ?? '').trim().isEmpty ? 'Owner' : ad!.ownerName!.trim();

    if (ownerId == null) {
      AppSnack.error('Error', 'Owner info is not available.');
      return;
    }

    final currentUserId = await getUserIdFromPrefs();
    if (currentUserId == null) {
      AppSnack.error('Error', 'Please log in to start a chat.');
      return;
    }

    try {
      final chatData =
          await _findExistingChat(
            currentUserId: currentUserId,
            ownerId: ownerId,
            fallbackName: ownerName,
          ) ??
          await _createChatWithOwner(
            currentUserId: currentUserId,
            ownerId: ownerId,
            fallbackName: ownerName,
            adId: ad?.id,
          );

      if (chatData == null) {
        AppSnack.error('Error', 'Unable to open chat right now.');
        return;
      }

      Get.toNamed(
        Routes.chatDetailsScreen,
        arguments: {
          'chatId': chatData.chatId,
          'chatName': chatData.chatTitle,
          'otherUserId': chatData.otherUserId,
        },
      );
    } catch (_) {
      AppSnack.error('Error', 'Failed to open chat.');
    }
  }

  Future<_ChatLaunchData?> _findExistingChat({
    required int currentUserId,
    required int ownerId,
    required String fallbackName,
  }) async {
    final api = ApiClient(client: Dio());
    final res = await api.get(
      ApiEndpoints.chatList,
      queryParams: {'userId': currentUserId, 'user_id': currentUserId},
    );

    final data = _extractList(res);
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final parsed = _parseChat(item, ownerId, fallbackName);
      if (parsed != null) return parsed;
    }
    return null;
  }

  Future<_ChatLaunchData?> _createChatWithOwner({
    required int currentUserId,
    required int ownerId,
    required String fallbackName,
    int? adId,
  }) async {
    final api = ApiClient(client: Dio());
    final payload = {
      'userId': currentUserId,
      'senderId': currentUserId,
      'receiverId': ownerId,
      'receiver_id': ownerId,
      'sender_id': currentUserId,
      'user_id': currentUserId,
      if (adId != null) ...{'adId': adId, 'ad_id': adId},
    };

    final res = await api.post(ApiEndpoints.chats, data: payload);
    final map = _extractDataMap(res);
    if (map == null) return null;

    return _parseChat(map, ownerId, fallbackName) ??
        _fallbackChat(map, ownerId, fallbackName);
  }

  List<dynamic> _extractList(dynamic res) {
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
    }
    if (res is List) return res;
    return const [];
  }

  Map<String, dynamic>? _extractDataMap(dynamic res) {
    if (res is Map<String, dynamic>) {
      if (res['data'] is Map<String, dynamic>) {
        return res['data'] as Map<String, dynamic>;
      }
      if (res['data'] is List && (res['data'] as List).isNotEmpty) {
        final first = (res['data'] as List).first;
        if (first is Map<String, dynamic>) return first;
      }
      if (res['chat'] is Map<String, dynamic>) {
        return res['chat'] as Map<String, dynamic>;
      }
      if (res['result'] is Map<String, dynamic>) {
        return res['result'] as Map<String, dynamic>;
      }
      final nestedData = res['data'];
      if (nestedData is Map && nestedData['chat'] is Map<String, dynamic>) {
        return nestedData['chat'] as Map<String, dynamic>;
      }
      return res;
    }
    return null;
  }

  _ChatLaunchData? _parseChat(
    Map<String, dynamic> item,
    int ownerId,
    String fallbackName,
  ) {
    final members = item['members'];
    int? chatId;
    String chatTitle = fallbackName;
    int otherUserId = ownerId;

    if (members is List) {
      for (final member in members) {
        if (member is! Map) continue;
        final uid = _toInt(member['user_id'] ?? member['userId']);
        if (uid == ownerId) {
          otherUserId = uid ?? ownerId;
          chatId = _toInt(item['id'] ?? item['chat_id'] ?? item['chatId']);
          final user = member['users'];
          if (user is Map && (user['name']?.toString().isNotEmpty ?? false)) {
            chatTitle = user['name'].toString();
          }
          break;
        }
      }
    }

    // fallback if members missing
    chatId ??= _toInt(item['id'] ?? item['chat_id'] ?? item['chatId']);
    final title = _extractUserName(item) ?? chatTitle;
    final other =
        _toInt(
          item['other_user_id'] ??
              item['receiver_id'] ??
              item['receiverId'] ??
              item['user_id'] ??
              item['userId'],
        ) ??
        otherUserId;

    if (chatId == null) return null;
    return _ChatLaunchData(
      chatId: chatId,
      chatTitle: title,
      otherUserId: other,
    );
  }

  _ChatLaunchData? _fallbackChat(
    Map<String, dynamic> item,
    int ownerId,
    String fallbackName,
  ) {
    final chatId = _toInt(item['id'] ?? item['chat_id'] ?? item['chatId']);
    if (chatId == null) return null;
    final title = _extractUserName(item) ?? fallbackName;
    final other =
        _toInt(
          item['other_user_id'] ??
              item['receiver_id'] ??
              item['receiverId'] ??
              item['user_id'] ??
              item['userId'],
        ) ??
        ownerId;
    return _ChatLaunchData(
      chatId: chatId,
      chatTitle: title,
      otherUserId: other,
    );
  }

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? _extractUserName(Map<String, dynamic> data) {
    final user = data['user'] ?? data['owner'] ?? data['receiver'];
    if (user is Map) {
      final name = user['name'] ?? user['user_name'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }
    final directName = data['name'] ?? data['user_name'];
    if (directName != null && directName.toString().trim().isNotEmpty) {
      return directName.toString();
    }
    return null;
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

class _ChatLaunchData {
  final int chatId;
  final String chatTitle;
  final int otherUserId;

  _ChatLaunchData({
    required this.chatId,
    required this.chatTitle,
    required this.otherUserId,
  });
}
