import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:wellenreiter/service_locator.dart';
import 'package:wellenreiter/services/cloud_server_service.dart';

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

  init() async {
    cloudServer.setCallback(refresh);
    Hive.registerAdapter<Device>(DeviceAdapter());
    devices = await Hive.openBox<Device>('devices');
    return cloudServer.checkAuthSettings().then((res) async {
      hasLoaded = true;
      refresh();
      return res;
    });
  }

/* Local database */
  read() {
    return devices != null ? devices?.values.toList() : [];
  }

  get(int index) {
    return devices?.getAt(index);
  }

  add(Device device) {
    devices?.add(device);
    refresh();
  }

  delete(int index) {
    devices?.deleteAt(index);
    refresh();
  }

  update(int index, Device device) {
    devices?.putAt(index, device);
    notifyListeners();
  }

  getDeviceStatus(int index) {
    return devicesStatus[index];
  }

  refresh() {
    if (cloudServer.getIsAuthValid()) {
      checkDevicesStatus().then((val) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  checkDevicesStatus() async {
    List statusList = [];

    Map status = await cloudServer.checkAllDevicesStatus();
    List devList = read();
    for (var i = 0; i < devList.length; i++) {
      var key = status.keys
          .firstWhere((element) => element == devList[i].id, orElse: () => -1);
      if (key != -1) {
        statusList.add(status[key]);
      } else {
        statusList.add(false);
      }
    }
    devicesStatus = statusList;
    return true;
  }

  addAll() async {
    Map status = await cloudServer.checkAllDevicesStatus();
    List devList = read();
    for (var i = 0; i < devList.length; i++) {
      var key = status.keys
          .firstWhere((element) => element == devList[i].id, orElse: () => -1);
      if (key != -1) {}
    }
  }

  bool shouldShow() {
    return cloudServer.getIsAuthValid();
  }
}
