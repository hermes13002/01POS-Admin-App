import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/features/products/presentation/widgets/edit_product_dialog.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// products screen with expandable product tiles
class ProductsScreen extends HookConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final expandedProductId = useState<int?>(null);
    final productsAsync = ref.watch(productsProvider);
    final scrollController = useScrollController();

    // listen for search changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // listen for pagination
    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(productsProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Products',
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.more_horiz, color: Colors.black),
          //   onPressed: () {
          //     // TODO: menu options
          //   },
          // ),
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

          // products list
          Expanded(
            child: productsAsync.when(
              data: (productsState) {
                final filtered = searchQuery.value.isEmpty
                    ? productsState.products
                    : productsState.products
                          .where(
                            (p) => p.name.toLowerCase().contains(
                              searchQuery.value.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    itemCount:
                        filtered.length + (productsState.hasMorePages ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTheme.spacingSmall),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final product = filtered[index];
                      final isExpanded = expandedProductId.value == product.id;

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _ProductTile(
                              product: product,
                              isExpanded: isExpanded,
                              onToggle: () {
                                expandedProductId.value = isExpanded
                                    ? null
                                    : product.id;
                              },
                              onView: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ViewProductDialog(productId: product.id),
                                );
                              },
                              onEdit: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      EditProductDialog(product: product),
                                );
                              },
                              onDelete: () {
                                _showDeleteDialog(context, ref, product);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load products',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(productsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // floating action button with expandable speed dial
      floatingActionButton: productsAsync.whenOrNull(
        data: (_) => _AddProductFab(
          onAddProduct: () {
            Navigator.pushNamed(context, '/add-product');
          },
          onAddCategory: () {
            Navigator.pushNamed(context, '/add-category');
          },
          onAddSubCategory: () {
            Navigator.pushNamed(context, '/add-sub-category');
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Delete Product',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
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
            onPressed: () async {
              final response = await ref
                  .read(productsProvider.notifier)
                  .deleteProductItem(product.id);
              if (context.mounted) {
                if (response.success) {
                  AppSnackbar.showSuccess(
                    context,
                    response.message ?? 'Product deleted successfully',
                  );
                } else {
                  AppSnackbar.showError(
                    context,
                    response.message ?? 'Failed to delete product',
                  );
                }
                Navigator.pop(context);
              }
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

/// expandable product tile
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
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
          // header row (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                children: [
                  // product image placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.grey800,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall + 4),

                  // product name
                  Expanded(
                    child: Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  // price
                  Text(
                    AmountFormatter.formatCurrency(
                      product.price,
                      showDecimals: false,
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),

                  // expand/collapse icon
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
                children: [
                  // category row
                  _DetailRow(label: 'Category:', value: product.category ?? ''),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // stock row
                  // _DetailRow(label: 'Stock:', value: '${product.stock}'),
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

            // action buttons
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
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        'View',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
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
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
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
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppTheme.errorColor,
                      ),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
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

/// detail row with label and value
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AmountDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _AmountDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// floating action button with expandable options
class _AddProductFab extends HookWidget {
  final VoidCallback onAddProduct;
  final VoidCallback onAddCategory;
  final VoidCallback onAddSubCategory;

  const _AddProductFab({
    required this.onAddProduct,
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
          // add product option
          _FabOption(
            label: 'Add Product',
            color: const Color(0xFF4CAF50),
            icon: Icons.add_box_outlined,
            onTap: () {
              isExpanded.value = false;
              onAddProduct();
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall + 4),

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
                color: Colors.black.withValues(alpha: 0.08),
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

class ViewProductDialog extends HookConsumerWidget {
  final int productId;

  const ViewProductDialog({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    final singleProductAsync = ref.watch(singleProductProvider(productId));

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () async {
                      await animationController.reverse();
                      if (context.mounted) Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              const Divider(height: 1, color: AppTheme.grey200),

              // Content
              Expanded(
                child: singleProductAsync.when(
                  data: (response) {
                    if (!response.success || response.data == null) {
                      return const Center(
                        child: Text('Failed to load details.'),
                      );
                    }
                    final p = response.data!;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Basic Information'),
                          Container(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.grey200),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(label: 'Name', value: p.name),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Category',
                                  value: p.category ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Sub Category',
                                  value: p.subCategory ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _AmountDetailRow(
                                  label: 'Price',
                                  value: AmountFormatter.formatCurrency(
                                    p.price,
                                    showDecimals: false,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Status',
                                  value: p.isActive == 1
                                      ? 'Active'
                                      : 'Inactive',
                                ),
                              ],
                            ),
                          ),

                          if (p.description != null &&
                              p.description!.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingLarge),
                            _buildSectionTitle('Description'),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                AppTheme.spacingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.grey200),
                              ),
                              child: Text(
                                p.description!,
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppTheme.spacingLarge),
                          _buildSectionTitle('Inventory'),
                          Container(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.grey200),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  label: 'Available Quantity',
                                  value: '${p.stock}',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Quantity Purchased',
                                  value: '${p.quantityPurchased}',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(label: 'SKU', value: p.sku ?? 'N/A'),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Barcode',
                                  value: p.barcode ?? 'N/A',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppTheme.spacingLarge),
                          _buildSectionTitle('Vendor & Dates'),
                          Container(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.grey200),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  label: 'Store',
                                  value: p.store ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Warehouse',
                                  value: p.warehouse ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Supplier',
                                  value: p.supplier ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Mfg Date',
                                  value: p.manufacturingDate ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _DetailRow(
                                  label: 'Exp Date',
                                  value: p.expiryDate ?? 'N/A',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              const Divider(height: 1, color: AppTheme.grey200),
              const SizedBox(height: AppTheme.spacingMedium),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await animationController.reverse();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
