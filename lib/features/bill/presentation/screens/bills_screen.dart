import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/core/utils/extensions.dart';
import 'package:onepos_admin_app/features/bill/presentation/providers/bill_providers.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart' as custom;
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';

/// Screen for viewing and managing bills
class BillsScreen extends HookConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsProvider);
    final expandedIndex = useState<int?>(null);
    final searchController = useTextEditingController();
    final scrollController = useScrollController();

    // pagination listener
    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(billsProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bills',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
              child: CustomSearchBar(
                controller: searchController,
                hintText: 'Search',
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Expanded(
              child: billsAsync.when(
                data: (state) {
                  if (state.bills.isEmpty && !state.isLoading) {
                    return const Center(child: Text('No bills found'));
                  }

                  if (state.error != null && state.bills.isEmpty) {
                    return custom.CustomErrorWidget(
                      message: state.error!,
                      onRetry: () => ref.read(billsProvider.notifier).refresh(),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(billsProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(
                        AppTheme.spacingMedium,
                      ).copyWith(bottom: 80),
                      itemCount:
                          state.bills.length + (state.hasMorePages ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppTheme.spacingMedium),
                      itemBuilder: (context, index) {
                        if (index == state.bills.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final bill = state.bills[index];
                        final isExpanded = expandedIndex.value == index;

                        return GestureDetector(
                          onTap: () {
                            expandedIndex.value = isExpanded ? null : index;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bill.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          AmountFormatter.formatCurrency(
                                            double.tryParse(bill.percentage) ??
                                                0,
                                            showDecimals: false,
                                          ),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: AppTheme.textSecondary,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  _DetailRow(
                                    label: 'Bill type',
                                    value: bill.billOption?.name ?? 'N/A',
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Status',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            bill.isActive == 1
                                                ? 'Active'
                                                : 'Inactive',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: bill.isActive == 1
                                                  ? const Color(0xFF4CAF50)
                                                  : AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          CustomSwitch(
                                            value: bill.isActive == 1,
                                            onChanged: (value) async {
                                              final response = await ref
                                                  .read(billsProvider.notifier)
                                                  .toggleBillStatus(
                                                    bill.id,
                                                    value,
                                                  );
                                              if (response.success) {
                                                context.showSnackBar(
                                                  response.message ??
                                                      'Status updated',
                                                );
                                              } else {
                                                context.showSnackBar(
                                                  response.message ??
                                                      'Failed to update',
                                                  isError: true,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButtonWithIcon(
                                          text: 'Edit',
                                          icon: Icons.edit_outlined,
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.addBill,
                                              arguments: bill,
                                            );
                                          },
                                          isOutlined: true,
                                          textColor: AppTheme.blue,
                                          iconColor: AppTheme.blue,
                                          borderColor: AppTheme.blue,
                                          height: 44,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CustomButtonWithIcon(
                                          text: 'Delete',
                                          icon: Icons.delete_outline,
                                          onPressed: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Delete Bill',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to delete this bill setting?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              final response = await ref
                                                  .read(billsProvider.notifier)
                                                  .deleteBillItem(
                                                    int.parse(
                                                      bill.id.toString(),
                                                    ),
                                                  );

                                              if (response.success) {
                                                context.showSnackBar(
                                                  'Bill deleted successfully',
                                                );
                                              } else {
                                                context.showSnackBar(
                                                  response.message ??
                                                      'An error occurred',
                                                  isError: true,
                                                );
                                              }
                                            }
                                          },
                                          isOutlined: true,
                                          textColor: const Color(0xFFD32F2F),
                                          iconColor: const Color(0xFFD32F2F),
                                          borderColor: const Color(0xFFD32F2F),
                                          height: 44,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (e, s) => custom.CustomErrorWidget(
                  message: e.toString(),
                  onRetry: () => ref.refresh(billsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addBill);
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
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
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
