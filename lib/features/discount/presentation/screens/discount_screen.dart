import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/discount/presentation/providers/discount_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';

/// Screen for viewing and managing discounts
class DiscountScreen extends HookConsumerWidget {
  const DiscountScreen({super.key});

  /// show confirmation dialog before deleting
  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Discount',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this discount?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discountsAsync = ref.watch(discountsProvider);
    final expandedIndex = useState<int?>(0);
    final searchController = useTextEditingController();
    useListenable(searchController);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Discount',
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
                onClear: () => searchController.clear(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Expanded(
              child: discountsAsync.when(
                loading: () => const LoadingWidget(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (discounts) {
                  final query = searchController.text.toLowerCase();
                  final filteredDiscounts = discounts
                      .where(
                        (d) =>
                            d.name.toLowerCase().contains(query) ||
                            (d.description ?? '').toLowerCase().contains(query),
                      )
                      .toList();

                  if (filteredDiscounts.isEmpty) {
                    return Center(
                      child: Text(
                        'No discounts found',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(
                      AppTheme.spacingMedium,
                    ).copyWith(bottom: 80), // space for fab
                    itemCount: filteredDiscounts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingMedium),
                    itemBuilder: (context, index) {
                      final discount = filteredDiscounts[index];
                      final isExpanded = expandedIndex.value == index;

                      return GestureDetector(
                        onTap: () {
                          if (isExpanded) {
                            expandedIndex.value = null;
                          } else {
                            expandedIndex.value = index;
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
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
                              // Top row: Title and Minimum Price
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      discount.name,
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
                                          discount.minimumPrice,
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

                              // Expanded content
                              if (isExpanded) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                // Discount value row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Discount value',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      discount.discountValue.toInt().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Type row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Discount type',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      discount.discountType,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Status row
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
                                    Text(
                                      discount.isActive ? 'Active' : 'Inactive',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: discount.isActive
                                            ? const Color(0xFF4CAF50)
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButtonWithIcon(
                                        text: 'Edit',
                                        icon: Icons.edit_outlined,
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.addDiscount,
                                            arguments: discount,
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
                                          final confirmed =
                                              await _showDeleteDialog(context);
                                          if (confirmed == true) {
                                            await ref
                                                .read(
                                                  discountsProvider.notifier,
                                                )
                                                .deleteDiscount(discount.id);
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: discountsAsync.whenOrNull(
        data: (_) => FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.addDiscount);
          },
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
