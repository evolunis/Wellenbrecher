import 'package:shared_preferences/shared_preferences.dart';

read(key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? 0;
}

save(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}
