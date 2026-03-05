import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';

/// Screen for viewing and managing standard online store profile settings
class StoreProfileScreen extends HookConsumerWidget {
  const StoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Store Profile',
        centerTitle: false,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            children: [
              // Top Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar with Edit Badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(
                            0xFF4A4A4A,
                          ), // Dark grey from design
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A90E2), // Blue badge
                            shape: BoxShape.rectangle,
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tova Superstore',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Plan Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your current plan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Standard',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppTheme.textPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expiry date',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '7th March, 2026',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // Settings List
              _ProfileListItem(
                title: 'Store Name',
                value: 'Tova Superstore',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editStoreName),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(
                title: 'Email',
                value: 'Jo***23@gmail.com',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editEmailAddress),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(
                title: 'Phone Number',
                value: '07012345678',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editPhoneNumber),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(
                title: 'Address',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.editAddress),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(
                title: 'Login Settings',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.loginSettings),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(title: 'Currency Settings'),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(title: 'Receipt Template Settings'),
              const SizedBox(height: AppTheme.spacingMedium),
              _ProfileListItem(title: 'Low Stock Limit Settings'),
              const SizedBox(height: AppTheme.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _ProfileListItem({required this.title, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              if (value != null) ...[
                Text(
                  value!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textPrimary,
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
