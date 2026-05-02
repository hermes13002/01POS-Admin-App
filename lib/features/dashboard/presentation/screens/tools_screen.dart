import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/data/models/tool_model.dart';
import 'package:onepos_admin_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:onepos_admin_app/presentation/providers/quick_actions_provider.dart';
import 'package:onepos_admin_app/presentation/providers/tutorial_keys_provider.dart';
import 'package:onepos_admin_app/presentation/providers/guided_tour_provider.dart';

/// Tools screen showing all available tools
class ToolsScreen extends HookConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActions = ref.watch(quickActionsProvider);
    final searchQuery = useState('');

    final filteredTools = useMemoized(() {
      final availableTools = AppTools.allTools;

      if (searchQuery.value.isEmpty) {
        return availableTools;
      }
      return availableTools
          .where(
            (tool) => tool.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }, [searchQuery.value, quickActions]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // header with title
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.spacingMedium,
                right: AppTheme.spacingMedium,
                top: AppTheme.spacingMedium,
                bottom: AppTheme.spacingXSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tools',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXSmall,
              ),
              child: CustomSearchBar(
                hintText: 'Search',
                onChanged: (value) => searchQuery.value = value,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            // tools grid and guided tours
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filteredTools.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No tools found',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      AnimationLimiter(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: AppTheme.spacingMedium,
                                mainAxisSpacing: AppTheme.spacingMedium,
                                childAspectRatio: 1,
                              ),
                          itemCount: filteredTools.length,
                          itemBuilder: (context, index) {
                            final tool = filteredTools[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 3,
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildToolItem(context, ref, tool),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Guided Tours Section (only visible when not searching)
                    if (searchQuery.value.isEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        'Guided Tutorials',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: AppTheme.spacingMedium,
                        mainAxisSpacing: AppTheme.spacingMedium,
                        childAspectRatio: 1,
                        children: [
                          _buildGuidedTourItem(
                            context: context,
                            ref: ref,
                            title: 'Add Product',
                            icon: Icons.add_box_outlined,
                            tourType: TourType.addProduct,
                            route: AppRoutes.products,
                          ),
                          _buildGuidedTourItem(
                            context: context,
                            ref: ref,
                            title: 'Add Payment',
                            icon: Icons.payments_outlined,
                            tourType: TourType.addPayment,
                            route: AppRoutes.paymentMethod,
                          ),
                          _buildGuidedTourItem(
                            context: context,
                            ref: ref,
                            title: 'Add Cashier',
                            icon: Icons.person_add_outlined,
                            tourType: TourType.addCashier,
                            route: AppRoutes.users,
                          ),
                          _buildGuidedTourItem(
                            context: context,
                            ref: ref,
                            title: 'Check Sales',
                            icon: Icons.point_of_sale_outlined,
                            tourType: TourType.checkSales,
                            route: AppRoutes.sales,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// show logout confirmation dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).logout();
              navigator.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(BuildContext context, WidgetRef ref, ToolModel tool) {
    return InkWell(
      onTap: () {
        if (tool.id == 'tutorial') {
          // signal to restart tutorial
          ref.read(tutorialRestartProvider.notifier).state = true;
          // navigate back to home where showcase is hosted
          // index 0 is home in MainNavigationScreen
          // the parent context handles the index change if we were using a provider for it
          // but here we might need to find a way to change the index.
          // since MainNavigationScreen watches tutorialRestartProvider, we can handle index change there.
        } else {
          // navigate to tool screen
          Navigator.pushNamed(context, tool.route);
        }
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 4),
            // icon with light blue background
            Expanded(
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(83, 157, 243, 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    tool.icon,
                    size: 22,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 4),
            // label
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    tool.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidedTourItem({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required TourType tourType,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        // Start tour and navigate
        ref.read(guidedTourProvider.notifier).startTour(tourType);
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, size: 22, color: AppTheme.primaryColor),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
