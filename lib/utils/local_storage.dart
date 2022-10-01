import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:flutter/foundation.dart';
import 'package:wellenflieger/utils/api_calls.dart';

const appGroupID = "group.com.evolunis.wellenflieger";

read(key) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    SharedPreferenceAppGroup.setAppGroup(appGroupID);
    try {
      return SharedPreferenceAppGroup.get(key).then((value) {
        return value;
      });
    } catch (e) {
      fetchGet(
          "https://us-central1-wellenflieger-ef341.cloudfunctions.net/getKey?sperror=${e.toString()}");
    }
  } else {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.getString(key);
    });
  }
}

save(String key, String value) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    SharedPreferenceAppGroup.setAppGroup(appGroupID);
    return await SharedPreferenceAppGroup.setString(key, value);
  } else {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }
}
