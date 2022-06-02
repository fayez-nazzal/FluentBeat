import 'package:fluent_beat/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: "Proxima Nova",
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: const MaterialColor(0xFFff6b6b, {
            50: Color(0xFF000000),
            100: Color(0xFF380000),
            200: Color(0xFF710000),
            300: Color(0xFFaa0000),
            400: Color(0xFFe20000),
            500: Color(0xFFff1c1c),
            600: Color(0xFFfe5555),
            700: Color(0xFFff8d8d),
            800: Color(0xFFffc6c6),
            900: Color(0xFFFFFFFF),
          }),
        ),
      ),
      home: App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
