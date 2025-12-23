import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import 'package:haraj_adan_app/features/home/views/widgets/shopping_ad_item.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';

import '../../../../core/widgets/side_menu.dart';

class AllNearbyAdsScreen extends StatelessWidget {
  const AllNearbyAdsScreen({
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
    if (controller.nearbyAds.isEmpty) {
      controller.loadNearby(lat: latitude, lng: longitude);
    }
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.allNearbyAds,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          if (controller.isLoadingNearby.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.nearbyError.value != null) {
            return Center(child: Text(controller.nearbyError.value!));
          }
          final items = controller.nearbyAds;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final ad = items[index];
              final imageUrl =
                  ad.images.isNotEmpty ? ad.images.first.image : '';
              final price = double.tryParse(ad.price) ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          );
        }),
      ),
    );
  }
}
