import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

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
  Box? devices;

  init() async {
    Hive.registerAdapter<Device>(DeviceAdapter());
    devices = await Hive.openBox<Device>('devices');
    notifyListeners();
  }

  read() {
    return devices != null ? devices?.values.toList() : [];
  }

  get(int index) {
    return devices?.values.toList()[index];
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
}
