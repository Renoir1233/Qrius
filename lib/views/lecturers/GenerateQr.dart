import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrius/controllers/Lecture/GenerateQrControler.dart';
import 'package:qrius/controllers/Lecture/SaveShareController.dart';
import 'package:qrius/models/GenerateQrCodeData.dart';
import 'package:screenshot/screenshot.dart';

class GenerateQr extends StatefulWidget {
  const GenerateQr({super.key});

  @override
  State<GenerateQr> createState() => _GenerateQrState();
}

class _GenerateQrState extends State<GenerateQr> {
  final GenerateQrController controller = Get.put(GenerateQrController());
  final SaveShareController _saveShareController = Get.put(
    SaveShareController(),
  );

  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    // Tick every second to update the countdown timers in the list
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet(context);
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  String _getTimeRemaining(DateTime expirationTime) {
    final now = DateTime.now();
    final remaining = expirationTime.difference(now);
    if (remaining.isNegative) return "Expired";
    return "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')} remaining";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.onSecondaryFixed,
        title: const Text(
          "Generate QR Code",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showBottomSheet(context),
            icon: SvgPicture.asset(
              'assets/icons/generateqr.svg',
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final activeQRs =
            controller.generatedQRs
                .where((qr) => qr.expirationTime.isAfter(DateTime.now()))
                .toList();

        if (activeQRs.isEmpty) {
          return Center(
            child: Card(
              margin: const EdgeInsets.all(20),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 80,
                      color: Colors.blue.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No QR Codes Generated Yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap the icon above to generate a QR code",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeQRs.length,
          itemBuilder: (context, index) {
            final qr = activeQRs[index];
            final isLatest = index == activeQRs.length - 1;
            return _QRCodeCard(
              qr: qr,
              index: index,
              isLatest: isLatest,
              timeRemaining: _getTimeRemaining(qr.expirationTime),
              controller: controller,
              saveShareController: _saveShareController,
            );
          },
        );
      }),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      backgroundColor: theme.onSecondary,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: bottomPadding + 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Generate QR Code",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Course display (locked - shows lecturer's registered course)
                Obx(() {
                  return TextFormField(
                    enabled: false,
                    controller: TextEditingController(
                      text:
                          controller.selectedCourse.value.isEmpty
                              ? 'Loading course...'
                              : controller.selectedCourse.value,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      labelText: "Course",
                      labelStyle: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // History button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final active = controller.getActiveQRs();
                      if (active.isEmpty) {
                        // Show dialog instead of snackbar
                        Get.dialog(
                          AlertDialog(
                            title: const Text("History"),
                            content: const Text("No active QR codes."),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Active QR Codes"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 300,
                              child: ListView.builder(
                                itemCount: active.length,
                                itemBuilder: (context, index) {
                                  final qr = active[index];
                                  return ListTile(
                                    title: Text("Course: ${qr.course}"),
                                    subtitle: Text(
                                      "Expires: ${qr.expirationTime}",
                                    ),
                                    trailing: const Icon(Icons.qr_code),
                                    onTap: () {
                                      controller.loadSelectedQRCode(qr);
                                      Get.back();
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("View History"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Duration dropdown
                Obx(() {
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value:
                        controller.selectedDuration.value.isEmpty
                            ? null
                            : controller.selectedDuration.value,
                    hint: const Text("Select Duration"),
                    items:
                        controller.durations
                            .map(
                              (duration) => DropdownMenuItem(
                                value: duration,
                                child: Text(duration),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      controller.selectedDuration.value = value ?? '';
                    },
                  );
                }),

                const SizedBox(height: 24),

                // Generate QR Button
                Obx(() {
                  final canGenerate =
                      controller.selectedCourse.value.isNotEmpty &&
                      controller.selectedDuration.value.isNotEmpty;

                  return ElevatedButton.icon(
                    onPressed:
                        canGenerate
                            ? () async {
                              await controller.generateQRCode();
                              if (context.mounted) Navigator.pop(context);
                            }
                            : null,
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    label: const Text(
                      'Generate QR Code',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: canGenerate ? Colors.blue : Colors.grey,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Separate widget for each QR card to prevent rebuild issues
class _QRCodeCard extends StatefulWidget {
  final QRCode qr;
  final int index;
  final bool isLatest;
  final String timeRemaining;
  final GenerateQrController controller;
  final SaveShareController saveShareController;

  const _QRCodeCard({
    required this.qr,
    required this.index,
    required this.isLatest,
    required this.timeRemaining,
    required this.controller,
    required this.saveShareController,
  });

  @override
  State<_QRCodeCard> createState() => _QRCodeCardState();
}

class _QRCodeCardState extends State<_QRCodeCard> {
  late ScreenshotController _screenshotController;

  @override
  void initState() {
    super.initState();
    // Each card gets its own screenshot controller with unique key
    _screenshotController = ScreenshotController();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.timeRemaining == "Expired";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isLatest ? Colors.blue : Colors.grey.shade300,
          width: widget.isLatest ? 2 : 1,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: widget.isLatest,
        leading: Icon(
          Icons.qr_code_2,
          color: widget.isLatest ? Colors.blue : Colors.grey,
        ),
        title: Text(
          "QR Code ${widget.index + 1} - ${widget.qr.course}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.isLatest ? Colors.blue : Colors.black87,
          ),
        ),
        subtitle: Text(
          isExpired ? "Expired" : "${widget.timeRemaining} remaining",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isExpired ? Colors.red : Colors.green[700],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: Column(
                    children: [
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 12,
                              spreadRadius: 3,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: jsonEncode(widget.qr.toMap()),
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.circle,
                            color: Colors.blue,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // QR Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow("Course", widget.qr.course),
                            _detailRow(
                              "Generated on",
                              widget.qr.dateCreated.split(' ')[0],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          widget.controller.generatedText.value = jsonEncode(
                            widget.qr.toMap(),
                          );
                          widget.controller.expirationTime.value =
                              widget.qr.expirationTime;
                          widget.controller.selectedCourse.value =
                              widget.qr.course;
                          // Capture and share using local screenshot controller
                          final image = await _screenshotController.capture();
                          if (image != null) {
                            await widget.saveShareController
                                .shareQRCodeWithBytes(image);
                          }
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text("Share"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          widget.controller.generatedText.value = jsonEncode(
                            widget.qr.toMap(),
                          );
                          widget.controller.expirationTime.value =
                              widget.qr.expirationTime;
                          widget.controller.selectedCourse.value =
                              widget.qr.course;
                          // Capture and save using local screenshot controller
                          final image = await _screenshotController.capture();
                          if (image != null) {
                            await widget.saveShareController
                                .saveQRCodeWithBytes(image);
                          }
                        },
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text("Save"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
