/// model for a bill item
class BillModel {
  final String id;
  final String title;
  final String billType;
  final double amount;
  final bool isActive;

  BillModel({
    required this.id,
    required this.title,
    required this.billType,
    required this.amount,
    required this.isActive,
  });
}
