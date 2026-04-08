import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  Future<void> init() async {
    try {
      await Firebase.initializeApp();

      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
        await FirebasePerformance.instance.setPerformanceCollectionEnabled(
          true,
        );
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      }
    } catch (e) {
      debugPrint('firebase init failed: $e');
    }
  }

  Future<void> logError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (kIsWeb) return;
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
    );
  }

  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    if (kIsWeb) return;
    await FirebaseCrashlytics.instance.log('$name: $parameters');
  }
}
