import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/studentAttendance.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final String studentId;

  var studentName = "Loading...".obs;
  var studentCourse = "".obs;
  var attendanceDetails = <AttendanceDetail>[].obs;
  var totalAttendance = 0.obs;
  var presentDays = 0.obs;
  var absentDays = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final argId = Get.arguments?['studentId'];
    studentId = argId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchStudentName();
    fetchAllAttendance();
  }

  Future<void> fetchStudentName() async {
    final doc = await firestore.collection('students').doc(studentId).get();
    if (doc.exists) {
      studentName.value = doc['name'] ?? "Unknown";
      studentCourse.value = doc['course'] ?? "";
    } else {
      studentName.value = "Not Found";
    }
  }

  Future<void> fetchAllAttendance() async {
    try {
      isLoading.value = true;

      // Get student info first
      final studentDoc =
          await firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) {
        isLoading.value = false;
        return;
      }

      final studentData = studentDoc.data() as Map<String, dynamic>? ?? {};
      final String course = (studentData['course'] ?? '').toString();
      final String department = (studentData['department'] ?? '').toString();

      // Read from flat attendance collection without composite query
      final attendanceSnap = await firestore.collection('attendance').get();

      List<AttendanceDetail> allRecords = [];
      int attended = 0;

      for (var doc in attendanceSnap.docs) {
        final data = doc.data();
        final docCourse = (data['course'] ?? '').toString();
        final docDepartment = (data['department'] ?? '').toString();
        final studentsMap = (data['students'] as Map<String, dynamic>?) ?? {};
        final isPresent = studentsMap.containsKey(studentId);

        // Include this record if:
        // 1. The student is recorded as present
        // 2. OR the attendance record belongs to the student's course or department
        bool isRelevant = isPresent;
        if (!isRelevant && course.isNotEmpty && docCourse.isNotEmpty) {
          isRelevant =
              docCourse.trim().toLowerCase() == course.trim().toLowerCase();
        }
        if (!isRelevant && department.isNotEmpty && docDepartment.isNotEmpty) {
          isRelevant =
              docDepartment.trim().toLowerCase() ==
              department.trim().toLowerCase();
        }

        if (!isRelevant) continue;

        final ts = data['createdOn'] as Timestamp?;
        final dateStr =
            ts != null
                ? DateFormat('yyyy-MM-dd').format(ts.toDate())
                : doc.id
                    .replaceFirst('att_', '')
                    .replaceAllMapped(
                      RegExp(r'(\d{4})(\d{2})(\d{2})'),
                      (m) => '${m[1]}-${m[2]}-${m[3]}',
                    );

        String timeStr = '';
        DateTime? recordDateTime;
        if (isPresent) {
          attended++;
          final sEntry = studentsMap[studentId] as Map<String, dynamic>? ?? {};
          final sTs = sEntry['signedAt'] as Timestamp?;
          if (sTs != null) {
            recordDateTime = sTs.toDate();
            timeStr = DateFormat('hh:mm a').format(recordDateTime);
          }
        }
        if (timeStr.isEmpty && ts != null) {
          recordDateTime = ts.toDate();
          timeStr = DateFormat('hh:mm a').format(recordDateTime);
        }

        allRecords.add(
          AttendanceDetail(
            date: dateStr,
            status: isPresent ? "Present" : "Absent",
            course: docCourse.isNotEmpty ? docCourse : course,
            time: timeStr,
            timestamp: recordDateTime, // Add timestamp for sorting
          ),
        );
      }

      // Sort by timestamp descending (most recent first)
      allRecords.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      attendanceDetails.value = allRecords;
      totalAttendance.value = allRecords.length;
      presentDays.value = attended;
      absentDays.value = allRecords.length - attended;

      debugPrint(
        "Student attendance: $attended present out of ${allRecords.length} records",
      );
    } catch (e) {
      debugPrint("Error fetching student attendance: $e");
      Get.snackbar(
        "Error",
        "Failed to load attendance records.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      totalAttendance.value = 0;
      presentDays.value = 0;
      absentDays.value = 0;
      attendanceDetails.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
