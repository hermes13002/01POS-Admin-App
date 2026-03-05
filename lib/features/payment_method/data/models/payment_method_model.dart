/// model for a payment method item
class PaymentMethodModel {
  final String id;
  final String name; // e.g., John Doe
  final String bankName; // e.g., Access Bank
  final String accountNumber; // e.g., **** 54321
  final String accountName; // e.g., John Doe

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });
}
