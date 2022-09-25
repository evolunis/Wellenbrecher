import 'package:flutter/foundation.dart';

import 'package:wellenreiter/service_locator.dart';
import 'package:wellenreiter/services/cloud_server_service.dart';

class SettingsModel extends ChangeNotifier {
  CloudServerService cloudServer = serviceLocator<CloudServerService>();

  dynamic setSettings(String serverAddress, String apiKey) async {
    return cloudServer
        .setSettings(ServerAuth(serverAddress, apiKey))
        .then(((res) {
      return cloudServer.checkAuthSettings().then((res) {
        notifyListeners();
        return res;
      });
    }));
  }

  Map getSettings() {
    ServerAuth? auth = cloudServer.getSettings();
    return {"serverAddress": auth?.serverAddress, "apiKey": auth?.apiKey};
  }
}
