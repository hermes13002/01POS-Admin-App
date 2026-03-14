import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/features/users/presentation/providers/users_provider.dart';

/// Screen for adding a new user
class AddUserScreen extends HookConsumerWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final addressController = useTextEditingController();
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final selectedRole = useState<String?>('Cashier');
    final isPasswordVisible = useState<bool>(false);
    final isConfirmPasswordVisible = useState<bool>(false);
    final isSubmitting = useState<bool>(false);

    final roleIdByName = {
      'Cashier': 2,
      'Manager': 3,
      'Supervisor': 4,
      'Lender': 5,
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add New User',
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
                  hint: 'First name',
                  controller: firstNameController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'First name'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Last name',
                  controller: lastNameController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Last name'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Email address',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                AppDropdown<String>(
                  hint: 'Role',
                  value: selectedRole.value,
                  items: const [
                    DropdownMenuItem(value: 'Cashier', child: Text('Cashier')),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    DropdownMenuItem(
                      value: 'Supervisor',
                      child: Text('Supervisor'),
                    ),
                    DropdownMenuItem(value: 'Lender', child: Text('Lender')),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedRole.value = val;
                  },
                  validator: (val) => Validators.validateRequired(val, 'Role'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Address',
                  controller: addressController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Address'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Phone number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Password',
                  controller: passwordController,
                  obscureText: !isPasswordVisible.value,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      isPasswordVisible.value = !isPasswordVisible.value;
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Confirm password',
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible.value,
                  validator: (val) {
                    if (val != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return Validators.validateRequired(val, 'Confirm password');
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      isConfirmPasswordVisible.value =
                          !isConfirmPasswordVisible.value;
                    },
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                CustomButton(
                  text: 'Add User',
                  isLoading: isSubmitting.value,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final selectedRoleName = selectedRole.value;
                    final roleId = roleIdByName[selectedRoleName] ?? 2;

                    isSubmitting.value = true;

                    final body = <String, dynamic>{
                      'role_id': roleId,
                      'firstname': firstNameController.text.trim(),
                      'lastname': lastNameController.text.trim(),
                      'email': emailController.text.trim(),
                      'address': addressController.text.trim(),
                      'phoneno': phoneController.text.trim(),
                      'password': passwordController.text,
                      'confirmPassword': confirmPasswordController.text,
                    };

                    final error =
                        await ref.read(allUsersProvider.notifier).createUser(body);

                    isSubmitting.value = false;

                    if (!context.mounted) return;

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User created successfully')),
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
