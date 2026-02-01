import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/ad_card_item.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/widgets/main_bar.dart';
import '../../../../core/widgets/side_menu.dart';
import '../../../../data/datasources/on_air_remote_datasource.dart';
import '../../../../data/datasources/post_ad_remote_datasource.dart';
import '../../../../data/repositories/on_air_repository_impl.dart';
import '../../../../data/repositories/post_ad_repository_impl.dart';
import '../../controllers/on_air_controller.dart';

class OnAirScreen extends StatefulWidget {
  const OnAirScreen({super.key});

  @override
  State<OnAirScreen> createState() => _OnAirScreenState();
}

class _OnAirScreenState extends State<OnAirScreen> {
  late final OnAirController controller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      OnAirController(
        OnAirRepositoryImpl(
          OnAirRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
        PostAdRepositoryImpl(
          PostAdRemoteDataSourceImpl(ApiClient(client: Dio())),
        ),
      ),
      permanent: true,
    );
  }

  @override
  Widget build(BuildContext context) {

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
        if (controller.ads.isEmpty) {
          return Center(
            child: Text(
              AppStrings.noItems,
              style: AppTypography.normal14.copyWith(color: AppColors.gray600),
            ),
          );
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
              currencySymbol: ad.currencySymbol,
              onEdit: () => controller.editAd(ad.id),
              onFeature: () => controller.featureAd(ad.id),
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
