import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isLast;
  final RxBool isExpanded = false.obs;
  final bool isPostAdFlow;

  CategoryItem({
    super.key,
    required this.category,
    required this.isLast,
    required this.isPostAdFlow,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final arrowIcon =
        currentLanguage == 'en'
            ? AppAssets.arrowRightIcon
            : AppAssets.arrowLeftIcon;
    final imageUrl =
        category.image.startsWith('http')
            ? category.image
            : '${ApiEndpoints.imageUrl}${category.image}';

    final displayName =
        currentLanguage == 'en' && category.nameEn.isNotEmpty
            ? category.nameEn
            : category.name;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Scaffold.maybeOf(context)?.isDrawerOpen == true
            ? Navigator.of(context).pop()
            : null;
        Get.toNamed(
          Routes.subcategoriesScreen,
          arguments: {'category': category, 'isPostAdFlow': isPostAdFlow},
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(imageUrl: imageUrl, height: 50, width: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      displayName,
                      style: AppTypography.bold16,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                    const SizedBox(height: 8),
                    AutoSizeText(
                      displayName,
                      style: AppTypography.normal14.copyWith(
                        color: AppColors.gray500,
                      ),
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                return Transform.rotate(
                  angle:
                      isExpanded.value
                          ? (currentLanguage == 'ar' ? -3.14 / 2 : 3.14 / 2)
                          : 0,
                  child: SvgPicture.asset(
                    arrowIcon,
                    height: 20,
                    width: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 16),
          Obx(() {
            return AnimatedCrossFade(
              firstChild:
                  isLast
                      ? const SizedBox.shrink()
                      : Container(color: AppColors.gray300, height: 1),
              secondChild: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children:
                          category.children
                              .map(
                                (sub) => InkWell(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.postAdScreen,
                                      arguments: {
                                        'categoryTitle':
                                            currentLanguage == 'en'
                                                ? sub.nameEn
                                                : sub.name,
                                      },
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  splashColor: AppColors.primary.withAlpha(25),
                                  highlightColor: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: AppColors.gray300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 1),
                                          Expanded(
                                            child: Text(
                                              currentLanguage == 'en'
                                                  ? sub.nameEn
                                                  : sub.name,
                                              style: AppTypography.normal14
                                                  .copyWith(
                                                    color: AppColors.gray800,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  if (isLast) const SizedBox(height: 16),
                ],
              ),
              crossFadeState:
                  isExpanded.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            );
          }),
        ],
      ),
    );
  }
}
