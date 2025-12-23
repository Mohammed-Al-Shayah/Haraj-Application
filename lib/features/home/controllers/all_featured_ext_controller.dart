import 'package:get/get.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';

extension AllFeaturedAdsControllerExtension on HomeController {
  Future<void> loadAds() async {
    try {
      isLoadingAds(true);
      ads.value = await homeRepository.getHomeAds();
    } catch (e) {
      Get.snackbar("Error", "Failed to load ads");
    } finally {
      isLoadingAds(false);
    }
  }
}
