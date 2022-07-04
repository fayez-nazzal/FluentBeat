import 'package:fluent_beat/pages/doctor/revisions/revision.dart';
import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorPatientsRevisions extends StatefulWidget {
  const DoctorPatientsRevisions({Key? key}) : super(key: key);

  @override
  State<DoctorPatientsRevisions> createState() =>
      _DoctorPatientsRevisionsState();
}

class _DoctorPatientsRevisionsState extends State<DoctorPatientsRevisions> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorStateController>(
        builder: (doctorState) => doctorState.currentRevision != null
            ? const DoctorPatientCurrentRevision()
            : doctorState.doctor != null &&
                    doctorState.doctor!.patients.isNotEmpty
                ? Column(
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
                                  "${doctorState.doctor!.patients[doctorState.selectedPatient].name}'s Revisions",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
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
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: doctorState
                                    .doctor!
                                    .patients[doctorState.selectedPatient]
                                    .revisions
                                    .length,
                                itemBuilder: (BuildContext context, int index) {
                                  var revision = doctorState
                                      .doctor!
                                      .patients[doctorState.selectedPatient]
                                      .revisions[doctorState
                                          .doctor!
                                          .patients[doctorState.selectedPatient]
                                          .revisions
                                          .length -
                                      index -
                                      1];

                                  return ListTile(
                                    title: Text(revision.date),
                                    subtitle: const Text("No comments yet"),
                                    enabled: true,
                                    onTap: () {
                                      setState(() {
                                        doctorState
                                            .setCurrentRevision(revision);
                                      });
                                    },
                                  );
                                }),
                          ),
                        ),
                    ],
                  )
                : Container());
  }
}
