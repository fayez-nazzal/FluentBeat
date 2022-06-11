import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

typedef void ListenCallback(Uint8List data);

class ClientConnectionController extends GetxController {
  BluetoothConnection? connection;
  bool shouldDisconnect = false;

  Future tryConnection() async {
    try {
      connection = await BluetoothConnection.toAddress('00:14:03:05:59:9C');
    } catch (e) {}

    update();
  }

  void refreshConnection() {
    shouldDisconnect = true;
    update();
  }
}
