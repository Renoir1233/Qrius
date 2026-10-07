import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:qrius/bindings/LectureBindings.dart';
import 'package:qrius/bindings/SharedBindings.dart';
import 'package:qrius/bindings/StudentBindings.dart';
import 'package:qrius/config/theme.dart';

import 'package:qrius/controllers/Shared/UserSessionController.dart';
import 'package:qrius/controllers/Shared/ThemeController.dart'; //
import 'package:qrius/firebase_options.dart';
import 'package:qrius/views/lecturers/announcementHistory.dart';
import 'package:qrius/views/shared/PrivacyPolicy.dart';
import 'package:qrius/views/shared/TermsConidtion.dart';

// Shared Views
import 'package:qrius/views/shared/Welcome.dart';
import 'package:qrius/views/shared/Role.dart';
import 'package:qrius/views/shared/Settings.dart';
import 'package:qrius/views/shared/attendance.dart';
import 'package:qrius/views/shared/Notifications.dart';
import 'package:qrius/views/shared/About.dart';

// Student Views
import 'package:qrius/views/students/Dashboard.dart';
import 'package:qrius/views/students/Navigation.dart';
import 'package:qrius/views/students/Profile.dart';
import 'package:qrius/views/students/Scanqr.dart';
import 'package:qrius/views/students/SignHistory.dart';
import 'package:qrius/views/students/SigninStudent.dart';
import 'package:qrius/views/students/SignupStudent.dart';

// Lecture Views
import 'package:qrius/views/lecturers/Dashboard.dart';
import 'package:qrius/views/lecturers/Announcement.dart';
import 'package:qrius/views/lecturers/GenerateQr.dart';
import 'package:qrius/views/lecturers/Profile.dart';
import 'package:qrius/views/lecturers/SigninLecture.dart';
import 'package:qrius/views/lecturers/SignupLecture.dart';
import 'package:qrius/views/lecturers/StudentList.dart';
import 'package:qrius/views/lecturers/attendance.dart';
import 'package:qrius/views/lecturers/navigation.dart';

//Background initialization in push notification
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.messageId}');
}

//implement global navigation for ontap pushNotification behaviour

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //init firebaseService
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(UserSessionController());
  Get.put(ThemeController()); // ✅ Inject ThemeController
  // Auth and role check
  final box = GetStorage();
  final user = FirebaseAuth.instance.currentUser;
  final role = box.read('role');
  String initialRoute = '/';
  if (user != null && role != null) {
    if (role == 'student') {
      initialRoute = '/StudentNavigation';
    } else if (role == 'lecture') {
      initialRoute = '/LectureNavigation';
    }
  }

  runApp(MyApp(initialRoute: initialRoute)); //
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>(); // Get theme controller

    return Obx(
      () => GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute, // ← Dynamic
        theme: lightmode,
        darkTheme: darkmode, // Optional: customize your dark theme here
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        getPages: [
          // Shared
          GetPage(name: '/', page: () => WelcomePage()),
          GetPage(name: '/Settings', page: () => Settings()),
          GetPage(name: '/Notification', page: () => Notifications()),
          GetPage(name: '/About', page: () => AboutAppPage()),
          GetPage(name: '/PrivacyPolicy', page: () => PrivacyPolicy()),
          GetPage(name: '/TermsConditions', page: () => TermsCondition()),
          GetPage(
            name: '/Role',
            page: () => Role(),
            binding: RoleBinding(),
            transition: Transition.cupertino,
          ),

          // Students
          GetPage(name: '/StudentDashboard', page: () => StudentDashboard()),
          GetPage(name: '/StudentNavigation', page: () => StudentNavigation()),
          GetPage(name: '/Signin_student', page: () => SigninStudent()),
          GetPage(name: '/Signup_student', page: () => SignupStudent()),
          GetPage(name: '/Student_Profile', page: () => ProfileStudent()),
          GetPage(
            name: '/SignHistory',
            page: () => SignHistory(),
            transition: Transition.cupertino,
            binding: SignHistoryBinding(),
          ),
          GetPage(
            name: '/StudentAttendance',
            page: () => StudentAttendance(),
            binding: StudentAttendanceBinding(),
          ),
          GetPage(
            name: '/Scanqr',
            page: () => Scanqr(),
            binding: ScanqrBinding(),
          ),

          // Lectures
          GetPage(name: '/LectureDashboard', page: () => LectureDashboard()),
          GetPage(name: '/LectureNavigation', page: () => LectureNavigation()),
          GetPage(name: '/Signin_lecture', page: () => SigninLecture()),
          GetPage(name: '/Signup_lecture', page: () => SignupLecture()),
          GetPage(name: '/Lecture_Profile', page: () => ProfileLecture()),
          GetPage(name: '/GenerateQr', page: () => GenerateQr()),
          GetPage(name: '/Announcement', page: () => Announcement()),
          GetPage(
            name: '/AnnouncementHistory',
            page: () => Announcementhistory(),
          ),
          GetPage(
            name: '/StudentList',
            page: () => StudentList(),
            binding: LectureStudentListBinding(),
          ),
          GetPage(
            name: '/LectureAttendance',
            page: () => LectureAttendance(),
            binding: LectureAttendanceBinding(),
          ),
        ],
      ),
    );
  }
}
