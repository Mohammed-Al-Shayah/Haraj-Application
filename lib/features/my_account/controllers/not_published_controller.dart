import 'package:haraj_adan_app/core/storage/user_storage.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';
import 'package:haraj_adan_app/core/theme/strings.dart';
import 'package:haraj_adan_app/domain/entities/not_published_entity.dart';
import 'package:haraj_adan_app/domain/repositories/not_published_repository.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';
import 'package:haraj_adan_app/core/routes/routes.dart';
import 'package:get/get.dart';
import 'package:haraj_adan_app/features/my_account/views/widgets/feature_plan_sheet.dart';

class NotPublishedController extends GetxController {
  final NotPublishedRepository repository;
  final PostAdRepository postAdRepository;

  NotPublishedController(this.repository, this.postAdRepository);

  var ads = <NotPublishedEntity>[].obs;
  var isLoading = true.obs;
  var featuringIds = <int>{}.obs;

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

  Future<void> featureAd(int adId) async {
    if (await getUserIdFromPrefs() == null) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.userNotFound);
      return;
    }
    if (featuringIds.contains(adId)) return;
    featuringIds.add(adId);
    try {
      await FeaturePlanSheet.show(
        adId: adId,
        postAdRepository: postAdRepository,
        onApplied: loadAds,
      );
    } catch (e) {
      AppSnack.error(AppStrings.errorTitle, AppStrings.featureRequestFailed);
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
        AppSnack.error(AppStrings.errorTitle, AppStrings.adCategoryNotFound);
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
      AppSnack.error(AppStrings.errorTitle, AppStrings.adDataLoadFailed);
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
