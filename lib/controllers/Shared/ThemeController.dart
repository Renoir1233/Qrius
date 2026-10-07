import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/utils/CustomeSnackBar.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Reactive variable
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromBox();
  }

  // Load theme from GetStorage
  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  // Save theme to GetStorage
  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  // Toggle and apply theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(isDarkMode.value);
    showCustomSnackBar(
      message:
          isDarkMode.value ? 'Dark Mode Activated' : 'Light Mode Activated',
      isDarkMode: isDarkMode.value,
    );
  }
}
