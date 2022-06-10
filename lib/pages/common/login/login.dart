import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/common/login/login.dart';
import 'package:fluent_beat/pages/common/signup/signup.dart';
import 'package:fluent_beat/widgets/Button/Button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/Input/Input.dart';
import '../../client/client.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = "";
  String password = "";
  String message = "";

  late AuthUser user;
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
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 240, 230, 234),
              Color.fromARGB(255, 250, 214, 252)
            ],
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        const Image(image: AssetImage('images/FluentBeat.png')),
                        const Spacer(),
                        Column(
                          children: [
                            Column(
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
                                  child: Button(
                                      bg: 0xffffffff,
                                      text: "Sign In",
                                      onPress: signIn),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 24),
                              child: Row(children: const <Widget>[
                                Expanded(
                                    child: Divider(
                                  thickness: 2,
                                )),
                                Text("\u200A OR \u200A"),
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
                                onPress: () {
                                  setState(() {
                                    Get.to(SignupPage(
                                        username: username,
                                        password: password));
                                  });
                                }),
                          ],
                        ),
                        Spacer()
                      ],
                    )))));
  }
}
