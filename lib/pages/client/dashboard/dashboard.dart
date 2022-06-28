import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'chart_data.dart';

class ClientDashboard extends StatelessWidget {
  ClientDashboard({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();
  final TooltipBehavior _tooltipBehavior =
      TooltipBehavior(enable: true, header: '', canShowMarker: false);

  List<ChartSeries<PredictionsSummaryChartData, DateTime>>
      _getStackedAreaSeries(PatientStateController patientState) {
    return <ChartSeries<PredictionsSummaryChartData, DateTime>>[
      StackedArea100Series<PredictionsSummaryChartData, DateTime>(
          animationDuration: 2500,
          dataSource: patientState.predictionsSummaryChartData,
          xValueMapper: (PredictionsSummaryChartData data, _) => data.date,
          yValueMapper: (PredictionsSummaryChartData data, _) => data.class_0,
          color: Colors.green,
          name: 'Normal ECG'),
      StackedArea100Series<PredictionsSummaryChartData, DateTime>(
          animationDuration: 2500,
          dataSource: patientState.predictionsSummaryChartData,
          xValueMapper: (PredictionsSummaryChartData data, _) => data.date,
          yValueMapper: (PredictionsSummaryChartData data, _) => data.class_1,
          color: Colors.orange,
          name: 'Supraventricular Arrhythmia'),
      StackedArea100Series<PredictionsSummaryChartData, DateTime>(
          animationDuration: 2500,
          dataSource: patientState.predictionsSummaryChartData,
          xValueMapper: (PredictionsSummaryChartData data, _) => data.date,
          yValueMapper: (PredictionsSummaryChartData data, _) => data.class_2,
          color: Colors.yellow,
          name: 'Premature Arrhythmia'),
      StackedArea100Series<PredictionsSummaryChartData, DateTime>(
          animationDuration: 2500,
          dataSource: patientState.predictionsSummaryChartData,
          xValueMapper: (PredictionsSummaryChartData data, _) => data.date,
          yValueMapper: (PredictionsSummaryChartData data, _) => data.class_3,
          color: Colors.red,
          name: 'Atrial Fibrillation')
    ];
  }

  List<ChartSeries<AverageBPMSummaryChartData, DateTime>> _getBPMBarSeries(
      PatientStateController patientState) {
    return <ChartSeries<AverageBPMSummaryChartData, DateTime>>[
      ColumnSeries<AverageBPMSummaryChartData, DateTime>(
          animationDuration: 2500,
          dataSource: patientState.avgBPMSummaryHeartData,
          xValueMapper: (AverageBPMSummaryChartData data, _) => data.date,
          yValueMapper: (AverageBPMSummaryChartData data, _) => data.heartRate,
          color: const Color(0xFFff6b6b),
          name: 'Average BPM'),
    ];
  }

  Widget _getWinnerClassText(PatientStateController patientState) {
    const double fontSize = 16;
    const FontWeight fw = FontWeight.bold;

    switch (patientState.winnerClassThisWeek) {
      case 0:
        return const Text('Normal ECG',
            style: TextStyle(
                fontSize: fontSize, fontWeight: fw, color: Colors.green));
      case 1:
        return const Text('Supraventricular Arrhythmia',
            style: TextStyle(
                fontSize: fontSize, fontWeight: fw, color: Colors.orange));
      case 2:
        return const Text('Premature Arrhythmia',
            style: TextStyle(
                fontSize: fontSize, fontWeight: fw, color: Colors.yellow));
      case 3:
        return const Text('Atrial Fibrillation',
            style: TextStyle(
                fontSize: fontSize, fontWeight: fw, color: Colors.red));
      default:
        return const Text('~',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fw,
            ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: GetBuilder<PatientStateController>(
          init: PatientStateController(), // INIT IT ONLY THE FIRST TIME
          builder: (patientState) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 88.0,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  color: Colors.transparent,
                  child: Expanded(
                    child: Card(
                        child: Center(
                            child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: patientState.patient?.image ?? Container(),
                          ),
                          const Spacer(),
                          Text(patientState.patient?.name ?? "",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87)),
                          const Spacer(flex: 8)
                        ],
                      ),
                    ))),
                  ),
                ),
                // metrics
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 88.0,
                    width: double.infinity,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          width: 230,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // title
                              children: [
                                const Text(
                                  'Predicted Class',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                _getWinnerClassText(
                                  patientState,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Average BPM',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  patientState.averageBPMThisWeek == 0
                                      ? "~"
                                      : patientState.averageBPMThisWeek
                                          .toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: (patientState.averageBPMThisWeek <
                                                  70 ||
                                              patientState.averageBPMThisWeek >
                                                  120)
                                          ? Colors.red
                                          : Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: _scrollController,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 320,
                                    width: double.infinity,
                                    child: Card(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: patientState
                                                          .winnerClassThisWeek ==
                                                      -1
                                                  ? const Text("No Data",
                                                      style: TextStyle(
                                                          fontSize: 32,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black26))
                                                  : SfCartesianChart(
                                                      plotAreaBorderWidth: 0,
                                                      title: ChartTitle(
                                                          text: patientState
                                                                  .predictionsSummaryChartData
                                                                  .isEmpty
                                                              ? ''
                                                              : 'Predictions Summary'),
                                                      legend: Legend(
                                                          isVisible: patientState
                                                              .predictionsSummaryChartData
                                                              .isNotEmpty,
                                                          position:
                                                              LegendPosition
                                                                  .bottom,
                                                          overflowMode:
                                                              LegendItemOverflowMode
                                                                  .wrap),
                                                      primaryXAxis: DateTimeAxis(
                                                          majorGridLines:
                                                              const MajorGridLines(
                                                                  width: 0),
                                                          intervalType:
                                                              DateTimeIntervalType
                                                                  .days,
                                                          dateFormat:
                                                              DateFormat.yMd()),
                                                      primaryYAxis:
                                                          NumericAxis(),
                                                      series:
                                                          _getStackedAreaSeries(
                                                              patientState),
                                                      tooltipBehavior:
                                                          _tooltipBehavior,
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 340,
                                    width: double.infinity,
                                    child: Card(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: patientState
                                                          .averageBPMThisWeek ==
                                                      0
                                                  ? const Text("No Data",
                                                      style: TextStyle(
                                                          fontSize: 32,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black26))
                                                  : SfCartesianChart(
                                                      plotAreaBorderWidth: 0,
                                                      title: ChartTitle(
                                                          text: patientState
                                                                  .predictionsSummaryChartData
                                                                  .isEmpty
                                                              ? ''
                                                              : 'Average BPM Summary'),
                                                      legend: Legend(
                                                          isVisible: patientState
                                                              .predictionsSummaryChartData
                                                              .isNotEmpty,
                                                          position:
                                                              LegendPosition
                                                                  .bottom,
                                                          overflowMode:
                                                              LegendItemOverflowMode
                                                                  .wrap),
                                                      primaryXAxis: DateTimeAxis(
                                                          majorGridLines:
                                                              const MajorGridLines(
                                                                  width: 0),
                                                          intervalType:
                                                              DateTimeIntervalType
                                                                  .days,
                                                          dateFormat:
                                                              DateFormat.yMd()),
                                                      primaryYAxis:
                                                          NumericAxis(),
                                                      series: _getBPMBarSeries(
                                                          patientState),
                                                      tooltipBehavior:
                                                          _tooltipBehavior,
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        )),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
