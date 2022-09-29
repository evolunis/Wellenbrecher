import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:wellenflieger/utils/remote_database.dart' as db;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//Background handler : Only on Android, iOS is handled natively.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //await Firebase.initializeApp();
  //prefs.reload();
  //await prefs.save("message", message.messageId.toString());

  //print("Handling a background message: ${message.messageId}");
}

//Foreground handler
Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Message data: ${message.data}');

  var url =
      "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?key='foreground'";
  http.get(Uri.parse(url));

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
}

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
    }

    //Foreground handler
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

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
