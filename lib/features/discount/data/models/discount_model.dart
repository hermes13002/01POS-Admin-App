/// model for a discount item
class DiscountModel {
  final int id;
  final int companyId;
  final String name;
  final double minimumPrice;
  final double discountValue;
  final String discountType;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DiscountModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.minimumPrice,
    required this.discountValue,
    required this.discountType,
    this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      companyId: json['company_id'] is String
          ? int.parse(json['company_id'])
          : json['company_id'],
      name: json['name'] ?? '',
      minimumPrice:
          double.tryParse(json['minimum_price']?.toString() ?? '0') ?? 0,
      discountValue:
          double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0,
      discountType: json['discount_type'] ?? 'fixed',
      description: json['description'],
      status: json['status'] ?? 'inactive',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'name': name,
      'minimum_price': minimumPrice,
      'discount_type': discountType.toLowerCase(),
      'discount_value': discountValue,
      'description': description,
      'status': status,
    };
  }
}
