import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/customers/data/models/customer_model.dart';

abstract class CustomersRemoteDatasource {
  Future<PaginatedCustomersResponse> getCustomers({int page = 1});
  Future<CustomerModel> getCustomer(int customerId);
  Future<CustomerModel> createCustomer(Map<String, dynamic> body);
  Future<CustomerModel> updateCustomer(int customerId, Map<String, dynamic> body);
  Future<void> deleteCustomer(int customerId);
}

class CustomersRemoteDatasourceImpl implements CustomersRemoteDatasource {
  final DioClient _client;

  CustomersRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedCustomersResponse> getCustomers({int page = 1}) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.allCustomers}?page=$page';
    final body = <String, dynamic>{};

    log('get_customers url: $url', name: 'API');
    log('get_customers body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(
      ApiEndpoints.allCustomers,
      queryParameters: {'page': page},
      data: body,
    );

    final responseBody = _asMap(response.data);

    log('get_customers response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch customers',
      );
    }

    final rawData = responseBody['data'];

    final paginatedData = _asNullableMap(rawData);
    if (paginatedData != null) {
      return PaginatedCustomersResponse.fromJson(paginatedData);
    }

    if (rawData is List) {
      final customers = rawData
          .map((item) => CustomerModel.fromJson(_asMap(item)))
          .toList();

      return PaginatedCustomersResponse(
        customers: customers,
        currentPage: 1,
        lastPage: 1,
        perPage: customers.length,
        total: customers.length,
        hasMorePages: false,
      );
    }

    throw ServerException(message: 'invalid customers response');
  }

  @override
  Future<CustomerModel> getCustomer(int customerId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.showCustomer}/$customerId';
    final body = <String, dynamic>{};

    log('show_customer url: $url', name: 'API');
    log('show_customer body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get('${ApiEndpoints.showCustomer}/$customerId');
    final responseBody = _asMap(response.data);

    log('show_customer response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch customer',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid customer response');
    }

    return CustomerModel.fromJson(data);
  }

  @override
  Future<CustomerModel> createCustomer(Map<String, dynamic> body) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.storeCustomer}';

    log('create_customer url: $url', name: 'API');
    log('create_customer body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.storeCustomer, data: body);
    final responseBody = _asMap(response.data);

    log('create_customer response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to create customer',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    final nestedCustomer = _asNullableMap(data?['customer']);
    final customer = nestedCustomer ?? data;
    if (customer == null) {
      throw ServerException(message: 'invalid create customer response');
    }

    return CustomerModel.fromJson(customer);
  }

  @override
  Future<CustomerModel> updateCustomer(
    int customerId,
    Map<String, dynamic> body,
  ) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.updateCustomer}/$customerId';

    log('update_customer url: $url', name: 'API');
    log('update_customer body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.put(
      '${ApiEndpoints.updateCustomer}/$customerId',
      data: body,
    );
    final responseBody = _asMap(response.data);

    log('update_customer response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to update customer',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid update customer response');
    }

    return CustomerModel.fromJson(data);
  }

  @override
  Future<void> deleteCustomer(int customerId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.deleteCustomer}/$customerId';
    final body = <String, dynamic>{};

    log('delete_customer url: $url', name: 'API');
    log('delete_customer body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.delete('${ApiEndpoints.deleteCustomer}/$customerId');
    final responseBody = _asMap(response.data);

    log('delete_customer response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to delete customer',
      );
    }
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
