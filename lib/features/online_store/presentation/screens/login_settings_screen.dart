import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

/// Screen for managing login settings
class LoginSettingsScreen extends HookConsumerWidget {
  const LoginSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final obscureCurrent = useState(true);
    final obscureNew = useState(true);
    final obscureConfirm = useState(true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Login Settings',
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppTheme.textPrimary,
          ),
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
                  hint: 'Enter Current Password',
                  controller: currentPasswordController,
                  obscureText: obscureCurrent.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrent.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        obscureCurrent.value = !obscureCurrent.value,
                  ),
                  validator: (val) =>
                      Validators.validateRequired(val, 'Current password'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Enter New Password',
                  controller: newPasswordController,
                  obscureText: obscureNew.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => obscureNew.value = !obscureNew.value,
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Confirm New Password',
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        obscureConfirm.value = !obscureConfirm.value,
                  ),
                  validator: (val) {
                    if (val != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                CustomButton(
                  text: 'Save',
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
