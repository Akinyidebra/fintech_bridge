import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fintech_bridge/models/provider_model.dart' as model;
import 'package:fintech_bridge/services/mpesa_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;
import 'package:fintech_bridge/models/notification_model.dart';

class LoanService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MpesaService _mpesaService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

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
        'message': 'Failed to submit loan request. Please try again.'
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
      return {'success': false, 'message': 'Failed to load loan details'};
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
      return {'success': false, 'message': 'Failed to load your loans'};
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
      return {'success': false, 'message': 'Failed to load provider loans'};
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
        final result = await _mpesaService.disburseLoan(
          phone: loan.mpesaPhone,
          amount: loan.amount,
          loanId: loan.id,
          businessShortCode: '174379', // From provider data
          callbackUrl: 'https://yourapp.com/mpesa-callback',
        );

        final transaction = tm.Transaction(
          id: '',
          loanId: loanId,
          amount: loan.amount,
          type: 'DISBURSEMENT',
          createdAt: DateTime.now(),
          status: 'COMPLETED',
          description: 'Loan disbursement',
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
      }

      return {
        'success': true,
        'message': 'Loan status updated to ${status.toLowerCase()}'
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update loan status'};
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

      // Create a payment transaction
      final transaction = tm.Transaction(
        id: '',
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: DateTime.now(),
        status: 'COMPLETED',
        description: 'Loan repayment via M-Pesa',
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

        return {'success': true, 'message': 'Payment recorded successfully'};
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to record payment'};
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
      return {'success': false, 'message': 'Failed to load all loans'};
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
      return {'success': false, 'message': 'Failed to filter loans'};
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
      return {'success': false, 'message': 'Failed to load transactions'};
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

      return {'success': true, 'message': 'Payment reminder sent'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to send payment reminder'};
    } finally {
      _setLoading(false);
    }
  }
}
