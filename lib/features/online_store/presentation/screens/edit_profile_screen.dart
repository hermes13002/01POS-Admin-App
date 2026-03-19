import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/features/auth/data/models/profile_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';

/// screen for editing all profile fields in one place
class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final oldPasswordFuture = useMemoized(
      () => SecureStorageService().read('user_password'),
    );
    final oldPasswordSnapshot = useFuture(oldPasswordFuture);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        centerTitle: false,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (oldPasswordSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _EditProfileForm(
            profile: profile,
            initialOldPassword: oldPasswordSnapshot.data ?? '',
          );
        },
      ),
    );
  }
}

class _EditProfileForm extends HookConsumerWidget {
  final ProfileModel profile;
  final String initialOldPassword;

  const _EditProfileForm({
    required this.profile,
    required this.initialOldPassword,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final firstNameController = useTextEditingController(
      text: profile.firstname,
    );
    final lastNameController = useTextEditingController(text: profile.lastname);
    final emailController = useTextEditingController(text: profile.email);
    final phoneController = useTextEditingController(text: profile.phoneno);
    final addressController = useTextEditingController(
      text: profile.address ?? '',
    );
    final oldPasswordController = useTextEditingController(
      text: initialOldPassword,
    );
    final newPasswordController = useTextEditingController();

    final isSubmitting = useState(false);
    final obscureOldPassword = useState(true);
    final obscureNewPassword = useState(true);

    Future<void> handleSave() async {
      if (!formKey.currentState!.validate()) return;

      isSubmitting.value = true;
      try {
        await ref.read(userProfileProvider.notifier).updateProfile({
          'firstname': firstNameController.text.trim(),
          'lastname': lastNameController.text.trim(),
          'email': emailController.text.trim(),
          'phoneno': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'old_password': oldPasswordController.text,
          'new_password': newPasswordController.text.isEmpty
              ? null
              : newPasswordController.text,
        });

        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Profile updated successfully');
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(context, e.toString());
        }
      } finally {
        if (context.mounted) {
          isSubmitting.value = false;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'First Name',
              controller: firstNameController,
              validator: (val) =>
                  Validators.validateRequired(val, 'First Name'),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'Last Name',
              controller: lastNameController,
              validator: (val) => Validators.validateRequired(val, 'Last Name'),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'Email Address',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'Phone Number',
              controller: phoneController,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'Address',
              controller: addressController,
              maxLines: 2,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Security',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'Old Password',
              controller: oldPasswordController,
              obscureText: obscureOldPassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureOldPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () =>
                    obscureOldPassword.value = !obscureOldPassword.value,
              ),
              validator: (val) =>
                  Validators.validateRequired(val, 'Old Password'),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            CustomTextField(
              label: 'New Password',
              controller: newPasswordController,
              obscureText: obscureNewPassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureNewPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () =>
                    obscureNewPassword.value = !obscureNewPassword.value,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Leave blank to keep current password',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            CustomButton(
              text: 'Save Changes',
              isLoading: isSubmitting.value,
              onPressed: handleSave,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
          ],
        ),
      ),
    );
  }
}
