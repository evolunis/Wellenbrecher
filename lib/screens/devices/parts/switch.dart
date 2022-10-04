import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:wellenbrecher/models/settings.dart';

class ShadowSwitch extends StatefulWidget {
  const ShadowSwitch({super.key});

  @override
  State<ShadowSwitch> createState() => _ShadowSwitchState();
}

class _ShadowSwitchState extends State<ShadowSwitch> {
  late Timer timer;
  late bool large;
  late bool value;
  SettingsModel? settingsModel;

  @override
  void initState() {
    super.initState();
    settingsModel = Provider.of<SettingsModel>(context, listen: false);
    settingsModel?.getAutoToggle().then((state){value = state;});
    large = false;
    timer = Timer.periodic(
        const Duration(milliseconds: 1000),
        (Timer t) => {
              setState((() {
                large = !large;
              }))
            });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.linear,
        height: 20,
        width: 40,
        decoration: value
            ? BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(large ? 1 : 0.1),
                    spreadRadius: 2,
                    blurRadius: 2,

                    //offset: const Offset(0, 3),
                  )
                ],
              )
            : null,
        child: Switch(
            value: value,
            thumbColor: MaterialStateProperty.all(Colors.red),
            trackColor: MaterialStateProperty.all(Colors.white),
            onChanged: (state) {
              setState(() {
                value = state;
              });
              settingsModel?.setAutoToggle(state);
            }));
  }
}
