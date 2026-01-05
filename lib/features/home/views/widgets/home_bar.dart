import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color.dart';

class HomeBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeBar({super.key});

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
                  AppAssets.userIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              IconButton(
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
              IconButton(
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

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
