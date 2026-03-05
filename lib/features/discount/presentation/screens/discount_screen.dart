import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/discount/data/models/discount_model.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';

/// Screen for viewing and managing discounts
class DiscountScreen extends HookConsumerWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // mock data
    final discounts = useMemoized(
      () => [
        DiscountModel(
          id: '1',
          title: 'Holiday',
          minPrice: 15000,
          discountType: 'Fixed',
          discountValue: 15,
          isActive: true, // true uses green Active
        ),
        DiscountModel(
          id: '2',
          title: 'Anniversary Discount',
          minPrice: 15000,
          discountType: 'Percentage',
          discountValue: 10,
          isActive: false,
        ),
        DiscountModel(
          id: '3',
          title: 'Buy 2 Get 1 Free',
          minPrice: 15000,
          discountType: 'Item Based',
          discountValue: 1,
          isActive: false,
        ),
        DiscountModel(
          id: '4',
          title: 'Halloween Sale',
          minPrice: 15000,
          discountType: 'Percentage',
          discountValue: 20,
          isActive: false,
        ),
        DiscountModel(
          id: '5',
          title: 'Black Friday Deals',
          minPrice: 15000,
          discountType: 'Fixed',
          discountValue: 5000,
          isActive: false,
        ),
      ],
    );

    final expandedIndex = useState<int?>(0);
    final searchController = useTextEditingController();

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
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(
                  AppTheme.spacingMedium,
                ).copyWith(bottom: 80), // space for fab
                itemCount: discounts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppTheme.spacingMedium),
                itemBuilder: (context, index) {
                  final discount = discounts[index];
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
                            color: Colors.black.withOpacity(0.04),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  discount.title,
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
                                      discount.minPrice,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    onPressed: () {},
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
                                    onPressed: () {},
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addDiscount);
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
