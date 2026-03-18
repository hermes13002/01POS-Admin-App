import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';

abstract class SalesRemoteDatasource {
  /// fetches sales list for a page
  Future<PaginatedSalesResponse> getSales({int page = 1});

  /// activate sales download
  Future<void> activateDownload(int companyId);

  /// deactivate sales download
  Future<void> deactivateDownload(int companyId);

  /// download sales data for a date range
  Future<List<SaleModel>> downloadSales({
    required String from,
    required String to,
  });
}

class SalesRemoteDatasourceImpl implements SalesRemoteDatasource {
  final DioClient _client;

  SalesRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedSalesResponse> getSales({int page = 1}) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.allSales}?page=$page';
    final body = <String, dynamic>{};

    log('get_all_sales url: $url', name: 'API');
    log('get_all_sales body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(
      ApiEndpoints.allSales,
      queryParameters: {'page': page},
      data: body,
    );
    final responseBody = _asMap(response.data);

    log('get_all_sales response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch sales',
      );
    }

    final rawData = responseBody['data'];

    final paginatedData = _asNullableMap(rawData);
    if (paginatedData != null) {
      return PaginatedSalesResponse.fromJson(paginatedData);
    }

    if (rawData is List) {
      final sales = rawData
          .map((item) => SaleModel.fromJson(_asMap(item)))
          .toList();

      return PaginatedSalesResponse(
        sales: sales,
        currentPage: 1,
        lastPage: 1,
        perPage: sales.length,
        total: sales.length,
        hasMorePages: false,
      );
    }

    throw ServerException(message: 'invalid sales response');
  }

  @override
  Future<void> activateDownload(int companyId) async {
    final url = '${ApiEndpoints.activateSalesDownload}$companyId';
    final response = await _client.get(url);
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to activate download',
      );
    }
  }

  @override
  Future<void> deactivateDownload(int companyId) async {
    final url = '${ApiEndpoints.deactivateSalesDownload}$companyId';
    final response = await _client.get(url);
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to deactivate download',
      );
    }
  }

  @override
  Future<List<SaleModel>> downloadSales({
    required String from,
    required String to,
  }) async {
    final body = {'from': from, 'to': to};
    final response = await _client.post(ApiEndpoints.downloadSales, data: body);
    final responseBody = _asMap(response.data);

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to download sales',
      );
    }

    final data = responseBody['data'];
    if (data is List) {
      return data.map((item) => SaleModel.fromJson(_asMap(item))).toList();
    }

    return [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  bool _isError(dynamic error) {
    return error == true || error?.toString().toLowerCase() == 'true';
  }
}
