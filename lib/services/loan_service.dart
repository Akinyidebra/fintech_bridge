import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fintech_bridge/models/provider_model.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;
import 'package:fintech_bridge/models/notification_model.dart';

class LoanService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Simple constructor - no dependencies
  LoanService();

  // Factory method simplified
  factory LoanService.initialize() {
    return LoanService();
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
      debugPrint('Error getting student: $e');
      throw Exception('Failed to get student information: $e');
    }
  }

  Future<List<model.Provider>> getVerifiedProviders() async {
    try {
      final snapshot = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => model.Provider.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching providers: $e');
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
      debugPrint('Starting loan request creation...');

      if (currentUser == null) {
        debugPrint('User not authenticated');
        return {
          'success': false,
          'message': 'Please sign in to request a loan'
        };
      }

      // Check minimum loan amount
      const double minAmount = 100.0;
      if (amount < minAmount) {
        debugPrint('Amount below minimum: $amount');
        return {
          'success': false,
          'message':
              'Minimum loan amount is KES ${minAmount.toStringAsFixed(2)}'
        };
      }

      debugPrint('Checking student profile...');
      final studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();

      if (!studentDoc.exists) {
        debugPrint('Student profile not found');
        return {
          'success': false,
          'message': 'Only verified students can request loans'
        };
      }

      final studentData = studentDoc.data() as Map<String, dynamic>;
      if (studentData['hasActiveLoan'] == true) {
        debugPrint('Student has active loan');
        return {
          'success': false,
          'message':
              'You already have an active loan. Please repay your current loan before applying for a new one.'
        };
      }

      debugPrint('Creating loan object...');
      final now = DateTime.now();
      final nextDueDate = now.add(const Duration(days: 30));

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
        nextDueDate: nextDueDate,
        mpesaTransactionCode: '',
        repaymentMethod: repaymentMethod,
        repaymentStartDate: repaymentStartDate,
        latePaymentPenaltyRate: 5.0,
        createdAt: now,
        updatedAt: now,
        providerName: providerName,
        loanType: loanType,
        institutionName: institutionName,
        mpesaPhone: mpesaPhone,
      );

      debugPrint('Saving loan to Firestore...');
      final loanRef = await _firestore.collection('loans').add(loan.toMap());
      debugPrint('Loan created with ID: ${loanRef.id}');

      // Create notification - SIMPLIFIED (no external service)
      debugPrint('Creating notification...');
      final notification = AppNotification(
        id: '',
        userId: currentUser!.uid,
        title: 'Loan Request Submitted',
        body:
            'Your loan request for KES ${amount.toStringAsFixed(2)} has been submitted for review.',
        type: 'LOAN_REQUEST',
        isRead: false,
        createdAt: now,
      );

      await _firestore.collection('notifications').add(notification.toJson());
      debugPrint('Notification created');

      // FIXED: Create APPLICATION transaction with consistent timestamp
      debugPrint('Creating application transaction...');
      final applicationTransaction = tm.Transaction(
        id: '',
        loanId: loanRef.id,
        amount: amount,
        type: 'APPLICATION',
        createdAt: now, // Use same timestamp as loan
        status: 'PENDING',
        description:
            'Loan application submitted for KES ${amount.toStringAsFixed(2)}',
      );

      // Use consistent timestamp approach
      final transactionData = applicationTransaction.toMap();

      await _firestore.collection('transactions').add(transactionData);
      debugPrint('Transaction created');

      debugPrint('Loan request completed successfully');
      return {
        'success': true,
        'message': 'Loan request submitted for review',
        'loan': loan.copyWith(id: loanRef.id)
      };
    } catch (e) {
      debugPrint('Error in createLoanRequest: $e');

      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        if (e.code == 'unavailable') {
          return {'success': false, 'message': 'No internet connection'};
        }
      }

      return {
        'success': false,
        'message': 'Failed to submit loan request. Please try again.'
      };
    } finally {
      debugPrint('Setting loading to false');
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
      debugPrint('Error getting loan by ID: $e');
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

      debugPrint('Fetching loans for student: ${currentUser!.uid}');

      // First check if student exists
      final studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        debugPrint('Student account not found');
        return {'success': false, 'message': 'Student account not found'};
      }

      // Query loans with proper ordering - most recent first
      final loanQuery = _firestore
          .collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true); // This ensures newest first

      final loanDocs = await loanQuery.get();

      debugPrint('Found ${loanDocs.docs.length} loans for student');

      if (loanDocs.docs.isEmpty) {
        debugPrint('No loans found for this student');
        return {'success': true, 'data': <Loan>[], 'message': 'No loans found'};
      }

      final loans = loanDocs.docs.map((doc) {
        debugPrint('Processing loan: ${doc.id}');
        return Loan.fromFirestore(doc);
      }).toList();

      debugPrint('Successfully processed ${loans.length} loans');

      return {'success': true, 'data': loans};
    } catch (e) {
      debugPrint('Error getting student loans: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        if (e.code == 'unavailable') {
          return {'success': false, 'message': 'No internet connection'};
        } else if (e.code == 'failed-precondition') {
          return {
            'success': false,
            'message': 'Database index required. Please contact support.'
          };
        }
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

      debugPrint('Fetching loans for provider: ${currentUser!.uid}');

      final providerDoc =
          await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'Provider account not found'};
      }

      // Query with proper ordering - most recent first
      final loanQuery = _firestore
          .collection('loans')
          .where('providerId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true);

      final loanDocs = await loanQuery.get();

      debugPrint('Found ${loanDocs.docs.length} loans for provider');

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      debugPrint('Error getting provider loans: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        if (e.code == 'unavailable') {
          return {'success': false, 'message': 'No internet connection'};
        } else if (e.code == 'failed-precondition') {
          return {
            'success': false,
            'message': 'Database index required. Please contact support.'
          };
        }
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
      debugPrint('Updating loan status to: $status');

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

      // Use batch write for atomic operations
      final batch = _firestore.batch();
      final loanRef = _firestore.collection('loans').doc(loanId);
      final now = DateTime.now();

      Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': now,
      };

      // Add simulated M-Pesa transaction code
      if (status == 'APPROVED') {
        updateData['mpesaTransactionCode'] =
            mpesaTransactionCode ?? 'SIM${now.millisecondsSinceEpoch}';
      }

      batch.update(loanRef, updateData);

      if (status == 'APPROVED') {
        // FIXED: Simulate disbursement with consistent timestamp
        final transaction = tm.Transaction(
          id: '',
          loanId: loanId,
          amount: loan.amount,
          type: 'DISBURSEMENT',
          createdAt: now,
          status: 'COMPLETED',
          description:
              '💰 Loan disbursement completed (SIMULATED - No real money transferred)',
        );

        final transactionRef = _firestore.collection('transactions').doc();
        batch.set(transactionRef, transaction.toMap());

        // Update student status
        final studentRef =
            _firestore.collection('students').doc(loan.studentId);
        batch.update(studentRef, {
          'hasActiveLoan': true,
          'updatedAt': now,
        });

        // Create notification
        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: '🎉 Loan Approved!',
          body:
              'Your loan request for KES ${loan.amount.toStringAsFixed(2)} has been approved and disbursed (SIMULATED).',
          type: 'LOAN_APPROVAL',
          isRead: false,
          createdAt: now,
        );

        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, notification.toJson());
      } else if (status == 'REJECTED') {
        final transaction = tm.Transaction(
          id: '',
          loanId: loanId,
          amount: 0,
          type: 'REJECTION',
          createdAt: now,
          status: 'COMPLETED',
          description: '❌ Loan application rejected',
        );

        final transactionRef = _firestore.collection('transactions').doc();
        batch.set(transactionRef, transaction.toMap());

        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: 'Loan Request Rejected',
          body:
              'Your loan request for KES ${loan.amount.toStringAsFixed(2)} has been rejected.',
          type: 'LOAN_REJECTION',
          isRead: false,
          createdAt: now,
        );

        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, notification.toJson());
      } else if (status == 'PAID') {
        final transaction = tm.Transaction(
          id: '',
          loanId: loanId,
          amount: loan.remainingBalance,
          type: 'PAYMENT',
          createdAt: now,
          status: 'COMPLETED',
          description: '✅ Loan fully paid (SIMULATED)',
        );

        final transactionRef = _firestore.collection('transactions').doc();
        batch.set(transactionRef, transaction.toMap());

        // Update student status
        final studentRef =
            _firestore.collection('students').doc(loan.studentId);
        batch.update(studentRef, {
          'hasActiveLoan': false,
          'updatedAt': now,
        });

        final notification = AppNotification(
          id: '',
          userId: loan.studentId,
          title: '🎊 Loan Fully Paid!',
          body:
              'Congratulations! Your loan of KES ${loan.amount.toStringAsFixed(2)} has been fully paid.',
          type: 'LOAN_PAID',
          isRead: false,
          createdAt: now,
        );

        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, notification.toJson());
      }

      // Commit all operations atomically
      await batch.commit();
      debugPrint('Loan status updated successfully');

      return {
        'success': true,
        'message': 'Loan status updated to ${status.toLowerCase()}'
      };
    } catch (e) {
      debugPrint('Error updating loan status: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update loan status'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoanTransactions(String loanId) async {
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
      final isAdmin =
          (await _firestore.collection('admins').doc(currentUser!.uid).get())
              .exists;

      if (loan.studentId != currentUser!.uid &&
          loan.providerId != currentUser!.uid &&
          !isAdmin) {
        return {'success': false, 'message': 'Access denied'};
      }

      debugPrint('Fetching transactions for loan: $loanId');

      // Query transactions ordered by latest first
      final transactionQuery = _firestore
          .collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .orderBy('createdAt', descending: true);

      final transactionDocs = await transactionQuery.get();

      debugPrint(
          'Found ${transactionDocs.docs.length} transactions for loan: $loanId');

      final transactions = transactionDocs.docs
          .map((doc) => tm.Transaction.fromFirestore(doc))
          .toList();

      return {'success': true, 'data': transactions};
    } catch (e) {
      debugPrint('Error getting loan transactions: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        if (e.code == 'unavailable') {
          return {'success': false, 'message': 'No internet connection'};
        } else if (e.code == 'failed-precondition') {
          return {
            'success': false,
            'message': 'Database index required. Please contact support.'
          };
        }
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
        title: '⏰ Payment Reminder',
        body:
            'This is a reminder that your payment of KES ${loan.monthlyPayment.toStringAsFixed(2)} is due on ${loan.nextDueDate.day}/${loan.nextDueDate.month}/${loan.nextDueDate.year}.',
        type: 'PAYMENT_REMINDER',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toJson());
      debugPrint('Payment reminder sent');

      return {'success': true, 'message': 'Payment reminder sent successfully'};
    } catch (e) {
      debugPrint('Error sending payment reminder: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to send payment reminder'};
    } finally {
      _setLoading(false);
    }
  }

  // Method to initiate M-Pesa payment (SIMULATED)
  Future<Map<String, dynamic>> initiateRepayment({
    required String loanId,
    required double amount,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      debugPrint('Initiating repayment: $amount for loan: $loanId');

      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);

      if (loan.studentId != currentUser!.uid) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      // Simulate STK Push (always successful for testing)
      final now = DateTime.now();
      final simulatedCheckoutId = 'ws_CO_${now.millisecondsSinceEpoch}';

      // FIXED: Create pending transaction record with consistent timestamp
      final pendingTransaction = tm.Transaction(
        id: '',
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: now,
        status: 'PENDING',
        description:
            '📱 Payment initiated (SIMULATED). CheckoutRequestID: $simulatedCheckoutId',
      );

      await _firestore
          .collection('transactions')
          .add(pendingTransaction.toMap());

      final notification = AppNotification(
        id: '',
        userId: loan.studentId,
        title: '📱 Payment Initiated',
        body:
            'Your payment of KES ${amount.toStringAsFixed(2)} has been initiated (SIMULATED MODE).',
        type: 'PAYMENT_INITIATED',
        isRead: false,
        createdAt: now,
      );

      await _firestore.collection('notifications').add(notification.toJson());
      debugPrint('Payment initiation completed');

      return {
        'success': true,
        'message': 'Payment initiated successfully (SIMULATED MODE)',
        'checkoutRequestId': simulatedCheckoutId,
      };
    } catch (e) {
      debugPrint('Error initiating repayment: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to initiate payment'};
    } finally {
      _setLoading(false);
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
          'message':
              'You already have an active loan. Please complete repayment before applying for a new loan.'
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

      // Check minimum loan amount (100 KES as per your requirement)
      const double minAmount = 100.0; // Minimum 100 KES

      if (requestedAmount < minAmount) {
        return {
          'eligible': false,
          'message':
              'Minimum loan amount is KES ${minAmount.toStringAsFixed(2)}'
        };
      }

      // Optional: Set a reasonable maximum based on your business logic
      // You can remove this check if you don't want any maximum limit
      const double maxAmount =
          1000000.0; // 1 Million KES as reasonable upper limit

      if (requestedAmount > maxAmount) {
        return {
          'eligible': false,
          'message':
              'Maximum loan amount is KES ${maxAmount.toStringAsFixed(2)}'
        };
      }

      // Basic credit score check (optional - you can remove this if not needed)
      // For demonstration purposes, assuming a default credit score
      final creditScore =
          studentData['creditScore'] ?? 650; // Default score if not set
      const int minRequiredScore = 500; // Lower minimum requirement

      if (creditScore < minRequiredScore) {
        return {
          'eligible': false,
          'message': 'Your credit score does not meet the minimum requirements'
        };
      }

      // Student is eligible for the loan
      return {
        'eligible': true,
        'message': 'You are eligible for this loan',
        'maxAmount': maxAmount, // Or remove this if no max limit
        'interestRate':
            providerData['interestRate'] ?? 10.0, // Default 10% if not set
      };
    } catch (e) {
      return {
        'eligible': false,
        'message': 'Error checking eligibility: ${e.toString()}'
      };
    }
  }
}
