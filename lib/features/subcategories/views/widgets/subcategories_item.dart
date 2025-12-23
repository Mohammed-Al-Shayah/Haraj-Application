import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/typography.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/category_entity.dart';

class SubcategoriesItem extends StatelessWidget {
  final SubCategoryEntity subcategories;
  final bool isLast;
  final bool isPostAdFlow;

  const SubcategoriesItem({
    super.key,
    required this.subcategories,
    required this.isLast,
    this.isPostAdFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final bool isArabic = currentLanguage.startsWith('ar');
    final bool isEnglish = currentLanguage.startsWith('en');
    final arrowIcon =
        isEnglish ? AppAssets.arrowRightIcon : AppAssets.arrowLeftIcon;

    final RxBool isExpanded = false.obs;

    return GestureDetector(
      onTap: () {
        isExpanded.value = !isExpanded.value;
      },
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subcategories.title.length > 30
                      ? '${subcategories.title.substring(0, 25)}...'
                      : subcategories.title,
                  style: AppTypography.semiBold14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    '0',
                    style: AppTypography.normal14.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => Transform.rotate(
                      angle:
                          isExpanded.value
                              ? (isArabic ? -3.14 / 2 : 3.14 / 2)
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
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => AnimatedCrossFade(
              firstChild:
                  isExpanded.value
                      ? Container()
                      : (isLast
                          ? const SizedBox.shrink()
                          : Container(color: AppColors.gray300, height: 1)),
              secondChild: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children:
                          subcategories.subSubCategories.map((subSub) {
                            return InkWell(
                              onTap: () {
                                print('hiiiii');
                                Get.toNamed(
                                  isPostAdFlow
                                      ? Routes.postAdScreen
                                      : Routes.adsResultScreen,
                                  arguments: {
                                    'categoryTitle': subcategories.title,
                                    if (isPostAdFlow)
                                      'subCategoryTitle': subSub.title,
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
                                          subSub.title,
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
                            );
                          }).toList(),
                    ),
                  ),
                  if (isExpanded.value) const SizedBox(height: 16),
                  if (!isLast && !isExpanded.value)
                    Container(color: AppColors.gray300, height: 1),
                ],
              ),
              crossFadeState:
                  isExpanded.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }
}
