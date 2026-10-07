import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendAnnouncementNotification({
    required String course,
    required String title,
    required String body,
    required String lecturerName,
  }) async {
    try {
      debugPrint("Creating notifications for students in course: $course");
      debugPrint("Lecturer: $lecturerName | Title: $title");

      final studentsQuery =
          await _firestore
              .collection('students')
              .where('course', isEqualTo: course)
              .get();

      if (studentsQuery.docs.isEmpty) {
        debugPrint("No students found for course: $course");
        debugPrint("Make sure student course field exactly matches: '$course'");
        return;
      }

      debugPrint(
        "Found ${studentsQuery.docs.length} students in course: $course",
      );

      for (var i = 0; i < studentsQuery.docs.length && i < 3; i++) {
        final studentData = studentsQuery.docs[i].data();
        debugPrint("Student: ${studentData['name']} (${studentData['email']})");
      }

      int successCount = 0;
      int failCount = 0;

      for (var studentDoc in studentsQuery.docs) {
        try {
          await _firestore
              .collection('students')
              .doc(studentDoc.id)
              .collection('notifications')
              .add({
                'title': title, // Use the actual announcement title
                'content': body, // Use the announcement content
                'from': lecturerName, // Add from field for display
                'course': course,
                'lecturerName': lecturerName,
                'type': 'announcement',
                'read': false,
                'timestamp': FieldValue.serverTimestamp(),
                'createdAt': DateTime.now().toIso8601String(),
              });

          debugPrint("Notification created for student: ${studentDoc.id}");
          successCount++;
        } catch (e) {
          debugPrint("Failed to create notification for ${studentDoc.id}: $e");
          failCount++;
        }
      }

      debugPrint(
        "Notifications created: $successCount successful, $failCount failed",
      );
    } catch (e) {
      debugPrint("Error creating announcement notifications: $e");
      rethrow;
    }
  }
}
