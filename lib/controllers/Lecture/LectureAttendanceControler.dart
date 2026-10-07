import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrius/models/Student.dart';

class LectureAttendanceController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lectureUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  var selectedCourse = RxnString(null);
  var searchQuery = ''.obs;
  var selectedFilter = 'Recent'.obs;

  var isLoading = false.obs;
  var courses = <String>[].obs;
  var students = <Student>[].obs;
  var filteredStudents = <Student>[].obs;
  var activeFilter = "Recent Attendance".obs;

  // Keep for compatibility with attendance view
  var selectedModule = RxnString(null);
  var modules = <String>[].obs;

  Map<String, List<DateTime>> attendanceMap = {};
  List<String> allDates = [];

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    fetchAttendance();
    everAll([selectedCourse, selectedFilter], (_) => fetchAttendance());
  }

  /// Fetch courses this lecturer has generated QR codes for
  Future<void> fetchCourses() async {
    isLoading.value = true;
    courses.clear();

    try {
      // Get all attendance docs created by this lecturer
      final snap = await firestore.collection('attendance').get();

      final Set<String> courseSet = {};
      for (var doc in snap.docs) {
        final data = doc.data();
        final lId =
            (data['lecturerId'] ?? data['lecturerUid'] ?? '').toString();
        // Only fetch courses for THIS lecturer
        if (lId == lectureUid) {
          final course = data['course'] ?? '';
          if (course.isNotEmpty) courseSet.add(course);
        }
      }

      courses.assignAll(courseSet.toList()..sort());
      modules.assignAll(courses);

      debugPrint("Lecturer courses: ${courses.length}");
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch attendance from flat attendance collection for all courses (or selected course if set)
  Future<void> fetchAttendance() async {
    final courseFilter = selectedCourse.value ?? selectedModule.value;

    isLoading.value = true;
    students.clear();
    attendanceMap.clear();
    allDates = [];

    try {
      final attendanceSnap = await firestore.collection('attendance').get();

      final List<DateTime> dateList = [];
      final Map<String, Map<String, dynamic>> scannedStudentCache = {};

      for (var doc in attendanceSnap.docs) {
        final data = doc.data();
        final lId =
            (data['lecturerId'] ?? data['lecturerUid'] ?? '').toString();

        // Only show attendance for THIS lecturer
        if (lId != lectureUid) continue;

        final docCourse = (data['course'] ?? '').toString();
        if (courseFilter != null &&
            courseFilter.isNotEmpty &&
            docCourse.trim().toLowerCase() !=
                courseFilter.trim().toLowerCase()) {
          continue;
        }

        final Timestamp? ts = data['createdOn'];
        final createdOn = ts?.toDate() ?? DateTime.now();
        dateList.add(createdOn);

        final Map<String, dynamic> studentMap = Map<String, dynamic>.from(
          data['students'] ?? {},
        );

        for (var sid in studentMap.keys) {
          attendanceMap.putIfAbsent(sid, () => []).add(createdOn);
          if (!scannedStudentCache.containsKey(sid)) {
            final sData = studentMap[sid] as Map<String, dynamic>? ?? {};
            scannedStudentCache[sid] = {
              'name': sData['name'] ?? '',
              'regNo': sData['registrationNumber'] ?? '',
              'course': docCourse,
            };
          }
        }
      }

      debugPrint(
        "Found ${dateList.length} attendance sessions for lecturer $lectureUid",
      );

      // Extract and sort unique attendance dates
      allDates =
          dateList
              .map((d) => DateFormat('yyyy-MM-dd').format(d))
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

      // Build student list
      final attendedStudentIds = attendanceMap.keys.toSet();
      if (attendedStudentIds.isEmpty) {
        students.clear();
        filteredStudents.clear();
        isLoading.value = false;
        return;
      }

      // Firestore whereIn supports max 30 items — chunk if needed
      final idList = attendedStudentIds.toList();
      final Map<String, Student> uniqueStudentsMap = {};

      for (int i = 0; i < idList.length; i += 30) {
        final chunk = idList.sublist(
          i,
          i + 30 > idList.length ? idList.length : i + 30,
        );
        try {
          final studentSnap =
              await firestore
                  .collection('students')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get();

          for (var sDoc in studentSnap.docs) {
            final sid = sDoc.id;
            final sData = sDoc.data();
            final dates = attendanceMap[sid] ?? [];

            uniqueStudentsMap[sid] = Student(
              id: sid,
              name: sData['name'] ?? '',
              registrationNumber:
                  sData.containsKey('registrationNumber')
                      ? sData['registrationNumber'] ?? ''
                      : (sData['studentNumber'] ?? ''),
              isPresent: false,
              date: dates.isEmpty ? DateTime.now() : dates.first,
              module: sData['course'] ?? '',
              attendanceDates: dates,
            );
          }
        } catch (e) {
          debugPrint("Error fetching students chunk: $e");
        }
      } // end chunk for-loop

      // Fallback for students not found in students collection
      for (var sid in attendedStudentIds) {
        if (!uniqueStudentsMap.containsKey(sid)) {
          final dates = attendanceMap[sid] ?? [];
          final cached = scannedStudentCache[sid] ?? {};
          uniqueStudentsMap[sid] = Student(
            id: sid,
            name:
                cached['name']?.isNotEmpty == true
                    ? cached['name']!
                    : 'Student',
            registrationNumber: cached['regNo'] ?? '',
            isPresent: false,
            date: dates.isEmpty ? DateTime.now() : dates.first,
            module: cached['course'] ?? '',
            attendanceDates: dates,
          );
        }
      }

      students.assignAll(uniqueStudentsMap.values.toList());
      applyFilter(selectedFilter.value);
      debugPrint("Loaded ${students.length} students for attendance");
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch attendance",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchStudents(String query) {
    searchQuery.value = query;
    applyFilter(selectedFilter.value);
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    final qLower = searchQuery.value.toLowerCase();
    final String? formattedSelectedDate = filter == 'Recent' ? null : filter;
    final String? recentDate = allDates.isNotEmpty ? allDates.first : null;

    filteredStudents.value =
        students
            .map((s) {
              bool present = false;
              if (formattedSelectedDate != null) {
                present = s.attendanceDates.any(
                  (dt) =>
                      DateFormat('yyyy-MM-dd').format(dt) ==
                      formattedSelectedDate,
                );
              } else if (recentDate != null) {
                present = s.attendanceDates.any(
                  (dt) => DateFormat('yyyy-MM-dd').format(dt) == recentDate,
                );
              }
              return s.copyWith(isPresent: present);
            })
            .where(
              (s) =>
                  s.name.toLowerCase().contains(qLower) ||
                  s.registrationNumber.toLowerCase().contains(qLower),
            )
            .toList();

    activeFilter.value =
        filteredStudents.isEmpty
            ? "No records found"
            : (filter == 'Recent'
                ? "Showing Recent Attendance"
                : "Showing on $filter");
  }

  List<String> get dateFilters => allDates;

  String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
