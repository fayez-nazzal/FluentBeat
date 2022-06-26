import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/classes/live_data.dart';
import 'package:fluent_beat/pages/client/monitor/ecg_connected.dart';
import 'package:fluent_beat/pages/client/monitor/ecg_disconnected.dart';
import 'package:fluent_beat/pages/client/state/connection.dart';
import 'package:fluent_beat/pages/client/state/ecg_buffer.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:fluent_beat/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../ui/button.dart';

class ClientMonitor extends StatefulWidget {
  final AuthUser user;

  const ClientMonitor({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientMonitor> createState() => _ClientMonitorState();
}

class _ClientMonitorState extends State<ClientMonitor> {
  List<double> normBuffer = <double>[];
  List<double> bpmBuffer = <double>[];
  List<double> revisionBuffer = <double>[];
  int heartrate = 0;

  List<LiveData> chartData = <LiveData>[];
  List<LiveData> appendData = <LiveData>[];
  ChartSeriesController? _chartSeriesController;
  final int chartLimit = 100;
  late int time;
  Timer? timer;
  Timer? sampleTimer;
  double normBufferMax = -1;
  int samplesPassed = 0;

  // samples will be sent every ( 1.5 * this variable  ) seconds
  final int sampleDelayMultiplier = 1;
  bool callingReq = false;

  Map<String, int> predictions = {};

  // for normalizing data
  int xMin = 200;
  int xMax = 680;

  bool isRecording = false;
  int recordingCountdown = 0;

  static ClientConnectionController get clientConnection => Get.find();

  static ECGBufferController get ecgBufferState => Get.find();

  @override
  void initState() {
    super.initState();

    setState(() {
      for (int i = 0; i < chartLimit; i++) {
        chartData.add(LiveData(i, 0));
      }
    });

    time = chartData.length;

    _attemptConnect(null);
    Timer.periodic(const Duration(seconds: 12), _attemptConnect);
  }

  void _attemptConnect(Timer? timer) async {
    // if is connected, return
    if (clientConnection.connection?.isConnected ?? false) {
      return;
    }

    try {
      await clientConnection.tryConnection();

      appendData = [];

      clientConnection.connection?.input!.listen(onBluetoothListen);
    } catch (exception) {}
  }

  void onBluetoothListen(Uint8List data) {
    // clientConnection.connection!.output.add(data);

    if (clientConnection.shouldDisconnect) {
      clientConnection.connection!.finish();
      clientConnection.shouldDisconnect = false;

      return;
    }

    String decodedData = ascii.decode(data);

    RegExp digitExp = RegExp(r'(\d)');

    var splittedDecodedData = decodedData.split("");

    print(decodedData);

    final String ecgBuffer = ecgBufferState.get();

    for (var element in splittedDecodedData) {
      if (ecgBuffer.length > 2 &&
          ecgBuffer.endsWith("E") &&
          ecgBuffer.startsWith("E")) {
        String data = ecgBuffer.substring(1, ecgBuffer.length - 1);

        int x = int.parse(data);

        // make sure it is not clapped
        x = x < xMin ? xMin : x;
        x = x > xMax ? xMax : x;

        samplesPassed++;

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

        if (isRecording) {
          revisionBuffer.add(normX);
        }

        ecgBufferState.prepare();
      }

      if (element != "!" && (element == "E" || digitExp.hasMatch(element))) {
        ecgBufferState.receiveData(element);
      }

      // in case wrong thing happens to the ecgBuffer, reset it from beginning.
      if (ecgBuffer.contains("EE")) {
        ecgBufferState.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<ECGBufferController>(
            init: ECGBufferController(),
            builder: (ecgBufferState) => ecgBufferState.get().isEmpty
                ? const ClientMonitorDisconnectedECG()
                : ClientMonitorECGConnected(user: widget.user)));
  }
}
