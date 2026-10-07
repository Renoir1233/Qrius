import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:qrius/models/Schedule.dart';

class LectureScheduleController extends GetxController {
  var isLoading = false.obs;
  var selectedCourse = ''.obs;
  var selectedDay = "Monday".obs;

  final courses = <String>[].obs;
  final schedules = <String, Map<String, List<ScheduleItem>>>{}.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot>? _scheduleStream;

  @override
  void onInit() {
    super.onInit();
    listenToCoursesAndSchedules();
  }

  void listenToCoursesAndSchedules() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not signed in.");

      final lectureSnapshot =
          await _firestore.collection('lectures').doc(user.uid).get();
      if (!lectureSnapshot.exists) throw Exception("Lecture not found.");

      final data = lectureSnapshot.data()!;

      // Extract courses array from details.courses (map -> array)
      final details = data['details'] as Map<String, dynamic>? ?? {};
      final List<dynamic> rawCourses = details['courses'] ?? [];

      // Courses in format "Computer Science Year 1"
      // Convert to "Computer Science_Year 1" to match schedule doc IDs
      courses.assignAll(
        rawCourses.map((course) {
          final parts = (course as String).split(' ');
          // Assuming last part is year like "Year 1"
          if (parts.length >= 2) {
            final yearPart = parts.sublist(parts.length - 2).join(' ');
            final courseName = parts.sublist(0, parts.length - 2).join(' ');
            return '${courseName}_$yearPart';
          }
          return course;
        }).toList(),
      );

      if (courses.isEmpty) {
        isLoading.value = false;
        return;
      }

      selectedCourse.value = courses.first;

      // Start listening to schedule for selected course
      _listenToScheduleForCourse(selectedCourse.value);

      // Reactively listen for course changes
      ever(selectedCourse, (course) {
        _listenToScheduleForCourse(course);
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      isLoading.value = false;
    }
  }

  void _listenToScheduleForCourse(String course) {
    _scheduleStream?.drain(); // Cancel previous stream if any
    isLoading.value = true;

    _scheduleStream =
        _firestore.collection('schedules').doc(course).snapshots();

    _scheduleStream!.listen((snapshot) {
      if (!snapshot.exists) {
        schedules[course] = {}; // Clear schedule if none
        isLoading.value = false;
        Get.snackbar(
          "Not Found",
          "Schedule not available for course $course",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
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
            list
                .map(
                  (item) => ScheduleItem(
                    type: item['type'] ?? 'session',
                    subject: item['module'] ?? '',
                    time: item['time'] ?? '',
                    venue: item['venue'] ?? '',
                  ),
                )
                .toList();
      }

      schedules[course] = loaded;
      isLoading.value = false;
    });
  }

  void setSelectedDay(String day) => selectedDay.value = day;

  void setSelectedCourse(String course) => selectedCourse.value = course;

  @override
  void onClose() {
    super.onClose();
    _scheduleStream = null;
  }
}
