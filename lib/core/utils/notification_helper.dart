import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Android settings
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings
  static final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );

  static final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

  static Future<void> initialize() async {
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
      },
    );

    // Request permissions explicitly for iOS (and Android 13+)
    if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print(
        '[NotificationHelper] iOS notification permission granted: $granted',
      );
    } else if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      print(
        '[NotificationHelper] Android notification permission granted: $granted',
      );
    }
  }

  static Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    var androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for scheduled tasks',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    // Initialize time zones if not already done
    tz.initializeTimeZones();
    final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);

    print(
      '[NotificationHelper] Scheduling notification: id=$id, title="$title", body="$body", scheduledDateTime=$scheduledDateTime, tzScheduled=$tzScheduled, now=${DateTime.now()}',
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
