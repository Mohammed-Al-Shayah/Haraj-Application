import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/core/widgets/side_menu.dart';
import 'package:haraj_adan_app/data/datasources/post_ad_remote_datasource.dart';
import 'package:haraj_adan_app/data/datasources/rejected_remote_datasource.dart';
import 'package:haraj_adan_app/data/repositories/post_ad_repository_impl.dart';
import 'package:haraj_adan_app/data/repositories/rejected_repository_impl.dart';
import 'package:haraj_adan_app/features/my_account/controllers/rejected_controller.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/ad_card_item.dart';

class RejectedScreen extends StatefulWidget {
  const RejectedScreen({super.key});

  @override
  State<RejectedScreen> createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  late final RejectedController controller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      RejectedController(
        RejectedRepositoryImpl(
          RejectedRemoteDataSourceImpl(ApiClient(client: Dio())),
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
        title: AppStrings.rejectedAdsTitle,
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
              onEdit: () => controller.editAd(ad.id),
              onFeature: () => controller.featureAd(ad.id),
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
