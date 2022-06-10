import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/monitor/LiveData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../widgets/Button/Button.dart';

class DoctorPatients extends StatefulWidget {
  const DoctorPatients({Key? key}) : super(key: key);

  @override
  State<DoctorPatients> createState() => _DoctorPatientsState();
}

class _DoctorPatientsState extends State<DoctorPatients> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Button(
        bg: 0xffffffffff,
        text: "Add New Patient",
        onPress: () async {},
      ),
    );
  }
}
