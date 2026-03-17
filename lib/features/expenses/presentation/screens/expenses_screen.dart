import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/features/expenses/data/models/expense_model.dart';
import 'package:onepos_admin_app/features/expenses/presentation/providers/expense_metadata_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

/// Screen for viewing and managing expenses
class ExpensesScreen extends HookConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expensesProvider);
    final expandedIndex = useState<int?>(null);
    final searchController = useTextEditingController();
    final scrollController = useScrollController();

    // handle pagination
    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(expensesProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

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
            onPressed: () => _showCategoryInfo(context),
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
                onChanged: (value) {
                  ref.read(expensesProvider.notifier).search(value);
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Expanded(
              child: expensesState.when(
                data: (state) {
                  if (state.expenses.isEmpty) {
                    return Center(
                      child: Text(
                        'No expenses found',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(expensesProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(
                        AppTheme.spacingMedium,
                      ).copyWith(bottom: 80),
                      itemCount:
                          state.expenses.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppTheme.spacingMedium),
                      itemBuilder: (context, index) {
                        if (index >= state.expenses.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacingSmall),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final expense = state.expenses[index];
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
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: expense.categoryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        expense.name,
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
                                if (isExpanded) ...[
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  _DetailRow(
                                    label: 'Type',
                                    value: expense.type,
                                  ),
                                  const SizedBox(height: 12),
                                  _DetailRow(
                                    label: 'Category',
                                    value: expense.category,
                                  ),
                                  if (expense.description != null &&
                                      expense.description!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _DetailRow(
                                      label: 'Description',
                                      value: expense.description!,
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButtonWithIcon(
                                          text: 'Edit',
                                          icon: Icons.edit_outlined,
                                          onPressed: () =>
                                              _showEditExpenseDialog(
                                                context,
                                                ref,
                                                expense,
                                              ),
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
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Delete Expense',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete "${expense.name}"? This action cannot be undone.',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      'Cancel',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.grey,
                                                          ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      final error = await ref
                                                          .read(
                                                            expensesProvider
                                                                .notifier,
                                                          )
                                                          .deleteExpense(
                                                            expense.id,
                                                          );

                                                      if (context.mounted) {
                                                        if (error != null) {
                                                          AppSnackbar.showError(
                                                            context,
                                                            error,
                                                          );
                                                        } else {
                                                          AppSnackbar.showSuccess(
                                                            context,
                                                            'Expense deleted successfully',
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          isOutlined: true,
                                          textColor: Colors.red,
                                          iconColor: Colors.red,
                                          height: 44,
                                          borderColor: Colors.red,
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load expenses',
                        style: GoogleFonts.poppins(color: AppTheme.errorColor),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(expensesProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
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

  void _showEditExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EditExpenseDialog(expense: expense),
    );
  }

  void _showCategoryInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Expense Category Explanations',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  const _InfoBulletItem(
                    category: 'Personnel',
                    description:
                        'Labor costs including staff salaries and benefits.',
                  ),
                  const _InfoBulletItem(
                    category: 'Facility',
                    description:
                        'Costs related to physical space, including rent, leases, utilities, property taxes, and routine repairs.',
                  ),
                  const _InfoBulletItem(
                    category: 'Marketing',
                    description:
                        'All costs related to generating sales, including advertising, sales commissions, and promotional materials.',
                  ),
                  const _InfoBulletItem(
                    category: 'Technology',
                    description: 'Software subscriptions and IT equipment.',
                  ),
                  const _InfoBulletItem(
                    category: 'Inventory',
                    description: 'Cost of products and raw materials.',
                  ),
                  const _InfoBulletItem(
                    category: 'Finance',
                    description:
                        'Interest paid on business loans and bank fees.',
                  ),
                  const _InfoBulletItem(
                    category: 'Compliance',
                    description:
                        'Legal and professional fees related to regulatory requirements.',
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Color(0xFF4B5563)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditExpenseDialog extends HookConsumerWidget {
  final ExpenseModel expense;

  const _EditExpenseDialog({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: expense.name);
    final amountController = useTextEditingController(
      text: expense.amountValue.toStringAsFixed(0),
    );
    final descController = useTextEditingController(text: expense.description);

    final metadataState = ref.watch(expenseMetadataProvider);
    final selectedCategory = useState<String?>(expense.category);
    final selectedType = useState<String?>(expense.type);
    final isLoading = useState(false);

    Future<void> handleUpdate() async {
      if (!formKey.currentState!.validate()) return;

      if (selectedCategory.value == 'Others') {
        AppSnackbar.showWarning(
          context,
          'The "Others" category is currently unavailable for updates. Please select a different category.',
        );
        return;
      }

      isLoading.value = true;
      final body = {
        "name": nameController.text.trim(),
        "category": selectedCategory.value,
        "type": selectedType.value,
        "amount": double.tryParse(amountController.text) ?? 0,
        "description": descController.text.trim(),
        "expense_date": expense.expenseDate.split('T').first,
      };

      final error = await ref
          .read(expensesProvider.notifier)
          .updateExpense(expense.id, body);
      isLoading.value = false;

      if (context.mounted) {
        if (error == null) {
          AppSnackbar.showSuccess(context, 'Expense updated successfully');
          Navigator.pop(context);
        } else {
          AppSnackbar.showError(context, error);
        }
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Expense',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              CustomTextField(
                hint: 'Name',
                controller: nameController,
                validator: (val) => Validators.validateRequired(val, 'Name'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              AppDropdown<String>(
                hint: 'Category',
                value: selectedCategory.value,
                items: metadataState.maybeWhen(
                  data: (data) => data.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  orElse: () => [],
                ),
                onChanged: (val) {
                  if (val != null) selectedCategory.value = val;
                },
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              AppDropdown<String>(
                hint: 'Type',
                value: selectedType.value,
                items: metadataState.maybeWhen(
                  data: (data) => data.types
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.substring(0, 1).toUpperCase() + t.substring(1),
                          ),
                        ),
                      )
                      .toList(),
                  orElse: () => [],
                ),
                onChanged: (val) {
                  if (val != null) selectedType.value = val;
                },
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              CustomTextField(
                hint: 'Amount',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) =>
                    Validators.validatePositiveNumber(val, 'Amount'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              CustomTextField(
                hint: 'Description',
                controller: descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              CustomButton(
                text: 'Update Expense',
                isLoading: isLoading.value,
                onPressed: () => handleUpdate(),
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBulletItem extends StatelessWidget {
  final String category;
  final String description;

  const _InfoBulletItem({required this.category, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppTheme.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$category: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
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
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
