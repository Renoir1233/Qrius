import 'package:get/get.dart';

class RoleController extends GetxController {
  var authAction = RxnString(); // Nullable observable (no default)

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    print("Arguments received: $args"); // <-- Add this for debugging

    if (args != null && args['mode'] != null) {
      authAction.value = args['mode'];
      print("Mode set to: ${authAction.value}");
    } else {
      print("No mode passed, defaulting...");
      authAction.value = "Sign Up"; // Optional fallback
    }
  }

  void setAction(String action) {
    authAction.value = action;
  }

  void navigateToRole(String role) {
    final mode = authAction.value ?? "Sign Up"; // Fallback if somehow null
    if (mode == "Sign Up") {
      // Get.toNamed("/signup_$role");
      Get.toNamed("/Signup_$role");
    } else {
      Get.toNamed("/Signin_$role");
    }
  }
}
