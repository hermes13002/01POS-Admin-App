import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';

class ProfileDetailsScreen extends HookConsumerWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Profile Details',
        centerTitle: false,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('Failed to load profile')),
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileDetailField(label: 'First Name', value: profile.firstname),
                const SizedBox(height: AppTheme.spacingSmall),
                _ProfileDetailField(label: 'Last Name', value: profile.lastname),
                const SizedBox(height: AppTheme.spacingSmall),
                _ProfileDetailField(label: 'Email', value: profile.email),
                const SizedBox(height: AppTheme.spacingSmall),
                _ProfileDetailField(label: 'Phone Number', value: profile.phoneno),
                const SizedBox(height: AppTheme.spacingSmall),
                _ProfileDetailField(label: 'Address', value: profile.address ?? '—'),
                const SizedBox(height: AppTheme.spacingLarge),
                CustomButton(
                  text: 'Edit Profile',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.editProfile),
                  icon: Icons.edit_note_rounded,
                ),
                const SizedBox(height: AppTheme.spacingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// read-only labelled field for profile details section
class _ProfileDetailField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
