import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DoctorPatientRequests extends StatefulWidget {
  const DoctorPatientRequests({Key? key}) : super(key: key);

  @override
  State<DoctorPatientRequests> createState() => _DoctorPatientRequestsState();
}

class _DoctorPatientRequestsState extends State<DoctorPatientRequests> {
  final TextEditingController _searchController = TextEditingController();
  List<PatientClient> filteredPatients = [];

  void respondToPatient(String patientId, bool accept) async {
    var user = await Amplify.Auth.getCurrentUser();

    var client = http.Client();
    var response = await client.post(Uri.parse("${dotenv.env["API_URL"]}/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'doctor_cognito_id': user.userId,
          'patient_cognito_id': patientId,
          'accept': accept
        }));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorStateController>(builder: (doctorState) {
      if (doctorState.doctor == null) return Container();

      List<PatientClient> patients = doctorState.doctor!.request_patients;

      filteredPatients = patients
          .where((patient) => patient.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();

      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: Text("Patient Requests",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search for a patient",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (txt) {
                        setState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: filteredPatients.length,
                        itemBuilder: (BuildContext context, int index) {
                          var patient = filteredPatients[index];

                          return Column(
                            children: [
                              ListTile(
                                title: Text(patient.name),
                                leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: patient.image),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      color: Colors.green,
                                      icon: const Icon(Icons.check, size: 26),
                                      onPressed: () =>
                                          respondToPatient(patient.id, true),
                                    ),
                                    IconButton(
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      color: Colors.red,
                                      icon: const Icon(Icons.cancel, size: 26),
                                      onPressed: () =>
                                          respondToPatient(patient.id, false),
                                    ),
                                  ],
                                ),
                              ),

                              // if this is the last one, no need for divider
                              if (patient.id !=
                                  filteredPatients[filteredPatients.length - 1]
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
        ],
      );
    });
  }
}
