import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDatasource {
  Future<PaginatedCategoriesResponse> fetchCategories({int page = 1});
  Future<CategoryModel> fetchCategoryDetails(int id);
  Future<CategoryModel> updateCategory(
    int id, {
    required String name,
    required String description,
  });
  Future<CategoryModel> storeCategory({
    required String name,
    required String description,
  });
  Future<void> deleteCategory(int id);
  Future<CategoryModel> activateCategory(int id);
  Future<CategoryModel> deactivateCategory(int id);
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final DioClient _client;

  CategoryRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedCategoriesResponse> fetchCategories({int page = 1}) async {
    final response = await _client.post(
      ApiEndpoints.categories,
      queryParameters: {'page': page},
    );

    return PaginatedCategoriesResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<CategoryModel> fetchCategoryDetails(int id) async {
    final response = await _client.get('${ApiEndpoints.showCategory}$id');

    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> updateCategory(
    int id, {
    required String name,
    required String description,
  }) async {
    final response = await _client.put(
      '${ApiEndpoints.updateCategory}$id',
      data: {'cat_name': name, 'short_description': description},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> storeCategory({
    required String name,
    required String description,
  }) async {
    final response = await _client.post(
      ApiEndpoints.storeCategory,
      data: {'cat_name': name, 'short_description': description},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _client.delete('${ApiEndpoints.deleteCategory}$id');
  }

  @override
  Future<CategoryModel> activateCategory(int id) async {
    final response = await _client.put('${ApiEndpoints.activateCategory}$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> deactivateCategory(int id) async {
    final response = await _client.put('${ApiEndpoints.deactivateCategory}$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }
}
