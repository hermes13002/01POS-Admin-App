import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart';
import '../providers/notifications_provider.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final int notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(notificationDetailProvider(notificationId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(title: 'Notification Detail'),
      body: detailAsync.when(
        data: (detail) => _DetailBody(detail: detail),
        loading: () => const LoadingWidget(),
        error: (error, _) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () =>
              ref.refresh(notificationDetailProvider(notificationId)),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final dynamic detail;

  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(detail.createdAt);
    final formattedDate = date != null
        ? DateFormat('MMMM dd, yyyy • hh:mm a').format(date)
        : detail.createdAt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              detail.type.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            detail.title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.grey500),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            detail.message,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          if (detail.user != null) ...[
            Text(
              'Sender Details',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
                border: Border.all(color: AppTheme.grey200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.blue.withValues(alpha: 0.1),
                    child: Text(
                      detail.user!.firstname[0],
                      style: const TextStyle(color: AppTheme.blue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${detail.user!.firstname} ${detail.user!.lastname}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        detail.user!.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
