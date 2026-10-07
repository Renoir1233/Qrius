import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Web-only import using conditional import
import 'web_save_stub.dart' if (dart.library.html) 'web_save_helper.dart';

class SaveShareController extends GetxController {
  final ScreenshotController screenshotController = ScreenshotController();

  void _showError(String msg) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccess(String msg) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showError("Grant storage permission to save the QR code.");
          return false;
        }
      } else {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          _showError("Grant photo permission to save the QR code.");
          return false;
        }
      }
    }
    return true;
  }

  /// Save QR Code — saves to gallery on phone, downloads as PNG on web/PC
  Future<void> saveQRCode() async {
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image == null) {
        _showError("Failed to capture QR code.");
        return;
      }

      if (kIsWeb) {
        // 💻 Web/PC: trigger browser download
        final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
        saveImageOnWeb(image, fileName);
        _showSuccess("QR Code downloaded to your PC!");
      } else {
        // 📱 Phone: save to gallery (existing behaviour)
        final hasPermission = await _checkAndRequestPermissions();
        if (!hasPermission) return;

        final result = await ImageGallerySaverPlus.saveImage(
          image,
          quality: 100,
        );
        if (result != null && result['isSuccess'] == true) {
          _showSuccess("QR Code saved to Gallery!");
        } else {
          _showError("Failed to save QR Code.");
        }
      }
    } catch (e) {
      debugPrint("Save QR error: $e");
      _showError("Something went wrong saving the QR code.");
    }
  }

  /// Share QR Code
  Future<void> shareQRCode() async {
    if (kIsWeb) {
      // On web, just trigger a download instead of share
      await saveQRCode();
      return;
    }

    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) return;

    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        await shareQRCodeWithBytes(image);
      }
    } catch (e) {
      _showError("Failed to share QR Code.");
    }
  }

  /// Save QR Code from raw bytes
  Future<void> saveQRCodeWithBytes(Uint8List image) async {
    try {
      if (kIsWeb) {
        // 💻 Web/PC: trigger browser download
        final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
        saveImageOnWeb(image, fileName);
        _showSuccess("QR Code downloaded to your PC!");
      } else {
        // 📱 Phone: save to gallery
        final hasPermission = await _checkAndRequestPermissions();
        if (!hasPermission) return;

        final result = await ImageGallerySaverPlus.saveImage(
          image,
          quality: 100,
        );
        if (result != null && result['isSuccess'] == true) {
          _showSuccess("QR Code saved to Gallery!");
        } else {
          _showError("Failed to save QR Code.");
        }
      }
    } catch (e) {
      debugPrint("Save QR error: $e");
      _showError("Something went wrong saving the QR code.");
    }
  }

  /// Share QR Code from raw bytes
  Future<void> shareQRCodeWithBytes(Uint8List image) async {
    if (kIsWeb) {
      // On web, just trigger a download instead of share
      await saveQRCodeWithBytes(image);
      return;
    }

    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) return;

    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/qr_code.png';
      final file = File(imagePath);
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: "Here is my QR Code.");
      await file.delete();
    } catch (e) {
      _showError("Failed to share QR Code.");
    }
  }
}
