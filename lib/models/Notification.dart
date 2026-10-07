import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String from;
  final String title;
  final String content;
  final DateTime timestamp;

  NotificationModel({
    required this.from,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  // Formatted time getter (e.g. "27 July 2025 at 18:59")
  String get formattedTime {
    final formatter = DateFormat('d MMMM yyyy \'at\' HH:mm');
    return formatter.format(timestamp);
  }

  // Factory constructor from Firestore map
  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      from: data['from'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert to Map (if needed to store back to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
