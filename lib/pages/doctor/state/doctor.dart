import 'package:fluent_beat/classes/user.dart';
import 'package:get/get.dart';

class DoctorStateController extends GetxController {
  Doctor? _doctor;
  List<Patient> _patients = [];

  Doctor? get doctor => _doctor;
  List<Patient> get patients => _patients;

  void setDoctor(Doctor? doctor) {
    _doctor = doctor;
    update();
  }

  void setPatients(List<Patient> patients) {
    _patients = patients;
    update();
  }
}
