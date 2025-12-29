import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';
import 'package:haraj_adan_app/core/utils/app_snackbar.dart';

class PostAdCategoriesController extends GetxController {
  final PostAdRepository repo;
  PostAdCategoriesController(this.repo);

  final isLoading = false.obs;
  final parents = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading(true);
    try {
      final raw = await repo.getParentCategories();
      final list = raw
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
      parents.assignAll(list);
    } finally {
      isLoading(false);
    }
  }

  void onSelectCategory(CategoryModel category) {
    // Business rule: only non-root categories are valid for posting.
    // Root categories are the ones with parent_id == null.
    if (category.parentId == null) {
      AppSnack.error('Error', 'Please choose a sub-category');
      return;
    }

    Get.toNamed('/post-ad', arguments: {
      'categoryId': category.id,
      'categoryTitle': category.title,
    });
  }
}
