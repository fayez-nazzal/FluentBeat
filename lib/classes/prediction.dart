// ignore_for_file: non_constant_identifier_names
import 'package:fluent_beat/classes/comment.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Prediction {
  final String date;
  final int bpm_count;
  final int bpm_sum;
  final Image? image;
  final int class_0;
  final int class_1;
  final int class_2;
  final int class_3;

  const Prediction(
      {required this.date,
      required this.bpm_count,
      required this.bpm_sum,
      required this.class_0,
      required this.class_1,
      required this.class_2,
      required this.class_3,
      required this.image});

  String getDaysAgo() {
    return timeago.format(DateTime.parse(date));
  }

  static Future<Prediction> fromJson(json) async {
    return Prediction(
        date: json['date'],
        bpm_count: int.parse(json['bpm_count'] ?? "0"),
        bpm_sum: int.parse(json['bpm_sum'] ?? "0"),
        class_0: int.parse(json['class_0'] ?? "0"),
        class_1: int.parse(json['class_1'] ?? "0"),
        class_2: int.parse(json['class_2'] ?? "0"),
        class_3: int.parse(json['class_3'] ?? "0"),
        image: null);
  }
}
