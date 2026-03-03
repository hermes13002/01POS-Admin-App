import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/reports/data/models/reports_model.dart';
import 'package:onepos_admin_app/features/reports/presentation/providers/reports_provider.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

/// Reports screen
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: reportsAsync.when(
          data: (data) => _ReportsContent(data: data),
          loading: () => const Center(child: LoadingWidget()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load reports',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(reportsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final ReportsData data;

  const _ReportsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // app bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                'Reports',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // sales overview
                _SalesOverviewSection(data: data.salesOverview),

                const SizedBox(height: 16),

                // store health
                _StoreHealthSection(data: data.storeHealth),

                const SizedBox(height: 16),

                // ai insights
                _AiInsightsSection(insight: data.aiInsight),

                const SizedBox(height: 16),

                // low stock
                _LowStockSection(items: data.lowStockItems),

                const SizedBox(height: 16),

                // sales summary
                _SalesSummarySection(data: data.salesSummary),

                const SizedBox(height: 16),

                // expenses overview
                _ExpensesOverviewSection(totalExpenses: data.totalExpenses),

                const SizedBox(height: 16),

                // stock level
                _StockLevelSection(data: data.stockLevel),

                const SizedBox(height: 16),

                // top sales
                _TopSalesSection(items: data.topSales),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Sales overview section
class _SalesOverviewSection extends StatelessWidget {
  final SalesOverviewData data;

  const _SalesOverviewSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OverviewCard(
                  label: 'Total Orders',
                  value: AmountFormatter.formatAmount(data.totalOrders, showDecimals: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  label: 'Sales Today',
                  value: data.salesToday.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OverviewCard(
            label: 'Total Orders',
            value: AmountFormatter.formatAmount(data.totalOrdersWithTrend, showDecimals: false),
            showTrend: true,
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final bool showTrend;

  const _OverviewCard({
    required this.label,
    required this.value,
    this.showTrend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.grey300),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_outlined,
              size: 18,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (showTrend)
            Image.asset(
              'assets/icons/trend_up.png',
              width: 40,
              height: 28,
              errorBuilder: (context, error, stack) => Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}

/// Store health section
class _StoreHealthSection extends StatelessWidget {
  final StoreHealthData data;

  const _StoreHealthSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Store Health',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Icon(Icons.info_outline, size: 20, color: AppTheme.grey500),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _StoreHealthPainter(score: data.score),
                child: Center(
                  child: Text(
                    '${data.score}',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              data.status,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreHealthPainter extends CustomPainter {
  final int score;

  _StoreHealthPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // background arc
    final bgPaint = Paint()
      ..color = AppTheme.grey200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweep = (score / 100) * pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StoreHealthPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

/// Ai insights section
class _AiInsightsSection extends StatelessWidget {
  final String insight;

  const _AiInsightsSection({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Insights',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    size: 20,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Low stock section
class _LowStockSection extends StatelessWidget {
  final List<LowStockItem> items;

  const _LowStockSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Low Stock',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${item.quantity}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: AppTheme.grey100),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Sales summary section with bar chart
class _SalesSummarySection extends StatelessWidget {
  final List<MonthlySalesData> data;

  const _SalesSummarySection({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxSales = data.map((e) => e.totalSales).reduce(max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Summary',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _legendDot(const Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Text(
                        'Total Sales',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      _legendDot(AppTheme.grey800),
                      const SizedBox(width: 4),
                      Text(
                        'Number of transactions',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Month',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // y-axis labels + bars
          SizedBox(
            height: 180,
            child: Row(
              children: [
                // y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$600', style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary)),
                    Text('\$500', style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary)),
                    Text('\$200', style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary)),
                    Text('\$0', style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(width: 8),

                // bars
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((item) {
                      final barHeight = (item.totalSales / maxSales) * 140;
                      final txnHeight = (item.transactions / 250) * 140;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 10,
                                height: barHeight.clamp(4.0, 140.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                width: 10,
                                height: txnHeight.clamp(4.0, 140.0),
                                decoration: BoxDecoration(
                                  color: AppTheme.grey800,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.month,
                            style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Expenses overview section
class _ExpensesOverviewSection extends StatelessWidget {
  final double totalExpenses;

  const _ExpensesOverviewSection({required this.totalExpenses});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Total expenses',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AmountFormatter.formatCurrency(totalExpenses, showDecimals: false),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stock level section with line chart
class _StockLevelSection extends StatelessWidget {
  final List<StockLevelData> data;

  const _StockLevelSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Level',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Total Sales',
                style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // line chart
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size(double.infinity, 120),
              painter: _StockLevelPainter(data: data),
            ),
          ),
          const SizedBox(height: 8),

          // x-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: data.map((item) {
              return Text(
                item.month,
                style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StockLevelPainter extends CustomPainter {
  final List<StockLevelData> data;

  _StockLevelPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxStock = data.map((e) => e.totalStock).reduce(max);
    final minStock = data.map((e) => e.totalStock).reduce(min);
    final range = maxStock - minStock;
    final effectiveRange = range == 0 ? 1.0 : range;

    // grid lines
    final gridPaint = Paint()
      ..color = AppTheme.grey200
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = (i / 3) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // line
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].totalStock - minStock) / effectiveRange * (size.height - 20) + 10);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _StockLevelPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

/// Top sales section
class _TopSalesSection extends StatelessWidget {
  final List<TopSalesItem> items;

  const _TopSalesSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Sales',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _TopSalesRow(item: item)),
        ],
      ),
    );
  }
}

class _TopSalesRow extends StatelessWidget {
  final TopSalesItem item;

  const _TopSalesRow({required this.item});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item.rank}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // name and category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  item.category,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // amount and units
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AmountFormatter.formatCurrency(item.amount, showDecimals: false),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${item.unitsSold} Sold',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
