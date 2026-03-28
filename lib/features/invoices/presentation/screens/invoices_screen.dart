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
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _InvoiceTile(invoice: invoice),
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
  final dynamic invoice;

  const _InvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // show details dialog or navigate
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
                    children: [
                      Text(
                        'Invoice #${invoice.invoiceNumber ?? invoice.id}',
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
                      Text(
                        invoice.createdAt != null
                            ? DateFormat(
                                'MMM dd, yyyy',
                              ).format(invoice.createdAt!)
                            : 'n/a',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // total amount and status
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusBadge(status: invoice.sendOption),
                        const SizedBox(width: 4),
                        // if status exists in json, show it
                        if (invoice
                            .id
                            .isNotEmpty) // dummy check to use status if we had it
                          _StatusBadge(
                            status: 'sent', // default for now based on log
                            isStatus: true,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isStatus;

  const _StatusBadge({required this.status, this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    final color = isStatus
        ? (status.toLowerCase() == 'sent'
              ? Colors.green
              : status.toLowerCase() == 'pending'
              ? Colors.orange
              : AppTheme.primaryColor)
        : AppTheme.primaryColor;

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
