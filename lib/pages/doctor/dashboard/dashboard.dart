import 'package:fluent_beat/classes/user.dart';
import 'package:fluent_beat/pages/client/dashboard/chart_data.dart';
import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final ScrollController _scrollController = ScrollController();

  final TooltipBehavior _tooltipBehavior =
      TooltipBehavior(enable: true, header: '', canShowMarker: false);

  List<ChartSeries<PredictionsSummaryChartData, DateTime>>
      _getStackedAreaSeries(Patient patientState) {
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
      Patient patientState) {
    return <ChartSeries<AverageBPMSummaryChartData, DateTime>>[
      ColumnSeries<AverageBPMSummaryChartData, DateTime>(
          animationDuration: 2500,
          dataSource: patientState.avgBPMSummaryHeartData,
          xValueMapper: (AverageBPMSummaryChartData data, _) => data.date,
          yValueMapper: (AverageBPMSummaryChartData data, _) => data.heartRate,
          color: const Color(0xFFff6b6b),
          name: 'Average Heart Rate'),
    ];
  }

  Widget _getWinnerClassText(Patient patientState) {
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
    return GetBuilder<DoctorStateController>(
        builder: (doctorState) => doctorState.doctor == null
            ? Container()
            : Column(children: [
                Container(
                  height: 88.0,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  color: Colors.transparent,
                  child: Card(
                      child: Center(
                          child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: doctorState.doctor!.image ?? Container(),
                        ),
                        const Spacer(),
                        Text(doctorState.doctor!.name ?? "",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        const Spacer(flex: 8)
                      ],
                    ),
                  ))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Select Patient",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: DropdownButton(
                        items: List<DropdownMenuItem>.from(
                            doctorState.doctor!.patients
                                .asMap()
                                .map((i, patient) {
                                  return MapEntry(
                                      i,
                                      DropdownMenuItem(
                                        value: i,
                                        child: Text(patient.name),
                                      ));
                                })
                                .values
                                .toList()),
                        value: doctorState.selectedPatient == -1
                            ? null
                            : doctorState.selectedPatient,
                        hint: const Text("Patient Name"),
                        onChanged: (dynamic value) {
                          setState(() {
                            doctorState.setSelectedPatient(value);
                          });
                        },
                      ),
                    )
                  ],
                ),
                Text(
                    "${doctorState.doctor!.patients[doctorState.selectedPatient].name}'s Charts",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    )),
                const Divider(
                  thickness: 2,
                  color: Colors.black12,
                  height: 16,
                ),
                if (doctorState.selectedPatient != -1)
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 80,
                                        child: Card(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            // title
                                            children: [
                                              const Text(
                                                'Most Frequent Class This week',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87),
                                              ),
                                              const SizedBox(height: 8),
                                              _getWinnerClassText(
                                                doctorState.doctor!.patients[
                                                    doctorState
                                                        .selectedPatient],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 80,
                                        child: Card(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Average Heart Rate This Week',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                doctorState
                                                            .doctor!
                                                            .patients[doctorState
                                                                .selectedPatient]
                                                            .averageBPMThisWeek ==
                                                        0
                                                    ? "~"
                                                    : doctorState
                                                        .doctor!
                                                        .patients[doctorState
                                                            .selectedPatient]
                                                        .averageBPMThisWeek
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: (doctorState
                                                                    .doctor!
                                                                    .patients[
                                                                        doctorState
                                                                            .selectedPatient]
                                                                    .averageBPMThisWeek <
                                                                70 ||
                                                            doctorState
                                                                    .doctor!
                                                                    .patients[
                                                                        doctorState
                                                                            .selectedPatient]
                                                                    .averageBPMThisWeek >
                                                                120)
                                                        ? Colors.red
                                                        : Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    SizedBox(
                                      height: 380,
                                      width: double.infinity,
                                      child: Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: doctorState
                                                          .doctor!
                                                          .patients[doctorState
                                                              .selectedPatient]
                                                          .predictionsSummaryChartData
                                                          .isEmpty
                                                      ? const Text("No Data",
                                                          style: TextStyle(
                                                              fontSize: 28,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black26))
                                                      : doctorState
                                                                  .doctor!
                                                                  .patients[doctorState
                                                                      .selectedPatient]
                                                                  .predictionsSummaryChartData
                                                                  .length ==
                                                              1
                                                          ? const Text(
                                                              "Needs 2 days at least",
                                                              style: TextStyle(
                                                                  fontSize: 28,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Colors.black26))
                                                          : Expanded(
                                                              child:
                                                                  SfCartesianChart(
                                                                plotAreaBorderWidth:
                                                                    0,
                                                                legend: Legend(
                                                                    isVisible: doctorState
                                                                        .doctor!
                                                                        .patients[doctorState
                                                                            .selectedPatient]
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
                                                                            width:
                                                                                0),
                                                                    intervalType:
                                                                        DateTimeIntervalType
                                                                            .days,
                                                                    dateFormat:
                                                                        DateFormat
                                                                            .yMd()),
                                                                primaryYAxis:
                                                                    NumericAxis(),
                                                                series: _getStackedAreaSeries(doctorState
                                                                        .doctor!
                                                                        .patients[
                                                                    doctorState
                                                                        .selectedPatient]),
                                                                tooltipBehavior:
                                                                    _tooltipBehavior,
                                                              ),
                                                            )),
                                            ),
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
                                            const Text("This Week BPM ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87)),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: doctorState
                                                            .doctor!
                                                            .patients[doctorState
                                                                .selectedPatient]
                                                            .averageBPMThisWeek ==
                                                        0
                                                    ? const Text("No Data",
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black26))
                                                    : SfCartesianChart(
                                                        plotAreaBorderWidth: 0,
                                                        legend: Legend(
                                                            isVisible: doctorState
                                                                .doctor!
                                                                .patients[
                                                                    doctorState
                                                                        .selectedPatient]
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
                                                                DateFormat
                                                                    .yMd()),
                                                        primaryYAxis:
                                                            NumericAxis(),
                                                        series: _getBPMBarSeries(
                                                            doctorState.doctor!
                                                                    .patients[
                                                                doctorState
                                                                    .selectedPatient]),
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
              ]));
  }
}
