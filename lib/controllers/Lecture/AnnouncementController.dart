import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrius/models/annoncementmodel.dart';
import 'package:qrius/services/PushNotificationService.dart';

class AnnouncementController extends GetxController {
  var selectedCourse = RxnString();
  var title = ''.obs;
  var content = ''.obs;
  var isSending = false.obs;
  var announcements = <Announcement>[].obs;
  var courses = <String>[].obs;
  var isLoadingCourses = false.obs;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    debugPrint("AnnouncementController initialized");
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      isLoadingCourses.value = true;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      var doc =
          await FirebaseFirestore.instance
              .collection('lecturers')
              .doc(uid)
              .get();

      if (!doc.exists) {
        doc =
            await FirebaseFirestore.instance
                .collection('lectures')
                .doc(uid)
                .get();
      }

      if (doc.exists) {
        final data = doc.data();
        debugPrint("Lecturer document loaded");

        if (data?['details'] != null && data!['details']['courses'] != null) {
          List<dynamic> rawCourses = data['details']['courses'];
          courses.value = rawCourses.map((e) => e.toString()).toList();
          debugPrint("Found courses in details.courses: ${courses.value}");
        } else if (data?['course'] != null) {
          courses.value = [data!['course'].toString()];
          debugPrint("Found course in 'course' field: ${courses.value}");
        } else if (data?['department'] != null) {
          courses.value = [data!['department'].toString()];
          debugPrint("Found course in 'department' field: ${courses.value}");
        } else {
          debugPrint("No courses found in lecturer profile");
          debugPrint("Available fields: ${data?.keys.toList()}");
          _showMessage("No courses found in your profile.", isError: true);
        }

        if (courses.isNotEmpty) {
          selectedCourse.value = courses.first;
          debugPrint("Auto-selected course: ${courses.first}");
        }
      } else {
        debugPrint("Lecturer profile not found");
        _showMessage("Lecturer profile not found.", isError: true);
      }
    } catch (e) {
      debugPrint("Failed to load courses: $e");
      _showMessage("Failed to load courses: $e", isError: true);
    } finally {
      isLoadingCourses.value = false;
    }
  }

  Future<void> sendAnnouncement() async {
    debugPrint("=== SEND ANNOUNCEMENT DEBUG ===");
    debugPrint("selectedCourse.value: '${selectedCourse.value}'");
    debugPrint("titleController.text: '${titleController.text}'");
    debugPrint("contentController.text: '${contentController.text}'");
    debugPrint("==============================");

    if (selectedCourse.value == null || selectedCourse.value!.trim().isEmpty) {
      debugPrint("Validation failed: No course selected");
      _showMessage(
        "No course found. Please check your profile.",
        isError: true,
      );
      return;
    }

    if (titleController.text.trim().isEmpty) {
      debugPrint("Validation failed: Title is empty");
      _showMessage("Please enter a title!", isError: true);
      return;
    }

    if (contentController.text.trim().isEmpty) {
      debugPrint("Validation failed: Content is empty");
      _showMessage("Please enter announcement content!", isError: true);
      return;
    }

    isSending.value = true;

    try {
      String selectedCourseName = selectedCourse.value!.trim();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      debugPrint("Sending announcement to course: $selectedCourseName");

      DocumentSnapshot lecturerDoc;
      try {
        lecturerDoc =
            await FirebaseFirestore.instance
                .collection('lecturers')
                .doc(uid)
                .get();
      } catch (_) {
        lecturerDoc =
            await FirebaseFirestore.instance
                .collection('lectures')
                .doc(uid)
                .get();
      }

      final lecturerData = lecturerDoc.data() as Map<String, dynamic>?;
      final lecturerName = lecturerData?['name'] ?? 'Unknown Lecturer';

      final announcementData = {
        'lecturerId': uid,
        'lecturerName': lecturerName,
        'course': selectedCourseName,
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('announcements')
          .add(announcementData);

      debugPrint("Announcement saved to global collection");

      final courseQuery =
          await FirebaseFirestore.instance
              .collection('courses')
              .where('name', isEqualTo: selectedCourseName)
              .limit(1)
              .get();

      if (courseQuery.docs.isNotEmpty) {
        final courseId = courseQuery.docs.first.id;
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('announcements')
            .add(announcementData);
        debugPrint("Announcement saved to course-specific collection");
      }

      try {
        debugPrint("Sending notifications to students...");
        await PushNotificationService.sendAnnouncementNotification(
          course: selectedCourseName,
          title: titleController.text.trim(),
          body: contentController.text.trim(),
          lecturerName: lecturerName,
        );
        debugPrint("Notifications sent successfully");
      } catch (notifError) {
        debugPrint("Failed to send notifications: $notifError");
      }

      clearFields();

      debugPrint("Announcement sent successfully");
      _showMessage(
        "Announcement sent to $selectedCourseName students!",
        isError: false,
      );
    } catch (e) {
      debugPrint("Announcement error: $e");
      _showMessage("Failed to send announcement: $e", isError: true);
    } finally {
      isSending.value = false;
    }
  }

  void clearFields() {
    titleController.clear();
    contentController.clear();
  }

  void _showMessage(String message, {required bool isError}) {
    debugPrint(isError ? "ERROR: $message" : "SUCCESS: $message");

    try {
      final context = Get.context;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Could not show snackbar: $e");
    }
  }
}
