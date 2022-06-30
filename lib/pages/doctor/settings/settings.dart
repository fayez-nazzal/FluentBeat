// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app.dart';
import '../../../ui/button.dart';
import '../../../ui/input.dart';
import '../../../utils.dart';

class DoctorSettings extends StatefulWidget {
  const DoctorSettings({Key? key}) : super(key: key);

  @override
  State<DoctorSettings> createState() => _DoctorSettingsState();
}

class _DoctorSettingsState extends State<DoctorSettings> {
  String username = "";
  String password = "";
  // static DoctorStateController get doctorState => Get.find();

  void signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      showErrorDialog("Unable to sign out.", context);
    }

    // reset app
    Get.to(const App());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorStateController>(
        init: DoctorStateController(), // INIT IT ONLY THE FIRST TIME
        builder: (doctorState) => doctorState.doctor == null
            ? Container()
            : Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32), // Image border
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(80), // Image radius
                          child: doctorState.doctor!.image,
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white60,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFff6b6b),
                              ),
                              onPressed: doctorState.pickImage),
                        ),
                      ),
                    ],
                  ),
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
                  Button(bg: 0xffffffff, text: "Sign Out", onPress: signOut),
                ],
              ));
  }
}
