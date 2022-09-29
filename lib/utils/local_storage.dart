import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:flutter/foundation.dart';

const appGroupID = "group.com.evolunis.wellenflieger";

read(key) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    SharedPreferenceAppGroup.setAppGroup(appGroupID);
    String value = await SharedPreferenceAppGroup.get(key);
    value ??= "";
    return "";
  } else {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }
}

save(key, value) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    SharedPreferenceAppGroup.setAppGroup(appGroupID);
    return await SharedPreferenceAppGroup.setString(key, value);
  } else {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }
}

reload() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.reload().then((v) {
    return true;
  });
}
