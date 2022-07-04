import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/pages/doctor/doctor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void redirectUserToRelevantPage(AuthUser user) async {
  try {
    var userAttributes = await Amplify.Auth.fetchUserAttributes();

    for (var element in userAttributes) {
      if (element.userAttributeKey.toString() == "custom:usertype") {
        if (element.value == "USER") {
          Get.to(() => ClientPage(user: user));
        } else if (element.value == "DOCTOR") {
          Get.to(() => DoctorPage(user: user));
        }
      }
    }
  } catch (e) {
    // nothing to do...
  }
}

void showErrorDialog(String message, BuildContext context) {
  AlertDialog alert = AlertDialog(
    title: const Text("An error occured"),
    content: Text(message),
    actions: [
      ElevatedButton(
          onPressed: () {
            // hide dialog
            Navigator.of(context).pop();
          },
          child: const Text("OK")),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
