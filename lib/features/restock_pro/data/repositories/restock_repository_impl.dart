import 'package:dio/dio.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../../domain/repositories/restock_repository.dart';
import '../models/restock_suggestion_model.dart';

class RestockRepositoryImpl implements RestockRepository {
  final DioClient _dioClient;

  RestockRepositoryImpl({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  @override
  Future<ApiResponse<List<RestockSuggestionModel>>> fetchRestockSuggestions({
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.restock}?page=$page',
      );
      final rawData = response.data;
      List<dynamic> list = [];

      if (rawData is Map<String, dynamic>) {
        if (rawData['suggestions'] is List) {
          list = rawData['suggestions'];
        } else if (rawData['data'] is List) {
          list = rawData['data'];
        } else if (rawData['data'] is Map<String, dynamic> &&
            rawData['data']['suggestions'] is List) {
          list = rawData['data']['suggestions'];
        }
      } else if (rawData is List) {
        list = rawData;
      }

      final suggestions = list
          .map(
            (e) => RestockSuggestionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      int? currentPage;
      int? lastPage;
      int? perPage;
      int? total;
      if (rawData is Map<String, dynamic>) {
        currentPage = rawData['current_page'] ?? rawData['currentPage'];
        lastPage = rawData['last_page'] ?? rawData['lastPage'];
        perPage = rawData['per_page'] ?? rawData['perPage'];
        total = rawData['total'];
      }

      return ApiResponse<List<RestockSuggestionModel>>(
        success: true,
        data: suggestions,
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: perPage,
        total: total,
      );
    } on DioException catch (e) {
      return ApiResponse<List<RestockSuggestionModel>>(
        success: false,
        message: _extractErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<List<RestockSuggestionModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // extract error message from dio exception
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
