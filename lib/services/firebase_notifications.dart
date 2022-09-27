import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:wellenflieger/utils/local_storage.dart' as prefs;
import 'package:wellenflieger/utils/remote_database.dart' as db;
import 'package:flutter/foundation.dart';

//Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  //prefs.reload();
  await prefs.save("message", message.messageId.toString());

  //print("Handling a background message: ${message.messageId}");
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

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
