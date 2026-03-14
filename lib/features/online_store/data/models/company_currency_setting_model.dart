import 'package:onepos_admin_app/features/online_store/data/models/currency_model.dart';

class CompanyCurrencySettingModel {
  final int id;
  final String companyId;
  final String currencyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CurrencyModel? currency;

  const CompanyCurrencySettingModel({
    required this.id,
    required this.companyId,
    required this.currencyId,
    required this.createdAt,
    required this.updatedAt,
    required this.currency,
  });

  factory CompanyCurrencySettingModel.fromJson(Map<String, dynamic> json) {
    final nestedCurrency = json['currency'];

    return CompanyCurrencySettingModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      companyId: json['company_id']?.toString() ?? '',
      currencyId: json['currency_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      currency: nestedCurrency is Map<String, dynamic>
          ? CurrencyModel.fromJson(nestedCurrency)
          : nestedCurrency is Map
              ? CurrencyModel.fromJson(Map<String, dynamic>.from(nestedCurrency))
              : null,
    );
  }
}
