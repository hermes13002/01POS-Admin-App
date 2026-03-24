import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/low_stock/presentation/providers/low_stock_provider.dart';
import 'package:onepos_admin_app/features/low_stock/presentation/widgets/edit_low_stock_dialog.dart';
import 'package:onepos_admin_app/features/products/presentation/screens/products_screen.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

/// low stock screen with expandable product tiles
class LowStockScreen extends HookConsumerWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    useListenable(searchController);
    final expandedProductId = useState<int?>(null);
    final productsAsync = ref.watch(lowStockProductsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Low Stock',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // search bar
          CustomSearchBar(
            controller: searchController,
            onClear: () => searchController.clear(),
          ),

          // products list
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final query = searchController.text.toLowerCase();
                final filtered = query.isEmpty
                    ? products
                    : products
                          .where((p) => p.name.toLowerCase().contains(query))
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No low stock products found',
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
                    final product = filtered[index];
                    final isExpanded = expandedProductId.value == product.id;

                    return _LowStockTile(
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
                              EditLowStockDialog(product: product),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingWidget()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load low stock products',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(lowStockProductsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // simple black circular fab
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

/// expandable low stock product tile
class _LowStockTile extends StatelessWidget {
  final ProductModel product;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _LowStockTile({
    required this.product,
    required this.isExpanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
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
                  _DetailRow(label: 'Stock:', value: '${product.stock}'),
                ],
              ),
            ),

            // divider before action
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall + 4,
              ),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),

            // actions (View and Edit)
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
                        'Restock',
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
