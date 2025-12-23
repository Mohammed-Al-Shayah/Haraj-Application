import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../theme/assets.dart';
import '../theme/color.dart';
import '../theme/typography.dart';

class MainBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool menu;
  final List<Widget>? customActions;

  const MainBar({
    super.key,
    required this.title,
    this.scaffoldKey,
    this.menu = false,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final bool isArabic = currentLanguage.startsWith('ar');
    final arrowIcon = isArabic
        ? AppAssets.arrowRightIcon
        : AppAssets.arrowLeftIcon;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    AppTypography.semiBold18.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        leading: Padding(
          padding: isArabic
              ? const EdgeInsets.only(right: 16)
              : const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: SvgPicture.asset(
              arrowIcon,
              width: 16,
              height: 32,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: menu
            ? [
          Padding(
            padding: currentLanguage == 'ar'
                ? const EdgeInsets.only(left: 16)
                : const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => scaffoldKey?.currentState?.openDrawer(),
              icon: SvgPicture.asset(
                AppAssets.menuIcon,
                width: 32,
                height: 32,
              ),
            ),
          ),
        ]
            : (customActions ?? []),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
