// Helper script to add test courses and departments to Firestore
// Run this ONCE to populate your database

import 'package:cloud_firestore/cloud_firestore.dart';

class AddTestData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add sample courses
  static Future<void> addCourses() async {
    print(' Adding courses to Firestore...');

    final courses = [
      {'name': 'Computer Science', 'year': 'Year 4'},
      {'name': 'Information Technology', 'year': 'Year 3'},
      {'name': 'Business Administration', 'year': 'Year 4'},
      {'name': 'Engineering', 'year': 'Year 5'},
      {'name': 'Accounting', 'year': 'Year 4'},
      {'name': 'Marketing', 'year': 'Year 3'},
      {'name': 'Education', 'year': 'Year 4'},
      {'name': 'Nursing', 'year': 'Year 4'},
      {'name': 'Architecture', 'year': 'Year 5'},
      {'name': 'Psychology', 'year': 'Year 4'},
    ];

    for (var course in courses) {
      try {
        await _firestore.collection('courses').add(course);
        print(' Added course: ${course['name']}');
      } catch (e) {
        print(' Error adding ${course['name']}: $e');
      }
    }

    print(' Courses added successfully!');
  }

  /// Add sample departments
  static Future<void> addDepartments() async {
    print(' Adding departments to Firestore...');

    final departments = [
      {'name': 'Computer Science'},
      {'name': 'Information Technology'},
      {'name': 'Business'},
      {'name': 'Engineering'},
      {'name': 'Arts and Sciences'},
      {'name': 'Education'},
      {'name': 'Health Sciences'},
      {'name': 'Architecture'},
    ];

    for (var dept in departments) {
      try {
        await _firestore.collection('departments').add(dept);
        print(' Added department: ${dept['name']}');
      } catch (e) {
        print(' Error adding ${dept['name']}: $e');
      }
    }

    print(' Departments added successfully!');
  }

  /// Add both courses and departments
  static Future<void> addAllTestData() async {
    try {
      await addCourses();
      await addDepartments();
      print('\n All test data added successfully!');
      print(' Restart your app to see the data.');
    } catch (e) {
      print(' Error adding test data: $e');
    }
  }
}

/*
HOW TO USE:
===========

Option 1: Add a temporary button in your Welcome page:

ElevatedButton(
  onPressed: () async {
    await AddTestData.addAllTestData();
  },
  child: Text('Add Test Data'),
)

Option 2: Call from anywhere in your app:

import 'package:qrius/utils/add_test_data.dart';
await AddTestData.addAllTestData();

Option 3: Run once in main.dart (then remove):

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Run once, then comment out
  await AddTestData.addAllTestData();
  
  runApp(MyApp());
}

After data is added, REMOVE the button/code!
*/
