import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Student/Module.dart';
import 'package:qrius/models/Module.dart';

class Modules extends StatelessWidget {
  final ModuleController controller = Get.find();

  Modules({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modules",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (controller.moduleList.isEmpty) {
            return const Center(
              child: Text(
                "No modules available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.moduleList.length,
            itemBuilder: (context, index) {
              ModuleModel module = controller.moduleList[index];
              return Card(
                color: theme.onSecondary,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            module.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Code: ${module.code}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Lecturer: ${module.lecturer}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
