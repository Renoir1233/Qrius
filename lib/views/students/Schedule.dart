import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Student/Schedule.dart';
import 'package:qrius/models/Schedule.dart';

class StudentSchedule extends StatelessWidget {
  final ScheduleController controller = Get.find();

  StudentSchedule({super.key});

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
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                          controller.selectedDay.value = day;
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

                  // Selected day's schedule header
                  Obx(
                    () => Text(
                      "${controller.selectedDay.value} Schedule",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Schedule list with scroll support
                  SizedBox(
                    height: screenHeight * 0.75,
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.schedules.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        );
                      }
                      List<ScheduleItem> daySchedule =
                          controller.schedules[controller.selectedDay.value] ??
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
            ),
          );
        },
      ),
    );
  }
}
