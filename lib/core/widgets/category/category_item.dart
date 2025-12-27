import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/data/datasources/categories_remote_datasource.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/assets.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';

import 'package:haraj_adan_app/features/home/models/category.model.dart';
import 'package:haraj_adan_app/features/filters/models/enums.dart';

import 'package:haraj_adan_app/data/repositories/categories_repository_impl.dart';
import 'package:haraj_adan_app/features/home/controllers/category_leaf_controller.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isLast;
  final bool isPostAdFlow;

  /// ✅ النوع اللي جاي من الأب (مثلاً: عقارات => real_estates)
  final AdType? inheritedAdType;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isLast,
    required this.isPostAdFlow,
    this.inheritedAdType,
  });

  @override
  Widget build(BuildContext context) {
    final String currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final String arrowIcon =
        currentLanguage == 'en'
            ? AppAssets.arrowRightIcon
            : AppAssets.arrowLeftIcon;

    final String imageUrl =
        category.image.startsWith('http')
            ? category.image
            : '${ApiEndpoints.imageUrl}${category.image}';

    final String displayName =
        currentLanguage == 'en' && category.nameEn.isNotEmpty
            ? category.nameEn
            : category.name;

    final AdType? adType = inheritedAdType ?? _resolveAdType(category);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await _onTapCategory(
          context: context,
          category: category,
          displayName: displayName,
          adType: adType,
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
              SvgPicture.asset(
                arrowIcon,
                height: 20,
                width: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isLast) Container(color: AppColors.gray300, height: 1),
        ],
      ),
    );
  }

  Future<void> _onTapCategory({
    required BuildContext context,
    required CategoryModel category,
    required String displayName,
    required AdType? adType,
  }) async {
    // اغلاق drawer لو مفتوح
    if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }

    // ✅ Browse flow: زي ما هو
    if (!isPostAdFlow) {
      Get.toNamed(
        Routes.subcategoriesScreen,
        arguments: {
          'category': category,
          'isPostAdFlow': false,
          'adType': adType,
        },
      );
      return;
    }

    // ✅ PostAd flow:
    // 1) لو local عنده children => افتح subcategories
    if (category.children.isNotEmpty) {
      Get.toNamed(
        Routes.subcategoriesScreen,
        arguments: {
          'category': category,
          'isPostAdFlow': true,
          'adType': adType,
        },
      );
      return;
    }

    // 2) local leaf => ✅ VERIFY from server (مطلب العميل)
    final CategoryModel verified = await _verifyLeafFromServer(category);

    // لو السيرفر قال إن إلها children => ممنوع PostAd مباشرة
    if (verified.children.isNotEmpty) {
      Get.toNamed(
        Routes.subcategoriesScreen,
        arguments: {
          'category': verified,
          'isPostAdFlow': true,
          'adType': adType,
        },
      );
      return;
    }

    // 3) server leaf => افتح PostAd
    Get.toNamed(
      Routes.postAdScreen,
      arguments: {
        'category': verified,
        'categoryTitle': displayName,
        'categoryId': verified.id,
        'adType': adType,
        'realEstateType':
            adType == AdType.real_estates
                ? _mapRealEstateType(displayName)
                : null,
      },
    );
  }

  Future<CategoryModel> _verifyLeafFromServer(CategoryModel category) async {
    // init leaf controller once
    final CategoryLeafController leafCtrl = Get.put(
      CategoryLeafController(
        repo: CategoriesRepositoryImpl(
          CategoriesRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
      permanent: true,
    );

    CategoryModel result = category;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final fresh = await leafCtrl.fetchFreshCategory(category.id);
      if (fresh != null) {
        result = fresh;
      }
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }

    return result;
  }

  RealEstateType _mapRealEstateType(String name) {
    final String n = name.toLowerCase();

    if (n.contains('بيوت') ||
        n.contains('بيت') ||
        n.contains('منازل') ||
        n.contains('منزل') ||
        n.contains('house')) {
      return RealEstateType.houses;
    }

    if (n.contains('ارض') ||
        n.contains('أراضي') ||
        n.contains('اراضي') ||
        n.contains('land')) {
      return RealEstateType.lands;
    }

    if (n.contains('فيلا') ||
        n.contains('فلل') ||
        n.contains('فلة') ||
        n.contains('villa')) {
      return RealEstateType.villas;
    }

    if (n.contains('شقة') || n.contains('شقق') || n.contains('apartment')) {
      return RealEstateType.apartments;
    }

    if (n.contains('عمارة') ||
        n.contains('عمارات') ||
        n.contains('مباني') ||
        n.contains('building')) {
      return RealEstateType.buildings;
    }

    return RealEstateType.apartments;
  }

  AdType? _resolveAdType(CategoryModel category) {
    final String normalized = '${category.name} ${category.nameEn}'
        .toLowerCase()
        .replaceAll('_', ' ');

    if (normalized.contains('real estate') ||
        normalized.contains('realestate') ||
        normalized.contains('real_estate') ||
        normalized.contains('عقار') ||
        normalized.contains('عقارات') ||
        normalized.contains('بيت') ||
        normalized.contains('بيوت') ||
        normalized.contains('منزل') ||
        normalized.contains('منازل') ||
        normalized.contains('شقة') ||
        normalized.contains('شقق') ||
        normalized.contains('فيلا') ||
        normalized.contains('فلل') ||
        normalized.contains('فلة') ||
        normalized.contains('ارض') ||
        normalized.contains('اراضي') ||
        normalized.contains('أراضي') ||
        normalized.contains('building') ||
        normalized.contains('house')) {
      return AdType.real_estates;
    }

    if (normalized.contains('vehicle') ||
        normalized.contains('vehicles') ||
        normalized.contains('car') ||
        normalized.contains('cars') ||
        normalized.contains('سيارة') ||
        normalized.contains('سيارات') ||
        normalized.contains('مركبة') ||
        normalized.contains('مركبات') ||
        normalized.contains('عربية') ||
        normalized.contains('عربيات')) {
      return AdType.vehicles;
    }

    return null;
  }
}
