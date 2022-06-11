import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/storage.dart';
import 'package:fluent_beat/pages/client/state/connection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/Button/Button.dart';
import '../../../widgets/Input/Input.dart';
import '../../common/login/login.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String username = "";
  String password = "";

  File? imageFile;
  final ImagePicker imagePicker = ImagePicker();

  static ClientConnectionController get clientConnection => Get.find();

  void signOut() async {
    await Amplify.Auth.signOut();

    Get.to(LoginPage());
  }

  void checkProfileImage() async {
    var user = await Amplify.Auth.getCurrentUser();
    File? file = await StorageRepository.getProfileImage(user.userId);

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

  Widget ImageProfile() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32), // Image border
          child: SizedBox.fromSize(
            size: Size.fromRadius(80), // Image radius
            child: imageFile == null
                ? Image.asset('images/heart.jpg', fit: BoxFit.cover)
                : Image.file(imageFile!, fit: BoxFit.cover),
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
              onPressed: () async {
                var pickedFile =
                    await imagePicker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  var user = await Amplify.Auth.getCurrentUser();

                  File file = await StorageRepository.uploadProfileImage(
                      File(pickedFile.path), user.userId);

                  setState(() {
                    imageFile = file;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void refreshBluetoothConnection() async {
    clientConnection.refreshConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageProfile(),
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
        Button(
            bg: 0xffffffff,
            text: "Refresh Bluetooth Connection",
            onPress: refreshBluetoothConnection),
      ],
    );
  }
}
