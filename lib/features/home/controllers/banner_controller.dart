import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

extension BannerControllerExtension on HomeController {
  Future<void> loadBanners() async {
    try {
      isLoadingBanners(true);
      final result = await bannerApi.fetchBanners();
      banners.assignAll(result);
      if (kDebugMode) {
        print('banner items ${banners.length}');
      }
    } catch (e) {
      AppSnack.error('Error', 'Failed to load banners');
    } finally {
      isLoadingBanners(false);
    }
  }
}
