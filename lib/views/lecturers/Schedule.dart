import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Lecture/ScheduleController.dart';
import 'package:qrius/models/Schedule.dart';

class LectureSchedule extends StatelessWidget {
  final LectureScheduleController controller = Get.find();

  LectureSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Schedule",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Selection Dropdown
                const Text(
                  "Select Course",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value:
                        controller.selectedCourse.value.isEmpty
                            ? null
                            : controller.selectedCourse.value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    items:
                        controller.courses.map((course) {
                          return DropdownMenuItem(
                            value: course,
                            child: Text(course),
                          );
                        }).toList(),
                    onChanged: (value) {
                      controller.setSelectedCourse(value ?? "");
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // "Choose a day" text
                const Text(
                  "Choose a day",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Day selection chips wrapped horizontally
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                                "Monday",
                                "Tuesday",
                                "Wednesday",
                                "Thursday",
                                "Friday",
                              ]
                              .map(
                                (day) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(day),
                                    selected:
                                        controller.selectedDay.value == day,
                                    onSelected: (bool selected) {
                                      if (selected) {
                                        controller.setSelectedDay(day);
                                      }
                                    },
                                    selectedColor: Colors.blue,
                                    backgroundColor: Colors.grey[300],
                                    labelStyle: TextStyle(
                                      color:
                                          controller.selectedDay.value == day
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Schedule list with scroll support
                SizedBox(
                  height: screenHeight * 0.6,
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }
                    List<ScheduleItem> daySchedule =
                        controller.schedules[controller
                            .selectedCourse
                            .value]?[controller.selectedDay.value] ??
                        [];

                    if (daySchedule.isEmpty) {
                      return const Center(
                        child: Text(
                          "No schedule for this day",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: daySchedule.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        var item = daySchedule[index];
                        return Card(
                          color: theme.onSecondary,
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  item.type == "session"
                                      ? Icons.school
                                      : Icons.pause_rounded,
                                  color:
                                      item.type == "session"
                                          ? Colors.blue
                                          : Colors.orange,
                                  size: 30,
                                ),
                                const SizedBox(width: 10),

                                // Schedule details (flexible to avoid overflow)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.subject,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text("Time: ${item.time}"),
                                      Text("Venue: ${item.venue}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
