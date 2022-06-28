class PredictionsSummaryChartData {
  final DateTime date;
  final num class_0;
  final num class_1;
  final num class_2;
  final num class_3;

  PredictionsSummaryChartData({
    required this.date,
    required this.class_0,
    required this.class_1,
    required this.class_2,
    required this.class_3,
  });
}

class AverageBPMSummaryChartData {
  final DateTime date;
  final double heartRate;

  AverageBPMSummaryChartData({
    required this.date,
    required this.heartRate,
  });
}
