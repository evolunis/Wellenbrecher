import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelly_controller/models/settings.dart';
import 'package:shelly_controller/models/devices.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override

  //Initialization, data fetching
  void initState() {
    Provider.of<SettingsModel>(context, listen: false).loadSettings();
    Provider.of<DevicesModel>(context, listen: false).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Center(child: Consumer<DevicesModel>(
        builder: (context, deviceModel, child) {
          return GridView.count(crossAxisCount: 3, children: [
            ...List.generate(deviceModel.devices.values.toList().length,
                (index) {
              return Card(
                color: Colors.lightGreen,
                borderOnForeground: true,
                child: Center(
                  child: Text(
                    'Item $index ${deviceModel.devices.values.toList()[index].name}',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              );
            }),
            const Card(
              color: Colors.grey,
              child: Center(
                child: Icon(Icons.add_box_outlined, size: 100),
              ),
            ),
          ]);
        },
      )),
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

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  SettingsFormState createState() {
    return SettingsFormState();
  }
}

class SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Allows to fill fields with settings values.
    final SettingsModel settingsModel =
        Provider.of<SettingsModel>(context, listen: false);
    final serverController = TextEditingController(
        text: settingsModel.serverSettings?.serverAddress);
    final keyController =
        TextEditingController(text: settingsModel.serverSettings?.apiKey);

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              controller: serverController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              controller: keyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Secret key',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<SettingsModel>(context, listen: false).set(
                      ServerSettings(
                          serverController.text, keyController.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved !')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
