import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/services/NotificationServices.dart';

class SignupLectureController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final lectureId = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // Changed from department to course
  var selectedCourse = ''.obs;
  var courses = <String>[].obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  void fetchCourses() {
    _firestore.collection('courses').snapshots().listen((snapshot) {
      courses.value =
          snapshot.docs
              .map((doc) => doc.data()['name'] as String? ?? '')
              .where((n) => n.isNotEmpty)
              .toList();
    });
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  void _showError(String msg) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    final id = lectureId.text.trim();
    final mail = email.text.trim();
    final lecturerName = name.text.trim();
    final course = selectedCourse.value;

    isLoading.value = true;

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: password.text.trim(),
      );
      final uid = userCredential.user!.uid;

      // Check if lecturer ID already exists
      bool alreadyExists = false;
      try {
        final q1 =
            await _firestore
                .collection('lecturers')
                .where('employeeId', isEqualTo: id)
                .limit(1)
                .get();
        if (q1.docs.isNotEmpty && q1.docs.first.id != uid) alreadyExists = true;

        if (!alreadyExists) {
          final q2 =
              await _firestore
                  .collection('lectures')
                  .where('lectureId', isEqualTo: id)
                  .limit(1)
                  .get();
          if (q2.docs.isNotEmpty && q2.docs.first.id != uid)
            alreadyExists = true;
        }
      } catch (_) {}

      if (alreadyExists) {
        await userCredential.user?.delete();
        isLoading.value = false;
        _showError('This Lecturer ID is already registered.');
        return;
      }

      // Write only to lecturers collection (single source of truth)
      await _firestore.collection('lecturers').doc(uid).set({
        'name': lecturerName,
        'email': mail,
        'employeeId': id,
        'lectureId': id, // alias for compatibility
        'course': course,
        'department': course, // store course as department for compatibility
        'role': 'lecture',
        'details': {
          'courses': [course],
          'modules': [],
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      final box = GetStorage();
      box.write('role', 'lecture');
      box.write('userId', uid);
      box.write('name', lecturerName);
      box.write('email', mail);

      try {
        await NotificationService.initialize();
      } catch (_) {}

      isLoading.value = false;
      Get.offAllNamed('/LectureNavigation');
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already registered.';
          break;
        case 'weak-password':
          msg = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          msg = 'Invalid email address.';
          break;
        default:
          msg = e.message ?? 'Sign up failed.';
      }
      _showError(msg);
    } catch (e) {
      isLoading.value = false;
      _showError('Something went wrong. Please try again.');
      debugPrint('Lecturer signup error: $e');
    }
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    lectureId.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
