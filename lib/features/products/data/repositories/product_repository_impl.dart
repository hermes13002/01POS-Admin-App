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
        message: _extractErrorMessage(e),
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
        message: _extractErrorMessage(e),
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
        message: _extractErrorMessage(e),
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
        message: _extractErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<ProductModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<ProductModel>> addProduct(
    Map<String, dynamic> data,
  ) async {
    try {
      final formDataMap = <String, dynamic>{...data};

      // Handle image if present
      if (data['product_image'] != null &&
          data['product_image'] is String &&
          data['product_image'].toString().isNotEmpty) {
        final imagePath = data['product_image'] as String;
        formDataMap['product_image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      } else {
        formDataMap.remove('product_image');
      }

      final response = await _remoteDatasource.addProduct(
        FormData.fromMap(formDataMap),
      );

      return ApiResponse<ProductModel>.fromJson(
        response.data,
        (data) => ProductModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<ProductModel>(
        success: false,
        message: _extractErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<ProductModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> setLowStockLimit(int companyId, int limit) async {
    try {
      final response = await _remoteDatasource.setLowStockLimit(
        companyId,
        limit,
      );
      return ApiResponse<void>(
        success: response.data['error'] == false,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: _extractErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<ProductModel>>> fetchLowStockProducts({
    int page = 1,
  }) async {
    try {
      final response = await _remoteDatasource.fetchLowStockProducts(
        page: page,
      );
      final rawData = response.data['data'];

      List<dynamic> list;
      if (rawData is Map<String, dynamic>) {
        list = rawData['data'] as List<dynamic>? ?? [];
      } else {
        list = rawData as List<dynamic>? ?? [];
      }

      final products = list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse<List<ProductModel>>(
        success: response.data['error'] == false,
        message: response.data['message'],
        data: products,
      );
    } on DioException catch (e) {
      return ApiResponse<List<ProductModel>>(
        success: false,
        message: _extractErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<List<ProductModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map;
      final message = data['message'];
      if (message is String) return message;
      if (message is Map) {
        return message['message']?.toString() ??
            message.values.firstOrNull?.toString() ??
            'An error occurred';
      }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.firstOrNull;
        if (firstError is List) {
          return firstError.firstOrNull?.toString() ?? 'An error occurred';
        }
        return firstError?.toString() ?? 'An error occurred';
      }
    }
    return e.message ?? 'An error occurred';
  }
}
