import 'package:fluent_beat/widgets/Button/Button.dart';
import 'package:fluent_beat/widgets/LogoWithChild/LogoWithChild.dart';
import 'package:flutter/material.dart';

class StartHome extends StatelessWidget {
  const StartHome({Key? key}) : super(key: key);

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
        child: LogoWithChild(
          child: Column(
            children: const [
              Button(
                bg: 0xffffffff,
                text: "Sign In",
              ),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Button(
                  bg: 0xffff7f7f,
                  text: "Sign Up",
                  onPrimary: 0xffffff,
                ),
              ),
            ],
          ),
        ));
  }
}
