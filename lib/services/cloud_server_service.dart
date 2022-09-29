/* Handles all operations related to the smart plugs control */

import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:wellenflieger/utils/local_storage.dart' as prefs;
import 'package:wellenflieger/utils/api_calls.dart';

class ServerAuth {
  String serverAddress;
  String apiKey;

  ServerAuth(this.serverAddress, this.apiKey);
}

class CloudServerService {
  ServerAuth serverAuth = ServerAuth("", "");
  bool isAuthValid = false;
  VoidCallback? devicesModelCallback;
  DateTime lastTime = DateTime.now();

  init() async {
    var var1 = await prefs.read("server");
    var var2 = await prefs.read("apikey");

    serverAuth = ServerAuth(var1, var2);
  }

  setCallback(VoidCallback cb) {
    devicesModelCallback = cb;
  }

  notifyProviders() {
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
    //Server accepts only one request per second
    DateTime now = DateTime.now();
    int diff = now.difference(lastTime).inMilliseconds;
    lastTime = DateTime.now();
    int delay = 0;

    if (diff < 800) {
      delay = 800 - diff;
    }

    return Future.delayed(Duration(milliseconds: delay), () async {
      String url = serverAuth.serverAddress + command;
      args.addAll({"auth_key": serverAuth.apiKey});
      dynamic response = await fetchPost(url, args);
      // print("error?:" + jsonDecode(response.body).toString());
      return response;
    });
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
          "code": status[device]["_dev_info"]['code'],
          "ison": status[device]["relays"][0]['ison'] ?? false
        };
      }
      return statusClean;
    }
  }

  Future<void> switchAllDevices(List ids, bool state) async {
    List devices = [];
    for (var i = 0; i < ids.length; i++) {
      devices.add({"id": ids[i].toString(), "channel": "0"});
    }
    return sendCommand("/device/relay/bulk_control", {
      "devices": jsonEncode(devices),
      "turn": state ? "on" : "off"
    }).then((v) {
      return v;
    });
  }

//Willr only check the key, not the server address
  dynamic checkAuthSettings() async {
    var res = await sendCommand("/device", {});
    if (res != false) {
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
