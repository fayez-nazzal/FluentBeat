// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:flutter/material.dart';

class _User {
  final String id;
  final String name;
  final String user_country;
  final String birth_date;
  final String gender;
  final String email;
  final String join_date;
  final Image? image;

  const _User(
      {required this.image,
      required this.id,
      required this.name,
      required this.user_country,
      required this.birth_date,
      required this.gender,
      required this.email,
      required this.join_date});
}

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

class Patient extends _User {
  String? doctor_id;
  Doctor? doctor;

  // the id of the doctor that patient's sent request to ( yes, one doctor only )
  String? request_doctor_id;

  Patient(
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

  static Future<Patient> fromJson(json) async {
    Doctor? doctor;
    if (json['doctor'] != null) doctor = await Doctor.fromJson(json['doctor']);

    String id = json['id'];
    File? imageFile = await StorageRepository.getImage(id, "jpg");

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/patient.png");

    return Patient(
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
