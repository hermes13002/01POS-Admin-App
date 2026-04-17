import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/services/firebase_service.dart';
import 'package:onepos_admin_app/core/services/update_service.dart';
import 'package:onepos_admin_app/features/auth/presentation/screens/login_screen.dart';
import 'package:onepos_admin_app/presentation/screens/main_navigation_screen.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ),
      ),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
        ),
      ),
    );

    useEffect(() {
      animationController.forward();

      // initialize services and determine navigation
      Future<void> initializeApp() async {
        try {
          // start animations
          final minDisplayTime = Future.delayed(const Duration(seconds: 2));

          // perform initialization
          await SharedPrefsService().init();
          await FirebaseService().init();
          await UpdateService().init();

          // check auth status
          final token = await SecureStorageService().read(
            AppConstants.keyAccessToken,
          );
          final isLoggedIn = token != null && token.isNotEmpty;

          // wait for at least 2 seconds for branding
          await minDisplayTime;

          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    isLoggedIn
                    ? const MainNavigationScreen()
                    : const LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          }
        } catch (e) {
          // handle initialization error? maybe show a retry button or just log
          debugPrint('Initialization error: $e');
        }
      }

      initializeApp();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // animated logo
            Transform.scale(
              scale: scaleAnimation,
              child: Opacity(
                opacity: fadeAnimation,
                child: Image.asset(
                  'assets/images/logo/logo-no-bg.png',
                  width: 180,
                  height: 180,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // app name or loading indicator
            Opacity(
              opacity: fadeAnimation,
              child: Column(
                children: [
                  Text(
                    '01POS ADMIN',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empowering Your Business',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            'Version 1.1.0',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.grey400),
          ),
        ),
      ),
    );
  }
}
