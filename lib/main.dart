import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:wellenreiter/models/settings.dart';
import 'package:wellenreiter/models/time_series.dart';
import 'package:wellenreiter/models/devices.dart';
import 'package:wellenreiter/screens/devices.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'Wellenreiter',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green,
        ),
        home: const DevicesPage(),
      ),
    );
  }
}
