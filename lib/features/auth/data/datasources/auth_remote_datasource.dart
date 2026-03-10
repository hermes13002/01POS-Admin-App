import 'dart:developer';
import 'dart:convert';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponseModel> loginWithEmail(String email, String password);
  Future<LoginResponseModel> loginWithPin(String pin);
  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final DioClient _client;
  final SecureStorageService _storage;

  AuthRemoteDatasourceImpl(this._client, this._storage);

  @override
  Future<LoginResponseModel> loginWithEmail(
    String email,
    String password,
  ) async {
    final body = {'email': email, 'password': password};
    final url = '${AppConstants.baseUrl}${ApiEndpoints.login}';

    log('login_email url: $url', name: 'API');
    log('login_email body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.login, data: body);
    final responseBody = response.data as Map<String, dynamic>;

    log('login_email response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(message: responseBody['message'] ?? 'Login failed');
    }

    final loginResponse = LoginResponseModel.fromJson(responseBody['data']);
    await _persistToken(loginResponse);
    return loginResponse;
  }

  @override
  Future<LoginResponseModel> loginWithPin(String pin) async {
    final body = {'login_pin': pin};
    final url = '${AppConstants.baseUrl}${ApiEndpoints.login}';

    log('login_pin url: $url', name: 'API');
    log('login_pin body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.login, data: body);
    final responseBody = response.data as Map<String, dynamic>;

    log('login_pin response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(message: responseBody['message'] ?? 'Login failed');
    }

    final loginResponse = LoginResponseModel.fromJson(responseBody['data']);
    await _persistToken(loginResponse);
    return loginResponse;
  }

  @override
  Future<void> logout() async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.logout}';

    log('logout url: $url', name: 'API');

    final response = await _client.get(ApiEndpoints.logout);
    final responseBody = response.data as Map<String, dynamic>;

    log('logout response: ${jsonEncode(responseBody)}', name: 'API');
  }

  Future<void> _persistToken(LoginResponseModel response) async {
    await _storage.write(AppConstants.keyAccessToken, response.accessToken);
    await _storage.write(AppConstants.keyUserId, response.user.id.toString());
  }
}
