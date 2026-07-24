import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/auth/data/models/profile_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

/// store profile screen — company details and admin profile
class StoreProfileScreen extends HookConsumerWidget {
  const StoreProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

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
        child: profileAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load profile',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProfileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (profile) => _ProfileContent(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileContent extends HookConsumerWidget {
  final ProfileModel profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = profile.company;
    final isRequestingDeletion = useState(false);

    // format license expiry
    String expiryLabel = company?.licenseDuration ?? '—';
    if (company != null) {
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
            '${parsed.day} ${months[parsed.month - 1]}, ${parsed.year}';
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top store card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profileDetails),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      // avatar with edit badge
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFF4A4A4A),
                            child: Text(
                              (company?.companyName ?? profile.firstname).isNotEmpty
                                  ? (company?.companyName ?? profile.firstname)[0]
                                        .toUpperCase()
                                  : '',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.all(4),
                          //   decoration: const BoxDecoration(
                          //     color: Color(0xFF4A90E2),
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: const Icon(
                          //     Icons.edit_outlined,
                          //     size: 14,
                          //     color: Colors.white,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company?.companyName ?? profile.firstname,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View store details and\nmanage your information',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1),
                ),
                // plan row
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.subscriptionDetails);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Current Plan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        (profile.plan != null && profile.plan!.isNotEmpty)
                            ? '${profile.plan![0].toUpperCase()}${profile.plan!.substring(1).toLowerCase()}'
                            : 'Standard',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // expiry row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Expiry Date',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      expiryLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Edit Profile Button
          // CustomButton(
          //   text: 'Edit Profile',
          //   onPressed: () =>
          //       Navigator.pushNamed(context, AppRoutes.editProfile),
          //   icon: Icons.edit_note_rounded,
          // ),
          // const SizedBox(height: AppTheme.spacingMedium),

          // settings list
          /*
          _ProfileListItem(
            title: 'Store Name',
            value: company?.companyName,
            onTap: () => Navigator.pushNamed(context, AppRoutes.editStoreName),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Email',
            value: company?.companyEmail,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.editEmailAddress),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Phone Number',
            value: company?.companyNumber,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.editPhoneNumber),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Address',
            value: company?.companyAddress,
            onTap: () => Navigator.pushNamed(context, AppRoutes.editAddress),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          */


          _ProfileListItem(
            title: 'Login Settings',
            icon: Icons.lock_outline,
            iconColor: Colors.blue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.loginSettings),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Currency Settings',
            icon: Icons.monetization_on_outlined,
            iconColor: Colors.green,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.currencySettings),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Receipt Template Settings',
            icon: Icons.receipt_long_outlined,
            iconColor: Colors.purple,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.receiptTemplateSettings),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Low Stock Limit Settings',
            value: company?.lowStockLimit,
            icon: Icons.view_in_ar_outlined,
            iconColor: Colors.orange,
            onTap: () async {
              final controller = TextEditingController(
                text: company?.lowStockLimit ?? '0',
              );
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Set Low Stock Limit',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: CustomTextField(
                    label: 'Limit',
                    controller: controller,
                    keyboardType: TextInputType.number,
                    hint: 'e.g. 10',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );

              if (result != null && result.isNotEmpty && context.mounted) {
                final limit = int.tryParse(result);
                if (limit == null) {
                  AppSnackbar.showError(context, 'Please enter a valid number');
                  return;
                }

                final repository = ref.read(productRepositoryProvider);
                // companyId is used from profile.company.id
                final companyId = profile.company?.id;
                if (companyId == null) {
                  AppSnackbar.showError(context, 'Company ID not found');
                  return;
                }

                final response = await repository.setLowStockLimit(
                  companyId,
                  limit,
                );
                if (response.success && context.mounted) {
                  AppSnackbar.showSuccess(context, response.message!);
                  ref.invalidate(userProfileProvider);
                } else if (context.mounted) {
                  AppSnackbar.showError(
                    context,
                    response.message ?? 'Failed to update limit',
                  );
                }
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Notification Settings',
            icon: Icons.notifications_none_outlined,
            iconColor: Colors.amber,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.notificationSettings),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _ProfileListItem(
            title: 'Sales Download Settings',
            icon: Icons.cloud_download_outlined,
            iconColor: Colors.blue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.salesSettings),
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          CustomButtonWithIcon(
            text: 'Logout',
            icon: Icons.logout_rounded,
            backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
            textColor: AppTheme.errorColor,
            iconColor: AppTheme.errorColor,
            onPressed: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          CustomButtonWithIcon(
            text: 'Request Account Deletion',
            icon: Icons.mail_outline_rounded,
            backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
            textColor: AppTheme.errorColor,
            iconColor: AppTheme.errorColor,
            borderColor: AppTheme.errorColor.withValues(alpha: 0.2),
            isOutlined: true,
            isLoading: isRequestingDeletion.value,
            onPressed: () => _showAccountDeletionConfirmation(
              context,
              ref,
              isRequestingDeletion,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    );
  }

  void _showAccountDeletionConfirmation(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isRequestingDeletion,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Request Account Deletion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will send a deletion request to the organization email. Do you want to continue?',
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
              isRequestingDeletion.value = true;

              final error = await ref
                  .read(authProvider.notifier)
                  .requestAccountDeletion();

              isRequestingDeletion.value = false;

              if (!context.mounted) return;

              if (error != null) {
                AppSnackbar.showError(context, error);
                return;
              }

              AppSnackbar.showSuccess(
                context,
                'Check your inbox, We sent you a mail!',
              );
            },
            child: Text(
              'Send',
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
}

/// tappable list row for settings section
class _ProfileListItem extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;

  const _ProfileListItem({
    required this.title,
    this.value,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
            if (icon != null) ...[
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Row(
              children: [
                if (value != null) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    child: Text(
                      value!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
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
      ),
    );
  }
}


