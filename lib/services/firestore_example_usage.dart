// ===================================================================
// EXAMPLE: How to use FirestoreService in your Qrius app
// ===================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrius/services/firestore_service.dart';

// ==================== STUDENT SIGNUP EXAMPLE ====================
Future<void> exampleStudentSignup({
  required String uid,
  required String email,
  required String name,
  required String studentNumber,
  String? course,
  String? year,
}) async {
  try {
    // 1. Create user document
    await FirestoreService.createUser(
      uid: uid,
      email: email,
      role: 'student',
      additionalData: {'name': name},
    );

    // 2. Create student profile
    await FirestoreService.createStudent(
      studentId: uid,
      name: name,
      email: email,
      studentNumber: studentNumber,
      course: course,
      year: year,
    );

    print(' Student created successfully');
  } catch (e) {
    print(' Error: $e');
    rethrow;
  }
}

// ==================== LECTURER SIGNUP EXAMPLE ====================
Future<void> exampleLecturerSignup({
  required String uid,
  required String email,
  required String name,
  String? department,
  String? employeeId,
}) async {
  try {
    // 1. Create user document
    await FirestoreService.createUser(
      uid: uid,
      email: email,
      role: 'lecture',
      additionalData: {'name': name},
    );

    // 2. Create lecturer profile
    await FirestoreService.createLecturer(
      lecturerId: uid,
      name: name,
      email: email,
      department: department,
      employeeId: employeeId,
    );

    print(' Lecturer created successfully');
  } catch (e) {
    print(' Error: $e');
    rethrow;
  }
}

// ==================== MODULE CREATION EXAMPLE ====================
Future<void> exampleCreateModule(String lecturerId) async {
  try {
    String moduleId = await FirestoreService.createModule(
      name: 'Software Engineering',
      code: 'CSC301',
      lecturerId: lecturerId,
      description: 'Introduction to software development methodologies',
      additionalData: {'semester': 'Spring 2024', 'credits': 3},
    );

    print('✅ Module created with ID: $moduleId');
  } catch (e) {
    print(' Error: $e');
  }
}

// ==================== ATTENDANCE RECORDING EXAMPLE ====================
Future<void> exampleRecordAttendance({
  required String studentId,
  required String moduleId,
  required String lecturerId,
}) async {
  try {
    String attendanceId = await FirestoreService.recordAttendance(
      studentId: studentId,
      moduleId: moduleId,
      lecturerId: lecturerId,
      attendanceDate: DateTime.now(),
      status: 'present',
      remarks: 'On time',
      location: {'latitude': 0.0, 'longitude': 0.0},
    );

    print('✅ Attendance recorded with ID: $attendanceId');
  } catch (e) {
    print(' Error: $e');
  }
}

// ==================== ANNOUNCEMENT EXAMPLE ====================
Future<void> exampleCreateAnnouncement(String lecturerId) async {
  try {
    String announcementId = await FirestoreService.createAnnouncement(
      title: 'Class Postponed',
      message: 'Tomorrow\'s class is postponed to next week.',
      lecturerId: lecturerId,
      moduleId: 'CSC301', // Optional
      targetStudents: null, // null = all students
    );

    print(' Announcement created with ID: $announcementId');
  } catch (e) {
    print(' Error: $e');
  }
}

// ==================== FETCHING DATA WITH STREAMS (For GetX) ====================
class ExampleController {
  // Stream for real-time student list
  Stream<QuerySnapshot> getStudentListStream() {
    return FirestoreService.getStudents();
  }

  // Stream for real-time attendance
  Stream<QuerySnapshot> getStudentAttendanceStream(String studentId) {
    return FirestoreService.getAttendanceByStudent(studentId);
  }

  // Stream for announcements
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return FirestoreService.getAnnouncements();
  }

  // Stream for lecturer's modules
  Stream<QuerySnapshot> getLecturerModulesStream(String lecturerId) {
    return FirestoreService.getModulesByLecturer(lecturerId);
  }
}

// ==================== GetX USAGE EXAMPLE ====================
/*
// In your GetX controller:
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrius/services/firestore_service.dart';

class StudentListController extends GetxController {
  // Observable list
  final students = <DocumentSnapshot>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Listen to real-time updates
    FirestoreService.getStudents().listen((snapshot) {
      students.value = snapshot.docs;
    });
  }
}

// In your widget:
Obx(() {
  return ListView.builder(
    itemCount: controller.students.length,
    itemBuilder: (context, index) {
      var student = controller.students[index].data() as Map<String, dynamic>;
      return ListTile(
        title: Text(student['name'] ?? 'Unknown'),
        subtitle: Text(student['email'] ?? ''),
      );
    },
  );
})
*/

// ==================== QUERY ATTENDANCE BY DATE RANGE ====================
Future<void> exampleGetAttendanceReport({
  required String studentId,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    QuerySnapshot snapshot = await FirestoreService.getAttendanceByDateRange(
      startDate: startDate,
      endDate: endDate,
      studentId: studentId,
    );

    print(' Found ${snapshot.docs.length} attendance records');

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      print('Date: ${data['attendanceDate']}, Status: ${data['status']}');
    }
  } catch (e) {
    print(' Error: $e');
  }
}
