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

  double get total => quantity * unitPrice;
}

/// model for sales filter options
class SalesFilter {
  final double? minPrice;
  final double? maxPrice;
  final String? cashier;
  final String? customer;
  final String? discount;
  final String? paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;

  const SalesFilter({
    this.minPrice,
    this.maxPrice,
    this.cashier,
    this.customer,
    this.discount,
    this.paymentMethod,
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
      startDate != null ||
      endDate != null;

  SalesFilter copyWith({
    double? minPrice,
    double? maxPrice,
    String? cashier,
    String? customer,
    String? discount,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCashier = false,
    bool clearCustomer = false,
    bool clearDiscount = false,
    bool clearPaymentMethod = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return SalesFilter(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      cashier: clearCashier ? null : (cashier ?? this.cashier),
      customer: clearCustomer ? null : (customer ?? this.customer),
      discount: clearDiscount ? null : (discount ?? this.discount),
      paymentMethod:
          clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  /// reset all filters
  static const SalesFilter empty = SalesFilter();
}
