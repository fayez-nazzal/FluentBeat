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
  int winnerClassThisWeek = -1;
  int winnerClassToday = -1;
  List<num> classCountsThisWeek = [0, 0, 0, 0];
  List<num> classCountsToday = [0, 0, 0, 0];

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

      classCountsThisWeek[0] += statItem['class_0'];
      classCountsThisWeek[1] += statItem['class_1'];
      classCountsThisWeek[2] += statItem['class_2'];
      classCountsThisWeek[3] += statItem['class_3'];

      predictionsSummaryChartData.add(statPredictionsSummary);

      avgBPMSummaryHeartData.add(AverageBPMSummaryChartData(
          date: date, heartRate: statItem['bpm_sum'] / statItem['bpm_count']));
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

    update();
  }

  void updateWinnerClass(int classIndex) {
    if (classIndex == -1) return;

    classCountsToday[classIndex]++;
    classCountsThisWeek[classIndex]++;

    int updateWinner(int winner, List<num> classCounts) {
      if (winner == -1) {
        winner = classIndex;
      } else {
        num maxClass = classCounts.reduce(max);

        winner = classCounts.indexOf(maxClass);
      }

      return winner;
    }

    winnerClassToday = updateWinner(winnerClassToday, classCountsToday);

    winnerClassThisWeek = updateWinner(winnerClassToday, classCountsThisWeek);

    update();
  }
}
