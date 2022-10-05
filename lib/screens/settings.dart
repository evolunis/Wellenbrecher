import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellenbrecher/models/settings.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  SettingsFormState createState() {
    return SettingsFormState();
  }
}

class SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  //Linked model
  late SettingsModel settingsModel;

  //Fields variables
  late TextEditingController serverController;
  late TextEditingController keyController;
  late bool showNotifs;

  late bool loading;
  late Map settings;

  @override
  void initState() {
    super.initState();
    settings = {};
    loading = true;
    keyController = TextEditingController(text: "");
    serverController = TextEditingController(text: "");
    settingsModel = Provider.of<SettingsModel>(context, listen: false);
    getSettings();
  }

  //Loads the to be put in the fields
  getSettings() async {
    settingsModel.getSettings().then((settings) {
      setState(() {
        settings = settings;
        loading = false;
        serverController =
            TextEditingController(text: settings['serverAddress']);
        keyController = TextEditingController(text: settings['apiKey']);

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
            serverController.text, keyController.text, showNotifs),
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
                          title: const Text("Show reminders "),
                          trailing: Switch(
                              value: showNotifs,
                              onChanged: (bool value) {
                                setState(() {
                                  showNotifs = value;
                                });
                              }),
                        ),
                        ListTile(
                            title: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: InkWell(
                                      onTap: () async {
                                        await launchUrl(
                                            Uri.parse(
                                                'https://youtu.be/JMoZeLe6TS0'),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: Row(children: [
                                        const Icon(Icons.info_outline),
                                        Text(
                                          ' Setup video guide',
                                          style: const TextStyle(
                                                  color: Colors.black)
                                              .merge(const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ]))),
                            ],
                          ),
                        ))
                      ],
                    ),
                  )));
  }
}
