import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/providers/payment_method_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

class AddPaymentMethodScreen extends HookConsumerWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final isSubmitting = useState(false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Payment Method',
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
                  hint: 'Payment method name',
                  controller: nameController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Payment method name'),
                ),

                const Spacer(),

                CustomButton(
                  text: 'Add Method',
                  isLoading: isSubmitting.value,
                  onPressed: () async {
                    if (!formKey.currentState!.validate() ||
                        isSubmitting.value) {
                      return;
                    }

                    isSubmitting.value = true;

                    final error = await ref
                        .read(paymentMethodsProvider.notifier)
                        .addPaymentMethod({
                          'method_name': nameController.text.trim(),
                        });

                    isSubmitting.value = false;

                    if (!context.mounted) return;

                    if (error != null) {
                      AppSnackbar.showError(context, error);
                      return;
                    }

                    AppSnackbar.showSuccess(
                      context,
                      'Payment method added successfully',
                    );

                    Navigator.pop(context, true);
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
