import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import '../../../products/data/models/product_model.dart';
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

    // listen for search changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'My Store',
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              // TODO: implement more options menu
            },
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
              data: (categories) {
                // filter by search
                final filtered = searchQuery.value.isEmpty
                    ? categories
                    : categories
                        .where((c) => c.name
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase()))
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppTheme.spacingSmall),
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final isExpanded = expandedIndex.value == index;

                    return _CategoryCard(
                      category: category,
                      isExpanded: isExpanded,
                      onToggle: () {
                        expandedIndex.value = isExpanded ? null : index;
                      },
                      onView: () {
                        // TODO: navigate to category detail
                      },
                      onEdit: () {
                        _showEditCategoryDialog(context, ref, category);
                      },
                      onDelete: () {
                        _showDeleteConfirmation(context, ref, category);
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
                      onPressed: () => ref.invalidate(storeCategoriesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // fab with speed dial (same pattern as products screen)
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

  /// show dialog to edit a category name
  void _showEditCategoryDialog(
      BuildContext context, WidgetRef ref, ProductCategory category) {
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Edit Category',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Category name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
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
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(storeCategoriesProvider.notifier).updateCategory(
                      ProductCategory(
                        id: category.id,
                        name: nameController.text.trim(),
                        subCategories: category.subCategories,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// show delete confirmation dialog
  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ProductCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Delete Category',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: GoogleFonts.poppins(fontSize: 14),
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
            onPressed: () {
              ref
                  .read(storeCategoriesProvider.notifier)
                  .deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// expandable category card widget
class _CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.isExpanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
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
                    child: Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
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
                  horizontal: AppTheme.spacingMedium),
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
                  if (category.subCategories.isNotEmpty)
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: category.subCategories.map((sub) {
                        return Text(
                          sub,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // divider before actions
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall + 4,
              ),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),

            // action buttons row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMedium,
                0,
                AppTheme.spacingMedium,
                AppTheme.spacingMedium,
              ),
              child: Row(
                children: [
                  // view button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onView,
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        'View',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // edit button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF4CAF50),
                      ),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFC8E6C9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // delete button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
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

/// fab with speed dial for adding category/sub-category
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
        // expanded options
        if (isExpanded.value) ...[
          // add sub-category option
          _FabOption(
            label: 'Add Sub-category',
            color: const Color(0xFFC2185B),
            icon: Icons.description_outlined,
            onTap: () {
              isExpanded.value = false;
              onAddSubCategory();
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall + 4),

          // add category option
          _FabOption(
            label: 'Add Category',
            color: const Color(0xFF1E88E5),
            icon: Icons.description_outlined,
            onTap: () {
              isExpanded.value = false;
              onAddCategory();
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall + 4),
        ],

        // main fab
        FloatingActionButton(
          onPressed: () => isExpanded.value = !isExpanded.value,
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
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

/// individual fab option button
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
        // label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall + 4),

        // icon button
        SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: color,
            elevation: 2,
            shape: const CircleBorder(),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}
