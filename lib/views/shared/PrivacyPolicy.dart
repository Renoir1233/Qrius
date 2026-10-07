import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "1. Introduction",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Qrius is committed to protecting your privacy. This policy explains how we collect, use, and protect your personal data while using the app.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "2. Information We Collect",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "- Full name, email, registration number or lecture ID\n"
                "- Department and academic year\n"
                "- Attendance records and activity logs\n"
                "- User role (Student, Lecturer, or Admin)",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "3. Why We Collect Your Data",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "- To manage and track attendance records\n"
                "- To provide role-based access and features\n"
                "- To send notifications about attendance or schedules\n"
                "- To ensure system security and usage monitoring",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "4. Data Storage & Security",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "All data is securely stored using Firebase services (Authentication & Firestore). We apply security best practices to protect your information from unauthorized access.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "5. Data Sharing",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "We do not sell or rent your data. Your data is only accessible to school administrators or when required by law.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "6. Your Rights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "You may request to:\n"
                "- View the personal data we store\n"
                "- Correct or update your details\n"
                "- Request deletion of your account (via admin)",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "7. Children's Privacy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Qrius is used in educational settings and may involve students under 18. Usage must be supervised or authorized by school institutions.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "8. Changes to This Policy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "We may update this policy to reflect improvements or legal updates. You’ll be notified of significant changes in the app.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "9. Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "For questions or concerns about this Privacy Policy, please contact your school administrator.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 30),
              Center(
                child: Text(
                  "© 2025 University of Mindanao - Qrius Attendance System",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
