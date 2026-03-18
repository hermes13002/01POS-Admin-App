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

  /// creates a user
  Future<UserModel> createUser(Map<String, dynamic> body);

  /// updates a user
  Future<UserModel> updateUser(int userId, Map<String, dynamic> body);

  /// activates a user by id
  Future<UserModel> activateUser(int userId);

  /// deactivates a user by id
  Future<UserModel> deactivateUser(int userId);

  /// fetches a single user by id
  Future<UserModel> getUser(int userId);

  /// deletes a user by id
  Future<void> deleteUser(int userId);

  /// fetches roles
  Future<List<RoleModel>> getRoles();
}

class UsersRemoteDatasourceImpl implements UsersRemoteDatasource {
  final DioClient _client;

  UsersRemoteDatasourceImpl(this._client);

  @override
  Future<PaginatedUsersResponse> getUsers({int page = 1}) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.allUsers}?page=$page';
    final body = {'page': page};

    log('get_users url: $url', name: 'API');
    log('get_users body: ${jsonEncode(body)}', name: 'API');

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
  Future<UserModel> createUser(Map<String, dynamic> body) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.storeUser}';

    log('create_user url: $url', name: 'API');
    log('create_user body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.post(ApiEndpoints.storeUser, data: body);
    final responseBody = response.data as Map<String, dynamic>;

    log('create_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to create user',
      );
    }

    return UserModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateUser(int userId, Map<String, dynamic> body) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.updateUser}/$userId';

    log('update_user url: $url', name: 'API');
    log('update_user body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.put(
      '${ApiEndpoints.updateUser}/$userId',
      data: body,
    );
    final responseBody = response.data as Map<String, dynamic>;

    log('update_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to update user',
      );
    }

    return UserModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> activateUser(int userId) async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.activateUser}/$userId';
    final body = <String, dynamic>{};

    log('activate_user url: $url', name: 'API');
    log('activate_user body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get('${ApiEndpoints.activateUser}/$userId');
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
    final url = '${AppConstants.baseUrl}${ApiEndpoints.deactivateUser}/$userId';
    final body = <String, dynamic>{};

    log('deactivate_user url: $url', name: 'API');
    log('deactivate_user body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.get(
      '${ApiEndpoints.deactivateUser}/$userId',
    );
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
    final body = <String, dynamic>{};

    log('get_user url: $url', name: 'API');
    log('get_user body: ${jsonEncode(body)}', name: 'API');

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
    final body = <String, dynamic>{};

    log('delete_user url: $url', name: 'API');
    log('delete_user body: ${jsonEncode(body)}', name: 'API');

    final response = await _client.delete('${ApiEndpoints.deleteUser}/$userId');
    final responseBody = response.data as Map<String, dynamic>;

    log('delete_user response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to delete user',
      );
    }
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    final url = '${AppConstants.baseUrl}${ApiEndpoints.getRoles}';

    log('get_roles url: $url', name: 'API');

    final response = await _client.get(ApiEndpoints.getRoles);
    final responseBody = response.data as Map<String, dynamic>;

    log('get_roles response: ${jsonEncode(responseBody)}', name: 'API');

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch roles',
      );
    }

    final rolesList = responseBody['data'] as List<dynamic>? ?? [];

    return rolesList
        .map((r) => RoleModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
