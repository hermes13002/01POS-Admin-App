import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';

/// String extensions
extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is email
  bool isEmail() {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is phone number
  bool isPhoneNumber() {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(this);
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }
}

/// DateTime extensions
extension DateTimeExtension on DateTime {
  /// Format date as 'dd MMM yyyy'
  String toFormattedDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// Format date as 'dd/MM/yyyy'
  String toShortDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format time as 'HH:mm'
  String toFormattedTime() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format date and time as 'dd MMM yyyy, HH:mm'
  String toFormattedDateTime() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  /// Check if date is today
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

/// Number extensions
extension DoubleExtension on double {
  /// Format as currency
  String toCurrency({String symbol = '₦'}) {
    return '$symbol${toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// Format with commas
  String toFormattedString({int decimals = 2}) {
    return toStringAsFixed(decimals).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

extension IntExtension on int {
  /// Format as currency
  String toCurrency({String symbol = '₦'}) {
    return toDouble().toCurrency(symbol: symbol);
  }

  /// Format with commas
  String toFormattedString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// BuildContext extensions
extension BuildContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get width => MediaQuery.of(this).size.width;

  /// Get screen height
  double get height => MediaQuery.of(this).size.height;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      AppSnackbar.showError(this, message);
    } else {
      AppSnackbar.showSuccess(this, message);
    }
  }

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
