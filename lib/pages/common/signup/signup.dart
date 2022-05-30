import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/pages/common/login/login.dart';
import 'package:fluent_beat/widgets/Input/Input.dart';
import 'package:fluent_beat/widgets/LogoWithChild/LogoWithChild.dart';
import 'package:flutter/material.dart';

import '../../../widgets/Button/Button.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String name = "";
  String username = "";
  String password = "";
  String message = "";
  String confirmPassword = "";
  bool hasUser = false;
  late AuthUser user;

  void checkUser() async {
    try {
      user = await Amplify.Auth.getCurrentUser();

      // if so, push to the client page
      setState(() {
        hasUser = true;
      });
    } on AuthException {
      // nothing to do...
    }
  }

  @override
  void initState() {
    super.initState();

    checkUser();
  }

  void signUp() async {
    bool matchPasswords = password == confirmPassword;
    bool hasAllFields =
        name != "" && username != "" && password != "" && confirmPassword != "";

    setState(() {
      message = "";

      if (!matchPasswords) {
        message = "Passwords must match";
      }

      if (!hasAllFields) {
        message = "All fields are required";
      }
    });

    if (!matchPasswords || !hasAllFields) return;

    try {
      Map<CognitoUserAttributeKey, String> userAttributes = {
        CognitoUserAttributeKey.name: name,
        CognitoUserAttributeKey.email: username,
      };

      SignUpResult signupResult = await Amplify.Auth.signUp(
          username: username,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));

      user = await Amplify.Auth.getCurrentUser();

      setState(() {
        hasUser = true;
      });
    } on AuthException catch (e) {
      setState(() {
        message = e.message;

        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasUser) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ClientPage(user: user)));
    }

    return LogoWithChild(
        child: Column(
      children: [
        Input(
            onChange: (txt) {
              name = txt.trim();
            },
            labelText: "Name"),
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
        Input(
          onChange: (txt) {
            confirmPassword = txt;
          },
          labelText: "Confirm Password",
          password: true,
        ),
        Text(message,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.w500, fontSize: 18)),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Button(
              bg: 0xffff7f7f,
              text: "Sign Up",
              onPrimary: 0xffffff,
              onPress: signUp),
        ),
      ],
    ));
  }
}
