import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import '../../data/models/customer_model.dart';
import '../providers/customers_provider.dart';

/// add new customer screen
class AddCustomerScreen extends HookConsumerWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final commentController = useTextEditingController();
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
                validator: (val) =>
                    Validators.validateRequired(val, 'Customer name'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // email address field
              CustomTextField(
                controller: emailController,
                hint: 'Email address',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // additional comment field
              CustomTextField(
                controller: commentController,
                hint: 'Additional comment',
                maxLines: 4,
              ),

              const Spacer(),

              // add customer button
              CustomButton(
                text: 'Add Customer',
                isLoading: isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    await ref
                        .read(customersProvider.notifier)
                        .addCustomer(
                          CustomerModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            comment: commentController.text.trim().isEmpty
                                ? null
                                : commentController.text.trim(),
                          ),
                        );
                    isLoading.value = false;
                    if (context.mounted) {
                      Navigator.pop(context);
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
