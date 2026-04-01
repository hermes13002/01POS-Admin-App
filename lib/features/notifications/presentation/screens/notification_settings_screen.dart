import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';
import 'package:onepos_admin_app/core/services/local_notification_service.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';
import 'package:workmanager/workmanager.dart';
import 'package:onepos_admin_app/core/services/background_sync_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _dailySnapshots = true;
  bool _weeklyRecaps = true;
  bool _lowStockAlerts = true;
  bool _endOfDaySummary = true;
  final _prefs = SharedPrefsService();
  final _localAuth = LocalNotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _dailySnapshots = _prefs.readBool('pref_daily_snapshots') ?? true;
      _weeklyRecaps = _prefs.readBool('pref_weekly_recaps') ?? true;
      _lowStockAlerts = _prefs.readBool('pref_low_stock_alerts') ?? true;
      _endOfDaySummary = _prefs.readBool('pref_eod_summary') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    await _prefs.writeBool(key, value);
    setState(() {
      if (key == 'pref_daily_snapshots') _dailySnapshots = value;
      if (key == 'pref_weekly_recaps') _weeklyRecaps = value;
      if (key == 'pref_low_stock_alerts') _lowStockAlerts = value;
      if (key == 'pref_eod_summary') _endOfDaySummary = value;
    });

    if (key == 'pref_daily_snapshots') {
      if (value) {
        await _localAuth.scheduleDailyNotification(
          id: 1,
          title: 'Daily Business Snapshot',
          body: 'Take a quick look at how your business is doing.',
          hour: 8,
          minute: 0,
        );
      } else {
        await _localAuth.flutterLocalNotificationsPlugin.cancel(id: 1);
      }
    } else if (key == 'pref_weekly_recaps') {
      if (value) {
        await _localAuth.scheduleWeeklyNotification(
          id: 2,
          title: 'Weekly Recap',
          body: 'See how your week went.',
          day: 1, // Monday
          hour: 9,
          minute: 0,
        );
      } else {
        await _localAuth.flutterLocalNotificationsPlugin.cancel(id: 2);
      }
    } else if (key == 'pref_eod_summary') {
      if (value) {
        await _localAuth.scheduleDailyNotification(
          id: 3,
          title: 'End of Day Summary',
          body: 'Great sales today! Check your end-of-day summary.',
          hour: 21,
          minute: 0,
        );
      } else {
        await _localAuth.flutterLocalNotificationsPlugin.cancel(id: 3);
      }
    } else if (key == 'pref_low_stock_alerts') {
      if (!value) {
        Workmanager().cancelByUniqueName("low_stock_bg_sync");
      } else {
        Workmanager().registerPeriodicTask(
          "low_stock_bg_sync",
          BackgroundSyncService.checkLowStockTask,
          frequency: const Duration(hours: 12),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Notification Settings',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          _buildSwitchTile(
            title: 'Daily Snapshots',
            subtitle: 'Receive a quick summary of your business at 8 AM',
            value: _dailySnapshots,
            onChanged: (val) => _updateSetting('pref_daily_snapshots', val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Weekly Recaps',
            subtitle: 'Get an overview of your week every Monday at 9 AM',
            value: _weeklyRecaps,
            onChanged: (val) => _updateSetting('pref_weekly_recaps', val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'End of Day Summary',
            subtitle: 'Check your total sales at 9 PM daily',
            value: _endOfDaySummary,
            onChanged: (val) => _updateSetting('pref_eod_summary', val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Low Stock Alerts',
            subtitle: 'Periodic checks to notify you when items run low',
            value: _lowStockAlerts,
            onChanged: (val) => _updateSetting('pref_low_stock_alerts', val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CustomSwitch(
            value: value,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
