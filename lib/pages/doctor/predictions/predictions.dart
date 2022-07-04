import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorPatientsPredictions extends StatefulWidget {
  const DoctorPatientsPredictions({Key? key}) : super(key: key);

  @override
  State<DoctorPatientsPredictions> createState() =>
      _DoctorPatientsPredictionsState();
}

class _DoctorPatientsPredictionsState extends State<DoctorPatientsPredictions> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorStateController>(
        builder: (doctorState) => doctorState.doctor == null &&
                doctorState.doctor!.patients.isNotEmpty
            ? Container()
            : Column(
                children: [
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
                  if (doctorState.selectedPatient != -1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "${doctorState.doctor!.patients[doctorState.selectedPatient].name}'s Predictions",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  const Divider(
                    thickness: 2,
                    height: 16,
                  ),
                  if (doctorState.selectedPatient != -1)
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: doctorState
                                .doctor!
                                .patients[doctorState.selectedPatient]
                                .predictions
                                .length,
                            itemBuilder: (BuildContext context, int index) {
                              var prediction = doctorState
                                  .doctor!
                                  .patients[doctorState.selectedPatient]
                                  .predictions[doctorState
                                      .doctor!
                                      .patients[doctorState.selectedPatient]
                                      .predictions
                                      .length -
                                  index -
                                  1];

                              List<int> classes = [
                                prediction.class_0,
                                prediction.class_1,
                                prediction.class_2,
                                prediction.class_3
                              ];

                              // get max class index
                              int maxIndex = classes.indexOf(
                                  classes.reduce((a, b) => a > b ? a : b));

                              const double fontSize = 16;
                              const FontWeight fw = FontWeight.bold;
                              Widget? titleWidget;
                              String subtitle = prediction.getDaysAgo();

                              switch (maxIndex) {
                                case 0:
                                  titleWidget = const Text('Normal ECG',
                                      style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: fw,
                                          color: Colors.green));
                                  break;
                                case 1:
                                  titleWidget = const Text(
                                      'Supraventricular Arrhythmia',
                                      style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: fw,
                                          color: Colors.orange));
                                  break;
                                case 2:
                                  titleWidget = const Text(
                                      'Premature Arrhythmia',
                                      style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: fw,
                                          color: Colors.yellow));
                                  break;
                                case 3:
                                  titleWidget = const Text(
                                      'Atrial Fibrillation',
                                      style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: fw,
                                          color: Colors.red));
                              }

                              return ListTile(
                                  trailing: Text(prediction.date),
                                  title: titleWidget,
                                  subtitle: Text(subtitle));
                            }),
                      ),
                    ),
                ],
              ));
  }
}
