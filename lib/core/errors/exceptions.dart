/// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

/// Server exception - API errors
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.statusCode,
  });
}

/// Cache exception - Local storage errors
class CacheException extends AppException {
  CacheException({
    required super.message,
  });
}

/// Network exception - Connection errors
class NetworkException extends AppException {
  NetworkException({
    required super.message,
  });
}

/// Authentication exception
class AuthenticationException extends AppException {
  AuthenticationException({
    required super.message,
    super.statusCode,
  });
}

/// Validation exception
class ValidationException extends AppException {
  ValidationException({
    required super.message,
  });
}
