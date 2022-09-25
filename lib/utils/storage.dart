import 'package:shared_preferences/shared_preferences.dart';

read(key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? "https://shelly-49-eu.shelly.cloud";
}

save(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.setString(key, value);
}
