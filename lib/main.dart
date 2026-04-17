import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/network/connectivity_provider.dart';
import 'package:onepos_admin_app/core/utils/session_manager.dart';
import 'package:onepos_admin_app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // enable edge-to-edge support for Android 15+
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      if (kReleaseMode) {
        debugPrint = (String? message, {int? wrapWidth}) {};
      }

      runApp(const ProviderScope(child: MyApp()));
    },
    // ... rest of zoned settings
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (!kReleaseMode) {
          parent.print(zone, line);
        }
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: SessionManager.navigatorKey,
      title: '01POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: AppRoutes.routes,
      // wrap every screen with the connectivity banner
      builder: (context, child) => ConnectivityBanner(child: child!),
    );
  }
}

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
