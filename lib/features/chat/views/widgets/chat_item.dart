import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/domain/entities/chat_entity.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/routes/routes.dart';

class ChatItem extends StatelessWidget {
  final ChatEntity chat;

  const ChatItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (chat.id == null) {
          AppSnack.error('خطأ', 'لا يوجد معرف للمحادثة');
          return;
        }
        Get.toNamed(
          Routes.chatDetailsScreen,
          arguments: {
            'chatId': chat.id,
            'chatName': chat.name,
            'otherUserId': chat.otherUserId,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                      chat.image.isNotEmpty
                          ? Image.network(
                            chat.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            width: 50,
                            height: 50,
                            color: Colors.blue,
                            child: Center(
                              child: Text(
                                chat.name.isNotEmpty
                                    ? chat.name.substring(0, 1)
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.green00CD52,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.name, style: AppTypography.semiBold14),
                  const SizedBox(height: 2),
                  Text(
                    chat.message,
                    style: AppTypography.normal14.copyWith(
                      color: AppColors.gray500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: AppTypography.normal12.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 5),
                if (chat.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        chat.unreadCount.toString(),
                        textAlign: TextAlign.center,
                        style: AppTypography.semiBold10.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
