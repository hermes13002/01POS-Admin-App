import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';
import '../../data/models/category_model.dart';
import '../providers/store_provider.dart';

/// my store screen - manage store categories
class MyStoreScreen extends HookConsumerWidget {
  const MyStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final expandedIndex = useState<int?>(0);
    final categoriesAsync = ref.watch(storeCategoriesProvider);
    final scrollController = useScrollController();

    // infinite scroll listener
    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(storeCategoriesProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'My Store',
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh, color: Colors.black),
          //   onPressed: () =>
          //       ref.read(storeCategoriesProvider.notifier).refresh(),
          // ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/sub-categories'),
            child: Text(
              'Sub-category',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // search bar
          CustomSearchBar(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            onClear: () => searchQuery.value = '',
          ),

          // categories list
          Expanded(
            child: categoriesAsync.when(
              data: (state) {
                // filter by search
                final filtered = searchQuery.value.isEmpty
                    ? state.categories
                    : state.categories
                          .where(
                            (c) => c.name.toLowerCase().contains(
                              searchQuery.value.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories found',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacingSmall),
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spacingSmall),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final category = filtered[index];
                    final isExpanded = expandedIndex.value == index;

                    return _CategoryCard(
                      category: category,
                      isExpanded: isExpanded,
                      onToggle: () {
                        expandedIndex.value = isExpanded ? null : index;
                      },
                      onView: () {
                        _showCategoryDetailsDialog(context, ref, category);
                      },
                      onEdit: () {
                        _showEditCategoryDialog(context, ref, category);
                      },
                      onDelete: () {
                        _showDeleteConfirmation(context, ref, category);
                      },
                      onStatusToggle: (value) async {
                        final success = await ref
                            .read(storeCategoriesProvider.notifier)
                            .toggleCategoryStatus(category.id, value);

                        if (context.mounted) {
                          if (success) {
                            AppSnackbar.showSuccess(
                              context,
                              'Category ${value ? "activated" : "deactivated"} successfully',
                            );
                          } else {
                            AppSnackbar.showError(
                              context,
                              'Failed to ${value ? "activate" : "deactivate"} category',
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load categories',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(storeCategoriesProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // fab with speed dial
      floatingActionButton: _AddCategoryFab(
        onAddCategory: () {
          Navigator.pushNamed(context, '/add-category');
        },
        onAddSubCategory: () {
          Navigator.pushNamed(context, '/add-sub-category');
        },
      ),
    );
  }

  /// show a long dialog with category and product details
  void _showCategoryDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel summary,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: FutureBuilder<CategoryModel?>(
            future: ref
                .read(storeCategoriesProvider.notifier)
                .getCategoryDetails(summary.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Failed to load details',
                      style: GoogleFonts.poppins(color: AppTheme.errorColor),
                    ),
                  ),
                );
              }

              final category = snapshot.data!;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),

                    // scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(label: 'Name', value: category.name),
                            _DetailRow(
                              label: 'Description',
                              value: (category.shortDescription ?? '').isEmpty
                                  ? 'N/A'
                                  : category.shortDescription!,
                            ),
                            _DetailRow(
                              label: 'Status',
                              value: category.isActive == 1
                                  ? 'Active'
                                  : 'Inactive',
                              valueColor: category.isActive == 1
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),

                            // products list
                            Text(
                              'Products (${category.products.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSmall),
                            if (category.products.isEmpty)
                              Text(
                                'No products in this category',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: category.products.length,
                                separatorBuilder: (_, __) => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Divider(height: 1, thickness: 0.5),
                                ),
                                itemBuilder: (context, index) {
                                  final product = category.products[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // product image or placeholder
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            color: AppTheme.grey200,
                                            child:
                                                product.imageUrl != null &&
                                                    product.imageUrl!.isNotEmpty
                                                ? Image.network(
                                                    product.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                              Icons.image,
                                                            ),
                                                  )
                                                : const Icon(Icons.image),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'SKU: ${product.sku} | Price: ₦${product.price}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                'Stock: ${product.stock}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: product.stock > 0
                                                      ? AppTheme.successColor
                                                      : AppTheme.errorColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// show dialog to edit a category name
  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(
      text: category.shortDescription,
    );
    final isUpdating = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: isUpdating,
        builder: (context, loading, _) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            title: Text(
              'Edit Category',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Category Name',
                  hint: 'Enter name',
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                CustomTextField(
                  controller: descController,
                  label: 'Description',
                  hint: 'Enter description',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                ),
              ),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (nameController.text.isEmpty) return;
                        isUpdating.value = true;

                        await ref
                            .read(storeCategoriesProvider.notifier)
                            .updateCategory(
                              category.id,
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          AppSnackbar.showSuccess(context, 'Category updated');
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: GoogleFonts.poppins(color: AppTheme.blue),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// show dialog to confirm deletion
  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Category',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                final success = await ref
                    .read(storeCategoriesProvider.notifier)
                    .deleteCategory(category.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    AppSnackbar.showSuccess(
                      context,
                      '${category.name} deleted',
                    );
                  } else {
                    AppSnackbar.showError(context, 'Failed to delete category');
                  }
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: AppTheme.errorColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// expandable category card widget
class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onStatusToggle;

  const _CategoryCard({
    required this.category,
    required this.isExpanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          // category header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          category.isActive == 1 ? 'Active' : 'Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: category.isActive == 1
                                ? AppTheme.primaryColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: CustomSwitch(
                      value: category.isActive == 1,
                      onChanged: onStatusToggle,
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // expanded content
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
              ),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMedium,
                AppTheme.spacingSmall + 4,
                AppTheme.spacingMedium,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // sub-category labels
                  if (category.subCategories.isNotEmpty) ...[
                    Text(
                      'Sub-categories',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: category.subCategories.take(3).map((sub) {
                        return Text(
                          sub.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // product labels
                  if (category.products.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Products',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: category.products.take(3).map((prod) {
                        return Text(
                          prod.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (category.subCategories.isEmpty &&
                      category.products.isEmpty)
                    Text(
                      'No sub-categories or products',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),

            // action buttons row
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                children: [
                  // view button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // edit button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: AppTheme.blue,
                        side: const BorderSide(color: AppTheme.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // delete button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// detail row for the dialog
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// fab speed dial option
class _FabOption extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _FabOption({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

/// add category fab
class _AddCategoryFab extends HookWidget {
  final VoidCallback onAddCategory;
  final VoidCallback onAddSubCategory;

  const _AddCategoryFab({
    required this.onAddCategory,
    required this.onAddSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isExpanded.value) ...[
          _FabOption(
            label: 'Add Sub-category',
            color: const Color(0xFFC2185B),
            icon: Icons.description_outlined,
            onTap: () {
              isExpanded.value = false;
              onAddSubCategory();
            },
          ),
          const SizedBox(height: 12),
          _FabOption(
            label: 'Add Category',
            color: const Color(0xFF1E88E5),
            icon: Icons.description_outlined,
            onTap: () {
              isExpanded.value = false;
              onAddCategory();
            },
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: () => isExpanded.value = !isExpanded.value,
          backgroundColor: Colors.black,
          child: AnimatedRotation(
            turns: isExpanded.value ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}
