const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

/**
 * Cloud Function to send attendance notification emails via EmailJS
 * Triggered by HTTPS request from the Flutter app
 */
exports.sendAttendanceEmail = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send emails'
    );
  }

  // Validate required fields
  const { guardianEmail, studentName, course } = data;
  
  if (!guardianEmail || !guardianEmail.includes('@')) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Valid guardian email is required'
    );
  }

  if (!studentName || !course) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Student name and course are required'
    );
  }

  // EmailJS configuration
  const EMAILJS_SERVICE_ID = 'service_bedgj4w';
  const EMAILJS_TEMPLATE_ID = 'template_tm9nxyf';
  const EMAILJS_PUBLIC_KEY = 'IFK1PM9EkLIDsxfBU';
  const EMAILJS_URL = 'https://api.emailjs.com/api/v1.0/email/send';

  // Get current date and time
  const now = new Date();
  const date = now.toISOString().split('T')[0];
  const time = now.toTimeString().split(' ')[0].substring(0, 5);

  // Prepare EmailJS payload
  const payload = {
    service_id: EMAILJS_SERVICE_ID,
    template_id: EMAILJS_TEMPLATE_ID,
    user_id: EMAILJS_PUBLIC_KEY,
    template_params: {
      email: guardianEmail,
      to_name: 'Parent/Guardian',
      student_name: studentName,
      course: course,
      date: date,
      time: time,
      school_name: 'University of Mindanao',
      status: 'PRESENT',
    },
  };

  try {
    console.log('Sending email to:', guardianEmail);
    
    // Send email via EmailJS
    const response = await axios.post(EMAILJS_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 30000,
    });

    console.log('Email sent successfully:', response.data);

    return {
      success: true,
      message: 'Email sent successfully',
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    };

  } catch (error) {
    console.error('Failed to send email:', error.message);
    
    // Return error but don't throw - we want the client to handle it gracefully
    return {
      success: false,
      error: error.response?.data || error.message,
      message: 'Failed to send email',
    };
  }
});

/**
 * Background function to send emails when attendance is marked
 * Triggered automatically by Firestore writes
 */
exports.onAttendanceMarked = functions.firestore
  .document('attendance/{attendanceId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const attendanceId = context.params.attendanceId;

    // Check for new students added
    const beforeStudents = before.students || {};
    const afterStudents = after.students || {};

    const promises = [];

    for (const [studentId, studentData] of Object.entries(afterStudents)) {
      // Skip if student was already there or already has notification sent
      if (beforeStudents[studentId] || studentData.notificationStatus === 'sent') {
        continue;
      }

      const guardianEmail = studentData.guardianEmail;
      
      if (!guardianEmail || !guardianEmail.includes('@')) {
        console.log(`No valid guardian email for student ${studentId}`);
        continue;
      }

      console.log(`Sending email for new attendance: ${studentId} -> ${guardianEmail}`);

      // Send email via EmailJS
      const promise = sendEmailViaEmailJS({
        guardianEmail,
        studentName: studentData.name || 'Student',
        course: after.course || 'Course',
      })
        .then(async (result) => {
          // Update Firestore with result
          await change.after.ref.update({
            [`students.${studentId}.notificationStatus`]: result.success ? 'sent' : 'failed',
            [`students.${studentId}.notificationSentAt`]: admin.firestore.FieldValue.serverTimestamp(),
            [`students.${studentId}.notificationError`]: result.error || null,
          });
          console.log(`Email notification updated for ${studentId}: ${result.success ? 'sent' : 'failed'}`);
        })
        .catch((error) => {
          console.error(`Failed to process email for ${studentId}:`, error);
        });

      promises.push(promise);
    }

    await Promise.all(promises);
    return null;
  });

/**
 * Helper function to send email via EmailJS
 */
async function sendEmailViaEmailJS({ guardianEmail, studentName, course }) {
  const EMAILJS_SERVICE_ID = 'service_bedgj4w';
  const EMAILJS_TEMPLATE_ID = 'template_tm9nxyf';
  const EMAILJS_PUBLIC_KEY = 'IFK1PM9EkLIDsxfBU';
  const EMAILJS_URL = 'https://api.emailjs.com/api/v1.0/email/send';

  const now = new Date();
  const date = now.toISOString().split('T')[0];
  const time = now.toTimeString().split(' ')[0].substring(0, 5);

  const payload = {
    service_id: EMAILJS_SERVICE_ID,
    template_id: EMAILJS_TEMPLATE_ID,
    user_id: EMAILJS_PUBLIC_KEY,
    template_params: {
      email: guardianEmail,
      to_name: 'Parent/Guardian',
      student_name: studentName,
      course: course,
      date: date,
      time: time,
      school_name: 'University of Mindanao',
      status: 'PRESENT',
    },
  };

  try {
    const response = await axios.post(EMAILJS_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 30000,
    });

    return {
      success: true,
      message: 'Email sent successfully',
    };
  } catch (error) {
    console.error('EmailJS error:', error.message);
    return {
      success: false,
      error: error.response?.data || error.message,
    };
  }
}
