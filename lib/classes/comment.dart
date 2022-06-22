// ignore_for_file: non_constant_identifier_names
import 'package:timeago/timeago.dart' as timeago;

class Comment {
  final String revision_id;
  final String date;
  final String by;
  final String body;

  const Comment(
      {required this.revision_id,
      required this.date,
      required this.by,
      required this.body});

  String getDaysAgo() {
    return timeago.format(DateTime.parse(date));
  }

  static Comment fromJson(json) {
    return Comment(
        revision_id: json['revision_id'],
        date: json['date'],
        by: json['by'],
        body: json['body']);
  }
}
