import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/theme/typography.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import 'package:haraj_adan_app/features/home/views/screens/all_nearby_ads_screen.dart';
import 'see_all_header.dart';
import 'shopping_ad_item.dart';


class NearbyAdsSection extends StatelessWidget {
  const NearbyAdsSection({
    super.key,
    required this.controller,
    required this.latitude,
    required this.longitude,
  });

  final HomeController controller;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    controller.loadNearby(lat: latitude, lng: longitude);
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
                Get.to(() => AllNearbyAdsScreen(
                      controller: controller,
                      latitude: latitude,
                      longitude: longitude,
                    ));
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingNearby.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.nearbyError.value != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  controller.nearbyError.value!,
                  style: AppTypography.normal14.copyWith(
                    color: AppColors.red,
                  ),
                ),
              );
            }

            final items = controller.nearbyAds;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'No nearby ads found.',
                  style: AppTypography.normal14.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              );
            }

            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length > 4 ? 4 : items.length,
                itemBuilder: (context, index) {
                  final ad = items[index];
                  final imageUrl =
                      ad.images.isNotEmpty ? ad.images.first.image : '';
                  final price = double.tryParse(ad.price) ?? 0;
                  final bool isLastItem =
                      index == items.length - 1 ||
                      (items.length > 4 && index == 3);

                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 20 : 12,
                      right: isLastItem ? 20 : 0,
                    ),
                    child: ShoppingAdItem(
                      imageAsset: imageUrl,
                      name: ad.title,
                      location: ad.address,
                      price: price,
                      isLoading: false,
                      onTap: () => Get.toNamed(
                        Routes.adDetailsScreen,
                        arguments: {'adId': ad.id},
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
