import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/features/home/controllers/all_featured_ext_controller.dart';
import 'package:haraj_adan_app/features/home/views/widgets/see_all_header.dart';
import '../../controllers/home_controller.dart';
import '../screens/all_featured_ads_screen.dart';
import 'featured_ad_item.dart';

class FeaturedAdsSection extends StatelessWidget {
  final HomeController controller;

  const FeaturedAdsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.refreshFavouriteIds();
    if (controller.ads.isEmpty) {
      controller.loadAds();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeeAllHeader(
            title: AppStrings.homePageFeaturedAds,
            onSeeAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AllFeaturedAdsScreen(controller: controller),
                ),
              );
            },
          ),
          Obx(() {
            if (controller.isLoadingAds.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.ads.isEmpty) {
              return const Center(child: Text('لا توجد إعلانات مميزة حالياً'));
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.ads.length > 4 ? 4 : controller.ads.length,
              itemBuilder: (context, index) {
                final ad = controller.ads[index];
                String imageUrl = '';
                if (ad.images.isNotEmpty) {
                  final raw = ad.images.first.image.trim();
                  if (raw.startsWith('http')) {
                    imageUrl = raw;
                  } else {
                    final sanitized = raw.replaceFirst(RegExp(r'^/+'), '');
                    imageUrl = '${ApiEndpoints.imageUrl}$sanitized';
                  }
                }

                return GetBuilder<HomeController>(
                  builder: (context) {
                    return FeaturedAdItem(
                      index: index,
                      imageUrl: imageUrl,
                      title: ad.title,
                      isFavourite: controller.favouriteIds.contains(ad.id),
                      isLoading: controller.isLoadingAds.value,
                      onTap:
                          () => Get.toNamed(
                            Routes.adDetailsScreen,
                            arguments: ad.id,
                          ),
                    );
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
