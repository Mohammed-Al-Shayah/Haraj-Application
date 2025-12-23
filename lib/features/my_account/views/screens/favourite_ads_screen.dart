import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/data/datasources/favourite_ads_remote_datasource.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/ad_card_item.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../../../data/repositories/favourite_ads_repository_impl.dart';
import '../../controllers/favourite_ads_controller.dart';

class FavouriteAdsScreen extends StatelessWidget {
  const FavouriteAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      FavouriteAdsController(
        FavouriteAdsRepositoryImpl(FavouriteAdsRemoteDataSourceImpl()),
      ),
    );

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.favouriteAdsTitle,
        menu: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: SideMenu(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.ads.length,
          itemBuilder: (context, index) {
            final ad = controller.ads[index];
            return AdCardItem(
              adId: ad.id,
              title: ad.title,
              location: ad.location,
              price: ad.price,
              imageUrl: ad.imageUrl,
              currencySymbol: ad.currencySymbol,
              onTap:
                  () => Get.toNamed(
                    Routes.adDetailsScreen,
                    arguments: {'adId': ad.id},
                  ),
            );
          },
        );
      }),
    );
  }
}
