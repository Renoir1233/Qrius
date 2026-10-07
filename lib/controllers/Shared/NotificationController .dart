import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/config/theme.dart';

import 'package:qrius/models/Notification.dart';
import 'package:qrius/services/NotificationServices.dart';

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final selectedIndexes = <int>{}.obs;
  final deletedItems = <NotificationModel>[].obs;
  final deletedIndexes = <int>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();

  StreamSubscription? _adminSub;
  StreamSubscription? _lectureSub;
  StreamSubscription? _personalSub;

  Set<String> deletedHashes = {};
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    NotificationService.requestPermissions();
    _loadDeletedHashes();
    _initListeners();
  }

  void _loadDeletedHashes() {
    final stored = box.read<List>('deletedNotificationHashes');
    if (stored != null) {
      deletedHashes = stored.cast<String>().toSet();
    }
  }

  void _saveDeletedHashes() {
    box.write('deletedNotificationHashes', deletedHashes.toList());
  }

  void _initListeners() async {
    isLoading.value = true;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      isLoading.value = false;
      return;
    }

    final String role = box.read('role') ?? '';
    final String userId = currentUser.uid;

    List<NotificationModel> allNotifications = [];

    _adminSub?.cancel();
    _lectureSub?.cancel();
    _personalSub?.cancel();

    _adminSub = _firestore.collection('sentMessages').snapshots().listen((
      snapshot,
    ) {
      allNotifications.removeWhere((n) => n.from == "Admin");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final audience = data['audience'] ?? 'all';

        if (audience == 'all' ||
            (role == 'student' && audience == 'students') ||
            (role == 'lecture' && audience == 'lecturers')) {
          allNotifications.add(
            NotificationModel(
              from: "Admin",
              title: data['title'] ?? '',
              content: data['body'] ?? '',

              timestamp: (data['timestamp'] as Timestamp).toDate(),
            ),
          );
        }
      }

      _updateAndSort(allNotifications);
    });

    if (role == 'student') {
      try {
        final studentDoc =
            await _firestore.collection('students').doc(userId).get();
        final studentData = studentDoc.data();

        if (studentData != null) {
          final course = studentData['course'] ?? '';
          final year = studentData['year'] ?? '';
          final combinedCourse = "$course $year";

          // Listen to personal notifications subcollection
          _personalSub = _firestore
              .collection('students')
              .doc(userId)
              .collection('notifications')
              .snapshots()
              .listen((snapshot) {
                // Remove old personal notifications before adding new ones
                allNotifications.removeWhere(
                  (n) => n.from != "Admin" && n.from != "Lecturer",
                );

                for (var doc in snapshot.docs) {
                  final data = doc.data();
                  final lecturerName = data['lecturerName'] ?? 'Lecturer';
                  allNotifications.add(
                    NotificationModel(
                      from: lecturerName,
                      title: data['title'] ?? '',
                      content: data['content'] ?? '',
                      timestamp:
                          (data['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.parse(
                            data['createdAt'] ??
                                DateTime.now().toIso8601String(),
                          ),
                    ),
                  );
                }

                _updateAndSort(allNotifications);
              });

          // Also listen to course-wide announcements (legacy)
          _lectureSub = _firestore
              .collection('lectureMessages')
              .where('course', isEqualTo: combinedCourse)
              .snapshots()
              .listen((snapshot) {
                allNotifications.removeWhere((n) => n.from == "Lecturer");

                for (var doc in snapshot.docs) {
                  final data = doc.data();
                  allNotifications.add(
                    NotificationModel(
                      from: "Lecturer",
                      title: data['title'] ?? '',
                      content: data['content'] ?? '',

                      timestamp: (data['timestamp'] as Timestamp).toDate(),
                    ),
                  );
                }

                _updateAndSort(allNotifications);
              });
        }
      } catch (e) {
        print("Error loading student course: $e");
      }
    }

    isLoading.value = false;
  }

  void _updateAndSort(List<NotificationModel> items) {
    final filtered =
        items.where((n) {
          final hash = _generateHash(n);
          final isInDeletedItems = deletedItems.any(
            (d) =>
                d.title == n.title &&
                d.content == n.content &&
                d.timestamp == n.timestamp,
          );
          return !deletedHashes.contains(hash) && !isInDeletedItems;
        }).toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifications.assignAll(filtered);
  }

  String _generateHash(NotificationModel n) {
    return '${n.from}_${n.title}_${n.content}_${n.timestamp.toIso8601String()}';
  }

  void toggleSelection(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
  }

  void clearSelection() => selectedIndexes.clear();

  void deleteSelectedNotifications() {
    if (selectedIndexes.isEmpty) return;

    final validIndexes =
        selectedIndexes
            .where((i) => i >= 0 && i < notifications.length)
            .toList();
    if (validIndexes.isEmpty) {
      selectedIndexes.clear();
      return;
    }

    // Store the actual notification items to delete
    deletedItems.value = validIndexes.map((i) => notifications[i]).toList();
    deletedIndexes.value = validIndexes.toList()..sort();

    // Add their hashes to deleted list
    for (var item in deletedItems) {
      deletedHashes.add(_generateHash(item));
    }
    _saveDeletedHashes();

    // Remove from current list by filtering out deleted hashes
    notifications.removeWhere((n) => deletedHashes.contains(_generateHash(n)));

    selectedIndexes.clear();

    debugPrint(
      "${deletedItems.length} notification(s) deleted and saved to storage",
    );
  }

  void undoDelete() {
    if (deletedItems.isEmpty || deletedIndexes.isEmpty) return;

    for (var item in deletedItems) {
      deletedHashes.remove(_generateHash(item));
    }
    _saveDeletedHashes();

    notifications.addAll(deletedItems);
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    debugPrint("Notifications restored");

    deletedItems.clear();
    deletedIndexes.clear();
  }

  void copySelectedNotifications() {
    if (selectedIndexes.isEmpty) return;

    final text = selectedIndexes
        .map((i) {
          final n = notifications[i];
          return "From: ${n.from}\nTitle: ${n.title}\nContent: ${n.content}\nTime: ${n.timestamp}\n";
        })
        .join("\n-----------------\n");

    Clipboard.setData(ClipboardData(text: text)).then((_) {
      debugPrint("Notifications copied to clipboard");
    });

    clearSelection();
  }

  void sortByTime() {
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  void onClose() {
    _adminSub?.cancel();
    _lectureSub?.cancel();
    _personalSub?.cancel();
    super.onClose();
  }
}
