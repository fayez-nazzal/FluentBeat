import 'package:fluent_beat/pages/common/login/login.dart';
import 'package:fluent_beat/widgets/Button/Button.dart';
import 'package:fluent_beat/widgets/LogoWithChild/LogoWithChild.dart';
import 'package:flutter/material.dart';

class StartHome extends StatefulWidget {
  StartHome({Key? key}) : super(key: key);

  @override
  State<StartHome> createState() => _StartHomeState();
}

class _StartHomeState extends State<StartHome> {
  int page = 0;
  late List<Widget> pages;

  _StartHomeState() {
    pages = [
      Column(
        children: [
          Button(
              bg: 0xffffffff,
              text: "Sign In",
              onPress: () {
                setState(() {
                  print("ddddd");
                  page = 1;
                });
              }),
          Button(
              bg: 0xffff7f7f,
              text: "Sign Up",
              onPrimary: 0xffffff,
              onPress: () {
                setState(() {
                  print("dd");
                  page = 2;
                });
              }),
        ],
      ),
      Login()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 240, 230, 234),
              Color.fromARGB(200, 250, 214, 252)
            ],
          ),
        ),
        // see https://api.flutter.dev/flutter/widgets/SlideTransition-class.html for transition animation
        child: LogoWithChild(child: pages[page]));
  }
}
