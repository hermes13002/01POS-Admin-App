import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import '../providers/store_provider.dart';

/// add new category screen
class AddCategoryScreen extends HookConsumerWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final isLoading = useState(false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(
        title: 'Add New Category',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // category name field
              CustomTextField(
                label: 'Category Name',
                hint: 'e.g. Beverages',
                controller: nameController,
                validator: (val) =>
                    Validators.validateRequired(val, 'Category name'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // category description field
              CustomTextField(
                label: 'Category Description',
                hint: 'Description of items in this category',
                controller: descriptionController,
                maxLines: 5,
              ),

              const Spacer(),

              // add category button
              CustomButton(
                text: 'Add Category',
                isLoading: isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    await ref
                        .read(storeCategoriesProvider.notifier)
                        .addCategory(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                        );
                    isLoading.value = false;
                    if (context.mounted) {
                      Navigator.pop(context);
                      AppSnackbar.showSuccess(
                        context,
                        'Category added successfully',
                      );
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
