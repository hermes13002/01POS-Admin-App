import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class PerformanceInterceptor extends Interceptor {
  final _metrics = <RequestOptions, HttpMetric>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kIsWeb) return super.onRequest(options, handler);

    try {
      final metric = FirebasePerformance.instance.newHttpMetric(
        options.uri.toString(),
        _mapMethod(options.method),
      );

      metric.start();
      _metrics[options] = metric;
    } catch (e) {
      debugPrint('failed to start performance metric: $e');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kIsWeb) return super.onResponse(response, handler);

    final metric = _metrics.remove(response.requestOptions);
    if (metric != null) {
      try {
        metric.httpResponseCode = response.statusCode;
        metric.responsePayloadSize = response.data?.toString().length;
        metric.stop();
      } catch (e) {
        debugPrint('failed to stop performance metric: $e');
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kIsWeb) return super.onError(err, handler);

    final metric = _metrics.remove(err.requestOptions);
    if (metric != null) {
      try {
        metric.httpResponseCode = err.response?.statusCode;
        metric.stop();
      } catch (e) {
        debugPrint('failed to stop performance metric: $e');
      }
    }

    super.onError(err, handler);
  }

  HttpMethod _mapMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'HEAD':
        return HttpMethod.Head;
      case 'OPTIONS':
        return HttpMethod.Options;
      default:
        return HttpMethod.Get;
    }
  }
}
