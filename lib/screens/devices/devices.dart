import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wellenflieger/utils/local_storage.dart' as ls;

import 'package:wellenflieger/models/devices.dart';
import 'package:wellenflieger/models/time_series.dart';

import 'package:wellenflieger/screens/settings.dart';
import 'package:wellenflieger/screens/devices/parts/modal.dart';
import 'package:wellenflieger/screens/devices/parts/time_series.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> with WidgetsBindingObserver{
  @override
 
  //Initialization, data fetching
  void initState() {
    ls.read('firstInit').then((value) {
      if (value == "true") {
        //// special start !
      }
    });
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Provider.of<DevicesModel>(context, listen: false).init().then((res) {
      if (res != true) {
        Future<void>.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res)),
          );
        });
      }
      Provider.of<TimeSeriesModel>(context, listen: false).init();
    });
  }
  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Provider.of<DevicesModel>(context, listen: false).refresh();
    }
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
                MaterialPageRoute(
                    builder: (context) =>
                        const SettingsForm()), //Scaffold.of(context).openEndDrawer(),
                //tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          )
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
                  "No server available, check settings or internet connection !"),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showModalBottomSheet(
              context: context,
              builder: (ctx) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 3,
                  child: const Center(
                    child: TimeSeries(),
                  ),
                );
              })
        },
        tooltip: 'Show chart',
        child: const Icon(Icons.area_chart),
      ),
      bottomNavigationBar:
          Consumer<DevicesModel>(builder: (context, devicesModel, child) {
        if (devicesModel.shouldShow()) {
          return BottomAppBar(
            //shape: shape,
            color: Colors.blue,
            child: IconTheme(
              data:
                  IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              child: Row(
                children: <Widget>[
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
                  IconButton(
                    tooltip: 'Add a device',
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return DeviceModal(-1, Device(id: "", name: ""));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      // This traili
      //Settings drawer
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text('Settings'),
            ),
            const SettingsForm(),
          ],
        ),
      ),
    );
  }
}
