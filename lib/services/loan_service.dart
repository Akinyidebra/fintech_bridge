import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fintech_bridge/models/provider_model.dart' as model;
import 'package:fintech_bridge/services/mpesa_service.dart';
import 'package:fintech_bridge/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;
import 'package:fintech_bridge/models/notification_model.dart';

class LoanService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MpesaService _mpesaService;
  final NotificationService _notificationService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Constructor with dependency injection
  LoanService(
      {required MpesaService mpesaService,
      required NotificationService notificationService})
      : _mpesaService = mpesaService,
        _notificationService = notificationService;

  // Factory method to create an initialized instance
  factory LoanService.initialize() {
    // Initialize MpesaService
    final mpesaService = MpesaService.initialize(
      consumerKey: 'gKJtz1baDAmDzqG84feLzLw3uWWWfYgJI8GH5PN79Ben8mDU',
      consumerSecret:
          'HF4Z29wIGs4cnFOmkGWtYddpQNtH8pcR74ICnMqcIboYIct9PAMDRNtCXZOkq7Pj',
      passKey:
          'Co9cjuHbCPsj7Oos3vcG8izCnzBib4ALfqK3OOUZJEal2EHon987MGMCFd/IQ4wzkJI3caLWw60fz/KlqVK5E4AED0Bvqts4qBhqPr5TkLDDPu8/No28h11J6lXdYlmCCguhTlpKzq0qrl9NKREsGWRowGlsyQNiWXhDdW3GmPa30mW3e0r16asD93bWKzP2kBbhUAn2fWWuwOMCGVGemlJjTugbTyT/eIpAK131L/ruebjYBmCAu6zwiEMhleywctX/khKDnSfaRhUQ1GyiEVWcqtBV1wW/5XiVel9pNf/SKt4GI61uMbIDhQyHjaQNxgvK7OxnZcfApU9qvZHKVA==',
      isProduction: false,
    );

    // Initialize NotificationService
    final notificationService = NotificationService(
      apiKey:
          'atsk_8a2a76f117fdaa91a739c1537be52fd7a500145f8b980029bf664c430e779f6ff0150334',
      username: 'sandbox',
      useSandbox: true,
    );

    return LoanService(
        mpesaService: mpesaService, notificationService: notificationService);
  }

  // Dispose all resources
  @override
  void dispose() {
    _mpesaService.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  // Helper method to get current student
  Future<dynamic> getCurrentStudent() async {
    try {
      final studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        throw Exception('Student profile not found');
      }
      return studentDoc.data();
    } catch (e) {
      throw Exception('Failed to get student information: $e');
    }
  }

  Future<List<model.Provider>> getApprovedProviders() async {
    try {
      final snapshot = await _firestore
          .collection('providers')
          .where('approved', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => model.Provider.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching providers: $e');
    }
  }

  Future<Map<String, dynamic>> createLoanRequest({
    required String providerId,
    required double amount,
    required String purpose,
    required DateTime dueDate,
    required double interestRate,
    required int termMonths,
    required double monthlyPayment,
    required String repaymentMethod,
    required DateTime repaymentStartDate,
    required String providerName,
    required String loanType,
    required String institutionName,
    required String mpesaPhone,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Please sign in to request a loan'
        };
      }

      final studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {
          'success': false,
          'message': 'Only verified students can request loans'
        };
      }

      final loan = Loan(
        id: '',
        studentId: currentUser!.uid,
        providerId: providerId,
        amount: amount,
        status: 'PENDING',
        purpose: purpose,
        dueDate: dueDate,
        interestRate: interestRate,
        termMonths: termMonths,
        monthlyPayment: monthlyPayment,
        remainingBalance: amount,
        nextDueDate: repaymentStartDate,
        mpesaTransactionCode: '',
        repaymentMethod: repaymentMethod,
        repaymentStartDate: repaymentStartDate,
        latePaymentPenaltyRate: 5.0, // Default penalty rate
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        providerName: providerName,
        loanType: loanType,
        institutionName: institutionName,
        mpesaPhone: mpesaPhone,
      );

      final loanRef = await _firestore.collection('loans').add(loan.toMap());

      // Create notification for the student
      final notification = AppNotification(
        id: '',
        userId: currentUser!.uid,
        title: 'Loan Request Submitted',
        body:
            'Your loan request for KES ${amount.toStringAsFixed(2)} has been submitted for review.',
        type: 'LOAN_REQUEST',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toJson());

      // Send push notification
      try {
        final studentData = await getCurrentStudent();
        if (studentData != null && studentData['deviceToken'] != null) {
          await _notificationService.sendPushNotification(
            phone: studentData['deviceToken'],
            title: notification.title,
            body: notification.body,
            data: {'type': notification.type, 'loanId': loanRef.id},
          );
        }
      } catch (e) {
        // Log notification error but continue with success response
        print('Push notification failed: $e');
      }

      return {
        'success': true,
        'message': 'Loan request submitted for review',
        'loan': loan.copyWith(id: loanRef.id)
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to submit loan request: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoanById(String loanId) async {
    _setLoading(true);
    try {
      final doc = await _firestore.collection('loans').doc(loanId).get();
      return doc.exists
          ? {'success': true, 'data': Loan.fromFirestore(doc)}
          : {'success': false, 'message': 'Loan not found'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load loan details: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStudentLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Student account not found'};
      }

      final loanDocs = await _firestore
          .collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .get();

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to load your loans: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getProviderLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final providerDoc =
          await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'Provider account not found'};
      }

      final loanDocs = await _firestore
          .collection('loans')
          .where('providerId', isEqualTo: currentUser!.uid)
          .get();

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to load provider loans: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateLoanStatus(String loanId, String status,
      {String? mpesaTransactionCode}) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      if (!['APPROVED', 'REJECTED', 'PAID'].contains(status)) {
        return {'success': false, 'message': 'Invalid status update'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final isAdmin =
          (await _firestore.collection('admins').doc(currentUser!.uid).get())
              .exists;

      if (loan.providerId != currentUser!.uid && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': DateTime.now(),
      };

      // Add M-Pesa transaction code if provided
      if (mpesaTransactionCode != null && status == 'APPROVED') {
        updateData['mpesaTransactionCode'] = mpesaTransactionCode;
      }

      await _firestore.collection('loans').doc(loanId).update(updateData);

      if (status == 'APPROVED') {
        // Disburse via M-Pesa
        final mpesaResult = await _mpesaService.disburseLoan(
          phone: loan.mpesaPhone,
          amount: loan.amount,
          loanId: loan.id,
          businessShortCode: '174379', // From provider data
          callbackUrl: 'https://yourapp.com/mpesa-callback',
        );

        if (!mpesaResult['success']) {
          // If M-Pesa fails, revert the status
          await _firestore.collection('loans').doc(loanId).update({
            'status': 'PENDING',
            'updatedAt': DateTime.now(),
          });
          return {
            'success': false,
            'message': 'Failed to disburse loan: ${mpesaResult['message']}'
          };
        }

        final transaction = tm.Transaction(
          id: '',
          loanId: loanId,
          amount: loan.amount,
          type: 'DISBURSEMENT',
          createdAt: DateTime.now(),
          status: 'COMPLETED',
          description:
              'Loan disbursement via M-Pesa. Transaction ID: ${mpesaResult['transactionId'] ?? 'N/A'}',
        );
        await _firestore.collection('transactions').add(transaction.toMap());

        // Update student's hasActiveLoan status
        await _firestore.collection('students').doc(loan.studentId).update({
          'hasActiveLoan': true,
          'updatedAt': DateTime.now(),
        });

        // Create notification for the student
        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: 'Loan Approved',
          body:
              'Your loan request for KES ${loan.amount.toStringAsFixed(2)} has been approved! Funds will be disbursed shortly.',
          type: 'LOAN_APPROVAL',
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('notifications').add(notification.toJson());

        // Send push notification
        try {
          final studentDoc =
              await _firestore.collection('students').doc(loan.studentId).get();
          final studentData = studentDoc.data();
          if (studentData != null && studentData['deviceToken'] != null) {
            await _notificationService.sendPushNotification(
              phone: studentData['deviceToken'],
              title: notification.title,
              body: notification.body,
              data: {'type': notification.type, 'loanId': loanId},
            );
          }
        } catch (e) {
          // Log notification error but continue with success response
          print('Push notification failed: $e');
        }
      } else if (status == 'REJECTED') {
        // Create notification for rejection
        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: 'Loan Request Rejected',
          body:
              'Your loan request for KES ${loan.amount.toStringAsFixed(2)} has been rejected. Please contact support for more information.',
          type: 'LOAN_REJECTION',
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('notifications').add(notification.toJson());

        // Send push notification
        try {
          final studentDoc =
              await _firestore.collection('students').doc(loan.studentId).get();
          final studentData = studentDoc.data();
          if (studentData != null && studentData['deviceToken'] != null) {
            await _notificationService.sendPushNotification(
              phone: studentData['deviceToken'],
              title: notification.title,
              body: notification.body,
              data: {'type': notification.type, 'loanId': loanId},
            );
          }
        } catch (e) {
          // Log notification error but continue with success response
          print('Push notification failed: $e');
        }
      } else if (status == 'PAID') {
        // Update student's hasActiveLoan status
        await _firestore.collection('students').doc(loan.studentId).update({
          'hasActiveLoan': false,
          'updatedAt': DateTime.now(),
        });

        // Create notification for the student
        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: 'Loan Fully Paid',
          body:
              'Congratulations! Your loan of KES ${loan.amount.toStringAsFixed(2)} has been fully paid.',
          type: 'LOAN_PAID',
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('notifications').add(notification.toJson());

        // Send push notification
        try {
          final studentDoc =
              await _firestore.collection('students').doc(loan.studentId).get();
          final studentData = studentDoc.data();
          if (studentData != null && studentData['deviceToken'] != null) {
            await _notificationService.sendPushNotification(
              phone: studentData['deviceToken'],
              title: notification.title,
              body: notification.body,
              data: {'type': notification.type, 'loanId': loanId},
            );
          }
        } catch (e) {
          // Log notification error but continue with success response
          print('Push notification failed: $e');
        }
      }

      return {
        'success': true,
        'message': 'Loan status updated to ${status.toLowerCase()}'
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to update loan status: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> recordPayment({
    required String loanId,
    required double amount,
    required String mpesaTransactionCode,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);

      // Verify the student is making the payment
      if (loan.studentId != currentUser!.uid) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      // Verify M-Pesa transaction
      final mpesaVerification = await _mpesaService.verifyTransaction(
        transactionCode: mpesaTransactionCode,
        amount: amount,
      );

      if (!mpesaVerification['success']) {
        return {
          'success': false,
          'message':
              'M-Pesa transaction verification failed: ${mpesaVerification['message']}'
        };
      }

      // Create a payment transaction
      final transaction = tm.Transaction(
        id: '',
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: DateTime.now(),
        status: 'COMPLETED',
        description:
            'Loan repayment via M-Pesa. Transaction ID: $mpesaTransactionCode',
      );

      await _firestore.collection('transactions').add(transaction.toMap());

      // Update loan remaining balance
      double newBalance = loan.remainingBalance - amount;
      if (newBalance <= 0) {
        // Loan is fully paid
        await updateLoanStatus(loanId, 'PAID');

        return {
          'success': true,
          'message': 'Payment recorded successfully. Loan fully paid!'
        };
      } else {
        // Calculate next due date (30 days from now)
        DateTime nextDueDate = DateTime.now().add(const Duration(days: 30));

        await _firestore.collection('loans').doc(loanId).update({
          'remainingBalance': newBalance,
          'nextDueDate': nextDueDate,
          'updatedAt': DateTime.now(),
        });

        // Create payment notification
        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: 'Payment Received',
          body:
              'Your payment of KES ${amount.toStringAsFixed(2)} has been received. Remaining balance: KES ${newBalance.toStringAsFixed(2)}',
          type: 'PAYMENT_CONFIRMATION',
          isRead: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('notifications').add(notification.toJson());

        // Send push notification
        try {
          final studentDoc =
              await _firestore.collection('students').doc(loan.studentId).get();
          final studentData = studentDoc.data();
          if (studentData != null && studentData['deviceToken'] != null) {
            await _notificationService.sendPushNotification(
              phone: studentData['deviceToken'],
              title: notification.title,
              body: notification.body,
              data: {'type': notification.type, 'loanId': loanId},
            );
          }
        } catch (e) {
          // Log notification error but continue with success response
          print('Push notification failed: $e');
        }

        return {'success': true, 'message': 'Payment recorded successfully'};
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to record payment: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getAllLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Admin access required'};
      }

      final loanDocs = await _firestore.collection('loans').get();
      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to load all loans: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoansByStatus(String status) async {
    _setLoading(true);
    try {
      if (!['PENDING', 'APPROVED', 'REJECTED', 'PAID'].contains(status)) {
        return {'success': false, 'message': 'Invalid status filter'};
      }

      final loanDocs = await _firestore
          .collection('loans')
          .where('status', isEqualTo: status)
          .get();

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to filter loans: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoanTransactions(String loanId) async {
    _setLoading(true);
    try {
      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final isAdmin =
          (await _firestore.collection('admins').doc(currentUser!.uid).get())
              .exists;

      if (loan.studentId != currentUser!.uid &&
          loan.providerId != currentUser!.uid &&
          !isAdmin) {
        return {'success': false, 'message': 'Access denied'};
      }

      final transactionDocs = await _firestore
          .collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .get();

      return {
        'success': true,
        'data': transactionDocs.docs
            .map((doc) => tm.Transaction.fromFirestore(doc))
            .toList()
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to load transactions: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> sendPaymentReminder(String loanId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);

      // Only the provider or admin can send reminders
      final isAdmin =
          (await _firestore.collection('admins').doc(currentUser!.uid).get())
              .exists;
      if (loan.providerId != currentUser!.uid && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      // Create payment reminder notification
      final notification = AppNotification(
        id: '',
        userId: loan.studentId,
        title: 'Payment Reminder',
        body:
            'This is a reminder that your payment of KES ${loan.monthlyPayment.toStringAsFixed(2)} is due on ${loan.nextDueDate.day}/${loan.nextDueDate.month}/${loan.nextDueDate.year}.',
        type: 'PAYMENT_REMINDER',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toJson());

      // Send push notification
      try {
        final studentDoc =
            await _firestore.collection('students').doc(loan.studentId).get();
        final studentData = studentDoc.data();
        if (studentData != null && studentData['deviceToken'] != null) {
          await _notificationService.sendPushNotification(
            phone: studentData['deviceToken'],
            title: notification.title,
            body: notification.body,
            data: {'type': notification.type, 'loanId': loanId},
          );
        }
      } catch (e) {
        // Log notification error but continue with success response
        print('Push notification failed: $e');
      }

      return {'success': true, 'message': 'Payment reminder sent'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to send payment reminder: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Method to initiate M-Pesa payment
  Future<Map<String, dynamic>> initiateRepayment({
    required String loanId,
    required double amount,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);

      // Verify the student is making the payment
      if (loan.studentId != currentUser!.uid) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      // Initiate STK Push
      final result = await _mpesaService.initiateSTKPush(
        phone: phoneNumber,
        amount: amount,
        accountReference: 'Loan Repayment: $loanId',
        transactionDesc: 'Loan Repayment',
        businessShortCode: '174379', // From provider data
        callbackUrl: 'https://yourapp.com/mpesa-callback',
      );

      if (!result['success']) {
        return {
          'success': false,
          'message': 'Failed to initiate M-Pesa payment: ${result['message']}'
        };
      }

      // Create pending transaction record
      final pendingTransaction = tm.Transaction(
        id: '',
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: DateTime.now(),
        status: 'PENDING',
        description:
            'M-Pesa payment initiated. CheckoutRequestID: ${result['checkoutRequestId']}',
      );

      await _firestore
          .collection('transactions')
          .add(pendingTransaction.toMap());

      // Create a notification about payment initiation
      final notification = AppNotification(
        id: '',
        userId: loan.studentId,
        title: 'Payment Initiated',
        body:
            'Your M-Pesa payment of KES ${amount.toStringAsFixed(2)} has been initiated. Please check your phone and enter your PIN.',
        type: 'PAYMENT_INITIATED',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toJson());

      return {
        'success': true,
        'message':
            'M-Pesa payment initiated. Please check your phone and enter your PIN.',
        'checkoutRequestId': result['checkoutRequestId'],
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to initiate payment: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Add a method to handle M-Pesa callback
  Future<Map<String, dynamic>> processMpesaCallback({
    required Map<String, dynamic> callbackData,
  }) async {
    try {
      // Extract data from callback
      final resultCode = callbackData['Body']['stkCallback']['ResultCode'];
      final resultDesc = callbackData['Body']['stkCallback']['ResultDesc'];
      final checkoutRequestId =
          callbackData['Body']['stkCallback']['CheckoutRequestID'];

      // If transaction was successful
      if (resultCode == 0) {
        // Get transaction items
        final callbackItems =
            callbackData['Body']['stkCallback']['CallbackMetadata']['Item'];

        // Extract transaction details
        String mpesaReceiptNumber = '';
        double amount = 0.0;
        String phoneNumber = '';
        DateTime transactionDate = DateTime.now();

        for (final item in callbackItems) {
          if (item['Name'] == 'MpesaReceiptNumber') {
            mpesaReceiptNumber = item['Value'];
          } else if (item['Name'] == 'Amount') {
            amount = double.parse(item['Value'].toString());
          } else if (item['Name'] == 'PhoneNumber') {
            phoneNumber = item['Value'].toString();
          } else if (item['Name'] == 'TransactionDate') {
            // Parse transaction date from string format to DateTime
            final String dateString = item['Value'].toString();
            // Format: YYYYMMDDHHmmss
            final year = int.parse(dateString.substring(0, 4));
            final month = int.parse(dateString.substring(4, 6));
            final day = int.parse(dateString.substring(6, 8));
            final hour = int.parse(dateString.substring(8, 10));
            final minute = int.parse(dateString.substring(10, 12));
            final second = int.parse(dateString.substring(12, 14));

            transactionDate = DateTime(year, month, day, hour, minute, second);
          }
        }

        // Find the pending transaction with this checkoutRequestId
        final pendingTxQuery = await _firestore
            .collection('transactions')
            .where('description',
                isGreaterThanOrEqualTo:
                    'M-Pesa payment initiated. CheckoutRequestID: $checkoutRequestId')
            .where('description',
                isLessThan:
                    'M-Pesa payment initiated. CheckoutRequestID: $checkoutRequestId' +
                        'z')
            .where('status', isEqualTo: 'PENDING')
            .get();

        if (pendingTxQuery.docs.isEmpty) {
          return {
            'success': false,
            'message': 'No pending transaction found for this payment'
          };
        }

        final pendingTxDoc = pendingTxQuery.docs.first;
        final pendingTx = tm.Transaction.fromFirestore(pendingTxDoc);

        // Update the transaction to completed
        await _firestore
            .collection('transactions')
            .doc(pendingTxDoc.id)
            .update({
          'status': 'COMPLETED',
          'description':
              'Loan repayment via M-Pesa. Receipt: $mpesaReceiptNumber | Phone: $phoneNumber | Date: ${transactionDate.toIso8601String()}',
        });

        // Update the loan's remaining balance
        final loanDoc =
            await _firestore.collection('loans').doc(pendingTx.loanId).get();
        if (!loanDoc.exists) {
          return {'success': false, 'message': 'Loan not found'};
        }

        final loan = Loan.fromFirestore(loanDoc);
        double newBalance = loan.remainingBalance - amount;

        if (newBalance <= 0) {
          // Loan is fully paid
          await updateLoanStatus(pendingTx.loanId, 'PAID');
        } else {
          // Calculate next due date (30 days from now)
          DateTime nextDueDate = DateTime.now().add(const Duration(days: 30));

          await _firestore.collection('loans').doc(pendingTx.loanId).update({
            'remainingBalance': newBalance,
            'nextDueDate': nextDueDate,
            'updatedAt': DateTime.now(),
          });

          // Create payment confirmation notification
          final notification = AppNotification(
            id: '',
            userId: loan.studentId,
            title: 'Payment Confirmed',
            body:
                'Your payment of KES ${amount.toStringAsFixed(2)} has been confirmed. Remaining balance: KES ${newBalance.toStringAsFixed(2)}',
            type: 'PAYMENT_CONFIRMATION',
            isRead: false,
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection('notifications')
              .add(notification.toJson());

          // Send push notification
          try {
            final studentDoc = await _firestore
                .collection('students')
                .doc(loan.studentId)
                .get();
            final studentData = studentDoc.data();
            if (studentData != null && studentData['deviceToken'] != null) {
              await _notificationService.sendPushNotification(
                phone: studentData['deviceToken'],
                title: notification.title,
                body: notification.body,
                data: {'type': notification.type, 'loanId': pendingTx.loanId},
              );
            }
          } catch (e) {
            // Log notification error but continue with success response
            print('Push notification failed: $e');
          }
        }

        return {'success': true, 'message': 'Payment processed successfully'};
      } else {
        // Transaction failed
        // Find the pending transaction and mark it as failed
        final pendingTxQuery = await _firestore
            .collection('transactions')
            .where('description',
                isGreaterThanOrEqualTo:
                    'M-Pesa payment initiated. CheckoutRequestID: $checkoutRequestId')
            .where('description',
                isLessThan:
                    'M-Pesa payment initiated. CheckoutRequestID: $checkoutRequestId' +
                        'z')
            .where('status', isEqualTo: 'PENDING')
            .get();

        if (pendingTxQuery.docs.isNotEmpty) {
          final pendingTxDoc = pendingTxQuery.docs.first;
          final pendingTx = tm.Transaction.fromFirestore(pendingTxDoc);

          // Update transaction to failed
          await _firestore
              .collection('transactions')
              .doc(pendingTxDoc.id)
              .update({
            'status': 'FAILED',
            'description': 'M-Pesa payment failed: $resultDesc',
          });

          // Get loan and student information
          final loanDoc =
              await _firestore.collection('loans').doc(pendingTx.loanId).get();
          if (loanDoc.exists) {
            final loan = Loan.fromFirestore(loanDoc);

            // Create payment failure notification
            final notification = AppNotification(
              id: '',
              userId: loan.studentId,
              title: 'Payment Failed',
              body: 'Your M-Pesa payment could not be processed: $resultDesc',
              type: 'PAYMENT_FAILURE',
              isRead: false,
              createdAt: DateTime.now(),
            );

            await _firestore
                .collection('notifications')
                .add(notification.toJson());

            // Send push notification
            try {
              final studentDoc = await _firestore
                  .collection('students')
                  .doc(loan.studentId)
                  .get();
              final studentData = studentDoc.data();
              if (studentData != null && studentData['deviceToken'] != null) {
                await _notificationService.sendPushNotification(
                  phone: studentData['deviceToken'],
                  title: notification.title,
                  body: notification.body,
                  data: {'type': notification.type, 'loanId': pendingTx.loanId},
                );
              }
            } catch (e) {
              // Log notification error but continue with error response
              print('Push notification failed: $e');
            }
          }
        }

        return {'success': false, 'message': 'Payment failed: $resultDesc'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing callback: ${e.toString()}'
      };
    }
  }

  // Add method to check loan eligibility
  Future<Map<String, dynamic>> checkLoanEligibility({
    required double requestedAmount,
    required String providerId,
  }) async {
    try {
      if (currentUser == null) {
        return {'eligible': false, 'message': 'Authentication required'};
      }

      // Get student profile
      final studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'eligible': false, 'message': 'Student profile not found'};
      }

      final studentData = studentDoc.data() as Map<String, dynamic>;

      // Check if student already has an active loan
      if (studentData['hasActiveLoan'] == true) {
        return {
          'eligible': false,
          'message': 'You already have an active loan'
        };
      }

      // Check if verified
      if (studentData['verified'] != true) {
        return {
          'eligible': false,
          'message': 'Your account needs to be verified first'
        };
      }

      // Get provider details to check against provider-specific criteria
      final providerDoc =
          await _firestore.collection('providers').doc(providerId).get();
      if (!providerDoc.exists) {
        return {'eligible': false, 'message': 'Loan provider not found'};
      }

      final providerData = providerDoc.data() as Map<String, dynamic>;

      // Check if requested amount is within provider's limits
      final minAmount = providerData['minLoanAmount'] ?? 0.0;
      final maxAmount = providerData['maxLoanAmount'] ?? 0.0;

      if (requestedAmount < minAmount) {
        return {
          'eligible': false,
          'message':
              'Minimum loan amount is KES ${minAmount.toStringAsFixed(2)}'
        };
      }

      if (requestedAmount > maxAmount) {
        return {
          'eligible': false,
          'message':
              'Maximum loan amount is KES ${maxAmount.toStringAsFixed(2)}'
        };
      }

      // For demonstration, simple credit score check
      // In a real application, you would use a more sophisticated creditworthiness algorithm
      final creditScore = studentData['creditScore'] ?? 0;
      final minRequiredScore = providerData['minCreditScore'] ?? 600;

      if (creditScore < minRequiredScore) {
        return {
          'eligible': false,
          'message': 'Your credit score does not meet the minimum requirements'
        };
      }

      // Check if student's education institution is approved by the provider
      final studentInstitution = studentData['institutionName'] ?? '';
      final approvedInstitutions =
          List<String>.from(providerData['approvedInstitutions'] ?? []);

      if (approvedInstitutions.isNotEmpty &&
          !approvedInstitutions.contains(studentInstitution)) {
        return {
          'eligible': false,
          'message':
              'Your educational institution is not supported by this provider'
        };
      }

      // Student is eligible for the loan
      return {
        'eligible': true,
        'message': 'You are eligible for this loan',
        'maxAmount': maxAmount,
        'interestRate': providerData['interestRate'] ?? 0.0,
      };
    } catch (e) {
      return {
        'eligible': false,
        'message': 'Error checking eligibility: ${e.toString()}'
      };
    }
  }

  // Method to get loan statistics for a student
  Future<Map<String, dynamic>> getStudentLoanStatistics() async {
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final loanDocs = await _firestore
          .collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .get();

      if (loanDocs.docs.isEmpty) {
        return {
          'success': true,
          'data': {
            'totalLoansCount': 0,
            'totalBorrowed': 0.0,
            'totalRepaid': 0.0,
            'activeLoanCount': 0,
            'completedLoanCount': 0,
          }
        };
      }

      int totalLoansCount = loanDocs.docs.length;
      double totalBorrowed = 0.0;
      double totalRepaid = 0.0;
      int activeLoanCount = 0;
      int completedLoanCount = 0;

      for (final doc in loanDocs.docs) {
        final loan = Loan.fromFirestore(doc);

        totalBorrowed += loan.amount;

        if (loan.status == 'APPROVED' || loan.status == 'PENDING') {
          activeLoanCount++;
          // Calculate repaid amount
          totalRepaid += (loan.amount - loan.remainingBalance);
        } else if (loan.status == 'PAID') {
          completedLoanCount++;
          totalRepaid += loan.amount; // Fully repaid
        }
      }

      return {
        'success': true,
        'data': {
          'totalLoansCount': totalLoansCount,
          'totalBorrowed': totalBorrowed,
          'totalRepaid': totalRepaid,
          'activeLoanCount': activeLoanCount,
          'completedLoanCount': completedLoanCount,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load loan statistics: ${e.toString()}'
      };
    }
  }
}
