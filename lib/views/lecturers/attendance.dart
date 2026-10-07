import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Lecture/LectureAttendanceControler.dart';
import 'package:qrius/controllers/Shared/UserSessionController.dart';

class LectureAttendance extends StatefulWidget {
  LectureAttendance({Key? key}) : super(key: key);

  @override
  State<LectureAttendance> createState() => _LectureAttendanceState();
}

class _LectureAttendanceState extends State<LectureAttendance> {
  final LectureAttendanceController controller = Get.find();
  final UserSessionController sessionController = Get.find();
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAttendance,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search + Filter
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: searchController,
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search by name or reg no.",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: controller.searchStudents,
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_alt_rounded, size: 35),
                      onSelected: controller.applyFilter,
                      itemBuilder:
                          (context) =>
                              controller.dateFilters
                                  .map(
                                    (date) => PopupMenuItem<String>(
                                      value: date,
                                      child: Text(date),
                                    ),
                                  )
                                  .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter label
                Obx(
                  () => Text(
                    controller.activeFilter.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // Present students only
                Obx(() {
                  final presentList =
                      controller.filteredStudents
                          .where((s) => s.isPresent)
                          .toList();

                  if (presentList.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No students present yet",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${presentList.length} student${presentList.length == 1 ? '' : 's'} present",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: presentList.length,
                        itemBuilder: (context, index) {
                          final student = presentList[index];
                          return Card(
                            color: theme.onSecondary,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Reg No: ${student.registrationNumber}",
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.green,
                              ),
                              onTap:
                                  () => Get.toNamed(
                                    "/StudentAttendance",
                                    arguments: {'studentId': student.id},
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
