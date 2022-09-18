import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelly_controller/models/settings.dart';
import 'package:shelly_controller/models/devices.dart';
import 'package:shelly_controller/screens/parts/settings.dart';
import 'package:shelly_controller/screens/parts/modal.dart';

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
    Provider.of<SettingsModel>(context, listen: false).loadSettings();

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
              Card(
                color: Colors.grey,
                child: InkWell(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return DeviceModal(-1, Device(id: "", name: ""));
                      },
                    );
                  },
                  child: const Center(
                    child: Icon(Icons.add_sharp, size: 100),
                  ),
                ),
              ),
              Card(
                color: Colors.grey,
                child: Center(
                  child: InkWell(
                    onTap: () async {},
                    child:
                        const Icon(Icons.airplane_ticket_outlined, size: 100),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
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
