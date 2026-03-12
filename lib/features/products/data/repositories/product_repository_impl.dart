import 'package:dio/dio.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import 'package:onepos_admin_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _remoteDatasource;

  ProductRepositoryImpl({ProductRemoteDatasource? remoteDatasource})
    : _remoteDatasource = remoteDatasource ?? ProductRemoteDatasource();

  @override
  Future<ApiResponse<List<ProductModel>>> fetchProducts(int page) async {
    try {
      final response = await _remoteDatasource.fetchProducts(page);

      return ApiResponse<List<ProductModel>>.fromJson(response.data, (data) {
        final items = data['data'] as List;
        return items.map((e) => ProductModel.fromJson(e)).toList();
      });
    } on DioException catch (e) {
      return ApiResponse<List<ProductModel>>(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'An error occurred',
      );
    } catch (e) {
      return ApiResponse<List<ProductModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResponse<ProductModel>> fetchSingleProduct(int id) async {
    try {
      final response = await _remoteDatasource.fetchSingleProduct(id);

      return ApiResponse<ProductModel>.fromJson(
        response.data,
        (data) => ProductModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<ProductModel>(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'An error occurred',
      );
    } catch (e) {
      return ApiResponse<ProductModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteProduct(int id) async {
    try {
      final response = await _remoteDatasource.deleteProduct(id);

      return ApiResponse<void>.fromJson(response.data, (_) => null);
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'An error occurred',
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<ProductModel>> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDatasource.updateProduct(id, data);

      return ApiResponse<ProductModel>.fromJson(
        response.data,
        (data) => ProductModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<ProductModel>(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'An error occurred',
      );
    } catch (e) {
      return ApiResponse<ProductModel>(success: false, message: e.toString());
    }
  }
}
