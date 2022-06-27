import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({Key? key}) : super(key: key);

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
              ]),
        ),
      ),
    );
  }
}
