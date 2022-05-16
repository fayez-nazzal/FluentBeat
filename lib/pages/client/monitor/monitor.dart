import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fluent_beat/pages/client/monitor/LiveData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ClientMonitor extends StatefulWidget {
  ClientMonitor({Key? key}) : super(key: key);

  @override
  State<ClientMonitor> createState() => _ClientMonitorState();
}

class _ClientMonitorState extends State<ClientMonitor> {
  List<int> normBuffer = List.filled(188, 0);
  int normBufferIndex = 0;
  String bufferStr = "";
  List<LiveData> chartData = <LiveData>[];
  List<LiveData> appendData = <LiveData>[];
  Timer? timer;
  ChartSeriesController? _chartSeriesController;
  final int chartLimit = 68;
  late int time;
  bool exitConnection = false;
  bool connected = false;
  bool error = false;
  final int connectionCountdownMax = 6;
  int connectionCountdown = 0;
  bool placedProperly = false;
  int bpm = 0;

  // for normalizing data
  final int xMin = 200;
  final int xMax = 1000;

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
      print('Connected to the device');

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
            print('Device not placed properly');
          } else if (decodedData.contains('disconnect')) {}

          RegExp digitExp = RegExp(r'(\d)');
          RegExp letterExp = RegExp(r'(E)'); // only E letter

          decodedData.split("").forEach((element) {
            if (bufferStr.length > 2 &&
                bufferStr.endsWith("E") &&
                bufferStr.startsWith("E")) {
              int x = int.parse(bufferStr.substring(1, bufferStr.length - 1));
              double normX = (x - xMin) / (xMax - xMin);
              LiveData liveData = LiveData(time, normX);
              time += 1;

              appendData.add(liveData);

              print(liveData.y);

              bufferStr = "E";
            }

            if (element == "E" || digitExp.hasMatch(element)) {
              bufferStr += element;
            }
          });
        }
      }).onDone(() {
        print('Disconnected by remote request');
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
    if (appendData.length == 0) return;

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
        title: Text("My Heart"),
        actions: [],
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
                Padding(padding: const EdgeInsets.only(right: 6)),
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
            padding: EdgeInsets.symmetric(vertical: 52),
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
        ],
      ),
    );
  }
}
