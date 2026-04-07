import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/invoices/presentation/providers/invoice_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/empty_state_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:onepos_admin_app/features/invoices/data/models/invoice_model.dart';
import 'package:onepos_admin_app/features/invoices/presentation/widgets/invoice_detail_dialog.dart';
import 'package:onepos_admin_app/features/sales/presentation/providers/sales_provider.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HookConsumer(
      builder: (context, ref, child) {
        final invoicesAsync = ref.watch(invoicesListProvider);
        final searchController = useTextEditingController();
        final searchQuery = useState('');
        final expandedInvoiceId = useState<String?>(null);

        // watch sales to sync items if missing
        final salesAsync = ref.watch(salesProvider);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const CustomAppBar2(title: 'Invoices'),
          body: Column(
            children: [
              // search bar
              CustomSearchBar(
                controller: searchController,
                onChanged: (value) => searchQuery.value = value,
                onClear: () => searchQuery.value = '',
              ),
              Expanded(
                child: invoicesAsync.when(
                  data: (response) {
                    if (!response.success) {
                      return Center(
                        child: Text(
                          response.message ?? 'failed to load invoices',
                          style: GoogleFonts.poppins(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      );
                    }
                    final allInvoices = response.data ?? [];
                    final filtered = searchQuery.value.isEmpty
                        ? allInvoices
                        : allInvoices
                              .where(
                                (i) => i.id.toString().toLowerCase().contains(
                                  searchQuery.value.toLowerCase(),
                                ),
                              )
                              .toList();

                    if (filtered.isEmpty) {
                      return EmptyStateWidget(
                        title: 'No invoices found',
                        message: searchQuery.value.isEmpty
                            ? 'You haven\'t created any invoices yet'
                            : 'No invoices match your search',
                        icon: Icons.receipt_long_outlined,
                      );
                    }

                    return AnimationLimiter(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingSmall,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppTheme.spacingSmall),
                        itemBuilder: (context, index) {
                          final invoice = filtered[index];
                          final isExpanded =
                              expandedInvoiceId.value == invoice.id;

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _InvoiceTile(
                                  invoice: invoice,
                                  isExpanded: isExpanded,
                                  onToggle: () {
                                    expandedInvoiceId.value = isExpanded
                                        ? null
                                        : invoice.id;
                                  },
                                  matchingSale: salesAsync.valueOrNull?.sales
                                      .where(
                                        (s) =>
                                            s.orderNumber ==
                                                invoice.invoiceNumber ||
                                            s.id == invoice.id,
                                      )
                                      .firstOrNull,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'failed to load invoices',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(invoicesListProvider),
                          child: const Text('retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createInvoice),
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final InvoiceModel invoice;
  final bool isExpanded;
  final VoidCallback onToggle;
  final dynamic matchingSale;

  const _InvoiceTile({
    required this.invoice,
    required this.isExpanded,
    required this.onToggle,
    this.matchingSale,
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.sales,
                  arguments: invoice.invoiceNumber ?? invoice.id,
                );
              },
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Row(
                  children: [
                    // invoice icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall + 4),

                    // invoice details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${invoice.invoiceNumber ?? invoice.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (invoice.customerName != null)
                            Text(
                              invoice.customerName!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // total amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AmountFormatter.formatCurrency(invoice.total),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _StatusBadge(status: invoice.sendOption),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                      onPressed: onToggle,
                    ),
                  ],
                ),
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
                  _DetailRow(
                    label: 'Date:',
                    value: invoice.createdAt != null
                        ? DateFormat('MMM dd, yyyy').format(invoice.createdAt!)
                        : 'n/a',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Items:',
                    value:
                        '${matchingSale?.items.length ?? invoice.items.length} items',
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final displayInvoice = matchingSale != null
                                ? invoice.copyWith(
                                    items: (matchingSale.items as List)
                                        .map(
                                          (i) =>
                                              InvoiceItemModel.fromSaleItem(i),
                                        )
                                        .toList(),
                                  )
                                : invoice;

                            showDialog(
                              context: context,
                              builder: (context) =>
                                  InvoiceDetailDialog(invoice: displayInvoice),
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'now':
        color = Colors.green;
        break;
      case 'scheduled':
        color = Colors.orange;
        break;
      case 'recurring':
        color = Colors.blue;
        break;
      default:
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toLowerCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
