import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:flutter/foundation.dart';
import 'package:wellenflieger/utils/api_calls.dart';

const appGroupID = "group.com.evolunis.wellenflieger";

read(key) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    SharedPreferenceAppGroup.setAppGroup(appGroupID);
    try {
      var value = await SharedPreferenceAppGroup.get(key);
      fetchGet(
          "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?key=${value.toString()}");
      value ??= "";
      return value;
    } catch (e) {
      fetchGet(
          "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?key=${e.toString()}");
    }
  } else {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }
}

save(key, value) async {
  if (false && defaultTargetPlatform == TargetPlatform.iOS) {
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
