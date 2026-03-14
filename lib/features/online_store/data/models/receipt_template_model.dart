class ReceiptTemplateModel {
  final int id;
  final String? companyId;
  final String? logo;
  final String headerLineOne;
  final String headerLineTwo;
  final String headerLineThree;
  final String footerLineOne;
  final String footerLineTwo;
  final String footerLineThree;
  final int numberOfPages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReceiptTemplateModel({
    required this.id,
    required this.companyId,
    required this.logo,
    required this.headerLineOne,
    required this.headerLineTwo,
    required this.headerLineThree,
    required this.footerLineOne,
    required this.footerLineTwo,
    required this.footerLineThree,
    required this.numberOfPages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReceiptTemplateModel.fromJson(Map<String, dynamic> json) {
    return ReceiptTemplateModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      companyId: json['company_id']?.toString(),
      logo: json['logo']?.toString(),
      headerLineOne: json['header_line_one']?.toString() ?? '',
      headerLineTwo: json['header_line_two']?.toString() ?? '',
      headerLineThree: json['header_line_three']?.toString() ?? '',
      footerLineOne: json['footer_line_one']?.toString() ?? '',
      footerLineTwo: json['footer_line_two']?.toString() ?? '',
      footerLineThree: json['footer_line_three']?.toString() ?? '',
      numberOfPages: int.tryParse(json['number_of_pages']?.toString() ?? '') ?? 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  ReceiptTemplateModel copyWith({
    int? id,
    String? companyId,
    String? logo,
    String? headerLineOne,
    String? headerLineTwo,
    String? headerLineThree,
    String? footerLineOne,
    String? footerLineTwo,
    String? footerLineThree,
    int? numberOfPages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReceiptTemplateModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      logo: logo ?? this.logo,
      headerLineOne: headerLineOne ?? this.headerLineOne,
      headerLineTwo: headerLineTwo ?? this.headerLineTwo,
      headerLineThree: headerLineThree ?? this.headerLineThree,
      footerLineOne: footerLineOne ?? this.footerLineOne,
      footerLineTwo: footerLineTwo ?? this.footerLineTwo,
      footerLineThree: footerLineThree ?? this.footerLineThree,
      numberOfPages: numberOfPages ?? this.numberOfPages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
