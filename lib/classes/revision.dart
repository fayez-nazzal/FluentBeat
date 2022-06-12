// ignore_for_file: non_constant_identifier_names
class Revision {
  final String cognito_id;
  final String date;
  final List<double> ecg;
  final double bpm;

  const Revision({
    required this.cognito_id,
    required this.date,
    required this.ecg,
    required this.bpm,
  });

  String getId() {
    return "$cognito_id$date";
  }

  static Future<Revision> fromJson(json) async {
    List<dynamic> resEcg = json['ecg'];
    List<double> ecg = [];

    for (var val in resEcg) {
      ecg.add(double.parse(val));
    }

    return Revision(
        cognito_id: json['cognito_id'],
        date: json['date'],
        ecg: ecg,
        bpm: double.parse(json['bpm']));
  }
}
