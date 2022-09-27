import 'package:shared_preferences/shared_preferences.dart';

read(key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? "";
}

save(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.setString(key, value);
}

reload() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.reload().then((v) {
    return true;
  });
}
