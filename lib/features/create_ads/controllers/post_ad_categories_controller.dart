import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/repositories/post_ad_repository.dart';

class PostAdCategoriesController extends GetxController {
  final PostAdRepository repo;
  PostAdCategoriesController(this.repo);

  final isLoading = false.obs;
  final parents = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading(true);
    try {
      parents.assignAll(await repo.getParentCategories());
    } finally {
      isLoading(false);
    }
  }

  void onSelectChildCategory(int childCategoryId) {
    // ✅ rule: only child IDs
    Get.toNamed('/post-ad', arguments: {'categoryId': childCategoryId});
  }
}
