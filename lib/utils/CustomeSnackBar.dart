import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar({required String message, required bool isDarkMode}) {
  Get.snackbar(
    '',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
    colorText: isDarkMode ? Colors.white : Colors.black,
    // icon: Icon(
    //   isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
    //   color: isDarkMode ? Colors.white : Colors.black,
    // ),
    borderRadius: 30,
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    duration: Duration(seconds: 2),
    shouldIconPulse: false,
    borderColor: Colors.transparent,
    borderWidth: 0,
    maxWidth: 200,
    snackStyle: SnackStyle.FLOATING,
    // Align the icon and message in one line using Row
    titleText: SizedBox.shrink(), // Hide the title
    messageText: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        SizedBox(width: 8), // Add space between the icon and text
        Text(
          message,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ],
    ),
  );
}
