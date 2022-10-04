import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wellenbrecher/utils/local_storage.dart' as ls;

import 'package:wellenbrecher/models/devices.dart';
import 'package:wellenbrecher/models/time_series.dart';

import 'package:wellenbrecher/screens/settings.dart';
import 'package:wellenbrecher/screens/devices/parts/modal.dart';
import 'package:wellenbrecher/screens/devices/parts/time_series.dart';
import 'package:wellenbrecher/screens/devices/parts/switch.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> with WidgetsBindingObserver {
  late bool autoToggle;

  //Initialization, data fetching
  @override
  void initState() {
    var devicesModel = Provider.of<DevicesModel>(context, listen: false);
    ls.read('firstInit').then((value) {
      if (value == "true") {
        //// special start !
      }
    });
    super.initState();
    autoToggle = true;
    WidgetsBinding.instance.addObserver(this);
    devicesModel.init().then((res) {
      if (res != true) {
        Future<void>.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res)),
          );
        });
      }

      Provider.of<TimeSeriesModel>(context, listen: false).update();
    });
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Provider.of<DevicesModel>(context, listen: false).refresh();
      Provider.of<TimeSeriesModel>(context, listen: false).update();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsForm()),
              ),
            ),
          ),
        ],
        title: const Text("Devices"),
      ),
      body: Consumer<DevicesModel>(builder: (context, devicesModel, child) {
        if (devicesModel.hasLoaded) {
          if (devicesModel.shouldShow()) {
            //Gridview
            return GridView.count(crossAxisCount: 3, children: [
              ...List.generate(devicesModel.readDb().length, (index) {
                return Card(
                  color: devicesModel.getDeviceStatus(index) != false
                      ? (devicesModel.getDeviceStatus(index)['online']
                          ? (devicesModel.getDeviceStatus(index)['ison']
                              ? Colors.green
                              : Colors.red)
                          : Colors.blue)
                      : Colors.grey,
                  borderOnForeground: true,
                  child: InkWell(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return DeviceModal(
                              index, devicesModel.getDevice(index));
                        },
                      );
                    },
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${devicesModel.getDevice(index).name}\n",
                            ),
                            WidgetSpan(
                                child: devicesModel.getDeviceStatus(index) !=
                                        false
                                    ? devicesModel
                                            .getDeviceStatus(index)['online']
                                        ? const SizedBox.shrink()
                                        : const Icon(Icons.wifi_off,
                                            size: 20, color: Colors.yellow)
                                    : const Icon(Icons.warning_amber,
                                        size: 20, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(
                child: Center(
                  child: Text(devicesModel.retrieveMessage()),
                ),
              ),
            ]);
          } else {
            return const Center(
              child: Text(
                "No server available, check settings or internet connection !",
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),

      floatingActionButton:
          Consumer<TimeSeriesModel>(builder: (context, timeSeries, child) {
        return FloatingActionButton(
            onPressed: () => {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                            color: Colors.white,
                          ),
                          height: MediaQuery.of(context).size.height * 3,
                          child: const Center(
                            child: TimeSeries(),
                          ),
                        );
                      })
                },
            tooltip: 'Show chart',
            backgroundColor: (timeSeries.getData() != null &&
                    timeSeries.getData()['overProd'] != null)
                ? (timeSeries.getData()['overProd'] ? Colors.green : Colors.red)
                : Colors.blue,
            child: const Icon(Icons.area_chart));
      }),
      bottomNavigationBar:
          Consumer<DevicesModel>(builder: (context, devicesModel, child) {
        if (devicesModel.shouldShow()) {
          return BottomAppBar(
              //shape: shape,
              color: Colors.blue,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                          color: Theme.of(context).colorScheme.onPrimary),
                      child: Row(children: <Widget>[
                        IconButton(
                          tooltip: 'Switch all devices on',
                          icon: const Icon(Icons.power),
                          onPressed: (() {
                            devicesModel.switchDevices(true);
                          }),
                        ),
                        IconButton(
                          tooltip: 'Switch all devices off',
                          icon: const Icon(Icons.power_off),
                          onPressed: () {
                            devicesModel.switchDevices(false);
                          },
                        ),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 30),
                      child: IconTheme(
                        data: IconThemeData(
                            color: Theme.of(context).colorScheme.onPrimary),
                        child: Row(children: <Widget>[
                          IconButton(
                            tooltip: 'Add a device',
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return DeviceModal(
                                      -1, Device(id: "", name: ""));
                                },
                              );
                            },
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: const [
                          Icon(Icons.bolt, color: Colors.white),
                          Text("Auto : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          ShadowSwitch()
                        ],
                      ),
                    )
                  ]));
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}
