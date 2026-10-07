import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/SignHistory.dart';
import 'package:intl/intl.dart';

class SignHistoryController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String studentId = FirebaseAuth.instance.currentUser?.uid ?? '';

  var signHistoryList = <SignHistoryModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSignHistory();
  }

  Future<void> fetchSignHistory() async {
    isLoading.value = true;
    signHistoryList.clear();

    try {
      if (studentId.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Fetch login history from students/{studentId}/loginHistory collection
      final loginHistoryQuery =
          await firestore
              .collection('students')
              .doc(studentId)
              .collection('loginHistory')
              .orderBy('loginTime', descending: true)
              .limit(100) // Limit to last 100 logins
              .get();

      List<SignHistoryModel> history = [];

      for (var doc in loginHistoryQuery.docs) {
        final data = doc.data();
        final Timestamp? loginTimestamp = data['loginTime'];
        final String email = data['email'] ?? 'N/A';

        if (loginTimestamp != null) {
          final DateTime loginDateTime = loginTimestamp.toDate();
          final String date = DateFormat('yyyy-MM-dd').format(loginDateTime);
          final String time = DateFormat('hh:mm a').format(loginDateTime);

          history.add(
            SignHistoryModel(
              moduleCode: email, // Display email instead of module code
              timeSigned: "$date at $time",
              status: "Signed In",
            ),
          );
        }
      }

      signHistoryList.assignAll(history);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sign-in history: $e');
      signHistoryList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh the sign-in history
  Future<void> refresh() async {
    await fetchSignHistory();
  }
}
