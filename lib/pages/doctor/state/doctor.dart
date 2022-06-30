import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DoctorStateController extends GetxController {
  Doctor? _doctor;
  List<Patient> _patients = [];
  final ImagePicker _picker = ImagePicker();

  Doctor? get doctor => _doctor;
  List<Patient> get patients => _patients;

  void setDoctor(Doctor? doctor) {
    _doctor = doctor;
    update();
  }

  void setPatients(List<Patient> patients) {
    _patients = patients;
    update();
  }

  void pickImage() async {
    var pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var user = await Amplify.Auth.getCurrentUser();

      File? file = await StorageRepository.uploadProfileImage(
          File(pickedFile.path), user.userId);

      if (file != null) {
        Image image = Image.file(file);

        doctor!.setImage(image);
      }
    }
  }
}
