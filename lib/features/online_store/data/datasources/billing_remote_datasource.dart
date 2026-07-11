import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';

abstract class BillingRemoteDatasource {
  Future<void> upgradePlan({
    required int amount,
    required int months,
    required String plan,
    required String status,
    String? productId,
    String? transactionId,
    String? purchaseId,
  });
}

class BillingRemoteDatasourceImpl implements BillingRemoteDatasource {
  final DioClient _client;

  BillingRemoteDatasourceImpl(this._client);

  @override
  Future<void> upgradePlan({
    required int amount,
    required int months,
    required String plan,
    required String status,
    String? productId,
    String? transactionId,
    String? purchaseId,
  }) async {
    final endpoint = ApiEndpoints.billingUpgrade;
    final url = '${AppConstants.baseUrl}$endpoint';
    final body = <String, dynamic>{
      'amount': amount,
      'months': months,
      'plan': plan,
      'status': status,
      if (productId != null) 'product_id': productId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (purchaseId != null) 'purchase_id': purchaseId,
    };

    log('billing_upgrade url: $url', name: 'API');
    log('billing_upgrade body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(endpoint, data: body);
    final responseBody = _asMap(response.data);

    log('billing_upgrade response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to upgrade billing plan',
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  bool _isError(dynamic error) {
    return error == true || error?.toString().toLowerCase() == 'true';
  }
}
