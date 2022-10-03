import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:flutter/foundation.dart';

const appGroupID = "group.com.evolunis.wellenbrecher";

read(key) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    SharedPreferenceAppGroup.setAppGroup(appGroupID);
    try {
      return SharedPreferenceAppGroup.get(key).then((value) {
        return value;
      });
    } catch (e) {
      print("false");
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
