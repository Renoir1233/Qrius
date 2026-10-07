class ScheduleItem {
  final String type;
  final String subject;
  final String time;
  final String venue;

  ScheduleItem({
    required this.type,
    required this.subject,
    required this.time,
    required this.venue,
  });

  factory ScheduleItem.fromJson(Map<String, String> json) {
    return ScheduleItem(
      type: json['type'] ?? 'lecture',
      subject: json['subject'] ?? '',
      time: json['time'] ?? '',
      venue: json['venue'] ?? '',
    );
  }
}
