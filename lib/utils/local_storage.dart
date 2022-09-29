//import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

const appGroupID = "group.com.evolunis.wellenflieger";

read(key) async {
  SharedPreferenceAppGroup.setAppGroup(appGroupID);
  return SharedPreferenceAppGroup.get(key);
}

save(key, value) async {
  SharedPreferenceAppGroup.setAppGroup(appGroupID);

  return await SharedPreferenceAppGroup.setString(key, value);
}

/*
reload() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.reload().then((v) {
    return true;
  });
}
*/
