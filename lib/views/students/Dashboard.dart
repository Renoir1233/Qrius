import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Student/DashboardController.dart'; // For navigation

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentDashboardController controller = Get.put(
      StudentDashboardController(),
    );
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2; // Adjust for tablets
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.onSecondaryFixed,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 25),
            ),
            SizedBox(width: 8),
            Obx(() {
              return controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello", style: TextStyle(fontSize: 14)),
                      Text(
                        controller.studentName.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
          child: Column(
            children: [
              // Responsive Grid Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> items = [
                        {
                          'icon': 'assets/icons/scan qr.svg',
                          'label': "Scan QR",
                          'route': '/Scanqr',
                        },
                        {
                          'icon': 'assets/icons/sign-history.svg',
                          'label': "Sign in History",
                          'route': '/SignHistory',
                        },
                      ];

                      return _dashboardItem(
                        iconPath: items[index]['icon']!,
                        label: items[index]['label']!,
                        onTap: () => Get.toNamed(items[index]['route']),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              // "View Attendance" Card
              Card(
                elevation: 3,
                color: theme.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/attendance-person.svg',

                    width: 30,
                    height: 30,
                    color: theme.onPrimary,
                  ),
                  title: Text(
                    "View Attendance",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () => Get.toNamed('/StudentAttendance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: onTap,
          child: Card(
            color:
                theme.secondary, // Changed from Colors.blue to theme.secondary
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 50,
                    height: 50,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
