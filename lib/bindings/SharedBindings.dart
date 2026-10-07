import 'package:get/get.dart';
import 'package:qrius/controllers/Shared/NotificationController%20.dart';
import 'package:qrius/controllers/Shared/RoleController.dart';

import 'package:qrius/controllers/Shared/StudentAttendance.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

class StudentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Always create a fresh instance so studentId is re-evaluated on each navigation
    Get.put<AttendanceController>(AttendanceController(), permanent: false);
  }
}

class RoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleController>(() => RoleController());
  }
}
