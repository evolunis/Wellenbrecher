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

class DevicesModel extends ChangeNotifier {
  CloudServerService cloudServer = serviceLocator<CloudServerService>();
  Box? devices;

  init() async {
    return cloudServer.checkAuthSettings().then((res) async {
      Hive.registerAdapter<Device>(DeviceAdapter());
      devices = await Hive.openBox<Device>('devices');
      checkDevicesValidity();
      notifyListeners();
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
    notifyListeners();
  }

  delete(int index) {
    devices?.deleteAt(index);
    notifyListeners();
  }

  update(int index, Device device) {
    devices?.putAt(index, device);
    notifyListeners();
  }

  checkDevicesValidity() async {
    var validList = [];

    for (var i = 0; i < read().length; i++) {
      validList.add(await cloudServer.checkDeviceStatus(get(i).id));
    }
    return validList;
  }
}
