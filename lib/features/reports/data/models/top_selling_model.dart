/// Model for top selling product data
class TopSellingProduct {
  final String productName;
  final String? categoryName;
  final int totalQuantity;
  final double totalAmount;
  final String? productImage;

  const TopSellingProduct({
    required this.productName,
    this.categoryName,
    required this.totalQuantity,
    required this.totalAmount,
    this.productImage,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    // Handle nested category name
    final category = json['category'];
    String? categoryName;
    if (category is Map) {
      categoryName = category['cat_name']?.toString();
    }

    final quantity = parseInt(
      json['quantity_purchased'] ?? json['total_quantity'] ?? json['quantity'],
    );
    final price = parseDouble(
      json['price'] ?? json['total_amount'] ?? json['amount'],
    );

    return TopSellingProduct(
      productName: json['product_name']?.toString() ?? 'Unknown Product',
      categoryName: categoryName ?? json['category_name']?.toString(),
      totalQuantity: quantity,
      totalAmount: quantity * price, // Total = qty * unit price
      productImage:
          json['product_image']?.toString() ?? json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'category_name': categoryName,
      'total_quantity': totalQuantity,
      'total_amount': totalAmount,
      'product_image': productImage,
    };
  }
}
