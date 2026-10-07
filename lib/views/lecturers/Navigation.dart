import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qrius/controllers/Lecture/NavigationControler.dart';
import 'package:qrius/views/lecturers/Dashboard.dart';
import 'package:qrius/views/shared/Notifications.dart';
import 'package:qrius/views/shared/Settings.dart';

class LectureNavigation extends StatelessWidget {
  const LectureNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final LecturenavController controller = Get.put(LecturenavController());
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          backgroundColor: theme.onSecondary,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          elevation: 8, // Added elevation effect
          selectedItemColor: Colors.blue, // Blue color for selected items
          unselectedItemColor: Colors.grey, // Grey color for unselected items
          showUnselectedLabels: true,
          items: [
            _buildNavItem('assets/icons/home.svg', 'Home', 0, controller),
            _buildNavItem(
              'assets/icons/notification2.svg',
              'Notifications',
              1,
              controller,
            ),
            _buildNavItem(
              'assets/icons/setting.svg',
              'Settings',
              2,
              controller,
            ),
          ],
        );
      }),
      body: Obx(() {
        switch (controller.selectedIndex.value) {
          case 0:
            return LectureDashboard();
          case 1:
            return Notifications();
          case 2:
            return Settings();
          default:
            return LectureDashboard();
        }
      }),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String iconPath,
    String label,
    int index,
    LecturenavController controller,
  ) {
    bool isSelected = controller.selectedIndex.value == index;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: isSelected ? 32 : 24, // Increase size when selected
        height: isSelected ? 32 : 24,
        child: SvgPicture.asset(
          iconPath,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.blue : Colors.grey, // Change color
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }
}
