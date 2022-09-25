/* Handles all operations related to the smart plugs control */

import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:wellenreiter/utils/storage.dart' as prefs;
import 'package:wellenreiter/utils/api_calls.dart';

class ServerAuth {
  String serverAddress;
  String apiKey;

  ServerAuth(this.serverAddress, this.apiKey);
}

class CloudServerService {
  ServerAuth serverAuth = ServerAuth("", "");
  bool isAuthValid = false;
  VoidCallback? devicesModelCallback;

  init() async {
    var var1 = await prefs.read("server");
    var var2 = await prefs.read("apikey");
    serverAuth = ServerAuth(var1, var2);
  }

  setCallback(VoidCallback cb) {
    devicesModelCallback = cb;
  }

  emitRefresh() {
    devicesModelCallback!();
  }

  Future<bool> setSettings(ServerAuth serverAuth) async {
    this.serverAuth = serverAuth;
    var res1 = await prefs.save("server", serverAuth.serverAddress);
    var res2 = await prefs.save("apikey", serverAuth.apiKey);

    return res1 && res2;
  }

  ServerAuth? getSettings() {
    return serverAuth;
  }

  sendCommand(String command, Map<String, String> args) async {
    String url = serverAuth.serverAddress + command;
    args.addAll({"auth_key": serverAuth.apiKey});
    dynamic response = await fetchPost(url, args);
    return response;
  }

  checkDeviceStatus(String id) async {
    return sendCommand("/device/status", {"id": id}).then((res) {
      try {
        print("response");
      } catch (e) {
        print(e);
      }

      return jsonDecode(res.body)['isok'];
    });
  }

  checkAllDevicesStatus() async {
    var res = await sendCommand("/device/all_status?show_info=true", {});
    res = jsonDecode(res.body);
    if (res['isok']) {
      Map status = res['data']['devices_status'];
      Iterable devices = status.keys;
      Map statusClean = {};
      for (var device in devices) {
        statusClean[device] = {
          "online": status[device]["_dev_info"]['online'],
          "code": status[device]["_dev_info"]['code']
        };
      }
      return statusClean;
    }
  }

//Willr only check the key, not the server address
  dynamic checkAuthSettings() async {
    var res = await sendCommand("/device", {});
    if (res != false) {
      print(res.statusCode);
      if (res.statusCode == 200) {
        isAuthValid = true;
        return true;
      } else {
        isAuthValid = false;
        return {
          "status": "error",
          "message": "API key invalid, please update settings !"
        };
      }
    } else {
      isAuthValid = false;
      return {
        "status": "error",
        "message":
            "Can't connect to server, please update settings or check connection !"
      };
    }
  }

  getIsAuthValid() {
    return isAuthValid;
  }

  setIsAuthValid(val) {
    isAuthValid = val;
  }
}
