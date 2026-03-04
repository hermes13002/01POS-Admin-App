import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import '../../../products/data/models/product_model.dart';
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
                controller: nameController,
                hint: 'Category name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // category description field
              CustomTextField(
                controller: descriptionController,
                hint: 'Category description',
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
                          ProductCategory(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text.trim(),
                            subCategories: const [],
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
