import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qrius/models/GenerateQrCodeData.dart';

class GenerateQrController extends GetxController {
  final box = GetStorage();

  var generatedQRs = <QRCode>[].obs;
  var selectedCourse = ''.obs;
  var selectedModule = ''.obs;
  var selectedDuration = ''.obs;
  var generatedText = ''.obs;
  var isLoading = false.obs;
  var expirationTime = DateTime.now().obs;
  var remainingTime = "Expired".obs;

  var coursesWithModules = <String, List<String>>{}.obs;
  var durations = RxList<String>([]);

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Rxn<Position> fetchedPosition = Rxn<Position>();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String lecturerUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Safe snackbar that won't crash if Overlay isn't ready
  void _showSnackbar(String title, String message, Color color) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      debugPrint('[$title] $message');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchLecturerCourse(); // Fetch lecturer's registered course first
    fetchDurations();
    loadQRsFromStorage();
    startCountdown();

    // Only fetch location on mobile, not web
    if (!kIsWeb) {
      _getCurrentLocation()
          .then((pos) => fetchedPosition.value = pos)
          .catchError((e) {
            debugPrint("Initial location fetch failed: $e");
            return null;
          });
    }
  }

  /// Fetch the lecturer's registered course from their profile
  Future<void> fetchLecturerCourse() async {
    try {
      debugPrint("Fetching lecturer's registered course");

      if (lecturerUid.isEmpty) {
        debugPrint("No lecturer UID found");
        return;
      }

      // Try lecturers collection first
      DocumentSnapshot lecturerDoc;
      try {
        lecturerDoc =
            await firestore.collection('lecturers').doc(lecturerUid).get();
      } catch (_) {
        // Fallback to lectures collection
        lecturerDoc =
            await firestore.collection('lectures').doc(lecturerUid).get();
      }

      if (lecturerDoc.exists) {
        final data = lecturerDoc.data() as Map<String, dynamic>?;

        // Try multiple possible field names
        String? courseName;

        if (data?['course'] != null) {
          courseName = data!['course'].toString();
        } else if (data?['department'] != null) {
          courseName = data!['department'].toString();
        } else if (data?['details'] != null &&
            data!['details']['courses'] != null) {
          final courses = data['details']['courses'] as List<dynamic>;
          if (courses.isNotEmpty) {
            courseName = courses.first.toString();
          }
        }

        if (courseName != null && courseName.isNotEmpty) {
          selectedCourse.value = courseName;
          debugPrint("Lecturer's course: $courseName");
        } else {
          debugPrint("No course found in lecturer profile");
        }
      } else {
        debugPrint("Lecturer profile not found");
      }
    } catch (e) {
      debugPrint("Error fetching lecturer course: $e");
    }
  }

  Future<void> fetchCourseModulePairs() async {
    try {
      debugPrint("Fetching all courses");
      Map<String, List<String>> courseModules = {};

      final coursesSnapshot = await firestore.collection('courses').get();
      debugPrint("Found ${coursesSnapshot.docs.length} courses");

      for (var courseDoc in coursesSnapshot.docs) {
        String courseName = courseDoc['name'];
        courseModules[courseName] = ['General'];
        debugPrint("Added course: $courseName");
      }

      coursesWithModules.value = courseModules;
      debugPrint("Total courses: ${courseModules.length}");
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
  }

  Future<void> fetchDurations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    durations.value = ['5 min', '10 min', '15 min', '30 min'];
  }

  void loadQRsFromStorage() {
    final storageKey = 'generated_qrs_$lecturerUid';
    List stored = box.read(storageKey) ?? [];

    // Parse QR codes and filter out expired ones
    final now = DateTime.now();
    final allQRs = stored.map((e) => QRCode.fromMap(e)).toList();
    final activeQRs =
        allQRs.where((qr) => qr.expirationTime.isAfter(now)).toList();

    generatedQRs.value = activeQRs;

    // Save back only active QR codes (clean up expired ones)
    if (activeQRs.length != allQRs.length) {
      final activeQRMaps = activeQRs.map((qr) => qr.toMap()).toList();
      box.write(storageKey, activeQRMaps);
      debugPrint(
        "Cleaned up ${allQRs.length - activeQRs.length} expired QR codes",
      );
    }

    debugPrint(
      "Loaded ${generatedQRs.length} active QR codes for lecturer: $lecturerUid",
    );
  }

  Future<Position?> _getCurrentLocation() async {
    // Skip location on web — not supported reliably
    if (kIsWeb) return null;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services disabled");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint("Location permission denied");
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint("Location timed out, proceeding without GPS");
          throw Exception("Location request timed out.");
        },
      );
    } catch (e) {
      debugPrint("Location error (non-critical): $e");
      return null;
    }
  }

  Future<void> generateQRCode() async {
    if (selectedCourse.value.isEmpty || selectedDuration.value.isEmpty) {
      _showSnackbar("Error", "Please select course and duration", Colors.red);
      return;
    }

    isLoading.value = true;

    try {
      // Get Location — optional, won't block QR generation if unavailable
      Position? position = fetchedPosition.value;
      if (position == null && !kIsWeb) {
        position = await _getCurrentLocation();
      }

      final double lat = position?.latitude ?? 0.0;
      final double lng = position?.longitude ?? 0.0;

      String course = selectedCourse.value;
      String module = 'General';
      DateTime now = DateTime.now();

      int minutes = int.parse(selectedDuration.value.split(" ")[0]);
      DateTime newExpirationTime = now.add(Duration(minutes: minutes));
      String secrecyCode = "secret_${now.millisecondsSinceEpoch}";

      // Use secrecyCode in attendance ID so each QR gets a unique document
      String attendanceDocId = "att_${secrecyCode.replaceAll('secret_', '')}";

      // Fetch lecturer name + department
      DocumentSnapshot lecSnap =
          await firestore.collection('lecturers').doc(lecturerUid).get();
      if (!lecSnap.exists) {
        lecSnap = await firestore.collection('lectures').doc(lecturerUid).get();
      }
      final lecData = lecSnap.data() as Map<String, dynamic>? ?? {};
      final lecName = lecData['name'] ?? 'Unknown';
      String lecDepartment = lecData['department'] ?? '';
      if (lecDepartment.isEmpty) {
        final userSnap =
            await firestore.collection('users').doc(lecturerUid).get();
        final userData = userSnap.data() as Map<String, dynamic>? ?? {};
        lecDepartment = userData['department'] ?? '';
      }

      // Build QR model
      final qrCode = QRCode(
        lectureId: lecturerUid,
        course: course,
        module: module,
        dateCreated: now.toString(),
        expirationTime: newExpirationTime,
        secrecyCode: secrecyCode,
        latitude: lat,
        longitude: lng,
      );

      saveQRCodeToStorage(qrCode);
      expirationTime.value = newExpirationTime;

      generatedText.value = jsonEncode({
        ...qrCode.toMap(),
        'lecturerId': lecturerUid,
        'lecturerUid': lecturerUid,
        'department': lecDepartment,
        'lecturerName': lecName,
      });
      selectedModule.value = module;

      // Create attendance record
      try {
        final attRef = firestore.collection('attendance').doc(attendanceDocId);
        final attSnap = await attRef.get();

        final attData = {
          'course': course,
          'module': module,
          'secrecyCode': secrecyCode,
          'expirationTime': Timestamp.fromDate(newExpirationTime),
          'createdOn': Timestamp.now(),
          'createdBy': lecName,
          'lecturerUid': lecturerUid,
          'lecturerId': lecturerUid,
          'department': lecDepartment,
          if (!attSnap.exists) 'students': {},
        };

        await attRef.set(attData, SetOptions(merge: true));
        debugPrint("Attendance record created");
      } catch (e) {
        debugPrint("Attendance creation failed (non-critical): $e");
      }

      startCountdown();
      _showSnackbar("Success", "QR Code generated!", Colors.green);
    } catch (e) {
      debugPrint("QR Generation Error: $e");
      _showSnackbar(
        "Error",
        "QR generation failed: ${e.toString()}",
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void saveQRCodeToStorage(QRCode qrCode) {
    final storageKey = 'generated_qrs_$lecturerUid';
    List stored = box.read(storageKey) ?? [];
    stored.add(qrCode.toMap());
    box.write(storageKey, stored);
    generatedQRs.add(qrCode);
    debugPrint("Saved QR code for lecturer: $lecturerUid");
  }

  List<QRCode> getActiveQRs() {
    DateTime now = DateTime.now();
    return generatedQRs.where((qr) => qr.expirationTime.isAfter(now)).toList();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = expirationTime.value.difference(now);
      if (remaining.isNegative) {
        remainingTime.value = "Expired";
        timer.cancel();
      } else {
        remainingTime.value =
            "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')} remaining";
      }
    });
  }

  bool isModuleActive(String module) => false;

  void loadSelectedQRCode(QRCode qrCode) {
    generatedText.value = jsonEncode({
      'lectureId': qrCode.lectureId,
      'course': qrCode.course,
      'module': qrCode.module,
      'dateCreated': qrCode.dateCreated,
      'expirationTime': qrCode.expirationTime.toIso8601String(),
      'secrecyCode': qrCode.secrecyCode,
      'latitude': qrCode.latitude,
      'longitude': qrCode.longitude,
    });
    expirationTime.value = qrCode.expirationTime;
    selectedModule.value = qrCode.module;
    selectedCourse.value = qrCode.course;
    startCountdown();
  }

  String getFormattedDate() =>
      DateTime.now().toLocal().toString().split(' ')[0];

  List<String> getModulesForSelectedCourse() =>
      coursesWithModules[selectedCourse.value] ?? [];
}
