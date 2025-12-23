import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/ad_card_item.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../../../data/datasources/on_air_remote_datasource.dart';
import '../../../../data/repositories/on_air_repository_impl.dart';
import '../../controllers/on_air_controller.dart';

class OnAirScreen extends StatelessWidget {
  const OnAirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final controller = Get.put(
      OnAirController(OnAirRepositoryImpl(OnAirRemoteDataSourceImpl())),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: MainBar(
        title: AppStrings.onAirTitle,
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
              status: ad.status,
              latitude: ad.latitude,
              longitude: ad.longitude,
              onTap: () => Get.toNamed(
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
