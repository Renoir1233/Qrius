import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/services/NotificationServices.dart';
import 'package:qrius/services/firestore_service.dart';

class SignupStudentController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final registrationNumber = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final guardianEmail = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  var selectedCourse = ''.obs;
  var selectedYear = ''.obs;
  var selectedDepartment = ''.obs;

  var courses = <String>[].obs;
  var years = <String>[].obs;
  var departments = <String>[].obs;

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
    ever(selectedCourse, (_) {
      selectedYear.value = '';
      fetchYearsForCourse();
    });
  }

  void fetchCourses() {
    _firestore.collection('courses').snapshots().listen((snapshot) {
      courses.value =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> fetchYearsForCourse() async {
    if (selectedCourse.value.isEmpty) return;
    try {
      final query =
          await _firestore
              .collection('courses')
              .where('name', isEqualTo: selectedCourse.value)
              .get();
      if (query.docs.isNotEmpty) {
        final yearData = query.docs.first['year'] as String;
        final match = RegExp(r'Year (\d+)').firstMatch(yearData);
        if (match != null) {
          final max = int.parse(match.group(1)!);
          years.value = List.generate(max, (i) => 'Year ${i + 1}');
        }
      } else {
        years.clear();
      }
    } catch (_) {
      years.clear();
    }
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

    final regNo = registrationNumber.text.trim();
    final emailText = email.text.trim();
    final studentName = name.text.trim();

    isLoading.value = true;

    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailText,
        password: password.text.trim(),
      );
      final uid = userCredential.user!.uid;

      // Check if registration number already exists (check both field names)
      bool alreadyExists = false;
      try {
        final q1 =
            await _firestore
                .collection('students')
                .where('registrationNumber', isEqualTo: regNo)
                .limit(1)
                .get();
        if (q1.docs.isNotEmpty && q1.docs.first.id != uid) {
          alreadyExists = true;
        }
        if (!alreadyExists) {
          final q2 =
              await _firestore
                  .collection('students')
                  .where('studentNumber', isEqualTo: regNo)
                  .limit(1)
                  .get();
          if (q2.docs.isNotEmpty && q2.docs.first.id != uid) {
            alreadyExists = true;
          }
        }
      } catch (_) {}

      if (alreadyExists) {
        await userCredential.user?.delete();
        isLoading.value = false;
        _showError('This registration number is already registered.');
        return;
      }

      // Save only to students collection (not users)
      await FirestoreService.createStudent(
        studentId: uid,
        name: studentName,
        email: emailText,
        studentNumber: regNo,
        course: selectedCourse.value,
        year: selectedYear.value,
        department: selectedDepartment.value,
        additionalData: {
          'guardianEmail': guardianEmail.text.trim(),
          'role': 'student', // Add role here for clarity
        },
      );

      final box = GetStorage();
      box.write('role', 'student');
      box.write('userId', uid);
      box.write('name', studentName);
      box.write('email', emailText);

      try {
        await NotificationService.initialize();
      } catch (_) {}

      isLoading.value = false;
      Get.offAllNamed('/StudentNavigation');
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
      debugPrint('Student signup error: $e');
    }
  }

  @override
  void onClose() {
    registrationNumber.dispose();
    name.dispose();
    email.dispose();
    guardianEmail.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
