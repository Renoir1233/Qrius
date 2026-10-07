// lecture_dashboard_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StudentDashboardController extends GetxController {
  var studentName = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchStudentName();
    super.onInit();
  }

  void fetchStudentName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(uid)
              .get();
      if (doc.exists) {
        studentName.value = doc['name'] ?? 'Unknown';
      }
    } catch (e) {
      Get.snackbar('Error', 'failed to fetch Student name $e');
    } finally {
      isLoading.value = false;
    }
  }
}
