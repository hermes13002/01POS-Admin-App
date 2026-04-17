import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/amount_formatter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/reports_model.dart';
import '../../data/models/top_selling_model.dart';
import '../providers/reports_provider.dart';
import 'package:onepos_admin_app/shared/widgets/dots_loader.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

class ReportsScreen extends HookConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() => ref.read(reportsProvider.notifier).refresh());
      return null;
    }, []);

    final reportsData = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(child: _ReportsContent(data: reportsData)),
    );
  }
}

class _ReportsContent extends ConsumerWidget {
  final ReportsData data;

  const _ReportsContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
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

        Expanded(
          child: AnimationLimiter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    const SizedBox(height: 8),

                    _SalesOverviewSection(
                      data: data.salesOverview,
                      isLoading: data.isSalesOverviewLoading,
                      errorMessage: data.salesOverviewError,
                    ),

                    const SizedBox(height: 16),

                    _StoreHealthSection(data: data.storeHealth),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

                    _LowStockSection(
                      items: data.lowStockItems,
                      isLoading: data.isLowStockLoading,
                      errorMessage: data.lowStockError,
                    ),

                    const SizedBox(height: 16),

                    _SalesSummarySection(
                      data: data.salesSummary,
                      isLoading: data.isSalesSummaryLoading,
                      errorMessage: data.salesSummaryError,
                      currentFilter: data.salesSummaryFilter,
                      onFilterChanged: (filter) {
                        ref
                            .read(reportsProvider.notifier)
                            .updateSalesSummaryFilter(filter);
                      },
                    ),

                    const SizedBox(height: 16),

                    _ExpensesOverviewSection(
                      data: data.expenseStatistics,
                      isLoading: data.isExpensesLoading,
                      errorMessage: data.expensesError,
                    ),

                    const SizedBox(height: 16),

                    _StockLevelSection(
                      data: data.stockLevel,
                      isLoading: data.isStockLevelLoading,
                      errorMessage: data.stockLevelError,
                    ),

                    const SizedBox(height: AppTheme.spacingLarge),
                    _TopSalesSection(
                      items: data.topSales,
                      errorMessage: data.topSalesError,
                      isLoading: data.isTopSalesLoading,
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesOverviewSection extends StatelessWidget {
  final SalesOverviewData data;
  final bool isLoading;
  final String? errorMessage;

  const _SalesOverviewSection({
    required this.data,
    this.isLoading = false,
    this.errorMessage,
  });

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
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: DotsLoader(),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _OverviewCard(
                        label: 'Restock Needed',
                        value: data.lowStockCount.toString(),
                        icon: Icons.bar_chart,
                        iconColor: AppTheme.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OverviewCard(
                        label: 'Sales Today',
                        value: data.todaysSalesCount.toString(),
                        icon: Icons.trending_up,
                        iconColor: AppTheme.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OverviewCard(
                  label: 'Total Revenue',
                  value: AmountFormatter.formatAmount(
                    data.todaysTotalRevenue,
                    showDecimals: true,
                  ),
                  icon: Icons.monetization_on_outlined,
                  iconColor: AppTheme.blue,
                  isFullWidth: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ExpensesOverviewSection extends StatefulWidget {
  final ExpenseStatisticsData? data;
  final bool isLoading;
  final String? errorMessage;

  const _ExpensesOverviewSection({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<_ExpensesOverviewSection> createState() =>
      _ExpensesOverviewSectionState();
}

class _ExpensesOverviewSectionState extends State<_ExpensesOverviewSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isLoading = widget.isLoading;
    final errorMessage = widget.errorMessage;
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
            'Expenses Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: DotsLoader(),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (data == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No expense data available',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _ExpenseDonutChart(
                      byCategory: data.byCategory,
                      selectedIndex: _selectedIndex,
                      onSelect: (index) {
                        setState(() {
                          if (_selectedIndex == index) {
                            _selectedIndex = null;
                          } else {
                            _selectedIndex = index;
                          }
                        });
                      },
                    ),
                    _buildCenterText(data),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: data.byCategory.keys.indexed.map((entry) {
                final index = entry.$1;
                final category = entry.$2;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            _ExpenseDonutChart.chartColors[index %
                                _ExpenseDonutChart.chartColors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCenterText(ExpenseStatisticsData data) {
    if (_selectedIndex == null ||
        _selectedIndex! >= data.byCategory.keys.length) {
      return SizedBox(
        width: 160,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total Expenses',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AmountFormatter.formatCurrency(
                  data.totalExpenses,
                  showDecimals: true,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final category = data.byCategory.keys.elementAt(_selectedIndex!);
    final value = data.byCategory[category]!;
    final percentage = (value / data.totalExpenses) * 100;
    final color = _ExpenseDonutChart
        .chartColors[_selectedIndex! % _ExpenseDonutChart.chartColors.length];

    return SizedBox(
      width: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AmountFormatter.formatCurrency(value, showDecimals: true),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${percentage.toStringAsFixed(1)}% of total',
              style: GoogleFonts.poppins(
                fontSize: 14,
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

class _ExpenseDonutChart extends StatelessWidget {
  final Map<String, double> byCategory;
  final int? selectedIndex;
  final Function(int?) onSelect;

  const _ExpenseDonutChart({
    required this.byCategory,
    this.selectedIndex,
    required this.onSelect,
  });

  static const List<Color> chartColors = [
    Color(0xFFFF6B81), // Pink - Facility
    Color(0xFF54A0FF), // Blue - Personnel
    Color(0xFFFFD93D), // Yellow - Marketing
    Color(0xFF1DD1A1), // Teal - Compliance
    Color(0xFFAC92EB), // Purple
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final renderObject = context.findRenderObject() as RenderBox;
        final localPosition = details.localPosition;
        final size = renderObject.size;
        final center = Offset(size.width / 2, size.height / 2);
        final radius = min(size.width, size.height) / 2;
        final innerRadius = radius * 0.65; // Matches 0.35 strokeWidth

        final distance = (localPosition - center).distance;
        if (distance < innerRadius || distance > radius) {
          onSelect(null);
          return;
        }

        final angle =
            atan2(localPosition.dy - center.dy, localPosition.dx - center.dx) +
            pi / 2;
        final normalizedAngle = (angle < 0 ? angle + 2 * pi : angle) % (2 * pi);

        final activeEntries = byCategory.entries
            .where((e) => e.value > 0)
            .toList();
        if (activeEntries.isEmpty) return;

        final total = activeEntries.fold(0.0, (sum, e) => sum + e.value);
        if (total == 0) return;

        final double strokeWidth = radius * 0.35;
        final double rectRadius = radius - strokeWidth / 2;
        final double visualGap = 6.0;
        final double paddingAngle = (visualGap + strokeWidth) / 2 / rectRadius;
        final double gapPerSegment = paddingAngle * 2;

        double availableAngle =
            (2 * pi) - (activeEntries.length * gapPerSegment);
        if (availableAngle <= 0) availableAngle = 0;

        double currentAngle = 0;
        int? tappedIndex;

        for (var i = 0; i < activeEntries.length; i++) {
          final entry = activeEntries[i];
          final value = entry.value;

          final sweepAngle = availableAngle > 0
              ? (value / total) * availableAngle
              : 0.0;
          final totalSlotAngle = sweepAngle + gapPerSegment;

          if (normalizedAngle >= currentAngle &&
              (i == activeEntries.length - 1 ||
                  normalizedAngle < currentAngle + totalSlotAngle)) {
            tappedIndex = byCategory.keys.toList().indexOf(entry.key);
            break;
          }
          currentAngle += totalSlotAngle;
        }

        onSelect(tappedIndex);
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _DonutChartPainter(
          data: byCategory,
          colors: chartColors,
          selectedIndex: selectedIndex,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final int? selectedIndex;

  _DonutChartPainter({
    required this.data,
    required this.colors,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.35;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final activeEntries = data.entries.where((e) => e.value > 0).toList();
    if (activeEntries.isEmpty) return;

    final total = activeEntries.fold(0.0, (sum, e) => sum + e.value);
    if (total == 0) return;

    final double visualGap = 6.0;
    final rectRadius = radius - strokeWidth / 2;
    final double paddingAngle = (visualGap + strokeWidth) / 2 / rectRadius;
    final double gapPerSegment = paddingAngle * 2;

    if (activeEntries.length == 1) {
      final entry = activeEntries.first;
      final dataIndex = data.keys.toList().indexOf(entry.key);
      final paint = Paint()
        ..color = dataIndex == selectedIndex
            ? colors[dataIndex % colors.length]
            : colors[dataIndex % colors.length].withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = dataIndex == selectedIndex
            ? strokeWidth * 1.1
            : strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }

    double availableAngle = (2 * pi) - (activeEntries.length * gapPerSegment);

    if (availableAngle <= 0) {
      availableAngle = 0;
    }

    double currentSlotStart = -pi / 2;

    for (var i = 0; i < activeEntries.length; i++) {
      final entry = activeEntries[i];
      final dataIndex = data.keys.toList().indexOf(entry.key);
      final value = entry.value;

      final sweepAngle = availableAngle > 0
          ? (value / total) * availableAngle
          : 0.0;

      final paint = Paint()
        ..color = dataIndex == selectedIndex
            ? colors[dataIndex % colors.length]
            : colors[dataIndex % colors.length].withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = dataIndex == selectedIndex
            ? strokeWidth * 1.1
            : strokeWidth
        ..strokeCap = StrokeCap.round;

      double adjustedStart = currentSlotStart + paddingAngle;
      double adjustedSweep = sweepAngle <= 0 ? 0.0001 : sweepAngle;

      canvas.drawArc(rect, adjustedStart, adjustedSweep, false, paint);

      currentSlotStart += (gapPerSegment + sweepAngle);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool isFullWidth;

  const _OverviewCard({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: isFullWidth
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor ?? AppTheme.textSecondary),
            const SizedBox(height: 8),
          ],
          if (isFullWidth)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            )
          else ...[
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _StoreHealthSection extends StatelessWidget {
  final StoreHealthData data;

  const _StoreHealthSection({required this.data});

  void _showStoreHealthInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Store Health shows how your business is doing on a scale from 0 to 100. It combines:",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "1.	Activity – How often you make sales\n"
                  "2.	Profitability – How much money you keep after expenses",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const _HealthLegendRow(
                  color: Color(0xFF1DD1A1),
                  label: 'Excellent (81-100)',
                ),
                const _HealthLegendRow(
                  color: Color(0xFF4CAF50),
                  label: 'Good (61-80)',
                ),
                const _HealthLegendRow(
                  color: Color(0xFFFFD93D),
                  label: 'Fair (41-60)',
                ),
                const _HealthLegendRow(
                  color: Color(0xFFFF9F43),
                  label: 'Poor (21-40)',
                ),
                const _HealthLegendRow(
                  color: Color(0xFFFF4757),
                  label: 'Critical (0-20)',
                ),
                const SizedBox(height: 16),
                Text(
                  "Tip: Aim for green! Keep making sales and staying profitable to maintain a healthy score.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 81) return const Color(0xFF1DD1A1);
    if (score >= 61) return const Color(0xFF4CAF50);
    if (score >= 41) return const Color(0xFFFFD93D);
    if (score >= 21) return const Color(0xFFFF9F43);
    return const Color(0xFFFF4757);
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getHealthColor(data.score);

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
              GestureDetector(
                onTap: () => _showStoreHealthInfo(context),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scoreColor.withValues(alpha: 0.6), scoreColor],
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: scoreColor.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${data.score}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              data.status,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthLegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _HealthLegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Low stock section
class _LowStockSection extends StatelessWidget {
  final List<ProductModel> items;
  final bool isLoading;
  final String? errorMessage;

  const _LowStockSection({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

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
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: DotsLoader(),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No low stock items',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.stock.toString().replaceAll(RegExp(r'\.0$'), ''),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(color: AppTheme.grey100),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.lowStock),
                child: Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sales summary section with bar chart
class _SalesSummarySection extends StatefulWidget {
  final List<MonthlySalesData> data;
  final bool isLoading;
  final String? errorMessage;
  final String currentFilter;
  final Function(String) onFilterChanged;

  const _SalesSummarySection({
    required this.data,
    this.isLoading = false,
    this.errorMessage,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<_SalesSummarySection> createState() => _SalesSummarySectionState();
}

class _SalesSummarySectionState extends State<_SalesSummarySection> {
  final ScrollController _scrollController = ScrollController();
  int? _selectedIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isLoading = widget.isLoading;
    final errorMessage = widget.errorMessage;
    final currentFilter = widget.currentFilter;
    final onFilterChanged = widget.onFilterChanged;

    if (isLoading) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: const DotsLoader(text: 'Fetching sales summary'),
      );
    }

    if (errorMessage != null) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final maxSales = data.isEmpty
        ? 1.0
        : data.map((e) => e.totalSales).reduce(max);

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
              Expanded(
                child: Column(
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _legendDot(const Color(0xFF4CAF50)),
                            const SizedBox(width: 4),
                            Text(
                              'Total Sales',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _legendDot(AppTheme.grey800),
                            const SizedBox(width: 4),
                            Text(
                              'Number of transactions',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentFilter,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    isDense: true,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onFilterChanged(newValue);
                      }
                    },
                    items: [
                      const DropdownMenuItem(
                        value: '7days',
                        child: Text('This week'),
                      ),
                      const DropdownMenuItem(
                        value: '30days',
                        child: Text('This month'),
                      ),
                      const DropdownMenuItem(
                        value: '12months',
                        child: Text('This year'),
                      ),
                      // const DropdownMenuItem(
                      //   value: 'next_week_ai',
                      //   child: Text('Next week (AI)'),
                      // ),
                      // const DropdownMenuItem(
                      //   value: 'next_month_ai',
                      //   child: Text('Next month (AI)'),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // y-axis labels + bars
          SizedBox(
            height: 280,
            child: Row(
              children: [
                // y-axis labels
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AmountFormatter.formatCompact(maxSales * 1.0),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatCompact(maxSales * 0.75),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatCompact(maxSales * 0.5),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatCompact(maxSales * 0.25),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '0',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // bars
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thumbColor: AppTheme.primaryColor.withValues(
                          alpha: 0.5,
                        ),
                        radius: const Radius.circular(8),
                        thickness: 6,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: data.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final isSelected = _selectedIndex == index;

                                final barHeight =
                                    (item.totalSales / maxSales) * 140;
                                final txnHeight =
                                    (item.transactions / 250) * 140;

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = isSelected
                                          ? null
                                          : index;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (isSelected)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: AppTheme.grey200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AmountFormatter.formatCurrency(
                                                    item.totalSales,
                                                    showDecimals: false,
                                                  ),
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                          0xFF4CAF50,
                                                        ),
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${item.transactions} transactions',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.grey800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          const SizedBox(
                                            height: 60,
                                          ), // placeholder
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 10,
                                              height: barHeight.clamp(
                                                4.0,
                                                140.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Container(
                                              width: 10,
                                              height: txnHeight.clamp(
                                                4.0,
                                                140.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.grey800,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.month,
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppTheme.textPrimary
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 24,
                                        ), // spacing for scrollbar
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Expenses overview section

/// Stock level section with line chart
class _StockLevelSection extends StatelessWidget {
  final List<StockLevelData> data;
  final bool isLoading;
  final String? errorMessage;

  const _StockLevelSection({
    required this.data,
    this.isLoading = false,
    this.errorMessage,
  });

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
          const SizedBox(height: 14),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: DotsLoader(),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
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
                  'Stock Count',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                  ),
                );
              }).toList(),
            ),
          ],
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
      final y =
          size.height -
          ((data[i].totalStock - minStock) /
                  effectiveRange *
                  (size.height - 20) +
              10);
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
  final List<TopSellingProduct> items;
  final String? errorMessage;
  final bool isLoading;

  const _TopSalesSection({
    required this.items,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Sales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
                child: DotsLoader(text: 'Fetching top sales'),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingLarge,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'Failed to load top sales: $errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            )
          else if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
                child: Text('No sales data available'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length > 5 ? 5 : items.length,
              separatorBuilder: (context, index) => const Divider(
                height: AppTheme.spacingLarge,
                color: AppTheme.grey300,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _TopSalesRow(rank: index + 1, item: item);
              },
            ),
        ],
      ),
    );
  }
}

class _TopSalesRow extends StatelessWidget {
  final int rank;
  final TopSellingProduct item;

  const _TopSalesRow({required this.rank, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: rank <= 3
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank <= 3
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.categoryName != null)
                Text(
                  item.categoryName!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AmountFormatter.formatCurrency(
                item.totalAmount,
                showDecimals: false,
              ),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${item.totalQuantity} Sold',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
