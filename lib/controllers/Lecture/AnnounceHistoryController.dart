import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/annouHistory.dart';

class AnnouncementHistoryController extends GetxController {
  var isLoading = true.obs;
  var announcements = <AnnouncementModel>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  void fetchAnnouncements() async {
    isLoading.value = true;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("No user is signed in.");
        announcements.clear();
        return;
      }

      final lectureId = currentUser.uid;

      final querySnapshot =
          await _firestore
              .collection('lectureMessages')
              .where('id', isEqualTo: lectureId)
              .get();

      final fetchedAnnouncements =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return AnnouncementModel(
              title:
                  data['title'] ?? '', // <-- Fix: Use 'tit' if that's the field
              content: data['content'] ?? '',
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

      fetchedAnnouncements.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      announcements.assignAll(fetchedAnnouncements);
    } catch (e) {
      print("Error fetching announcements: $e");
      announcements.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
