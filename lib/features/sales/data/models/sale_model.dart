/// model for a sale order
class SaleModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String cashierName;
  final String? cashierEmail;
  final String? cashierPhone;
  final double totalAmount;
  final DateTime date;
  final String status;
  final String? customerAddress;
  final List<SaleItem> items;
  final String? paymentMethod;
  final String? discountApplied;
  final double? loyaltyApplied;
  final double? totalPrice;

  const SaleModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.cashierName,
    this.cashierEmail,
    this.cashierPhone,
    required this.totalAmount,
    required this.date,
    required this.status,
    this.customerAddress,
    this.items = const [],
    this.paymentMethod,
    this.discountApplied,
    this.loyaltyApplied,
    this.totalPrice,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final orderDetails = json['orderdetails'] as List<dynamic>? ?? [];
    final userJson = _asMap(json['user']);
    final customerJson = _asMap(json['customer']);

    final customerName =
        customerJson['name']?.toString() ??
        'Customer #${json['customer_id']?.toString() ?? 'N/A'}';

    return SaleModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNO']?.toString() ?? 'N/A',
      customerName: customerName,
      cashierName:
          '${userJson['firstname']?.toString() ?? ''} ${userJson['lastname']?.toString() ?? ''}'
              .trim()
              .isEmpty
          ? 'N/A'
          : '${userJson['firstname']?.toString() ?? ''} ${userJson['lastname']?.toString() ?? ''}'
                .trim(),
      cashierEmail: userJson['email']?.toString(),
      cashierPhone: userJson['phoneno']?.toString(),
      totalAmount: _toDouble(json['total_price']),
      totalPrice: _toDouble(json['total_price']),
      date:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'N/A',
      customerAddress: customerJson['address']?.toString(),
      paymentMethod: json['payment_type']?.toString(),
      discountApplied: null,
      loyaltyApplied: null,
      items: orderDetails
          .map((item) => SaleItem.fromJson(_asMap(item)))
          .toList(),
    );
  }

  SaleModel copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? cashierName,
    String? cashierEmail,
    String? cashierPhone,
    double? totalAmount,
    DateTime? date,
    String? status,
    String? customerAddress,
    List<SaleItem>? items,
    String? paymentMethod,
    String? discountApplied,
    double? loyaltyApplied,
    double? totalPrice,
  }) {
    return SaleModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      cashierName: cashierName ?? this.cashierName,
      cashierEmail: cashierEmail ?? this.cashierEmail,
      cashierPhone: cashierPhone ?? this.cashierPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      status: status ?? this.status,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discountApplied: discountApplied ?? this.discountApplied,
      loyaltyApplied: loyaltyApplied ?? this.loyaltyApplied,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  static int _asInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
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

/// model for an individual sale item
class SaleItem {
  final String productName;
  final int quantity;
  final double unitPrice;

  const SaleItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productName: json['product_name']?.toString() ?? 'N/A',
      quantity: json['quantity_ordered'] is int
          ? json['quantity_ordered'] as int
          : int.tryParse(json['quantity_ordered']?.toString() ?? '') ?? 0,
      unitPrice: SaleModel._toDouble(json['unit_price']),
    );
  }

  double get total => quantity * unitPrice;
}

/// paginated response wrapper for sales
class PaginatedSalesResponse {
  final List<SaleModel> sales;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  const PaginatedSalesResponse({
    required this.sales,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginatedSalesResponse.fromJson(Map<String, dynamic> json) {
    // Some endpoints wrap the pagination object in 'data', others return it directly
    final rawData = json['data'];
    final bool isDataMap = rawData is Map<String, dynamic>;
    final Map<String, dynamic> paginationSource = isDataMap ? rawData : json;

    // The actual items list can be in paginationSource['data'] or rawData (if it was already a list)
    final salesListValue = (paginationSource['data'] is List)
        ? paginationSource['data'] as List<dynamic>
        : (rawData is List ? rawData : []);

    final int currentPage = SaleModel._asInt(
      paginationSource['current_page'],
      1,
    );
    final int lastPage = SaleModel._asInt(paginationSource['last_page'], 1);
    final int perPage = SaleModel._asInt(paginationSource['per_page'], 10);
    final int total = SaleModel._asInt(
      paginationSource['total'],
      salesListValue.length,
    );

    return PaginatedSalesResponse(
      sales: salesListValue
          .map((s) => SaleModel.fromJson(SaleModel._asMap(s)))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasMorePages: currentPage < lastPage,
    );
  }
}

/// state holder for sales list pagination
class SalesState {
  final List<SaleModel> sales;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool hasMorePages;
  final bool isDownloadEnabled;

  const SalesState({
    this.sales = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.hasMorePages = true,
    this.isDownloadEnabled = false,
  });

  SalesState copyWith({
    List<SaleModel>? sales,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? hasMorePages,
    bool? isDownloadEnabled,
  }) {
    return SalesState(
      sales: sales ?? this.sales,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isDownloadEnabled: isDownloadEnabled ?? this.isDownloadEnabled,
    );
  }
}

/// model for sales filter options
class SalesFilter {
  final double? minPrice;
  final double? maxPrice;
  final String? cashier;
  final String? customer;
  final String? discount;
  final String? paymentMethod;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const SalesFilter({
    this.minPrice,
    this.maxPrice,
    this.cashier,
    this.customer,
    this.discount,
    this.paymentMethod,
    this.status,
    this.startDate,
    this.endDate,
  });

  /// check if any filter is active
  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      cashier != null ||
      customer != null ||
      discount != null ||
      paymentMethod != null ||
      status != null ||
      startDate != null ||
      endDate != null;

  SalesFilter copyWith({
    double? minPrice,
    double? maxPrice,
    String? cashier,
    String? customer,
    String? discount,
    String? paymentMethod,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCashier = false,
    bool clearCustomer = false,
    bool clearDiscount = false,
    bool clearPaymentMethod = false,
    bool clearStatus = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return SalesFilter(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      cashier: clearCashier ? null : (cashier ?? this.cashier),
      customer: clearCustomer ? null : (customer ?? this.customer),
      discount: clearDiscount ? null : (discount ?? this.discount),
      paymentMethod: clearPaymentMethod
          ? null
          : (paymentMethod ?? this.paymentMethod),
      status: clearStatus ? null : (status ?? this.status),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  /// reset all filters
  static const SalesFilter empty = SalesFilter();
}
