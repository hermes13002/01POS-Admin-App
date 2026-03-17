import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import '../providers/customers_provider.dart';

/// add new customer screen
class AddCustomerScreen extends HookConsumerWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final commentController = useTextEditingController();
    final preferenceController = useTextEditingController();
    final isLoading = useState(false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(
        title: 'Add New Customer',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // customer name field
              CustomTextField(
                controller: nameController,
                hint: 'Customer name',
                textCapitalization: TextCapitalization.words,
                validator: (val) =>
                    Validators.validateRequired(val, 'Customer name'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // comment field
              CustomTextField(
                controller: commentController,
                hint: 'Comment',
                validator: (val) => Validators.validateRequired(val, 'Comment'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // preference field
              CustomTextField(
                controller: preferenceController,
                hint: 'Preference',
                validator: (val) =>
                    Validators.validateRequired(val, 'Preference'),
              ),

              const Spacer(),

              // add customer button
              CustomButton(
                text: 'Add Customer',
                isLoading: isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    final error = await ref
                        .read(customersProvider.notifier)
                        .addCustomer({
                          'name': nameController.text.trim(),
                          'comment': commentController.text.trim(),
                          'preference': preferenceController.text.trim(),
                        });
                    isLoading.value = false;

                    if (!context.mounted) return;

                    if (error != null) {
                      AppSnackbar.showError(context, error);
                      return;
                    }

                    AppSnackbar.showSuccess(
                      context,
                      'Customer created successfully',
                    );
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}
