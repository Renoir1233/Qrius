import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/NotificationServices.dart';

class Signoutcontroller extends GetxController {
  void showLoading() {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideDialog() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  Future<void> signOutUser() async {
    final box = GetStorage();
    showLoading();
    await Future.delayed(Duration(milliseconds: 600));
    try {
      await NotificationService.clearTokenOnSignOut();
      await FirebaseAuth.instance.signOut();

      _hideDialog();
      box.remove('role');

      Get.offAllNamed('/');
    } catch (e) {
      _hideDialog();
      Get.snackbar('Error', 'failed to signOut: $e');
    }
  }
}
