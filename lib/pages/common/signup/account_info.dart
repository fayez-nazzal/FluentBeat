import 'package:fluent_beat/pages/common/signup/signup.dart';
import 'package:flutter/material.dart';
import '../../../ui/input.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({Key? key}) : super(key: key);

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Account Credentials",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 16),
        Input(
            onChange: (txt) {
              SignupPage.of(context)!.name = txt.trim();
            },
            labelText: "Name"),
        Input(
            onChange: (txt) {
              SignupPage.of(context)!.username = txt.trim();
            },
            labelText: "Email"),
        Input(
          onChange: (txt) {
            SignupPage.of(context)!.password = txt;
          },
          labelText: "Password",
          password: true,
        ),
        Input(
          onChange: (txt) {
            SignupPage.of(context)!.confirmPassword = txt;
          },
          labelText: "Confirm Password",
          password: true,
        ),
      ],
    );
  }
}
