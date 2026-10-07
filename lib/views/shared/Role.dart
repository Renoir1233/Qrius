import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Shared/RoleController.dart';
import 'package:qrius/controllers/Shared/UserSessionController.dart';

class Role extends StatelessWidget {
  final RoleController controller = Get.find();
  final UserSessionController sessionController = Get.find();

  Role({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Maroon,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // App Logo
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: umLightMaroon,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/logos/appLogo_foreground.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Auth Action Text (Sign Up / Sign In)
                        Obx(
                          () => Text(
                            controller.authAction.value ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Switch Action Button
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  String newAction =
                                      controller.authAction.value == "Sign Up"
                                          ? "Sign In"
                                          : "Sign Up";
                                  controller.setAction(newAction);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.swap_horiz_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Switch to ${controller.authAction.value == "Sign Up" ? "Sign In" : "Sign Up"}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        const Text(
                          'Select Your Role',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        const Text(
                          'Please choose how you want to continue',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Role Selection Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _roleOption(
                                icon: Icons.school_outlined,
                                label: 'Student',
                                onTap: () {
                                  sessionController.setRole(UserRole.student);
                                  controller.navigateToRole("student");
                                },
                              ),
                              _roleOption(
                                icon: Icons.cast_for_education_outlined,
                                label: 'Lecturer',
                                onTap: () {
                                  sessionController.setRole(UserRole.lecturer);
                                  controller.navigateToRole("lecture");
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roleOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
