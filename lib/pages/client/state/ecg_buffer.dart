import 'package:get/get.dart';

// WE USE ECGBuffer for 2 purposes
// 1- Save data received from bluetooth
// 2- Check if the patient is connected with the ECG device
class ECGBufferController extends GetxController {
  // ignore: non_constant_identifier_names
  String _ECGBuffer = "";

  // just returns the ECG buffer
  String get() => _ECGBuffer;

  void receiveData(String data) {
    _ECGBuffer += data;
    update();
  }

  // prepares the ECG buffer for the next data
  void prepare() {
    _ECGBuffer = "E";
    update();
  }

  void reset() {
    _ECGBuffer = "";
    update();
  }
}
