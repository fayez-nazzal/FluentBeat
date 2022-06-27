import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:fluent_beat/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../../../classes/storage_repository.dart';
import 'package:http/http.dart' as http;

class PatientRevisionsNoDoctor extends StatefulWidget {
  const PatientRevisionsNoDoctor({Key? key}) : super(key: key);

  @override
  State<PatientRevisionsNoDoctor> createState() =>
      _PatientRevisionsNoDoctorState();
}

class _PatientRevisionsNoDoctorState extends State<PatientRevisionsNoDoctor> {
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  static PatientStateController get patientState => Get.find();

  final TextEditingController _searchController = TextEditingController();

  void listDoctors() async {
    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "${dotenv.env["API_URL"]}/list_doctors?patient_cognito_id=$patientCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response ( looks like {  statusCode: 200, body: {....}  }  )
    // for this request, this will be done automatically, as we are using lambda proxy integration
    var body = jsonDecode(utf8.decode(response.bodyBytes));

    // last, map the values taken from results to User class, this will result into a list of Users
    List<Doctor> reqDoctors = [];

    for (var json in body) {
      var doctor = await Doctor.fromJson(json);
      reqDoctors.add(doctor);
    }
    setState(() {
      _searchController.text = "";
      doctors = reqDoctors;
      filteredDoctors = reqDoctors;
    });
  }

  void requestDoctor(String doctorCognitoId) async {
    // first cancel previous requests, patient can request and have only one doctor
    cancelDoctorRequest();

    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;
    String? prevReqId = patientState.patient!.request_doctor_id;
    patientState.patient!.request_doctor_id = doctorCognitoId;
    patientState.update();

    var client = http.Client();
    var response = await client.post(
      Uri.parse("${dotenv.env["API_URL"]}/patient/request_doctor"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "doctor_cognito_id": doctorCognitoId,
        "patient_cognito_id": patientCognitoId,
      }),
    );

    // first, decode the full response ( looks like {  statusCode: 200, body: {....}  }  )
    // for this request, this will be done automatically, as we are using lambda proxy integration
    var body = jsonDecode(utf8.decode(response.bodyBytes));

    // see if the request was successful
    if (body['statusCode'] == 200) {
      // succeded, do nothing as we made the optimistic update

    } else {
      // failed, revert the optimistic update
      patientState.patient!.request_doctor_id = prevReqId;

      // display an error message
      showErrorDialog("Can't send request to doctor.", context);
    }
  }

  void cancelDoctorRequest() async {
    if (patientState.patient!.request_doctor_id == null) {
      return;
    }

    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;
    String? prevReqId = patientState.patient!.request_doctor_id;
    patientState.patient!.request_doctor_id = null;
    patientState.update();

    var client = http.Client();
    var response = await client.post(
      Uri.parse("${dotenv.env["API_URL"]}/patient/cancel_request"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "patient_cognito_id": patientCognitoId,
      }),
    );

    var body = jsonDecode(utf8.decode(response.bodyBytes));

    if (body['statusCode'] == 200) {
      // succeded, do nothing as we made the optimistic update
    } else {
      patientState.patient!.request_doctor_id = prevReqId;
      // display an error message
      showErrorDialog("Can't cancel request to doctor.", context);
    }
  }

  @override
  void initState() {
    super.initState();

    listDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          GetBuilder<PatientStateController>(
            builder: (_) => Container(
              height: 116.0,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              color: Colors.transparent,
              child: Expanded(
                child: Card(
                    child: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.info,
                          color: Color(0xFFff6b6b),
                          size: 32,
                        ),
                      ),
                      Text("You don't have a doctor",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87)),
                    ],
                  ),
                ))),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: Text("Request a doctor from below:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for a doctor",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (txt) {
                          setState(() {
                            filteredDoctors = doctors
                                .where((doctor) => doctor.name
                                    .toLowerCase()
                                    .contains(txt.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: filteredDoctors.length,
                          itemBuilder: (BuildContext context, int index) {
                            var doctor = filteredDoctors[index];

                            return Column(
                              children: [
                                ListTile(
                                  title: Text(doctor.name),
                                  leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: doctor.image),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(),
                                        color: Colors.green,
                                        icon: const Icon(Icons.schedule_send,
                                            size: 26),
                                        onPressed: doctor.id ==
                                                patientState
                                                    .patient!.request_doctor_id
                                            ? null
                                            : () {
                                                requestDoctor(doctor.id);
                                              },
                                      ),
                                      IconButton(
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(),
                                        color: Colors.red,
                                        icon:
                                            const Icon(Icons.cancel, size: 26),
                                        onPressed: doctor.id ==
                                                patientState
                                                    .patient!.request_doctor_id
                                            ? cancelDoctorRequest
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),

                                // if this is the last one, no need for divider
                                if (doctor.id !=
                                    filteredDoctors[filteredDoctors.length - 1]
                                        .id)
                                  Divider(
                                      thickness: 2,
                                      height: 16,
                                      indent: 16,
                                      endIndent: 16,
                                      color: Colors.grey.withOpacity(0.22)),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
