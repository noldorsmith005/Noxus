import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  final NotificationsPlugin = FlutterLocalNotificationsPlugin();
  final rand = Random();

  bool initialized = false;
  List<int> IDS = [];

  Future<void> clearCache() async {
    IDS.clear();
    NotificationsPlugin.cancelAll();
  }

  Future<void> initNotifications() async {
    if (initialized) return;

    timezone.initializeTimeZones();
    final String current_timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(current_timezone));

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );
    await NotificationsPlugin.initialize(initSettings);

    final androidImplementation = NotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    initialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'noxus_notifications',
        'Noxus Notifications',
        channelDescription: 'Notifications for reality checks and reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  Future<void> showNotification({String? title, String? body}) async {
    int new_oID = rand.nextInt(100);
    for (int i = 0; i < 100; i++) {
      int tempID = rand.nextInt(100);
      if (!IDS.contains(tempID)) {
        new_oID = tempID;
        break;
      }
    }
    IDS.add(new_oID);

    return NotificationsPlugin.show(new_oID, title, body, notificationDetails());
  }

  Future<void> scheduleNotification({required String? title, required String? body, required int year, required int month, required int day, required int hour, required int minute}) async {
    var scheduled = tz.TZDateTime(
      tz.local, 
      year,
      month,
      day,
      hour,
      minute
    );

    int new_sID = 100 + rand.nextInt(100);
    for (int i = 0; i < 100; i++) {
      int tempID = 100 + rand.nextInt(100);
      if (!IDS.contains(tempID)) {
        new_sID = tempID;
        break;
      }
    }
    IDS.add(new_sID);

    await NotificationsPlugin.zonedSchedule(
      new_sID, 
      title, 
      body, 
      scheduled, 
      notificationDetails(), 
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> purgeNotifications() async {
    await NotificationsPlugin.cancelAll();
  }
}