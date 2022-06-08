import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/common/signup/signup.dart';
import 'package:flutter/material.dart';

import '../../../widgets/Button/Button.dart';
import '../../../widgets/Input/Input.dart';

class Verfication extends StatefulWidget {
  const Verfication({Key? key}) : super(key: key);

  @override
  State<Verfication> createState() => _VerficationState();
}

class _VerficationState extends State<Verfication> {
  @override
  Widget build(BuildContext context) {
    String message = Signup.of(context)!.message;
    String username = Signup.of(context)!.username;

    void resendVerficationCode() async {
      try {
        await Amplify.Auth.resendSignUpCode(username: username);
      } on AuthException catch (e) {
        setState(() {
          message = e.message;
        });
      }
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Please, check your Email for the verification code.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Input(
            onChange: (txt) {
              setState(() {
                Signup.of(context)!.verficationCode = txt.trim();
              });
            },
            labelText: "Verfication Code"),
        Button(
            bg: 0xffffffff,
            text: "Resend Code",
            onPrimary: 0xffff7f7f,
            onPress: resendVerficationCode),
      ],
    );
  }
}
