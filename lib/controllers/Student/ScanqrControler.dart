import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrius/utils/CustomeScandialog.dart';
import 'package:qrius/services/EmailService.dart';
import 'package:zxing_lib/zxing.dart';
import 'package:zxing_lib/common.dart';

class QRScanController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  var isFlashOn = false.obs;
  var isImagePickerActive = false.obs;
  var isQRCodeScanned = false.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    scannerController.toggleTorch();
  }

  void switchCamera() {
    scannerController.switchCamera();
  }

  // Called by camera scanner
  Future<void> handleQRScan(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || isQRCodeScanned.value) return;

    isQRCodeScanned.value = true;
    ScanDialog.showLoading();

    final String? scannedCode = barcodes.first.rawValue;
    await _processScannedCode(scannedCode);

    Future.delayed(const Duration(seconds: 3), () {
      isQRCodeScanned.value = false;
    });
  }

  // Called by gallery upload
  Future<void> pickImageFromGallery() async {
    if (isImagePickerActive.value) return;
    isImagePickerActive.value = true;

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      ScanDialog.showLoading();

      final bytes = await image.readAsBytes();
      String? qrContent;

      // Try mobile_scanner analyzeImage first (mobile only)
      if (!kIsWeb) {
        try {
          final capture = await scannerController
              .analyzeImage(image.path)
              .timeout(const Duration(seconds: 5));
          if (capture != null && capture.barcodes.isNotEmpty) {
            qrContent = capture.barcodes.first.rawValue;
          }
        } catch (_) {
          debugPrint("analyzeImage unavailable, using zxing_lib");
        }
      }

      // Fallback: pure Dart decoder (works everywhere)
      if (qrContent == null || qrContent.isEmpty) {
        qrContent = await _decodeQrFromImageBytes(bytes);
      }

      if (qrContent == null || qrContent.isEmpty) {
        ScanDialog.showResult(
          success: false,
          message: "No QR code found. Please try a clearer photo.",
        );
        return;
      }

      // Process the decoded QR string directly — bypass camera guard
      await _processScannedCode(qrContent);
    } catch (e) {
      debugPrint("Gallery scan error: $e");
      ScanDialog.showResult(
        success: false,
        message: e.toString().replaceFirst("Exception: ", ""),
      );
    } finally {
      isImagePickerActive.value = false;
    }
  }

  // Core logic — shared by camera and gallery
  Future<void> _processScannedCode(String? scannedCode) async {
    try {
      if (scannedCode == null || scannedCode.isEmpty) {
        throw Exception("QR Code is empty.");
      }

      // Decode QR JSON
      Map<String, dynamic> qrData;
      try {
        qrData = jsonDecode(scannedCode);
      } catch (_) {
        throw Exception("Invalid QR code. Please scan a Qrius QR code.");
      }

      final String course = qrData['course'] ?? '';
      final String lecturerId =
          qrData['lecturerId'] ?? qrData['lectureId'] ?? '';
      final String qrDepartment = qrData['department'] ?? '';
      final String secrecyCode = qrData['secrecyCode'] ?? '';
      final double qrLatitude = (qrData['latitude'] ?? 0.0).toDouble();
      final double qrLongitude = (qrData['longitude'] ?? 0.0).toDouble();

      DateTime expiration;
      try {
        expiration = DateTime.parse(qrData['expirationTime']);
      } catch (_) {
        throw Exception("Invalid QR code: bad expiration time.");
      }

      // Parse creation time if available
      DateTime? createdTime;
      try {
        if (qrData.containsKey('dateCreated') &&
            qrData['dateCreated'] != null) {
          createdTime = DateTime.parse(qrData['dateCreated']);
        }
      } catch (_) {}

      if (course.isEmpty) throw Exception("Invalid QR code: missing course.");

      // Check expiry — reject old QR codes
      final now = DateTime.now();

      // Prevent future QR codes (tampering detection)
      if (createdTime != null &&
          now.isBefore(createdTime.subtract(const Duration(minutes: 5)))) {
        throw Exception("Invalid QR code: creation time is in the future.");
      }

      if (now.isAfter(expiration)) {
        final minutesAgo = now.difference(expiration).inMinutes;
        if (minutesAgo < 60) {
          throw Exception(
            "This QR Code expired $minutesAgo minute${minutesAgo == 1 ? '' : 's'} ago.",
          );
        } else {
          final hoursAgo = (minutesAgo / 60).floor();
          throw Exception(
            "This QR Code expired $hoursAgo hour${hoursAgo == 1 ? '' : 's'} ago.",
          );
        }
      }

      // Get student info
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("You must be signed in to mark attendance.");
      }

      final studentId = currentUser.uid;
      final studentDoc =
          await firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) throw Exception("Student record not found.");

      final studentData = studentDoc.data() as Map<String, dynamic>;
      final studentName = studentData['name'] ?? 'Unknown';
      final studentCourse = studentData['course'] ?? '';
      final studentRegNo =
          studentData.containsKey('registrationNumber')
              ? (studentData['registrationNumber'] ?? '')
              : '';
      final guardianEmail = studentData['guardianEmail'] ?? '';

      // Course match
      if (studentCourse.toLowerCase() != course.toLowerCase()) {
        throw Exception("You are not registered in the course '$course'.");
      }

      // Department check
      String lecturerDepartment = qrDepartment;
      if (lecturerDepartment.isEmpty && lecturerId.isNotEmpty) {
        try {
          DocumentSnapshot lDoc =
              await firestore.collection('lecturers').doc(lecturerId).get();
          if (!lDoc.exists) {
            lDoc = await firestore.collection('lectures').doc(lecturerId).get();
          }
          if (lDoc.exists) {
            final lData = lDoc.data() as Map<String, dynamic>? ?? {};
            lecturerDepartment = lData['department'] ?? '';
          }
        } catch (_) {}
      }

      if (lecturerDepartment.isNotEmpty) {
        final cleanLecDept = lecturerDepartment.trim().toLowerCase();
        String studentDepartment = studentData['department'] ?? '';
        if (studentDepartment.isEmpty) {
          try {
            final uDoc =
                await firestore.collection('users').doc(studentId).get();
            studentDepartment =
                (uDoc.data() as Map<String, dynamic>?)?['department'] ?? '';
          } catch (_) {}
        }
        final cleanStudentDept = studentDepartment.trim().toLowerCase();
        bool isDeptMatch =
            cleanStudentDept.isNotEmpty && cleanStudentDept == cleanLecDept;
        if (!isDeptMatch && cleanStudentDept.isEmpty) {
          final c = studentCourse.trim().toLowerCase();
          if (c.contains(cleanLecDept) || cleanLecDept.contains(c)) {
            isDeptMatch = true;
          }
        }
        if (!isDeptMatch) {
          throw Exception(
            "This QR is for '$lecturerDepartment' department only.",
          );
        }
      }

      // 📅 Each QR gets its own attendance document using secrecyCode
      // This allows students to scan multiple QRs per day (different class sessions)
      if (secrecyCode.isEmpty) {
        throw Exception("Invalid QR code: missing secrecy code.");
      }

      final attendanceId = "att_${secrecyCode.replaceAll('secret_', '')}";
      final attendanceRef = firestore
          .collection('attendance')
          .doc(attendanceId);
      final attendanceSnap = await attendanceRef.get();

      // Check if THIS student already scanned THIS specific QR
      if (attendanceSnap.exists) {
        final existingStudents =
            (attendanceSnap.data()?['students'] ?? {}) as Map<String, dynamic>;
        if (existingStudents.containsKey(studentId)) {
          throw Exception(
            "You already scanned this QR. Wait for a new QR from your lecturer.",
          );
        }
      }

      // 📍 Location — optional, 5s timeout
      double distance = 0.0;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          ).timeout(const Duration(seconds: 5));
          if (qrLatitude != 0.0 && qrLongitude != 0.0) {
            distance = Geolocator.distanceBetween(
              qrLatitude,
              qrLongitude,
              position.latitude,
              position.longitude,
            );
            if (distance > 100) {
              throw Exception(
                "You are ${distance.toStringAsFixed(0)}m away. Please move closer.",
              );
            }
          }
        }
      } catch (e) {
        if (e.toString().contains("away")) rethrow;
        debugPrint("Location skipped: $e");
      }

      // ✅ Write attendance with notification tracking
      await attendanceRef.set({
        'course': course,
        'lecturerId': lecturerId,
        'lecturerUid': lecturerId,
        'department': lecturerDepartment,
        'secrecyCode': secrecyCode,
        if (!attendanceSnap.exists) 'createdOn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await attendanceRef.update({
        'students.$studentId': {
          'name': studentName,
          'registrationNumber': studentRegNo,
          'signedAt': FieldValue.serverTimestamp(),
          'distance': distance > 0 ? distance.toStringAsFixed(0) : 'N/A',
          'guardianEmail': guardianEmail,
          'notificationStatus': 'pending',
          'notificationError': null,
        },
      });

      debugPrint("Attendance marked for $studentName in $course");

      // Send guardian email BEFORE showing success dialog
      if (guardianEmail.isNotEmpty) {
        debugPrint(
          "Guardian email found: $guardianEmail - Sending email now...",
        );
        try {
          await _sendEmailWithTracking(
            attendanceId: attendanceId,
            attendanceRef: attendanceRef,
            studentId: studentId,
            guardianEmail: guardianEmail,
            studentName: studentName,
            course: course,
          );
          debugPrint("Email send completed");
        } catch (emailError) {
          debugPrint("Email send failed but not blocking: $emailError");
        }
      } else {
        debugPrint("No guardian email provided for $studentName");
      }

      ScanDialog.showResult(
        success: true,
        message:
            distance > 0
                ? "Attendance marked! ${distance.toStringAsFixed(0)}m from class."
                : "Attendance marked successfully!",
      );
    } catch (e) {
      debugPrint("Scan error: $e");
      ScanDialog.showResult(
        success: false,
        message: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }

  Future<String?> _decodeQrFromImageBytes(Uint8List bytes) async {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final pixels = List<int>.generate(decoded.width * decoded.height, (i) {
        final x = i % decoded.width;
        final y = i ~/ decoded.width;
        final pixel = decoded.getPixel(x, y);
        return (pixel.a.toInt() << 24) |
            (pixel.r.toInt() << 16) |
            (pixel.g.toInt() << 8) |
            pixel.b.toInt();
      });

      final lum = RGBLuminanceSource(decoded.width, decoded.height, pixels);
      final bmp = BinaryBitmap(GlobalHistogramBinarizer(lum));
      final result = MultiFormatReader().decode(bmp);
      return result.text;
    } catch (e) {
      debugPrint("zxing decode error: $e");
      return null;
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}

/// Send email with notification tracking to Firestore
Future<void> _sendEmailWithTracking({
  required String attendanceId,
  required DocumentReference attendanceRef,
  required String studentId,
  required String guardianEmail,
  required String studentName,
  required String course,
}) async {
  debugPrint("🔔 _sendEmailWithTracking CALLED for $guardianEmail");

  // WRITE TO FIRESTORE IMMEDIATELY to confirm function entry
  try {
    await attendanceRef.update({
      'students.$studentId.emailFunctionEntered': true,
      'students.$studentId.emailFunctionEnteredAt':
          FieldValue.serverTimestamp(),
      'students.$studentId.notificationStatus': 'attempting',
    });
    debugPrint("✅ Firestore updated: email function entered");
  } catch (e) {
    debugPrint("❌ Failed to write function entry to Firestore: $e");
  }

  try {
    final result = await EmailService.sendAttendanceNotificationWithTracking(
      attendanceId: attendanceId,
      studentId: studentId,
      guardianEmail: guardianEmail,
      studentName: studentName,
      course: course,
    );

    debugPrint("📧 Email result received: ${result['success']}");

    // Show visible feedback to user
    if (!result['success']) {
      final errorMsg = result['error'] ?? 'Unknown error';
      debugPrint("❌ Email send failed. Error: $errorMsg");

      // Show error dialog to user
      Get.dialog(
        AlertDialog(
          title: const Text('⚠️ Email Not Sent'),
          content: Text(
            'Guardian email failed to send:\n\n$errorMsg\n\nAttendance was still recorded.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      debugPrint("✅ Email sent successfully to $guardianEmail");

      // Show success notification
      Get.rawSnackbar(
        message: '📧 Guardian email sent successfully',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.TOP,
      );
    }

    // Update Firestore with email status
    await attendanceRef.update({
      'students.$studentId.notificationStatus':
          result['success'] ? 'sent' : 'failed',
      'students.$studentId.notificationSentAt':
          result['sentAt'] ?? result['timestamp'],
      'students.$studentId.notificationError': result['error'],
      'students.$studentId.notificationPlatform': result['platform'],
    });

    debugPrint("✅ Firestore notification status updated");
  } catch (e, stackTrace) {
    debugPrint('❌ Email failed with exception: $e');
    debugPrint('❌ Stack trace: $stackTrace');

    // Show error dialog
    Get.dialog(
      AlertDialog(
        title: const Text('⚠️ Email Error'),
        content: Text(
          'Failed to send guardian email:\n\n$e\n\nAttendance was still recorded.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
      barrierDismissible: false,
    );

    // Update Firestore with error status
    try {
      await attendanceRef.update({
        'students.$studentId.notificationStatus': 'failed',
        'students.$studentId.notificationError': e.toString(),
        'students.$studentId.notificationErrorStack': stackTrace
            .toString()
            .substring(0, 500),
      });
    } catch (updateError) {
      debugPrint('❌ Failed to update error status: $updateError');
    }
  }
}
