import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/domain/entities/on_air_entity.dart';
import 'package:haraj_adan_app/domain/repositories/on_air_repository.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';

class OnAirController extends GetxController {
  final OnAirRepository repository;
  final PostAdRepository postAdRepository;

  OnAirController(this.repository, this.postAdRepository);

  var ads = <OnAirEntity>[].obs;
  var isLoading = true.obs;
  var featuringIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAds();
  }

  void loadAds() async {
    isLoading.value = true;
    final userId = await getUserIdFromPrefs();
    if (userId != null) {
      ads.value = await repository.getAds(userId: userId);
    } else {
      ads.clear();
    }
    isLoading.value = false;
  }

  Future<void> featureAd(int adId) async {
    final userId = await getUserIdFromPrefs();
    if (userId == null) {
      AppSnack.error('خطأ', 'المستخدم غير معروف');
      return;
    }
    if (featuringIds.contains(adId)) return;
    featuringIds.add(adId);
    try {
      await postAdRepository.featureAd(adId, userId: userId);
       loadAds();
      AppSnack.success('تم', 'تم إرسال طلب التمييز بنجاح');
    } catch (e) {
      String message = 'تعذر تنفيذ التمييز، حاول مجدداً';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          message = data['message'].toString();
        }
      }
      AppSnack.error('خطأ', message);
    } finally {
      featuringIds.remove(adId);
      featuringIds.refresh();
    }
  }

  Future<void> editAd(int adId) async {
    try {
      isLoading.value = true;
      final data = await postAdRepository.getAdForEdit(adId);

      final List<int> adCategories = _extractCategories(data);
      final int? categoryId =
          adCategories.isNotEmpty ? adCategories.first : null;

      if (categoryId == null || categoryId == 0) {
        AppSnack.error('خطأ', 'لا يمكن تحديد التصنيف لهذا الإعلان');
        return;
      }

      isLoading.value = false;
      final result = await Get.toNamed(
        Routes.postAdScreen,
        arguments: {
          'editAdId': adId,
          'adData': data,
          'categoryId': categoryId,
          'categoryTitle':
              data['category']?['name'] ??
              data['categories']?['name'] ??
              'Category',
        },
      );
      if (result == true) {
        loadAds();
      }
    } catch (_) {
      AppSnack.error('خطأ', 'تعذر تحميل بيانات الإعلان للتعديل');
    } finally {
      isLoading.value = false;
    }
  }

  List<int> _extractCategories(Map<String, dynamic> data) {
    final Set<int> ids = {};

    void addId(dynamic v) {
      if (v is num && v.toInt() > 0) ids.add(v.toInt());
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null && parsed > 0) ids.add(parsed);
      }
    }

    void addFrom(dynamic cats) {
      if (cats is List) {
        for (final c in cats) {
          if (c is Map) {
            addId(c['id'] ?? c['category_id']);
          } else {
            addId(c);
          }
        }
      } else if (cats is Map) {
        addId(cats['id'] ?? cats['category_id']);
      }
    }

    addFrom(data['ad_categories']);
    addFrom(data['categories']);
    addFrom(data['category']);
    addFrom(data['ad_category']);
    addId(data['category_id']);
    addId(data['ad_category_id']);
    addId(data['ad_categories_id']);

    // Fallback: scan root keys that look like category ids.
    data.forEach((key, value) {
      final k = key.toString().toLowerCase();
      if (k.contains('category') && value is num) addId(value);
    });

    final attrs = data['ad_attributes'];
    if (attrs is List) {
      for (final attr in attrs) {
        if (attr is! Map) continue;
        final catAttrs = attr['category_attributes'];
        if (catAttrs is Map) {
          addId(catAttrs['category_id'] ?? catAttrs['id']);
        }
        addId(attr['category_id']);
      }
    }

    return ids.toList();
  }
}
