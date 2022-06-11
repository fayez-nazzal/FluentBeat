import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/monitor/LiveData.dart';
import 'package:fluent_beat/pages/client/state/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../widgets/Button/Button.dart';

class ClientMonitor extends StatefulWidget {
  final AuthUser user;

  const ClientMonitor({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientMonitor> createState() => _ClientMonitorState();
}

class _ClientMonitorState extends State<ClientMonitor> {
  List<double> normBuffer = <double>[];
  List<double> bpmBuffer = <double>[];
  int heartrate = 0;
  String bufferStr = "";
  List<LiveData> chartData = <LiveData>[];
  List<LiveData> appendData = <LiveData>[];
  ChartSeriesController? _chartSeriesController;
  final int chartLimit = 100;
  late int time;
  Timer? timer;
  Timer? bpmTimer;
  Timer? sampleTimer;
  double normBufferMax = -1;
  int samplesPassed = 0;

  // samples will be sent every ( 1.5 * this variable  ) seconds
  final int sampleDelayMultiplier = 1;
  bool callingReq = false;

  Map<String, int> predictions = {};

  // for normalizing data
  int xMin = 250;
  int xMax = 650;

  String winnerClass = "";
  String warning = "";

  bool isRecording = false;
  int recordingCountdown = 0;

  static ClientConnectionController get clientConnection => Get.find();

  @override
  void initState() {
    super.initState();

    setState(() {
      for (int i = 0; i < chartLimit; i++) {
        chartData.add(LiveData(i, 0));
      }
    });

    time = chartData.length;
    bpmTimer = Timer.periodic(const Duration(seconds: 1), _updateBPM);
    sampleTimer = Timer.periodic(const Duration(seconds: 5), _attemptPredict);

    _attemptConnect(null);
    Timer.periodic(const Duration(seconds: 12), _attemptConnect);
  }

  int secs = 0;

  void _updateBPM(Timer timer) {
    int bpm = 0;
    double bpmBufferMax = -1;

    if (bpmBuffer.length >= 740) {
      for (var element in bpmBuffer) {
        if (element > bpmBufferMax) {
          bpmBufferMax = element;
        }
      }

      // get the bpm from the array
      bool reachedHighRecently = false;

      for (var element in bpmBuffer) {
        if (!reachedHighRecently &&
            element >= bpmBufferMax - 0.2 &&
            element <= bpmBufferMax + 0.2) {
          bpm += 1;
          reachedHighRecently = true;
        }

        if (element < bpmBufferMax - 0.3) {
          reachedHighRecently = false;
        }
      }

      print(bpm * 10);

      bpmBuffer = [];

      setState(() {
        heartrate = bpm * 10;
      });
    }
  }

  void _attemptPredict(Timer timer) async {
    if (normBuffer.length < 187) return;
    if (heartrate < 20) return;
    if (callingReq) return;

    // TODO REMOVE THIS LINE
    return;

    callingReq = true;

    http.Response response = await http.post(
      Uri.parse(
          "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/invoke_sklearn"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'data': normBuffer.sublist(0, 187),
        'user_id': widget.user.userId,
        'bpm': heartrate,
        'date': DateFormat.yMd().format(DateTime.now())
      }),
    );

    normBuffer = [];

    if (response.statusCode == 200) {
      if (predictions.containsKey(response.body)) {
        predictions.update(response.body, (value) => value + 1);
      } else {
        predictions[response.body] = 1;
      }
    } else {
      print("ERROR, status");
      print(response.statusCode);
    }

    int maxValue = -1;
    String maxKey = "";

    predictions.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    });

    setState(() {
      winnerClass = maxKey;
    });

