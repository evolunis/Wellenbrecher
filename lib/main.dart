import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:wellenflieger/models/settings.dart';
import 'package:wellenflieger/models/time_series.dart';
import 'package:wellenflieger/models/devices.dart';
import 'package:wellenflieger/screens/devices/devices.dart';

import 'package:wellenflieger/service_locator.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wellenflieger/utils/storage.dart' as prefs;

//Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  prefs.reload();
  prefs.save("message", message.messageId);

  //print("Handling a background message: ${message.messageId}");
}

void main() async {
  await Hive.initFlutter();

  //Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

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
  String? token = "";
  FirebaseMessaging.instance.getToken().then((value) {
    token = value;
    setUp();
    serviceLocator.allReady().then((value) {
      runApp(MyApp(token: token));
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.token});
  final String? token;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsModel()),
        ChangeNotifierProvider(create: (context) => DevicesModel()),
        ChangeNotifierProvider(create: (context) => TimeSeriesModel())
      ],
      child: MaterialApp(
        title: 'Wellenflieger',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF3399FF),
        ),
        home: DevicesPage(token: token),
      ),
    );
  }
}

/*
class SnackBarModel extends ChangeNotifier {
  String message = "";

  showMessage(String message) {
    message = message;
    notifyListeners();
  }

  getMessage() {
    return message;
  }
}
*/