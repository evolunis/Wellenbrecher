import 'package:flutter/material.dart';
import 'dart:async';

class ShadowSwitch extends StatefulWidget {
  const ShadowSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final Function onChanged;

  @override
  State<ShadowSwitch> createState() => _ShadowSwitchState();
}

class _ShadowSwitchState extends State<ShadowSwitch> {
  late Timer timer;
  late bool large;
  @override
  void initState() {
    super.initState();
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
        decoration: widget.value
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
            value: widget.value,
            thumbColor: MaterialStateProperty.all(Colors.red),
            trackColor: MaterialStateProperty.all(Colors.white),
            onChanged: (state) {
              widget.onChanged(state);
            }));
  }
}
