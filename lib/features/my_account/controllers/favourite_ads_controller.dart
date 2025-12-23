import 'package:get/get.dart';
import '../../../domain/entities/favourite_ads_entity.dart';
import '../../../domain/repositories/favourite_ads_repository.dart';

class FavouriteAdsController extends GetxController {
  final FavouriteAdsRepository repository;

  FavouriteAdsController(this.repository);

  var ads = <FavouriteAdsEntity>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavouriteAds();
  }

  Future<void> loadFavouriteAds() async {
    isLoading.value = true;
    ads.value = await repository.getFavouriteAds();
    isLoading.value = false;
  }
}
