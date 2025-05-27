import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;

class PaymentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> makeRepayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
    String? note,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please sign in.'
        };
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);

      if (loan.studentId != currentUser!.uid) {
        return {
          'success': false,
          'message': 'Only the loan borrower can make repayments'
        };
      }

      if (loan.status != 'APPROVED') {
        return {
          'success': false,
          'message': 'Payments only allowed for approved loans'
        };
      }

      // Validate payment amount
      if (amount <= 0) {
        return {
          'success': false,
          'message': 'Invalid payment amount'
        };
      }

      if (amount > loan.remainingBalance) {
        return {
          'success': false,
          'message': 'Payment amount cannot exceed remaining balance'
        };
      }

      final now = DateTime.now();

      // Create repayment transaction
      final transaction = tm.Transaction(
        id: '',
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: now,
        status: 'COMPLETED',
        description: note?.isNotEmpty == true 
            ? 'Loan repayment - $note' 
            : 'Loan repayment via $paymentMethod',
      );

      // Calculate new remaining balance
      final newRemainingBalance = loan.remainingBalance - amount;
      final isFullyPaid = newRemainingBalance <= 0;

      // Use batch write for atomic operations
      final batch = _firestore.batch();

      // Add transaction
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, transaction.toMap());

      // Update loan
      final loanUpdateData = <String, dynamic>{
        'remainingBalance': newRemainingBalance.clamp(0, double.infinity),
        'updatedAt': now,
      };

      // If loan is fully paid, update status and student record
      if (isFullyPaid) {
        loanUpdateData['status'] = 'PAID';
        
        // Update student's active loan status
        final studentRef = _firestore.collection('students').doc(loan.studentId);
        batch.update(studentRef, {
          'hasActiveLoan': false,
          'updatedAt': now,
        });
      } else {
        // Update next due date (advance by 30 days for monthly payments)
        loanUpdateData['nextDueDate'] = loan.nextDueDate.add(const Duration(days: 30));
      }

      final loanRef = _firestore.collection('loans').doc(loanId);
      batch.update(loanRef, loanUpdateData);

      // Commit all changes atomically
      await batch.commit();

      return {
        'success': true,
        'message': isFullyPaid
            ? 'Congratulations! Your loan has been fully paid!'
            : 'Payment processed successfully',
        'transaction': transaction.copyWith(id: transactionRef.id),
        'loanPaid': isFullyPaid,
        'remainingAmount': newRemainingBalance.clamp(0, double.infinity),
      };
    } catch (e) {
      debugPrint('Error in makeRepayment: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Payment processing failed. Please check your connection and try again.'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStudentTransactions() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please sign in.'
        };
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

      if (loanDocs.docs.isEmpty) {
        return {'success': true, 'data': <tm.Transaction>[]};
      }

      List<tm.Transaction> allTransactions = [];
      for (var loanDoc in loanDocs.docs) {
        final transactionDocs = await _firestore
            .collection('transactions')
            .where('loanId', isEqualTo: loanDoc.id)
            .orderBy('createdAt', descending: true)
            .get();

        allTransactions.addAll(transactionDocs.docs
            .map((doc) => tm.Transaction.fromFirestore(doc)));
      }

      // Sort all transactions by date (most recent first)
      allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return {'success': true, 'data': allTransactions};
    } catch (e) {
      debugPrint('Error in getStudentTransactions: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve payment history'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getRemainingBalance(String loanId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please sign in.'
        };
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();

      final isAuthorized = loan.studentId == currentUser!.uid ||
          loan.providerId == currentUser!.uid ||
          adminDoc.exists;

      if (!isAuthorized) {
        return {'success': false, 'message': 'Unauthorized to view this loan'};
      }

      final transactionDocs = await _firestore
          .collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .where('type', isEqualTo: 'REPAYMENT')
          .get();

      final totalRepaid = transactionDocs.docs.fold(
          0.0,
          (accumulated, doc) =>
              accumulated + tm.Transaction.fromFirestore(doc).amount);
      final remainingBalance =
          (loan.amount - totalRepaid).clamp(0, loan.amount);

      return {
        'success': true,
        'data': {
          'loanAmount': loan.amount,
          'totalRepaid': totalRepaid,
          'remainingBalance': remainingBalance,
          'isFullyPaid': remainingBalance <= 0
        }
      };
    } catch (e) {
      debugPrint('Error in getRemainingBalance: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to calculate balance. Please try again.'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please sign in.'
        };
      }

      final transactionDoc =
          await _firestore.collection('transactions').doc(transactionId).get();
      if (!transactionDoc.exists) {
        return {'success': false, 'message': 'Transaction not found'};
      }

      final transaction = tm.Transaction.fromFirestore(transactionDoc);
      final loanDoc =
          await _firestore.collection('loans').doc(transaction.loanId).get();

      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Associated loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();

      final isAuthorized = loan.studentId == currentUser!.uid ||
          loan.providerId == currentUser!.uid ||
          adminDoc.exists;

      if (!isAuthorized) {
        return {
          'success': false,
          'message': 'Unauthorized to view this transaction'
        };
      }

      return {'success': true, 'data': transaction};
    } catch (e) {
      debugPrint('Error in getTransactionById: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve transaction details'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoanTransactions(String loanId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please sign in.'
        };
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();

      final isAuthorized = loan.studentId == currentUser!.uid ||
          loan.providerId == currentUser!.uid ||
          adminDoc.exists;

      if (!isAuthorized) {
        return {'success': false, 'message': 'Unauthorized to view this loan'};
      }

      final transactionDocs = await _firestore
          .collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .orderBy('createdAt', descending: true)
          .get();

      final transactions = transactionDocs.docs
          .map((doc) => tm.Transaction.fromFirestore(doc))
          .toList();

      return {'success': true, 'data': transactions};
    } catch (e) {
      debugPrint('Error in getLoanTransactions: $e');
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve loan transactions'
      };
    } finally {
      _setLoading(false);
    }
  }
}