import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelly_controller/models/settings.dart';

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
