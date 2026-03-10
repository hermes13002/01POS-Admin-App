/// model for company details
class CompanyModel {
  final int id;
  final String companyName;
  final String companyEmail;
  final String companyAddress;
  final String companyNumber;
  final String? companyType;
  final String licenseDuration;
  final String? logo;
  final String lowStockLimit;
  final bool isActive;

  const CompanyModel({
    required this.id,
    required this.companyName,
    required this.companyEmail,
    required this.companyAddress,
    required this.companyNumber,
    this.companyType,
    required this.licenseDuration,
    this.logo,
    required this.lowStockLimit,
    required this.isActive,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      companyName: json['company_name']?.toString() ?? '',
      companyEmail: json['company_email']?.toString() ?? '',
      companyAddress: json['company_address']?.toString() ?? '',
      companyNumber: json['company_number']?.toString() ?? '',
      companyType: json['company_type']?.toString(),
      licenseDuration: json['license_duration']?.toString() ?? '',
      logo: json['logo']?.toString(),
      lowStockLimit: json['low_stock_limit']?.toString() ?? '0',
      isActive:
          json['is_active'] == true ||
          json['is_active'] == '1' ||
          json['is_active'] == 1,
    );
  }
}
