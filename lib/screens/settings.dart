import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellenflieger/models/settings.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  SettingsFormState createState() {
    return SettingsFormState();
  }
}

class SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  late SettingsModel settingsModel;
  late TextEditingController serverController;
  late TextEditingController keyController;
  late bool autoToggle;
  late bool showNotifs;

  late bool loading;
  late Map settings;

  @override
  void initState() {
    super.initState();
    settings = {};
    loading = true;
    autoToggle = showNotifs = true;
    keyController = TextEditingController(text: "");
    serverController = TextEditingController(text: "");
    settingsModel = Provider.of<SettingsModel>(context, listen: false);
    getSettings();
  }

  getSettings() async {
    settingsModel.getSettings().then((settings) {
      setState(() {
        settings = settings;
        loading = false;
        serverController =
            TextEditingController(text: settings['serverAddress']);
        keyController = TextEditingController(text: settings['apiKey']);
        autoToggle = settings['autoToggle'];
        showNotifs = settings['showNotifs'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Allows to fill fields with settings values.

    // Build a Form widget using the _formKey created above.
    return WillPopScope(
        onWillPop: () => settingsModel.setSettings(
            serverController.text, keyController.text, showNotifs, autoToggle),
        child: Scaffold(
            //Appbar
            appBar: AppBar(
              title: const Text("Settings"),
            ),
            body: loading
                ? const SizedBox.shrink()
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
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
                        ListTile(
                          title: const Text("Toggle power automatically  "),
                          trailing: Switch(
                              value: autoToggle,
                              onChanged: (bool value) {
                                setState(() {
                                  autoToggle = value;
                                });
                              }),
                        ),
                        /*ListTile(
                          title: const Text("Show notifications "),
                          trailing: Switch(
                              value: showNotifs,
                              onChanged: (bool value) {
                                setState(() {
                                  showNotifs = value;
                                });
                              }),
                        ),*/
                      ],
                    ),
                  )));
  }
}
