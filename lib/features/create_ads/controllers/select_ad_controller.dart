import 'package:get/get.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';
import 'package:haraj_adan_app/features/home/repo/categories_repo.dart';
// import '../../../domain/entities/category_entity.dart';
// import '../../../domain/repositories/category_repository.dart';

class SelectAdController extends GetxController {
  final CategoriesRepository repository;
  var categories = <CategoryModel>[].obs;
  var isLoading = true.obs;

  SelectAdController(this.repository);

  @override
  void onInit() {
    loadCategories();
    super.onInit();
  }

  void loadCategories() async{
    try {
      isLoading(true);
      categories.value = await repository.getAllCategories();
    } finally {
      isLoading(false);
    }
  }
}
