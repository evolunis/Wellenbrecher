import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wellenreiter/models/settings.dart';
import 'package:wellenreiter/models/devices.dart';
import 'package:wellenreiter/models/time_series.dart';

import 'package:wellenreiter/screens/parts/settings.dart';
import 'package:wellenreiter/screens/parts/modal.dart';
import 'package:wellenreiter/screens/parts/time_series.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override

  //Initialization, data fetching
  void initState() {
    Provider.of<DevicesModel>(context, listen: false).init();
    Provider.of<SettingsModel>(context, listen: false).init();
    Provider.of<TimeSeriesModel>(context, listen: false).init();

    super.initState();
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
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
        title: const Text("Devices"),
      ),
      body: Center(
        child: Consumer<DevicesModel>(
          builder: (context, devicesModel, child) {
            //Gridview
            return GridView.count(crossAxisCount: 3, children: [
              ...List.generate(devicesModel.read().length, (index) {
                return Card(
                  color: Colors.green,
                  borderOnForeground: true,
                  child: InkWell(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return DeviceModal(index, devicesModel.get(index));
                        },
                      );
                    },
                    child: Center(
                      child: Text(
                        '${devicesModel.get(index).name}',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(
                child: Center(
                  child: InkWell(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return DeviceModal(-1, Device(id: "", name: ""));
                        },
                      );
                    },
                    child: Icon(
                      Icons.add,
                      size: 100,
                      color: Colors.black.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
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
      ), // This traili
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
