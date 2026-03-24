import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';

class SubscriptionDetailsScreen extends ConsumerWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

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

              // Bottom Section: Plans
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PlanPill(
                    title: 'STANDARD',
                    price: '₦5,000/mo',
                    bgColor: const Color(0xFFE1EEFE),
                    textColor: const Color(0xFF1B4F93),
                    borderColor: const Color(0xFFC5DFFE),
                  ),
                  _PlanPill(
                    title: 'PRO',
                    price: '₦5,000/mo',
                    bgColor: const Color(0xFFE2E4FA),
                    textColor: const Color(0xFF28287F),
                    borderColor: const Color(0xFFC7CDFA),
                  ),
                  _PlanPill(
                    title: 'AI',
                    price: '₦6,000/mo',
                    bgColor: const Color(0xFFF3E7FE),
                    textColor: const Color(0xFF5B1194),
                    borderColor: const Color(0xFFDFBEFD),
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

  const _PlanPill({
    required this.title,
    required this.price,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
