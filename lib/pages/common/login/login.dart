import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/widgets/Input/Input.dart';
import 'package:fluent_beat/widgets/LogoWithChild/LogoWithChild.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:get/get.dart';

import '../../../widgets/Button/Button.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username = "";
  String password = "";

  String message = "";

  late AuthUser user;
  void checkUser() async {
    try {
      user = await Amplify.Auth.getCurrentUser();

      Get.to(ClientPage(user: user));
    } on AuthException {
      // nothing to do...
    }
  }

  @override
  void initState() {
    super.initState();

    checkUser();
  }

  void signIn() async {
    bool hasAllValues = username != "" && password != "";

    setState(() {
      message = !hasAllValues ? "All fields are required." : "";
    });

    if (!hasAllValues) return;

    try {
      SignInResult signInResult =
          await Amplify.Auth.signIn(username: username, password: password);

      user = await Amplify.Auth.getCurrentUser();

      setState(() {
        Get.to(ClientPage(user: user));
      });
    } on AuthException catch (e) {
      setState(() {
        message = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LogoWithChild(
      child: Column(
        children: [
          Input(
              onChange: (txt) {
                username = txt.trim();
              },
              labelText: "Email"),
          Input(
            onChange: (txt) {
              password = txt;
            },
            labelText: "Password",
            password: true,
          ),
          Text(message,
              style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 18)),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Button(bg: 0xffffffff, text: "Sign In", onPress: signIn),
          ),
        ],
      ),
    );
  }
}
