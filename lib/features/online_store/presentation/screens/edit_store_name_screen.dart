import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';

/// Screen for editing the store name
class EditStoreNameScreen extends HookConsumerWidget {
  const EditStoreNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final isLoading = useState(false);

    // Initialize controller with current store name
    useEffect(() {
      if (profileAsync.hasValue) {
        nameController.text = profileAsync.value?.company?.companyName ?? '';
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
          'company_name':
              nameController.text, // Field name from ProfileModel/API mapping
        });

        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Store name updated successfully');
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
        title: 'Edit Store Name',
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
                  CustomTextField(
                    label: 'Store Name',
                    hint: 'e.g. My Amazing Store',
                    controller: nameController,
                    validator: (val) =>
                        Validators.validateRequired(val, 'Store Name'),
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
