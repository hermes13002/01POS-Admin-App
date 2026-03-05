/// model for a discount item
class DiscountModel {
  final String id;
  final String title;
  final double minPrice;
  final double discountValue;
  final String discountType;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.title,
    required this.minPrice,
    required this.discountValue,
    required this.discountType,
    required this.isActive,
  });
}
