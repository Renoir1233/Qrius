import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanDialog {
  // Close any open dialog safely without affecting snackbars
  static void _closeAny() {
    try {
      // Only close if a dialog is actually open
      if (Get.isDialogOpen == true) {
        // Use Navigator.pop with Get.overlayContext to avoid snackbar issues
        if (Get.overlayContext != null) {
          Navigator.of(Get.overlayContext!, rootNavigator: false).pop();
        }
      }
    } catch (e) {
      debugPrint('Error closing dialog: $e');
    }
  }

  static void showLoading() {
    _closeAny(); // Always close anything open first
    try {
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Verifying your attendance...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      debugPrint('ScanDialog.showLoading error: $e');
    }
  }

  static void showResult({required bool success, required String message}) {
    _closeAny(); // Close loading dialog

    try {
      Get.dialog(
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // X button in top-right corner
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        // Close dialog and go back to dashboard
                        try {
                          if (Get.isDialogOpen == true) {
                            Get.back(); // Close dialog
                          }
                          // Navigate back to dashboard
                          Get.offAllNamed('/StudentNavigation');
                        } catch (e) {
                          debugPrint('Error navigating to dashboard: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    success ? "Success!" : "Oops!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: success ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Auto-close after 3 seconds with safer approach
      Future.delayed(const Duration(milliseconds: 3000), () {
        try {
          if (Get.isDialogOpen == true && Get.overlayContext != null) {
            Navigator.of(Get.overlayContext!, rootNavigator: false).pop();
          }
        } catch (e) {
          debugPrint('Error auto-closing result dialog: $e');
        }
      });
    } catch (e) {
      debugPrint('ScanDialog.showResult error: $e');
    }
  }
}
