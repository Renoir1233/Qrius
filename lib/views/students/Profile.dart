import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Student/ProfileStudentController.dart';

class ProfileStudent extends StatelessWidget {
  final ProfileStudentController controller = Get.put(
    ProfileStudentController(),
  );

  ProfileStudent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: theme.primary,
      body: Obx(() {
        final isEditing = controller.isEditing.value;
        final student = controller.student.value;
        final showDeleteConfirm = controller.showDeleteConfirm.value;

        // Show loading indicator while student data is loading
        if (student == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

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
                        // Back + Title
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.blue[800],
                              ),
                              onPressed: () {
                                if (isEditing) {
                                  controller.toggleEdit();
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                            Text(
                              isEditing ? "Edit Profile" : "Student Account",
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
                              controller
                                  .saveProfileChanges(); // Save changes on Save button
                            }
                            controller.toggleEdit();
                          },
                          icon: Icon(
                            isEditing ? Icons.save : Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            isEditing ? "Save" : "Edit",
                            style: const TextStyle(color: Colors.white),
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

                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                                // Avatar
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
                                              student.profileImagePath != null
                                                  ? DecorationImage(
                                                    image: FileImage(
                                                      File(
                                                        student
                                                            .profileImagePath!,
                                                      ),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : null,
                                        ),
                                        child:
                                            student.profileImagePath == null
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
                                            onTap: () {
                                              Get.snackbar(
                                                "Coming Soon",
                                                "Profile picture upload feature coming soon!",
                                                backgroundColor: Colors.orange,
                                                colorText: Colors.white,
                                              );
                                            },
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

                                isEditing
                                    ? _buildEditableField(
                                      label: "Name",
                                      controller: controller.nameController,
                                    )
                                    : _buildReadOnlyItem("Name", student.name),

                                isEditing
                                    ? _buildEditableField(
                                      label: "Email",
                                      controller: controller.emailController,
                                    )
                                    : _buildReadOnlyItem(
                                      "Email",
                                      student.email,
                                    ),

                                _buildReadOnlyItem(
                                  "Student ID",
                                  student.registrationNumber,
                                ),
                                _buildReadOnlyItem("Course", student.course),
                                _buildReadOnlyItem(
                                  "Academic Year",
                                  student.year,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Delete Button
                        if (!isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                "Delete Account",
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                minimumSize: const Size.fromHeight(50),
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
                          const Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Delete Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Are you sure you want to delete your student account? This action cannot be undone.",
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

                                  child: const Text("Delete"),
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
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        cursorColor: Colors.blue,
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
        style: const TextStyle(fontSize: 16),
        controller: controller,
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
