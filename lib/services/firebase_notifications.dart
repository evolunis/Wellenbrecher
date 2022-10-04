import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:wellenbrecher/utils/remote_database.dart' as db;
import 'package:wellenbrecher/utils/local_storage.dart' as ls;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wellenbrecher/utils/api_calls.dart';

//Background handler : Only on Android, iOS is handled natively.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FirebaseNotifications {
  Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
    var title = message.notification?.title ?? "The market has changed :";
    var state = message.toString();
    fetchGet(
        "https://us-central1-wellenbrecher-3c570.cloudfunctions.net/debug?test=$state");

    ls.read('autoToggle').then((state) {
      if (state) {
        showNotification(title, "Your devices were toggled !");
      } else {
        showNotification(title, "Time to toggle your devices !");
      }
    });
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  late DarwinInitializationSettings iosSettings;

  late InitializationSettings localSettings;

  FirebaseNotifications() {
    iosSettings = const DarwinInitializationSettings();
    localSettings = InitializationSettings(iOS: iosSettings);
  }

  init() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _localNotificationPlugin.initialize(
      localSettings,
    );

    //Foreground handler
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    if (defaultTargetPlatform == TargetPlatform.android) {
      //Background handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }

    //Add the token to the database with timestamp for future optimisation
    return messaging.getToken().then((value) {
      db.write("FCMTokens/${value!}",
          {"timestamp": DateTime.now().microsecondsSinceEpoch});

      //Notification channel
      messaging.subscribeToTopic('All');
      return true;
    });
  }

  showNotification(String title, String body) async {
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: "plainCategory",
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(iOS: iosNotificationDetails);

    await _localNotificationPlugin.show(0, title, body, notificationDetails,
        payload: 'item z');
  }
}
