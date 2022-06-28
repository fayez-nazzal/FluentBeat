import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/classes/live_data.dart';
import 'package:fluent_beat/pages/client/monitor/ecg_disconnected.dart';
import 'package:fluent_beat/pages/client/state/connection.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:fluent_beat/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  bool isPredictionEmergency = false;

  // samples will be sent every ( 1.5 * this variable  ) seconds
  final int sampleDelayMultiplier = 1;
  bool callingReq = false;

  Map<String, int> predictions = {};

  // for normalizing data
  int xMin = 200;
  int xMax = 700;

  bool isRecording = false;
  int recordingCountdown = 0;

  static ClientConnectionController get clientConnection => Get.find();

  String bufferStr = "";

  Timer? bpmTimer;

  List<String> predictionText = <String>[
    "Normal ECG",
    "Supraventricular Arrhythmia",
    "Premature Arrhythmia",
    "Atrial Fibrillation",
  ];

  Map<String, String> abnormalBPMText = {
    "high-bpm": "High BPM detected",
    "low-bpm": "Low BPM detected"
  };

  final Map<String, String> bodyText = {
    "no-risk": "No Risk detected, be committed to your revisions for safety.",
    "no-risk-bpm": "We will notify your doctor in case this persists.",
    "no-high-risk":
        "No high Risk Factor, just keep wearing the ECG device for safety.",
    "risk-emergency-high-bpm": "And your BPM is high, we notified your doctor.",
    "risk-emergency-low-bpm": "And your BPM is low, we notified your doctor.",
    "risk-emergency-high-prediction":
        "We notified your doctor, be careful and wait for support.",
  };

  Map<String, dynamic> predictionCardStatus = {
    "title": "Normal ECG",
    "body": "No Risk detected, be committed to your revisions for safety.",
    "icon": Icons.sentiment_very_satisfied,
    "color": Colors.green,
  };

  static PatientStateController get patientState => Get.find();

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

    bpmTimer = Timer.periodic(const Duration(seconds: 1), _updateBPM);
    sampleTimer = Timer.periodic(const Duration(seconds: 5), _attemptPredict);
  }

  void _updatePredictionText() {
    int winnerClass = patientState.winnerClassThisWeek;
    predictionCardStatus["title"] = predictionText[winnerClass];

    bool abnormalWinner = patientState.winnerClassToday != 0 &&
        patientState.classCountsToday[patientState.winnerClassToday] > 12;

    // Change prediction title only when winnerClass is 0 and BPM is abnormal
    if (winnerClass == 0 && heartrate < 70) {
      predictionCardStatus["title"] = abnormalBPMText["low-bpm"];
      predictionCardStatus["body"] = bodyText["no-risk-bpm"];
      predictionCardStatus["icon"] = Icons.sentiment_dissatisfied;
      predictionCardStatus["color"] = Colors.orange;
    } else if (winnerClass == 0 && heartrate > 120) {
      predictionCardStatus["title"] = abnormalBPMText["high-bpm"];
      predictionCardStatus["body"] = bodyText["no-risk-bpm"];
      predictionCardStatus["icon"] = Icons.sentiment_dissatisfied;
      predictionCardStatus["color"] = Colors.orange;
    } else if (winnerClass == 0) {
      predictionCardStatus["body"] = bodyText["no-risk"];
      predictionCardStatus["icon"] = Icons.sentiment_very_satisfied;
      predictionCardStatus["color"] = Colors.green;
    } else if (heartrate < 70 && abnormalWinner) {
      predictionCardStatus["body"] = bodyText["risk-emergency-low-bpm"];
      predictionCardStatus["icon"] = Icons.sentiment_very_dissatisfied;
      predictionCardStatus["color"] = Colors.red;
    } else if (heartrate > 120 && abnormalWinner) {
      predictionCardStatus["body"] = bodyText["risk-emergency-high-bpm"];
      predictionCardStatus["icon"] = Icons.sentiment_very_dissatisfied;
      predictionCardStatus["color"] = Colors.red;
    } else if (!isPredictionEmergency) {
      predictionCardStatus["body"] = bodyText["no-high-risk"];
      predictionCardStatus["icon"] = Icons.sentiment_dissatisfied;
      predictionCardStatus["color"] = Colors.orange;
    } else {
      predictionCardStatus["body"] = bodyText["risk-emergency-high-prediction"];
      predictionCardStatus["icon"] = Icons.sentiment_very_dissatisfied;
      predictionCardStatus["color"] = Colors.red;
    }
  }

  void _checkEmergency(Timer timer) {
    // if the winnerClass is not zero and count is more than 12*5 ( equivelent to last 5 minutes ) -- low emergency ( simple push notification )
    if (patientState.winnerClassToday != 0 &&
        patientState.classCountsToday[patientState.winnerClassToday] > 12 * 5) {
      isPredictionEmergency = true;
    } else {
      isPredictionEmergency = false;
    }

    // if the winnerClass is not zero, count is more than 12*2 and BPM is high or low, make push notification emergency ( may be the 2nd in case of prediction emergency )
    if (patientState.winnerClassToday != 0 &&
        patientState.classCountsToday[patientState.winnerClassToday] > 12 * 2 &&
        (heartrate < 70 || heartrate > 120)) {}
  }

  void _updateBPM(Timer timer) {
    int bpm = 0;
    double bpmBufferMax = -1;

    if (bpmBuffer.length >= 1250) {
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

      //

      bpmBuffer = [];

      setState(() {
        heartrate = bpm * 6;

        _updatePredictionText();
      });
    }
  }

  void _attemptPredict(Timer timer) async {
    if (normBuffer.length < 187) return;
    if (heartrate < 20) return;
    if (callingReq) return;

    print("attempt predict");

    callingReq = true;

    http.Response response = await http.post(
      Uri.parse("${dotenv.env["API_URL"]}/invoke_sklearn"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'data': normBuffer.sublist(0, 187),
        'user_id': widget.user.userId,
        'bpm': heartrate,
        'date': DateFormat("yyyy-MM-dd").format(DateTime.now())
      }),
    );

    normBuffer = [];

    if (response.statusCode == 200) {
      patientState.updateWinnerClass(int.parse(response.body));
    } else {}

    callingReq = false;
  }

  void createRevision() async {
    if (!isRecording || revisionBuffer.isEmpty) return;

    List<double> ecgData = [...revisionBuffer];
    revisionBuffer = [];

    var client = http.Client();

    var response = await client.post(
      Uri.parse("${dotenv.env["API_URL"]}/revisions/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': widget.user.userId,
        'data': ecgData,
        'bpm': heartrate,
        "user_display_name": patientState.patient!.name
      }),
    );

    // check response status
    if (response.statusCode == 200) {
      // print response body
      print(response.body);
    } else {
      print(response.body);
      showErrorDialog("Revision cannot be created", context);
    }
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

  void _attemptConnect(Timer? timer) async {
    // if is connected, return
    if (clientConnection.connection?.isConnected ?? false) {
      return;
    }

    try {
      await clientConnection.tryConnection();

      // update data source
      Timer.periodic(const Duration(milliseconds: 9), _updateDataSource);

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

    print(decodedData);

    RegExp digitExp = RegExp(r'(\d)');

    var splittedDecodedData = decodedData.split("");

    for (var element in splittedDecodedData) {
      if (bufferStr.length > 2 &&
          bufferStr.endsWith("E") &&
          bufferStr.startsWith("E")) {
        String data = bufferStr.substring(1, bufferStr.length - 1);

        int x = int.parse(data);

        // make sure it is not clapped
        x = x < xMin ? xMin : x;
        x = x > xMax ? xMax : x;

        samplesPassed++;

        double normX = (x - xMin) / (xMax - xMin);
        time += 1;

        LiveData liveData = LiveData(time, normX);

        if (appendData.length < 10) appendData.add(liveData);

        // for bpm measurement
        bpmBuffer.add(normX);

        // for prediction
        normBuffer.add(normX);

        if (isRecording) {
          revisionBuffer.add(normX);
        }

        bufferStr = "E";
      }

      if (element != "!" && (element == "E" || digitExp.hasMatch(element))) {
        bufferStr += element;
      }

      // in case wrong thing happens
      bufferStr.replaceAll("EE", "E");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (clientConnection.connection?.isConnected == false) {
      return const ClientMonitorDisconnectedECG();
    }

    return Scaffold(
      body: Column(
        children: [
          GetBuilder<PatientStateController>(builder: (_) => Container()),
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
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8),
                  child: chartData.isEmpty
                      ? Container()
                      : SfCartesianChart(
                          plotAreaBackgroundColor: isRecording
                              ? const Color(0x33CAD7D7)
                              : const Color(0xaafafafa),
                          series: [
                            FastLineSeries<LiveData, int>(
                                color: const Color(0xff52A1BC),
                                onRendererCreated:
                                    (ChartSeriesController controller) {
                                  // Assigning the controller to the _chartSeriesController.
                                  _chartSeriesController = controller;
                                },
                                // Binding the chartData to the dataSource of the line series.
                                dataSource: chartData,
                                xValueMapper: (LiveData liveData, _) =>
                                    liveData.x,
                                yValueMapper: (LiveData liveData, _) =>
                                    liveData.y,
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
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 6, bottom: 12, left: 12, right: 12),
            child: Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        predictionCardStatus['icon'],
                        color: predictionCardStatus['color'],
                        size: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            predictionCardStatus['title']!,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: predictionCardStatus['color']),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          SizedBox(
                            width: 240,
                            child: Text(
                              predictionCardStatus['body'],
                              style: const TextStyle(
                                  fontSize: 13.0,
                                  color: Color(0xff333333),
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
              child: Text(
                  isRecording
                      ? "Recording $recordingCountdown/60 (Stop)"
                      : "Record for Revision",
                  style: const TextStyle(fontSize: 16)),
              onPressed: () {
                if (isRecording) createRevision();

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
