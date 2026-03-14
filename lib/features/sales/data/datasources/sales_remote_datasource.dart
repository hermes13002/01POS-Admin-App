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
