import 'package:haraj_adan_app/core/network/api_client.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';

abstract class CategoriesRemoteDataSource {
  Future<CategoryModel> fetchOne({
    required int id,
    bool includeChildren = true,
  });
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final ApiClient api;

  CategoriesRemoteDataSourceImpl(this.api);

  @override
  Future<CategoryModel> fetchOne({
    required int id,
    bool includeChildren = true,
  }) async {
    final Map<String, dynamic> res = await api.get(
      '/categories/$id',
      queryParams:
          includeChildren ? <String, dynamic>{'includes': 'children'} : null,
    );

    final dynamic data = res['data'];

    if (data is Map<String, dynamic>) {
      return CategoryModel.fromJson(data);
    }

    throw Exception('Invalid category response');
  }
}
