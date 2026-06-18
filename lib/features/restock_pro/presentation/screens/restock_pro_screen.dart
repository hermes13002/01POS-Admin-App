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

// restock pro screen with scrollable suggestions table
class RestockProScreen extends HookConsumerWidget {
  const RestockProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    useListenable(searchController);
    final currentPage = useState(1);
    final restockAsync = ref.watch(
      restockSuggestionsProvider(page: currentPage.value),
    );
    final horizontalScrollController = useScrollController();

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
                      Navigator.of(context).pop(); // go back from screen
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
        title: 'Restock pro',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // search bar
          CustomSearchBar(
            controller: searchController,
            onClear: () => searchController.clear(),
          ),

          // suggestions table
          Expanded(
            child: restockAsync.when(
              data: (response) {
                final suggestions = response.data ?? [];
                final query = searchController.text.toLowerCase();
                final filtered = query.isEmpty
                    ? suggestions
                    : suggestions
                          .where(
                            (s) => s.productName.toLowerCase().contains(query),
                          )
                          .toList();

                final meta = response.meta;
                final totalPages =
                    meta?.totalPages ??
                    (suggestions.length >= 20
                        ? currentPage.value + 1
                        : currentPage.value);
                final hasNextPage = meta != null
                    ? currentPage.value < meta.totalPages
                    : suggestions.length >= 20;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingSmall,
                        ),
                        child: _buildTable(
                          filtered,
                          horizontalScrollController,
                        ),
                      ),
                    ),

                    // pagination footer
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // prev button
                          ElevatedButton(
                            onPressed: currentPage.value > 1
                                ? () => currentPage.value--
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('Prev'),
                          ),

                          // page text
                          Text(
                            'Page ${currentPage.value} of $totalPages',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),

                          // next button
                          ElevatedButton(
                            onPressed: hasNextPage
                                ? () => currentPage.value++
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('Next'),
                          ),
                        ],
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

  // build horizontally scrollable table
  Widget _buildTable(
    List<RestockSuggestionModel> filtered,
    ScrollController scrollController,
  ) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.grey200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // table header
              _buildTableHeader(),
              // table rows or empty state
              if (filtered.isEmpty)
                _buildEmptyState()
              else
                ...filtered.map((item) => _buildTableRow(item)),
            ],
          ),
        ),
      ),
    );
  }

  // build table header row
  Widget _buildTableHeader() {
    final headerStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppTheme.textPrimary,
    );
    return _buildRow(
      productName: Text('PRODUCT NAME', style: headerStyle),
      stock: Text('STOCK', style: headerStyle),
      stockOutDate: Text('STOCK-OUT DATE', style: headerStyle),
      suggestedReorderQty: Text('SUGGESTED REORDER QTY', style: headerStyle),
      price: Text('PRICE', style: headerStyle),
      isHeader: true,
    );
  }

  // build data row
  Widget _buildTableRow(RestockSuggestionModel item) {
    final cellStyle = GoogleFonts.poppins(
      fontSize: 14,
      color: AppTheme.textPrimary,
    );
    return _buildRow(
      productName: Text(
        item.productName,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: cellStyle,
      ),
      stock: Text(item.currentStock.toStringAsFixed(0), style: cellStyle),
      stockOutDate: Text(item.stockOutDate ?? '—', style: cellStyle),
      suggestedReorderQty: Text(
        item.suggestedReorderQty.toStringAsFixed(0),
        style: cellStyle,
      ),
      price: Text(
        item.price != null ? AmountFormatter.formatCurrency(item.price) : '—',
        style: cellStyle,
      ),
      isHeader: false,
    );
  }

  // build helper row layout
  Widget _buildRow({
    required Widget productName,
    required Widget stock,
    required Widget stockOutDate,
    required Widget suggestedReorderQty,
    required Widget price,
    bool isHeader = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHeader ? AppTheme.grey100 : Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.grey200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 180, child: productName),
          SizedBox(width: 90, child: stock),
          SizedBox(width: 140, child: stockOutDate),
          SizedBox(width: 180, child: suggestedReorderQty),
          SizedBox(width: 100, child: price),
        ],
      ),
    );
  }

  // build empty state row
  Widget _buildEmptyState() {
    return Container(
      width: 670,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text(
        'No data found.',
        style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
      ),
    );
  }
}
