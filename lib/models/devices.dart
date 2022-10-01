import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:wellenflieger/service_locator.dart';
import 'package:wellenflieger/services/cloud_server_service.dart';
import 'package:wellenflieger/utils/local_storage.dart' as ls;

part 'devices.g.dart';

@HiveType(typeId: 0) // 1
class Device {
  @HiveField(0) // 2
  String? name;

  @HiveField(1) // 2
  String? id;

  Device({
    this.name,
    this.id,
  });
}

//Not used yet.
List supportedCodes = ["SHPL", "SHPLG-S"];

class DevicesModel extends ChangeNotifier {
  CloudServerService cloudServer = serviceLocator<CloudServerService>();
  bool hasLoaded = false;
  Box? devices;
  List devicesStatus = [];
  String message = "";

  dynamic init() async {
    cloudServer.setCallback(refresh);

    Hive.registerAdapter<Device>(DeviceAdapter());
    devices = await Hive.openBox<Device>('devices');
    return cloudServer.checkAuthSettings().then((res) async {
      dynamic message = true;
      if (res != true) {
        message = cloudServer.serverAuth.errorMessage;
      }
      hasLoaded = true;
      refresh();
      return message;
    });
  }

/* Local database */
  readDb() {
    return devices != null ? devices?.values.toList() : [];
  }

  getDevice(int index) {
    return devices?.getAt(index);
  }

  addDevice(Device device) {
    List devList = readDb();
    List devIds = [];
    for (var i = 0; i < devList.length; i++) {
      devIds.add(devList[i].id);
    }
    if (!devIds.contains(device.id)) {
      devices?.add(device);
      refresh();
    }
  }

  deleteDevice(int index) {
    devices?.deleteAt(index);
    refresh();
  }

  modifyDevice(int index, Device device) {
    List devList = readDb();
    List devIds = [];
    for (var i = 0; i < devList.length; i++) {
      devIds.add(devList[i].id);
    }
    if (!devIds.contains(device.id)) {
      devices?.putAt(index, device);
      refresh();
    }
  }

  getDeviceStatus(int index) {
    return devicesStatus[index];
  }

  switchDevices(bool state) async {
    List devList = readDb();
    List ids = [];
    for (var i = 0; i < devList.length; i++) {
      if (devicesStatus[i] != false && devicesStatus[i]["online"]) {
        ids.add(devList[i].id);
      }
    }
    cloudServer.switchAllDevices(ids, state).then((v) {
      refresh();
    });
  }

  refresh() {
    notifyListeners();
    if (cloudServer.getIsAuthValid()) {
      hasLoaded = false;
      updateDevicesStatusList().then((val) {
        hasLoaded = true;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  updateDevicesStatusList() async {
    List statusList = [];

    Map status = await cloudServer.checkAllDevicesStatus();
    List devList = readDb();
    //this is a summary for extension isolates
    List saveList = [];
    for (var i = 0; i < devList.length; i++) {
      var key = status.keys
          .firstWhere((element) => element == devList[i].id, orElse: () => -1);
      if (key != -1) {
        statusList.add(status[key]);
        saveList.add({"id": devList[i].id, "name": devList[i].name});
      } else {
        statusList.add(false);
      }
    }
    devicesStatus = statusList;
    ls.save("devices", jsonEncode(saveList));
    return true;
  }

  addAllExisting() async {
    Map status = await cloudServer.checkAllDevicesStatus();
    List devList = readDb();
    List devIds = [];
    for (var i = 0; i < devList.length; i++) {
      devIds.add(devList[i].id);
    }
    for (var i = 0; i < status.keys.length; i++) {
      if (!devIds.contains(status.keys.elementAt(i))) {
        String key = status.keys.elementAt(i);
        addDevice(Device(id: key, name: status[key]['code']));
      }
    }
  }

  bool shouldShow() {
    return cloudServer.getIsAuthValid();
  }

  String retrieveMessage() {
    return message;
  }
}
