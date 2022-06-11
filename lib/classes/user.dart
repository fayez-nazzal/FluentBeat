// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String user_country;
  final String birth_date;
  final String gender;
  final String email;
  final String join_date;
  final Image? image;

  const User(
      {required this.image,
      required this.id,
      required this.name,
      required this.user_country,
      required this.birth_date,
      required this.gender,
      required this.email,
      required this.join_date});

  static Future<User> fromJson(json) async {
    String id = json['id'];
    File? imageFile = await StorageRepository.getProfileImage(id);

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/heart.jpg");

    return User(
        id: id,
        image: image,
        name: json['name'],
        user_country: json['user_country'],
        birth_date: json['birth_date'],
        gender: json['gender'],
        email: json['email'],
        join_date: json['join_date']);
  }
}

class Patient extends User {
  final String? request_doctor_id;
  String? doctor_id;
  User? doctor;

  Patient(
      {required this.request_doctor_id,
      required this.doctor_id,
      this.doctor,
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
    User doctor = await User.fromJson(json['doctor']);

    String id = json['id'];
    File? imageFile = await StorageRepository.getProfileImage(id);

    Image image = imageFile != null
        ? Image.file(imageFile)
        : Image.asset("images/heart.jpg");

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
