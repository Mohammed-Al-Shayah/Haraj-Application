import 'package:haraj_adan_app/features/home/models/category.model.dart';

abstract class CategoriesRepository {
  Future<CategoryModel> fetchOne({
    required int id,
    bool includeChildren = true,
  });
}
