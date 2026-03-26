import 'package:onepos_admin_app/data/models/base_model.dart';

/// model for an auto bill item
class AutoBillModel extends BaseModel {
  final int id;
  final String companyId;
  final String createdBy;
  final String name;
  final String slug;
  final String description;
  final String percentage;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String billOptionId;
  final BillOptionModel? billOption;

  AutoBillModel({
    required this.id,
    required this.companyId,
    required this.createdBy,
    required this.name,
    required this.slug,
    required this.description,
    required this.percentage,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.billOptionId,
    this.billOption,
  });

  factory AutoBillModel.fromJson(Map<String, dynamic> json) {
    return AutoBillModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      companyId: json['company_id']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      percentage: json['percentage']?.toString() ?? '0.00',
      isActive: json['is_active'] is int
          ? json['is_active']
          : int.tryParse(json['is_active']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      billOptionId: json['bill_option_id']?.toString() ?? '',
      billOption: json['bill_option'] != null
          ? BillOptionModel.fromJson(json['bill_option'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'created_by': createdBy,
      'name': name,
      'slug': slug,
      'description': description,
      'percentage': percentage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'bill_option_id': billOptionId,
      'bill_option': billOption?.toJson(),
    };
  }
}

/// model for bill option
class BillOptionModel extends BaseModel {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BillOptionModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory BillOptionModel.fromJson(Map<String, dynamic> json) {
    return BillOptionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
