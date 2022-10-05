/* Handles all operations related to the smart plugs control */

import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

import 'package:wellenbrecher/utils/local_storage.dart' as ls;
import 'package:wellenbrecher/utils/api_calls.dart';

//Authentification data class
class ServerAuth {
  String serverAddress;
  String apiKey;
  bool isAuthValid;
  String errorMessage;

  ServerAuth(this.serverAddress, this.apiKey,
      [this.isAuthValid = false, this.errorMessage = ""]);
}

class CloudServerService {
  ServerAuth serverAuth = ServerAuth("", "");
  VoidCallback? devicesModelCallback;

  //Keep track of the interval between api calls
  DateTime lastTime = DateTime.now();
  bool loading = true;

  init() async {
    var serverAddr = await ls.read("serverAddr") ?? "";
    var apiKey = await ls.read("apiKey") ?? "";
    var isAuthValid = await ls.read("isAuthValid") == "true" ? true : false;

    serverAuth = ServerAuth(serverAddr, apiKey, isAuthValid);
  }

  setCallback(VoidCallback cb) {
    devicesModelCallback = cb;
  }

  notifyProviders() {
    devicesModelCallback!();
  }

  updateSettings() async {
    var serverAddr = await ls.read("serverAddr") ?? "";
    var apiKey = await ls.read("apiKey") ?? "";
    var isAuthValid = false;
    serverAuth = ServerAuth(serverAddr, apiKey, isAuthValid);

    checkAuthSettings().then((res) {
      notifyProviders();
    });
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

  //Switch all devices in local memory after opening app or changeing auto setting
  catchUp(state) async {
    String devicesIds = await ls.read('devicesIds');
    var devices = jsonDecode(devicesIds);
    var ids = [];
    for (var device in devices) {
      ids.add(device['id']);
    }

    Future.delayed(const Duration(milliseconds: 2000), () async {
      switchAllDevices(ids, state);

      notifyProviders();
    });
  }

//Willr only check the key, not the server address
  Future<bool> checkAuthSettings() async {
    var res = await sendCommand("/device", {});
    if (res != false) {
      if (res.statusCode == 200) {
        setIsAuthValid(true);
        return true;
      } else {
        setIsAuthValid(false);
        serverAuth.errorMessage = "API key invalid, please update settings !";
        return false;
      }
    } else {
      setIsAuthValid(false);
      serverAuth.errorMessage =
          "Can't connect to server, please update settings or check connection !";
      return false;
    }
  }

  //Setter and getter for the auth class
  getIsAuthValid() {
    return serverAuth.isAuthValid;
  }

  setIsAuthValid(bool valid) {
    serverAuth.isAuthValid = valid;
    ls.save("isAuthValid", valid.toString());
  }
}
