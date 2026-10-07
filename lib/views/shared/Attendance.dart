import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Shared/StudentAttendance.dart';

class StudentAttendance extends StatelessWidget {
  // Use find() — binding always puts a fresh instance before this widget builds
  final AttendanceController controller = Get.find<AttendanceController>();

  StudentAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: controller.fetchAllAttendance,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Name
              Obx(
                () => Text(
                  controller.studentName.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Total Attendance Card
              Obx(() {
                final total =
                    controller.presentDays.value + controller.absentDays.value;
                final percentage =
                    total > 0
                        ? ((controller.presentDays.value / total) * 100).round()
                        : 0;

                return Card(
                  elevation: 3,
                  color: Maroon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Percentage circle
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Stats
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Attendance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${controller.presentDays.value} of $total classes',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Summary Row — Present only
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        label: 'Present',
                        count: controller.presentDays.value,
                        color: Colors.green,
                        icon: Icons.check_circle_outline,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        label: 'Total Classes',
                        count: controller.totalAttendance.value,
                        color: Colors.blue,
                        icon: Icons.calendar_today_outlined,
                        theme: theme,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // Attendance Records Header
              const Text(
                'Attendance Records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Attendance List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Maroon),
                    ),
                  );
                }

                if (controller.attendanceDetails
                    .where((d) => d.status == 'Present')
                    .isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No attendance records yet",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      controller.attendanceDetails
                          .where((d) => d.status == 'Present')
                          .length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final presentRecords =
                        controller.attendanceDetails
                            .where((d) => d.status == 'Present')
                            .toList();
                    final detail = presentRecords[index];
                    return Card(
                      color: theme.onSecondary,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.15),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          detail.course.isNotEmpty
                              ? detail.course
                              : "Class Attendance",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              detail.date,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            if (detail.time.isNotEmpty)
                              Text(
                                "Signed at ${detail.time}",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: const Text(
                            "Present",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required ColorScheme theme,
  }) {
    return Card(
      elevation: 2,
      color: theme.onSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
