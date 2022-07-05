// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:fluent_beat/pages/client/state/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app.dart';
import '../../../ui/button.dart';
import '../../../utils.dart';
import '../state/patient.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String username = "";
  String password = "";

  File? imageFile;

  static ClientConnectionController get clientConnection => Get.find();

  void signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      showErrorDialog("Unable to sign out.", context);
    }

    // reset app
    Get.to(() => const App());
  }

  void checkProfileImage() async {
    var user = await Amplify.Auth.getCurrentUser();
    File? file = await StorageRepository.getImage(user.userId, "jpg");

    if (file != null) {
      setState(() {
        imageFile = file;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkProfileImage();
  }

  void refreshBluetoothConnection() async {
    clientConnection.refreshConnection();
  }

  void updatePatient(PatientStateController patientState) {
    patientState.nullifyPatient();
    patientState.getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientStateController>(
        builder: (patientState) => patientState.patient == null
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
                            child: patientState.patient!.image,
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
                                onPressed: patientState.pickImage),
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
                              onPressed: () => updatePatient(patientState),
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
                                Text(patientState.patient!.name,
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
                                Text("${patientState.patient!.email}com",
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
                                Text("${patientState.patient!.birth_date}com",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: GetBuilder<ClientConnectionController>(
                          builder: (_) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                !(_.connection?.isConnected ?? false)
                                    ? Icons.bluetooth_disabled
                                    : Icons.bluetooth_connected,
                                color: _.connection?.isConnected ?? false
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const Padding(padding: EdgeInsets.only(right: 6)),
                              Text(
                                _.connection?.isConnected ?? false
                                    ? "ECG device connected"
                                    : "ECG device not connected",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color:
                                        (!(_.connection?.isConnected ?? false))
                                            ? Colors.red
                                            : Colors.blue),
                              ),
                            ],
                          ),
                        )),
                    ElevatedButton(
                        onPressed: refreshBluetoothConnection,
                        child: const Text("Refresh Bluetooth Connection")),
                    Button(bg: 0xffffffff, text: "Sign Out", onPress: signOut),
                  ],
                ),
              ));
  }
}
