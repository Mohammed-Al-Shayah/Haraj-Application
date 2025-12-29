import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/assets.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/theme/typography.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../filters/models/enums.dart';

class SubcategoriesItem extends StatelessWidget {
  final SubCategoryEntity subcategories;
  final bool isLast;
  final bool isPostAdFlow;
  final String? parentCategoryName;
  final String? parentCategoryNameEn;
  final AdType? parentAdType;
  final int? parentCategoryId;

  const SubcategoriesItem({
    super.key,
    required this.subcategories,
    required this.isLast,
    this.isPostAdFlow = false,
    this.parentCategoryName,
    this.parentCategoryNameEn,
    this.parentAdType,
    this.parentCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguage =
        LocalizeAndTranslate.getLanguageCode().toLowerCase();
    final bool isArabic = currentLanguage.startsWith('ar');
    final bool isEnglish = currentLanguage.startsWith('en');
    final arrowIcon =
        isEnglish ? AppAssets.arrowRightIcon : AppAssets.arrowLeftIcon;

    final RxBool isExpanded = false.obs;
    final String displayTitle =
        isEnglish && (subcategories.titleEn?.isNotEmpty ?? false)
            ? subcategories.titleEn!
            : subcategories.title;

    return GestureDetector(
      onTap: () {
        final hasChildren = subcategories.subSubCategories.isNotEmpty;
        if (!hasChildren) {
          if (isPostAdFlow) {
            final realEstateType =
                parentAdType == AdType.real_estates
                    ? _resolveRealEstateType(
                      subcategories.titleEn ?? subcategories.title,
                    )
                    : null;
            Get.toNamed(
              Routes.postAdScreen,
              arguments: {
                'categoryTitle': displayTitle,
                'categoryId': subcategories.id,
                'subCategoryId': subcategories.id,
                'adType': parentAdType,
                if (realEstateType != null) 'realEstateType': realEstateType,
              },
            );
          } else {
            final realEstateType =
                parentAdType == AdType.real_estates
                    ? _resolveRealEstateType(
                      subcategories.titleEn ?? subcategories.title,
                    )
                    : null;
            Get.toNamed(
              Routes.adsResultScreen,
              arguments: {
                'categoryTitle': displayTitle,
                'categoryId': parentCategoryId ?? subcategories.id,
                'subCategoryId': subcategories.id,
                'adType': parentAdType,
                if (realEstateType != null) 'realEstateType': realEstateType,
              },
            );
          }
        } else {
          isExpanded.value = !isExpanded.value;
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayTitle.length > 30
                      ? '${displayTitle.substring(0, 25)}...'
                      : displayTitle,
                  style: AppTypography.semiBold14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    subcategories.adsCount.toString(),
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
                            final subSubTitle =
                                isEnglish &&
                                        (subSub.titleEn?.isNotEmpty ?? false)
                                    ? subSub.titleEn!
                                    : subSub.title;

                            return InkWell(
                              onTap: () {
                                Get.toNamed(
                                  isPostAdFlow
                                      ? Routes.postAdScreen
                                      : Routes.adsResultScreen,
                                  arguments: {
                                    'categoryTitle': displayTitle,
                                    'adType': parentAdType,
                                    if (parentAdType ==
                                        AdType.real_estates) ...{
                                      'realEstateType': _resolveRealEstateType(
                                        subSub.titleEn ?? subSub.title,
                                      ),
                                    },
                                    if (!isPostAdFlow) ...{
                                      'categoryId':
                                          parentCategoryId ?? subcategories.id,
                                      'subCategoryId': subcategories.id,
                                      'subSubCategoryId': subSub.id,
                                    },
                                    if (isPostAdFlow) ...{
                                      'subCategoryTitle': subSubTitle,
                                      'subSubCategoryId': subSub.id,
                                      'categoryId': subSub.id,
                                      'subCategoryId': subcategories.id,
                                    },
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
                                          subSubTitle,
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

  RealEstateType? _resolveRealEstateType(String title) {
    final normalized =
        title.toLowerCase().replaceAll(RegExp(r'[_-]+'), ' ').trim();

    // Shops (commercial stores)
    if (normalized.contains('shop') ||
        normalized.contains('store') ||
        normalized.contains('commercial') ||
        normalized.contains('محل') ||
        normalized.contains('محلات تجارية') ||
        normalized.contains('تجاري')) {
      return RealEstateType.shops;
    }
    if (normalized.contains('house')) return RealEstateType.houses;
    if (normalized.contains('villa')) return RealEstateType.villas;
    if (normalized.contains('land')) return RealEstateType.lands;
    if (normalized.contains('building')) return RealEstateType.buildings;
    if (normalized.contains('apart')) return RealEstateType.apartments;
    return null;
  }
}
