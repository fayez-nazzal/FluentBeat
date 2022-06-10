import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/pages/common/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'amplifyconfiguration.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool hasAuthUser = false;
  bool amplifyConfigured = false;
  late AuthUser user;

  void checkUser() async {
    try {
      user = await Amplify.Auth.getCurrentUser();

      Get.to(ClientPage(user: user));
    } on AuthException {
      // amplify would be configured if we reach here, so redirect to Login page
      setState(() {
        amplifyConfigured = true;
      });
    }
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugin(AmplifyAuthCognito());

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      print('An error occurred configuring Amplify: $e');
    }

    checkUser();
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: amplifyConfigured ? LoginPage() : Container(),
    );
  }
}
