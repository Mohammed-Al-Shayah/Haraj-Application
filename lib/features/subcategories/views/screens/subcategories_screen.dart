import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/widgets/category/category_card.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../../../core/theme/color.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../filters/models/enums.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../home/views/widgets/featured_ads_section.dart';
import '../widgets/exclusive_offer_card.dart';
import '../widgets/subcategories_card.dart';

class SubcategoriesScreen extends StatelessWidget {
  const SubcategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments ?? {}) as Map?;
    final category = args?['category'];

    if (category is! CategoryModel) {
      return Scaffold(
        appBar: MainBar(
          title: AppStrings.categorySelection,
          menu: true,
          scaffoldKey: GlobalKey<ScaffoldState>(),
        ),
        body: const Center(child: Text('Category not found')),
      );
    }

    final bool isPostAdFlow = args?['isPostAdFlow'] ?? false;
    final AdType? adType = args?['adType'] as AdType?;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final HomeController controller = Get.find<HomeController>();

    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final bool isArabic = currentLanguage.startsWith('ar');
    final bool isEnglish = currentLanguage.startsWith('en');

    final String text =
        isArabic
            ? '${AppStrings.all} ${AppStrings.ads} "${category.name}"'
            : '${AppStrings.all} "${category.nameEn}" ${AppStrings.ads}';

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: isArabic ? category.name : category.nameEn,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
                left: 20.0,
                top: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style: AppTypography.semiBold14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    category.children.length.toString(),
                    style: AppTypography.semiBold14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            if (isPostAdFlow)
              CategoryCard(
                categories: RxList<CategoryModel>.from(category.children),
                isPostAdFlow: true,
                parentAdType: adType,
              )
            else
              Obx(() {
                if (controller.isLoadingCategories.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (category.children.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text("لا توجد تصنيفات فرعية")),
                  );
                }

                return SubcategoriesCard(
                  categorySelection:
                      category.children.map((child) {
                        return SubCategoryEntity(
                          id: child.id,
                          title: isEnglish ? child.nameEn : child.name,
                          adsCount: child.adsCount,
                          subSubCategories:
                              child.children
                                  .map(
                                    (sub) => SubSubCategoryEntity(
                                      id: sub.id,
                                      title: isEnglish ? sub.nameEn : sub.name,
                                    ),
                                  )
                                  .toList(),
                        );
                      }).toList(),
                  isPostAdFlow: false,
                  parentCategoryName: category.name,
                  parentCategoryNameEn: category.nameEn,
                  parentAdType: adType,
                  parentCategoryId: category.id,
                );
              }),

            if (!isPostAdFlow)
              Column(
                children: [
                  Obx(() {
                    final banners = controller.banners;
                    final offers =
                        banners.isNotEmpty
                            ? banners
                                .map(
                                  (banner) => {
                                    "imageUrl":
                                        "${ApiEndpoints.imageUrl}${banner.image}",
                                  },
                                )
                                .toList()
                            : [
                              {"imageUrl": "https://picsum.photos/400/200?1"},
                              {"imageUrl": "https://picsum.photos/400/200?2"},
                              {"imageUrl": "https://picsum.photos/400/200?3"},
                            ];

                    return ExclusiveOfferSlider(offers: offers);
                  }),
                  FeaturedAdsSection(controller: controller),
                ],
              ),
          ],
        ),
      ),
      drawer: SideMenu(),
    );
  }
}
