import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Lecture/DashboardController.dart';

class LectureDashboard extends StatelessWidget {
  const LectureDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final LectureDashboardController controller = Get.put(
      LectureDashboardController(),
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
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello", style: TextStyle(fontSize: 14)),
                      Text(
                        controller.lectureName.value,
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
                    itemCount: 3,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> items = [
                        {
                          'icon': 'assets/icons/generateqr.svg',
                          'label': "Generate QR",
                          'route': '/GenerateQr',
                        },
                        {
                          'icon': 'assets/icons/studentlist.svg',
                          'label': "Student List",
                          'route': '/StudentList',
                        },
                        {
                          'icon': 'assets/icons/announce.svg',
                          'label': "Announcement",
                          'route': '/Announcement',
                        },
                      ];

                      return _dashboardItem(
                        context: context,
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
                  onTap: () => Get.toNamed('/LectureAttendance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: theme.secondary, // Match StudentDashboard's theme
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 50,
                height: 50,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              SizedBox(height: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
  }
}
