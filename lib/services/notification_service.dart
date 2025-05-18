import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  // Africa's Talking API configuration
  final String _apiKey; // Your Africa's Talking API key
  final String _username; // Your Africa's Talking username
  final String _baseUrl = 'https://api.africastalking.com/version1/messaging';
  final bool _useSandbox; // Whether to use sandbox environment

  NotificationService({
    required String apiKey,
    required String username,
    bool useSandbox = false,
  }) : _apiKey = apiKey,
        _username = username,
        _useSandbox = useSandbox;

  // Send SMS using Africa's Talking API
  Future<bool> sendSMS({
    required String phone,
    required String message,
  }) async {
    try {
      // Determine which URL to use based on environment
      final url = _useSandbox
          ? 'https://api.sandbox.africastalking.com/version1/messaging'
          : _baseUrl;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'apiKey': _apiKey,
        },
        body: {
          'username': _username,
          'to': phone,
          'message': message,
        },
      );

      final responseData = json.decode(response.body);

      // Log SMS send attempt to Firestore for tracking
      await _logSmsNotification(
        phone: phone,
        message: message,
        success: response.statusCode == 201 || response.statusCode == 200,
        responseData: responseData,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  // Log SMS notification to Firestore
  Future<void> _logSmsNotification({
    required String phone,
    required String message,
    required bool success,
    required Map<String, dynamic> responseData,
  }) async {
    await FirebaseFirestore.instance.collection('sms_notifications').add({
      'phone': phone,
      'message': message,
      'success': success,
      'response': responseData,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  // Send loan reminder notification
  Future<bool> sendLoanReminderNotification({
    required String userId,
    required String phone,
    required double amount,
    required DateTime dueDate,
  }) async {
    final formattedDate = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    final message = 'REMINDER: Your loan payment of KES ${amount.toStringAsFixed(2)} is due on $formattedDate. Please ensure timely payment to avoid penalties.';

    return await sendSMS(
      phone: phone,
      message: message,
    );
  }

  // Send loan approval notification
  Future<bool> sendLoanApprovalNotification({
    required String userId,
    required String phone,
    required double amount,
  }) async {
    final message = 'Congratulations! Your loan request of KES ${amount.toStringAsFixed(2)} has been approved. The funds will be disbursed to your M-Pesa shortly.';

    return await sendSMS(
      phone: phone,
      message: message,
    );
  }

  // Send loan disbursement notification
  Future<bool> sendLoanDisbursementNotification({
    required String userId,
    required String phone,
    required double amount,
    required String transactionId,
  }) async {
    final message = 'Your loan of KES ${amount.toStringAsFixed(2)} has been successfully disbursed to your M-Pesa. Transaction ID: $transactionId.';

    return await sendSMS(
      phone: phone,
      message: message,
    );
  }

  // Send repayment confirmation notification
  Future<bool> sendRepaymentConfirmationNotification({
    required String userId,
    required String phone,
    required double amount,
    required String loanId,
  }) async {
    final message = 'We have received your payment of KES ${amount.toStringAsFixed(2)} for loan ID: $loanId. Thank you for your prompt payment.';

    return await sendSMS(
      phone: phone,
      message: message,
    );
  }
}