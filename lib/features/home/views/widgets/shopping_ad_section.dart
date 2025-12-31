import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import '../../../../core/routes/routes.dart';
import '../screens/all_shopping_ad_screen.dart';
import 'shopping_ad_item.dart';
import 'see_all_header.dart';

class ShoppingAdSection extends StatelessWidget {
  final HomeController controller;

  const ShoppingAdSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.shoppingAds.isEmpty) {
      controller.loadShoppingAds();
    }

    final currentLanguage = LocalizeAndTranslate.getLanguageCode();
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.6);
    final listHeight = 120 * (textScale);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SeeAllHeader(
              title: AppStrings.shoppingListingsFromOwnerNearYou,
              onSeeAllPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AllShoppingAdScreen(controller: controller),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final items = controller.shoppingAds;
            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length > 4 ? 4 : items.length,
                itemBuilder: (context, index) {
                  bool isLastItem =
                      index == items.length - 1 ||
                      (items.length > 4 && index == 3);

                  return Padding(
                    padding: EdgeInsets.only(
                      left:
                          currentLanguage == 'ar' ? (isLastItem ? 20 : 0) : 20,
                      right:
                          currentLanguage == 'ar' ? 20 : (isLastItem ? 20 : 0),
                    ),
                    child: ShoppingAdItem(
                      imageAsset: items[index].imageUrl,
                      name: items[index].title,
                      location: items[index].location,
                      price: items[index].price,
                      isLoading: controller.isLoadingShoppingList[index],
                      onTap: () => Get.toNamed(
                        Routes.adDetailsScreen,
                        arguments: items[index].id,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
