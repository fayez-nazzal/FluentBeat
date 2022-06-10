import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/pages/doctor/doctor.dart';
import 'package:get/get.dart';

void redirectUserToRelevantPage(AuthUser user) async {
  var userAttributes = await Amplify.Auth.fetchUserAttributes();
  userAttributes.forEach((element) {
    if (element.userAttributeKey.toString() == "custom:usertype") {
      if (element.value == "USER") {
        Get.to(ClientPage(user: user));
      } else if (element.value == "DOCTOR") {
        Get.to(DoctorPage(user: user));
      }
    }
  });
}