import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color.dart';
import '../../../chat/controllers/chat_controller.dart';
import '../../../support/controllers/support_controller.dart';

class HomeBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeBar({
    super.key,
    required this.chatController,
    required this.supportController,
  });

  final ChatController chatController;
  final SupportController supportController;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      centerTitle: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.toNamed(Routes.myAccountScreen),
                icon: SvgPicture.asset(
                  AppAssets.userSvgIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              _buildBadgeButton(
                badge: chatController.notificationBadge,
                onPressed: () => Get.toNamed(Routes.chatsScreen),
                icon: SvgPicture.asset(
                  AppAssets.messageIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          Image.asset(AppAssets.harajAdenLogo, height: 40),
          Row(
            children: [
              _buildBadgeButton(
                badge: supportController.supportNotificationBadge,
                onPressed: () => Get.toNamed(Routes.supportScreen),
                icon: SvgPicture.asset(
                  AppAssets.headphoneIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: SvgPicture.asset(
                  AppAssets.menuIcon,
                  width: 32,
                  height: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeButton({
    required RxInt badge,
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return Obx(() {
      final count = badge.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(onPressed: onPressed, icon: icon),
          if (count > 0)
            Positioned(
              right: 2,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
