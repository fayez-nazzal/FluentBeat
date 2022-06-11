import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final int bg;
  final String text;
  final int onPrimary;
  final Function() onPress;

  const Button(
      {Key? key,
      required this.bg,
      required this.text,
      required this.onPress,
      this.onPrimary = 0xffFF6B6B})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: 250,
        height: 42,
        child: ElevatedButton(
          onPressed: onPress,
          style: ElevatedButton.styleFrom(
              primary: Color(bg), onPrimary: Color(onPrimary)),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
