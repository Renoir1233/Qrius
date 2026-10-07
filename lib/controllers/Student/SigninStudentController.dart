import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/services/NotificationServices.dart';

class SigninStudentController extends GetxController {
  // Field accepts email OR registration number
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscureText = true.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

  Future<void> login() async {
    final input = emailController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _showError('Please enter your email/registration number and password');
      return;
    }

    isLoading.value = true;
    try {
      String email = input;

      // If not an email, look up the email by registration number
      if (!input.contains('@')) {
        String? found;

        // Try registrationNumber field
        try {
          final q =
              await FirebaseFirestore.instance
                  .collection('students')
                  .where('registrationNumber', isEqualTo: input)
                  .limit(1)
                  .get();
          if (q.docs.isNotEmpty) {
            found = q.docs.first.data()['email'] as String?;
          }
        } catch (_) {}

        // Try studentNumber field as fallback
        if (found == null || found.isEmpty) {
          try {
            final q =
                await FirebaseFirestore.instance
                    .collection('students')
                    .where('studentNumber', isEqualTo: input)
                    .limit(1)
                    .get();
            if (q.docs.isNotEmpty) {
              found = q.docs.first.data()['email'] as String?;
            }
          } catch (_) {}
        }

        if (found == null || found.isEmpty) {
          isLoading.value = false;
          _showError('No student found with that registration number.');
          return;
        }
        email = found;
      }

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // ✅ Verify this user is actually a student (not lecturer)
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(uid)
              .get();

      if (!studentDoc.exists) {
        // Not a student — sign them out and show error
        await FirebaseAuth.instance.signOut();
        isLoading.value = false;
        _showError(
          'This account is not registered as a student. Please use the lecturer login.',
        );
        return;
      }

      String name = studentDoc.data()?['name'] ?? '';

      // ✅ Record login history for this student
      await _recordLoginHistory(uid, name, email);

      final box = GetStorage();
      box.write('role', 'student');
      box.write('userId', uid);
      box.write('email', email);
      box.write('name', name);

      try {
        await NotificationService.initialize();
      } catch (_) {}

      isLoading.value = false;
      Get.offAllNamed('/StudentNavigation');
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      final errorMsg = _authMessage(e.code, e.message);
      debugPrint('FirebaseAuthException: ${e.code} - $errorMsg');
      _showError(errorMsg);
    } catch (e) {
      isLoading.value = false;
      debugPrint('Student login error: $e');
      _showError('Something went wrong. Please try again.');
    }
  }

  Future<void> forgotPassword() async {
    final input = emailController.text.trim();
    if (input.isEmpty) {
      _showError('Enter your email or registration number first');
      return;
    }

    String email = input;

    if (!input.contains('@')) {
      String? found;
      try {
        final q =
            await FirebaseFirestore.instance
                .collection('students')
                .where('registrationNumber', isEqualTo: input)
                .limit(1)
                .get();
        if (q.docs.isNotEmpty) found = q.docs.first.data()['email'] as String?;
      } catch (_) {}

      if (found == null || found.isEmpty) {
        _showError('No student found with that registration number.');
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

  /// Record student login history in Firestore
  Future<void> _recordLoginHistory(
    String studentId,
    String studentName,
    String email,
  ) async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      // Create login history document in students/{studentId}/loginHistory collection
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .collection('loginHistory')
          .add({
            'studentName': studentName,
            'email': email,
            'loginTime': FieldValue.serverTimestamp(),
            'date': dateStr,
            'timestamp': now.millisecondsSinceEpoch,
          });

      debugPrint('Login history recorded for student: $studentName');
    } catch (e) {
      debugPrint('Failed to record login history: $e');
      // Don't block login if history recording fails
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
