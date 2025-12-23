import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/home/repo/categories_repo.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import '../routes/routes.dart';
import '../theme/assets.dart';
import '../theme/color.dart';
import '../theme/strings.dart';
import 'category/category_card.dart';
import '../../features/home/models/category.model.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class SideMenu extends StatelessWidget {
  SideMenu({super.key});

  final SideMenuController controller = Get.put(SideMenuController());

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final arrowIcon =
        currentLanguage == 'en'
            ? AppAssets.arrowRightIcon
            : AppAssets.arrowLeftIcon;

    return Drawer(
      width: 350,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.homeScreen);
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        AppAssets.harajAdenLogo,
                        width: 36,
                        height: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.appTitle,
                        style: AppTypography.bold16.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.myAccountScreen);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.myAccountIcon,
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.myAccount,
                        style: AppTypography.bold16.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        arrowIcon,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.selectAdScreen);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.postAdIcon,
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.postAd,
                        style: AppTypography.bold16.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        arrowIcon,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // هنا نعرض التصنيفات
          CategoryCard(categories: controller.categories, isDrawer: true),
        ],
      ),
    );
  }
}

class SideMenuController extends GetxController {
  final CategoriesRepository repository =
      CategoriesRepository(ApiClient(client: Dio()));
  var categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  void _loadCategories() async {
    categories.value = await repository.getAllCategories();
  }
}
