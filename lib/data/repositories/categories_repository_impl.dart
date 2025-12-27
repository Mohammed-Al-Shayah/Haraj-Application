import 'package:haraj_adan_app/data/datasources/categories_remote_datasource.dart';
import 'package:haraj_adan_app/domain/repositories/categories_repository.dart';
import 'package:haraj_adan_app/features/home/models/category.model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remote;

  CategoriesRepositoryImpl(this.remote);

  @override
  Future<CategoryModel> fetchOne({
    required int id,
    bool includeChildren = true,
  }) {
    return remote.fetchOne(id: id, includeChildren: includeChildren);
  }
}
