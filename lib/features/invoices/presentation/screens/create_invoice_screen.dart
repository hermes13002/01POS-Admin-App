import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/features/customers/presentation/providers/customers_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import '../providers/invoice_provider.dart';
import 'package:onepos_admin_app/features/customers/data/models/customer_model.dart';
import '../../data/models/invoice_model.dart';

class CreateInvoiceScreen extends HookConsumerWidget {
  const CreateInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    final productsAsync = ref.watch(productsProvider);
    final customersAsync = ref.watch(customersProvider);
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');

    // filter products based on search
    final filteredProducts = useMemoized(() {
      final products = productsAsync.valueOrNull?.products ?? [];
      if (searchQuery.value.isEmpty) return products;
      return products
          .where(
            (p) =>
                p.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
          )
          .toList();
    }, [productsAsync.valueOrNull, searchQuery.value]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(title: 'Create Invoice'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left section: select products
                Expanded(
                  flex: 3,
                  child: _ProductSelectionSection(
                    searchCtrl: searchCtrl,
                    onSearch: (v) => searchQuery.value = v,
                    products: filteredProducts,
                    onAdd: (product) {
                      ref
                          .read(invoiceProvider.notifier)
                          .addItem(
                            InvoiceItemModel(
                              productId: product.id.toString(),
                              productName: product.name,
                              price: product.price,
                              imageUrl: product.imageUrl,
                            ),
                          );
                    },
                  ),
                ),
                // right section: invoice details sidebar
                Expanded(
                  flex: 1,
                  child: _InvoiceSummarySidebar(
                    invoice: invoice,
                    customersAsync: customersAsync,
                  ),
                ),
              ],
            );
          } else {
            // mobile/tablet: stack them vertically
            return SingleChildScrollView(
              child: Column(
                children: [
                  _ProductSelectionSection(
                    searchCtrl: searchCtrl,
                    onSearch: (v) => searchQuery.value = v,
                    products: filteredProducts,
                    onAdd: (product) {
                      ref
                          .read(invoiceProvider.notifier)
                          .addItem(
                            InvoiceItemModel(
                              productId: product.id.toString(),
                              productName: product.name,
                              price: product.price,
                              imageUrl: product.imageUrl,
                            ),
                          );
                    },
                  ),
                  _InvoiceSummarySidebar(
                    invoice: invoice,
                    customersAsync: customersAsync,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _ProductSelectionSection extends StatelessWidget {
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final List<dynamic> products;
  final Function(dynamic) onAdd;

  const _ProductSelectionSection({
    required this.searchCtrl,
    required this.onSearch,
    required this.products,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Text(
                'Select Products',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // search bar
              CustomSearchBar(
                controller: searchCtrl,
                onChanged: onSearch,
                onClear: () => onSearch(''),
              ),
              const SizedBox(height: 16),
              // product table header - only show on desktop/tablet
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: _HeaderCell('Image')),
                      Expanded(flex: 3, child: _HeaderCell('Name')),
                      Expanded(flex: 2, child: _HeaderCell('Price')),
                      Expanded(flex: 1, child: _HeaderCell('Stock')),
                      Expanded(flex: 2, child: _HeaderCell('Action')),
                    ],
                  ),
                ),
              // product list
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No products found')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    if (isMobile) {
                      // responsive card-like row for mobile
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppTheme.grey200,
                                  child: Center(
                                    child: Text(
                                      product.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AmountFormatter.formatCurrency(
                                      product.price,
                                    ),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => onAdd(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                    }

                    // desktop/tablet row
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl ?? '',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: AppTheme.grey200,
                                  child: Center(
                                    child: Text(
                                      product.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              product.name,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              AmountFormatter.formatCurrency(product.price),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${product.stock}',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => onAdd(product),
                              icon: const Icon(Icons.add, size: 14),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              // pagination placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Prev'),
                  ),
                  Text('Page 1 of 3', style: GoogleFonts.poppins(fontSize: 13)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InvoiceSummarySidebar extends ConsumerWidget {
  final InvoiceModel invoice;
  final AsyncValue<CustomersState> customersAsync;

  const _InvoiceSummarySidebar({
    required this.invoice,
    required this.customersAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Invoice Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // customer selection
          const _Label('Customer *'),
          const SizedBox(height: 6),
          customersAsync.when(
            data: (state) => AppDropdown<int>(
              items: state.customers
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              value: int.tryParse(invoice.customerId),
              onChanged: (v) {
                if (v != null) {
                  ref.read(invoiceProvider.notifier).setCustomer(v.toString());
                }
              },
              hint: 'Select Customer',
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error loading customers'),
          ),
          const SizedBox(height: 16),
          // selected products summary
          const _Label('Selected Products'),
          const SizedBox(height: 6),
          if (invoice.items.isEmpty)
            Text(
              'No products selected',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.grey500,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...invoice.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.productName}',
                        style: GoogleFonts.poppins(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      AmountFormatter.formatCurrency(
                        item.price * item.quantity,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () => ref
                          .read(invoiceProvider.notifier)
                          .removeItem(item.productId),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const _Label('Discount (optional)'),
          const SizedBox(height: 6),
          AppDropdown<double>(
            items: const [
              DropdownMenuItem(value: 0.0, child: Text('No Discount')),
              DropdownMenuItem(value: 5.0, child: Text('5%')),
              DropdownMenuItem(value: 10.0, child: Text('10%')),
              DropdownMenuItem(value: 15.0, child: Text('15%')),
            ],
            value: invoice.discount,
            onChanged: (v) =>
                ref.read(invoiceProvider.notifier).setDiscount(v ?? 0.0),
            hint: 'Select Discount',
          ),
          const SizedBox(height: 16),
          const _Label('Tax (optional)'),
          const SizedBox(height: 6),
          AppDropdown<double>(
            items: const [
              DropdownMenuItem(value: 0.0, child: Text('No Tax')),
              DropdownMenuItem(value: 5.0, child: Text('5%')),
              DropdownMenuItem(value: 7.5, child: Text('7.5%')),
              DropdownMenuItem(value: 10.0, child: Text('10%')),
            ],
            value: invoice.tax,
            onChanged: (v) =>
                ref.read(invoiceProvider.notifier).setTax(v ?? 0.0),
            hint: 'Select Tax',
          ),
          const SizedBox(height: 16),
          const _Label('Send Invoice *'),
          Column(
            children:
                {
                      'now': 'Send Now',
                      'later': 'Send Later',
                      'recurring': 'Recurring',
                    }.entries
                    .map(
                      (entry) => RadioListTile<String>(
                        title: Text(
                          entry.value,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        value: entry.key,
                        groupValue: invoice.sendOption,
                        onChanged: (v) => ref
                            .read(invoiceProvider.notifier)
                            .setSendOption(v!),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
          ),
          const Divider(height: 32),
          _SummaryRow(
            'Subtotal:',
            AmountFormatter.formatCurrency(invoice.subtotal),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            'Total:',
            AmountFormatter.formatCurrency(invoice.total),
            isBold: true,
            fontSize: 18,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (invoice.items.isEmpty || invoice.customerId.isEmpty)
                  ? null
                  : () async {
                      final notifier = ref.read(invoiceProvider.notifier);
                      final response = await notifier.createInvoice();

                      if (context.mounted) {
                        if (response.success) {
                          AppSnackbar.showSuccess(
                            context,
                            'Invoice created successfully',
                          );
                          Navigator.pop(context);
                        } else {
                          AppSnackbar.showError(
                            context,
                            response.message ?? 'Unknown error',
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.grey300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                invoice.sendOption.contains('now')
                    ? 'Send Invoice Now'
                    : 'Save Invoice',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
