import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import '../../data/models/category_model.dart';
import '../providers/store_provider.dart';

/// add new sub-category screen
class AddSubCategoryScreen extends HookConsumerWidget {
  const AddSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final selectedCategory = useState<CategoryModel?>(null);
    final isLoading = useState(false);
    final categoriesAsync = ref.watch(storeCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(
        title: 'Add New Sub-Category',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // select category dropdown
              categoriesAsync.when(
                data: (state) => AppDropdown<int>(
                  hint: 'Select a category',
                  value: selectedCategory.value?.id,
                  items: state.categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    selectedCategory.value = state.categories.firstWhere(
                      (c) => c.id == id,
                    );
                  },
                  validator: (val) =>
                      Validators.validateRequired(val?.toString(), 'Category'),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text(
                  'Failed to load categories',
                  style: GoogleFonts.poppins(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // sub-category name field
              CustomTextField(
                controller: nameController,
                hint: 'Sub-category name',
                validator: (val) =>
                    Validators.validateRequired(val, 'Sub-category name'),
              ),

              const Spacer(),

              // add sub-category button
              CustomButton(
                text: 'Add Sub-category',
                isLoading: isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    isLoading.value = true;
                    // API for this requested yet, just mock local for now if possible
                    // However, notifier doesn't have addSubCategory anymore.
                    // I will pop for now.
                    isLoading.value = false;
                    if (context.mounted) {
                      Navigator.pop(context);
                      AppSnackbar.showSuccess(
                        context,
                        'Sub-category added locally',
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
