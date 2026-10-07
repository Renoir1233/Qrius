import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Shared/NotificationController%20.dart';
import 'package:qrius/models/Notification.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final theme = Theme.of(context).colorScheme;
    return Obx(
      () => Scaffold(
        appBar:
            controller.selectedIndexes.isNotEmpty
                ? _buildSelectionAppBar(controller)
                : AppBar(
                  title: Text(
                    "Notifications",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: theme.onSecondaryFixed,
                ),

        body: Padding(
          padding: EdgeInsets.all(16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            if (controller.notifications.isEmpty) {
              return _buildNoNotifications();
            }

            return ListView.builder(
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final NotificationModel notification =
                    controller.notifications[index];
                bool isSelected = controller.selectedIndexes.contains(index);

                return GestureDetector(
                  onLongPress: () => controller.toggleSelection(index),
                  onTap: () {
                    if (controller.selectedIndexes.isNotEmpty) {
                      controller.toggleSelection(index);
                    } else {
                      // Show modal when notification is clicked
                      _showNotificationModal(context, notification);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    color:
                        isSelected
                            ? umSoftMaroon.withOpacity(0.2)
                            : theme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            "From: ${notification.from}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected ? Maroon : theme.onSurface,
                            ),
                          ),
                          Spacer(),
                          Text(
                            notification.formattedTime,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSelected ? Colors.blue : theme.onPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            notification.content,
                            style: TextStyle(color: theme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  AppBar _buildSelectionAppBar(NotificationController controller) {
    return AppBar(
      title: Text("${controller.selectedIndexes.length} Selected"),
      backgroundColor: Colors.blueAccent,
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: controller.clearSelection,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: controller.copySelectedNotifications,
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: controller.deleteSelectedNotifications,
        ),
      ],
    );
  }

  Widget _buildNoNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No notifications available",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Show modal dialog when notification is tapped
  void _showNotificationModal(
    BuildContext context,
    NotificationModel notification,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: Colors.black87, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Announcement",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey,
                    ),
                  ],
                ),
                Divider(thickness: 2),
                SizedBox(height: 10),

                // From field
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "From: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        notification.from,
                        style: TextStyle(fontSize: 14, color: theme.onSurface),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Time field
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Time: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      notification.formattedTime,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 16),

                // Title - More prominent display
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Content label
                Text(
                  "Message:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),

                // Content (scrollable)
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: theme.onSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        notification.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: theme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
