import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/network/connectivity_provider.dart';
import 'package:onepos_admin_app/core/utils/session_manager.dart';
import 'package:onepos_admin_app/features/auth/presentation/screens/login_screen.dart';
import 'package:onepos_admin_app/presentation/screens/main_navigation_screen.dart';
import 'dart:developer';
import 'package:onepos_admin_app/core/services/local_notification_service.dart';
import 'package:onepos_admin_app/core/services/background_sync_service.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize shared preferences
  await SharedPrefsService().init();

  // check for existing token to determine start screen
  final token = await SecureStorageService().read(AppConstants.keyAccessToken);
  final isLoggedIn = token != null && token.isNotEmpty;

  // initialize background and notification services if user is logged in
  if (isLoggedIn) {
    try {
      final localNotificationService = LocalNotificationService();
      await localNotificationService.init();
      await localNotificationService.requestPermissions();

      final bgSyncService = BackgroundSyncService();
      await bgSyncService.init();
      await bgSyncService.registerPeriodicTasks();

      await _scheduleDefaultInsights(localNotificationService);
    } catch (e) {
      log('Failed to initialize local notifications: $e');
    }
  }

  await GRecaptchaV3.ready(
    '6LfOgo0sAAAAAADQv_G0IXOktWTeGNtRBqEcEQAW',
    showBadge: true,
  );
  log('reCAPTCHA v3 initialized.');

  runApp(ProviderScope(child: MyApp(isLoggedIn: isLoggedIn)));
}

Future<void> _scheduleDefaultInsights(LocalNotificationService service) async {
  // daily snapshot at 8AM
  await service.scheduleDailyNotification(
    id: 1,
    title: 'Daily Business Snapshot',
    body: 'Take a quick look at how your business is doing.',
    hour: 8,
    minute: 0,
  );

  // weekly recap at Mon 9AM
  await service.scheduleWeeklyNotification(
    id: 2,
    title: 'Weekly Recap',
    body: 'See how your week went.',
    day: 1, // monday
    hour: 9,
    minute: 0,
  );

  // end of day sales at 9PM
  await service.scheduleDailyNotification(
    id: 3,
    title: 'End of Day Summary',
    body: 'Great sales today! Check your end-of-day summary.',
    hour: 21,
    minute: 0,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: SessionManager.navigatorKey,
      title: '01POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
      routes: AppRoutes.routes,
      // wrap every screen with the connectivity banner
      builder: (context, child) => ConnectivityBanner(child: child!),
    );
  }
}

/// app-wide offline/online banner — sits above every screen
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool? _previousStatus;
  bool _showRestoredBanner = false;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (isOnline) {
        final justRestored = _previousStatus == false && isOnline;
        _previousStatus = isOnline;

        if (justRestored) {
          _showRestoredBanner = true;
          _dismissTimer?.cancel();
          _dismissTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() => _showRestoredBanner = false);
            }
          });
        }

        // hide restored banner when going offline again
        if (!isOnline) {
          _showRestoredBanner = false;
          _dismissTimer?.cancel();
        }

        return Column(
          children: [
            if (!isOnline)
              _StatusBanner(
                message: 'No internet connection',
                color: AppTheme.errorColor,
                icon: Icons.wifi_off_rounded,
              )
            else if (_showRestoredBanner)
              _StatusBanner(
                message: 'Back online',
                color: AppTheme.successColor,
                icon: Icons.wifi_rounded,
              ),
            Expanded(child: widget.child),
          ],
        );
      },
      loading: () => widget.child,
      error: (_, __) => widget.child,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
