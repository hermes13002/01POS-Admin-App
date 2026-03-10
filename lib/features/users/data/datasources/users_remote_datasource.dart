import 'dart:convert';
import 'dart:developer';

import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';

abstract class UsersRemoteDatasource {
  /// fetches users from the api for a given page
  Future<PaginatedUsersResponse> getUsers({int page = 1});

  /// activates a user by id
  Future<UserModel> activateUser(int userId);

  /// deactivates a user by id
  Future<UserModel> deactivateUser(int userId);

  /// fetches a single user by id
  Future<UserModel> getUser(int userId);

  /// deletes a user by id
  Future<void> deleteUser(int userId);
}

class UsersRemoteDatasourceImpl implements UsersRemoteDatasource {
  final DioClient _client;

  UsersRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedUsersResponse> getUsers({int page = 1}) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.allUsers}?page=$page';

    log('get_users url: $url', name: 'API');

    final response = await _client.post(
      ApiEndpoints.allUsers,
      queryParameters: {'page': page},
    );
    final responseBody = response.data as Map<String, dynamic>;

    log('get_users response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch users',
      );
    }

    final paginatedData = responseBody['data'] as Map<String, dynamic>;

    return PaginatedUsersResponse.fromJson(paginatedData);
  }

  @override
  Future<UserModel> activateUser(int userId) async {
    final url =
        '${AppConstants.baseUrl}${ApiEndpoints.activateUser}/$userId';

    log('activate_user url: $url', name: 'API');

    final response =
        await _client.get('${ApiEndpoints.activateUser}/$userId');
    final responseBody = response.data as Map<String, dynamic>;

    log('activate_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to activate user',
      );
    }

    return UserModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> deactivateUser(int userId) async {
    final url =
        '${AppConstants.baseUrl}${ApiEndpoints.deactivateUser}/$userId';

    log('deactivate_user url: $url', name: 'API');

    final response =
        await _client.get('${ApiEndpoints.deactivateUser}/$userId');
    final responseBody = response.data as Map<String, dynamic>;

    log('deactivate_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to deactivate user',
      );
    }

    return UserModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getUser(int userId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.showUser}/$userId';

    log('get_user url: $url', name: 'API');

    final response = await _client.get('${ApiEndpoints.showUser}/$userId');
    final responseBody = response.data as Map<String, dynamic>;

    log('get_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch user',
      );
    }

    return UserModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteUser(int userId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.deleteUser}/$userId';

    log('delete_user url: $url', name: 'API');

    final response =
        await _client.delete('${ApiEndpoints.deleteUser}/$userId');
    final responseBody = response.data as Map<String, dynamic>;

    log('delete_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to delete user',
      );
    }
  }
}
