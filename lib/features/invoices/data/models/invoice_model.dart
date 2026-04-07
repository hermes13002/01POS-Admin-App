class InvoiceModel {
  final String id;
  final String? invoiceNumber;
  final String customerId;
  final String? customerName;
  final List<InvoiceItemModel> items;
  final double discount; // percentage
  final double tax; // percentage
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final String sendOption;
  final String? scheduledDate;
  final String? scheduledTime;
  final String? recurringFrequency;
  final DateTime? createdAt;

  const InvoiceModel({
    required this.id,
    this.invoiceNumber,
    required this.customerId,
    this.customerName,
    required this.items,
    this.discount = 0.0,
    this.tax = 0.0,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.total = 0.0,
    this.sendOption = 'now',
    this.scheduledDate,
    this.scheduledTime,
    this.recurringFrequency,
    this.createdAt,
  });

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    List<InvoiceItemModel>? items,
    double? discount,
    double? tax,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? total,
    String? sendOption,
    String? scheduledDate,
    String? scheduledTime,
    String? recurringFrequency,
    DateTime? createdAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      sendOption: sendOption ?? this.sendOption,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': int.tryParse(customerId) ?? customerId,
      'products': items.map((x) => x.toJson()).toList(),
      'discount': discount,
      'tax': tax,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total': total,
      'send_option': sendOption.toLowerCase(),
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'recurring_frequency': recurringFrequency,
    };
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber:
          json['invoice_number']?.toString() ?? json['invoice_no']?.toString(),
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? json['customer']?['name'],
      items:
          (json['products'] as List?)
              ?.map((x) => InvoiceItemModel.fromJson(x))
              .toList() ??
          (json['items'] as List?)
              ?.map((x) => InvoiceItemModel.fromJson(x))
              .toList() ??
          [],
      discount: parseDouble(json['discount']),
      tax: parseDouble(json['tax']),
      subtotal: parseDouble(json['subtotal']),
      discountAmount: parseDouble(json['discount_amount']),
      taxAmount: parseDouble(json['tax_amount']),
      total: parseDouble(json['total']) != 0.0
          ? parseDouble(json['total'])
          : parseDouble(json['total_amount']),
      sendOption: json['send_option'] ?? 'now',
      scheduledDate: json['scheduled_date'],
      scheduledTime: json['scheduled_time'],
      recurringFrequency: json['recurring_frequency'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class InvoiceItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  const InvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });

  InvoiceItemModel copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return InvoiceItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': int.tryParse(productId) ?? productId,
      'quantity': quantity,
      'unit_price': price,
    };
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return InvoiceItemModel(
      productId: (json['product_id'] ?? json['productId'])?.toString() ?? '',
      productName: json['product_name'] ?? json['productName'] ?? '',
      price: parseDouble(json['unit_price'] ?? json['price']),
      quantity:
          (json['quantity'] as int?) ??
          int.tryParse(json['quantity']?.toString() ?? '1') ??
          1,
      imageUrl: json['product_image'] ?? json['imageUrl'],
    );
  }

  factory InvoiceItemModel.fromSaleItem(dynamic saleItem) {
    // using dynamic to avoid direct dependency on SaleItem model if possible,
    // or we can import it if it's cleaner.
    // since both are in different features, i'll use their properties.
    return InvoiceItemModel(
      productId: '', // sale item doesn't always have product id
      productName: saleItem.productName,
      price: saleItem.unitPrice,
      quantity: saleItem.quantity,
    );
  }
}
