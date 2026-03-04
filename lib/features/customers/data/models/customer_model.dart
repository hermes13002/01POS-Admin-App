/// model for a customer
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String? comment;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    this.comment,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? comment,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      comment: comment ?? this.comment,
    );
  }
}
