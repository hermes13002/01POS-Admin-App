import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor for logging HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_shouldLog(options.path)) {
      return handler.next(options);
    }

    debugPrint('[REQUEST] ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('[REQUEST] Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_shouldLog(response.requestOptions.path)) {
      return handler.next(response);
    }

    debugPrint(
      '[SUCCESS] ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('[SUCCESS] Response: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_shouldLog(err.requestOptions.path)) {
      return handler.next(err);
    }

    debugPrint(
      '[FAILURE] ${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    debugPrint('[FAILURE] Error: ${err.message}');
    if (err.response != null) {
      debugPrint('[FAILURE] Status: ${err.response?.statusCode}');
      debugPrint('[FAILURE] Data: ${err.response?.data}');
    }
    handler.next(err);
  }

  /// Check if the request should be logged
  bool _shouldLog(String path) {
    // Disable logging for chat endpoints to reduce console noise during polling
    if (path.contains('/chats/')) {
      return false;
    }
    return true;
  }
}
