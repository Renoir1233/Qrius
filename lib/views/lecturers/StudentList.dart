import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Lecture/StudentListControllers.dart';
import 'package:qrius/models/studentList.dart' as model;

class StudentList extends StatelessWidget {
  final StudentListController controller = Get.find();

  StudentList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              cursorColor: Maroon,
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: "Search by name, reg no or course",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Maroon),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Count header
            Obx(() {
              final count = controller.filteredStudents.length;
              return Text(
                "$count student${count == 1 ? '' : 's'} who attended",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              );
            }),

            const SizedBox(height: 12),

            // Student List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Maroon),
                  );
                }

                if (controller.filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No students have scanned attendance yet.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: controller.fetchStudents,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchStudents,
                  color: Maroon,
                  child: ListView.builder(
                    itemCount: controller.filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = controller.filteredStudents[index];
                      return Card(
                        color: theme.onSecondary,
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: umSoftMaroon.withOpacity(0.2),
                            child: Text(
                              student.name.isNotEmpty
                                  ? student.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Maroon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (student.isClassRep)
                                Tooltip(
                                  message: "Class Rep",
                                  child: Icon(
                                    Icons.verified,
                                    color: Maroon,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (student.regNo.isNotEmpty)
                                Text("Reg No: ${student.regNo}"),
                              Text(
                                student.course,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed:
                                () =>
                                    _showStudentDetailsDialog(student, context),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetailsDialog(
    model.StudentList student,
    BuildContext context,
  ) {
    final theme = Theme.of(context).colorScheme;
    Get.dialog(
      Dialog(
        backgroundColor: theme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: umSoftMaroon.withOpacity(0.2),
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Maroon,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (student.isClassRep)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Tooltip(
                          message: "Class Representative",
                          child: Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: umPaleMaroon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (student.regNo.isNotEmpty)
                        _infoRow("Reg No:", student.regNo),
                      if (student.email.isNotEmpty)
                        _infoRow("Email:", student.email),
                      if (student.course.isNotEmpty)
                        _infoRow("Course:", student.course),
                      if (student.year.isNotEmpty)
                        _infoRow("Year:", student.year),
                      _infoRow("Class Rep:", student.isClassRep ? "Yes" : "No"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text("Close"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Maroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
