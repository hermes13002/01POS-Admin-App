import 'package:onepos_admin_app/data/models/base_model.dart';

/// Generic API response model
class ApiResponse<T> extends BaseModel {
  final bool? error;
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  // flattened meta for convenience
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  ApiResponse({
    this.error,
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  /// compatibility getter for pagination meta
  PaginationMeta? get meta => (currentPage != null || lastPage != null)
      ? PaginationMeta(
          currentPage: currentPage ?? 1,
          totalPages: lastPage ?? 1,
          totalItems: total ?? 0,
          itemsPerPage: perPage ?? 20,
        )
      : null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final bool isError = json['error'] ?? false;
    return ApiResponse<T>(
      error: isError,
      success: json['success'] ?? !isError,
      message: json['message'],
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      totalItems: json['total_items'] ?? json['totalItems'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? json['itemsPerPage'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
    };
  }
}
