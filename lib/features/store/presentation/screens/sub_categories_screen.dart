import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import '../../data/models/category_model.dart';
import '../providers/store_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';

class SubCategoriesScreen extends HookConsumerWidget {
  const SubCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final subCategoriesAsync = ref.watch(storeSubCategoriesProvider);
    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(storeSubCategoriesProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Sub-Categories',
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh, color: Colors.black),
          //   onPressed: () =>
          //       ref.read(storeSubCategoriesProvider.notifier).refresh(),
          // ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            onClear: () => searchQuery.value = '',
          ),
          Expanded(
            child: subCategoriesAsync.when(
              data: (state) {
                final filtered = searchQuery.value.isEmpty
                    ? state.subCategories
                    : state.subCategories
                          .where(
                            (s) => s.name.toLowerCase().contains(
                              searchQuery.value.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No sub-categories found',
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

                    final subCategory = filtered[index];
                    return _SubCategoryCard(
                      subCategory: subCategory,
                      onView: () => _showSubCategoryDetailsDialog(
                        context,
                        ref,
                        subCategory,
                      ),
                      onEdit: () => Navigator.pushNamed(
                        context,
                        '/add-sub-category',
                        arguments: subCategory,
                      ),
                      onToggleStatus: (value) async {
                        final success = await ref
                            .read(storeSubCategoriesProvider.notifier)
                            .toggleSubCategoryStatus(subCategory.id, value);
                        if (context.mounted && !success) {
                          AppSnackbar.showError(
                            context,
                            'Failed to update status',
                          );
                        }
                      },
                      onDelete: () =>
                          _showDeleteConfirmation(context, ref, subCategory),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load sub-categories'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(storeSubCategoriesProvider.notifier)
                          .refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-sub-category'),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSubCategoryDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    SubCategoryModel summary,
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
          child: FutureBuilder<SubCategoryModel?>(
            future: ref
                .read(storeSubCategoriesProvider.notifier)
                .getSubCategoryDetails(summary.id),
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

              final subCategory = snapshot.data!;

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
                          'Sub-Category Details',
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
                            _DetailRow(label: 'Name', value: subCategory.name),
                            if (subCategory.category != null)
                              _DetailRow(
                                label: 'Parent Category',
                                value: subCategory.category!.name,
                              ),
                            _DetailRow(
                              label: 'Status',
                              value: subCategory.isActive == 1
                                  ? 'Active'
                                  : 'Inactive',
                              valueColor: subCategory.isActive == 1
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),

                            // products list
                            Text(
                              'Products (${subCategory.products.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSmall),
                            if (subCategory.products.isEmpty)
                              Text(
                                'No products in this sub-category',
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
                                itemCount: subCategory.products.length,
                                separatorBuilder: (_, __) => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Divider(height: 1, thickness: 0.5),
                                ),
                                itemBuilder: (context, index) {
                                  final product = subCategory.products[index];
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

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    SubCategoryModel sub,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sub-Category'),
        content: Text('Are you sure you want to delete "${sub.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(storeSubCategoriesProvider.notifier)
                  .deleteSubCategory(sub.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  AppSnackbar.showSuccess(context, 'Sub-category deleted');
                } else {
                  AppSnackbar.showError(context, 'Failed to delete');
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryCard extends StatelessWidget {
  final SubCategoryModel subCategory;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleStatus;

  const _SubCategoryCard({
    required this.subCategory,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subCategory.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subCategory.category != null)
                  Text(
                    'Category: ${subCategory.category!.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          CustomSwitch(
            value: subCategory.isActive == 1,
            onChanged: onToggleStatus,
            activeColor: AppTheme.successColor,
          ),
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: AppTheme.primaryColor,
            ),
            onPressed: onView,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

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
