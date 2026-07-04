import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import '../providers/restock_provider.dart';
import '../../data/models/restock_suggestion_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/features/low_stock/presentation/widgets/edit_low_stock_dialog.dart';
import 'package:onepos_admin_app/features/products/presentation/screens/products_screen.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';

// restock pro screen with suggestions list
class RestockProScreen extends HookConsumerWidget {
  const RestockProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    useListenable(searchController);
    final expandedSuggestionId = useState<int?>(null);
    final scrollController = useScrollController();
    final restockAsync = ref.watch(restockSuggestionsProvider);

    // listen for pagination
    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(restockSuggestionsProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    final profileAsync = ref.watch(userProfileProvider);
    final hasShownDialog = useState(false);

    useEffect(() {
      final profile = profileAsync.valueOrNull;
      if (profile != null && !hasShownDialog.value) {
        final plan = profile.plan?.toLowerCase() ?? 'standard';
        if (plan != 'pro' && plan != 'ai') {
          hasShownDialog.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  'Upgrade Required',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                content: Text(
                  'Restock Pro is available on the Pro Plan.\nUpgrade to receive stockout predictions and reorder suggestions powered by AI.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // dismiss dialog
                      Navigator.of(context).pop(); // go back
                    },
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // dismiss dialog
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.subscriptionDetails);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Upgrade',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          });
        }
      }
      return null;
    }, [profileAsync.value, hasShownDialog.value]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Restock Pro',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // search bar
          CustomSearchBar(
            controller: searchController,
            onClear: () => searchController.clear(),
          ),

          // suggestions list
          Expanded(
            child: restockAsync.when(
              data: (restockState) {
                final suggestions = restockState.suggestions;
                final query = searchController.text.toLowerCase();
                final filtered = query.isEmpty
                    ? suggestions
                    : suggestions
                          .where(
                            (s) => s.productName.toLowerCase().contains(query),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No restock suggestions found',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingSmall,
                        ),
                        itemCount:
                            filtered.length +
                            (restockState.hasMorePages ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppTheme.spacingSmall),
                        itemBuilder: (context, index) {
                          if (index == filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = filtered[index];
                          final isExpanded =
                              expandedSuggestionId.value == item.id;

                          return _RestockSuggestionTile(
                            item: item,
                            isExpanded: isExpanded,
                            onToggle: () {
                              expandedSuggestionId.value = isExpanded
                                  ? null
                                  : item.id;
                            },
                            onView: () {
                              final parsedId =
                                  int.tryParse(item.productId) ?? item.id;
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ViewProductDialog(productId: parsedId),
                              );
                            },
                            onEdit: () async {
                              // show loading dialog while fetching product
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) =>
                                    const Center(child: LoadingWidget()),
                              );
                              try {
                                final parsedId =
                                    int.tryParse(item.productId) ?? item.id;
                                final productResponse = await ref.read(
                                  singleProductProvider(parsedId).future,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context); // dismiss loading
                                  if (productResponse.success &&
                                      productResponse.data != null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => EditLowStockDialog(
                                        product: productResponse.data!,
                                      ),
                                    );
                                  } else {
                                    AppSnackbar.showError(
                                      context,
                                      productResponse.message ??
                                          'Product not found',
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context); // dismiss loading
                                  AppSnackbar.showError(
                                    context,
                                    'Failed to fetch product details: $e',
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: LoadingWidget()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load restock suggestions',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(restockSuggestionsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// expandable restock suggestion tile
class _RestockSuggestionTile extends StatelessWidget {
  final RestockSuggestionModel item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _RestockSuggestionTile({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final stockOutDays = item.resolvedStockOutDays;

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
                  // ai icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/ai-icon.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall + 4),

                  // product name
                  Expanded(
                    child: Text(
                      item.productName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  // stockout days
                  Text(
                    stockOutDays != null ? '$stockOutDays Days' : '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: (stockOutDays != null && stockOutDays < 10)
                          ? AppTheme.errorColor
                          : AppTheme.textPrimary,
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
                  // stock row
                  _DetailRow(
                    label: 'Current Stock:',
                    value: item.currentStock.toStringAsFixed(0),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // stock out date row
                  _DetailRow(
                    label: 'Stock-Out Date:',
                    value: item.stockOutDate ?? '—',
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // suggested reorder qty row
                  _DetailRow(
                    label: 'Suggested Reorder Qty:',
                    value: item.suggestedReorderQty.toStringAsFixed(0),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // avg daily sales row
                  _DetailRow(
                    label: 'Avg Daily Sales:',
                    value: item.averageDailySales.toStringAsFixed(1),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // low stock limit row
                  _DetailRow(
                    label: 'Low Stock Limit:',
                    value: item.lowStockLimit.toStringAsFixed(0),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),

                  // price row
                  _DetailRow(
                    label: 'Price:',
                    value: item.price != null
                        ? AmountFormatter.formatCurrency(
                            item.price!,
                            showDecimals: true,
                          )
                        : '—',
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

            // actions
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMedium,
                0,
                AppTheme.spacingMedium,
                AppTheme.spacingMedium,
              ),
              child: SizedBox(
                width: double.infinity,
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
            ),
          ],
        ],
      ),
    );
  }
}

// detail row with label and value
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
