import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final int bg;
  final String text;
  final int onPrimary;

  const Button(
      {Key? key,
      required this.bg,
      required this.text,
      this.onPrimary = 0xffFF6B6B})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 46,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            primary: Color(bg), onPrimary: Color(onPrimary)),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
    );
  }
}
