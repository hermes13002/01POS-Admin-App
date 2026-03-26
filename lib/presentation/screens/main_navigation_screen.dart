import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/tools_screen.dart';
import '../../features/loan/presentation/screens/loan_screen.dart';
import '../../features/online_store/presentation/providers/profile_provider.dart';
import '../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../../features/store/presentation/providers/store_provider.dart';
import '../widgets/welcome_dialog.dart';
import 'dart:developer';

/// Main navigation screen with bottom navigation
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LoanScreen(),
    ToolsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // pre-fetch user profile on app startup so screens have data immediately
    ref.read(userProfileProvider.future).ignore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLogin();
    });
  }

  Future<void> _checkFirstLogin() async {
    final prefs = SharedPrefsService();
    if (!prefs.isFirstLogin) return;

    try {
      final categoriesState = await ref.read(storeCategoriesProvider.future);
      bool hasStructure = false;

      for (final cat in categoriesState.categories) {
        if (cat.subCategories.isNotEmpty) {
          hasStructure = true;
          break;
        }
      }

      if (hasStructure || categoriesState.categories.isNotEmpty) {
        // user already has items, secretly complete the flow
        await prefs.setFirstLoginCompleted();
      } else {
        // show popup
        if (!mounted) return;

        // immediately set to false so it won't show again if they leave and return later
        // wait, we can set it when they click the button, or right when it shows.
        await prefs.setFirstLoginCompleted();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const WelcomeDialog(),
        );
      }
    } catch (e) {
      log('Error checking categories for first login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
