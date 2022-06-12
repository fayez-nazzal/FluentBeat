import 'package:fluent_beat/classes/revision.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CurrentRevision extends StatelessWidget {
  final Revision revision;
  const CurrentRevision({Key? key, required this.revision}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetBuilder<PatientStateController>(
          builder: (_) => Container(
            height: 80.0,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
            color: Colors.transparent,
            child: Expanded(
                child: Card(
                    child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFff6b6b)),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Revision",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                            Text(revision.getShortId(),
                                style: const TextStyle(
                                  fontSize: 10,
                                )),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(revision.getDaysAgo())
                    ],
                  )
                ],
              ),
            ))),
          ),
          // large empty card
        ),
      ],
    );
  }
}
