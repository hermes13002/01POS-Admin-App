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
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
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
              
          if (parsed.isBefore(DateTime.now())) {
            currentPlan = 'Expired';
          }
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

    final standardButtonText = currentPlanKey == 'pro' ? 'Purchase Standard' : 'Renew Standard';
    final proButtonText = currentPlanKey == 'pro' ? 'Renew Pro' : 'Upgrade to Pro';

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
                          color: currentPlanKey == 'pro'
                              ? const Color(0xFFE2E4FA)
                              : currentPlanKey == 'expired'
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFE1EEFE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: currentPlanKey == 'pro'
                                ? const Color(0xFFC7CDFA)
                                : currentPlanKey == 'expired'
                                    ? const Color(0xFFFFCDD2)
                                    : const Color(0xFFC5DFFE),
                          ),
                        ),
                        child: Text(
                          currentPlan,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: currentPlanKey == 'pro'
                                ? const Color(0xFF28287F)
                                : currentPlanKey == 'expired'
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF1B4F93),
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
              Column(
                children: [
                  _PlanPill(
                    title: 'STANDARD',
                    price: priceLabel(
                      'net.onepos.app.standard_monthly',
                      '₦5,000/mo',
                    ),
                    bgColor: const Color(0xFFE1EEFE),
                    textColor: const Color(0xFF1B4F93),
                    borderColor: const Color(0xFFC5DFFE),
                    isCurrentPlan: currentPlanKey == 'standard',
                    isPending:
                        billing?.pendingProductId ==
                        'net.onepos.app.standard_monthly',
                    buttonText: standardButtonText,
                    buttonColor: const Color(0xFF22A353),
                    onTap: () {
                      debugPrint('[SUBSCRIPTION] STANDARD plan tapped');
                      ref
                          .read(subscriptionBillingProvider.notifier)
                          .purchasePlan('net.onepos.app.standard_monthly');
                    },
                  ),
                  const SizedBox(height: 32),
                  _PlanPill(
                    title: 'PRO',
                    price: priceLabel(
                      'net.oneposadmin.app.pro_1month',
                      '₦10,000/mo',
                    ),
                    bgColor: const Color(0xFFE2E4FA),
                    textColor: const Color(0xFF28287F),
                    borderColor: const Color(0xFFC7CDFA),
                    isCurrentPlan: currentPlanKey == 'pro',
                    isPending:
                        billing?.pendingProductId ==
                        'net.oneposadmin.app.pro_1month',
                    buttonText: proButtonText,
                    buttonColor: const Color(0xFF1D4ED8),
                    onTap: () {
                      debugPrint('[SUBSCRIPTION] PRO plan tapped');
                      ref
                          .read(subscriptionBillingProvider.notifier)
                          .purchasePlan('net.oneposadmin.app.pro_1month');
                    },
                  ),
                  const SizedBox(height: 32),
                  /*
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
                    buttonText: 'Activate AI',
                    buttonColor: const Color(0xFF1D4ED8),
                    onTap: () {
                      debugPrint('[SUBSCRIPTION] AI plan tapped');
                      ref
                          .read(subscriptionBillingProvider.notifier)
                          .purchasePlan('net.onepos.app.ai_monthly');
                    },
                  ),
                  */
                ],
              ),

              const SizedBox(height: 28),

              if (billing != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
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
                            color:
                                AppTheme.textSecondary.withValues(alpha: 0.45),
                          ),
                        ),
                        child: billing.isRestoring
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.2),
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
                    const SizedBox(width: 16),
                    Tooltip(
                      message:
                          'Tap this if you changed devices, reinstalled the app, or if a payment was successful but your plan did not update.',
                      triggerMode: TooltipTriggerMode.tap,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(12),
                      showDuration: const Duration(seconds: 4),
                      child: Icon(
                        Icons.info_outline,
                        size: 24,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
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
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onTap;

  const _PlanPill({
    required this.title,
    required this.price,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.isCurrentPlan,
    required this.isPending,
    required this.buttonText,
    required this.buttonColor,
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isPending
              ? null
              : () {
                  debugPrint('[PLAN_PILL] Button pressed for: $title');
                  onTap();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: buttonColor.withValues(alpha: 0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            elevation: 0,
          ),
          child: isPending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
