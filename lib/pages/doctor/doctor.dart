import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/monitor/monitor.dart';
import 'package:fluent_beat/pages/client/revisions/revisions.dart';
import 'package:fluent_beat/pages/client/settings/settings.dart';
import 'package:fluent_beat/pages/doctor/patients/pateints.dart';
import 'package:flutter/material.dart';

import 'dashboard/dashboard.dart';

class DoctorPage extends StatefulWidget {
  final AuthUser user;

  DoctorPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  int currentIndex = 0;
  late dynamic screens;

  @override
  void initState() {
    screens = [
      DoctorDashboard(),
      DoctorPatients(),
      PatientRevisions(),
      Settings(),
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
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: "Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Revisions",
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
