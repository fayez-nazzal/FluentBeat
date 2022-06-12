import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../classes/user.dart';
import '../../../ui/button.dart';

class DoctorPatients extends StatefulWidget {
  const DoctorPatients({Key? key}) : super(key: key);

  @override
  State<DoctorPatients> createState() => _DoctorPatientsState();
}

class _DoctorPatientsState extends State<DoctorPatients> {
  List<dynamic>? patients;
  int fetchCount = 0;
  List<ListTile> patientList = [];

  void requestPatient(String patientId) async {
    String doctorId = (await Amplify.Auth.getCurrentUser()).userId;

    var dotenv;
    http.Response response = await http.post(
        Uri.parse("${dotenv.env["API_URL"]}/request_patient"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(
            {'doctor_cognito_id': doctorId, 'patient_cognito_id': patientId}));

    // decode the response
    Map<String, dynamic> responseJson = jsonDecode(response.body);

    // check if the request was successful
    if (responseJson['statusCode'] == 200) {
      // print("Success");
    } else {
      // print("Error");
    }
  }

  void listPatients() async {
    if (patients != null) return;

    setState(() {
      fetchCount += 1;
    });

    var client = http.Client();
    var response = await client.get(
      Uri.parse("${dotenv.env["API_URL"]}/list_patients"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response ( looks like {  statusCode: 200, body: {....}  }  )
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    // now, decode the body from decodedResponse, this will result into a List of values
    var body = json.decode(decodedResponse['body']);

    // last, map the values taken from results to User class, this will result into a list of Users
    patients = await body.map(Patient.fromJson).toList();

    if (patients != null) {
      for (var patient in patients!) {
        File? patientImageFile =
            await StorageRepository.getProfileImage(patient.id);

        Image patientImage = patientImageFile != null
            ? Image.file(patientImageFile)
            : Image.asset("images/heart.jpg");

        patientList.add(
          ListTile(
            leading: patientImage,
            title: Text(patient.name),
            subtitle: Text(patient.join_date),
            enabled: patient.request_doctor_id == null,
            onTap: () {
              requestPatient(patient.id);
            },
          ),
        );
      }
    }

    setState(() {
      patientList = patientList;
    });
  }

  @override
  void initState() {
    super.initState();

    listPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Button(
            bg: 0xffffffffff,
            text: "Add New Patient",
            onPress: () async {},
          ),
          Text("lambda fetch count: $fetchCount"),
          if (patients != null)
            ListView(shrinkWrap: true, children: patientList),
        ],
      ),
    );
  }
}
