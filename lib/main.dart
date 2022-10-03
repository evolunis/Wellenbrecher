import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:wellenbrecher/models/settings.dart';
import 'package:wellenbrecher/models/time_series.dart';
import 'package:wellenbrecher/models/devices.dart';
import 'package:wellenbrecher/screens/devices/devices.dart';

import 'package:wellenbrecher/service_locator.dart';
import 'package:wellenbrecher/services/firebase_notifications.dart';
import 'package:flutter/foundation.dart';

import 'package:app_group_directory/app_group_directory.dart';
import 'dart:io';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Hive.initFlutter();

  //Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //testing
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    String data = "This is a test !";
    try {
      Directory? sharedDirectory = await AppGroupDirectory.getAppGroupDirectory(
          'group.com.evolunis.wellenbrecher');

      File file = File('${sharedDirectory?.path}/Library/Caches/settings.txt');
      file.writeAsString(data);
    } catch (e) {
      print("false");
    }
  }

  setUp();
  serviceLocator.allReady().then((value) {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      FirebaseNotifications notifications = FirebaseNotifications();
      notifications.init().then((token) {
        runApp(const MyApp());
      });
    } else {
      runApp(const MyApp());
    }
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
        title: 'Wellenbrecher',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF3399FF),
        ),
        home: const DevicesPage(),
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