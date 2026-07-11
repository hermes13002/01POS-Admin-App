import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/subscription_billing_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';

class SubscriptionDetailsScreen extends ConsumerWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final billingAsync = ref.watch(subscriptionBillingProvider);

    ref.listen<AsyncValue<SubscriptionBillingState>>(
      subscriptionBillingProvider,
      (previous, next) {
        final prev = previous?.valueOrNull;
        final curr = next.valueOrNull;
        if (curr == null || !context.mounted) return;

        if (curr.errorMessage != null &&
            curr.errorMessage != prev?.errorMessage) {
          AppSnackbar.showError(context, curr.errorMessage!);
        }

        if (curr.successMessage != null &&
            curr.successMessage != prev?.successMessage) {
          AppSnackbar.showSuccess(context, curr.successMessage!);
        }
      },
    );

    String expiryLabel = '—';
    String currentPlan = 'Standard';

    profileAsync.whenData((profile) {
      if (profile.plan != null) currentPlan = profile.plan!;
      final company = profile.company;
      if (company != null && company.licenseDuration.isNotEmpty) {
        try {
          final parsed = DateTime.parse(company.licenseDuration);
          const months = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
          expiryLabel =
              '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
        } catch (_) {
          expiryLabel = company.licenseDuration;
        }
      }
    });

    final billing = billingAsync.valueOrNull;

    String priceLabel(String productId, String fallback) {
      final product = billing?.productsById[productId];
      if (product == null) return fallback;
      return '${product.price}/mo';
    }

    String currentPlanKey = currentPlan.toLowerCase();
    if (currentPlanKey.contains('ai')) {
      currentPlanKey = 'ai';
    } else if (currentPlanKey.contains('pro')) {
      currentPlanKey = 'pro';
    } else {
      currentPlanKey = 'standard';
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Subscription Details',
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Section: Current Plan & Expiry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'YOUR CURRENT PLAN',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBE2FD),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFAECFFB)),
                        ),
                        child: Text(
                          currentPlan,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1B4F93),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'EXPIRY',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        expiryLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 80),

              if (billingAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),

              if (billing != null && !billing.isStoreAvailable)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'In-app purchases are not available on this device.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),

              // Bottom Section: Plans
              Wrap(
                spacing: 12,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _PlanPill(
                    title: 'STANDARD',
                    price: priceLabel(
                      'net.onepos.app.standard_monthly',
                      '₦4,900/mo',
                    ),
                    bgColor: const Color(0xFFE1EEFE),
                    textColor: const Color(0xFF1B4F93),
                    borderColor: const Color(0xFFC5DFFE),
                    isCurrentPlan: currentPlanKey == 'standard',
                    isPending:
                        billing?.pendingProductId ==
                        'net.onepos.app.standard_monthly',
                    onTap: () {
                      debugPrint('[SUBSCRIPTION] STANDARD plan tapped');
                      ref
                          .read(subscriptionBillingProvider.notifier)
                          .purchasePlan('net.onepos.app.standard_monthly');
                    },
                  ),
                  _PlanPill(
                    title: 'PRO',
                    price: priceLabel(
                      'net.onepos.app.pro_monthly',
                      '₦4,900/mo',
                    ),
                    bgColor: const Color(0xFFE2E4FA),
                    textColor: const Color(0xFF28287F),
                    borderColor: const Color(0xFFC7CDFA),
                    isCurrentPlan: currentPlanKey == 'pro',
                    isPending:
                        billing?.pendingProductId ==
                        'net.onepos.app.pro_monthly',
                    onTap: () {
                      debugPrint('[SUBSCRIPTION] PRO plan tapped');
                      ref
                          .read(subscriptionBillingProvider.notifier)
                          .purchasePlan('net.onepos.app.pro_monthly');
                    },
                  ),
                  _PlanPill(
                    title: 'AI',
                    price: priceLabel('net.onepos.app.ai_monthly', '₦5,900/mo'),
                    bgColor: const Color(0xFFF3E7FE),
                    textColor: const Color(0xFF5B1194),
                    borderColor: const Color(0xFFDFBEFD),
                    isCurrentPlan: currentPlanKey == 'ai',
                    isPending:
                        billing?.pendingProductId ==
                        'net.onepos.app.ai_monthly',
                    onTap: () {
                      debugPrint('[SUBSCRIPTION] AI plan tapped');
                      ref
                          .read(subscriptionBillingProvider.notifier)
                          .purchasePlan('net.onepos.app.ai_monthly');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (billing != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: billing.isRestoring
                        ? null
                        : () {
                            debugPrint(
                              '[SUBSCRIPTION] Restore Purchases tapped',
                            );
                            ref
                                .read(subscriptionBillingProvider.notifier)
                                .restorePurchases();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppTheme.textSecondary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: billing.isRestoring
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : Text(
                            'Restore Purchases',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
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
}

class _PlanPill extends StatelessWidget {
  final String title;
  final String price;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final bool isCurrentPlan;
  final bool isPending;
  final VoidCallback onTap;

  const _PlanPill({
    required this.title,
    required this.price,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.isCurrentPlan,
    required this.isPending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[PLAN_PILL] Building: $title, isCurrentPlan: $isCurrentPlan, isPending: $isPending',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: (isCurrentPlan || isPending)
                ? null
                : () {
                    debugPrint('[PLAN_PILL] Button pressed for: $title');
                    onTap();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentPlan
                  ? AppTheme.textSecondary.withValues(alpha: 0.25)
                  : Colors.black,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isCurrentPlan
                  ? AppTheme.textSecondary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: isPending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isCurrentPlan ? 'Current' : 'Purchase',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
