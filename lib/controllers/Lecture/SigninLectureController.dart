import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/services/NotificationServices.dart';

class SigninLectureController extends GetxController {
  // Accepts email OR lecturer ID
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

  /// Look up email from lecturer ID across both collections
  Future<String?> _findEmailByLecturerId(String id) async {
    // 1. lecturers collection - employeeId
    try {
      final q =
          await FirebaseFirestore.instance
              .collection('lecturers')
              .where('employeeId', isEqualTo: id)
              .limit(1)
              .get();
      if (q.docs.isNotEmpty) return q.docs.first.data()['email'] as String?;
    } catch (_) {}

    // 2. lectures collection - lectureId
    try {
      final q =
          await FirebaseFirestore.instance
              .collection('lectures')
              .where('lectureId', isEqualTo: id)
              .limit(1)
              .get();
      if (q.docs.isNotEmpty) return q.docs.first.data()['email'] as String?;
    } catch (_) {}

    // 3. lectures collection - employeeId
    try {
      final q =
          await FirebaseFirestore.instance
              .collection('lectures')
              .where('employeeId', isEqualTo: id)
              .limit(1)
              .get();
      if (q.docs.isNotEmpty) return q.docs.first.data()['email'] as String?;
    } catch (_) {}

    return null;
  }

  Future<void> login() async {
    final input = emailController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _showError('Please enter your email/lecturer ID and password');
      return;
    }

    isLoading.value = true;
    try {
      String email = input;

      // If not an email, look up by lecturer ID
      if (!input.contains('@')) {
        final found = await _findEmailByLecturerId(input);
        if (found == null || found.isEmpty) {
          isLoading.value = false;
          _showError('No lecturer found with that ID.');
          return;
        }
        email = found;
      }

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // ✅ Verify this user is actually a lecturer (not student)
      final lecturerDoc =
          await FirebaseFirestore.instance
              .collection('lecturers')
              .doc(uid)
              .get();

      if (!lecturerDoc.exists) {
        // Not a lecturer — sign them out and show error
        await FirebaseAuth.instance.signOut();
        isLoading.value = false;
        _showError(
          'This account is not registered as a lecturer. Please use the student login.',
        );
        return;
      }

      String name = lecturerDoc.data()?['name'] ?? '';

      final box = GetStorage();
      box.write('role', 'lecture');
      box.write('userId', uid);
      box.write('email', email);
      box.write('name', name);

      try {
        await NotificationService.initialize();
      } catch (_) {}

      isLoading.value = false;
      Get.offAllNamed('/LectureNavigation');
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      final errorMsg = _authMessage(e.code, e.message);
      debugPrint('FirebaseAuthException: ${e.code} - $errorMsg');
      _showError(errorMsg);
    } catch (e) {
      isLoading.value = false;
      debugPrint('Lecturer login error: $e');
      _showError('Something went wrong. Please try again.');
    }
  }

  Future<void> resetPassword() async {
    final input = emailController.text.trim();
    if (input.isEmpty) {
      _showError('Enter your email or lecturer ID first');
      return;
    }

    String email = input;
    if (!input.contains('@')) {
      final found = await _findEmailByLecturerId(input);
      if (found == null || found.isEmpty) {
        _showError('No lecturer found with that ID.');
        return;
      }
      email = found;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSuccess('Password reset link sent to $email');
    } catch (_) {
      _showError('Failed to send reset email. Please try again.');
    }
  }

  String _authMessage(String code, String? msg) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found. Please sign up first.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return msg ?? 'Login failed. Please try again.';
    }
  }

  void _showError(String msg) {
    try {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // Fallback if context is not available
        debugPrint('Error (no context): $msg');
        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to show error message: $e');
      debugPrint('Original error message: $msg');
    }
  }

  void _showSuccess(String msg) {
    try {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        debugPrint('Success: $msg');
      }
    } catch (e) {
      debugPrint('Failed to show success message: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
