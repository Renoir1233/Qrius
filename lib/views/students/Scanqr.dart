import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Student/ScanqrControler.dart';

class Scanqr extends StatelessWidget {
  final QRScanController controller = Get.find();

  Scanqr({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildMobileUI(context);
  }

  Widget _buildUploadUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan QR Code",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 100, color: Maroon),
              const SizedBox(height: 24),
              const Text(
                "Upload QR Code Image",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Select the QR code image from your computer to mark attendance.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: controller.pickImageFromGallery,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    "Upload QR Code Image",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Maroon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileUI(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // QR Scanner Camera View
          MobileScanner(
            controller: controller.scannerController,
            onDetect:
                (BarcodeCapture capture) => controller.handleQRScan(capture),
          ),

          // Cancel button at top left
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),

          // Camera switch and torch at top right
          Positioned(
            top: 50,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: controller.switchCamera,
                ),
                const SizedBox(width: 20),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isFlashOn.value
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: controller.toggleFlash,
                  ),
                ),
              ],
            ),
          ),

          // Scanning frame
          Center(
            child: CustomPaint(
              size: const Size(250, 250),
              painter: CircularBorderPainter(),
            ),
          ),

          // Upload from Gallery button at the bottom
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: controller.pickImageFromGallery,
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text(
                'Upload from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke;

    // Drawing the thinner border on all sides
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(20)),
      paint,
    );

    // Drawing the bold circular corners (top-left, top-right, bottom-left, bottom-right)
    paint.strokeWidth = 6;

    // Top-left corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: 20),
      3.14,
      1.57,
      false,
      paint,
    );

    // Top-right corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, 0), radius: 20),
      4.71,
      1.57,
      false,
      paint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, size.height), radius: 20),
      1.57,
      1.57,
      false,
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width, size.height), radius: 20),
      0,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
