import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:wellenflieger/utils/local_storage.dart' as prefs;
import 'package:wellenflieger/utils/remote_database.dart' as db;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//Handler

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  var url =
      "https://us-central1-wellenflieger-ef341.cloudfunctions.net/testCalled";
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

    //Background handler

    //Foreground handler
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
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
}
