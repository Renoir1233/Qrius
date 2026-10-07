import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Lecture/AnnouncementController.dart';

class Announcement extends StatelessWidget {
  final AnnouncementController controller = Get.put(AnnouncementController());

  Announcement({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/AnnouncementHistory'),
            icon: Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Display (Read-only - shows lecturer's registered course)
            Obx(() {
              if (controller.isLoadingCourses.value) {
                return TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.onSecondary,
                    labelText: "Loading....",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                );
              }
              return TextFormField(
                enabled: false, // Read-only field
                controller: TextEditingController(
                  text: controller.selectedCourse.value ?? 'No course assigned',
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.onSecondary,
                  labelText: "Course",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              );
            }),
            SizedBox(height: 25),

            // Title Input
            TextField(
              controller: controller.titleController,
              cursorColor: Colors.blue,
              onChanged: (value) => controller.title.value = value,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.onSecondary,
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Content Input (Multiline)
            TextField(
              controller: controller.contentController,
              cursorColor: Colors.blue,
              onChanged: (value) => controller.content.value = value,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.onSecondary,
                labelText: "Content",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 25),

            // Send Announcement Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isSending.value
                          ? null
                          : controller.sendAnnouncement,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      controller.isSending.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Send Announcement",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
