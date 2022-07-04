import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/doctor/dashboard/dashboard.dart';
import 'package:fluent_beat/pages/doctor/predictions/predictions.dart';
import 'package:fluent_beat/pages/doctor/requests/requests.dart';
import 'package:fluent_beat/pages/doctor/revisions/revisions.dart';
import 'package:fluent_beat/pages/doctor/settings/settings.dart';
import 'package:fluent_beat/pages/doctor/state/doctor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorPage extends StatefulWidget {
  final AuthUser user;

  const DoctorPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  int currentIndex = 0;
  late dynamic screens;

  static DoctorStateController get doctorState => Get.find();

  @override
  void initState() {
    super.initState();

    doctorState.getInfo();

    screens = [
      const DoctorDashboard(),
      const DoctorPatientsPredictions(),
      const DoctorPatientsRevisions(),
      const DoctorPatientRequests(),
      const DoctorSettings(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 18,
        unselectedFontSize: 10,
        selectedFontSize: 11,
        unselectedItemColor: const Color(0xff86AEAD),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Predictions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: "Revisions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_received),
            label: "Requests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
