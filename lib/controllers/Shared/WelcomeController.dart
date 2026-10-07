import 'package:get/get.dart';

class WelcomeController extends GetxController {
  // Store current mode: "Signin" or "Signup"
  var authMode = ''.obs;

  void handleAuthMode(String mode) {
    authMode.value = mode;
    Get.toNamed("/Role", arguments: {'mode': mode});
  }
}
