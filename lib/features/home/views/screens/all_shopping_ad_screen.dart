import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/side_menu.dart';
import '../widgets/shopping_ad_item.dart';

class AllShoppingAdScreen extends StatelessWidget {
  final HomeController controller;

  const AllShoppingAdScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.shoppingAds.isEmpty) {
      controller.loadShoppingAds();
    }
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(title: AppStrings.allNearbyAds, scaffoldKey: scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          final items = controller.shoppingAds;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
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
          );
        }),
      ),
      drawer: SideMenu(),
    );
  }
}
