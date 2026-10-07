import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Lecture/SignupLectureController.dart';
import 'package:qrius/utils/SearchableDropdown.dart';

class SignupLecture extends StatelessWidget {
  SignupLecture({super.key});
  final SignupLectureController controller = Get.put(SignupLectureController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Maroon,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Lecturer Sign Up",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your account to get started.",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Academic Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),

                _sectionCard([
                  _inputField(
                    controller.lectureId,
                    "Lecturer ID",
                    Icons.badge,
                    (v) => v!.isEmpty ? 'Required' : null,
                    context,
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdown(
                    items: controller.courses,
                    label: "Course",
                    selected: controller.selectedCourse,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please select a course'
                                : null,
                  ),
                ], context),

                const SizedBox(height: 30),
                const Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),

                _sectionCard([
                  _inputField(
                    controller.name,
                    "Lecturer Name",
                    Icons.person,
                    (v) => v!.isEmpty ? 'Required' : null,
                    context,
                  ),
                  const SizedBox(height: 16),
                  _inputField(
                    controller.email,
                    "Email",
                    Icons.email,
                    (v) => v!.isEmpty ? 'Required' : null,
                    context,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _passwordField(
                      controller.password,
                      "Password",
                      controller.obscurePassword.value,
                      controller.togglePasswordVisibility,
                      context,
                    ),
                  ),
                ], context),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Maroon,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Sign in here",
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
    );
  }

  Widget _sectionCard(List<Widget> children, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator,
    BuildContext context,
  ) {
    return TextFormField(
      enabled: true, // Always enabled, even during loading
      cursorColor: Maroon,
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(icon, color: Maroon),
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Maroon),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Maroon, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label,
    bool isObscured,
    VoidCallback toggle,
    BuildContext context,
  ) {
    return TextFormField(
      enabled: true, // Always enabled, even during loading
      cursorColor: Maroon,
      controller: controller,
      obscureText: isObscured,
      validator: (value) => value!.isEmpty ? 'Required' : null,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(Icons.lock, color: Maroon),
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Maroon),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Maroon, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility : Icons.visibility_off,
            color: Maroon,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}
