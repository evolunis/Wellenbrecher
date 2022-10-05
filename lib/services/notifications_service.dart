import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wellenbrecher/service_locator.dart';

import 'package:wellenbrecher/utils/remote_database.dart' as db;
import 'package:wellenbrecher/utils/local_storage.dart' as ls;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:wellenbrecher/services/cloud_server_service.dart';

//Background handler : Only on Android, iOS is handled natively.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationsService {
  late CloudServerService cloudServer;

  //Foreground notifications handler
  Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {
    var title = message.notification?.title ?? "The market has changed :";
    var state = message.data['toState'] ?? "fail";
    // var state = "off";

    ls.read('autoToggle').then((auto) {
      auto = auto != "false" ? true : false;
      if (auto) {
        showNotification(title, "Your devices were turned $state !");
      } else {
        showNotification(title, "Time to turn your devices $state !");
      }
      Future.delayed(const Duration(seconds: 1), () async {
        notifyProvider();
      });
    });
  }

  //Firebase and local notification variables
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  VoidCallback? devicesModelCallback;

  final FlutterLocalNotificationsPlugin _localNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  late DarwinInitializationSettings iosSettings;

  late InitializationSettings localSettings;

  NotificationsService() {
    iosSettings = const DarwinInitializationSettings();
    localSettings = InitializationSettings(iOS: iosSettings);
  }

  init() async {
    //Asks for notifications permission
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

      return true;
    });
  }

  //Second init called later as other service isn't ready
  setup() {
    cloudServer = serviceLocator<CloudServerService>();
    updateSettings();
  }

  //Show a local notification
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

  setCallback(VoidCallback cb) {
    devicesModelCallback = cb;
  }

  notifyProvider() {
    devicesModelCallback!();
  }

  //Update the service after settings were changed
  updateSettings() async {
    var showNotifs = await ls.read('showNotifs');
    showNotifs = showNotifs != "false" ? true : false;
    var autoToggle = await ls.read('autoToggle');
    autoToggle = autoToggle != "false" ? true : false;

    if (autoToggle || showNotifs) {
      messaging.subscribeToTopic("All");
    } else {
      messaging.unsubscribeFromTopic("All");
    }
    if (autoToggle) {
      var state = await db.read("/data/overProd");

      cloudServer.catchUp(state);
    }
  }
}
