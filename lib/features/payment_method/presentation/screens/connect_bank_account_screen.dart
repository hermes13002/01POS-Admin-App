import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

/// Screen for connecting a bank account
class ConnectBankAccountScreen extends HookConsumerWidget {
  const ConnectBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final accountController = useTextEditingController();
    final selectedBank = useState<String?>('Access Bank');

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Connect Bank Account',
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
                  hint: 'Account number',
                  controller: accountController,
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Account number'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                AppDropdown<String>(
                  hint: 'Select bank',
                  value: selectedBank.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'Access Bank',
                      child: Text('Access Bank'),
                    ),
                    DropdownMenuItem(value: 'GTBank', child: Text('GTBank')),
                    DropdownMenuItem(
                      value: 'First Bank',
                      child: Text('First Bank'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedBank.value = val;
                  },
                  validator: (val) => Validators.validateRequired(val, 'Bank'),
                ),

                const Spacer(),

                CustomButton(
                  text: 'Validate Account',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
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
