import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

/// Screen for editing the phone number
class EditPhoneNumberScreen extends HookConsumerWidget {
  const EditPhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final phoneController = useTextEditingController();
    final selectedCountry = useState<String?>('Nigeria (+234)');
    final isLoading = useState(false);

    // Initialize controller with current phone number
    useEffect(() {
      if (profileAsync.hasValue) {
        phoneController.text = profileAsync.value?.company?.companyNumber ?? '';
      }
      return null;
    }, [profileAsync.hasValue]);

    Future<void> handleSave() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      try {
        await ref.read(userProfileProvider.notifier).updateProfile({
          'firstname': profileAsync.value?.firstname,
          'lastname': profileAsync.value?.lastname,
          'phoneno':
              phoneController.text, // Field name from ProfileModel/API mapping
        });

        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Phone number updated successfully');
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(context, e.toString());
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Edit Phone Number',
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
      body: profileAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDropdown<String>(
                    label: 'Country Code',
                    hint: 'Select country code',
                    value: selectedCountry.value,
                    items: const [
                      DropdownMenuItem(
                        value: 'Nigeria (+234)',
                        child: Text('Nigeria (+234)'),
                      ),
                      DropdownMenuItem(
                        value: 'USA (+1)',
                        child: Text('USA (+1)'),
                      ),
                      DropdownMenuItem(
                        value: 'UK (+44)',
                        child: Text('UK (+44)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) selectedCountry.value = val;
                    },
                    validator: (val) =>
                        Validators.validateRequired(val, 'Country code'),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  CustomTextField(
                    label: 'Phone Number',
                    hint: 'e.g. 08012345678',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),

                  const Spacer(),

                  CustomButton(
                    text: 'Save',
                    isLoading: isLoading.value,
                    onPressed: handleSave,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
