import 'package:flutter/foundation.dart';

import 'package:wellenbrecher/service_locator.dart';
import 'package:wellenbrecher/services/cloud_server_service.dart';
import 'package:wellenbrecher/services/notifications_service.dart';
import 'package:wellenbrecher/utils/local_storage.dart' as ls;

class SettingsModel extends ChangeNotifier {
  CloudServerService cloudServer = serviceLocator<CloudServerService>();
  NotificationsService notifications = serviceLocator<NotificationsService>();

  Future<bool> setSettings(
      String serverAddress, String apiKey, bool showNotifs) async {
    if (serverAddress != "" && serverAddress[serverAddress.length - 1] == "/") {
      serverAddress = serverAddress.substring(0, serverAddress.length - 1);
    }
    ls.save("serverAddr", serverAddress);
    ls.save("apiKey", apiKey);
    ls.save("showNotifs", showNotifs.toString());
    cloudServer.updateSettings();
    notifications.updateSettings();
    return true;
  }

  getSettings() async {
    Map settings = {};
    settings['serverAddress'] = await ls.read('serverAddr') ?? "";
    settings['apiKey'] = await ls.read('apiKey') ?? "";
    settings['showNotifs'] =
        await ls.read('showNotifs') != "false" ? true : false;
    return settings;
  }

  getAutoToggle() {
    return ls.read("autoToggle").then((state) {
      return state == "true" ? true : false;
    });
  }

  void setAutoToggle(bool state) {
    ls.save("autoToggle", state.toString());
    notifications.updateSettings();
  }
}
