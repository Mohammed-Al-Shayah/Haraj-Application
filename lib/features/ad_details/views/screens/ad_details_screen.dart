import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/theme/color.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/widgets/main_bar.dart';
import 'package:haraj_adan_app/data/datasources/likes_remote_datasource.dart';
import 'package:haraj_adan_app/data/repositories/likes_repository_impl.dart';
import 'package:haraj_adan_app/features/ad_details/controllers/ad_details_controller.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/bottom_navigation_action.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/ad_details_image_slider.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/ad_title_and_price.dart';
import 'package:haraj_adan_app/features/ad_details/views/widgets/tab_bar_views.dart';
import 'package:haraj_adan_app/data/repositories/ad_details_repository_impl.dart';
import 'package:haraj_adan_app/data/datasources/ad_details_remote_data_source.dart';

class AdDetailsScreen extends StatelessWidget {
  const AdDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    int? adId;
    if (args is Map && args['adId'] != null) {
      adId = int.tryParse(args['adId'].toString());
    } else if (args is int) {
      adId = args;
    } else if (args is String) {
      adId = int.tryParse(args);
    }
    adId ??= 0;

    if (adId == 0) {
      return Scaffold(
        appBar: MainBar(title: AppStrings.adDetailsTitle),
        body: const Center(child: Text('Ad not found')),
      );
    }

    final apiClient = ApiClient(client: Dio());

    Get.put(
      AdDetailsController(
        repository: AdDetailsRepositoryImpl(
          AdDetailsRemoteDataSourceImpl(apiClient),
        ),
        likesRepository: LikesRepositoryImpl(
          LikesRemoteDataSourceImpl(apiClient),
        ),
        adId: adId,
      ),
    );

    return Scaffold(
      appBar: MainBar(
        title: AppStrings.adDetailsTitle,
        customActions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: AppColors.white),
          ),
          Obx(() {
            final controller = Get.find<AdDetailsController>();
            final isLiked = controller.ad.value?.isLiked ?? false;
            final isBusy = controller.isTogglingLike.value;
            return IconButton(
              onPressed: isBusy ? null : controller.toggleLike,
              icon:
                  isBusy
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                      : Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : AppColors.white,
                      ),
            );
          }),
        ],
      ),
      bottomNavigationBar: const BottomNavigationAction(),
      body: Obx(() {
        final controller = Get.find<AdDetailsController>();
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.ad.value == null) {
          return const Center(child: Text('No data'));
        }
        return const SingleChildScrollView(
          child: Column(
            children: [
              AdDetailsImageSlider(),
              AdTitleAndPrice(),
              TabBarViews(),
            ],
          ),
        );
      }),
    );
  }
}
