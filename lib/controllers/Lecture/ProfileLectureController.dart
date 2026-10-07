import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrius/models/LectureProfile.dart';

import '../../services/NotificationServices.dart';

class ProfileLectureController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final picker = ImagePicker();

  var isEditing = false.obs;
  var isLoading = true.obs;
  var showDeleteConfirm = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  var lecturer = Rxn<LectureModel>(); // Nullable, will be loaded async

  @override
  void onInit() {
    super.onInit();
    fetchLectureData();
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  void updateName(String name) {
    final current = lecturer.value;
    if (current != null) {
      lecturer.value = current.copyWith(name: name);
      nameController.text = name;
    }
  }

  void updateEmail(String email) {
    final current = lecturer.value;
    if (current != null) {
      lecturer.value = current.copyWith(email: email);
      emailController.text = email;
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      lecturer.update((l) => l?.copyWith(profileImagePath: picked.path));
      Get.snackbar(
        "Note",
        "Profile picture updated locally but not synced yet.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> fetchLectureData() async {
    isLoading.value = true;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      final doc = await _firestore.collection('lectures').doc(user.uid).get();
      if (!doc.exists) {
        Get.snackbar("Error", "Lecturer data not found");
        return;
      }

      final data = doc.data()!;
      final details = data['details'] ?? {};

      lecturer.value = LectureModel(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        lectureId: data['lectureId'] ?? '',
        department: data['department'] ?? '',
        courses: List<String>.from(details['courses'] ?? []),
        modules: List<String>.from(details['modules'] ?? []),
        profileImagePath: null, // Load from Firestore if stored
      );

      nameController.text = lecturer.value?.name ?? '';
      emailController.text = lecturer.value?.email ?? '';
    } catch (e) {
      Get.snackbar("Error", "Failed to load lecturer data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfileChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updatedName = nameController.text.trim();
    final updatedEmail = emailController.text.trim();
    final current = lecturer.value;

    if (current == null) return;

    final updatedLecturer = current.copyWith(
      name: updatedName,
      email: updatedEmail,
    );

    try {
      await _firestore
          .collection('lectures')
          .doc(user.uid)
          .update(updatedLecturer.toMap());

      lecturer.value = updatedLecturer;
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
        "Failed to update Firestore: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      await _firestore.collection('lectures').doc(user.uid).delete();
      await user.delete(); // Deletes from Firebase Auth
      _hideDialog();

      Get.snackbar(
        "Account Deleted",
        "Lecturer account deleted",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.offAllNamed('/');
    } catch (e) {
      _hideDialog();
      Get.snackbar(
        "Error",
        "Failed to delete: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
