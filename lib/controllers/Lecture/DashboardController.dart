// lecture_dashboard_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LectureDashboardController extends GetxController {
  var lectureName = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchLectureName();
    super.onInit();
  }

  void fetchLectureName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Try lecturers collection first (new users)
      var doc =
          await FirebaseFirestore.instance
              .collection('lecturers')
              .doc(uid)
              .get();

      if (doc.exists && doc.data() != null) {
        lectureName.value = doc['name'] ?? 'Unknown';
      } else {
        // Fallback to lectures collection (old users)
        doc =
            await FirebaseFirestore.instance
                .collection('lectures')
                .doc(uid)
                .get();
        if (doc.exists && doc.data() != null) {
          lectureName.value = doc['name'] ?? 'Unknown';
        } else {
          lectureName.value = 'Lecturer';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch Lecturer name: $e');
      lectureName.value = 'Lecturer';
    } finally {
      isLoading.value = false;
    }
  }
}
