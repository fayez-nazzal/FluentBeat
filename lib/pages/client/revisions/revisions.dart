import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:fluent_beat/pages/client/revisions/no_doctor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientRevisions extends StatefulWidget {
  const PatientRevisions({Key? key}) : super(key: key);

  @override
  State<PatientRevisions> createState() => PatientRevisionsState();

  static PatientRevisionsState? of(BuildContext context) =>
      context.findAncestorStateOfType<PatientRevisionsState>();
}

class PatientRevisionsState extends State<PatientRevisions> {
  late List<dynamic> doctors;
  bool hasDoctors = false;
  Patient? self;

  void getPatientInfo() async {
    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/patient_info?patient_cognito_id=$patientCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response body
    // for this request, this will be done automatically, as we are using lambda proxy integration
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    // TODO handle errors
    // last, get the patient from the body, this will result into a Pateint
    var patient = Patient.fromJson(decodedResponse);

    setState(() {
      self = patient;
    });
  }

  @override
  void initState() {
    super.initState();

    getPatientInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (self != null && self!.doctor_id == null)
          PatientRevisionsNoDoctor()
        else
          Container(
            height: 116.0,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
            color: Colors.transparent,
            child: Expanded(
              child: Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFFff6b6b),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset("images/heart.jpg")),
                        Spacer(),
                        const Text("Your Doctor",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        Spacer()
                      ],
                    ),
                  ))),
            ),
          ),
        if (hasDoctors)
          ListView(
            shrinkWrap: true,
            children: doctors.map((doctor) {
              return ListTile(
                title: Text(doctor.name),
                subtitle: Text(doctor.email),
              );
            }).toList(),
          ),
      ],
    );
  }
}
