import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:qrius/models/Schedule.dart';

class ScheduleController extends GetxController {
  var isLoading = false.obs;
  var selectedDay = "Monday".obs;
  final schedules = <String, List<ScheduleItem>>{}.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot>? _scheduleStream;

  @override
  void onInit() {
    super.onInit();
    listenToScheduleForStudent();
  }

  void listenToScheduleForStudent() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not signed in.");

      final studentSnapshot =
          await _firestore.collection('students').doc(user.uid).get();
      if (!studentSnapshot.exists) throw Exception("Student not found.");

      final data = studentSnapshot.data()!;
      final course = data['course'] as String;
      final year = data['year'] as String;
      final docId = '${course}_$year';

      _scheduleStream =
          _firestore.collection('schedules').doc(docId).snapshots();

      _scheduleStream!.listen((snapshot) {
        if (!snapshot.exists) {
          Get.snackbar(
            "Not Found",
            "Schedule not available for your course/year",
          );
          return;
        }

        final scheduleData = snapshot.data() as Map<String, dynamic>;
        final loaded = <String, List<ScheduleItem>>{};

        for (var day in [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
        ]) {
          final list = scheduleData[day] as List<dynamic>? ?? [];
          loaded[day] =
              list.map((item) {
                return ScheduleItem(
                  type: item['type'] ?? 'session',
                  subject: item['module'] ?? '',
                  time: item['time'] ?? '',
                  venue: item['venue'] ?? '',
                );
              }).toList();
        }

        schedules.value = loaded;
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedDay(String day) => selectedDay.value = day;

  @override
  void onClose() {
    super.onClose();
    _scheduleStream = null;
  }
}
