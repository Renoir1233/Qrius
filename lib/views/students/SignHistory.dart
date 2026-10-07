import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Student/SignHistory.dart';
import 'package:qrius/models/SignHistory.dart';

class SignHistory extends StatelessWidget {
  final SignHistoryController controller = Get.find();

  SignHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign in History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          if (controller.signHistoryList.isEmpty) {
            return const Center(
              child: Text(
                "No sign-in history available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Displaying sign-in history as simple ListTiles
          return ListView.builder(
            itemCount: controller.signHistoryList.length,
            itemBuilder: (context, index) {
              SignHistoryModel sign = controller.signHistoryList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.login,
                    color: Colors.blue,
                    size: 32,
                  ),
                  title: Text(
                    sign.status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Email: ${sign.moduleCode}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sign.timeSigned,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
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
