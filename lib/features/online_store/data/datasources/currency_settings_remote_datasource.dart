import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/online_store/data/models/company_currency_setting_model.dart';
import 'package:onepos_admin_app/features/online_store/data/models/currency_model.dart';

abstract class CurrencySettingsRemoteDatasource {
  Future<List<CurrencyModel>> getAllCurrencies();
  Future<CompanyCurrencySettingModel> getCompanyCurrency();
  Future<void> updateCompanyCurrency({
    required int settingId,
    required String currencyId,
  });
}

class CurrencySettingsRemoteDatasourceImpl
    implements CurrencySettingsRemoteDatasource {
  final DioClient _client;

  CurrencySettingsRemoteDatasourceImpl(this._client);

  @override
  Future<List<CurrencyModel>> getAllCurrencies() async {
    final url =
        '${AppConstants.baseUrl}${ApiEndpoints.currencySettingsCurrencies}';
    final body = <String, dynamic>{};

    log('get_all_currencies url: $url', name: 'API');
    log('get_all_currencies body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get(ApiEndpoints.currencySettingsCurrencies);
    final responseBody = _asMap(response.data);

    log('get_all_currencies response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch currencies',
      );
    }

    final list = responseBody['data'];
    if (list is! List) {
      throw ServerException(message: 'invalid currencies response');
    }

    return list
        .map((item) => CurrencyModel.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  @override
  Future<CompanyCurrencySettingModel> getCompanyCurrency() async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.currencySettings}';
    final body = <String, dynamic>{};

    log('get_company_currency url: $url', name: 'API');
    log('get_company_currency body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get(ApiEndpoints.currencySettings);
    final responseBody = _asMap(response.data);

    log('get_company_currency response: ${jsonEncode(responseBody)}', name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to fetch company currency',
      );
    }

    final data = _asNullableMap(responseBody['data']);
    if (data == null) {
      throw ServerException(message: 'invalid company currency response');
    }

    return CompanyCurrencySettingModel.fromJson(data);
  }

  @override
  Future<void> updateCompanyCurrency({
    required int settingId,
    required String currencyId,
  }) async {
    final endpoint = '${ApiEndpoints.currencySettingsUpdate}/$settingId';
    final url = '${AppConstants.baseUrl}$endpoint';
    final body = {'currency_id': currencyId};

    log('update_company_currency url: $url', name: 'API');
    log('update_company_currency body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.put(endpoint, data: body);
    final responseBody = _asMap(response.data);

    log('update_company_currency response: ${jsonEncode(responseBody)}',
        name: 'API');

    if (_isError(responseBody['error'])) {
      throw ServerException(
        message: responseBody['message'] ?? 'failed to update company currency',
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
