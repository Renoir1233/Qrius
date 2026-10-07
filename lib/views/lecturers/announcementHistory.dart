import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Lecture/AnnounceHistoryController.dart';
import '../../models/annouHistory.dart';

import 'package:intl/intl.dart'; // for formatting time

class Announcementhistory extends StatelessWidget {
  const Announcementhistory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final controller = Get.put(AnnouncementHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sent Announcements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (controller.announcements.isEmpty) {
          return Center(child: Text("No announcements found."));
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: controller.announcements.length,
          itemBuilder: (context, index) {
            AnnouncementModel announcement = controller.announcements[index];
            return Card(
              color: theme.onSecondary,
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(
                  announcement.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(announcement.content),
                trailing: Text(
                  DateFormat('HH:mm').format(announcement.timestamp),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
