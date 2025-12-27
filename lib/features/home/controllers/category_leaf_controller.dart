import 'package:get/get.dart';
import 'package:haraj_adan_app/domain/repositories/categories_repository.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';

class CategoryLeafController extends GetxController {
  final CategoriesRepository repo;

  CategoryLeafController({required this.repo});

  final isLoading = false.obs;

  Future<CategoryModel?> fetchFreshCategory(int id) async {
    isLoading(true);
    try {
      return await repo.fetchOne(id: id, includeChildren: true);
    } catch (_) {
      return null;
    } finally {
      isLoading(false);
    }
  }

  bool isLeaf(CategoryModel c) => (c.children).isEmpty;
}
