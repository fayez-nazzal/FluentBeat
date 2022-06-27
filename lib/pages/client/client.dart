import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/monitor/monitor.dart';
import 'package:fluent_beat/pages/client/revisions/revisions.dart';
import 'package:fluent_beat/pages/client/settings/settings.dart';
import 'package:fluent_beat/pages/client/state/ecg_buffer.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard/dashboard.dart';

class ClientPage extends StatefulWidget {
  final AuthUser user;

  const ClientPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  int currentIndex = 0;
  late dynamic screens;

  static PatientStateController get patientState => Get.find();

  @override
  void initState() {
    super.initState();

    patientState.getInfo();

    screens = [
      const ClientDashboard(),
      ClientMonitor(user: widget.user),
      const PatientRevisions(),
      const Settings(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // add ecgBuffferState to global state
    Get.put(ECGBufferController());

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
        unselectedItemColor: const Color(0xff86AEAD),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: "My Heart",
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
