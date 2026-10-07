import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Student/SignupStudentController.dart';
import 'package:qrius/utils/SearchableDropdown.dart';

class SignupStudent extends StatelessWidget {
  SignupStudent({super.key});
  final SignupStudentController controller = Get.put(SignupStudentController());

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
                  "Student Sign Up",
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
                    controller.registrationNumber,
                    "Registration Number",
                    Icons.school_rounded,
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
                  const SizedBox(height: 16),
                  _dropdown(
                    controller.years,
                    "Year",
                    controller.selectedYear,
                    context,
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
                    "Full Name",
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
                  _inputField(
                    controller.guardianEmail,
                    "Guardian Email",
                    Icons.supervisor_account,
                    (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                    context,
                    keyboardType: TextInputType.emailAddress,
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
    BuildContext context, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      enabled: true, // Always enabled, even during loading
      cursorColor: Maroon,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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

  Widget _dropdown(
    List<String> items,
    String hint,
    RxString selected,
    BuildContext context,
  ) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        isExpanded: true,
        value: selected.value.isEmpty ? null : selected.value,
        items:
            items.isEmpty
                ? [
                  const DropdownMenuItem(
                    value: '',
                    enabled: false,
                    child: Text(
                      'No options available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ]
                : items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
        onChanged:
            items.isEmpty
                ? null
                : (value) {
                  if (value != null && value.isNotEmpty) {
                    selected.value = value;
                  }
                },
        decoration: InputDecoration(
          labelText: hint,
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
          prefixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.arrow_drop_down, color: Maroon),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintText: items.isEmpty ? 'Select a course first' : 'Select $hint',
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Please select $hint' : null,
        menuMaxHeight: 300,
      );
    });
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
