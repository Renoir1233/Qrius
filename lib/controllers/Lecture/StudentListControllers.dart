import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/studentList.dart';

class StudentListController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lectureId = FirebaseAuth.instance.currentUser?.uid ?? '';

  var searchQuery = ''.obs;
  var allStudents = <StudentList>[].obs;
  var filteredStudents = <StudentList>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
    ever(searchQuery, (_) => filterStudents());
  }

  /// Load all students who have scanned this lecturer's QR codes
  Future<void> fetchStudents() async {
    isLoading.value = true;
    allStudents.clear();
    filteredStudents.clear();

    try {
      final currentUid =
          lectureId.isNotEmpty
              ? lectureId
              : (FirebaseAuth.instance.currentUser?.uid ?? '');

      // Get all attendance docs and match either lecturerId or lecturerUid
      final attendanceSnap = await firestore.collection('attendance').get();

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> lecturerDocs = [];
      for (var doc in attendanceSnap.docs) {
        final data = doc.data();
        final lId =
            (data['lecturerId'] ?? data['lecturerUid'] ?? '').toString();
        if (lId == currentUid) {
          lecturerDocs.add(doc);
        }
      }

      debugPrint(
        "Found ${lecturerDocs.length} attendance docs for lecturer $currentUid",
      );

      // Collect unique student IDs across all attendance docs
      final Map<String, Map<String, dynamic>> studentInfoMap = {};

      for (var doc in lecturerDocs) {
        final data = doc.data();
        final studentsMap = (data['students'] as Map<String, dynamic>?) ?? {};

        for (var entry in studentsMap.entries) {
          final sid = entry.key;
          final sInfo = entry.value as Map<String, dynamic>? ?? {};
          if (!studentInfoMap.containsKey(sid)) {
            studentInfoMap[sid] = {
              'name': sInfo['name'] ?? '',
              'regNo': sInfo['registrationNumber'] ?? sInfo['regNo'] ?? '',
              'course': data['course'] ?? '',
            };
          }
        }
      }

      if (studentInfoMap.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Fetch full student details from students collection in chunks of 30
      final idList = studentInfoMap.keys.toList();
      final Map<String, StudentList> studentResults = {};

      for (int i = 0; i < idList.length; i += 30) {
        final chunk = idList.sublist(
          i,
          (i + 30) > idList.length ? idList.length : i + 30,
        );

        try {
          final studentSnap =
              await firestore
                  .collection('students')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get();

          for (var sDoc in studentSnap.docs) {
            final data = sDoc.data();
            final cachedInfo = studentInfoMap[sDoc.id] ?? {};

            studentResults[sDoc.id] = StudentList(
              id: sDoc.id,
              name: data['name'] ?? cachedInfo['name'] ?? '',
              regNo:
                  data['registrationNumber'] ??
                  data['studentNumber'] ??
                  cachedInfo['regNo'] ??
                  '',
              course: data['course'] ?? cachedInfo['course'] ?? '',
              module: '',
              email: data['email'] ?? '',
              year: data['year'] ?? '',
              isClassRep: data['isClassRep'] ?? false,
            );
          }
        } catch (e) {
          debugPrint("Error fetching students chunk: $e");
        }
      }

      // Add fallback for any students from scans not returned in students collection query
      for (var entry in studentInfoMap.entries) {
        final sid = entry.key;
        if (!studentResults.containsKey(sid)) {
          final cached = entry.value;
          studentResults[sid] = StudentList(
            id: sid,
            name:
                cached['name']?.isNotEmpty == true
                    ? cached['name']!
                    : 'Student',
            regNo: cached['regNo'] ?? '',
            course: cached['course'] ?? '',
            module: '',
            email: '',
            year: '',
            isClassRep: false,
          );
        }
      }

      allStudents.assignAll(studentResults.values.toList());
      filterStudents();
      debugPrint("Loaded ${allStudents.length} students who attended");
    } catch (e) {
      debugPrint("Error fetching students: $e");
      Get.snackbar(
        "Error",
        "Failed to load students.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredStudents.value = allStudents.toList();
    } else {
      filteredStudents.value =
          allStudents.where((s) {
            return s.name.toLowerCase().contains(query) ||
                s.regNo.toLowerCase().contains(query) ||
                s.course.toLowerCase().contains(query);
          }).toList();
    }
  }
}
