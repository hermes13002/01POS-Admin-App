import 'package:intl/intl.dart';

/// Utility class for formatting amounts
class AmountFormatter {
  // private constructor
  AmountFormatter._();

  /// Format amount as currency with naira symbol
  /// Example: formatCurrency(1234567.89) => "₦1,234,567.89"
  static String formatCurrency(
    dynamic amount, {
    String symbol = '₦',
    int decimals = 2,
    bool showDecimals = true,
  }) {
    if (amount == null) return '$symbol 0.00';
    
    final double value = amount is double 
        ? amount 
        : amount is int 
            ? amount.toDouble() 
            : double.tryParse(amount.toString()) ?? 0.0;

    final formatter = NumberFormat('#,##0${showDecimals ? ".00" : ""}', 'en_US');
    return '$symbol ${formatter.format(value)}';
  }

  /// Format amount without currency symbol
  /// Example: formatAmount(1234567.89) => "1,234,567.89"
  static String formatAmount(
    dynamic amount, {
    int decimals = 2,
    bool showDecimals = true,
  }) {
    if (amount == null) return '0.00';
    
    final double value = amount is double 
        ? amount 
        : amount is int 
            ? amount.toDouble() 
            : double.tryParse(amount.toString()) ?? 0.0;

    final formatter = NumberFormat('#,##0${showDecimals ? ".00" : ""}', 'en_US');
    return formatter.format(value);
  }

  /// Format large numbers with K, M, B suffix
  /// Example: formatCompact(1234567) => "1.23M"
  static String formatCompact(
    dynamic amount, {
    int decimals = 2,
  }) {
    if (amount == null) return '0';
    
    final double value = amount is double 
        ? amount 
        : amount is int 
            ? amount.toDouble() 
            : double.tryParse(amount.toString()) ?? 0.0;

    final formatter = NumberFormat.compact();
    return formatter.format(value);
  }

  /// Format percentage
  /// Example: formatPercentage(0.1234) => "12.34%"
  static String formatPercentage(
    dynamic value, {
    int decimals = 2,
  }) {
    if (value == null) return '0%';
    
    final double percent = value is double 
        ? value 
        : value is int 
            ? value.toDouble() 
            : double.tryParse(value.toString()) ?? 0.0;

    return '${(percent * 100).toStringAsFixed(decimals)}%';
  }
}
