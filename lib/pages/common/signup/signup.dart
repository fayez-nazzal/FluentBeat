import 'package:fluent_beat/widgets/Input/Input.dart';
import 'package:flutter/material.dart';

import '../../../widgets/Button/Button.dart';

class Signup extends StatelessWidget {
  String username = "";
  String password = "";
  String confirmPassword = "";

  Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Input(
            onChange: (txt) {
              username = txt;
            },
            labelText: "Email"),
        Input(
          onChange: (txt) {
            password = txt;
          },
          labelText: "Password",
          password: true,
        ),
        Input(
          onChange: (txt) {
            password = txt;
          },
          labelText: "Confirm Password",
          password: true,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Button(bg: 0xffffffff, text: "Sign In", onPress: () {}),
        ),
        SizedBox(
          height: 36,
          child: Row(children: const <Widget>[
            Expanded(
                child: Divider(
              thickness: 2,
            )),
            Text(" OR "),
            Expanded(
                child: Divider(
              thickness: 2,
            )),
          ]),
        ),
        Button(
            bg: 0xffff7f7f,
            text: "Sign Up",
            onPrimary: 0xffffff,
            onPress: () {})
      ],
    );
  }
}
