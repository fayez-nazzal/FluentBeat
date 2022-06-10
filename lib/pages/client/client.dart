import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:fluent_beat/pages/client/monitor/monitor.dart';
import 'package:fluent_beat/pages/client/revisions/settings.dart';
import 'package:flutter/material.dart';

import 'dashboard/dashboard.dart';

class ClientPage extends StatefulWidget {
  final AuthUser user;

  ClientPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  int currentIndex = 0;
  late dynamic screens;

  @override
  void initState() {
    screens = [
      ClientDashboard(),
      ClientMonitor(user: widget.user),
      Text("Revisions"),
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
