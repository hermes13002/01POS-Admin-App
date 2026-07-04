// restock suggestion model
class RestockSuggestionModel {
  final int id;
  final String productId;
  final String companyId;
  final String productName;
  final double currentStock;
  final double averageDailySales;
  final double lowStockLimit;
  final int? stockOutDays;
  final String? stockOutDate;
  final double suggestedReorderQty;
  final String createdAt;
  final String updatedAt;
  final double? price;

  const RestockSuggestionModel({
    required this.id,
    required this.productId,
    required this.companyId,
    required this.productName,
    required this.currentStock,
    required this.averageDailySales,
    required this.lowStockLimit,
    this.stockOutDays,
    this.stockOutDate,
    required this.suggestedReorderQty,
    required this.createdAt,
    required this.updatedAt,
    this.price,
  });

  int? get resolvedStockOutDays {
    if (stockOutDays != null) return stockOutDays;
    return _calculateStockOutDaysFromDate(stockOutDate);
  }

  // convert json to model
  factory RestockSuggestionModel.fromJson(Map<String, dynamic> json) {
    return RestockSuggestionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      productId: json['product_id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      currentStock:
          double.tryParse(json['current_stock']?.toString() ?? '0.0') ?? 0.0,
      averageDailySales:
          double.tryParse(json['average_daily_sales']?.toString() ?? '0.0') ??
          0.0,
      lowStockLimit:
          double.tryParse(json['low_stock_limit']?.toString() ?? '0.0') ?? 0.0,
      stockOutDays: _parseStockOutDays(json['stock_out_days']),
      stockOutDate: json['stock_out_date']?.toString(),
      suggestedReorderQty:
          double.tryParse(json['suggested_reorder_qty']?.toString() ?? '0.0') ??
          0.0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }

  // convert model to json
  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'company_id': companyId,
    'product_name': productName,
    'current_stock': currentStock,
    'average_daily_sales': averageDailySales,
    'low_stock_limit': lowStockLimit,
    'stock_out_days': stockOutDays,
    'stock_out_date': stockOutDate,
    'suggested_reorder_qty': suggestedReorderQty,
    'created_at': createdAt,
    'updated_at': updatedAt,
    if (price != null) 'price': price,
  };

  static int? _parseStockOutDays(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static int? _calculateStockOutDaysFromDate(String? stockOutDate) {
    if (stockOutDate == null || stockOutDate.trim().isEmpty) return null;

    try {
      final parsedDate = DateTime.parse(stockOutDate).toLocal();
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      final startOfTargetDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      final difference = startOfTargetDate.difference(startOfToday).inDays;
      return difference < 0 ? 0 : difference;
    } catch (_) {
      return null;
    }
  }
}
