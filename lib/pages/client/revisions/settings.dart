import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/Button/Button.dart';
import '../../common/login/login.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  void signOut() async {
    await Amplify.Auth.signOut();

    Get.to(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Button(bg: 0xffffffff, text: "Sign Out", onPress: signOut));
  }
}
