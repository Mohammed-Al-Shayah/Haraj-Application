import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

extension AllFeaturedAdsControllerExtension on HomeController {
  Future<void> loadAds() async {
    try {
      isLoadingAds(true);
      ads.value = await homeRepository.getHomeAds();
    } catch (e) {
      AppSnack.error("Error", "Failed to load ads");
    } finally {
      isLoadingAds(false);
    }
  }
}
