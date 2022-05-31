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
  double normBufferMax = -1;
  int normBufferIndex = 0;
  int renderedBPM = 0;
  String bufferStr = "";
  String normStr = "";
  bool isTakingSample = false;
  List<LiveData> chartData = <LiveData>[];
  List<LiveData> appendData = <LiveData>[];
  Timer? timer;
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
  int currentSampleIndex = 0;
  bool callingReq = false;

  Map<String, int> predictions = {};

  // for normalizing data
  final int xMin = 200;
  final int xMax = 880;

  String winnerClass = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      for (int i = 0; i < chartLimit; i++) {
        chartData.add(LiveData(i, 0));
      }
    });

    time = chartData.length;
    timer = Timer.periodic(const Duration(milliseconds: 8), _updateDataSource);
  }

  int _getBPM(List<double> prevNormBuffer) {
    int bpm = 0;

    // get max in prevNormBuffer
    for (var element in prevNormBuffer) {
      if (element > normBufferMax) {
        normBufferMax = element;
      }
    }

    bpmBuffer = [...bpmBuffer, ...prevNormBuffer];

    // 7500 = 60 seconds ( 1 minute ) to get bpm per minute
    if (bpmBuffer.length >= 750) {
      // get the bpm from the array
      bool reachedHighRecently = false;
      print("max buffer");

      for (var element in bpmBuffer) {
        if (!reachedHighRecently &&
            element >= normBufferMax - 0.03 &&
            element <= normBufferMax + 0.06) {
          bpm += 1;
          reachedHighRecently = true;
        }

        if (element < normBufferMax - 0.3) {
          reachedHighRecently = false;
        }
      }

      bpm = bpm * 10;

      if (bpm < 25 || bpm > 300) {
        print(bpm);
        bpm = 0;
        bpmBuffer = [];

        throw Exception('Movement Or silent detected');
      }

      bpmBuffer = [];
    }

    return bpm;
  }

  void _sendSample(List<double> normBufferClone) async {
    if (callingReq) {
      currentSampleIndex += 1;
      return;
    }

    if (currentSampleIndex >= sampleDelayMultiplier) {
      late int bpm;

      try {
        // get bpm for this normBuffer..
        bpm = _getBPM(normBufferClone);
      } catch (e) {
        normBuffer = [];
        print(e);
        return;
      }

      callingReq = true;
      http.Response response = await http.post(
        Uri.parse(
            "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/invoke_sklearn"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'data': normBufferClone,
          'user_id': widget.user.userId,
          'bpm': bpm,
          'date': DateFormat.yMd().format(DateTime.now())
        }),
      );

      if (response.statusCode == 200) {
        if (predictions.containsKey(response.body)) {
          predictions.update(response.body, (value) => value + 1);
        } else {
          predictions[response.body] = 1;

          // if not class4, update bpm
          if (response.body.toString() != "4") {
            setState(() {
              renderedBPM = bpm;
            });
          }
        }

        // print("body $response.body");
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

      winnerClass = maxKey;
      callingReq = false;
    }

    predictions.forEach((key, value) {
      // print("for class $key value is $value");
    });

    if (currentSampleIndex >= sampleDelayMultiplier) {
      currentSampleIndex = 0;
    } else {
      currentSampleIndex += 1;
      // print("sampleIndex+");
    }
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

          if (decodedData.contains('!')) {
            // movement
            // print('Device not placed properly');
          } else if (decodedData.contains('disconnect')) {}

          RegExp digitExp = RegExp(r'(\d)');

          decodedData.split("").forEach((element) async {
            if (isTakingSample &&
                bufferStr.length > 2 &&
                bufferStr.startsWith("S") &&
                bufferStr.endsWith("S")) {
              int x = int.parse(bufferStr.substring(1, bufferStr.length - 1));

              double normX = (x - xMin) / (xMax - xMin);
              LiveData liveData = LiveData(time, normX);
              time += 1;

              appendData.add(liveData);

              normBuffer.add(normX);

              // if norm buffer is full, send request to the endpoint and clear
              if (normBuffer.length == 187) {
                setState(() {
                  isTakingSample = false;
                  bufferStr = "";
                });

                _sendSample([...normBuffer]);

                currentSampleIndex += 1;
                normBuffer.clear();
              }

              bufferStr = "S";
            } else if (bufferStr.length > 2 &&
                bufferStr.endsWith("E") &&
                bufferStr.startsWith("E")) {
              int x = int.parse(bufferStr.substring(1, bufferStr.length - 1));
              double normX = (x - xMin) / (xMax - xMin);
              LiveData liveData = LiveData(time, normX);
              time += 1;

              appendData.add(liveData);

              bufferStr = "E";
            }

            if (element == "E") {
              isTakingSample = false;
            }

            if (element == "E" ||
                element == "S" ||
                digitExp.hasMatch(element)) {
              bufferStr += element;
            }

            if (element == "N") {
              isTakingSample = !isTakingSample;
              bufferStr = "";
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
          Text("bpm is $renderedBPM"),
          Text("Length of bpm buffer ${bpmBuffer.length}"),
          Text("Max normBuff $normBufferMax")
        ],
      ),
    );
  }
}