    callingReq = false;
  }

  void _attemptConnect(Timer? timer) async {
    // if is connected, return
    if (clientConnection.connection?.isConnected ?? false) {
      print("connected, ignoring...");
      return;
    }

    try {
      await clientConnection.tryConnection();

      print("To address");

      // if we get there, should be connected
      timer =
          Timer.periodic(const Duration(milliseconds: 9), _updateDataSource);

      appendData = [];

      clientConnection.connection?.input!.listen((Uint8List data) {
        // clientConnection.connection!.output.add(data);

        if (clientConnection.shouldDisconnect) {
          clientConnection.connection!.finish();
          clientConnection.shouldDisconnect = false;

          return;
        }

        String decodedData = ascii.decode(data);

        RegExp digitExp = RegExp(r'(\d)');

        decodedData.split("").forEach((element) async {
          if (bufferStr.length > 2 &&
              bufferStr.endsWith("E") &&
              bufferStr.startsWith("E")) {
            String data = bufferStr.substring(1, bufferStr.length - 1);

            // if those condition are met, movement may be hapened
            // so throw the samples..next samples might be better
            if (data.contains("!") || int.parse(data) == 0) {
              normBuffer = [];
              bpmBuffer = [];
              appendData = [];
              bufferStr = "E";
              print("received bad sample");

              setState(() {
                warning =
                    "Body movement or incorrect sensor placement is detected, adjust your position for a proper measurement";
              });

              return;
            } else {
              setState(() {
                warning = "";
              });
              int x = int.parse(data);

              samplesPassed++;

              // if 1000 samples passed ( 8 seconds, we cn update min max )
              if (samplesPassed >= 1000) {
                if (x > xMax && x < 900)
                  xMax = x;
                else if (x < xMin && x > 0) xMin = x;

                samplesPassed = 1;
              }

              double normX = (x - xMin) / (xMax - xMin);
              time += 1;

              if (appendData.length < 10) {
                LiveData liveData = LiveData(time, normX);
                appendData.add(liveData);
              }

              // for bpm measurement
              bpmBuffer.add(normX);

              // for prediction
              normBuffer.add(normX);

              bufferStr = "E";
            }
          }

          if (element == "E" || digitExp.hasMatch(element)) {
            bufferStr += element;
          }
        });
      });
    } catch (exception) {}

    setState(() {});
  }

  void _updateDataSource(Timer timer) {
    if (appendData.isEmpty) return;
    chartData.add(appendData[0]);
    chartData.removeAt(0);
    appendData.removeAt(0);

    _chartSeriesController?.updateDataSource(
      addedDataIndex: chartData.length - 1,
      removedDataIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Heart"),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.chat_bubble_rounded)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitPumpingHeart(
                  color: const Color(0xffF9595F),
                  size: 24,
                  duration: heartrate > 120
                      ? const Duration(milliseconds: 300)
                      : heartrate > 100
                          ? const Duration(milliseconds: 500)
                          : heartrate > 90
                              ? const Duration(milliseconds: 600)
                              : heartrate > 80
                                  ? const Duration(milliseconds: 700)
                                  : heartrate > 70
                                      ? const Duration(milliseconds: 880)
                                      : heartrate > 0
                                          ? const Duration(milliseconds: 1000)
                                          : const Duration(days: 100),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${heartrate > 0 ? heartrate : "~"} BPM"),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const Text("ECG Signal",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SfCartesianChart(
                  plotAreaBackgroundColor: isRecording
                      ? const Color(0x33CAD7D7)
                      : const Color(0xaafafafa),
                  series: [
                    FastLineSeries<LiveData, int>(
                        color: const Color(0xff52A1BC),
                        onRendererCreated: (ChartSeriesController controller) {
                          // Assigning the controller to the _chartSeriesController.
                          _chartSeriesController = controller;
                        },
                        // Binding the chartData to the dataSource of the line series.
                        dataSource: chartData,
                        xValueMapper: (LiveData liveData, _) => liveData.x,
                        yValueMapper: (LiveData liveData, _) => liveData.y,
                        animationDuration: 8),
                  ],
                  enableAxisAnimation: true,
                  primaryYAxis: NumericAxis(
                    minimum: 0.000,
                    maximum: 1.000,
                  ),
                  primaryXAxis: NumericAxis(isVisible: false),
                ),
              ],
            ),
          ),
          if (predictions[winnerClass] != null)
            Text("winner is $winnerClass for ${predictions[winnerClass]!}"),
          Text(warning),
          Button(
              bg: 0xFFff6b6b,
              text: isRecording
                  ? "Recording $recordingCountdown/60 (Stop)"
                  : "Record for Revision",
              onPress: () {
                setState(() {
                  isRecording = !isRecording;

                  if (isRecording) {
                    recordingCountdown = 60;

                    Timer.periodic(const Duration(seconds: 1), (timer) {
                      setState(() {
                        recordingCountdown -= 1;

                        if (recordingCountdown <= 0 || !isRecording) {
                          timer.cancel();
                          isRecording = false;
                          recordingCountdown = 0;
                        }
                      });
                    });
                  }
                });
              }),
        ],
      ),
    );
  }
}
