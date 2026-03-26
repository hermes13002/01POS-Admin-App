import 'package:dio/dio.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import 'package:onepos_admin_app/features/bill/data/datasources/auto_bill_remote_datasource.dart';
import 'package:onepos_admin_app/features/bill/data/models/auto_bill_model.dart';
import 'package:onepos_admin_app/features/bill/domain/repositories/auto_bill_repository.dart';

class AutoBillRepositoryImpl implements AutoBillRepository {
  final AutoBillRemoteDataSource _remoteDataSource;

  AutoBillRepositoryImpl({AutoBillRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AutoBillRemoteDataSource();

  @override
  Future<ApiResponse<List<AutoBillModel>>> fetchAutoBills({
    int page = 1,
  }) async {
    try {
      final response = await _remoteDataSource.fetchAutoBills(page: page);

      return ApiResponse<List<AutoBillModel>>.fromJson(response.data, (data) {
        final items = data['data'] as List? ?? [];
        return items.map((e) => AutoBillModel.fromJson(e)).toList();
      });
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<List<AutoBillModel>>(success: false, message: message);
    } catch (e) {
      return ApiResponse<List<AutoBillModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResponse<AutoBillModel>> fetchAutoBill(int id) async {
    try {
      final response = await _remoteDataSource.fetchAutoBill(id);

      return ApiResponse<AutoBillModel>.fromJson(
        response.data,
        (data) => AutoBillModel.fromJson(data),
      );
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<AutoBillModel>(success: false, message: message);
    } catch (e) {
      return ApiResponse<AutoBillModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<List<BillOptionModel>>> fetchBillOptions() async {
    try {
      final response = await _remoteDataSource.fetchBillOptions();

      return ApiResponse<List<BillOptionModel>>.fromJson(response.data, (data) {
        final items = data as List? ?? [];
        return items.map((e) => BillOptionModel.fromJson(e)).toList();
      });
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<List<BillOptionModel>>(
        success: false,
        message: message,
      );
    } catch (e) {
      return ApiResponse<List<BillOptionModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResponse<AutoBillModel>> addAutoBill(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.addAutoBill(data);

      return ApiResponse<AutoBillModel>.fromJson(
        response.data,
        (data) => AutoBillModel.fromJson(data),
      );
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<AutoBillModel>(success: false, message: message);
    } catch (e) {
      return ApiResponse<AutoBillModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AutoBillModel>> updateAutoBill(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _remoteDataSource.updateAutoBill(id, data);

      return ApiResponse<AutoBillModel>.fromJson(
        response.data,
        (data) => AutoBillModel.fromJson(data),
      );
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<AutoBillModel>(success: false, message: message);
    } catch (e) {
      return ApiResponse<AutoBillModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteAutoBill(int id) async {
    try {
      final response = await _remoteDataSource.deleteAutoBill(id);

      return ApiResponse<void>(
        success: response.data?['error'] == false,
        message: response.data?['message'] ?? 'Deleted successfully',
      );
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<void>(success: false, message: message);
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AutoBillModel>> activateAutoBill(int id) async {
    try {
      final response = await _remoteDataSource.activateAutoBill(id);

      return ApiResponse<AutoBillModel>.fromJson(
        response.data,
        (data) => AutoBillModel.fromJson(data),
      );
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<AutoBillModel>(success: false, message: message);
    } catch (e) {
      return ApiResponse<AutoBillModel>(success: false, message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AutoBillModel>> deactivateAutoBill(int id) async {
    try {
      final response = await _remoteDataSource.deactivateAutoBill(id);

      return ApiResponse<AutoBillModel>.fromJson(
        response.data,
        (data) => AutoBillModel.fromJson(data),
      );
    } on DioException catch (e) {
      String message =
          e.response?.data?['message'] ?? e.message ?? 'An error occurred';
      final data = e.response?.data?['data'];
      if (data is List && data.isNotEmpty) {
        message = data.join('\n');
      }
      return ApiResponse<AutoBillModel>(success: false, message: message);
    } catch (e) {
      return ApiResponse<AutoBillModel>(success: false, message: e.toString());
    }
  }
}
