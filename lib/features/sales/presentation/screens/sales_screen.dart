import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/features/sales/presentation/providers/sales_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

/// sales screen with expandable sale tiles
class SalesScreen extends HookConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final expandedSaleId = useState<String?>(null);
    final salesAsync = ref.watch(salesProvider);

    // listen for search changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Sales',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // search bar with filter icon
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            child: Row(
              children: [
                // search field
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textHint,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium),
                        borderSide: BorderSide(color: AppTheme.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium),
                        borderSide: BorderSide(color: AppTheme.grey300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),

                // filter button
                GestureDetector(
                  onTap: () => _showFilterDialog(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium),
                      border: Border.all(color: AppTheme.grey300),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: AppTheme.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // sales list
          Expanded(
            child: salesAsync.when(
              data: (sales) {
                final filtered = searchQuery.value.isEmpty
                    ? sales
                    : sales
                        .where((s) =>
                            s.customerName
                                .toLowerCase()
                                .contains(
                                    searchQuery.value.toLowerCase()) ||
                            s.orderNumber
                                .toLowerCase()
                                .contains(
                                    searchQuery.value.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No sales found',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacingSmall),
                  itemBuilder: (context, index) {
                    final sale = filtered[index];
                    final isExpanded = expandedSaleId.value == sale.id;

                    return _SaleTile(
                      sale: sale,
                      isExpanded: isExpanded,
                      onToggle: () {
                        expandedSaleId.value =
                            isExpanded ? null : sale.id;
                      },
                      onView: () {
                        _showSaleDetailsDialog(context, sale);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingWidget()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load sales',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(salesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// show filter bottom sheet dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _SalesFilterDialog(),
    );
  }

  /// show sale details dialog
  void _showSaleDetailsDialog(BuildContext context, SaleModel sale) {
    showDialog(
      context: context,
      builder: (context) => _SaleDetailsDialog(sale: sale),
    );
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
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          // header row (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // left column: customer name label + value
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
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // right column: status + amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // status badge
                          Text(
                            sale.status,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(sale.status),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // amount
                          Text(
                            AmountFormatter.formatCurrency(
                              sale.totalAmount,
                              showDecimals: false,
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 4),

                      // expand/collapse icon
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // expanded content
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMedium,
                AppTheme.spacingSmall + 4,
                AppTheme.spacingMedium,
                0,
              ),
              child: Column(
                children: [
                  // order number row
                  _DetailRow(
                    label: 'Order number:',
                    value: sale.orderNumber,
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // cashier name row
                  _DetailRow(
                    label: 'Cashier name:',
                    value: sale.cashierName,
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // date row
                  _DetailRow(
                    label: 'Date:',
                    value: _formatDate(sale.date),
                  ),
                ],
              ),
            ),

            // divider before action
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall + 4,
              ),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),

            // view button
            CustomButtonWithIcon(
              text: 'View', 
              icon: Icons.visibility_outlined,
              onPressed: (){
                onView();
              },
              backgroundColor: AppTheme.white,
              textColor: AppTheme.primaryColor,
              isOutlined: true
            )
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d\'th\', yyyy').format(date);
  }
}

/// detail row with label and value
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
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
  const _SalesFilterDialog();

  @override
  Widget build(BuildContext context) {
    final selectedCashier = useState<String?>(null);
    final selectedCustomer = useState<String?>(null);
    final selectedDiscount = useState<String?>(null);
    final selectedPaymentMethod = useState<String?>(null);
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);

    // price range
    final rangeValues = useState(const RangeValues(1000, 500000));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // price range section
              Text(
                'Select a price range',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                '\$${rangeValues.value.start.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}  -  \$${rangeValues.value.end.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.black,
                  inactiveTrackColor: AppTheme.grey300,
                  thumbColor: Colors.black,
                  overlayColor: Colors.black.withOpacity(0.1),
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: RangeSlider(
                  values: rangeValues.value,
                  min: 0,
                  max: 1000000,
                  onChanged: (values) {
                    rangeValues.value = values;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // select cashier dropdown
              AppDropdown<String>(
                hint: 'Select cashier',
                value: selectedCashier.value,
                items: const ['John Doe', 'Jane Smith', 'Mike Johnson']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedCashier.value = value,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // select customer dropdown
              AppDropdown<String>(
                hint: 'Select customer',
                value: selectedCustomer.value,
                items: const ['John Doe', 'Jane Doe', 'Bob Smith']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedCustomer.value = value,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // select discount dropdown
              AppDropdown<String>(
                hint: 'Select discount',
                value: selectedDiscount.value,
                items: const ['10%', '20%', '30%', '50%']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => selectedDiscount.value = value,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // select payment method dropdown
              AppDropdown<String>(
                hint: 'Select payment method',
                value: selectedPaymentMethod.value,
                items: const ['Cash', 'Card', 'Transfer', 'Mobile Money']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    selectedPaymentMethod.value = value,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // date range row
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      hint: 'Start date',
                      value: startDate.value,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          startDate.value = picked;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: _DatePickerField(
                      hint: 'End date',
                      value: endDate.value,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          endDate.value = picked;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // action buttons
              Row(
                children: [
                  // cancel button
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),

                  // search button
                  Expanded(
                    child: CustomButton(
                      text: 'Search',
                      onPressed: () {
                        // TODO: apply filters and close
                        Navigator.pop(context);
                      },
                      backgroundColor: AppTheme.blue,
                      height: 50,
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
}

/// date picker field widget
class _DatePickerField extends StatelessWidget {
  final String hint;
  final DateTime? value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: AppTheme.grey300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? DateFormat('MMM d, yyyy').format(value!)
                    : hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: value != null
                      ? AppTheme.textPrimary
                      : AppTheme.textHint,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// sale details dialog
class _SaleDetailsDialog extends StatelessWidget {
  final SaleModel sale;

  const _SaleDetailsDialog({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row with order number and close button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // order number
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Order No: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                ),
                              ),
                              TextSpan(
                                text: sale.orderNumber,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // title
                        Text(
                          'Sales Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // status badge + date
                        Row(
                          children: [
                            // status chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusSmall),
                              ),
                              child: Text(
                                sale.status,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSmall),

                            // date
                            Text(
                              DateFormat('MMM d, yyyy, h:mma')
                                  .format(sale.date),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // order section
              _SectionHeader(title: 'Order'),
              const SizedBox(height: AppTheme.spacingSmall),
              _InfoRow(
                label: 'Total',
                value: AmountFormatter.formatCurrency(
                  sale.totalPrice ?? sale.totalAmount,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // customer section
              _SectionHeader(title: 'Customer'),
              const SizedBox(height: AppTheme.spacingSmall),
              _InfoRow(
                label: 'Customer name:',
                value: 'Cashier ${sale.customerName}',
              ),
              const SizedBox(height: 6),
              _InfoRow(
                label: 'Address:',
                value: sale.customerAddress ?? 'N/A',
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // cashier section
              _SectionHeader(title: 'Cashier'),
              const SizedBox(height: AppTheme.spacingSmall),
              _InfoRow(
                label: 'Cashier name:',
                value: sale.cashierName,
              ),
              const SizedBox(height: 6),
              _InfoRow(
                label: 'Email:',
                value: sale.cashierEmail ?? 'N/A',
              ),
              const SizedBox(height: 6),
              _InfoRow(
                label: 'Phone:',
                value: sale.cashierPhone ?? 'N/A',
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // order items section
              Text(
                'Order Items',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),

              // items table header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DA6C9),
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(AppTheme.borderRadiusSmall),
                    topRight:
                        Radius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Product',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Quantity',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Unit Price',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // items table body
              ...sale.items.map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppTheme.grey200),
                      right: BorderSide(color: AppTheme.grey200),
                      bottom: BorderSide(color: AppTheme.grey200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.productName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          AmountFormatter.formatCurrency(
                            item.unitPrice,
                            symbol: '\$',
                            showDecimals: false,
                          ),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // total row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppTheme.grey200),
                    right: BorderSide(color: AppTheme.grey200),
                    bottom: BorderSide(color: AppTheme.grey200),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(AppTheme.borderRadiusSmall),
                    bottomRight:
                        Radius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // payment method section
              _SectionHeader(title: 'Payment Method'),
              const SizedBox(height: AppTheme.spacingSmall),
              _InfoRow(
                label: 'Loyalrty applied:',
                value: sale.loyaltyApplied != null
                    ? AmountFormatter.formatCurrency(sale.loyaltyApplied)
                    : 'N/A',
              ),
              const SizedBox(height: 6),
              _InfoRow(
                label: 'Total price:',
                value: AmountFormatter.formatCurrency(
                  sale.totalPrice ?? sale.totalAmount,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // close button
              CustomButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                backgroundColor: AppTheme.blue,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// section header label
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

/// info row with label and value for the details dialog
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
