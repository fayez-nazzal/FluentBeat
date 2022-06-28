import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/pages/client/dashboard/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../../../classes/user.dart';
import 'package:http/http.dart' as http;

class PatientStateController extends GetxController {
  Patient? patient;
  Map<int, int> predictions = {0: 0, 1: 0, 2: 0, 3: 0};
  List<PredictionsSummaryChartData> predictionsSummaryChartData = [];
  List<AverageBPMSummaryChartData> avgBPMSummaryHeartData = [];
  int averageBPMThisWeek = 0;
  num winnerClassThisWeek = -1;

  Future getInfo() async {
    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "${dotenv.env["API_URL"]}/patient_info?patient_cognito_id=$patientCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response body
    // for this request, this will be done automatically, as we are using lambda proxy integration
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    // TODO handle errors

    // last, get the patient from the body, this will result into a Pateint
    patient = await Patient.fromJson(decodedResponse);

    update();

    getStatistics();
  }

  Future getStatistics() async {
    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "${dotenv.env["API_URL"]}/get_statistics?user_id=$patientCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    // average of ( average bpm across week )
    double bpmAvgSum = 0;
    int bpmAvgCount = 0;
    List<num> classCounts = [0, 0, 0, 0];

    for (var statItem in decodedResponse) {
      DateTime date = DateTime.parse(statItem['date']);

      // check if date is before 1 week, if so, continue the loop
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
        continue;
      }

      statItem['class_0'] =
          statItem['class_0'] == null ? 0 : int.parse(statItem['class_0']);
      statItem['class_1'] =
          statItem['class_1'] == null ? 0 : int.parse(statItem['class_1']);
      statItem['class_2'] =
          statItem['class_2'] == null ? 0 : int.parse(statItem['class_2']);
      statItem['class_3'] =
          statItem['class_3'] == null ? 0 : int.parse(statItem['class_3']);
      statItem['bpm_sum'] =
          statItem['bpm_sum'] == null ? 0 : int.parse(statItem['bpm_sum']);
      statItem['bpm_count'] =
          statItem['bpm_count'] == null ? 0 : int.parse(statItem['bpm_count']);

      double averageBPM = statItem['bpm_sum'] / statItem['bpm_count'];

      if (averageBPM > 0) {
        bpmAvgSum += averageBPM;
        bpmAvgCount++;
      }

      PredictionsSummaryChartData statPredictionsSummary =
          PredictionsSummaryChartData(
        class_0: statItem['class_0'],
        class_1: statItem['class_1'],
        class_2: statItem['class_2'],
        class_3: statItem['class_3'],
        date: date,
      );

      classCounts[0] += statItem['class_0'];
      classCounts[1] += statItem['class_1'];
      classCounts[2] += statItem['class_2'];
      classCounts[3] += statItem['class_3'];

      predictionsSummaryChartData.add(statPredictionsSummary);

      avgBPMSummaryHeartData.add(AverageBPMSummaryChartData(
          date: date, heartRate: statItem['bpm_sum'] / statItem['bpm_count']));
    }

    // check if all classCounts are zero
    if (classCounts.every((element) => element == 0)) {
      winnerClassThisWeek = -1;
    } else {
      num maxClass = classCounts.reduce(max);

      winnerClassThisWeek = classCounts.indexOf(maxClass);
    }

    // check if bpmAvgSum is zero
    if (bpmAvgSum == 0) {
      averageBPMThisWeek = 0;
    } else {
      averageBPMThisWeek = bpmAvgSum ~/ bpmAvgCount;
    }
    update();
  }
}
