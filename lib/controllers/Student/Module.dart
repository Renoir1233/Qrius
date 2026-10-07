import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/Module.dart';

class ModuleController extends GetxController {
  var moduleList = <ModuleModel>[].obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentModules();
  }

  Future<void> fetchStudentModules() async {
    try {
      isLoading.value = true;
      final user = auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      // Step 1: Get student's course and year
      final studentDoc =
          await firestore.collection('students').doc(user.uid).get();
      if (!studentDoc.exists) {
        Get.snackbar("Error", "Student record not found");
        return;
      }

      final studentCourse = studentDoc['course'];
      final studentYear =
          studentDoc['year']; // or 'academicYear' based on your data

      // Step 2: Query course document using both course name and year
      final courseQuery =
          await firestore
              .collection('courses')
              .where('name', isEqualTo: studentCourse)
              .where('year', isEqualTo: studentYear)
              .limit(1)
              .get();

      if (courseQuery.docs.isEmpty) {
        Get.snackbar("Error", "Course not found for selected year");
        return;
      }

      final courseDocId = courseQuery.docs.first.id;

      // Step 3: Fetch modules from the matched course document
      final moduleSnap =
          await firestore
              .collection('courses')
              .doc(courseDocId)
              .collection('modules')
              .get();

      final modules =
          moduleSnap.docs
              .map((doc) => ModuleModel.fromMap(doc.data()))
              .toList();
      moduleList.assignAll(modules);
    } catch (e) {
      Get.snackbar("Error", "Failed to load modules: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
