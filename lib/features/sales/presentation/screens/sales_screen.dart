import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/sales/presentation/providers/sales_provider.dart';
import 'package:onepos_admin_app/features/sales/presentation/widgets/sale_detail_dialog.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/empty_state_widget.dart';
import 'package:onepos_admin_app/shared/widgets/dots_loader.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

/// sales screen with expandable sale tiles
class SalesScreen extends HookConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final activeFilter = useState(SalesFilter.empty);
    final expandedSaleId = useState<String?>(null);
    final scrollController = useScrollController();
    final salesAsync = ref.watch(salesProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(salesProvider.notifier).refreshSales();
      });
      return null;
    }, const []);

    // listen for scroll changes for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(salesProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Sales',
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.salesSettings),
          ),
        ],
      ),
      body: Column(
        children: [
          // search bar with filter icon
          CustomSearchBar(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            onClear: () => searchQuery.value = '',
            hintText: 'Search by customer, order #, or cashier',
            trailing: [
              IconButton(
                icon: const Icon(
                  Icons.tune,
                  size: 22,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () async {
                  final currentSales =
                      salesAsync.valueOrNull?.sales ?? const <SaleModel>[];
                  final nextFilter = await _showFilterDialog(
                    context,
                    currentFilter: activeFilter.value,
                    sales: currentSales,
                  );
                  if (nextFilter != null) {
                    activeFilter.value = nextFilter;
                  }
                },
              ),
            ],
          ),

          // sales list
          Expanded(
            child: salesAsync.when(
              data: (salesState) {
                final filtered = _applySearchAndFilter(
                  salesState.sales,
                  searchQuery.value,
                  activeFilter.value,
                );

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No sales found',
                    message:
                        searchQuery.value.isNotEmpty ||
                            activeFilter.value.hasActiveFilters
                        ? 'Try adjusting your search or filters'
                        : 'No sales recorded yet',
                    icon: Icons.history,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(salesProvider.notifier).refreshSales(),
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    itemCount:
                        filtered.length + (salesState.hasMorePages ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTheme.spacingSmall),
                    itemBuilder: (context, index) {
                      if (index >= filtered.length) {
                        return const DotsLoader();
                      }

                      final sale = filtered[index];
                      final isExpanded = expandedSaleId.value == sale.id;

                      return _SaleTile(
                        sale: sale,
                        isExpanded: isExpanded,
                        onToggle: () {
                          expandedSaleId.value = isExpanded ? null : sale.id;
                        },
                        onView: () {
                          _showSaleDetailsDialog(context, sale);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: LoadingWidget()),
              error: (error, stack) => CustomErrorWidget(
                message: error.toString(),
                onRetry: () => ref.read(salesProvider.notifier).refreshSales(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// show filter bottom sheet dialog
  Future<SalesFilter?> _showFilterDialog(
    BuildContext context, {
    required SalesFilter currentFilter,
    required List<SaleModel> sales,
  }) {
    final cashierOptions =
        sales
            .map((s) => s.cashierName)
            .where((s) => s.isNotEmpty && s != 'N/A')
            .toSet()
            .toList()
          ..sort();
    final customerOptions =
        sales
            .map((s) => s.customerName)
            .where((s) => s.isNotEmpty && s != 'N/A')
            .toSet()
            .toList()
          ..sort();
    final paymentOptions =
        sales
            .map((s) => s.paymentMethod ?? 'N/A')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final statusOptions =
        sales.map((s) => s.status).where((s) => s.isNotEmpty).toSet().toList()
          ..sort();

    return showDialog<SalesFilter>(
      context: context,
      builder: (context) => _SalesFilterDialog(
        initialFilter: currentFilter,
        cashierOptions: cashierOptions,
        customerOptions: customerOptions,
        paymentOptions: paymentOptions,
        statusOptions: statusOptions,
      ),
    );
  }

  /// show sale details dialog
  void _showSaleDetailsDialog(BuildContext context, SaleModel sale) {
    showDialog(
      context: context,
      builder: (context) => SaleDetailDialog(sale: sale),
    );
  }

  List<SaleModel> _applySearchAndFilter(
    List<SaleModel> sales,
    String query,
    SalesFilter filter,
  ) {
    final lowerQuery = query.trim().toLowerCase();

    return sales.where((sale) {
      final matchesSearch =
          lowerQuery.isEmpty ||
          sale.customerName.toLowerCase().contains(lowerQuery) ||
          sale.orderNumber.toLowerCase().contains(lowerQuery) ||
          sale.cashierName.toLowerCase().contains(lowerQuery) ||
          sale.status.toLowerCase().contains(lowerQuery);

      final saleTotal = sale.totalPrice ?? sale.totalAmount;
      final matchesMinPrice =
          filter.minPrice == null || saleTotal >= filter.minPrice!;
      final matchesMaxPrice =
          filter.maxPrice == null || saleTotal <= filter.maxPrice!;
      final matchesCashier =
          filter.cashier == null || sale.cashierName == filter.cashier;
      final matchesCustomer =
          filter.customer == null || sale.customerName == filter.customer;
      final matchesPayment =
          filter.paymentMethod == null ||
          (sale.paymentMethod ?? 'N/A') == filter.paymentMethod;
      final matchesStatus =
          filter.status == null || sale.status == filter.status;

      final matchesStartDate =
          filter.startDate == null ||
          !sale.date.isBefore(_startOfDay(filter.startDate!));
      final matchesEndDate =
          filter.endDate == null ||
          !sale.date.isAfter(_endOfDay(filter.endDate!));

      return matchesSearch &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesCashier &&
          matchesCustomer &&
          matchesPayment &&
          matchesStatus &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
  }
}

/// expandable sale tile
class _SaleTile extends StatelessWidget {
  final SaleModel sale;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;

  const _SaleTile({
    required this.sale,
    required this.isExpanded,
    required this.onToggle,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // header row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer name',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sale.customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusLabel(sale.status),
                      const SizedBox(height: 2),
                      Text(
                        AmountFormatter.formatCurrency(
                          sale.totalAmount,
                          showDecimals: false,
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // expanded content
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
              ),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                children: [
                  _DetailRow(label: 'Order number:', value: sale.orderNumber),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Cashier name:', value: sale.cashierName),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Date:',
                    value: DateFormat('MMM d, yyyy').format(sale.date),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  CustomButtonWithIcon(
                    text: 'View Details',
                    icon: Icons.visibility_outlined,
                    onPressed: onView,
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryColor,
                    isOutlined: true,
                    height: 44,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppTheme.successColor;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = AppTheme.errorColor;
        break;
      default:
        color = AppTheme.textSecondary;
    }
    return Text(
      status.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// filter dialog for sales
class _SalesFilterDialog extends HookWidget {
  final SalesFilter initialFilter;
  final List<String> cashierOptions;
  final List<String> customerOptions;
  final List<String> paymentOptions;
  final List<String> statusOptions;

  const _SalesFilterDialog({
    required this.initialFilter,
    required this.cashierOptions,
    required this.customerOptions,
    required this.paymentOptions,
    required this.statusOptions,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCashier = useState<String?>(initialFilter.cashier);
    final selectedCustomer = useState<String?>(initialFilter.customer);
    final selectedPaymentMethod = useState<String?>(
      initialFilter.paymentMethod,
    );
    final selectedStatus = useState<String?>(initialFilter.status);
    final startDate = useState<DateTime?>(initialFilter.startDate);
    final endDate = useState<DateTime?>(initialFilter.endDate);
    final rangeValues = useState(
      RangeValues(
        initialFilter.minPrice ?? 0,
        initialFilter.maxPrice ?? 1000000,
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              Text(
                'Price Range',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AmountFormatter.formatCurrency(rangeValues.value.start)} - ${AmountFormatter.formatCurrency(rangeValues.value.end)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              RangeSlider(
                values: rangeValues.value,
                min: 0,
                max: 1000000,
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.grey300,
                onChanged: (v) => rangeValues.value = v,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              _buildDropdown('Cashier', selectedCashier, cashierOptions),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildDropdown('Customer', selectedCustomer, customerOptions),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildDropdown(
                'Payment Type',
                selectedPaymentMethod,
                paymentOptions,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildDropdown('Status', selectedStatus, statusOptions),
              const SizedBox(height: AppTheme.spacingMedium),

              Row(
                children: [
                  Expanded(
                    child: _DatePickerButton(
                      label: 'Start Date',
                      value: startDate.value,
                      onPicked: (d) => startDate.value = d,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DatePickerButton(
                      label: 'End Date',
                      value: endDate.value,
                      onPicked: (d) => endDate.value = d,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Reset',
                      onPressed: () =>
                          Navigator.pop(context, SalesFilter.empty),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Apply',
                      onPressed: () {
                        Navigator.pop(
                          context,
                          SalesFilter(
                            minPrice: rangeValues.value.start,
                            maxPrice: rangeValues.value.end,
                            cashier: selectedCashier.value,
                            customer: selectedCustomer.value,
                            paymentMethod: selectedPaymentMethod.value,
                            status: selectedStatus.value,
                            startDate: startDate.value,
                            endDate: endDate.value,
                          ),
                        );
                      },
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    ValueNotifier<String?> notifier,
    List<String> options,
  ) {
    return AppDropdown<String>(
      hint: hint,
      value: notifier.value,
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => notifier.value = v,
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final Function(DateTime) onPicked;

  const _DatePickerButton({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grey300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? DateFormat('MMM d, yyyy').format(value!)
                    : label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: value != null
                      ? AppTheme.textPrimary
                      : AppTheme.textHint,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
