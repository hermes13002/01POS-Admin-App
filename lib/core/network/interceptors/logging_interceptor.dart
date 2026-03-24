import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// Interceptor for logging HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_shouldLog(options.path)) {
      return handler.next(options);
    }

    developer.log('┌──────────────', name: 'HTTP REQUEST');
    developer.log('│ ${options.method} ${options.uri}', name: 'HTTP REQUEST');
    developer.log('│ Headers:', name: 'HTTP REQUEST');
    options.headers.forEach((key, value) {
      developer.log('│   $key: $value', name: 'HTTP REQUEST');
    });
    if (options.data != null) {
      developer.log('│ Body: ${options.data}', name: 'HTTP REQUEST');
    }
    developer.log('└──────────────', name: 'HTTP REQUEST');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_shouldLog(response.requestOptions.path)) {
      return handler.next(response);
    }

    developer.log('┌──────────────', name: 'HTTP RESPONSE');
    developer.log(
      '│ ${response.statusCode} ${response.requestOptions.uri}',
      name: 'HTTP RESPONSE',
    );
    developer.log('│ Response: ${response.data}', name: 'HTTP RESPONSE');
    developer.log('└──────────────', name: 'HTTP RESPONSE');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_shouldLog(err.requestOptions.path)) {
      return handler.next(err);
    }

    developer.log('┌──────────────', name: 'HTTP ERROR');
    developer.log(
      '│ ${err.requestOptions.method} ${err.requestOptions.uri}',
      name: 'HTTP ERROR',
    );
    developer.log('│ Error: ${err.message}', name: 'HTTP ERROR');
    if (err.response != null) {
      developer.log(
        '│ Status: ${err.response?.statusCode}',
        name: 'HTTP ERROR',
      );
      developer.log('│ Data: ${err.response?.data}', name: 'HTTP ERROR');
    }
    developer.log('└──────────────', name: 'HTTP ERROR');
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
