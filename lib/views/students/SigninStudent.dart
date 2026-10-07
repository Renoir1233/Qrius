import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Student/SigninStudentController.dart';

class SigninStudent extends StatelessWidget {
  final SigninStudentController controller = Get.put(SigninStudentController());

  SigninStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Maroon,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Student Sign In",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome back! Please sign in to continue.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Authentication",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _styledInputField(
                    hintText: "Email or Registration Number",
                    controller: controller.emailController,
                    icon: Icons.person_outlined,
                    keyboardType: TextInputType.emailAddress,
                    context: context,
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => _styledInputField(
                      hintText: "Password",
                      controller: controller.passwordController,
                      icon: Icons.vpn_key,
                      obscure: controller.obscureText.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureText.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.forgotPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Maroon,
                          disabledBackgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child:
                            controller.isLoading.value
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Maroon,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Get.toNamed('/Signup_student'),
                      child: const Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: "Sign up here",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledInputField({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        enabled: true, // Always enabled, even during loading
        cursorColor: Maroon,
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Maroon),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
