class Announcement {
  final String id;
  final String course;
  final String title;
  final String content;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.course,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Convert Announcement object to a Map (for API or local storage)
  Map<String, dynamic> toMap() {
    return {
      'course': course,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create an Announcement object from a Map (from API or local storage)
  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      course: map['course'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
