import 'package:flutter/material.dart';

class TermsCondition extends StatelessWidget {
  const TermsCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 16),

              Text(
                "1. Acceptance of Terms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "By using the Qrius app, you agree to follow these Terms and Conditions. If you do not agree, please do not use the app.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "2. Purpose of the App",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Qrius is designed to help schools, lecturers, and students manage attendance using QR codes. The app is intended strictly for academic use.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "3. User Responsibilities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "- You must provide accurate information when signing up.\n"
                "- You must not misuse the QR system or impersonate others.\n"
                "- You are responsible for keeping your account secure.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "4. Access and Usage",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Access to Qrius is role-based (Student, Lecturer, Admin). Features are restricted based on your assigned role, and misuse may result in suspension.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "5. Intellectual Property",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "All content, icons, and features in Qrius are the property of University of Mindanao. Do not copy or redistribute the app or its code without permission.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "6. Termination",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "We reserve the right to suspend or terminate access to the app if any user violates these terms or engages in harmful activities.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "7. Changes to Terms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "These terms may be updated at any time. Continued use of the app means you accept any changes.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),
              Text(
                "8. Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "If you have questions about these terms, please contact your school administrator.",
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
