import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart';
import 'package:onepos_admin_app/shared/widgets/empty_state_widget.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final scrollController = useScrollController();

    // pagination listener
    useEffect(() {
      void listener() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(notificationsProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Notifications',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: AppTheme.errorColor,
            ),
            onPressed: () => _confirmDeleteAllRead(context, ref),
          ),
        ],
      ),
      body: notificationsState.when(
        data: (state) {
          if (state.notifications.isEmpty) {
            return const EmptyStateWidget(
              message: 'No notifications found',
              icon: Icons.notifications_none_outlined,
              title: '',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            color: AppTheme.blue,
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              itemCount:
                  state.notifications.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = state.notifications[index];
                return Dismissible(
                  key: Key('notification_${item.id}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) =>
                      _confirmDeleteSingle(context, item),
                  onDismissed: (_) async {
                    final error = await ref
                        .read(notificationsProvider.notifier)
                        .deleteNotification(item.id);
                    if (context.mounted) {
                      if (error != null) {
                        AppSnackbar.showError(context, error);
                      } else {
                        AppSnackbar.showSuccess(
                          context,
                          'Notification deleted successfully',
                        );
                      }
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusMedium,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorColor,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(item.id);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.notificationDetail,
                        arguments: item.notificationId,
                      );
                    },
                    child: _NotificationCard(item: item),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(notificationsProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAllRead(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete all read?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will permanently delete all notifications you have read.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final error = await ref
          .read(notificationsProvider.notifier)
          .deleteAllReadNotifications();
      if (context.mounted) {
        if (error != null) {
          AppSnackbar.showError(context, error);
        } else {
          AppSnackbar.showSuccess(context, 'All read notifications deleted');
        }
      }
    }
  }

  Future<bool?> _confirmDeleteSingle(BuildContext context, dynamic item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete notification?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this notification?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final notification = item.notification;
    if (notification == null) return const SizedBox.shrink();

    final date = DateTime.tryParse(notification.createdAt);
    final formattedDate = date != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(date)
        : notification.createdAt;

    // determine icon and color based on type
    IconData iconData = Icons.notifications_outlined;
    Color iconColor = AppTheme.blue;

    final type = notification.type.toLowerCase();
    if (type.contains('order')) {
      iconData = Icons.shopping_bag_outlined;
      iconColor = AppTheme.successColor;
    } else if (type.contains('stock')) {
      iconData = Icons.inventory_2_outlined;
      iconColor = AppTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (item.read == 0)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
