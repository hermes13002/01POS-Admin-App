import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:onepos_admin_app/features/expenses/presentation/providers/expense_metadata_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

/// Screen for adding a new expense
class AddExpenseScreen extends HookConsumerWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final amountController = useTextEditingController();
    final descController = useTextEditingController();

    final selectedCategory = useState<String?>('Technology');
    final selectedType = useState<String?>('monthly');
    final metadataState = ref.watch(expenseMetadataProvider);
    final isLoading = useState(false);

    // handles save logic
    Future<void> handleSave() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      final body = {
        "name": nameController.text.trim(),
        "category": selectedCategory.value,
        "type": selectedType.value,
        "amount": double.tryParse(amountController.text) ?? 0,
        "description": descController.text.trim(),
        "expense_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      final error = await ref
          .read(expensesProvider.notifier)
          .createExpense(body);
      isLoading.value = false;

      if (context.mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense created successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add New Expense',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  validator: (val) =>
                      Validators.validateRequired(val, 'Category'),
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
                  validator: (val) => Validators.validateRequired(val, 'Type'),
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
                  maxLines: 5,
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                CustomButton(
                  text: 'Add Expense',
                  isLoading: isLoading.value,
                  onPressed: () => handleSave(),
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
