import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== USER OPERATIONS ====================
  
  /// Create or update user document
  static Future<void> createUser({
    required String uid,
    required String email,
    required String role,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...additionalData,
      });
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Get user document
  static Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  /// Update user document
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== STUDENT OPERATIONS ====================

  /// Create student profile
  static Future<void> createStudent({
    required String studentId,
    required String name,
    required String email,
    required String studentNumber,
    String? course,
    String? year,
    String? department,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _db.collection('students').doc(studentId).set({
        'name': name,
        'email': email,
        'studentNumber': studentNumber,
        'registrationNumber': studentNumber,
        'course': course,
        'year': year,
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
    } catch (e) {
      throw Exception('Error creating student: $e');
    }
  }

  /// Get student by ID
  static Future<DocumentSnapshot> getStudent(String studentId) async {
    return await _db.collection('students').doc(studentId).get();
  }

  /// Get all students
  static Stream<QuerySnapshot> getStudents() {
    return _db.collection('students').orderBy('name').snapshots();
  }

  /// Update student
  static Future<void> updateStudent(
      String studentId, Map<String, dynamic> data) async {
    await _db.collection('students').doc(studentId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== LECTURER OPERATIONS ====================

  /// Create lecturer profile
  static Future<void> createLecturer({
    required String lecturerId,
    required String name,
    required String email,
    String? department,
    String? employeeId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _db.collection('lecturers').doc(lecturerId).set({
        'name': name,
        'email': email,
        'department': department,
        'employeeId': employeeId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
    } catch (e) {
      throw Exception('Error creating lecturer: $e');
    }
  }

  /// Get lecturer by ID
  static Future<DocumentSnapshot> getLecturer(String lecturerId) async {
    return await _db.collection('lecturers').doc(lecturerId).get();
  }

  // ==================== MODULE OPERATIONS ====================

  /// Create module
  static Future<String> createModule({
    required String name,
    required String code,
    required String lecturerId,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      DocumentReference docRef = await _db.collection('modules').add({
        'name': name,
        'code': code,
        'lecturerId': lecturerId,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating module: $e');
    }
  }

  /// Get modules by lecturer
  static Stream<QuerySnapshot> getModulesByLecturer(String lecturerId) {
    return _db
        .collection('modules')
        .where('lecturerId', isEqualTo: lecturerId)
        .snapshots();
  }

  /// Get all modules
  static Stream<QuerySnapshot> getAllModules() {
    return _db.collection('modules').orderBy('name').snapshots();
  }

  /// Update module
  static Future<void> updateModule(
      String moduleId, Map<String, dynamic> data) async {
    await _db.collection('modules').doc(moduleId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete module
  static Future<void> deleteModule(String moduleId) async {
    await _db.collection('modules').doc(moduleId).delete();
  }

  // ==================== ATTENDANCE OPERATIONS ====================

  /// Record attendance
  static Future<String> recordAttendance({
    required String studentId,
    required String moduleId,
    required String lecturerId,
    required DateTime attendanceDate,
    required String status, // 'present', 'absent', 'late'
    String? remarks,
    Map<String, dynamic>? location,
  }) async {
    try {
      DocumentReference docRef = await _db.collection('attendance').add({
        'studentId': studentId,
        'moduleId': moduleId,
        'lecturerId': lecturerId,
        'attendanceDate': Timestamp.fromDate(attendanceDate),
        'status': status,
        'remarks': remarks,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error recording attendance: $e');
    }
  }

  /// Get attendance by student
  static Stream<QuerySnapshot> getAttendanceByStudent(String studentId) {
    return _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('attendanceDate', descending: true)
        .snapshots();
  }

  /// Get attendance by module
  static Stream<QuerySnapshot> getAttendanceByModule(String moduleId) {
    return _db
        .collection('attendance')
        .where('moduleId', isEqualTo: moduleId)
        .orderBy('attendanceDate', descending: true)
        .snapshots();
  }

  /// Get attendance by date range
  static Future<QuerySnapshot> getAttendanceByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? studentId,
    String? moduleId,
  }) async {
    Query query = _db.collection('attendance');

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (moduleId != null) {
      query = query.where('moduleId', isEqualTo: moduleId);
    }

    query = query
        .where('attendanceDate', isGreaterThanOrEqualTo: startDate)
        .where('attendanceDate', isLessThanOrEqualTo: endDate)
        .orderBy('attendanceDate', descending: true);

    return await query.get();
  }

  // ==================== ANNOUNCEMENT OPERATIONS ====================

  /// Create announcement
  static Future<String> createAnnouncement({
    required String title,
    required String message,
    required String lecturerId,
    String? moduleId,
    List<String>? targetStudents, // null = all students
  }) async {
    try {
      DocumentReference docRef = await _db.collection('announcements').add({
        'title': title,
        'message': message,
        'lecturerId': lecturerId,
        'moduleId': moduleId,
        'targetStudents': targetStudents,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating announcement: $e');
    }
  }

  /// Get announcements
  static Stream<QuerySnapshot> getAnnouncements({String? moduleId}) {
    Query query = _db
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (moduleId != null) {
      query = query.where('moduleId', isEqualTo: moduleId);
    }

    return query.snapshots();
  }

  /// Get announcements by lecturer
  static Stream<QuerySnapshot> getAnnouncementsByLecturer(String lecturerId) {
    return _db
        .collection('announcements')
        .where('lecturerId', isEqualTo: lecturerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete announcement
  static Future<void> deleteAnnouncement(String announcementId) async {
    await _db.collection('announcements').doc(announcementId).update({
      'isActive': false,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== SCHEDULE OPERATIONS ====================

  /// Create schedule
  static Future<String> createSchedule({
    required String moduleId,
    required String lecturerId,
    required String day, // 'Monday', 'Tuesday', etc.
    required String startTime,
    required String endTime,
    required String venue,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      DocumentReference docRef = await _db.collection('schedules').add({
        'moduleId': moduleId,
        'lecturerId': lecturerId,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
        'venue': venue,
        'createdAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating schedule: $e');
    }
  }

  /// Get schedules by module
  static Stream<QuerySnapshot> getSchedulesByModule(String moduleId) {
    return _db
        .collection('schedules')
        .where('moduleId', isEqualTo: moduleId)
        .snapshots();
  }

  /// Get schedules by lecturer
  static Stream<QuerySnapshot> getSchedulesByLecturer(String lecturerId) {
    return _db
        .collection('schedules')
        .where('lecturerId', isEqualTo: lecturerId)
        .snapshots();
  }

  /// Delete schedule
  static Future<void> deleteSchedule(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).delete();
  }

  // ==================== UTILITY METHODS ====================

  /// Batch write example
  static Future<void> batchWrite(
      List<Map<String, dynamic>> operations) async {
    WriteBatch batch = _db.batch();

    for (var operation in operations) {
      DocumentReference docRef =
          _db.collection(operation['collection']).doc(operation['docId']);
      batch.set(docRef, operation['data']);
    }

    await batch.commit();
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
