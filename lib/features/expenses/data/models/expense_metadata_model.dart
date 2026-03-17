import 'package:onepos_admin_app/data/models/base_model.dart';

/// model for expense metadata (categories and types)
class ExpenseMetadataModel extends BaseModel {
  final List<String> categories;
  final List<String> types;

  ExpenseMetadataModel({required this.categories, required this.types});

  factory ExpenseMetadataModel.fromJson(Map<String, dynamic> json) {
    return ExpenseMetadataModel(
      categories: List<String>.from(json['categories'] ?? []),
      types: List<String>.from(json['types'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'categories': categories, 'types': types};
  }
}
