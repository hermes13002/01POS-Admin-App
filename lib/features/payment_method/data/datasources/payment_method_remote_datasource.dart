import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/payment_method/data/models/payment_method_model.dart';

abstract class PaymentMethodRemoteDatasource {
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<PaymentMethodModel> getPaymentMethod(int methodId);
  Future<PaymentMethodModel> createPaymentMethod(Map<String, dynamic> body);
  Future<PaymentMethodModel> updatePaymentMethod(
    int methodId,
    Map<String, dynamic> body,
  );
  Future<void> deletePaymentMethod(int methodId);
}

class PaymentMethodRemoteDatasourceImpl implements PaymentMethodRemoteDatasource {
  final DioClient _client;

  PaymentMethodRemoteDatasourceImpl(this._client);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.allPaymentMethods}';
    final body = <String, dynamic>{};

    log('get_payment_methods url: $url', name: 'API');
    log('get_payment_methods body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.allPaymentMethods, data: body);
    final responseBody = _asMap(response.data);

    log('get_payment_methods response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch payment methods',
      );
    }

    final data = responseBody['data'];
    if (data is List) {
      return data
          .map((item) => PaymentMethodModel.fromJson(_asMap(item)))
          .toList();
    }

    throw ServerException(message: 'invalid payment methods response');
  }

  @override
  Future<PaymentMethodModel> getPaymentMethod(int methodId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.showPaymentMethod}/$methodId';
    final body = <String, dynamic>{};

    log('show_payment_method url: $url', name: 'API');
    log('show_payment_method body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get('${ApiEndpoints.showPaymentMethod}/$methodId');
    final responseBody = _asMap(response.data);

    log('show_payment_method response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch payment method',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid payment method response');
    }

    return PaymentMethodModel.fromJson(data);
  }

  @override
  Future<PaymentMethodModel> createPaymentMethod(Map<String, dynamic> body) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.storePaymentMethod}';

    log('create_payment_method url: $url', name: 'API');
    log('create_payment_method body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.storePaymentMethod, data: body);
    final responseBody = _asMap(response.data);

    log('create_payment_method response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to create payment method',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid create payment method response');
    }

    return PaymentMethodModel.fromJson(data);
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(
    int methodId,
    Map<String, dynamic> body,
  ) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.updatePaymentMethod}/$methodId';

    log('update_payment_method url: $url', name: 'API');
    log('update_payment_method body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.put(
      '${ApiEndpoints.updatePaymentMethod}/$methodId',
      data: body,
    );
    final responseBody = _asMap(response.data);

    log('update_payment_method response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to update payment method',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid update payment method response');
    }

    return PaymentMethodModel.fromJson(data);
  }

  @override
  Future<void> deletePaymentMethod(int methodId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.deletePaymentMethod}/$methodId';
    final body = <String, dynamic>{};

    log('delete_payment_method url: $url', name: 'API');
    log('delete_payment_method body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.delete('${ApiEndpoints.deletePaymentMethod}/$methodId');
    final responseBody = _asMap(response.data);

    log('delete_payment_method response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to delete payment method',
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
