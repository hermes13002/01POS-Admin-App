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

/// add/edit sub-category screen
class AddSubCategoryScreen extends HookConsumerWidget {
  final SubCategoryModel? subCategory;

  const AddSubCategoryScreen({super.key, this.subCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = subCategory != null;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(
      text: subCategory?.name ?? '',
    );
    final categoriesAsync = ref.watch(storeCategoriesProvider);
    final selectedCategory = useState<CategoryModel?>(null);
    final isLoading = useState(false);

    // set initial category if editing
    useEffect(() {
      if (isEditing && subCategory!.category != null) {
        selectedCategory.value = subCategory!.category;
      }
      return null;
    }, [isEditing]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: isEditing ? 'Edit Sub-Category' : 'Add New Sub-Category',
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
                error: (error, _) => Text(
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

              // action button
              CustomButton(
                text: isEditing ? 'Update Sub-category' : 'Add Sub-category',
                isLoading: isLoading.value,
                onPressed: () async {
                  if (formKey.currentState!.validate() &&
                      selectedCategory.value != null) {
                    isLoading.value = true;

                    final notifier = ref.read(
                      storeSubCategoriesProvider.notifier,
                    );
                    final success = isEditing
                        ? await notifier.updateSubCategory(
                            subCategory!.id,
                            categoryId: selectedCategory.value!.id,
                            name: nameController.text.trim(),
                          )
                        : await notifier.addSubCategory(
                            categoryId: selectedCategory.value!.id,
                            name: nameController.text.trim(),
                          );

                    isLoading.value = false;

                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                        AppSnackbar.showSuccess(
                          context,
                          isEditing
                              ? 'Sub-category updated successfully'
                              : 'Sub-category added successfully',
                        );
                      } else {
                        AppSnackbar.showError(
                          context,
                          isEditing
                              ? 'Failed to update sub-category'
                              : 'Failed to add sub-category',
                        );
                      }
                    }
                  } else if (selectedCategory.value == null) {
                    AppSnackbar.showWarning(
                      context,
                      'Please select a category',
                    );
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
