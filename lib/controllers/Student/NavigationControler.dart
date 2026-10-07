import 'package:get/get.dart';

class StudentnavController extends GetxController {
  // Keep track of the selected index (Home, Notifications, Settings)
  var selectedIndex = 0.obs;

  // Change the selected index when an item is clicked
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
