import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/core/network/endpoints.dart';
import 'package:haraj_adan_app/domain/repositories/ad_details_repository.dart';
import 'package:haraj_adan_app/domain/repositories/likes_repository.dart';
import 'package:haraj_adan_app/features/ad_details/models/ad_details_model.dart';
import 'package:haraj_adan_app/features/ad_details/models/comment_model.dart';
import 'package:haraj_adan_app/features/home/controllers/home_controller.dart';
import 'package:haraj_adan_app/features/my_account/controllers/favourite_ads_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdDetailsController extends GetxController {
  final AdDetailsRepository repository;
  final LikesRepository likesRepository;
  final int adId;

  AdDetailsController({
    required this.repository,
    required this.likesRepository,
    required this.adId,
  });

  // State
  final ad = Rxn<AdDetailsModel>();
  final comments = <CommentModel>[].obs;

  final isLoading = false.obs;
  final isCommentsLoading = false.obs;

  final isFavourite = false.obs;
  final isTogglingLike = false.obs;

  static const String _prefsKey = 'favourite_ads';

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _loadFavouriteState();
    await fetchAdDetails();
    await fetchComments();
  }

  // User Id (for likes query param & like body)
  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("_userData");
    if (userJson == null || userJson.isEmpty) return null;

    final user = jsonDecode(userJson);
    final id = user['id'] ?? user['user_id'];

    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);

    return null;
  }

  // Details
  Future<void> fetchAdDetails() async {
    try {
      isLoading(true);

      final userId = await _getUserIdFromPrefs();

      ad.value = await repository.getAdDetails(
        adId: adId,
        includes: 'attributes,images,user,likes,featured,favourites',
        userId: userId,
      );

      await _loadOwnerInfoIfNeeded();
      await _loadFavouriteState();
    } catch (_) {
      AppSnack.error(
        _tWithFallback(AppStrings.errorTitle, 'Error'),
        _tWithFallback('failed_to_load_details', 'Failed to load ad details'),
      );
    } finally {
      isLoading(false);
    }
  }

  // Comments
  Future<void> fetchComments({int page = 1, int limit = 10}) async {
    try {
      isCommentsLoading(true);
      final data = await repository.getAdComments(
        adId: adId,
        page: page,
        limit: limit,
      );
      comments.assignAll(data);
    } catch (_) {
      AppSnack.error(
        _tWithFallback(AppStrings.errorTitle, 'Error'),
        _tWithFallback('failed_to_load_comments', 'Failed to load comments'),
      );
    } finally {
      isCommentsLoading(false);
    }
  }

  // Likes (API only)
  Future<void> toggleLike() async {
    final currentAd = ad.value;
    if (currentAd == null) return;

    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      AppSnack.error(
        _tWithFallback(AppStrings.errorTitle, 'Error'),
        _tWithFallback(AppStrings.loginRequired, 'Please login first'),
      );
      return;
    }

    isTogglingLike(true);

    try {
      final bool isLiked = currentAd.isLiked;
      final int? likeId = currentAd.likeId;
      String successMessage;

      if (isLiked && likeId != null) {
        await likesRepository.removeLike(likeId: likeId);
        successMessage = _tWithFallback(AppStrings.likeRemoved, 'Like removed');
      } else {
        await likesRepository.likeAd(adId: adId, userId: userId);
        successMessage = _tWithFallback(
          AppStrings.likeAdded,
          'Liked successfully',
        );
      }
      await fetchAdDetails();
      AppSnack.success(
        _tWithFallback(AppStrings.successTitle, 'Success'),
        successMessage,
      );
    } catch (_) {
      AppSnack.error(
        _tWithFallback(AppStrings.errorTitle, 'Error'),
        _tWithFallback(AppStrings.likeUpdateFailed, 'Failed to update like'),
      );
    } finally {
      isTogglingLike(false);
    }
  }

  // Favourite (Local)
  Future<void> toggleFavourite() async {
    final prefs = await SharedPreferences.getInstance();

    final currentAd = ad.value;
    if (currentAd == null) return;

    final favourites = _readFavourites(prefs);
    final exists = favourites.any((item) => item['id'] == adId);

    if (exists) {
      favourites.removeWhere((item) => item['id'] == adId);
      isFavourite(false);
      _syncHomeFavourite(false);
      AppSnack.success(
        _tWithFallback(AppStrings.successTitle, 'Success'),
        _tWithFallback(AppStrings.favouriteRemoved, 'Removed from favourites'),
      );
      update();
    } else {
      final firstImage =
          currentAd.images.isNotEmpty ? currentAd.images.first : '';
      favourites.add({
        'id': adId,
        'title': currentAd.title,
        'location': currentAd.address,
        'price': currentAd.price,
        'image': firstImage,
        'currencySymbol': currentAd.currencySymbol,
      });
      isFavourite(true);
      _syncHomeFavourite(true);
      AppSnack.success(
        _tWithFallback(AppStrings.successTitle, 'Success'),
        _tWithFallback(AppStrings.favouriteAdded, 'Added to favourites'),
      );
    }
    update();

    try {
      await prefs.setString(_prefsKey, jsonEncode(favourites));
      await _notifyFavouriteList();
      update();
    } catch (_) {
      AppSnack.error(
        _tWithFallback(AppStrings.errorTitle, 'Error'),
        _tWithFallback(
          AppStrings.favouriteUpdateFailed,
          'Failed to update favourites',
        ),
      );
      update();
    }
  }

  Future<void> _loadFavouriteState() async {
    final prefs = await SharedPreferences.getInstance();
    final favourites = _readFavourites(prefs);
    isFavourite(favourites.any((item) => item['id'] == adId));
  }

  List<Map<String, dynamic>> _readFavourites(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  Future<void> _notifyFavouriteList() async {
    if (!Get.isRegistered<FavouriteAdsController>()) return;
    await Get.find<FavouriteAdsController>().loadFavouriteAds();
  }

  Future<void> _loadOwnerInfoIfNeeded() async {
    final currentAd = ad.value;
    if (currentAd == null) return;
    final ownerId = currentAd.ownerId;
    if (ownerId == null) return;

    final hasName = (currentAd.ownerName ?? '').trim().isNotEmpty;
    final hasPhone = (currentAd.ownerPhone ?? '').trim().isNotEmpty;
    if (hasName && hasPhone) return;

    try {
      final api = ApiClient(client: Dio());
      final res = await api.get(ApiEndpoints.userById(ownerId));
      final user = _extractUserMap(res);
      if (user == null) return;

      final name = _pickString(user, const [
        'name',
        'user_name',
        'full_name',
        'username',
        'first_name',
      ]);
      final phone = _pickString(user, const [
        'phone',
        'mobile',
        'phone_number',
        'phoneNumber',
        'contact_phone',
        'whatsapp',
      ]);

      ad.value = _copyAdWithOwner(
        currentAd,
        name: name,
        phone: phone,
        ownerId: ownerId,
      );
      update();
    } catch (_) {
      // Silent fail; ad details still usable without owner info.
    }
  }

  Map<String, dynamic>? _extractUserMap(dynamic res) {
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is Map<String, dynamic>) return data;
      if (res['user'] is Map<String, dynamic>) {
        return res['user'] as Map<String, dynamic>;
      }
      return res;
    }
    return null;
  }

  String? _pickString(Map<String, dynamic> src, List<String> keys) {
    for (final k in keys) {
      final val = src[k];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    return null;
  }

  AdDetailsModel _copyAdWithOwner(
    AdDetailsModel ad, {
    String? name,
    String? phone,
    int? ownerId,
  }) {
    return AdDetailsModel(
      id: ad.id,
      title: ad.title,
      titleEn: ad.titleEn,
      price: ad.price,
      address: ad.address,
      images: ad.images,
      latitude: ad.latitude,
      longitude: ad.longitude,
      attributes: ad.attributes,
      description: ad.description,
      currencySymbol: ad.currencySymbol,
      likesCount: ad.likesCount,
      isLiked: ad.isLiked,
      likeId: ad.likeId,
      createdAt: ad.createdAt,
      categoryName: ad.categoryName,
      categoryNameEn: ad.categoryNameEn,
      ownerName: name ?? ad.ownerName,
      ownerPhone: phone ?? ad.ownerPhone,
      ownerId: ownerId ?? ad.ownerId,
    );
  }

  void _syncHomeFavourite(bool favourite) {
    if (!Get.isRegistered<HomeController>()) return;
    Get.find<HomeController>().setFavourite(adId, favourite);
    update();
  }

  String _tWithFallback(String translated, String enFallback) {
    final bool missing =
        translated.contains('- 404') || translated.trim().isEmpty;
    if (missing) {
      return enFallback;
    }
    return translated;
  }

  @override
  void onClose() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshFavouriteIds();
    }
    super.onClose();
  }
}
