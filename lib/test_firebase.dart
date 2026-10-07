// Test Firebase Connection
// Run this to verify Firestore is working

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTest {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Test 1: Check Firebase Connection
  static Future<bool> testConnection() async {
    try {
      // Try to access Firestore
      await _firestore.collection('_test').limit(1).get();
      print(' Firebase connection successful!');
      return true;
    } catch (e) {
      print(' Firebase connection failed: $e');
      return false;
    }
  }

  /// Test 2: Write Test Data
  static Future<bool> testWrite() async {
    try {
      // Create a test document
      await _firestore.collection('_test').doc('connection_test').set({
        'message': 'Hello from Qrius!',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'Flutter',
      });
      print(' Write test successful!');
      return true;
    } catch (e) {
      print(' Write test failed: $e');
      print('Note: This might fail if you need authentication in your rules');
      return false;
    }
  }

  /// Test 3: Read Test Data
  static Future<bool> testRead() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('_test').doc('connection_test').get();

      if (doc.exists) {
        print(' Read test successful!');
        print('Data: ${doc.data()}');
        return true;
      } else {
        print(' Document does not exist');
        return false;
      }
    } catch (e) {
      print(' Read test failed: $e');
      return false;
    }
  }

  /// Test 4: Check Auth State
  static Future<void> checkAuthState() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print(' User is signed in: ${user.email}');
      print('User ID: ${user.uid}');
    } else {
      print('ℹ No user signed in');
    }
  }

  /// Run All Tests
  static Future<void> runAllTests() async {
    print('\n Starting Firebase Tests...\n');

    print('Test 1: Connection');
    await testConnection();

    print('\nTest 2: Auth State');
    await checkAuthState();

    print('\nTest 3: Write Data');
    await testWrite();

    print('\nTest 4: Read Data');
    await testRead();

    print('\n All tests completed!\n');
  }
}
