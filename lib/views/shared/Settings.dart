import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qrius/controllers/Shared/SignOutController.dart';
import 'package:qrius/controllers/Shared/ThemeController.dart';
import 'package:qrius/controllers/Shared/UserSessionController.dart';

class Settings extends StatelessWidget {
  Settings({super.key});
  final UserSessionController sessionController =
      Get.find<UserSessionController>();
  final ThemeController themeController = Get.put(ThemeController());
  final Signoutcontroller _signOut = Get.put(Signoutcontroller());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.onSecondaryFixed,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              // Account Category inside a white container
              Container(
                decoration: BoxDecoration(
                  color: theme.onSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildListTile(
                      icon: Icons.person,
                      title: "Profile",
                      onTap: () {
                        // Handle Profile action
                        final box = GetStorage();
                        final role = box.read('role');

                        if (role == 'student') {
                          Get.toNamed('/Student_Profile');
                        } else if (role == 'lecture') {
                          Get.toNamed('/Lecture_Profile');
                        }
                      },
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.logout_rounded,
                      title: "Sign Out",
                      onTap: () {
                        // Handle Sign Out action with custom dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Sign Out"),
                              content: Text(
                                "Are you sure you want to sign out?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                    _signOut.signOutUser();
                                    sessionController.clearSession();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    "Sign Out",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              const Text(
                "General",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              // General Category inside a white container
              Container(
                decoration: BoxDecoration(
                  color: theme.onSecondary,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildListTile(
                      icon: Icons.nightlight_round,
                      title: "Theme",
                      trailing: Obx(
                        () => Switch(
                          activeColor: theme.onPrimary,
                          value: themeController.isDarkMode.value,
                          onChanged: (value) {
                            themeController.toggleTheme();
                          },
                        ),
                      ),
                      onTap:
                          () {}, // No need for tap if you're using the toggle
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.star_border,
                      title: "Rate us",
                      onTap: () {
                        // Handle Rate us action
                      },
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: "About",
                      onTap: () {
                        // Handle About action
                        Get.toNamed("/About");
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Privacy & Account Terms",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Privacy & Account Terms Category inside a white container
              Container(
                decoration: BoxDecoration(
                  color: theme.onSecondary,
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Adjust the radius as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        // Handle Privacy Policy action
                        Get.toNamed("/PrivacyPolicy");
                      },
                      context: context,
                    ),
                    _buildListTile(
                      icon: Icons.document_scanner_outlined,
                      title: "Terms & Conditions",
                      onTap: () {
                        // Handle Terms & Conditions action
                        Get.toNamed("/TermsConditions");
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    required BuildContext context, // Add BuildContext parameter
  }) {
    final theme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: theme.onPrimary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.onPrimary,
          ),
        ),
        trailing:
            trailing ??
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.onPrimary),
        onTap: onTap,
      ),
    );
  }
}
