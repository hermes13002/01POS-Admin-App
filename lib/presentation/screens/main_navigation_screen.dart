import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/tools_screen.dart';
import '../../features/loan/presentation/screens/loan_screen.dart';
import '../../features/online_store/presentation/providers/profile_provider.dart';
import '../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/services/background_sync_service.dart';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../providers/tutorial_keys_provider.dart';
import '../../features/reports/presentation/providers/reports_provider.dart';

/// Main navigation screen with bottom navigation
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _hasCheckedTutorial = false;

  List<Widget> get _screens => [
    const HomeScreen(),
    LoanScreen(isActive: _currentIndex == 1),
    const ToolsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // pre-fetch user profile on app startup so screens have data immediately
    ref.read(userProfileProvider.future).ignore();

    // proactively sync reports in the background after login/start
    // this ensures reports are ready (cached) before the user visits the screen
    ref.read(reportsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppServices();
    });
  }

  Future<void> _initAppServices() async {
    try {
      await [Permission.notification, Permission.camera].request();

      final localNotificationService = LocalNotificationService();
      await localNotificationService.init();

      await localNotificationService.requestPermissions();

      final bgSyncService = BackgroundSyncService();
      await bgSyncService.init();
      await bgSyncService.registerPeriodicTasks();

      await _scheduleDefaultInsights(localNotificationService);

      log('App services initialized successfully.');
    } on PlatformException catch (e) {
      log('Platform error during service initialization: ${e.code}');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        String message = 'Notification setup failed: ${e.message}';
        if (e.code == 'exact_alarms_not_permitted') {
          message =
              'Please allow exact alarms in settings for optimal notification delivery.';
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      log('General error during service initialization: $e');
    }
  }

  Future<void> _scheduleDefaultInsights(
    LocalNotificationService service,
  ) async {
    try {
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
    } catch (e) {
      log('Failed to schedule insights: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(tutorialRestartProvider, (previous, next) {
      if (next == true) {
        setState(() {
          _currentIndex = 0;
          _hasCheckedTutorial = false;
        });
        SharedPrefsService().writeBool('hasSeenTutorial', false);
        ref.read(tutorialRestartProvider.notifier).state = false;
      }
    });

    return ShowCaseWidget(
      builder: (builderContext) {
        if (!_hasCheckedTutorial) {
          _hasCheckedTutorial = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!SharedPrefsService().hasSeenTutorial && mounted) {
              final keys = ref.read(tutorialKeysProvider).allKeys;
              ShowCaseWidget.of(builderContext).startShowCase(keys);
              await SharedPrefsService().setTutorialCompleted();
            }
          });
        }

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
      },
    );
  }
}
