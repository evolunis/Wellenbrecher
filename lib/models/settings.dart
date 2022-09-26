import 'package:flutter/foundation.dart';

import 'package:wellenflieger/service_locator.dart';
import 'package:wellenflieger/services/cloud_server_service.dart';

class SettingsModel extends ChangeNotifier {
  CloudServerService cloudServer = serviceLocator<CloudServerService>();

  dynamic setSettings(String serverAddress, String apiKey) async {
    return cloudServer
        .setSettings(ServerAuth(serverAddress, apiKey))
        .then(((res) {
      return cloudServer.checkAuthSettings().then((res) {
        cloudServer.notifyProviders();
        return res;
      });
    }));
  }

  Map getSettings() {
    ServerAuth? auth = cloudServer.getSettings();
    return {"serverAddress": auth?.serverAddress, "apiKey": auth?.apiKey};
  }
}
