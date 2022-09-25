import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellenreiter/models/devices.dart';

class DeviceModal extends StatefulWidget {
  final int index;
  final Device device;
  const DeviceModal(this.index, this.device, {super.key});

  @override
  State<DeviceModal> createState() => _DeviceModalState();
}

class _DeviceModalState extends State<DeviceModal> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final DevicesModel devicesModel =
        Provider.of<DevicesModel>(context, listen: false);
    final nameController = TextEditingController(text: widget.device.name);
    final idController = TextEditingController(text: widget.device.id);
    return AlertDialog(
      content: Stack(
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.close),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
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
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Device id',
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
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text("Save Device"),
                    onPressed: () {
                      if (widget.index >= 0) {
                        devicesModel.modifyDevice(
                            widget.index,
                            Device(
                                name: nameController.text,
                                id: idController.text));
                      } else {
                        devicesModel.addDevice(Device(
                            name: nameController.text, id: idController.text));
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: (widget.index >= 0)
                      ? ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return Colors.red;
                              },
                            ),
                          ),
                          child: const Text("Delete"),
                          onPressed: () {
                            if (widget.index >= 0) {
                              devicesModel.deleteDevice(
                                widget.index,
                              );
                            }
                            Navigator.pop(context);
                          },
                        )
                      : ElevatedButton(
                          child: const Text("Add all available devices."),
                          onPressed: () {
                            devicesModel.addAllExisting();

                            Navigator.pop(context);
                          },
                        ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
