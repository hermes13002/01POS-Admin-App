import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';

/// manages session state and handles automatic logout on token expiry
class SessionManager {
  SessionManager._();

  /// global navigator key — attach to MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// guards against showing multiple expiry dialogs at once
  static bool _isShowingExpiry = false;

  static Future<void> handleSessionExpired() async {
    if (_isShowingExpiry) return;
    _isShowingExpiry = true;

    // clear all stored credentials immediately
    await SecureStorageService().deleteAll();

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _isShowingExpiry = false;
      return;
    }

    // skip if we are already on the login screen to avoid redundant/confusing dialogs
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.login) {
      _isShowingExpiry = false;
      return;
    }

    if (!context.mounted) {
      _isShowingExpiry = false;
      return;
    }

    // show session expired dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Session Expired',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Your session has expired. Please login again.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );

    // navigate to login and clear the entire navigation stack
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );

    _isShowingExpiry = false;
  }
}
