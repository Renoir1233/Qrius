import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String title;
  final String content;
  final DateTime timestamp;

  AnnouncementModel({
    required this.title,
    required this.content,
    required this.timestamp,
  });

  // Optional: Factory constructor for easy parsing
  factory AnnouncementModel.fromMap(Map<String, dynamic> data) {
    return AnnouncementModel(
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Optional: Convert model back to map (useful if saving)
  Map<String, dynamic> toMap() {
    return {'title': title, 'content': content, 'timestamp': timestamp};
  }
}
