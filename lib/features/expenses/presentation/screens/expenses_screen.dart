import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/expenses/data/models/expense_model.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';

/// Screen for viewing and managing expenses
class ExpensesScreen extends HookConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // mock data
    final expenses = useMemoized(
      () => [
        ExpenseModel(
          id: '1',
          title: 'Malware guard softwares',
          category: 'Technology',
          type: 'Monthly',
          amount: 15000,
          categoryColor: const Color(0xFFAC28A6), // purple
        ),
        ExpenseModel(
          id: '2',
          title: 'Overtime Bonus',
          category: 'Personnel',
          type: 'One-time',
          amount: 15000,
          categoryColor: const Color(0xFFFF5252), // red
        ),
        ExpenseModel(
          id: '3',
          title: 'Fuel Expense',
          category: 'Facility',
          type: 'Monthly',
          amount: 15000,
          categoryColor: const Color(0xFF673AB7), // deep purple/indigo
        ),
        ExpenseModel(
          id: '4',
          title: 'Holiday Banners',
          category: 'Marketing',
          type: 'One-time',
          amount: 15000,
          categoryColor: const Color(0xFF4CAF50), // green
        ),
        ExpenseModel(
          id: '5',
          title: 'System Upgrades',
          category: 'Technology',
          type: 'One-time',
          amount: 15000,
          categoryColor: const Color(0xFFAC28A6), // purple
        ),
      ],
    );

    final expandedIndex = useState<int?>(0);
    final searchController = useTextEditingController();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Expenses',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 24),
            onPressed: () {},
          ),
        ],
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
                itemCount: expenses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppTheme.spacingMedium),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
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
                          // Top row: Category
                          Text(
                            expense.category,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: expense.categoryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Second row: Title and Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  expense.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    AmountFormatter.formatCurrency(
                                      expense.amount,
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
                            // Type row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Type',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  expense.type,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Category row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Category',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  expense.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
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
                                    height: 44,
                                    borderColor: AppTheme.blue,
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
                                    height: 44,
                                    borderColor: const Color(0xFFD32F2F),
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
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
