import 'dart:convert';
import 'dart:developer';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDatasource {
  Future<ApiResponse<PaginatedNotificationsResponse>> fetchNotifications({
    int page = 1,
  });
  Future<ApiResponse<NotificationDetailModel>> fetchNotificationDetail(int id);
  Future<ApiResponse<void>> markAsRead(int id);
  Future<ApiResponse<void>> deleteNotification(int id);
  Future<ApiResponse<void>> deleteAllReadNotifications();
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final DioClient _client;

  NotificationRemoteDatasourceImpl(this._client);

  @override
  Future<ApiResponse<PaginatedNotificationsResponse>> fetchNotifications({
    int page = 1,
  }) async {
    final queryParams = {'page': page};

    final url = '${AppConstants.baseUrl}${ApiEndpoints.notifications}';

    log('fetch_notifications url: $url', name: 'API');
    log('fetch_notifications params: ${jsonEncode(queryParams)}', name: 'API');

    final response = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: queryParams,
    );

    final responseBody = response.data as Map<String, dynamic>;

    log(
      'fetch_notifications response: ${jsonEncode(responseBody)}',
      name: 'API',
    );

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to fetch notifications',
      );
    }

    return ApiResponse<PaginatedNotificationsResponse>.fromJson(responseBody, (
      data,
    ) {
      if (data is List) {
        final notifications = data
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedNotificationsResponse(
          notifications: notifications,
          currentPage: 1,
          lastPage: 1,
          perPage: notifications.length,
          total: notifications.length,
          hasMorePages: false,
        );
      }
      return PaginatedNotificationsResponse.fromJson(
        data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<ApiResponse<NotificationDetailModel>> fetchNotificationDetail(
    int id,
  ) async {
    final response = await _client.get('${ApiEndpoints.viewNotification}$id');
    final responseBody = response.data as Map<String, dynamic>;

    if (responseBody['error'] == true) {
      throw ServerException(
        message:
            responseBody['message'] ?? 'Failed to fetch notification detail',
      );
    }

    return ApiResponse<NotificationDetailModel>.fromJson(
      responseBody,
      (data) => NotificationDetailModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> markAsRead(int id) async {
    final response = await _client.post('${ApiEndpoints.readNotification}$id');
    final responseBody = response.data as Map<String, dynamic>;

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to mark as read',
      );
    }
    return ApiResponse<void>.fromJson(responseBody, (data) => null);
  }

  @override
  Future<ApiResponse<void>> deleteNotification(int id) async {
    final response = await _client.delete(
      '${ApiEndpoints.deleteNotification}$id',
    );
    final responseBody = response.data as Map<String, dynamic>;

    if (responseBody['error'] == true) {
      throw ServerException(
        message: responseBody['message'] ?? 'Failed to delete notification',
      );
    }

    return ApiResponse<void>.fromJson(responseBody, (data) => null);
  }

  @override
  Future<ApiResponse<void>> deleteAllReadNotifications() async {
    final response = await _client.delete(
      ApiEndpoints.deleteAllReadNotifications,
    );
    final responseBody = response.data as Map<String, dynamic>;

    if (responseBody['error'] == true) {
      throw ServerException(
        message:
            responseBody['message'] ??
            'Failed to delete all read notifications',
      );
    }

    return ApiResponse<void>.fromJson(responseBody, (data) => null);
  }
}
