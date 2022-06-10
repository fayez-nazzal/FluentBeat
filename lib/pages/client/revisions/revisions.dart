import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/Button/Button.dart';
import '../../common/login/login.dart';
import 'package:http/http.dart' as http;

class Revisions extends StatefulWidget {
  const Revisions({Key? key}) : super(key: key);

  @override
  State<Revisions> createState() => _RevisionsState();
}

class _RevisionsState extends State<Revisions> {
  late List<dynamic> doctors;
  bool hasDoctors = false;

  void listDoctors() async {
    var client = http.Client();
    var response = await client.get(
      Uri.parse(
          "https://rhp8umja5e.execute-api.us-east-2.amazonaws.com/invoke_sklearn/list_doctors"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // first, decode the full response ( looks like {  statusCode: 200, body: {....}  }  )
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    // now, decode the body from decodedResponse, this will result into a List of values
    var body = json.decode(decodedResponse['body']);

    // last, map the values taken from results to User class, this will result into a list of Users
    doctors = body.map(User.fromJson).toList();

    print(doctors.length);

    if (doctors.length > 0) hasDoctors = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            child: Button(
                bg: 0xffffffff, text: "List Doctors", onPress: listDoctors)),
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
