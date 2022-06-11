import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:flutter/material.dart';
import '../../../classes/storage_repository.dart';
import 'package:http/http.dart' as http;

class PatientRevisionsNoDoctor extends StatefulWidget {
  const PatientRevisionsNoDoctor({Key? key}) : super(key: key);

  @override
  State<PatientRevisionsNoDoctor> createState() =>
      _PatientRevisionsNoDoctorState();
}

class _PatientRevisionsNoDoctorState extends State<PatientRevisionsNoDoctor> {
  List<ListTile> doctorsList = [];

  void listDoctors() async {
    String patientCognitoId = (await Amplify.Auth.getCurrentUser()).userId;

    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/list_doctors?patient_cognito_id=$patientCognitoId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response ( looks like {  statusCode: 200, body: {....}  }  )
    // for this request, this will be done automatically, as we are using lambda proxy integration
    var body = jsonDecode(utf8.decode(response.bodyBytes));

    // last, map the values taken from results to User class, this will result into a list of Users
    var doctors = body.map(User.fromJson).toList();

    if (doctors != null) {
      for (var doctor in doctors) {
        File? doctorImageFile =
            await StorageRepository.getProfileImage(doctor.id);

        Image patientImage = doctorImageFile != null
            ? Image.file(doctorImageFile)
            : Image.asset("images/heart.jpg");

        doctorsList.add(ListTile(
          title: Text(doctor.name),
          subtitle: Text(doctor.email),
          leading: patientImage,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                color: Colors.green,
                icon: const Icon(Icons.check),
                onPressed: () {
                  // print("delete");
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red,
                onPressed: () {
                  // print("check");
                },
              ),
            ],
          ),
        ));
      }
    }

    setState(() {
      doctorsList = doctorsList;
    });
  }

  @override
  void initState() {
    super.initState();

    listDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.info,
                          color: Colors.cyan,
                          size: 32,
                        ),
                      ),
                      Text("You have no doctor!",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                ))),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 32.0),
          child: Text("Doctor Requests",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: doctorsList.length,
              itemBuilder: (BuildContext context, int index) {
                return doctorsList[index];
              }),
        ),
      ],
    );
  }
}
