import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/prediction.dart';
import 'package:fluent_beat/classes/revision.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class DoctorStateController extends GetxController {
  DoctorClient? _doctor;

  final ImagePicker _picker = ImagePicker();
  int _selectedPatient = -1;
  Revision? _currentRevision;

  DoctorClient? get doctor => _doctor;
  int get selectedPatient => _selectedPatient;
  Revision? get currentRevision => _currentRevision;

  void setSelectedPatient(int patientId) {
    _selectedPatient = patientId;
    update();
  }

  void setCurrentRevision(Revision? revision) {
    _currentRevision = revision;
    update();
  }

  void getInfo() async {
    String doctorCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    print("${dotenv.env["API_URL"]}/doctor?doctor_cognito_id=$doctorCognitoId");

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "${dotenv.env["API_URL"]}/doctor?doctor_cognito_id=$doctorCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // print response body
    print(response.body);

    // first, decode the full response body
    if (response.statusCode == 200) {
      var body = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

      _doctor = await DoctorClient.fromJson(body);
    } else {
      print(response.statusCode);
    }

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

    update();
  }
}
