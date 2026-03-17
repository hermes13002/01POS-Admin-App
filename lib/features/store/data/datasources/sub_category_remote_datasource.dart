import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import '../models/category_model.dart';

abstract class SubCategoryRemoteDatasource {
  Future<PaginatedSubCategoriesResponse> fetchSubCategories({int page = 1});
  Future<SubCategoryModel> storeSubCategory({
    required int categoryId,
    required String name,
  });
  Future<SubCategoryModel> updateSubCategory(
    int id, {
    required int categoryId,
    required String name,
  });
  Future<SubCategoryModel> fetchSubCategoryDetails(int id);
  Future<SubCategoryModel> activateSubCategory(int id);
  Future<SubCategoryModel> deactivateSubCategory(int id);
  Future<void> deleteSubCategory(int id);
}

class SubCategoryRemoteDatasourceImpl implements SubCategoryRemoteDatasource {
  final DioClient _client;

  SubCategoryRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedSubCategoriesResponse> fetchSubCategories({
    int page = 1,
  }) async {
    final response = await _client.post(
      ApiEndpoints.subCategories,
      queryParameters: {'page': page},
    );

    return PaginatedSubCategoriesResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<SubCategoryModel> storeSubCategory({
    required int categoryId,
    required String name,
  }) async {
    final response = await _client.post(
      ApiEndpoints.storeSubCategory,
      data: {'cat_id': categoryId, 'sub_cat_name': name},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return SubCategoryModel.fromJson(data);
  }

  @override
  Future<SubCategoryModel> updateSubCategory(
    int id, {
    required int categoryId,
    required String name,
  }) async {
    final response = await _client.put(
      '${ApiEndpoints.updateSubCategory}$id',
      data: {'cat_id': categoryId, 'sub_cat_name': name},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return SubCategoryModel.fromJson(data);
  }

  @override
  Future<SubCategoryModel> fetchSubCategoryDetails(int id) async {
    final response = await _client.get('${ApiEndpoints.showSubCategory}$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return SubCategoryModel.fromJson(data);
  }

  @override
  Future<SubCategoryModel> activateSubCategory(int id) async {
    final response = await _client.put(
      '${ApiEndpoints.activateSubCategory}$id',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return SubCategoryModel.fromJson(data);
  }

  @override
  Future<SubCategoryModel> deactivateSubCategory(int id) async {
    final response = await _client.put(
      '${ApiEndpoints.deactivateSubCategory}$id',
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return SubCategoryModel.fromJson(data);
  }

  @override
  Future<void> deleteSubCategory(int id) async {
    await _client.delete('${ApiEndpoints.deleteSubCategory}$id');
  }
}
