import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:wellenflieger/utils/remote_database.dart' as db;
import 'package:flutter/foundation.dart';

//Background handler : Only on Android, iOS is handled natively.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

//Foreground handler : Only on Android, iOS is handled natively.
Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {}

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

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

    if (defaultTargetPlatform == TargetPlatform.android) {
      //Background handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      //Foreground handler
      FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
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
}
