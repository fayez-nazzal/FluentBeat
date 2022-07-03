// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:math';
import 'package:fluent_beat/classes/prediction.dart';
import 'package:fluent_beat/classes/revision.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:flutter/material.dart';

import '../pages/client/dashboard/chart_data.dart';

class _User {
  final String id;
  final String name;
  final String user_country;
  final String birth_date;
  final String gender;
  final String email;
  final String join_date;
  Image? image;

  void setImage(Image image) {
    this.image = image;
  }

  _User(
      {this.image,
      required this.id,
      required this.name,
      required this.user_country,
      required this.birth_date,
      required this.gender,
      required this.email,
      required this.join_date});
}

// For Patient UI

class Doctor extends _User {
  Doctor(
      {required id,
      required image,
      required name,
      required user_country,
      required birth_date,
      required gender,
      required email,
      required join_date})
      : super(
          id: id,
          image: image,
          name: name,
          user_country: user_country,
          birth_date: birth_date,
          gender: gender,
          email: email,
          join_date: join_date,
        );

  static Future<Doctor> fromJson(json) async {
    String id = json['id'];
    File? imageFile = await StorageRepository.getImage(id, "jpg");

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/doctor.png");

    return Doctor(
      id: id,
      image: image,
      name: json['name'],
      user_country: json['user_country'],
      birth_date: json['birth_date'],
      gender: json['gender'],
      email: json['email'],
      join_date: json['join_date'],
    );
  }
}

class PatientClient extends _User {
  String? doctor_id;
  Doctor? doctor;

  // the id of the doctor that patient's sent request to ( yes, one doctor only )
  String? request_doctor_id;

  PatientClient(
      {required this.doctor_id,
      this.doctor,
      this.request_doctor_id,
      required id,
      required image,
      required name,
      required user_country,
      required birth_date,
      required gender,
      required email,
      required join_date})
      : super(
          id: id,
          image: image,
          name: name,
          user_country: user_country,
          birth_date: birth_date,
          gender: gender,
          email: email,
          join_date: join_date,
        );

  static Future<PatientClient> fromJson(json) async {
    Doctor? doctor;
    if (json['doctor'] != null) doctor = await Doctor.fromJson(json['doctor']);

    String id = json['id'];
    File? imageFile = await StorageRepository.getImage(id, "jpg");

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/patient.png");

    return PatientClient(
        id: id,
        image: image,
        name: json['name'],
        user_country: json['user_country'],
        birth_date: json['birth_date'],
        gender: json['gender'],
        email: json['email'],
        join_date: json['join_date'],
        doctor_id: json['doctor_id'],
        request_doctor_id: json['request_doctor_id'],
        doctor: doctor);
  }
}

// For Doctor UI
class DoctorClient extends _User {
  List<Patient> patients;
  List<PatientClient> request_patients;

  DoctorClient(
      {required id,
      required image,
      required name,
      required user_country,
      required birth_date,
      required gender,
      required email,
      required join_date,
      required this.patients,
      required this.request_patients})
      : super(
          id: id,
          image: image,
          name: name,
          user_country: user_country,
          birth_date: birth_date,
          gender: gender,
          email: email,
          join_date: join_date,
        );

  static Future<DoctorClient> fromJson(json) async {
    String id = json['id'];
    File? imageFile = await StorageRepository.getImage(id, "jpg");

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/doctor.png");

    List<Patient> patients = [];
    List<PatientClient> requestPatients = [];

    for (var patient in json["patients"]) {
      patients.add(await Patient.fromJson(patient));
    }

    for (var requestPatient in json['request_patients']) {
      requestPatients.add(await PatientClient.fromJson(requestPatient));
    }

    return DoctorClient(
        id: id,
        image: image,
        name: json['name'],
        user_country: json['user_country'],
        birth_date: json['birth_date'],
        gender: json['gender'],
        email: json['email'],
        join_date: json['join_date'],
        patients: patients,
        request_patients: requestPatients);
  }
}

class Patient extends _User {
  final List<Revision> revisions;
  final List<Prediction> predictions;
  Map<int, int> predictionsCounts = {0: 0, 1: 0, 2: 0, 3: 0};
  List<PredictionsSummaryChartData> predictionsSummaryChartData = [];
  List<AverageBPMSummaryChartData> avgBPMSummaryHeartData = [];
  int averageBPMThisWeek = 0;
  int winnerClassThisWeek = -1;
  int winnerClassToday = -1;
  List<num> classCountsThisWeek = [0, 0, 0, 0];
  List<num> classCountsToday = [0, 0, 0, 0];

  Patient(
      {required id,
      required image,
      required name,
      required user_country,
      required birth_date,
      required gender,
      required email,
      required join_date,
      required this.revisions,
      required this.predictions})
      : super(
          id: id,
          image: image,
          name: name,
          user_country: user_country,
          birth_date: birth_date,
          gender: gender,
          email: email,
          join_date: join_date,
        );

  static Future<Patient> fromJson(json) async {
    String id = json['id'];
    File? imageFile = await StorageRepository.getImage(id, "jpg");

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/patient.png");

    // get revisions
    List<Revision> revisions = [];

    for (var revision in json['revisions']) {
      revisions.add(await Revision.fromJson(revision));
    }

    // get predictions
    List<Prediction> predictions = [];

    for (var prediction in json['predictions']) {
      predictions.add(await Prediction.fromJson(prediction));
    }

    return Patient(
        id: id,
        image: image,
        name: json['name'],
        user_country: json['user_country'],
        birth_date: json['birth_date'],
        gender: json['gender'],
        email: json['email'],
        join_date: json['join_date'],
        revisions: revisions,
        predictions: predictions);
  }

  Future getStatistics() async {
    // average of ( average bpm across week )
    double bpmAvgSum = 0;
    int bpmAvgCount = 0;

    for (var statItem in predictions) {
      DateTime date = DateTime.parse(statItem.date);

      // check if date is before 1 week, if so, continue the loop
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
        continue;
      }

      double averageBPM = statItem.bpm_sum / statItem.bpm_count;

      if (averageBPM > 0) {
        bpmAvgSum += averageBPM;
        bpmAvgCount++;
      }

      PredictionsSummaryChartData statPredictionsSummary =
          PredictionsSummaryChartData(
        class_0: statItem.class_0,
        class_1: statItem.class_1,
        class_2: statItem.class_2,
        class_3: statItem.class_3,
        date: date,
      );

      classCountsThisWeek[0] += statItem.class_0;
      classCountsThisWeek[1] += statItem.class_1;
      classCountsThisWeek[2] += statItem.class_2;
      classCountsThisWeek[3] += statItem.class_3;

      predictionsSummaryChartData.add(statPredictionsSummary);

      avgBPMSummaryHeartData.add(AverageBPMSummaryChartData(
          date: date, heartRate: statItem.bpm_sum / statItem.bpm_count));
    }

    // check if all classCounts are zero
    if (classCountsThisWeek.every((element) => element == 0)) {
      winnerClassThisWeek = -1;
    } else {
      num maxClass = classCountsThisWeek.reduce(max);

      winnerClassThisWeek = classCountsThisWeek.indexOf(maxClass);
    }

    // check if bpmAvgSum is zero
    if (bpmAvgSum == 0) {
      averageBPMThisWeek = 0;
    } else {
      averageBPMThisWeek = bpmAvgSum ~/ bpmAvgCount;
    }
  }
}
