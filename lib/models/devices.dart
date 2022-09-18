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
  late Box devices;

  init() async {
    Hive.registerAdapter<Device>(DeviceAdapter());
    devices = await Hive.openBox<Device>('devices');
    notifyListeners();
  }

  read() {
    return devices.values.toList();
  }

  get(index) {
    return devices.values.toList()[index];
  }

  add(Device device) {
    devices.add(device);
    notifyListeners();
  }

  delete(index) {
    devices.deleteAt(index);
    notifyListeners();
  }

  update(index, device) {
    devices.putAt(index, device);
    notifyListeners();
  }
}
