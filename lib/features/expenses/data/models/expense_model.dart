import 'package:flutter/material.dart';

/// model for an expense item
class ExpenseModel {
  final String id;
  final String title;
  final String category;
  final String type;
  final double amount;
  final double
  amountTrend; // Just in case a trend is needed, otherwise ignored.
  final Color categoryColor;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.amount,
    required this.categoryColor,
    this.amountTrend = 0,
  });
}
