import 'package:get/get.dart';
import 'package:flutter/material.dart';

void showAlert(String title, String message, Color color) {
  // Add small delay to ensure navigation stack is stable
  Future.delayed(const Duration(milliseconds: 300), () {
    // Only show snackbar if we have a valid overlay context
    if (Get.overlayContext != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: color,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        snackStyle: SnackStyle.FLOATING,
      );
    } else {
      // Fallback: print to console if no overlay available
      debugPrint('Alert: $title - $message');
    }
  });
}
