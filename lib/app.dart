import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/pages/client/state/connection.dart';
import 'package:fluent_beat/pages/common/login/login.dart';
import 'package:fluent_beat/utils.dart';
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

      redirectUserToRelevantPage(user);
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
      await Amplify.addPlugin(AmplifyStorageS3());

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
      body: Column(
        children: [
          GetBuilder<ClientConnectionController>(
              init: ClientConnectionController(), // INIT IT ONLY THE FIRST TIME
              builder: (_) => Container()),
          amplifyConfigured ? LoginPage() : Container(),
        ],
      ),
    );
  }
}
