import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final Function(String) onChange;
  final String labelText;
  final bool password;

  const Input(
      {Key? key,
      required this.onChange,
      required this.labelText,
      this.password = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
          onChanged: onChange,
          obscureText: password,
          enableSuggestions: !password,
          autocorrect: !password,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: labelText,
          )),
    );
  }
}
