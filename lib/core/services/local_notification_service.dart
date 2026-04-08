import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import 'package:onepos_admin_app/core/services/firebase_service.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log('Notification clicked with payload: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    await init();

    // Notifications permission
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();

    // Exact alarms permission (Android 13+)
    try {
      await androidImplementation?.requestExactAlarmsPermission();
    } catch (e) {
      log('Exact alarms permission request failed: $e');
      // this might fail on older versions or if already granted/denied
      // where the method isn't supported, but zonedSchedule will
      // catch it later if it's truly required and missing.
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<bool> hasPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final notificationsGranted =
        await androidImplementation?.areNotificationsEnabled() ?? false;
    // for exact alarms, the plugin doesn't have a direct check for "is granted"
    // but the requestExactAlarmsPermission won't throw if we just call it.

    return notificationsGranted;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'insights_channel',
          'Insights Notifications',
          channelDescription: 'Notifications for business insights and reports',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          enableVibration: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );

    await FirebaseService().logEvent('notification_shown', {
      'id': id,
      'title': title,
    });
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await init();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'insights_channel_daily',
          'Daily Insights',
          channelDescription: 'Daily business insights and reports',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await FirebaseService().logEvent('notification_scheduled_daily', {
      'id': id,
      'time': '$hour:$minute',
    });
  }

  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int day,
    required int hour,
    required int minute,
  }) async {
    await init();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfWeekly(day, hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'insights_channel_weekly',
          'Weekly Insights',
          channelDescription: 'Weekly business insights and reports',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    await FirebaseService().logEvent('notification_scheduled_weekly', {
      'id': id,
      'day': day,
      'time': '$hour:$minute',
    });
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekly(int day, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
