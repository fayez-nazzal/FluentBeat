import 'dart:convert';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/revision.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:fluent_beat/pages/client/revisions/no_doctor.dart';
import 'package:fluent_beat/pages/client/revisions/revision.dart';
import 'package:fluent_beat/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class PatientRevisions extends StatefulWidget {
  const PatientRevisions({Key? key}) : super(key: key);

  @override
  State<PatientRevisions> createState() => PatientRevisionsState();

  static PatientRevisionsState? of(BuildContext context) =>
      context.findAncestorStateOfType<PatientRevisionsState>();
}

class PatientRevisionsState extends State<PatientRevisions> {
  late List<dynamic> doctors;
  List<ListTile> revisionsTiles = [];
  List<Revision> revisions = [];
  bool hasDoctor = false;
  Revision? currentRevision;
  final ScrollController _scrollController = ScrollController();

  static PatientStateController get patientState => Get.find();

  void listRevisions() async {
    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "${dotenv.env["API_URL"]}/revisions?patient_cognito_id=$patientCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response body
    // for this request, this will be done automatically, as we are using lambda proxy integration
    var body = jsonDecode(utf8.decode(response.bodyBytes)) as List;

    // check status code
    if (response.statusCode == 200) {
      revisions = [];
      revisionsTiles = [];

      for (var json in body) {
        var revision = await Revision.fromJson(json);

        revisions.add(revision);

        revisionsTiles.add(ListTile(
          title: Text(revision.date),
          subtitle: const Text("No comments yet"),
          enabled: true,
          onTap: () {
            setState(() {
              currentRevision = revision;
            });
          },
        ));
      }

      setState(() {
        revisionsTiles = revisionsTiles;
      });
    } else {
      showErrorDialog("Unable to list revisions.", context);
    }
  }

  @override
  void initState() {
    super.initState();

    listRevisions();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: KeyboardDismisser(
      child: GetBuilder<PatientStateController>(
        builder: (_) => Column(
          children: [
            if (patientState.patient != null &&
                patientState.patient!.doctor_id == null)
              PatientRevisionsNoDoctor()
            else if (currentRevision == null &&
                patientState.patient != null &&
                patientState.patient!.doctor != null)
              Container(
                height: 116.0,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                color: Colors.transparent,
                child: Expanded(
                  child: Card(
                      child: Center(
                          child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: patientState.patient!.doctor!.image),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Your Doctor:",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text("  ${patientState.patient!.doctor!.name}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87)),
                          ],
                        ),
                        const Spacer(flex: 2)
                      ],
                    ),
                  ))),
                ),
              ),
            if (currentRevision == null &&
                patientState.patient != null &&
                patientState.patient!.doctor != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Your Revisions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                        onPressed: listRevisions,
                        icon: const Icon(Icons.refresh)),
                  ],
                ),
              ),
            if (currentRevision == null &&
                patientState.patient != null &&
                patientState.patient!.doctor != null)
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: revisionsTiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return revisionsTiles[
                            revisionsTiles.length - index - 1];
                      }),
                ),
              ),
            if (currentRevision != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentRevision = null;
                  });
                },
                style: ElevatedButton.styleFrom(primary: Colors.white),
                child: SizedBox(
                  width: 160,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      Text("Go back to revisions",
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
            if (currentRevision != null)
              CurrentRevision(revision: currentRevision!)
          ],
        ),
      ),
    ));
  }
}
