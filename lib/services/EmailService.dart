import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String _schoolName = 'University of Mindanao';

  // Gmail SMTP Configuration
  static const String _gmailUsername = 'kakumeiigun@gmail.com';
  static const String _gmailAppPassword = 'blwwqythlqfltlvl'; // App password

  static Future<Map<String, dynamic>> sendAttendanceNotificationWithTracking({
    required String attendanceId,
    required String studentId,
    required String guardianEmail,
    required String studentName,
    required String course,
  }) async {
    debugPrint('EMAIL FUNCTION ENTERED for: $studentName ($guardianEmail)');

    if (guardianEmail.isEmpty || !guardianEmail.contains('@')) {
      debugPrint('Invalid guardian email format');
      return {
        'success': false,
        'error': 'Invalid guardian email',
        'timestamp': FieldValue.serverTimestamp(),
      };
    }

    if (_gmailUsername == 'YOUR_GMAIL@gmail.com') {
      debugPrint('Gmail credentials not configured');
      return {
        'success': false,
        'error': 'Email service not configured. Please contact administrator.',
        'timestamp': FieldValue.serverTimestamp(),
      };
    }

    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    debugPrint('📧 Sending email via Gmail SMTP...');

    try {
      // Configure Gmail SMTP
      final smtpServer = gmail(_gmailUsername, _gmailAppPassword);

      // Create email message
      final message =
          Message()
            ..from = Address(_gmailUsername, 'Qrius Attendance System')
            ..recipients.add(guardianEmail)
            ..subject = '[$_schoolName] Attendance Notification - $studentName'
            ..html = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #800000; color: white; padding: 20px; text-align: center; }
    .content { background-color: #f9f9f9; padding: 20px; margin-top: 20px; border-radius: 5px; }
    .info-row { padding: 10px 0; border-bottom: 1px solid #ddd; }
    .label { font-weight: bold; color: #800000; }
    .status { color: #28a745; font-weight: bold; font-size: 18px; }
    .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>$_schoolName</h1>
      <p>Attendance Notification System</p>
    </div>
    <div class="content">
      <p>Dear Parent/Guardian,</p>
      <p>This is to inform you that your student has successfully marked their attendance.</p>
      
      <div class="info-row">
        <span class="label">Student Name:</span> $studentName
      </div>
      <div class="info-row">
        <span class="label">Course:</span> $course
      </div>
      <div class="info-row">
        <span class="label">Date:</span> $date
      </div>
      <div class="info-row">
        <span class="label">Time:</span> $time
      </div>
      <div class="info-row">
        <span class="label">Status:</span> <span class="status">✓ PRESENT</span>
      </div>
    </div>
    <div class="footer">
      <p>This is an automated notification from the Qrius Attendance System.</p>
      <p>$_schoolName - Attendance Management</p>
    </div>
  </div>
</body>
</html>
        ''';

      debugPrint('Sending email to $guardianEmail...');

      // Send the email
      final sendReport = await send(message, smtpServer);

      debugPrint('Email sent successfully: ${sendReport.toString()}');

      return {
        'success': true,
        'sentAt': FieldValue.serverTimestamp(),
        'messageId': 'smtp-${DateTime.now().millisecondsSinceEpoch}',
        'error': null,
        'method': 'gmail_smtp',
      };
    } on MailerException catch (e) {
      debugPrint('Failed to send email: $e');

      String errorMsg = 'Email send failed';
      if (e.toString().contains('authentication')) {
        errorMsg = 'Gmail authentication failed. Check credentials.';
      } else if (e.toString().contains('connection')) {
        errorMsg = 'Cannot connect to Gmail. Check internet.';
      } else {
        errorMsg = 'Email error: ${e.toString()}';
      }

      return {
        'success': false,
        'error': errorMsg,
        'timestamp': FieldValue.serverTimestamp(),
        'method': 'gmail_smtp',
      };
    } catch (e, stackTrace) {
      debugPrint('Unknown error sending email: $e');
      debugPrint('Stack trace: $stackTrace');

      return {
        'success': false,
        'error': 'Unknown error: $e',
        'timestamp': FieldValue.serverTimestamp(),
        'method': 'gmail_smtp',
      };
    }
  }

  static Future<void> sendAttendanceNotification({
    required String guardianEmail,
    required String studentName,
    required String course,
  }) async {
    await sendAttendanceNotificationWithTracking(
      attendanceId: '',
      studentId: '',
      guardianEmail: guardianEmail,
      studentName: studentName,
      course: course,
    );
  }
}
