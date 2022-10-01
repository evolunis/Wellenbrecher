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

  @override
  Widget build(BuildContext context) {
    // Allows to fill fields with settings values.
    final SettingsModel settingsModel =
        Provider.of<SettingsModel>(context, listen: false);
    Map settings = settingsModel.getSettings();
    final serverController =
        TextEditingController(text: settings['serverAddress']);
    final keyController = TextEditingController(text: settings['apiKey']);
    bool notifs = false;
    bool autoToggle = false;

    // Build a Form widget using the _formKey created above.
    return Scaffold(
        //Appbar
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Switch(
                      // This bool value toggles the switch.
                      value: notifs,
                      activeColor: Colors.red,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        notifs = value;
                      })),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Switch(
                      // This bool value toggles the switch.
                      value: autoToggle,
                      activeColor: Colors.red,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        autoToggle = value;
                      })),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Provider.of<SettingsModel>(context, listen: false)
                          .setSettings(
                              serverController.text, keyController.text)
                          .then((res) {
                        if (res == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved !')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['message'])),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Save settings'),
                ),
              ),
            ],
          ),
        ));
  }
}
