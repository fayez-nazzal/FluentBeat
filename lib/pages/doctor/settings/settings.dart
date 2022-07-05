// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../app.dart';
import '../../../ui/button.dart';
import '../../../utils.dart';

class DoctorSettings extends StatefulWidget {
  const DoctorSettings({Key? key}) : super(key: key);

  @override
  State<DoctorSettings> createState() => _DoctorSettingsState();
}

class _DoctorSettingsState extends State<DoctorSettings> {
  void signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      showErrorDialog("Unable to sign out.", context);
    }

    // reset app
    Get.to(() => const App());
  }

  @override
  void initState() {
    super.initState();
  }

  void updateDoctor(DoctorStateController doctorState) {
    doctorState.nullifyDoctor();
    doctorState.getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorStateController>(
        builder: (doctorState) => doctorState.doctor == null
            ? const SpinKitWave(
                color: Color(0xFFff6b6b),
                size: 50.0,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(32), // Image border
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
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Profile Info",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: IconButton(
                              onPressed: () => updateDoctor(doctorState),
                              icon: const Icon(Icons.refresh)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // show user info in list view
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Name",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text(doctorState.doctor!.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Email",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text("${doctorState.doctor!.email}com",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("User Type",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text("DOCTOR",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Birth Date",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text("${doctorState.doctor!.birth_date}com",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Button(bg: 0xffffffff, text: "Sign Out", onPress: signOut),
                  ],
                ),
              ));
  }
}
