import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/online_store/data/models/receipt_template_model.dart';

abstract class ReceiptTemplateRemoteDatasource {
  Future<ReceiptTemplateModel> getReceiptTemplate();
  Future<ReceiptTemplateModel> updateReceiptTemplate(Map<String, dynamic> body);
}

class ReceiptTemplateRemoteDatasourceImpl implements ReceiptTemplateRemoteDatasource {
  final DioClient _client;

  ReceiptTemplateRemoteDatasourceImpl(this._client);

  @override
  Future<ReceiptTemplateModel> getReceiptTemplate() async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.receiptTemplate}';
    final body = <String, dynamic>{};

    log('get_receipt_template url: $url', name: 'API');
    log('get_receipt_template body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get(ApiEndpoints.receiptTemplate);
    final responseBody = _asMap(response.data);

    log('get_receipt_template response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch receipt template',
      );
    }

    final data = responseBody['data'];

    final directTemplate = _asNullableMap(data);
    if (directTemplate != null) {
      return ReceiptTemplateModel.fromJson(directTemplate);
    }

    if (data is List && data.isNotEmpty) {
      return ReceiptTemplateModel.fromJson(_asMap(data.first));
    }

    throw ServerException(message: 'invalid receipt template response');
  }

  @override
  Future<ReceiptTemplateModel> updateReceiptTemplate(
    Map<String, dynamic> body,
  ) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.receiptTemplate}';

    log('update_receipt_template url: $url', name: 'API');
    log('update_receipt_template body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.put(ApiEndpoints.receiptTemplate, data: body);
    final responseBody = _asMap(response.data);

    log('update_receipt_template response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to update receipt template',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid update receipt template response');
    }

    return ReceiptTemplateModel.fromJson(data);
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
