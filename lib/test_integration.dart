// Quick Integration Test
// Add a button somewhere in your app to run this test

import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrius/services/firestore_service.dart';

class IntegrationTest {
  /// Test 1: Check if current user has profile in Firestore
  static Future<void> testUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('❌ No user signed in');
        return;
      }

      print('✅ User signed in: ${user.email}');
      print('   User ID: ${user.uid}');

      // Check if user document exists
      final userDoc = await FirestoreService.getUser(user.uid);

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        print('✅ User document found');
        print('   Name: ${data['name']}');
        print('   Role: ${data['role']}');
        print('   Email: ${data['email']}');
      } else {
        print('❌ User document not found');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  /// Test 2: Check student profile
  static Future<void> testStudentProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('❌ No user signed in');
        return;
      }

      final studentDoc = await FirestoreService.getStudent(user.uid);

      if (studentDoc.exists) {
        final data = studentDoc.data() as Map<String, dynamic>;
        print('   Student profile found');
        print('   Name: ${data['name']}');
        print('   Student Number: ${data['studentNumber']}');
        print('   Course: ${data['course']}');
        print('   Year: ${data['year']}');
      } else {
        print('ℹ️ No student profile (might be a lecturer)');
      }
    } catch (e) {
      print(' Error: $e');
    }
  }

  /// Test 3: Check lecturer profile
  static Future<void> testLecturerProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print(' No user signed in');
        return;
      }

      final lecturerDoc = await FirestoreService.getLecturer(user.uid);

      if (lecturerDoc.exists) {
        final data = lecturerDoc.data() as Map<String, dynamic>;
        print(' Lecturer profile found');
        print('   Name: ${data['name']}');
        print('   Employee ID: ${data['employeeId']}');
        print('   Department: ${data['department']}');
      } else {
        print('ℹ No lecturer profile (might be a student)');
      }
    } catch (e) {
      print(' Error: $e');
    }
  }

  /// Test 4: List recent attendance records
  static Future<void> testAttendance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print(' No user signed in');
        return;
      }

      print(' Fetching attendance records...');

      final attendanceStream = FirestoreService.getAttendanceByStudent(
        user.uid,
      );

      attendanceStream.listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          print('ℹ No attendance records yet');
        } else {
          print(' Found ${snapshot.docs.length} attendance records');

          for (var doc in snapshot.docs.take(5)) {
            final data = doc.data() as Map<String, dynamic>;
            print('   - Date: ${data['attendanceDate']}');
            print('     Status: ${data['status']}');
            print('     Module: ${data['moduleId']}');
            if (data['remarks'] != null) {
              print('     Remarks: ${data['remarks']}');
            }
          }
        }
      });
    } catch (e) {
      print(' Error: $e');
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print('\n🔬 Running Integration Tests...\n');

    print('═══════════════════════════════════');
    print('Test 1: User Profile');
    print('═══════════════════════════════════');
    await testUserProfile();

    print('\n═══════════════════════════════════');
    print('Test 2: Student Profile');
    print('═══════════════════════════════════');
    await testStudentProfile();

    print('\n═══════════════════════════════════');
    print('Test 3: Lecturer Profile');
    print('═══════════════════════════════════');
    await testLecturerProfile();

    print('\n═══════════════════════════════════');
    print('Test 4: Attendance Records');
    print('═══════════════════════════════════');
    await testAttendance();

    print('\n Tests completed!\n');
  }
}

/*
HOW TO USE:
============

1. Add a test button temporarily to any page:

ElevatedButton(
  onPressed: () async {
    await IntegrationTest.runAllTests();
  },
  child: Text('Test Firestore Integration'),
)

2. Or call from console/controller:

await IntegrationTest.runAllTests();

3. Check the debug console for results

*/
