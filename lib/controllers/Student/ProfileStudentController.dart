import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrius/models/StudentProfile.dart';

import '../../services/NotificationServices.dart';

class ProfileStudentController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isEditing = false.obs;
  var isLoading = true.obs;
  var showDeleteConfirm = false.obs;

  final picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  var student = Rxn<StudentModel>(); // Nullable because it loads async

  @override
  void onInit() {
    super.onInit();
    fetchStudentData();
  }

  void toggleEdit() => isEditing.value = !isEditing.value;

  void updateName(String name) {
    nameController.text = name;
    student.update((s) => s?.copyWith(name: name));
  }

  void updateEmail(String email) {
    emailController.text = email;
    student.update((s) => s?.copyWith(email: email));
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Update local path only (hardcoded)
      student.update((s) => s?.copyWith(profileImagePath: picked.path));

      // Show snackbar to inform user syncing is not implemented yet
      Get.snackbar(
        "Note",
        "Profile picture updated locally but will not sync to your profile yet.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> fetchStudentData() async {
    isLoading.value = true;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      final doc = await _firestore.collection('students').doc(user.uid).get();
      if (!doc.exists) {
        Get.snackbar("Error", "Student data not found");
        return;
      }

      student.value = StudentModel.fromMap(doc.data()!);

      nameController.text = student.value?.name ?? '';
      emailController.text = student.value?.email ?? '';
    } catch (e) {
      Get.snackbar("Error", "Failed to load student data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfileChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updatedStudent = student.value?.copyWith(
      name: nameController.text,
      email: emailController.text,
    );

    if (updatedStudent != null) {
      try {
        await _firestore
            .collection('students')
            .doc(user.uid)
            .update(updatedStudent.toMap());
        student.value = updatedStudent;
        isEditing.value = false;

        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to save changes: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void loadingDialog() {
    Get.dialog(Center(child: CircularProgressIndicator()));
  }

  void _hideDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> handleDeleteAccount() async {
    loadingDialog();
    try {
      final user = _auth.currentUser;
      if (user == null) throw "No user logged in";

      await NotificationService.clearTokenOnSignOut();
      await _firestore.collection('students').doc(user.uid).delete();
      await user.delete();
      _hideDialog();

      Get.snackbar(
        "Account Deleted",
        "Your student account has been deleted.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.offAllNamed('/');
    } catch (e) {
      _hideDialog();
      Get.snackbar(
        "Error",
        "Failed to delete account: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
