import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Shared/NotificationController%20.dart';

import 'package:qrius/models/Notification.dart';

void main() {
  late NotificationController notificationController;

  setUp(() {
    notificationController = NotificationController();
    notificationController.onInit(); // simulate fetch
  });

  tearDown(() {
    Get.reset(); // Reset GetX between tests
  });

  group('NotificationController Tests', () {
    test('Initial state has 4 notifications', () {
      expect(notificationController.notifications.length, 4);
    });

    test('Toggle selection adds/removes indexes', () {
      notificationController.toggleSelection(0);
      expect(notificationController.selectedIndexes.contains(0), true);

      notificationController.toggleSelection(0);
      expect(notificationController.selectedIndexes.contains(0), false);
    });

    test('Clear selection removes all selections', () {
      notificationController.toggleSelection(0);
      notificationController.toggleSelection(1);
      notificationController.clearSelection();
      expect(notificationController.selectedIndexes.isEmpty, true);
    });

    testWidgets('Delete and undo restores notifications correctly', (
      tester,
    ) async {
      // Setup minimal widget tree for snackbar context
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        notificationController.toggleSelection(0);
                        notificationController.toggleSelection(1);
                        notificationController.deleteSelectedNotifications();
                      },
                      child: const Text("Delete"),
                    ),
                    Obx(
                      () => Text(
                        "Count: ${notificationController.notifications.length}",
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial count
      expect(find.text("Count: 4"), findsOneWidget);

      // Select and delete first two notifications
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify deletion
      expect(notificationController.notifications.length, 2);
      expect(find.text("Count: 2"), findsOneWidget);

      // Simulate undo action
      notificationController.undoDelete();
      await tester.pump();

      // Verify restoration
      expect(notificationController.notifications.length, 4);
      expect(find.text("Count: 4"), findsOneWidget);

      // Verify original order
      expect(notificationController.notifications[0].from, "Admin");
      expect(notificationController.notifications[1].from, "System");
    });

    testWidgets('Delete all and undo restores correctly', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    for (
                      int i = 0;
                      i < notificationController.notifications.length;
                      i++
                    ) {
                      notificationController.toggleSelection(i);
                    }
                    notificationController.deleteSelectedNotifications();
                  },
                  child: const Text("Delete All"),
                );
              },
            ),
          ),
        ),
      );

      // Delete all
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(notificationController.notifications.isEmpty, true);

      // Undo
      notificationController.undoDelete();
      await tester.pump();

      expect(notificationController.notifications.length, 4);
    });

    test('Copy selected notifications clears selection', () {
      notificationController.toggleSelection(0);
      notificationController.toggleSelection(1);

      expect(notificationController.selectedIndexes.length, 2);

      notificationController.copySelectedNotifications();

      expect(notificationController.selectedIndexes.isEmpty, true);
    });

    test('Undo with empty deleted items does nothing', () {
      final initialNotifications = List<NotificationModel>.from(
        notificationController.notifications,
      );

      notificationController.undoDelete();

      expect(notificationController.notifications, initialNotifications);
    });

    test('Delete with invalid indexes handles gracefully', () {
      // Get initial count
      final initialCount = notificationController.notifications.length;

      // Add both valid and invalid indexes
      notificationController.selectedIndexes.add(0); // Valid
      notificationController.selectedIndexes.add(100); // Invalid

      notificationController.deleteSelectedNotifications();

      // Should only delete the valid one
      expect(notificationController.notifications.length, initialCount - 1);
      expect(notificationController.selectedIndexes.isEmpty, true);

      // Verify undo still works with only valid deletions
      notificationController.undoDelete();
      expect(notificationController.notifications.length, initialCount);
    });
  });
}
