import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/amount_formatter.dart';

/// Business performance card widget
class BusinessPerformanceCard extends StatelessWidget {
  final double todaySales;
  final double totalRevenue;
  final double totalExpenses;

  const BusinessPerformanceCard({
    super.key,
    required this.todaySales,
    required this.totalRevenue,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Performance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          
          // today's sales
          _buildMetricItem(
            label: 'Today\'s Sales',
            amount: todaySales,
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // total revenue
          _buildMetricItem(
            label: 'Total Revenue',
            amount: totalRevenue,
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // total expenses
          _buildMetricItem(
            label: 'Total Expenses',
            amount: totalExpenses,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AmountFormatter.formatCurrency(amount),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
