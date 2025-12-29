import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/features/home/controllers/all_featured_ext_controller.dart';
import '../../../../core/routes/routes.dart';
import '../../controllers/home_controller.dart';
import '../widgets/featured_ad_item.dart';

class AllFeaturedAdsScreen extends StatelessWidget {
  final HomeController controller;

  const AllFeaturedAdsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.refreshFavouriteIds();
    if (controller.ads.isEmpty) {
      controller.loadAds();
    }

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: MainBar(
        title: AppStrings.allFeaturedAds,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (controller.isLoadingAds.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.ads.isEmpty) {
            return Center(child: Text(AppStrings.noFeaturedAds));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.ads.length,
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
                    isLoading: false,
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
      ),
    );
  }
}
