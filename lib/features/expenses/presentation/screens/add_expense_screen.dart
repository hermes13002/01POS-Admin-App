import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
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
    // using hooks for form state
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final amountController = useTextEditingController();
    final descController = useTextEditingController();

    final selectedCategory = useState<String?>('Technology');
    final selectedType = useState<String?>('Monthly');

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
        child: Padding(
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
                  items: const [
                    DropdownMenuItem(
                      value: 'Technology',
                      child: Text('Technology'),
                    ),
                    DropdownMenuItem(
                      value: 'Personnel',
                      child: Text('Personnel'),
                    ),
                    DropdownMenuItem(
                      value: 'Facility',
                      child: Text('Facility'),
                    ),
                    DropdownMenuItem(
                      value: 'Marketing',
                      child: Text('Marketing'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedCategory.value = val;
                  },
                  validator: (val) =>
                      Validators.validateRequired(val, 'Category'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                AppDropdown<String>(
                  hint: 'Monthly',
                  value: selectedType.value,
                  items: const [
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(
                      value: 'One-time',
                      child: Text('One-time'),
                    ),
                  ],
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

                Spacer(),

                CustomButton(
                  text: 'Add Expense',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // handle save logic
                    }
                  },
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
