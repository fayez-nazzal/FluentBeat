import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/monitor/LiveData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class ClientMonitor extends StatefulWidget {
  final AuthUser user;

  const ClientMonitor({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientMonitor> createState() => _ClientMonitorState();
}

class _ClientMonitorState extends State<ClientMonitor> {
  List<double> normBuffer = <double>[];
  List<double> bpmBuffer = <double>[];
  double bpmBufferMax = -1;
  int normBufferIndex = 0;
  int heartrate = 0;
  String bufferStr = "";
  String normStr = "";
  bool isTakingSample = false;
  List<LiveData> chartData = <LiveData>[];
  List<LiveData> appendData = <LiveData>[];
  Timer? timer;
  Timer? bpmTimer;
  ChartSeriesController? _chartSeriesController;
  final int chartLimit = 100;
  late int time;
  bool exitConnection = false;
  bool connected = false;
  bool error = false;
  final int connectionCountdownMax = 12;
  int connectionCountdown = 0;

  // samples will be sent every ( 1.5 * this variable  ) seconds
  final int sampleDelayMultiplier = 1;
  bool callingReq = false;

  Map<String, int> predictions = {};

  // for normalizing data
  final int xMin = 250;
  final int xMax = 650;

  String winnerClass = "";

  String warning = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      for (int i = 0; i < chartLimit; i++) {
        chartData.add(LiveData(i, 0));
      }
    });

    time = chartData.length;
    timer = Timer.periodic(const Duration(milliseconds: 10), _updateDataSource);
    bpmTimer = Timer.periodic(const Duration(seconds: 1), _updateBPM);
    bpmTimer = Timer.periodic(const Duration(seconds: 5), _attemptPredict);
  }

  int secs = 0;

  void _updateBPM(Timer timer) {
    int bpm = 0;
    print('length ${bpmBuffer.length}');

    if (bpmBuffer.isNotEmpty) print('seconds ${secs++}');

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

  void _updateConnectionCountdown(Timer timer) {
    setState(() {
      if (exitConnection || connectionCountdown <= 0 || connected) {
        connectionCountdown = 0;
        timer.cancel();
      }

      if (exitConnection) {
        connectionCountdown = 0;
        connected = false;
        exitConnection = false;
      } else if (connectionCountdown > 0) {
        connectionCountdown -= 1;
      } else {
        if (!connected) error = true;
      }
    });
  }

  void _connectToECGDevice() async {
    setState(() {
      exitConnection = false;
      connectionCountdown = connectionCountdownMax;
      connected = false;
      error = false;
      Timer.periodic(const Duration(seconds: 1), _updateConnectionCountdown);
    });

    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress('00:14:03:05:59:9C');
      // print('Connected to the device');

      connection.input?.listen((Uint8List data) {
        if (exitConnection) {
          connected = false;
          connection.finish();
          exitConnection = false;
        } else {
          error = false;
          connected = true;
          connectionCountdown = 0;

          connection.output.add(data); // Sending data

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

                warning =
                    "Body movement or incorrect sensor placement is detected, adjust your position for a proper measurement";

                return;
              } else {
                warning = "";
                int x = int.parse(data);
                double normX = (x - xMin) / (xMax - xMin);
                LiveData liveData = LiveData(time, normX);
                time += 1;

                appendData.add(liveData);

                // for bpm measurement
                bpmBuffer.add(normX);

                // for prediction
                normBuffer.add(normX);

                bufferStr = "E";
              }
            }

            if (element == "E") {
              isTakingSample = false;
            }

            if (element == "E" || digitExp.hasMatch(element)) {
              bufferStr += element;
            }
          });
        }
      }).onDone(() {
        // print('Disconnected by remote request');
      });
    } catch (exception) {
      connected = false;
      error = true;
    }
  }

  void disconnectDevice() {
    setState(() {
      exitConnection = true;
      error = false;
      connected = false;
    });
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: _connectToECGDevice,
                    child: const Text("Connect to ECG device")),
                ElevatedButton(
                    onPressed: disconnectDevice,
                    child: const Text("Disconnect"))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  error
                      ? Icons.error
                      : connectionCountdown > 0
                          ? Icons.bluetooth
                          : !connected
                              ? Icons.bluetooth_disabled
                              : Icons.bluetooth_connected,
                  color: connectionCountdown > 0
                      ? Colors.blue
                      : connected
                          ? Colors.green
                          : Colors.red,
                ),
                const Padding(padding: EdgeInsets.only(right: 6)),
                Text(
                  error
                      ? "Can't connect to the ECG device."
                      : connectionCountdown > 0 && !connected && !exitConnection
                          ? "Connectoing to the ECG device ($connectionCountdown)..."
                          : connected
                              ? "ECG device connected"
                              : "ECG device not connected",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: error || (!connected && connectionCountdown == 0)
                          ? Colors.red
                          : Colors.blue),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 52),
            child: SfCartesianChart(
              series: [
                FastLineSeries<LiveData, int>(
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
          ),
          if (predictions[winnerClass] != null)
            Text("winner is $winnerClass for ${predictions[winnerClass]!}"),
          Text("bpm is $heartrate"),
          Text("Max normBuff $bpmBufferMax"),
          Text(warning)
        ],
      ),
    );
  }
}
