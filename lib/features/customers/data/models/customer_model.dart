/// model for a customer
class CustomerModel {
  final int id;
  final String name;
  final String? address;
  final String? gender;
  final String? comment;
  final String? preference;
  final bool isActive;
  final double loyaltyPoint;
  final String? createdAt;
  final String? updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.address,
    this.gender,
    this.comment,
    this.preference,
    this.isActive = true,
    this.loyaltyPoint = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final loyaltyList = json['customer_loyalty_point'] as List<dynamic>? ?? [];
    final loyalty = loyaltyList.isNotEmpty
        ? _toDouble(_asMap(loyaltyList.first)['total_point'])
        : 0.0;

    return CustomerModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      comment: json['comment']?.toString(),
      preference: json['preference']?.toString(),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      loyaltyPoint: loyalty,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? address,
    String? gender,
    String? comment,
    String? preference,
    bool? isActive,
    double? loyaltyPoint,
    String? createdAt,
    String? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      comment: comment ?? this.comment,
      preference: preference ?? this.preference,
      isActive: isActive ?? this.isActive,
      loyaltyPoint: loyaltyPoint ?? this.loyaltyPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

/// paginated response wrapper for customers
class PaginatedCustomersResponse {
  final List<CustomerModel> customers;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  const PaginatedCustomersResponse({
    required this.customers,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginatedCustomersResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final currentPage = json['current_page'] is int
        ? json['current_page'] as int
        : int.tryParse(json['current_page']?.toString() ?? '') ?? 1;
    final lastPage = json['last_page'] is int
        ? json['last_page'] as int
        : int.tryParse(json['last_page']?.toString() ?? '') ?? 1;
    final perPage = json['per_page'] is int
        ? json['per_page'] as int
        : int.tryParse(json['per_page']?.toString() ?? '') ?? 10;
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? 0;

    return PaginatedCustomersResponse(
      customers: list
          .map((item) => CustomerModel.fromJson(CustomerModel._asMap(item)))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasMorePages: currentPage < lastPage,
    );
  }
}

/// state holder for customers list pagination
class CustomersState {
  final List<CustomerModel> customers;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool hasMorePages;

  const CustomersState({
    this.customers = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.hasMorePages = true,
  });

  CustomersState copyWith({
    List<CustomerModel>? customers,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? hasMorePages,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}
