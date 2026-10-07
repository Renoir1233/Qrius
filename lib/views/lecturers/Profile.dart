import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Lecture/ProfileLectureController.dart';

class ProfileLecture extends StatelessWidget {
  final ProfileLectureController controller = Get.put(
    ProfileLectureController(),
  );

  ProfileLecture({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Obx(() {
        final isEditing = controller.isEditing.value;
        final lecturer = controller.lecturer.value;
        final showDeleteConfirm = controller.showDeleteConfirm.value;

        return Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  color: theme.onSecondary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.blue[800],
                              ),
                              onPressed: () {
                                if (controller.isEditing.value) {
                                  controller.toggleEdit();
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                            Text(
                              controller.isEditing.value
                                  ? "Edit Profile"
                                  : "Lecturer Account",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isEditing) {
                              controller.updateName(
                                controller.nameController.text.trim(),
                              );
                              controller.updateEmail(
                                controller.emailController.text.trim(),
                              );
                            }
                            controller.toggleEdit();
                          },
                          icon: Icon(
                            controller.isEditing.value
                                ? Icons.save
                                : Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            controller.isEditing.value ? "Save" : "Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Card
                        Card(
                          color: theme.onSecondary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar at the top center
                                Center(
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 3,
                                          ),
                                          color: Colors.grey[200],
                                          image:
                                              lecturer?.profileImagePath != null
                                                  ? DecorationImage(
                                                    image: FileImage(
                                                      File(
                                                        lecturer!
                                                            .profileImagePath!,
                                                      ),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : null,
                                        ),
                                        child:
                                            lecturer?.profileImagePath == null
                                                ? Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.grey,
                                                )
                                                : null,
                                      ),
                                      if (isEditing)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: controller.pickImage,
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.black54,
                                              child: Icon(
                                                Icons.camera_alt,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                if (lecturer != null) ...[
                                  isEditing
                                      ? _buildEditableField(
                                        label: "Name",
                                        fieldcontrollerr:
                                            controller.nameController,
                                      )
                                      : _buildReadOnlyItem(
                                        "Name",
                                        lecturer.name,
                                      ),

                                  isEditing
                                      ? _buildEditableField(
                                        label: "Email",
                                        fieldcontrollerr:
                                            controller.emailController,
                                      )
                                      : _buildReadOnlyItem(
                                        "Email",
                                        lecturer.email,
                                      ),

                                  _buildReadOnlyItem(
                                    "Lecturer ID",
                                    lecturer.lectureId,
                                  ),
                                  _buildReadOnlyItem(
                                    "Course",
                                    lecturer.courses.join(', '),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        if (!isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text(
                                "Delete Account",
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red),
                                minimumSize: Size.fromHeight(50),
                              ),
                              onPressed:
                                  () =>
                                      controller.showDeleteConfirm.value = true,
                            ),
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Delete Confirmation Modal
            if (showDeleteConfirm)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: theme.onSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            "Delete Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Are you sure you want to delete your lecturer account? This action cannot be undone.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      () =>
                                          controller.showDeleteConfirm.value =
                                              false,
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: theme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: controller.handleDeleteAccount,
                                  child: Text("Delete"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController fieldcontrollerr,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[100]!),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        style: TextStyle(fontSize: 16),
        controller: fieldcontrollerr,
      ),
    );
  }

  Widget _buildReadOnlyItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
