import 'dart:convert';
import 'dart:developer';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../models/expense_metadata_model.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDatasource {
  Future<ApiResponse<List<ExpenseModel>>> fetchExpenses({
    int page = 1,
    String? search,
  });

  Future<ApiResponse<ExpenseModel>> createExpense(Map<String, dynamic> body);

  Future<ApiResponse<ExpenseModel>> updateExpense(
    int id,
    Map<String, dynamic> body,
  );

  Future<ApiResponse<ExpenseMetadataModel>> fetchMetadata();

  Future<ApiResponse<void>> deleteExpense(int id);
}

class ExpenseRemoteDatasourceImpl implements ExpenseRemoteDatasource {
  final DioClient _client;

  ExpenseRemoteDatasourceImpl(this._client);

  @override
  Future<ApiResponse<ExpenseModel>> createExpense(
    Map<String, dynamic> body,
  ) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.expenses}';

    log('create_expense url: $url', name: 'API');
    log('create_expense body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.expenses, data: body);

    final responseBody = response.data as Map<String, dynamic>;

    log('create_expense response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to create expense',
      );
    }

    return ApiResponse<ExpenseModel>.fromJson(
      responseBody,
      (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ExpenseModel>> updateExpense(
    int id,
    Map<String, dynamic> body,
  ) async {
    final url =
        '${AppConstants.baseUrl}${ApiEndpoints.expenseById.replaceAll('{id}', id.toString())}';

    log('update_expense url: $url', name: 'API');
    log('update_expense body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.put(
      ApiEndpoints.expenseById.replaceAll('{id}', id.toString()),
      data: body,
    );

    final responseBody = response.data as Map<String, dynamic>;

    log('update_expense response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to update expense',
      );
    }

    return ApiResponse<ExpenseModel>.fromJson(
      responseBody,
      (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<ExpenseMetadataModel>> fetchMetadata() async {
    const url = '${AppConstants.baseUrl}${ApiEndpoints.expenseMetadata}';

    log('fetch_metadata url: $url', name: 'API');

    final response = await _client.get(ApiEndpoints.expenseMetadata);
    final responseBody = response.data as Map<String, dynamic>;

    log('fetch_metadata response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch metadata',
      );
    }

    return ApiResponse<ExpenseMetadataModel>.fromJson(
      responseBody,
      (data) => ExpenseMetadataModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> deleteExpense(int id) async {
    final url =
        '${AppConstants.baseUrl}${ApiEndpoints.expenseById.replaceFirst('{id}', id.toString())}';

    log('[API] delete_expense url: $url', name: 'API');

    final response = await _client.delete(
      ApiEndpoints.expenseById.replaceFirst('{id}', id.toString()),
    );
    final responseBody = response.data as Map<String, dynamic>;

    log(
      '[API] delete_expense response: ${jsonEncode(responseBody)}',
      name: 'API',
    );

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to delete expense',
      );
    }

    return ApiResponse<void>.fromJson(responseBody, (_) => null);
  }

  @override
  Future<ApiResponse<List<ExpenseModel>>> fetchExpenses({
    int page = 1,
    String? search,
  }) async {
    final queryParams = {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final url = '${AppConstants.baseUrl}${ApiEndpoints.expenses}';

    log('fetch_expenses url: $url', name: 'API');
    log('fetch_expenses params: ${jsonEncode(queryParams)}', name: 'API');

    final response = await _client.get(
      ApiEndpoints.expenses,
      queryParameters: queryParams,
    );

    final responseBody = response.data as Map<String, dynamic>;

    log('fetch_expenses response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch expenses',
      );
    }

    return ApiResponse<List<ExpenseModel>>.fromJson(
      responseBody,
      (data) => (data as List)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
