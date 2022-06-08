import 'package:fluent_beat/pages/common/signup/signup.dart';
import 'package:fluent_beat/widgets/Button/Button.dart';
import 'package:flutter/material.dart';

class Toggles extends StatefulWidget {
  List<bool> toggleButtonsSelected;
  Toggles({Key? key, required this.toggleButtonsSelected}) : super(key: key);

  @override
  State<Toggles> createState() => _TogglesState();
}

class _TogglesState extends State<Toggles> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
        "Account Type",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
      const SizedBox(height: 16),
      ToggleButton(
          text: "Doctor",
          selected: Signup.of(context)!.userType == "DOCTOR",
          onPress: () {
            setState(() {
              Signup.of(context)!.userType = "DOCTOR";
            });
          }),
      ToggleButton(
          text: "User",
          selected: Signup.of(context)!.userType == "USER",
          onPress: () {
            setState(() {
              Signup.of(context)!.userType = "USER";
            });
          }),
    ]);
  }
}

class ToggleButton extends StatelessWidget {
  final String text;
  final bool selected;
  final Function onPress;

  const ToggleButton(
      {Key? key,
      required this.text,
      required this.selected,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      text: text,
      bg: !selected ? 0xffffffff : 0xffFFC0C0,
      onPrimary: 0xffFFAAAA,
      onPress: () => onPress(),
    );
  }
}
