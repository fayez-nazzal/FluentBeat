import 'package:flutter/material.dart';

class LogoWithChild extends StatelessWidget {
  final Widget? child;
  const LogoWithChild({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 240, 230, 234),
              Color.fromARGB(255, 250, 214, 252)
            ],
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox(
                height: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        Image(image: AssetImage('images/FluentBeat.png')),
                        Spacer(),
                        child!,
                      ],
                    )))));
  }
}
