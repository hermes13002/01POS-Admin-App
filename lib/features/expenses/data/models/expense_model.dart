import 'package:flutter/material.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/data/models/base_model.dart';

/// model for an expense item
class ExpenseModel extends BaseModel {
  final int id;
  final String companyId;
  final String userId;
  final String name;
  final String category;
  final String type;
  final String amount;
  final String? description;
  final String expenseDate;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final UserModel? user;

  ExpenseModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.name,
    required this.category,
    required this.type,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.user,
  });

  /// gets a color based on the category name
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'technology':
        return const Color(0xFFAC28A6); // purple
      case 'personnel':
        return const Color(0xFFFF5252); // red
      case 'facility':
        return const Color(0xFF673AB7); // indigo
      case 'marketing':
        return const Color(0xFF4CAF50); // green
      case 'inventory':
        return const Color(0xFFFF9800); // orange
      case 'finance':
        return const Color(0xFF009688); // teal
      case 'compliance':
        return const Color(0xFF607D8B); // blue-grey
      default:
        return Colors.blue;
    }
  }

  /// numeric amount for calculations if needed
  double get amountValue => double.tryParse(amount) ?? 0.0;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['company_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      description: json['description']?.toString(),
      expenseDate: json['expense_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'name': name,
      'category': category,
      'type': type,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'user': user?.toJson(),
    };
  }
}
