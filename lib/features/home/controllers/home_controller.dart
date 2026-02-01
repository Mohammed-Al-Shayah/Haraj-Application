import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/features/home/controllers/all_featured_ext_controller.dart';
import 'package:haraj_adan_app/features/home/controllers/banner_controller.dart';
import 'package:haraj_adan_app/features/home/controllers/categories_ext_controller.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';
import 'package:haraj_adan_app/features/subcategories/api/banner_api.dart';
import 'package:haraj_adan_app/features/subcategories/models/banner_model.dart';
import 'package:haraj_adan_app/features/home/models/ads/add_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/featured_ad_entity.dart';
import '../../../domain/entities/shopping_ad_entity.dart';
import '../../../domain/repositories/featured_ad_repository.dart';
import '../../../domain/repositories/shopping_ad_repository.dart';
import '../../../domain/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository homeRepository;
  final FeaturedAdRepository? featuredAdRepository;
  final ShoppingAdRepository? shoppingAdRepository;

  HomeController({
    required this.homeRepository,
    this.featuredAdRepository,
    this.shoppingAdRepository,
  });

  /// Featured Ads variables
  var featuredAds = <FeaturedAdEntity>[].obs;
  var isLoadingFeaturedAds = true.obs;
  var isLoadingList = <bool>[].obs;

  /// Shopping Ads variables
  var shoppingAds = <ShoppingAdEntity>[].obs;
  var isLoadingShoppingAds = true.obs;
  var isLoadingShoppingList = <bool>[].obs;

  /// Banner variables
  final bannerApi = BannerApi();
  var banners = <BannerModel>[].obs;
  var isLoadingBanners = true.obs;

  /// Home ads / categories
  var ads = <AdModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var isLoadingAds = false.obs;
  var isLoadingCategories = false.obs;

  /// Nearby ads
  var nearbyAds = <AdModel>[].obs;
  var isLoadingNearby = false.obs;
  var nearbyError = RxnString();
  double? _lastLat;
  double? _lastLng;
  var favouriteIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFavouriteIds();
    if (featuredAdRepository != null) {
      loadFeaturedAds();
    }
    if (shoppingAdRepository != null) {
      loadShoppingAds();
    }
    loadBanners();
    loadAds();
    loadCategories();
  }

  Future<void> loadFeaturedAds() async {
    if (featuredAdRepository == null) return;

    try {
      isLoadingFeaturedAds(true);
      final ads = await featuredAdRepository!.getFeaturedAds();
      featuredAds.assignAll(ads);
      isLoadingList.assignAll(List<bool>.filled(ads.length, true));
      _simulateItemLoading();
    } catch (e) {
      AppSnack.error('Error', 'Failed to load featured ads');
    } finally {
      isLoadingFeaturedAds(false);
    }
  }

  void _simulateItemLoading() {
    for (int i = 0; i < featuredAds.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        isLoadingList[i] = false;
        isLoadingList.refresh();
      });
    }
  }

  /// Load shopping ads if repository exists
  Future<void> loadShoppingAds() async {
    if (shoppingAdRepository == null) return;
    try {
      isLoadingShoppingAds(true);
      final position = await _getCurrentPosition();
      if (position == null) {
        AppSnack.error(
          AppStrings.locationDisabledTitle,
          AppStrings.locationDisabledMessage,
        );
        return;
      }
      if (position == null) {
        AppSnack.error(
          'لا يعمل',
          'يجب تشغيل خدمة الموقع GPS كي ترى الإعلانات القريبة منك.',
        );
        return;
      }
      final ads = await shoppingAdRepository!.getShoppingAds(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      shoppingAds.assignAll(ads);
      isLoadingShoppingList.assignAll(List<bool>.filled(ads.length, true));
      _simulateShoppingItemLoading();
    } catch (e) {
      AppSnack.error('Error', 'Failed to load shopping ads');
    } finally {
      isLoadingShoppingAds(false);
    }
  }

  /// Per-item shopping loading animation
  void _simulateShoppingItemLoading() {
    for (int i = 0; i < shoppingAds.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        isLoadingShoppingList[i] = false;
        isLoadingShoppingList.refresh();
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _loadFavouriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('favourite_ads');
      if (raw == null || raw.isEmpty) {
        favouriteIds.clear();
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final ids =
            decoded
                .whereType<dynamic>()
                .map((e) {
                  if (e is Map) return e['id'];
                  return e;
                })
                .map(
                  (id) => id is int ? id : int.tryParse(id?.toString() ?? ''),
                )
                .whereType<int>()
                .toList();
        favouriteIds.assignAll(ids);
      } else {
        favouriteIds.clear();
      }
    } catch (_) {
      favouriteIds.clear();
    }
    update();
  }

  Future<void> refreshFavouriteIds() => _loadFavouriteIds();

  void setFavourite(int adId, bool isFavourite) {
    if (isFavourite) {
      if (!favouriteIds.contains(adId)) {
        favouriteIds.add(adId);
      }
    } else {
      favouriteIds.remove(adId);
    }
    favouriteIds.refresh();
    update();
  }

  /// Load nearby ads with basic caching of last coordinates
  Future<void> loadNearby({required double lat, required double lng}) async {
    if ((_lastLat == lat && _lastLng == lng && nearbyAds.isNotEmpty) ||
        isLoadingNearby.value) {
      return;
    }

    _lastLat = lat;
    _lastLng = lng;

    try {
      isLoadingNearby(true);
      nearbyError.value = null;
      final ads = await homeRepository.getNearbyAds(lat, lng);
      nearbyAds.assignAll(ads);
    } catch (e) {
      nearbyError.value = e.toString();
      AppSnack.error('Error', 'Failed to load nearby ads');
    } finally {
      isLoadingNearby(false);
    }
  }
}
