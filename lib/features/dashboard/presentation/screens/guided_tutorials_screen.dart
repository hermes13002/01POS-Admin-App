import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/presentation/providers/guided_tour_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';

class GuidedTutorialsScreen extends HookConsumerWidget {
  const GuidedTutorialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(
        title: 'Guided Tutorials',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn how to use 01POS',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
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
