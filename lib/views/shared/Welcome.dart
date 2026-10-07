import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrius/config/theme.dart';
import 'package:qrius/controllers/Shared/WelcomeController.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});
  final WelcomeController controller = Get.put(WelcomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Maroon,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
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

                const SizedBox(height: 20),

                // App Name
                const Text(
                  "Qrius",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // Welcome Text
                const Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Description Text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Make attendance easy and stress-free with Qrius - Quick, Secure, and Real-time tracking at your fingertips.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Buttons Section
                Column(
                  children: [
                    // Sign In Button — white outlined
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => controller.handleAuthMode("Sign In"),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Create Account Button — solid white
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => controller.handleAuthMode("Sign Up"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Maroon,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
