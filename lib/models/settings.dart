import 'package:flutter/foundation.dart';
import 'package:shelly_controller/utils/storage.dart' as prefs;

class ServerSettings {
  String serverAddress;
  String apiKey;

  ServerSettings(this.serverAddress, this.apiKey);
}

class SettingsModel extends ChangeNotifier {
  ServerSettings? serverSettings;

  void loadSettings() async {
    var var1 = await prefs.read("server");
    var var2 = await prefs.read("apikey");
    serverSettings = ServerSettings(var1, var2);
    notifyListeners();
  }

  void set(ServerSettings serverSettings) {
    this.serverSettings = serverSettings;
    prefs.save("server", serverSettings.serverAddress);
    prefs.save("apikey", serverSettings.apiKey);

    notifyListeners();
  }
}
