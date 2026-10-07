class SignHistoryModel {
  final String moduleCode; // Now stores email or device info
  final String timeSigned; // Now stores login date/time
  final String status; // "Signed In"

  SignHistoryModel({
    required this.moduleCode,
    required this.timeSigned,
    required this.status,
  });

  factory SignHistoryModel.fromMap(Map<String, dynamic> data) {
    return SignHistoryModel(
      moduleCode: data['email'] ?? data['course_code'] ?? '',
      timeSigned: data['time_signed'] ?? '',
      status: data['status'] ?? 'Signed In',
    );
  }
}
