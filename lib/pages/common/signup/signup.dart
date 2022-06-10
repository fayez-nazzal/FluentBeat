import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/client/client.dart';
import 'package:fluent_beat/pages/common/signup/AccountInfo.dart';
import 'package:fluent_beat/pages/common/signup/ExtraInfo.dart';
import 'package:fluent_beat/pages/common/signup/toggles.dart';
import 'package:fluent_beat/pages/common/signup/verfication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../widgets/Button/Button.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => SignupState();

  static SignupState? of(BuildContext context) =>
      context.findAncestorStateOfType<SignupState>();
}

class SignupState extends State<Signup> {
  String name = "";
  String username = "";
  String password = "";
  String message = "";
  String confirmPassword = "";
  String verficationCode = "";
  String country = "";
  String userType = "";
  late AuthUser user;
  List<bool> toggleButtonsSelected = [false, false];
  DateTime birthday = DateTime.now();
  String gender = "Male";
  List<String> genders = ["Male", "Female"];
  int currentIndex = 0;
  late List<Widget> pages;

  void checkUser() async {
    try {
      user = await Amplify.Auth.getCurrentUser();

      // if so, push to the client page
      setState(() {
        Get.to(ClientPage(user: user));
      });
    } on AuthException {
      // nothing to do...
    }
  }

  @override
  void initState() {
    super.initState();
  }

  List<Step> getSteps() => [
        Step(
            isActive: currentIndex == 0,
            title: const Text("Account"),
            content: Scrollbar(
              child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    Toggles(
                      toggleButtonsSelected: toggleButtonsSelected,
                    ),
                    AccountInfo(),
                  ]),
            )),
        Step(
            isActive: currentIndex == 1,
            title: const Text("Extra Info"),
            content: Scrollbar(
              child: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [ExtraInfo()]),
            )),
        Step(
            isActive: currentIndex == 2,
            title: const Text("Verify"),
            content:
                Expanded(child: SingleChildScrollView(child: Verfication())))
      ];

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
        const CognitoUserAttributeKey.custom("userType"): userType,
      };

      SignUpResult signupResult = await Amplify.Auth.signUp(
          username: username,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
    } on AuthException catch (e) {
      setState(() {
        message = e.message;

        // print(e);
      });
    }
  }

  Future<void> confirmSignup() async {
    try {
      await Amplify.Auth.confirmSignUp(
          username: username, confirmationCode: verficationCode);
    } on AuthException catch (e) {
      setState(() {
        message = e.message;
      });
    }
  }

  void onStepContinue() async {
    if (currentIndex == 0) {
      // TODO, validate all fields
      print("info");
      print(userType);
      print(name);
      print(username);
      print(password);
      print(confirmPassword);
      signUp();
    } else if (currentIndex == 1) {
      // TODO, just validate attribute
    } else if (currentIndex == 2) {
      // TODO, make sure verification code is provided
      print(verficationCode);
      await confirmSignup();

      // check if user is signed in
      await Amplify.Auth.signIn(username: username, password: password)
          .then((value) async {
        var user = await Amplify.Auth.getCurrentUser();

        var client = http.Client();
        var response = await client.post(
            Uri.parse(
                "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/new_user"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'cognito_id': user.userId,
              'user_type': userType,
              'name': name,
              'email_address': username,
              // birth-date in format YYYY-MM-DD
              'birthday': birthday.toString().substring(0, 10),
              'user_country': country,
              'gender': gender
            }));

        var decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map;

        print(decodedResponse);

        if (response.statusCode == 200)
          setState(() {
            Get.to(ClientPage(user: user));
          });
      }).onError((error, stackTrace) {
        setState(() {
          message = error.toString();
        });
      });
    }

    if (currentIndex < 2) {
      setState(() {
        currentIndex++;
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(image: AssetImage('images/FluentBeat.png')),
                      Expanded(
                        child: Stepper(
                            type: StepperType.horizontal,
                            steps: getSteps(),
                            currentStep: currentIndex,
                            onStepTapped: null,
                            onStepCancel: null,
                            controlsBuilder: (BuildContext context,
                                ControlsDetails details) {
                              return TextButton(
                                  onPressed: details.onStepContinue,
                                  child: Button(
                                      bg: 0xFFff6b6b,
                                      text: "Continue",
                                      onPress: onStepContinue));
                            }),
                      )
                    ],
                  )))),
    );
  }
}
