import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/auth/presentation/screens/login_screen.dart';
import 'package:onepos_admin_app/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize shared preferences
  await SharedPrefsService().init();

  // check for existing token to determine start screen
  final token = await SecureStorageService().read(AppConstants.keyAccessToken);
  final isLoggedIn = token != null && token.isNotEmpty;

  runApp(ProviderScope(child: MyApp(isLoggedIn: isLoggedIn)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnePOS Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
      routes: AppRoutes.routes,
    );
  }
}
