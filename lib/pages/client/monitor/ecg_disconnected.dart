import 'package:flutter/material.dart';

class ClientMonitorDisconnectedECG extends StatelessWidget {
  const ClientMonitorDisconnectedECG({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // show grey image
        Image.asset('images/icon_grey.png',
            width: double.infinity,
            scale: 0.6,
            color: Colors.white.withOpacity(0.18),
            colorBlendMode: BlendMode.modulate),

        const Text(
          'ECG Device Not Connected',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
