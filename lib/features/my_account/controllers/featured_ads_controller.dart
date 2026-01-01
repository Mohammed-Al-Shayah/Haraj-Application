import 'package:get/get.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/domain/entities/user_featured_ad_entity.dart';
import 'package:haraj_adan_app/domain/repositories/user_featured_ads_repository.dart';

class FeaturedAdsController extends GetxController {
  final UserFeaturedAdsRepository repository;

  FeaturedAdsController(this.repository);

  var ads = <UserFeaturedAdEntity>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAds();
  }

  Future<void> loadAds() async {
    isLoading.value = true;
    final userId = await getUserIdFromPrefs();
    if (userId != null) {
      ads.value = await repository.getAds(userId: userId);
    } else {
      ads.clear();
    }
    isLoading.value = false;
  }
}
