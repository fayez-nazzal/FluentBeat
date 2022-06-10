import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/storage.dart';
import 'package:fluent_beat/pages/client/monitor/LiveData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../classes/user.dart';
import '../../../widgets/Button/Button.dart';

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

    http.Response response = await http.post(
        Uri.parse(
            'https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/request_patient'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(
            {'doctor_cognito_id': doctorId, 'patient_cognito_id': patientId}));

    // decode the response
    Map<String, dynamic> responseJson = jsonDecode(response.body);

    // check if the request was successful
    if (responseJson['statusCode'] == 200) {
      print("Success");
    } else {
      print("Error");
    }
  }

  void listPatients() async {
    if (patients != null) return;

    setState(() {
      fetchCount += 1;
    });

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/list_patients"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response ( looks like {  statusCode: 200, body: {....}  }  )
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    // now, decode the body from decodedResponse, this will result into a List of values
    var body = json.decode(decodedResponse['body']);

    // last, map the values taken from results to User class, this will result into a list of Users
    patients = body.map(Patient.fromJson).toList();

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
