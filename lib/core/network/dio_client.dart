import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/network/interceptors/auth_interceptor.dart';
import 'package:onepos_admin_app/core/network/interceptors/logging_interceptor.dart';
import 'package:onepos_admin_app/core/network/interceptors/performance_interceptor.dart';
import 'package:onepos_admin_app/core/services/firebase_service.dart';

/// Dio client for making HTTP requests
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'App-Client': 'mobile',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      PerformanceInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return NetworkException(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'No internet connection. Please check your network settings.',
        );
      default:
        final exception = ServerException(
          message: error.message ?? 'An unexpected error occurred',
        );
        FirebaseService().logError(
          exception,
          error.stackTrace,
          reason: 'Dio unexpected error',
        );
        return exception;
    }
  }

  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final dynamic rawMessage = error.response?.data?['message'];
    String message = 'An error occurred';

    if (rawMessage is String) {
      message = rawMessage;
    } else if (rawMessage is List) {
      message = rawMessage.join(', ');
    } else if (error.response?.statusMessage != null) {
      message = error.response!.statusMessage!;
    }

    switch (statusCode) {
      case 401:
        return AuthenticationException(
          message: message,
          statusCode: statusCode,
        );
      case 403:
        return AuthenticationException(
          message: 'Access forbidden',
          statusCode: statusCode,
        );
      case 404:
        return ServerException(
          message: 'Resource not found',
          statusCode: statusCode,
        );
      case 422:
        return ValidationException(message: message);
      case 500:
        return ServerException(
          message: 'Internal server error',
          statusCode: statusCode,
        );
      default:
        final exception = ServerException(
          message: message,
          statusCode: statusCode,
        );
        FirebaseService().logError(
          exception,
          StackTrace.current,
          reason: 'Dio response error: $statusCode',
        );
        return exception;
    }
  }
}
