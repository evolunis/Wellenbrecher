import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:wellenbrecher/models/settings.dart';
import 'package:wellenbrecher/models/time_series.dart';
import 'package:wellenbrecher/models/devices.dart';
import 'package:wellenbrecher/screens/devices/devices.dart';

import 'package:wellenbrecher/service_locator.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Hive.initFlutter();

  //Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Setting up Get_it service locator for services
  setUp();
  serviceLocator.allReady().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.token});
  final String? token;

  @override
  Widget build(BuildContext context) {
    //Creating Provider architecture
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsModel()),
        ChangeNotifierProvider(create: (context) => DevicesModel()),
        ChangeNotifierProvider(create: (context) => TimeSeriesModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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