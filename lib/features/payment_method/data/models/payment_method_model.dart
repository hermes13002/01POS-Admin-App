class PaymentMethodModel {
  final int id;
  final String? companyId;
  final String methodName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.companyId,
    required this.methodName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      companyId: json['company_id']?.toString(),
      methodName: (json['method_name'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  PaymentMethodModel copyWith({
    int? id,
    String? companyId,
    String? methodName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      methodName: methodName ?? this.methodName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentMethodsState {
  final List<PaymentMethodModel> methods;

  const PaymentMethodsState({required this.methods});

  PaymentMethodsState copyWith({List<PaymentMethodModel>? methods}) {
    return PaymentMethodsState(
      methods: methods ?? this.methods,
    );
  }
}
