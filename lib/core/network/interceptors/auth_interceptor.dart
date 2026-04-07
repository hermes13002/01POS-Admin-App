import 'package:dio/dio.dart';
import 'package:onepos_admin_app/core/constants/api_endpoints.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/utils/session_manager.dart';

/// interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // get access token from secure storage
    final token = await _secureStorage.read(AppConstants.keyAccessToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // skip session-expiry handling for login and logout endpoints
      final path = err.requestOptions.path;
      if (!path.contains(ApiEndpoints.login) &&
          !path.contains(ApiEndpoints.logout)) {
        SessionManager.handleSessionExpired();
      }
    }
    handler.next(err);
  }
}
