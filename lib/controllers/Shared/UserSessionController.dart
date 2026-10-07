import 'package:get/get.dart';

enum UserRole { student, lecturer, none }

class UserSessionController extends GetxController {
  var role = UserRole.student.obs; // default: student

  void setRole(UserRole newRole) => role.value = newRole;

  void clearSession() {
    role.value = UserRole.none;
    // userId.value = ''; // if you're storing user ID
    // Clear other session data if needed
  }
}
