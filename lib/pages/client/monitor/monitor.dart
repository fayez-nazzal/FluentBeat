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
  int time = 188;
  bool connected = true;

  @override
  void initState() {
    super.initState();

    setState(() {
      for (int i = 0; i < 188; i++) {
        chartData.add(LiveData(i, i));
      }
    });

    timer = Timer.periodic(const Duration(milliseconds: 8), _updateDataSource);
  }

  void scanForDevices() async {
    connected = true;

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      bondedDevices.forEach((element) {
        print(element.name);
        print(element.address);
      });
    });

    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress('00:14:03:05:59:9C');
      print('Connected to the device');

      connection.input?.listen((Uint8List data) {
        if (!connected) {
          connection.finish();
        } else {
          connection.output.add(data); // Sending data

          String decodedData = ascii.decode(data);

          if (decodedData.contains('!')) {
            // movement
            print('Device not placed properly');
          } else if (decodedData.contains('disconnect')) {}

          RegExp digitExp = RegExp(r'(\d)');
          RegExp letterExp = RegExp(r'(E)'); // only E letter

          decodedData.split("").forEach((element) {
            if (bufferStr.endsWith("E")) {
              try {
                LiveData liveData = LiveData(time,
                    int.parse(bufferStr.substring(1, bufferStr.length - 1)));
                time += 1;

                appendData.add(liveData);

                print(liveData.y);

                bufferStr = "E";
              } catch (err) {
                print(err);
                print("error occured");
              }
            }

            if (digitExp.hasMatch(element) || letterExp.hasMatch(element))
              bufferStr += element;
          });
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print(exception);
      print('Cannot connect, exception occured');
    }
  }

  void disconnectDevice() {
    setState(() {
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
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
                onPressed: scanForDevices, child: const Text("Scan")),
            ElevatedButton(
                onPressed: disconnectDevice, child: const Text("Disconnect"))
          ],
        ),
        SfCartesianChart(
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
            minimum: 100,
            maximum: 900,
          ),
        ),
      ],
    );
  }
}
